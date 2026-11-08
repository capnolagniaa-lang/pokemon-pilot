class_name NetPeer
extends Node
## Un extremo de la conexión online (docs/PLAN_ONLINE.md, O-0): el **servidor** (sala: quién está conectado) o un
## **cliente** (un jugador). Es el mismo script de los dos lados porque las RPC de Godot tienen que existir igual en
## ambos. Cada NetPeer usa su propia MultiplayerAPI (set_multiplayer sobre su rama): así el autotest levanta un
## servidor y dos clientes en el mismo proceso. El juego usa uno solo, el del autoload `Net`.

signal state_changed(state: String, message: String)
signal players_changed(players: Array)
# Desafíos y elección de equipo (O-2). Cliente:
signal challenged(from_id: int, from_name: String, count: int)
signal challenge_withdrawn(from_id: int)
signal challenge_answered(to_id: int, accepted: bool, message: String)
signal match_choose(match_id: int, opponent: Dictionary, count: int, seconds: float)
signal match_ready(match_id: int, opponent: Dictionary, opponent_team: Array)
signal match_cancelled(match_id: int, reason: String)
## Servidor: los dos eligieron equipo (la pelea la arma este mismo NetPeer si `host_battles`).
signal match_started(match: Dictionary)
## Cliente: la pelea online (O-3): foto del servidor (20 por segundo) y hechos (inicio, golpe, debilitado, sale otro, fin).
signal battle_state_received(match_id: int, state: Dictionary)
signal battle_event_received(match_id: int, ev: Dictionary)

## Sube cuando cambian los mensajes: un juego viejo y uno nuevo no se entienden.
const PROTOCOL := 8  # (4: el cambio 1-6 es el lugar en el equipo elegido; 5: aviso "use" de cada ataque, sin orden por rol; 6: Excavar en dos tiempos, dos avisos "use"; 7: contadores de toques en las teclas y la vida en el aviso "send"; 8: reconexión: token de sesión en hello/welcome, avisos "hold" y "resume")
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
## Formatos: cuántos Pokémon lleva cada uno.
const COUNTS := [1, 3, 6]
## Desafío sin contestar: se cae solo.
const ANSWER_TIMEOUT := 20.0
## Tiempo para elegir equipo (el cliente elige solo al terminar; el servidor espera un poco más y si no, cancela).
const CHOOSE_TIMEOUT := 30.0
const CHOOSE_GRACE := 5.0
## Reconexión (decisión del usuario 2026-11-08): al que se le corta la conexión en plena pelea, el servidor le guarda la
## partida este tiempo, con la pelea congelada para los dos; si vuelve (con su token de sesión), sigue donde estaba.
const RECONNECT_GRACE := 15.0

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
## Servidor: id → token de sesión (lo que el jugador presenta para volver a su pelea si se le corta la conexión).
var _tokens: Dictionary = {}
## Servidor: token → {entry, match, old_id, t}: jugadores que se cayeron en plena pelea y todavía pueden volver.
var _absent: Dictionary = {}
## (Var para que el autotest la achique.)
var reconnect_grace := RECONNECT_GRACE
## Cliente: mi token de sesión (lo da el servidor en welcome; se vuelve a presentar al reconectar).
var session_token := ""
## Cliente: al último welcome, ¿volví a una pelea que había dejado a medias?
var resumed := false
## Cliente: la última desconexión fue sin querer (se cortó, no se encontró el servidor), no un close().
var lost := false
## (Var para que el autotest lo achique.)
var hello_timeout := HELLO_TIMEOUT
var _api: SceneMultiplayer
var _version := ""
var _hello: Dictionary = {}
var _connecting_for := 0.0
## Servidor: desafíos abiertos, del que desafía → {to, count, t}.
var _challenges: Dictionary = {}
## Servidor: partidas, id → {id, a, b, count, teams: {id: [CreatureInstance.to_dict]}, t, ready}.
var matches: Dictionary = {}
var _next_match := 1
## (Vars para que el autotest los achique.)
var answer_timeout := ANSWER_TIMEOUT
var choose_timeout := CHOOSE_TIMEOUT
## Servidor: simula las peleas (O-3). Apagado: la partida termina al elegir equipo (como en la O-2).
var host_battles := true
## Servidor: peleas en curso, id de partida → NetMatch.
var battles: Dictionary = {}
## Cada pelea del servidor va a `ARENA_GAP` px de las demás (lugar libre: una pelea larga no se encima con la 17.ª).
const ARENA_GAP := 4000.0
const ARENA_BASE := Vector2(-60000, -60000)
## Solo para los tests: red simulada. Demora (ms) con la que se procesa lo que llega de la pelea (fotos, hechos y teclas) y
## proporción de paquetes sin garantía (fotos, teclas) que se pierden.
var sim_latency_ms := 0
var sim_loss := 0.0


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
	_api.server_relay = false  # los clientes no se hablan entre ellos a través del servidor (solo con él)
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
	for from in _challenges.keys():
		var c: Dictionary = _challenges[from]
		c.t += delta
		if c.t > answer_timeout:
			_challenges.erase(from)
			got_answer.rpc_id(from, c.to, false, "%s no contestó." % _name_of(c.to))
			got_withdrawn.rpc_id(c.to, from)
	for mid in matches.keys():
		var m: Dictionary = matches[mid]
		m.t += delta
		if not m.ready and m.t > choose_timeout + CHOOSE_GRACE:
			_cancel_match(mid, "No se eligió el equipo a tiempo.")
	for token in _absent.keys():
		var ab: Dictionary = _absent[token]
		ab.t += delta
		if ab.t > reconnect_grace:
			_absent.erase(token)
			var mid: int = ab.match
			if battles.has(mid) and matches.has(mid):
				_log("partida %d: %s no volvió en %d s" % [mid, ab.entry.name, int(reconnect_grace)])
				battles[mid].finish(_other(matches[mid], ab.old_id), "%s se desconectó." % ab.entry.name)


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
		var who: String = _by_id[id].name
		var entry: Dictionary = _by_id[id]
		var token: String = str(_tokens.get(id, ""))
		_by_id.erase(id)  # antes de avisar: que no se le mande nada al que se fue
		_tokens.erase(id)
		for from in _challenges.keys():
			var c: Dictionary = _challenges[from]
			if from == id:
				_challenges.erase(from)
				got_withdrawn.rpc_id(c.to, from)
			elif c.to == id:
				_challenges.erase(from)
				got_answer.rpc_id(from, id, false, "%s se desconectó." % who)
		for mid in matches.keys():
			if id in [matches[mid].a, matches[mid].b]:
				if battles.has(mid):
					_hold_battle(mid, id, entry, token)
				else:
					_cancel_match(mid, "%s se desconectó." % who, id)
		_broadcast_players()


