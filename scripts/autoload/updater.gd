class_name GameUpdater
extends Node
## Actualizaciones automáticas (docs/PLAN_ACTUALIZACIONES.md; decisión del usuario 2026-11-01: el juego se actualiza
## solo y es obligatorio). Al abrir la versión portable le pide al servidor del juego `update.json` + `update.sig`,
## verifica la firma con PUBLIC_KEY y compara la huella SHA-256 del .pck con la suya: si es otra, baja el .pck nuevo a
## user://updates/, lo comprueba y vuelve a abrir el juego con él (--main-pack). Al arrancar así, lo copia encima del
## .pck de la carpeta del juego (`--home-pck`), así la próxima vez abre directo. Sin conexión, se juega con lo que hay.
## Autoload "Updater"; con el juego quieto (árbol pausado) mientras busca o baja. Test: --autotest-updater.

signal finished(result: String)

## Clave pública de las actualizaciones (la privada está solo en la PC de quien publica: tools/update_keys.gd).
const PUBLIC_KEY := """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6RglGdATbACkFzWGuSgZ
GuIZYNBwfWtngPmAzXWTW4wQejMlObJFb75TrhKxoGWF+dJkIeIri4P93OkkjsAj
5HRl02tKtt6atLkHOIperMinH06Zlwd1eEkm4Szu6izODWSdIm/DEPbrv9gY72mM
PlmMwVzIhlHNOSIRMOZL3nTgGKJaJFHqkn/HL8yUvA7t4P2/mSyOd8S1frNJ/4hB
JXzxShQh8o7ad2XlW2WbIE40P2szfAeqdRhB+STTFlaxFx4+lMYDCSXtENhsM234
BU2CzVYg7QI6HQIiu0NRA8uat9imqC77lOyKj4PekyjO/rnwTIT8baSFecNwQGdJ
CwIDAQAB
-----END PUBLIC KEY-----"""
const UPDATES_DIR := "user://updates"
## Lo último que se bajó y verificó (para abrirlo aunque después no haya conexión).
const CURRENT := "user://updates/current.json"
const CHECK_TIMEOUT := 5.0

## Dónde están update.json, update.sig y los .pck (la carpeta que sirve nginx en el VPS).
var base_url := "http://%s/pokemon-pilot/" % Net.OFFICIAL_SERVER
var key_pem := PUBLIC_KEY
## El .pck con el que se juega ahora y el de la carpeta del juego (el que se reemplaza).
var local_pck := ""
var home_pck := ""
## Para los tests: en vez de volver a abrir el juego, llama a esto con los argumentos.
var relaunch_hook := Callable()
## "buscando", "bajando", o "" (nada en curso).
var state := ""
var progress := 0.0

var _layer: CanvasLayer
var _label: Label
var _bar: ProgressBar
var _http: HTTPRequest


## Solo la versión portable (el zip), y nunca el servidor online, los tests ni las vitrinas. ("portable" lo pone el
## preset de exportación: corriendo el proyecto con --path no está.)
static func enabled() -> bool:
	if not OS.has_feature("portable"):
		return false
	for a in OS.get_cmdline_user_args():
		if a == "--server" or a.begins_with("--autotest") or a.begins_with("--showcase") or a == "--overview":
			return false
	return true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not enabled():
		return
	local_pck = current_pck()
	home_pck = _user_arg("--home-pck", local_pck)
	base_url = _user_arg("--update-url", base_url)  # (para probar con un servidor local)
	if home_pck != local_pck:
		_replace_home.call_deferred()
	# Recién relanzado: no se vuelve a relanzar (si algo no cierra, mejor jugar que abrir el juego en bucle).
	if "--relanzado" in OS.get_cmdline_user_args():
		return
	_auto.call_deferred()


func _auto() -> void:
	get_tree().paused = true
	var result := await check_and_update()
	get_tree().paused = false
	finished.emit(result)


## El .pck que cargó el juego. Godot se "come" --main-pack (no aparece en OS.get_cmdline_args), así que quien abre el
## juego con otro .pck lo dice también en `--pck` (el relanzado y el lanzador de Mac); si no, es el que tiene el nombre
## del ejecutable al lado (Windows).
static func current_pck() -> String:
	var own := _user_arg("--pck", "")
	if own != "":
		return own
	var exe := OS.get_executable_path()
	return exe.get_base_dir().path_join(exe.get_file().get_basename() + ".pck")


static func _user_arg(name: String, fallback: String) -> String:
	var args := OS.get_cmdline_user_args()
	var i := args.find(name)
	return args[i + 1] if i >= 0 and i + 1 < args.size() else fallback


