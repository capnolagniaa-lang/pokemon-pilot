class_name NetPeer
extends Node
## Un extremo de la conexión online (docs/PLAN_ONLINE.md, O-0): el **servidor** (sala: quién está conectado) o un
## **cliente** (un jugador). Es el mismo script de los dos lados porque las RPC de Godot tienen que existir igual en
## ambos. Cada NetPeer usa su propia MultiplayerAPI (set_multiplayer sobre su rama): así el autotest levanta un
## servidor y dos clientes en el mismo proceso. El juego usa uno solo, el del autoload `Net`.

signal state_changed(state: String, message: String)
signal players_changed(players: Array)

## Sube cuando cambian los mensajes: un juego viejo y uno nuevo no se entienden.
const PROTOCOL := 1
const DEFAULT_PORT := 24680
const MAX_PLAYERS := 32
const NAME_MAX := 16
## Sin respuesta del servidor en este tiempo = se cortó (ENet).
const TIMEOUT_MS := 8000
## Un cliente que conectó y no se presentó (hello) en este tiempo se echa.
const HELLO_TIMEOUT := 10.0
const STATUSES := ["libre", "eligiendo", "peleando"]
## Cliente: si en este tiempo no entró a la sala, se da por no encontrado.
const CONNECT_TIMEOUT := 8.0

var is_server := false
## Cliente: "offline", "connecting", "online", "rejected".
var state := "offline"
## Cliente: la lista que mandó el servidor. Servidor: la de todos.
var players: Array = []
## Cliente: mi id de red (el del servidor es 1).
var my_id := 0
## Servidor: id → {id, name, team, status}.
var _by_id: Dictionary = {}
## Servidor: id → segundos sin presentarse.
var _pending: Dictionary = {}
## (Var para que el autotest lo achique.)
var hello_timeout := HELLO_TIMEOUT
var _api: SceneMultiplayer
var _version := ""
var _hello: Dictionary = {}
var _connecting_for := 0.0


func _enter_tree() -> void:
	_api = SceneMultiplayer.new()
	get_tree().set_multiplayer(_api, get_path())


func _exit_tree() -> void:
	close()
	get_tree().set_multiplayer(null, get_path())


# --- Servidor ------------------------------------------------------------------------------

## Escucha en `port`. Devuelve el error de ENet (OK si anduvo).
func host(port: int = DEFAULT_PORT, version: String = "") -> Error:
	close()
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_PLAYERS)
	if err != OK:
		return err
	is_server = true
	_version = version
	_api.multiplayer_peer = peer
	_connect_api()
	_log("servidor escuchando en el puerto %d (versión %s)" % [port, version])
	return OK


func _process(delta: float) -> void:
	if not is_server:
		if state == "connecting":
			_connecting_for += delta
			if _connecting_for > CONNECT_TIMEOUT:
				_drop("No se encontró el servidor.")
		return
	for id in _pending.keys():
		_pending[id] += delta
		if _pending[id] > hello_timeout:
			_log("echo a %d: no se presentó" % id)
			_kick(id, "No se presentó a tiempo.")


func _on_peer_connected(id: int) -> void:
	if is_server:
		_pending[id] = 0.0
		var enet := _api.multiplayer_peer as ENetMultiplayerPeer
		if enet != null and enet.get_peer(id) != null:
			enet.get_peer(id).set_timeout(0, 0, TIMEOUT_MS)


func _on_peer_disconnected(id: int) -> void:
	if not is_server:
		return
	_pending.erase(id)
	if _by_id.has(id):
		_log("se fue %s (%d)" % [_by_id[id].name, id])
		_by_id.erase(id)
		_broadcast_players()


## Cliente → servidor: presentarse con la versión, el nombre y el equipo (resumen: especie y nivel).
@rpc("any_peer", "reliable")
func hello(version: String, protocol: int, player_name: String, team: Array) -> void:
	if not is_server:
		return
	var id := _api.get_remote_sender_id()
	if not _pending.has(id):
		return  # ya se presentó (o no existe)
	_pending.erase(id)
	if protocol != PROTOCOL or version != _version:
		_log("rechazo a %d: versión %s (la del servidor es %s)" % [id, version, _version])
		_kick(id, "Tu juego es de otra versión que el servidor: bajate el zip nuevo.")
		return
	if _by_id.size() >= MAX_PLAYERS:
		_kick(id, "La sala está llena.")
		return
	var entry := {"id": id, "name": _unique_name(clean_name(player_name)), "team": clean_team(team), "status": "libre"}
	_by_id[id] = entry
	_log("entró %s (%d) · %d conectados" % [entry.name, id, _by_id.size()])
	welcome.rpc_id(id, id, entry.name)
	_broadcast_players()


## Cliente → servidor: cambió su equipo (curó, subió de nivel...).
@rpc("any_peer", "reliable")
func update_team(team: Array) -> void:
	var id := _api.get_remote_sender_id() if _api.multiplayer_peer != null else 0
	if is_server and _by_id.has(id):
		_by_id[id].team = clean_team(team)
		_broadcast_players()