## Se cayó uno en plena pelea: la pelea se congela y se lo espera `reconnect_grace` s (si ya se estaba esperando al otro,
## no hay a quién esperar: se termina sin ganador).
func _hold_battle(mid: int, id: int, entry: Dictionary, token: String) -> void:
	var nm: NetMatch = battles[mid]
	var other := _other(matches[mid], id)
	var other_absent: bool = _absent.values().any(func(ab): return ab.match == mid)
	if other_absent or token == "":
		for t in _absent.keys():
			if _absent[t].match == mid:
				_absent.erase(t)
		nm.finish(other if token != "" else 0, "Los dos se desconectaron." if other_absent else "%s se desconectó." % entry.name)
		return
	_absent[token] = {"entry": entry, "match": mid, "old_id": id, "t": 0.0}
	_log("partida %d: se espera a %s hasta %d s" % [mid, entry.name, int(reconnect_grace)])
	nm.hold(id, reconnect_grace)


## Volvió uno que se había caído: su lugar pasa al id nuevo, le mandamos cómo está la pelea y sigue para los dos.
func _resume_battle(ab: Dictionary, new_id: int) -> void:
	var mid: int = ab.match
	var old_id: int = ab.old_id
	if not battles.has(mid) or not matches.has(mid):
		return
	var m: Dictionary = matches[mid]
	if m.a == old_id:
		m.a = new_id
	elif m.b == old_id:
		m.b = new_id
	var nm: NetMatch = battles[mid]
	nm.rebind(old_id, new_id)
	_log("partida %d: volvió %s (%d → %d)" % [mid, ab.entry.name, old_id, new_id])
	nm.resume(new_id, old_id)