## Todo el chequeo. Devuelve: "al_dia", "sin_conexion", "firma_mala", "otro_godot", "huella_mala", "error_bajada" o
## "relanzado" (se volvió a abrir con el .pck nuevo).
func check_and_update() -> String:
	state = "buscando"
	_show("Buscando actualizaciones…", -1.0)
	var manifest_text := await _get_text(base_url + "update.json")
	var sig_text := await _get_text(base_url + "update.sig") if manifest_text != "" else ""
	if manifest_text == "" or sig_text == "":
		return _done(_offline_fallback())
	if not verify(manifest_text, sig_text, key_pem):
		push_warning("Updater: la firma de update.json no es válida; no se actualiza.")
		return _done("firma_mala")
	var m: Variant = JSON.parse_string(manifest_text)
	if not m is Dictionary or str(m.get("sha256", "")) == "":
		return _done("firma_mala")
	var decision := plan(m, file_sha256(local_pck), engine_version())
	if decision == "otro_godot":
		_show("Hay una versión nueva que necesita el zip nuevo:\npedíselo a quien te pasó el juego.", -1.0)
		await get_tree().create_timer(4.0, true, false, true).timeout
		return _done("otro_godot")
	if decision == "al_dia":
		return _done("al_dia")
	var target := UPDATES_DIR.path_join(str(m["file"]))
	if not (FileAccess.file_exists(target) and file_sha256(target) == m["sha256"]):
		state = "bajando"
		var got := await _download(base_url + str(m["file"]), target, int(m.get("size", 0)))
		if not got:
			_show("No se pudo bajar la versión nueva. Seguís con la que tenés.", -1.0)
			await get_tree().create_timer(3.0, true, false, true).timeout
			return _done("error_bajada")
		if file_sha256(target) != m["sha256"]:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(target))
			_show("La versión bajada vino dañada. Seguís con la que tenés.", -1.0)
			await get_tree().create_timer(3.0, true, false, true).timeout
			return _done("huella_mala")
	_save_current(target, str(m["sha256"]))
	_show("Listo: abriendo la versión nueva…", 1.0)
	relaunch(target)
	return _done("relanzado")


## Qué hacer con un update.json ya verificado: "al_dia", "bajar" u "otro_godot".
static func plan(manifest: Dictionary, local_sha: String, engine: String) -> String:
	if str(manifest.get("godot", engine)) != engine:
		return "otro_godot"
	return "al_dia" if str(manifest.get("sha256", "")) == local_sha else "bajar"


static func engine_version() -> String:
	var v := Engine.get_version_info()
	return "%d.%d.%d" % [v.major, v.minor, v.patch]


static func verify(text: String, sig_b64: String, pem: String) -> bool:
	var key := CryptoKey.new()
	if key.load_from_string(pem, true) != OK:
		return false
	var sig := Marshalls.base64_to_raw(sig_b64.strip_edges())
	if sig.is_empty():
		return false
	return Crypto.new().verify(HashingContext.HASH_SHA256, sha256_bytes(text.to_utf8_buffer()), sig, key)


static func sha256_bytes(data: PackedByteArray) -> PackedByteArray:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(data)
	return ctx.finish()


## Huella SHA-256 (hex) de un archivo, leyéndolo de a pedazos ("" si no existe).
static func file_sha256(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	while f.get_position() < f.get_length():
		ctx.update(f.get_buffer(1 << 20))
	return ctx.finish().hex_encode()


## Vuelve a abrir el juego con otro .pck (y le pasa cuál es el de la carpeta del juego, para que lo reemplace).
func relaunch(pck: String) -> void:
	var engine := OS.get_cmdline_args()
	if DisplayServer.get_name() == "headless" and not "--headless" in engine:
		engine.append("--headless")  # (también se lo come Godot)
	var args := relaunch_args(engine, OS.get_cmdline_user_args(), ProjectSettings.globalize_path(pck), home_pck)
	if relaunch_hook.is_valid():
		relaunch_hook.call(args)
		return
	OS.create_process(OS.get_executable_path(), args)
	get_tree().quit()


## Los argumentos con que se abrió (--screen, --update-url...) + el .pck nuevo y cuál es el de la carpeta del juego.
static func relaunch_args(engine_args: PackedStringArray, user_args: PackedStringArray, pck: String,
		home: String) -> PackedStringArray:
	var out := PackedStringArray()
	var skip := false
	for a in engine_args:
		if skip:
			skip = false
		elif a == "--main-pack":
			skip = true
		elif a != "--" and a != "++":
			out.append(a)
	out.append_array(["--main-pack", pck, "--"])
	for a in user_args:
		if skip:
			skip = false
		elif a in ["--home-pck", "--pck"]:
			skip = true
		elif a != "--relanzado":
			out.append(a)
	out.append_array(["--pck", pck, "--home-pck", home, "--relanzado"])
	return out


## Sin conexión: si antes se bajó y verificó una versión que no es la que está abierta, se abre esa.
func _offline_fallback() -> String:
	var cur: Variant = JSON.parse_string(FileAccess.get_file_as_string(CURRENT)) if FileAccess.file_exists(CURRENT) else null
	if cur is Dictionary and FileAccess.file_exists(str(cur.get("pck", ""))) \
			and str(cur.get("sha256", "")) != file_sha256(local_pck) \
			and file_sha256(str(cur["pck"])) == str(cur["sha256"]):
		relaunch(str(cur["pck"]))
		return "relanzado"
	return "sin_conexion"


func _save_current(pck: String, sha: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(UPDATES_DIR))
	var f := FileAccess.open(CURRENT, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"pck": pck, "sha256": sha}))


