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

	await _challenge_tests(server, a, b, version)
	await _battle_tests(server, a, b)

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


## O-2: desafiar, contestar, elegir equipo, tiempos y desconexiones.
func _challenge_tests(server: NetPeer, a: NetPeer, b: NetPeer, version: String) -> void:
	server.host_battles = false  # acá solo la sala (O-2); la pelea se prueba aparte (_battle_tests)
	b.send_status("libre")
	await _until(func(): return _entry(a, b.my_id).get("status") == "libre")
	var log := []
	for p in [a, b]:
		var who := "A" if p == a else "B"
		p.challenged.connect(func(id, n, c): log.append([who, "desafio", id, n, c]))
		p.challenge_withdrawn.connect(func(id): log.append([who, "retirado", id]))
		p.challenge_answered.connect(func(id, ok, m): log.append([who, "respuesta", id, ok, m]))
		p.match_choose.connect(func(mid, o, c, t): log.append([who, "elegir", mid, o, c, t]))
		p.match_ready.connect(func(mid, o, team): log.append([who, "lista", mid, o, team]))
		p.match_cancelled.connect(func(mid, why): log.append([who, "cancelada", mid, why]))
	var last := func(who: String, kind: String):
		for i in range(log.size() - 1, -1, -1):
			if log[i][0] == who and log[i][1] == kind:
				return log[i]
		return null

	# Lo que no se puede.
	a.send_challenge(a.my_id, 3)
	await _until(func(): return last.call("A", "respuesta") != null)
	r["Desafiarse a uno mismo: no"] = last.call("A", "respuesta") != null and not last.call("A", "respuesta")[3]
	log.clear()
	a.send_challenge(b.my_id, 4)
	await _until(func(): return last.call("A", "respuesta") != null)
	r["Formato que no existe (4): no"] = last.call("A", "respuesta") != null and not last.call("A", "respuesta")[3]

	# Rechazar.
	log.clear()
	a.send_challenge(b.my_id, 3)
	await _until(func(): return last.call("B", "desafio") != null)
	var got = last.call("B", "desafio")
	r["B recibe el desafío de A (3 contra 3)"] = got != null and got[2] == a.my_id and got[3] == "Ash" and got[4] == 3
	b.send_challenge(a.my_id, 1)
	await _until(func(): return last.call("B", "respuesta") != null)
	r["Con un desafío pendiente no se puede mandar otro"] = last.call("B", "respuesta") != null and not last.call("B", "respuesta")[3]
	b.send_answer(a.my_id, false)
	await _until(func(): return last.call("A", "respuesta") != null)
	r["B rechaza: A se entera"] = last.call("A", "respuesta") != null and not last.call("A", "respuesta")[3] 		and "no aceptó" in last.call("A", "respuesta")[4]

	# Retirar.
	log.clear()
	a.send_challenge(b.my_id, 1)
	await _until(func(): return last.call("B", "desafio") != null)
	a.send_withdraw()
	await _until(func(): return last.call("B", "retirado") != null)
	r["A retira el desafío: B se entera"] = last.call("B", "retirado") != null

	# Sin contestar: se cae solo.
	log.clear()
	server.answer_timeout = 0.5
	a.send_challenge(b.my_id, 1)
	await _until(func(): return last.call("A", "respuesta") != null, 3.0)
	r["Sin contestar a tiempo: se cae (\"no contestó\")"] = last.call("A", "respuesta") != null 		and "no contestó" in last.call("A", "respuesta")[4] and last.call("B", "retirado") != null
	server.answer_timeout = NetPeer.ANSWER_TIMEOUT

	# Aceptar → elegir → lista.
	log.clear()
	a.send_challenge(b.my_id, 3)
	await _until(func(): return last.call("B", "desafio") != null)
	b.send_answer(a.my_id, true)
	await _until(func(): return last.call("A", "elegir") != null and last.call("B", "elegir") != null)
	var ca = last.call("A", "elegir")
	var cb = last.call("B", "elegir")
	r["Acepta: los dos eligen equipo (contra quién, formato y tiempo)"] = ca != null and cb != null and ca[2] == cb[2] 		and ca[3].name == "Ash (2)" and cb[3].name == "Ash" and ca[4] == 3 and ca[5] == NetPeer.CHOOSE_TIMEOUT
	await _until(func(): return _entry(a, b.my_id).get("status") == "eligiendo")
	r["Mientras eligen figuran \"eligiendo\""] = _entry(a, a.my_id).get("status") == "eligiendo" and _entry(a, b.my_id).get("status") == "eligiendo"
	var team_a := [CreatureInstance.create(DB.species["pikachu"], 12), CreatureInstance.create(DB.species["pidgey"], 9),
		CreatureInstance.create(DB.species["rattata"], 8), CreatureInstance.create(DB.species["onix"], 14)]
	var fainted := CreatureInstance.create(DB.species["caterpie"], 5)
	fainted.hp = 0.0
	a.send_choice(ca[2], team_a)
	b.send_choice(cb[2], [fainted, CreatureInstance.create(DB.species["ivysaur"], 16)])
	await _until(func(): return last.call("A", "lista") != null and last.call("B", "lista") != null)
	var ra = last.call("A", "lista")
	var rb = last.call("B", "lista")
	r["Los dos eligieron: cada uno sabe con qué viene el otro"] = ra != null and rb != null 		and ra[4].map(func(d): return d.species_id) == ["ivysaur"] and rb[4].map(func(d): return d.species_id) == ["pikachu", "pidgey", "rattata"]
	r["Del equipo se saca el debilitado y lo que pasa del formato"] = rb != null and rb[4].size() == 3 and ra[4].size() == 1
	r["Lleva todo el Pokémon (nivel, ataques, habilidad)"] = rb != null and rb[4][0].level == 12 and rb[4][0].has("equipped_moves") and rb[4][0].has("ability")
	await _until(func(): return _entry(a, a.my_id).get("status") == "libre" and server.matches.is_empty())
	r["Sin pelea (host_battles apagado): vuelven a estar libres"] = server.matches.is_empty() and _entry(a, a.my_id).get("status") == "libre"

	# No eligen a tiempo: se cancela.
	log.clear()
	server.choose_timeout = 0.2
	a.send_challenge(b.my_id, 1)
	await _until(func(): return last.call("B", "desafio") != null)
	b.send_answer(a.my_id, true)
	await _until(func(): return last.call("A", "cancelada") != null, NetPeer.CHOOSE_GRACE + 3.0)
	r["Si no eligen a tiempo, se cancela para los dos"] = last.call("A", "cancelada") != null and last.call("B", "cancelada") != null 		and server.matches.is_empty()
	server.choose_timeout = NetPeer.CHOOSE_TIMEOUT

	# Se desconecta mientras eligen: al otro se le cancela.
	log.clear()
	var c2 := _peer("C2")
	c2.join("127.0.0.1", PORT, {"version": version, "name": "Gary", "team": [{"species": "eevee", "level": 10}]})
	await _until(func(): return c2.state == "online" and a.players.size() == 3)
	a.send_challenge(c2.my_id, 1)
	await _until(func(): return true, 0.3)
	c2.send_answer(a.my_id, true)
	await _until(func(): return last.call("A", "elegir") != null)
	c2.close()
	await _until(func(): return last.call("A", "cancelada") != null, 12.0)
	r["Se desconecta mientras eligen: al otro se le cancela"] = last.call("A", "cancelada") != null 		and "desconectó" in last.call("A", "cancelada")[3]
	await _until(func(): return a.players.size() == 2)