## Cliente → servidor: presentarse con la versión, el nombre y el equipo (resumen: especie y nivel).
@rpc("any_peer", "reliable")
func hello(version: String, protocol: int, player_name: String, team: Array, token: String = "") -> void:
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
	# ¿Vuelve a una pelea que dejó a medias? (Si el servidor todavía no notó que su conexión vieja se cortó, la corta ya.)
	if token != "":
		var old := _owner_of_token(token)
		if old > 0 and old != id:
			var enet := _api.multiplayer_peer as ENetMultiplayerPeer
			if enet != null and enet.get_peer(old) != null:
				enet.get_peer(old).peer_disconnect_now()
			_on_peer_disconnected(old)
	if token != "" and _absent.has(token):
		var ab: Dictionary = _absent[token]
		_absent.erase(token)
		var back: Dictionary = ab.entry
		back.id = id
		back.status = "peleando"
		_by_id[id] = back
		_tokens[id] = token
		_log("volvió %s (%d) · %d conectados" % [back.name, id, _by_id.size()])
		welcome.rpc_id(id, id, back.name, token, true)
		_broadcast_players()
		_resume_battle(ab, id)
		return
	var entry := {"id": id, "name": _unique_name(clean_name(player_name)), "team": clean_team(team), "status": "libre"}
	_by_id[id] = entry
	_tokens[id] = "%08x%08x" % [randi(), randi()]
	_log("entró %s (%d) · %d conectados" % [entry.name, id, _by_id.size()])
	welcome.rpc_id(id, id, entry.name, _tokens[id], false)
	_broadcast_players()


func _owner_of_token(token: String) -> int:
	for id in _tokens:
		if _tokens[id] == token:
			return id
	return 0


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


## Cliente → servidor: desafiar a alguien (cuántos Pokémon lleva cada uno: COUNTS).
@rpc("any_peer", "reliable")
func challenge(to_id: int, count: int) -> void:
	if not is_server:
		return
	var from := _api.get_remote_sender_id()
	if not _by_id.has(from):
		return
	var why := _challenge_problem(from, to_id, count)
	if why != "":
		got_answer.rpc_id(from, to_id, false, why)
		return
	_challenges[from] = {"to": to_id, "count": count, "t": 0.0}
	_log("%s desafía a %s (%d contra %d)" % [_name_of(from), _name_of(to_id), count, count])
	got_challenge.rpc_id(to_id, from, _name_of(from), count)


## Cliente → servidor: retirar el desafío que mandé.
@rpc("any_peer", "reliable")
func withdraw() -> void:
	if not is_server:
		return
	var from := _api.get_remote_sender_id()
	if _challenges.has(from):
		var c: Dictionary = _challenges[from]
		_challenges.erase(from)
		got_withdrawn.rpc_id(c.to, from)


## Cliente → servidor: aceptar o rechazar el desafío de `from_id`.
@rpc("any_peer", "reliable")
func answer(from_id: int, accept: bool) -> void:
	if not is_server:
		return
	var me := _api.get_remote_sender_id()
	var c = _challenges.get(from_id)
	if c == null or c.to != me:
		return
	_challenges.erase(from_id)
	if not accept:
		got_answer.rpc_id(from_id, me, false, "%s no aceptó." % _name_of(me))
		return
	if _by_id[from_id].status != "libre" or _by_id[me].status != "libre":
		got_answer.rpc_id(from_id, me, false, "Uno de los dos está ocupado.")
		return
	got_answer.rpc_id(from_id, me, true, "")
	var m := {"id": _next_match, "a": from_id, "b": me, "count": int(c.count), "teams": {}, "t": 0.0, "ready": false}
	_next_match += 1
	matches[m.id] = m
	for p in [m.a, m.b]:
		_by_id[p].status = "eligiendo"
		got_choose.rpc_id(p, m.id, _public(_other(m, p)), m.count, choose_timeout)
	_broadcast_players()


