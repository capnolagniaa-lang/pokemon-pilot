class_name UpdaterTests
extends Node
## Actualizaciones automáticas (GameUpdater, docs/PLAN_ACTUALIZACIONES.md):
##   godot --headless --path . --quit-after 60000 -- --autotest-updater
## Un servidor HTTP de prueba adentro del test sirve update.json / update.sig / el .pck nuevo (firmados con una clave de
## prueba). Se prueba: bajar, comprobar y "relanzar" (con un gancho en vez de abrir el juego), no volver a bajar lo ya
## bajado, al día, firma falsa, .pck dañado, otra versión de Godot, sin conexión (y abrir lo último verificado) y
## reemplazar el .pck de la carpeta del juego.

const DIR := "user://test_updater"

var autotest: Node
var _server := TCPServer.new()
var _port := 0
var _files := {}  # ruta → PackedByteArray
var _hits := {}  # ruta → veces que se pidió
var _peers: Array = []


func run() -> void:
	var r := {}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	_port = 24700
	while _server.listen(_port, "127.0.0.1") != OK:
		_port += 1
	var crypto := Crypto.new()
	var key := crypto.generate_rsa(1024)
	var other_key := crypto.generate_rsa(1024)
	var pem := key.save_to_string(true)

	var old_bytes := ("juego viejo " .repeat(5000)).to_utf8_buffer()
	var new_bytes := ("juego nuevo " .repeat(90000)).to_utf8_buffer()
	var home := DIR.path_join("PokemonPilot.pck")
	_write(home, old_bytes)
	var new_sha := GameUpdater.sha256_bytes(new_bytes).hex_encode()
	var file := "PokemonPilot-%s.pck" % new_sha.left(16)
	var manifest := JSON.stringify({"sha256": new_sha, "size": new_bytes.size(), "file": file,
		"godot": GameUpdater.engine_version(), "date": "2026-11-01"})
	_publish(manifest, _sign(manifest, key), file, new_bytes)
	var target := GameUpdater.UPDATES_DIR.path_join(file)
	_cleanup(target)

	r["Firma: la buena vale, otra clave no, el texto cambiado tampoco"] = \
		GameUpdater.verify(manifest, _sign(manifest, key), pem) \
		and not GameUpdater.verify(manifest, _sign(manifest, other_key), pem) \
		and not GameUpdater.verify(manifest + " ", _sign(manifest, key), pem)
	r["Plan: misma huella = al día, otra = bajar, otro Godot = zip nuevo"] = \
		GameUpdater.plan({"sha256": "a", "godot": "4.7.2"}, "a", "4.7.2") == "al_dia" \
		and GameUpdater.plan({"sha256": "b", "godot": "4.7.2"}, "a", "4.7.2") == "bajar" \
		and GameUpdater.plan({"sha256": "b", "godot": "4.8.0"}, "a", "4.7.2") == "otro_godot"

	# 1) Hay versión nueva: la baja, la comprueba y vuelve a abrir el juego con ella.
	var up := _updater(pem, home)
	var launched: Array = []
	up.relaunch_hook = func(args: PackedStringArray): launched.append(args)
	var res := await up.check_and_update()
	r["Versión nueva: se baja, se comprueba y se relanza (%s)" % res] = res == "relanzado" and launched.size() == 1 \
		and GameUpdater.file_sha256(target) == new_sha and "--main-pack" in launched[0] and "--home-pck" in launched[0] \
		and launched[0][launched[0].find("--home-pck") + 1] == home
	r["Relanzar pasa la ruta absoluta del .pck nuevo"] = launched.size() == 1 \
		and launched[0][launched[0].find("--main-pack") + 1] == ProjectSettings.globalize_path(target)
	var again := GameUpdater.relaunch_args(PackedStringArray(["--screen", "1", "--main-pack", "viejo.pck"]),
		PackedStringArray(["--update-url", "http://x/", "--pck", "viejo.pck", "--home-pck", "a.pck", "--relanzado"]),
		"nuevo.pck", "casa.pck")
	r["Relanzar conserva los argumentos y dice qué .pck abre (%s)" % " ".join(again)] = again == PackedStringArray([
		"--screen", "1", "--main-pack", "nuevo.pck", "--", "--update-url", "http://x/", "--pck", "nuevo.pck",
		"--home-pck", "casa.pck", "--relanzado"])

	# 2) Ya bajada: no se vuelve a bajar.
	var hits_before: int = _hits.get("/" + file, 0)
	res = await up.check_and_update()
	r["Ya bajada: relanza sin volver a bajarla (%s)" % res] = res == "relanzado" and _hits.get("/" + file, 0) == hits_before

	# 3) Abierto con la nueva: al día.
	up.local_pck = target
	res = await up.check_and_update()
	r["Con la versión nueva abierta: al día (%s)" % res] = res == "al_dia"

	# 4) Reemplazar el .pck de la carpeta del juego.
	r["El .pck nuevo queda copiado encima del de la carpeta del juego"] = GameUpdater.replace_file(target, home) \
		and GameUpdater.file_sha256(home) == new_sha and not FileAccess.file_exists(home + ".nuevo")
	_write(home, old_bytes)

	# 5) Firma falsa (otra clave): no baja nada.
	_cleanup(target)
	_publish(manifest, _sign(manifest, other_key), file, new_bytes)
	up.local_pck = home
	res = await up.check_and_update()
	r["Firma falsa: no se baja nada (%s)" % res] = res == "firma_mala" and not FileAccess.file_exists(target)

	# 6) El .pck que llega no tiene la huella del update.json: se borra.
	_publish(manifest, _sign(manifest, key), file, ("trucho " .repeat(1000)).to_utf8_buffer())
	res = await up.check_and_update()
	r[".pck con otra huella: se descarta (%s)" % res] = res == "huella_mala" and not FileAccess.file_exists(target)

	# 7) Otra versión de Godot: avisa que hace falta el zip nuevo.
	var other_godot := JSON.stringify({"sha256": new_sha, "size": new_bytes.size(), "file": file, "godot": "9.9.9"})
	_publish(other_godot, _sign(other_godot, key), file, new_bytes)
	res = await up.check_and_update()
	r["Otra versión de Godot: pide el zip nuevo (%s)" % res] = res == "otro_godot"

	# 8) Sin conexión: con una versión ya verificada abre esa; si no, sigue con la que tiene.
	_publish(manifest, _sign(manifest, key), file, new_bytes)
	launched.clear()
	res = await up.check_and_update()  # baja y deja current.json
	var offline := _updater(pem, home)
	offline.base_url = "http://127.0.0.1:%d/" % (_port + 50)
	offline.relaunch_hook = func(args: PackedStringArray): launched.append(args)
	var t0 := Time.get_ticks_msec()
	res = await offline.check_and_update()
	r["Sin conexión, con una versión ya bajada: abre esa (%s)" % res] = res == "relanzado" and launched.size() == 2
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GameUpdater.CURRENT))
	res = await offline.check_and_update()
	r["Sin conexión y nada bajado: sigue con la que tiene, sin colgarse (%s, %.1f s)" % [res, (Time.get_ticks_msec() - t0) / 1000.0]] = \
		res == "sin_conexion" and Time.get_ticks_msec() - t0 < 25000

	_cleanup(target)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(home))
	_server.stop()
	var ok := r.values().all(func(v): return v)
	for k in r:
		print("[updater] %s %s" % ["OK   " if r[k] else "FALLO", k])
	print("[autotest-updater] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _updater(pem: String, home: String) -> GameUpdater:
	var up := GameUpdater.new()
	up.base_url = "http://127.0.0.1:%d/" % _port
	up.key_pem = pem
	up.local_pck = home
	up.home_pck = home
	add_child(up)
	return up


func _sign(text: String, key: CryptoKey) -> String:
	return Marshalls.raw_to_base64(Crypto.new().sign(HashingContext.HASH_SHA256,
		GameUpdater.sha256_bytes(text.to_utf8_buffer()), key))


func _publish(manifest: String, sig: String, file: String, pck: PackedByteArray) -> void:
	_files = {"/update.json": manifest.to_utf8_buffer(), "/update.sig": sig.to_utf8_buffer(), "/" + file: pck}


func _write(path: String, data: PackedByteArray) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_buffer(data)
	f.close()


func _cleanup(target: String) -> void:
	for p in [target, target + ".parte", GameUpdater.CURRENT]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))


