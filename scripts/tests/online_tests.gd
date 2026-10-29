class_name OnlineTests
extends Node
## Autotest de la base online (docs/PLAN_ONLINE.md, O-0): un servidor y varios clientes en este mismo proceso (cada
## NetPeer con su MultiplayerAPI) por 127.0.0.1, el autoload Net y el modo `-- --server` en otro proceso.
##   godot --headless --path . --quit-after 60000 -- --autotest-online

const PORT := 24781
const PORT_PROCESS := 24782

var autotest: Node
var r := {}


func run() -> void:
	GameState.new_game(DB.species["charmander"])
	var version := Net.game_version()
	r["Versión del juego: huella estable de los datos"] = version == Net.game_version() and version.begins_with("%d-" % NetPeer.PROTOCOL)

	var server := _peer("Server")
	r["El servidor abre el puerto"] = server.host(PORT, version) == OK

	var a := _peer("A")
	a.join("127.0.0.1", PORT, {"version": version, "name": "Ash", "team": [{"species": "pikachu", "level": 12}]})
	r["Cliente A: conectando"] = a.state == "connecting"
	await _until(func(): return a.state == "online" and a.players.size() == 1)
	r["Cliente A entra a la sala y se ve en la lista"] = a.state == "online" and a.my_id > 1 and a.players.size() == 1 \
		and a.players[0].name == "Ash" and a.players[0].status == "libre"

	# Mismo nombre: se distingue. Equipo con basura: se limpia.
	var b := _peer("B")
	b.join("127.0.0.1", PORT, {"version": version, "name": "  Ash  ",
		"team": [{"species": "bulbasaur", "level": 250}, {"species": "no_existe", "level": 5}, "basura"]})
	await _until(func(): return b.state == "online" and a.players.size() == 2)
	var b_entry := _entry(a, b.my_id)
	r["Cliente B entra: los dos se ven"] = a.players.size() == 2 and b.players.size() == 2
	r["Nombre repetido: queda \"Ash (2)\""] = b_entry.get("name") == "Ash (2)"
	r["Equipo raro: solo especies que existen y nivel de 1 a 100"] = b_entry.get("team") == [{"species": "bulbasaur", "level": 100}]

	b.send_status("peleando")
	b.send_team([{"species": "ivysaur", "level": 16}])
	await _until(func(): return _entry(a, b.my_id).get("status") == "peleando" and _entry(a, b.my_id).get("team", [{}])[0].get("species") == "ivysaur")
	r["Estado y equipo nuevos llegan a los demás"] = _entry(a, b.my_id).get("status") == "peleando" \
		and _entry(a, b.my_id).team[0].level == 16
	b.send_status("inventado")
	await get_tree().create_timer(0.3).timeout
	r["Un estado que no existe se ignora"] = _entry(a, b.my_id).get("status") == "peleando"

	# Otra versión: no entra.
	var c := _peer("C")
	c.join("127.0.0.1", PORT, {"version": "0-viejo", "name": "Gary", "team": []})
	await _until(func(): return c.state == "rejected")
	await get_tree().create_timer(0.5).timeout
	r["Otra versión: rechazado con aviso de bajar el zip nuevo"] = c.state == "rejected" and a.players.size() == 2

	# Conecta y no se presenta: lo echa.
	server.hello_timeout = 1.0
	var raw := ENetMultiplayerPeer.new()
	raw.create_client("127.0.0.1", PORT)
	var t := 0.0
	while t < 3.0:
		if raw.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
			break
		raw.poll()
		await get_tree().process_frame
		t += get_process_delta_time()
	r["Conectado sin presentarse: lo echa"] = server._pending.is_empty() \
		and raw.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED
	raw.close()

	# B se va: A lo ve.
	b.close()
	r["B se desconecta: queda offline"] = b.state == "offline"
	await _until(func(): return a.players.size() == 1)
	r["Los demás ven que se fue"] = a.players.size() == 1 and server.players.size() == 1

	# El autoload Net (el del juego) contra el mismo servidor, con avisos por Events.
	var seen := []
	var on_state := func(s, _m): seen.append(s)
	Events.online_state_changed.connect(on_state)
	var lists := []
	var on_list := func(p): lists.append(p.size())
	Events.online_players_changed.connect(on_list)
	Net.address = "127.0.0.1"
	Net.port = PORT
	Net.player_name = "Rojo"
	Net.go_online()
	await _until(func(): return Net.is_online() and Net.players.size() == 2)
	r["Net: se conecta con el nombre y el equipo de la partida"] = Net.is_online() and _entry(a, Net.client.my_id).get("name") == "Rojo" \
		and _entry(a, Net.client.my_id).get("team") == [{"species": "charmander", "level": GameState.party[0].level}]
	r["Net: avisa por Events (estado y lista)"] = "connecting" in seen and "online" in seen and lists.has(2)

	# Se cae el servidor: los clientes quedan offline con aviso.
	server.close()
	await _until(func(): return a.state == "offline" and Net.state == "offline", 12.0)
	r["Se cae el servidor: los clientes quedan offline"] = a.state == "offline" and Net.state == "offline" and a.players.is_empty()
	Events.online_state_changed.disconnect(on_state)
	Events.online_players_changed.disconnect(on_list)

	# Nadie escuchando: no se encuentra.
	var d := _peer("D")
	d.join("127.0.0.1", PORT + 7, {"version": version, "name": "Nadie", "team": []})
	await _until(func(): return d.state == "offline", 12.0)
	r["Sin servidor: avisa que no lo encuentra"] = d.state == "offline"

	await _server_process_test(version)
	_results()


## El modo servidor de verdad: otro proceso con -- --server.
func _server_process_test(version: String) -> void:
	var args := ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--quit-after", "3000", "--",
		"--server", "--port", str(PORT_PROCESS)]
	var pid := OS.create_process(OS.get_executable_path(), args)
	var e := _peer("E")
	var t := 0.0
	# Arranca en unos segundos (carga los datos); se reintenta hasta que conteste.
	while t < 40.0 and e.state != "online":
		if e.state == "offline":
			e.join("127.0.0.1", PORT_PROCESS, {"version": version, "name": "Proceso", "team": []})
		await get_tree().create_timer(0.5).timeout
		t += 0.5
	r["Modo --server (otro proceso): se conecta, misma versión"] = e.state == "online" and e.players.size() == 1
	e.close()
	if pid > 0:
		OS.kill(pid)


func _peer(n: String) -> NetPeer:
	var p := NetPeer.new()
	p.name = n
	add_child(p)
	return p


func _entry(p: NetPeer, id: int) -> Dictionary:
	for e in p.players:
		if e.id == id:
			return e
	return {}


func _until(cond: Callable, limit: float = 5.0) -> void:
	var t := 0.0
	while t < limit and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func _results() -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[online] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-online] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