## Cliente → servidor: los Pokémon que lleva a la partida (CreatureInstance.to_dict, hasta `count`).
@rpc("any_peer", "reliable")
func choose_team(match_id: int, team: Array) -> void:
	if not is_server:
		return
	var me := _api.get_remote_sender_id()
	var m = matches.get(match_id)
	if m == null or m.ready or me not in [m.a, m.b] or m.teams.has(me):
		return
	var clean := clean_battle_team(team, m.count)
	if clean.is_empty():
		_cancel_match(match_id, "%s no tiene Pokémon en condiciones." % _name_of(me))
		return
	m.teams[me] = clean
	if m.teams.size() < 2:
		return
	m.ready = true
	for p in [m.a, m.b]:
		_by_id[p].status = "peleando"
		got_ready.rpc_id(p, m.id, _public(_other(m, p)), m.teams[_other(m, p)])
	_broadcast_players()
	_log("partida %d: %s contra %s" % [m.id, _name_of(m.a), _name_of(m.b)])
	match_started.emit(m)
	if host_battles:
		_start_battle(m)
	else:
		end_match(m.id)


## Arma la pelea en el servidor (NetMatch), lejos de las demás, y reparte sus fotos y hechos a los dos.
func _start_battle(m: Dictionary) -> void:
	var nm := NetMatch.new()
	nm.name = "Match%d" % m.id
	nm.setup(m.id, m.a, m.b, m.teams)
	nm.position = ARENA_BASE + Vector2(_free_arena_slot() * ARENA_GAP, 0.0)
	nm.event.connect(func(ev: Dictionary):
		for p in [m.a, m.b]:
			if _can_send(p):
				battle_event.rpc_id(p, m.id, ev))
	nm.snapshot.connect(func(st: Dictionary):
		for p in [m.a, m.b]:
			if _can_send(p):
				battle_state.rpc_id(p, m.id, st))
	nm.finished.connect(func(winner: int, reason: String):
		_log("partida %d: ganó %s%s" % [m.id, _name_of(winner), " (%s)" % reason if reason != "" else ""])
		battles.erase(m.id)
		nm.queue_free.call_deferred()
		end_match(m.id))
	nm.set_meta("arena_slot", int((nm.position.x - ARENA_BASE.x) / ARENA_GAP))
	battles[m.id] = nm
	add_child(nm)


## El primer lugar que no ocupa ninguna pelea viva.
func _free_arena_slot() -> int:
	var used := battles.values().filter(func(nm): return is_instance_valid(nm)).map(func(nm): return int(nm.get_meta("arena_slot", -1)))
	var k := 0
	while used.has(k):
		k += 1
	return k


## Cliente → servidor: mis teclas en la pelea (NetCombatInput.pack). Muchas por segundo: sin garantía, en orden.
@rpc("any_peer", "unreliable_ordered")
func battle_input(match_id: int, packet: Array) -> void:
	if not is_server or not battles.has(match_id) or not packet is Array:
		return
	var from := _api.get_remote_sender_id()
	_simulated(false, func():
		if battles.has(match_id):
			battles[match_id].set_input(from, packet))


## Red simulada (tests): corre `what` ya, o con la demora y la pérdida configuradas. Devuelve si lo corrió o lo programó.
func _simulated(reliable: bool, what: Callable) -> bool:
	if sim_latency_ms <= 0 and sim_loss <= 0.0:
		what.call()
		return true
	if not reliable and sim_loss > 0.0 and randf() < sim_loss:
		return false
	if sim_latency_ms <= 0:
		what.call()
	else:
		get_tree().create_timer(sim_latency_ms / 1000.0).timeout.connect(what)
	return true


## Cliente → servidor: cambiar de Pokémon (1-6).
@rpc("any_peer", "reliable")
func battle_switch(match_id: int, index: int) -> void:
	if is_server and battles.has(match_id):
		battles[match_id].request_switch(_api.get_remote_sender_id(), index)


## Servidor → cliente: foto de la pelea.
@rpc("authority", "unreliable_ordered")
func battle_state(match_id: int, st: Dictionary) -> void:
	_simulated(false, func(): battle_state_received.emit(match_id, st))


## Servidor → cliente: un hecho de la pelea.
@rpc("authority", "reliable")
func battle_event(match_id: int, ev: Dictionary) -> void:
	_simulated(true, func(): battle_event_received.emit(match_id, ev))


## Servidor: terminó la partida (la llama la pelea, O-3): los dos quedan libres.
func end_match(match_id: int) -> void:
	var m = matches.get(match_id)
	if m == null:
		return
	matches.erase(match_id)
	for p in [m.a, m.b]:
		if _by_id.has(p):
			_by_id[p].status = "libre"
	_broadcast_players()