## El servidor HTTP de prueba: responde GET con lo que hay en _files (o 404).
func _process(_delta: float) -> void:
	while _server.is_listening() and _server.is_connection_available():
		_peers.append({"peer": _server.take_connection(), "buf": ""})
	for p in _peers.duplicate():
		var peer: StreamPeerTCP = p["peer"]
		peer.poll()
		if peer.get_status() == StreamPeerTCP.STATUS_CONNECTING:
			continue
		if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			_peers.erase(p)
			continue
		var n := peer.get_available_bytes()
		if n > 0:
			p["buf"] += peer.get_utf8_string(n)
		if not "\r\n\r\n" in p["buf"]:
			continue
		var path: String = p["buf"].split(" ")[1] if p["buf"].split(" ").size() > 1 else "/"
		_hits[path] = _hits.get(path, 0) + 1
		var body: PackedByteArray = _files.get(path, "no está".to_utf8_buffer())
		var head := "HTTP/1.1 %s\r\nContent-Length: %d\r\nContent-Type: application/octet-stream\r\nConnection: close\r\n\r\n" \
			% ["200 OK" if _files.has(path) else "404 Not Found", body.size()]
		peer.put_data(head.to_utf8_buffer())
		peer.put_data(body)
		peer.disconnect_from_host()
		_peers.erase(p)
