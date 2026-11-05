class_name SaveSyncTests
extends Node
## Partidas en el servidor, de punta a punta: levanta el servicio de verdad (tools/server/partidas_server.py, con Python) en
## esta PC y una base de prueba, manda partidas con Sync y las lee en el panel. Nada sale al servidor real.
##   godot --headless --path . --quit-after 60000 -- --autotest-save-sync

const PORT := 24699
const DIR := "user://save_sync_test"
const SAVE_NAME := "Prueba Sync"

var autotest: Node
var world: Node
var r := {}
var _pid := -1
var _token := ""


func run() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	for f in DirAccess.get_files_at(DIR):
		DirAccess.remove_absolute(DIR.path_join(f))
	r["Apagado fuera de la versión portable (los tests y tu partida no suben nada)"] = not SaveSync.enabled() and not Sync.active
	var script := ProjectSettings.globalize_path("res://tools/server/partidas_server.py")
	var db := ProjectSettings.globalize_path(DIR.path_join("partidas.db"))
	_pid = OS.create_process("python", PackedStringArray(["-I", "-B", script, "--port", str(PORT), "--db", db]))
	r["Arranca el servicio"] = _pid > 0
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await _wait_token()
	await _checks()
	OS.kill(_pid)
	Sync.stop()
	DirAccess.remove_absolute(SaveManager.slot_path)
	var ok := true
	for k: String in r:
		print("[partidas] %s %s" % ["OK   " if r[k] else "FALLO", k])
		ok = ok and r[k]
	print("[autotest-save-sync] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)


func _wait_token() -> void:
	var path := DIR.path_join("panel_token")
	var left := 8.0
	while left > 0.0 and not FileAccess.file_exists(path):
		await get_tree().create_timer(0.2).timeout
		left -= 0.2
	_token = FileAccess.get_file_as_string(path).strip_edges() if FileAccess.file_exists(path) else ""
	await get_tree().create_timer(0.5).timeout
	r["El panel tiene su token, creado solo"] = _token.length() > 20


func _checks() -> void:
	Sync.config_path = DIR.path_join("sync.cfg")
	Sync.url = "http://127.0.0.1:%d/subir" % PORT
	Sync.start()
	var id: String = Sync.install_id()
	r["Código de instalación al azar y siempre el mismo"] = id.length() == 32 and id == Sync.install_id()

	# Guardar la manda
	SaveManager.use_name(SAVE_NAME)
	GameState.active().nickname = "<b>Fueguito"
	GameState.money = 4321
	var before: int = Sync.sent_ok
	SaveManager.save_game()
	await _drain()
	r["Guardar manda la partida"] = Sync.sent_ok > before
	var list := await _fetch("panel?k=" + _token)
	r["El panel la muestra con su nombre, equipo y dinero"] = list[0] == 200 and SAVE_NAME in list[1] and "Charmander" in list[1] and "4321" in list[1]
	r["Los apodos no se meten en la página"] = "<b>Fueguito" not in list[1] and "&lt;b&gt;Fueguito" in list[1]

	# Lo mismo no se manda dos veces
	Sync.send_all_saved()
	await _drain()
	var sent: int = Sync.sent_ok
	Sync.send_all_saved()
	await _drain()
	r["Lo que no cambió no se vuelve a mandar"] = Sync.sent_ok == sent

	# Jugando
	var zone: ZoneEntry = world.trainer_zone()
	GameState.money = 9876
	Sync.send_live(world)
	await _drain()
	list = await _fetch("panel?k=" + _token)
	r["Jugando se ve por dónde anda sin que guarde"] = zone.display_name in list[1] and "9876" in list[1]
	var detail := await _fetch("detalle?k=%s&i=%s&n=%s" % [_token, id, SAVE_NAME.uri_encode()])
	r["El detalle muestra equipo, Caja, mochila e historial"] = detail[0] == 200 and "Equipo" in detail[1] and "Caja" in detail[1] \
		and "Mochila" in detail[1] and "guardó" in detail[1]

	# Sin token no se ve nada
	r["Sin el token no se ve el panel"] = (await _fetch("panel"))[0] == 404 and (await _fetch("panel?k=otro"))[0] == 404
	var bad := await _post({"install": "../../x", "save_name": "a", "data": {}})
	r["Rechaza lo que no es una partida"] = bad == 400

	# Sin conexión: se juega igual y se manda después
	GameState.money = 1111
	Sync.url = "http://127.0.0.1:%d/subir" % (PORT + 1)
	var ok_before: int = Sync.sent_ok
	SaveManager.save_game()
	await _drain()
	r["Sin conexión no se traba ni cuenta como mandada"] = Sync.sent_ok == ok_before and SaveManager.has_save()
	Sync.url = "http://127.0.0.1:%d/subir" % PORT
	Sync.send_all_saved()
	await _drain()
	list = await _fetch("panel?k=" + _token)
	r["Al volver la conexión se manda lo que faltaba"] = "1111" in list[1]

	# Nombres que no se repiten
	r["Nombre nuevo: queda para vos"] = await Sync.reserve_name("Barriwow") == "libre"
	r["Tu mismo nombre sigue siendo tuyo"] = await Sync.reserve_name("Barriwow") == "libre"
	var other := "ab".repeat(16)
	r["Otro jugador no puede usarlo (ni con otras mayúsculas o tildes)"] = await _post({"install": other, "name": "BÁRRI wow!"}, "nombre") == 409
	r["Una partida ya subida también lo ocupa"] = await _post({"install": other, "name": "prueba sync"}, "nombre") == 409
	r["Otro nombre sí puede"] = await _post({"install": other, "name": "Misty"}, "nombre") == 200
	r["Y entonces a vos te dice ocupado"] = await Sync.reserve_name("misty") == "ocupado"
	Sync.url = "http://127.0.0.1:%d/subir" % (PORT + 1)
	r["Sin conexión deja seguir"] = await Sync.reserve_name("Otro") == "sin_conexion"
	Sync.url = "http://127.0.0.1:%d/subir" % PORT

	# La pantalla de título
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
	await get_tree().create_timer(0.4).timeout
	var title: Node = get_tree().current_scene
	title._ask_name()
	var labels: Array = title._overlay.find_children("*", "Label", true, false).map(func(l): return l.text)
	r["Pide el nombre del personaje"] = labels.has("Nombre de tu personaje:")
	await title._start_named("")
	r["Sin nombre no arranca"] = title._name_error.text != "" and get_tree().current_scene == title
	await title._start_named(SAVE_NAME.to_upper() + " ")
	r["Un nombre que ya tenés en esta PC no se puede repetir"] = "Ya tenés" in title._name_error.text and get_tree().current_scene == title
	await title._start_named("misty")
	r["Un nombre de otro jugador no se puede usar"] = "otro jugador" in title._name_error.text and get_tree().current_scene == title


func _drain() -> void:
	var left := 25.0
	await get_tree().process_frame
	while left > 0.0 and (Sync._busy or not Sync._queue.is_empty()):
		await get_tree().create_timer(0.1).timeout
		left -= 0.1


func _fetch(path: String) -> Array:
	var http := HTTPRequest.new()
	add_child(http)
	http.request("http://127.0.0.1:%d/%s" % [PORT, path])
	var res: Array = await http.request_completed
	http.queue_free()
	return [res[1], (res[3] as PackedByteArray).get_string_from_utf8()]


func _post(body: Dictionary, route := "subir") -> int:
	var http := HTTPRequest.new()
	add_child(http)
	http.request("http://127.0.0.1:%d/%s" % [PORT, route], PackedStringArray(["Content-Type: application/json"]), HTTPClient.METHOD_POST, JSON.stringify(body))
	var res: Array = await http.request_completed
	http.queue_free()
	return res[1]
