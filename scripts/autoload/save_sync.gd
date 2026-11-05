class_name SaveSync
extends Node
## Copia de las partidas en el servidor del juego (pedido del usuario 2026-11-05: ver qué Pokémon tiene cada uno y por dónde
## anda, para el torneo y para ver si alguien está buggeando algo). Manda cada partida al guardar, las que estén sin mandar
## al abrir el juego y, jugando, cómo viene la partida cada `LIVE_EVERY` segundos. Sin conexión no pasa nada: se juega igual
## y lo guardado se manda después. Solo en la versión portable.
## Servicio y panel: tools/server/partidas_server.py. Autoload "Sync". Test: --autotest-save-sync.

const LIVE_EVERY := 120.0
const FIRST_SCAN_DELAY := 5.0
const TIMEOUT := 20.0

## Lo prende `enabled()` o un test.
var active := false
var url := "http://%s/pokemon-pilot/partidas/subir" % Net.OFFICIAL_SERVER
## Código de instalación y qué ya se mandó.
var config_path := "user://save_sync.cfg"
## Cuántas subidas salieron bien (para los tests).
var sent_ok := 0

var _cfg := ConfigFile.new()
var _queue: Array = []  # [{"body": String, "path": String, "sha": String}]
var _http: HTTPRequest
var _busy := false
var _current := {}
var _live_left := LIVE_EVERY


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
		set_process(false)
		return
	start()
	get_tree().create_timer(FIRST_SCAN_DELAY, true, false, true).timeout.connect(send_all_saved)


## Empieza a trabajar (al abrir el juego, o desde un test).
func start() -> void:
	active = true
	_cfg = ConfigFile.new()
	_cfg.load(config_path)
	if _http == null:
		_http = HTTPRequest.new()
		_http.timeout = TIMEOUT
		_http.use_threads = true
		_http.request_completed.connect(_on_done)
		add_child(_http)
	if not Events.game_saved.is_connected(_on_saved):
		Events.game_saved.connect(_on_saved)
	set_process(true)


func stop() -> void:
	active = false
	set_process(false)


## Código de esta instalación: al azar, no sale de nada de la PC.
func install_id() -> String:
	var id := str(_cfg.get_value("sync", "install", ""))
	if id == "":
		id = Crypto.new().generate_random_bytes(16).hex_encode()
		_cfg.set_value("sync", "install", id)
		_cfg.save(config_path)
	return id


func _process(delta: float) -> void:
	var world := get_tree().get_first_node_in_group("world")
	if world == null or get_tree().paused:
		return
	_live_left -= delta
	if _live_left <= 0.0:
		_live_left = LIVE_EVERY
		send_live(world)


## Manda las partidas guardadas que cambiaron desde la última vez.
func send_all_saved() -> void:
	if not active:
		return
	for s in SaveManager.list_saves():
		_send_file(str(s["path"]))


func _on_saved() -> void:
	if active:
		_send_file(SaveManager.slot_path)


func _send_file(path: String) -> void:
	var text := FileAccess.get_file_as_string(path)
	var data: Variant = JSON.parse_string(text)
	if not data is Dictionary:
		return
	var sha := GameUpdater.sha256_bytes(text.to_utf8_buffer()).hex_encode()
	if str(_cfg.get_value("enviados", path.get_file(), "")) == sha or _queue.any(func(q): return q.get("sha") == sha):
		return
	_enqueue(str(data.get("save_name", path.get_file().get_basename())), data, false, path.get_file(), sha)


## Cómo viene la partida que se está jugando, sin guardarla.
func send_live(world: Node) -> void:
	if not active or not GameState.test_tournament.is_empty() or GameState.party.is_empty():
		return
	var data := GameState.to_dict()
	var zone: ZoneEntry = world.trainer_zone()
	data["zone_name"] = zone.display_name if zone != null else GameState.zone_name
	var pos: Vector2 = world.trainer.global_position
	data["trainer_position"] = [pos.x, pos.y]
	_enqueue(SaveManager.current_name, data, true, "", "")


func _enqueue(save_name: String, data: Dictionary, live: bool, file: String, sha: String) -> void:
	var body := JSON.stringify({"install": install_id(), "save_name": save_name, "live": live, "player": Net.display_name(),
		"game_version": Net.game_version(), "data": data})
	_queue.append({"body": body, "file": file, "sha": sha})
	_pump()


func _pump() -> void:
	if _busy or _queue.is_empty():
		return
	_current = _queue.pop_front()
	_busy = true
	if _http.request(url, PackedStringArray(["Content-Type: application/json"]), HTTPClient.METHOD_POST, _current["body"]) != OK:
		_busy = false


func _on_done(_result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	_busy = false
	if code == 200:
		sent_ok += 1
		if str(_current.get("file", "")) != "":  # si falló, queda sin marcar y se vuelve a mandar al abrir el juego
			_cfg.set_value("enviados", _current["file"], _current["sha"])
			_cfg.save(config_path)
	_pump()