## Cliente → servidor: libre / eligiendo / peleando.
@rpc("any_peer", "reliable")
func set_status(status: String) -> void:
	var id := _api.get_remote_sender_id() if _api.multiplayer_peer != null else 0
	if is_server and _by_id.has(id) and status in STATUSES:
		_by_id[id].status = status
		_broadcast_players()


func _broadcast_players() -> void:
	players = _by_id.values()
	for id in _by_id:
		player_list.rpc_id(id, players)
	players_changed.emit(players)


func _kick(id: int, reason: String) -> void:
	_pending.erase(id)
	rejected.rpc_id(id, reason)
	# Que llegue el aviso antes de cortar.
	var enet := _api.multiplayer_peer as ENetMultiplayerPeer
	get_tree().create_timer(0.3).timeout.connect(func():
		if is_instance_valid(self) and enet != null and enet.get_peer(id) != null:
			enet.get_peer(id).peer_disconnect_later())


func _unique_name(n: String) -> String:
	var taken := _by_id.values().map(func(p): return p.name)
	if n not in taken:
		return n
	var i := 2
	while "%s (%d)" % [n, i] in taken:
		i += 1
	return "%s (%d)" % [n, i]


static func clean_name(n: String) -> String:
	var out := ""
	for ch in n.strip_edges():
		if ch.unicode_at(0) >= 32:
			out += ch
	out = out.substr(0, NAME_MAX).strip_edges()
	return out if out != "" else "Entrenador"


## Solo especies que existen y niveles con sentido (entre amigos no se valida más que eso).
static func clean_team(team: Array) -> Array:
	var out: Array = []
	for m in team.slice(0, 6):
		if m is Dictionary and DB.species.has(str(m.get("species", ""))):
			out.append({"species": str(m.species), "level": clampi(int(m.get("level", 1)), 1, 100)})
	return out


# --- Cliente -------------------------------------------------------------------------------

## Conecta a un servidor. `hello_data` = {version, name, team}; se manda apenas conecta.
func join(address: String, port: int, hello_data: Dictionary) -> Error:
	close()
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		_set_state("offline", "No se pudo conectar (%s)." % error_string(err))
		return err
	is_server = false
	_hello = hello_data
	_api.multiplayer_peer = peer
	_connect_api()
	if peer.get_peer(1) != null:
		peer.get_peer(1).set_timeout(0, 0, TIMEOUT_MS)
	_connecting_for = 0.0
	_set_state("connecting", "Conectando a %s..." % address)
	return OK


func _on_connected() -> void:
	hello.rpc_id(1, str(_hello.get("version", "")), PROTOCOL, str(_hello.get("name", "")), _hello.get("team", []))


func _on_connection_failed() -> void:
	_drop("No se encontró el servidor.")


func _on_server_disconnected() -> void:
	if state == "rejected":
		_clear_peer()  # queda "rejected" con el motivo a la vista
	else:
		_drop("Se cortó la conexión con el servidor.")


## Servidor → cliente: entraste a la sala.
@rpc("authority", "reliable")
func welcome(id: int, final_name: String) -> void:
	my_id = id
	_set_state("online", "Conectado como %s." % final_name)


## Servidor → cliente: no te deja entrar (versión, sala llena...).
@rpc("authority", "reliable")
func rejected(reason: String) -> void:
	_set_state("rejected", reason)


## Servidor → cliente: los conectados.
@rpc("authority", "reliable")
func player_list(list: Array) -> void:
	players = list
	players_changed.emit(players)


func send_team(team: Array) -> void:
	if state == "online":
		update_team.rpc_id(1, team)


func send_status(status: String) -> void:
	if state == "online":
		set_status.rpc_id(1, status)


func _drop(message: String) -> void:
	_clear_peer()
	players = []
	players_changed.emit(players)
	_set_state("offline", message)


# --- Los dos -------------------------------------------------------------------------------

## Corta todo (cliente: se desconecta; servidor: deja de escuchar).
func close() -> void:
	if _api == null or _api.multiplayer_peer == null:
		return
	var was_client := not is_server and state != "offline"
	_clear_peer()
	_by_id.clear()
	_pending.clear()
	players = []
	if was_client:
		_set_state("offline", "Desconectado.")


func _clear_peer() -> void:
	if _api.peer_connected.is_connected(_on_peer_connected):
		_api.peer_connected.disconnect(_on_peer_connected)
		_api.peer_disconnected.disconnect(_on_peer_disconnected)
		_api.connected_to_server.disconnect(_on_connected)
		_api.connection_failed.disconnect(_on_connection_failed)
		_api.server_disconnected.disconnect(_on_server_disconnected)
	if _api.multiplayer_peer != null:
		_api.multiplayer_peer.close()
	_api.multiplayer_peer = null
	my_id = 0


func _connect_api() -> void:
	_api.peer_connected.connect(_on_peer_connected)
	_api.peer_disconnected.connect(_on_peer_disconnected)
	_api.connected_to_server.connect(_on_connected)
	_api.connection_failed.connect(_on_connection_failed)
	_api.server_disconnected.connect(_on_server_disconnected)


func _set_state(s: String, message: String) -> void:
	state = s
	state_changed.emit(s, message)


func _log(text: String) -> void:
	print("[servidor] ", text)