func _cancel_match(match_id: int, reason: String, skip: int = 0) -> void:
	var m = matches.get(match_id)
	if m == null:
		return
	for p in [m.a, m.b]:
		if p != skip and _by_id.has(p):
			got_cancelled.rpc_id(p, match_id, reason)
	end_match(match_id)


func _challenge_problem(from: int, to_id: int, count: int) -> String:
	if from == to_id:
		return "No te podés desafiar a vos mismo."
	if not _by_id.has(to_id):
		return "Ya no está conectado."
	if count not in COUNTS:
		return "Ese formato no existe."
	if _busy(from):
		return "Ya estás en un desafío o en una partida."
	if _busy(to_id) or _by_id[to_id].status != "libre":
		return "%s está ocupado." % _name_of(to_id)
	if _by_id[from].team.is_empty() or _by_id[to_id].team.is_empty():
		return "Para pelear los dos tienen que tener Pokémon."
	return ""


## En un desafío (mandado o recibido) o en una partida.
func _busy(id: int) -> bool:
	if _challenges.has(id) or _challenges.values().any(func(c): return c.to == id):
		return true
	return matches.values().any(func(m): return id in [m.a, m.b])


func _other(m: Dictionary, p: int) -> int:
	return m.b if p == m.a else m.a


func _public(id: int) -> Dictionary:
	var e: Dictionary = _by_id.get(id, {})
	return {"id": id, "name": e.get("name", "?"), "team": e.get("team", [])}


func _name_of(id: int) -> String:
	return _by_id[id].name if _by_id.has(id) else "?"


## Equipo para pelear: lo que se puede rearmar como CreatureInstance, en pie, hasta `count`. La vida va como
## proporción (`hp_ratio`): cada partida puede tener otra escala de vida (Ajustes del juego).
static func clean_battle_team(team: Array, count: int) -> Array:
	var out: Array = []
	for d in team:
		if out.size() >= count:
			break
		if not d is Dictionary or not DB.species.has(str(d.get("species_id", ""))):
			continue
		var inst := CreatureInstance.from_dict(d)
		if inst == null or inst.hp <= 0.0:
			continue
		# Habilidad de su especie (una ajena cambiaría la pelea) y apodo corto y limpio (los demás lo ven en pantalla).
		var ok_abilities: Array = inst.species.abilities.map(func(a): return a.id)
		if not ok_abilities.is_empty() and inst.ability not in ok_abilities:
			inst.ability = ok_abilities[0]
		inst.nickname = clean_name(inst.nickname).substr(0, 12) if inst.nickname.strip_edges() != "" else ""
		var clean := inst.to_dict()
		clean["hp_ratio"] = clampf(float(d.get("hp_ratio", inst.hp / maxf(1.0, inst.max_hp()))), 0.01, 1.0)
		out.append(clean)
	return out


func _broadcast_players() -> void:
	players = _by_id.values()
	for id in _by_id:
		if _can_send(id):
			player_list.rpc_id(id, players)
	players_changed.emit(players)


## ¿Se le puede mandar algo a ese peer? (Uno que se está yendo ya no tiene canales: mandarle llena la consola de errores.)
func _can_send(id: int) -> bool:
	if not is_server:
		return false
	if not _by_id.has(id):
		return false
	var enet := _api.multiplayer_peer as ENetMultiplayerPeer
	if enet == null:
		return false
	var p := enet.get_peer(id)
	return p != null and p.get_state() == ENetPacketPeer.STATE_CONNECTED


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
	lost = false
	resumed = false
	_api.multiplayer_peer = peer
	_connect_api()
	if peer.get_peer(1) != null:
		peer.get_peer(1).set_timeout(0, 0, TIMEOUT_MS)
	_connecting_for = 0.0
	_set_state("connecting", "Conectando a %s..." % address)
	return OK


func _on_connected() -> void:
	hello.rpc_id(1, str(_hello.get("version", "")), PROTOCOL, str(_hello.get("name", "")), _hello.get("team", []),
		str(_hello.get("token", "")))


func _on_connection_failed() -> void:
	_drop("No se encontró el servidor.")


func _on_server_disconnected() -> void:
	if state == "rejected":
		_clear_peer()  # queda "rejected" con el motivo a la vista
	else:
		_drop("Se cortó la conexión con el servidor.")