## O-3: la pelea en el servidor. A (fuerte, un bot que se acerca y pega) contra B (dos débiles; cambia al segundo).
func _battle_tests(server: NetPeer, a: NetPeer, b: NetPeer) -> void:
	server.host_battles = true
	var ev := {a: [], b: []}
	var st := {a: {}, b: {}}
	for p in [a, b]:
		p.battle_event_received.connect(func(_mid, e): ev[p].append(e))
		p.battle_state_received.connect(func(_mid, s2): st[p] = s2)
	var kinds := func(p: NetPeer, k: String): return ev[p].filter(func(e): return e.t == k)
	var chose := [0]
	a.match_choose.connect(func(mid, _o, _c, _t): chose[0] = mid)
	a.send_challenge(b.my_id, 3)
	await _until(func(): return b.my_id != 0)
	await get_tree().create_timer(0.3).timeout
	b.send_answer(a.my_id, true)
	await _until(func(): return chose[0] != 0)
	var mid: int = chose[0]
	var strong := CreatureInstance.create(DB.species["mewtwo"], 70)
	a.send_choice(mid, [strong])
	b.send_choice(mid, [CreatureInstance.create(DB.species["magikarp"], 3), CreatureInstance.create(DB.species["caterpie"], 3)])
	await _until(func(): return not kinds.call(a, "start").is_empty() and not kinds.call(b, "start").is_empty())
	var start: Dictionary = kinds.call(a, "start")[0] if not kinds.call(a, "start").is_empty() else {}
	r["Pelea: el servidor la arma y avisa a los dos (lado A = el que desafió)"] = start.get("a") == a.my_id \
		and start.get("b") == b.my_id and server.battles.has(mid)
	r["Sale el primero de cada uno"] = kinds.call(a, "send").size() == 2
	await _until(func(): return not st[a].is_empty() and st[a].has(b.my_id))
	r["Llegan fotos con posición, vida y estados de los dos"] = st[a].has(a.my_id) and st[a].has(b.my_id) \
		and st[a][b.my_id].has("p") and st[a][b.my_id].hp == 1.0
	var p0: Vector2 = st[a][a.my_id].p if st[a].has(a.my_id) else Vector2.ZERO
	# Durante la cuenta regresiva no se mueven.
	var seq := [0]
	var drive := func():
		var me: Dictionary = st[a].get(a.my_id, {})
		var foe: Dictionary = st[a].get(b.my_id, {})
		if me.is_empty() or foe.is_empty():
			return
		var to: Vector2 = foe.p - me.p
		a.send_battle_input(mid, [to.normalized() if to.length() > 26.0 else Vector2.ZERO, to, foe.p, 0b1111, 0])
	for i in 60:
		drive.call()
		await get_tree().physics_frame
	r["En la cuenta regresiva no se mueve"] = st[a][a.my_id].p.distance_to(p0) < 1.0
	await get_tree().create_timer(NetMatch.COUNTDOWN).timeout
	b.send_battle_switch(mid, 1)
	await _until(func(): return kinds.call(b, "send").size() >= 3)
	r["B cambia de Pokémon (1-6): el servidor lo saca"] = kinds.call(b, "send").size() >= 3 and kinds.call(b, "send")[-1].index == 1
	var t := 0.0
	while t < 40.0 and kinds.call(a, "end").is_empty():
		drive.call()
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	r["A se mueve y pega: el servidor manda los golpes"] = not kinds.call(b, "hit").is_empty() and st[a][a.my_id].p.distance_to(p0) > 4.0
	r["Debilitados: los dos de B, y sale el que queda"] = kinds.call(a, "faint").filter(func(e): return e.side == b.my_id).size() == 2
	var end: Dictionary = kinds.call(b, "end")[0] if not kinds.call(b, "end").is_empty() else {}
	r["Fin: gana A y los dos se enteran, con la vida final de cada uno"] = end.get("winner") == a.my_id \
		and not kinds.call(a, "end").is_empty() and end.get("hp", {}).get(b.my_id, []) == [0.0, 0.0]
	await _until(func(): return server.battles.is_empty() and _entry(a, a.my_id).get("status") == "libre")
	r["Al terminar vuelven a estar libres"] = server.battles.is_empty() and server.matches.is_empty() \
		and _entry(a, b.my_id).get("status") == "libre"

	# Se desconecta en plena pelea: gana el otro.
	ev[a].clear()
	chose[0] = 0
	b.send_challenge(a.my_id, 1)
	await get_tree().create_timer(0.3).timeout
	a.send_answer(b.my_id, true)
	await _until(func(): return chose[0] != 0)
	a.send_choice(chose[0], [CreatureInstance.create(DB.species["pikachu"], 10)])
	b.send_choice(chose[0], [CreatureInstance.create(DB.species["eevee"], 10)])
	await _until(func(): return not kinds.call(a, "start").is_empty())
	var b_id := b.my_id
	b.close()
	await _until(func(): return not kinds.call(a, "end").is_empty(), 12.0)
	var end2: Dictionary = kinds.call(a, "end")[0] if not kinds.call(a, "end").is_empty() else {}
	r["Se desconecta en plena pelea: gana el otro"] = end2.get("winner") == a.my_id and "desconectó" in str(end2.get("reason", ""))
	await _until(func(): return server.battles.is_empty())
	r["...y la pelea se cierra en el servidor"] = server.battles.is_empty() and not server.players.any(func(p): return p.id == b_id)
	# B vuelve a entrar para lo que sigue.
	b.join("127.0.0.1", PORT, {"version": Net.game_version(), "name": "Ash", "team": [{"species": "ivysaur", "level": 16}]})
	await _until(func(): return b.state == "online" and a.players.size() == 2)


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