## Abierto con el .pck de user://updates: lo copia encima del de la carpeta del juego (el juego viejo ya se cerró;
## se reintenta un par de veces por si tarda). Si no se puede, no pasa nada: se sigue abriendo desde user://updates.
func _replace_home() -> void:
	for attempt in 5:
		await get_tree().create_timer(0.6, true, false, true).timeout
		if replace_file(local_pck, home_pck):
			return


static func replace_file(src: String, dst: String) -> bool:
	var tmp := dst + ".nuevo"
	if DirAccess.copy_absolute(ProjectSettings.globalize_path(src), tmp) != OK:
		return false
	if FileAccess.file_exists(dst) and DirAccess.remove_absolute(dst) != OK:
		DirAccess.remove_absolute(tmp)
		return false
	return DirAccess.rename_absolute(tmp, dst) == OK


## El tiempo de espera se mide con el reloj (no con `HTTPRequest.timeout`, que suma el delta de los cuadros: el primer
## cuadro después de abrir el juego trae varios segundos y cortaba el pedido enseguida).
func _get_text(url: String) -> String:
	var req := HTTPRequest.new()
	req.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(req)
	if req.request(url) != OK:
		req.queue_free()
		return ""
	var res: Array = []
	req.request_completed.connect(func(r, code, _h, body): res.append_array([r, code, body]), CONNECT_ONE_SHOT)
	var deadline := Time.get_ticks_msec() + int(CHECK_TIMEOUT * 1000)
	while res.is_empty() and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	req.queue_free()
	if res.is_empty() or res[0] != HTTPRequest.RESULT_SUCCESS or res[1] != 200:
		return ""
	return (res[2] as PackedByteArray).get_string_from_utf8()


func _download(url: String, target: String, size: int) -> bool:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(UPDATES_DIR))
	var part := target + ".parte"
	_http = HTTPRequest.new()
	_http.download_file = part
	_http.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_http)
	_show("Bajando la versión nueva…", 0.0)
	if _http.request(url) != OK:
		_http.queue_free()
		return false
	var total := float(max(size, 1))
	var res: Array = []  # [resultado, código HTTP] al terminar
	_http.request_completed.connect(func(r, code, _h, _b): res.append_array([r, code]), CONNECT_ONE_SHOT)
	while res.is_empty():
		progress = clampf(_http.get_downloaded_bytes() / total, 0.0, 1.0)
		_show("Bajando la versión nueva… %d%% (%.0f de %.0f MB)" % [int(progress * 100), _http.get_downloaded_bytes() / 1e6,
			total / 1e6], progress)
		await get_tree().process_frame
	_http.queue_free()
	if res[0] != HTTPRequest.RESULT_SUCCESS or res[1] != 200:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(part))
		return false
	if FileAccess.file_exists(target):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(target))
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(part), ProjectSettings.globalize_path(target)) == OK


func _done(result: String) -> String:
	state = ""
	if _layer != null:
		_layer.queue_free()
		_layer = null
	return result


## Cartel en el medio de la pantalla (tapa todo mientras dura). ratio < 0 = sin barra.
func _show(text: String, ratio: float) -> void:
	if _layer == null:
		_layer = CanvasLayer.new()
		_layer.layer = 128
		add_child(_layer)
		var dim := ColorRect.new()
		dim.color = Color(0.04, 0.05, 0.08, 0.92)
		dim.set_anchors_preset(Control.PRESET_FULL_RECT)
		_layer.add_child(dim)
		var box := VBoxContainer.new()
		box.set_anchors_preset(Control.PRESET_CENTER)
		box.custom_minimum_size = Vector2(460, 0)
		box.position = Vector2(-230, -30)
		box.add_theme_constant_override("separation", 12)
		_layer.add_child(box)
		_label = Label.new()
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_label.add_theme_font_size_override("font_size", 18)
		box.add_child(_label)
		_bar = ProgressBar.new()
		_bar.custom_minimum_size = Vector2(460, 18)
		_bar.max_value = 1.0
		_bar.show_percentage = false
		box.add_child(_bar)
	_label.text = text
	_bar.visible = ratio >= 0.0
	_bar.value = maxf(ratio, 0.0)
