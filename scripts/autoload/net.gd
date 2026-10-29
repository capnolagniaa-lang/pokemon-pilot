extends Node
## Online (docs/PLAN_ONLINE.md): el enlace del jugador con el servidor y, con `-- --server`, el servidor mismo.
## Los sistemas no le hablan a NetPeer directo: usan esto y escuchan Events (online_state_changed,
## online_players_changed).
##   Servidor:  godot --headless --path . -- --server [--port 24680]
## Dirección del servidor: user://online.cfg (de esta PC, no de la partida).

const CONFIG_PATH := "user://online.cfg"
const DEFAULT_ADDRESS := "127.0.0.1"

var client: NetPeer
var server: NetPeer
var address := DEFAULT_ADDRESS
var port := NetPeer.DEFAULT_PORT
## Nombre con el que entrás a la sala (vacío = el de la partida).
var player_name := ""

var state: String:
	get: return client.state
var players: Array:
	get: return client.players


func _ready() -> void:
	_load_config()
	client = NetPeer.new()
	client.name = "Client"
	add_child(client)
	client.state_changed.connect(func(s, m): Events.online_state_changed.emit(s, m))
	client.players_changed.connect(func(p): Events.online_players_changed.emit(p))
	if "--server" in OS.get_cmdline_user_args():
		_start_server.call_deferred()


## Modo servidor: sin título ni mundo, solo la sala.
func _start_server() -> void:
	get_tree().unload_current_scene()
	var args := OS.get_cmdline_user_args()
	var i := args.find("--port")
	var p := int(args[i + 1]) if i >= 0 and i + 1 < args.size() else NetPeer.DEFAULT_PORT
	server = NetPeer.new()
	server.name = "Server"
	add_child(server)
	var err := server.host(p, game_version())
	if err != OK:
		push_error("No se pudo abrir el servidor en el puerto %d: %s" % [p, error_string(err)])
		get_tree().quit(1)


## Conectarse a la sala con el nombre y el equipo de la partida actual.
func go_online() -> Error:
	return client.join(address, port, {"version": game_version(), "name": display_name(), "team": team_summary()})


func go_offline() -> void:
	client.close()


func is_online() -> bool:
	return client.state == "online"


func display_name() -> String:
	return NetPeer.clean_name(player_name if player_name.strip_edges() != "" else SaveManager.current_name)


## Lo que ven los demás en la lista: especie y nivel de cada uno.
static func team_summary() -> Array:
	return GameState.party.map(func(c: CreatureInstance): return {"species": c.species.id, "level": c.level})


## Huella de los datos del juego (ataques y especies): si dos juegos no coinciden, el servidor no deja entrar (los
## ataques se comportarían distinto). Cambia sola al cambiar un ataque o sumar una especie.
static func game_version() -> String:
	var parts: PackedStringArray = []
	var ids := DB.moves.keys()
	ids.sort()
	for id in ids:
		var m: MoveData = DB.moves[id]
		parts.append("%s:%d:%s:%s:%s" % [id, m.kind, m.power, m.cooldown, m.knockback])
	var sp := DB.species.keys()
	sp.sort()
	parts.append(",".join(sp))
	return "%d-%08x" % [NetPeer.PROTOCOL, hash("|".join(parts))]


## "host" o "host:puerto" (como lo escribe el jugador en Opciones). Vacío = la de siempre.
func set_server(text: String) -> void:
	var t := text.strip_edges()
	if t == "":
		address = DEFAULT_ADDRESS
		port = NetPeer.DEFAULT_PORT
		return
	var i := t.rfind(":")
	if i > 0 and t.substr(i + 1).is_valid_int():
		address = t.substr(0, i)
		port = clampi(int(t.substr(i + 1)), 1, 65535)
	else:
		address = t
		port = NetPeer.DEFAULT_PORT


func save_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("online", "address", address)
	cfg.set_value("online", "port", port)
	cfg.set_value("online", "name", player_name)
	cfg.save(CONFIG_PATH)


func _load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	address = str(cfg.get_value("online", "address", DEFAULT_ADDRESS))
	port = int(cfg.get_value("online", "port", NetPeer.DEFAULT_PORT))
	player_name = str(cfg.get_value("online", "name", ""))