## Servidor → cliente: entraste a la sala (`token` = tu sesión, para volver si se corta; `back` = volviste a tu pelea).
@rpc("authority", "reliable")
func welcome(id: int, final_name: String, token: String, back: bool) -> void:
	my_id = id
	session_token = token
	resumed = back
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


## Servidor → cliente: te desafían.
@rpc("authority", "reliable")
func got_challenge(from_id: int, from_name: String, count: int) -> void:
	challenged.emit(from_id, from_name, count)


## Servidor → cliente: el que te desafió lo retiró (o se cayó).
@rpc("authority", "reliable")
func got_withdrawn(from_id: int) -> void:
	challenge_withdrawn.emit(from_id)


## Servidor → cliente: respuesta a tu desafío (o por qué no se pudo mandar).
@rpc("authority", "reliable")
func got_answer(to_id: int, accepted: bool, message: String) -> void:
	challenge_answered.emit(to_id, accepted, message)


## Servidor → cliente: aceptado: elegí tu equipo.
@rpc("authority", "reliable")
func got_choose(match_id: int, opponent: Dictionary, count: int, seconds: float) -> void:
	match_choose.emit(match_id, opponent, count, seconds)


## Servidor → cliente: los dos eligieron: con qué viene el otro.
@rpc("authority", "reliable")
func got_ready(match_id: int, opponent: Dictionary, opponent_team: Array) -> void:
	match_ready.emit(match_id, opponent, opponent_team)


## Servidor → cliente: se cayó la partida antes de empezar.
@rpc("authority", "reliable")
func got_cancelled(match_id: int, reason: String) -> void:
	match_cancelled.emit(match_id, reason)


func send_challenge(to_id: int, count: int) -> void:
	if state == "online":
		challenge.rpc_id(1, to_id, count)


func send_withdraw() -> void:
	if state == "online":
		withdraw.rpc_id(1)


func send_answer(from_id: int, accept: bool) -> void:
	if state == "online":
		answer.rpc_id(1, from_id, accept)


## Los Pokémon elegidos (CreatureInstance) para la partida.
func send_choice(match_id: int, team: Array) -> void:
	if state == "online":
		choose_team.rpc_id(1, match_id, team.map(func(c: CreatureInstance):
			var d := c.to_dict()
			d["hp_ratio"] = c.hp / maxf(1.0, c.max_hp())
			return d))


func send_battle_input(match_id: int, packet: Array) -> void:
	if state == "online" and _server_reachable():
		battle_input.rpc_id(1, match_id, packet)


## Cliente: el servidor sigue conectado del lado de ENet (si se cayó, hasta que ENet lo note no se le manda nada).
func _server_reachable() -> bool:
	var enet := _api.multiplayer_peer as ENetMultiplayerPeer
	if enet == null or enet.get_peer(1) == null:
		return false
	return enet.get_peer(1).get_state() == ENetPacketPeer.STATE_CONNECTED


func send_battle_switch(match_id: int, index: int) -> void:
	if state == "online":
		battle_switch.rpc_id(1, match_id, index)


func send_team(team: Array) -> void:
	if state == "online":
		update_team.rpc_id(1, team)


func send_status(status: String) -> void:
	if state == "online":
		set_status.rpc_id(1, status)


func _drop(message: String) -> void:
	lost = true
	_clear_peer()
	players = []
	players_changed.emit(players)
	_set_state("offline", message)


## Cliente: ida y vuelta al servidor en ms (lo mide ENet todo el tiempo; -1 si no hay conexión).
func ping_ms() -> int:
	if is_server or _api == null:
		return -1
	var enet := _api.multiplayer_peer as ENetMultiplayerPeer
	if enet == null or enet.get_peer(1) == null:
		return -1
	return int(enet.get_peer(1).get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME))


# --- Los dos -------------------------------------------------------------------------------

## Corta todo (cliente: se desconecta; servidor: deja de escuchar).
func close() -> void:
	if _api == null or _api.multiplayer_peer == null:
		return
	var was_client := not is_server and state != "offline"
	lost = false
	_clear_peer()
	_by_id.clear()
	_pending.clear()
	_tokens.clear()
	_absent.clear()
	_challenges.clear()
	matches.clear()
	for nm in battles.values():
		if is_instance_valid(nm):
			nm.queue_free()
	battles.clear()
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
