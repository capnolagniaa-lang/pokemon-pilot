class_name SparringRecorder
extends Node
## Graba tus peleas contra entrenadores para entrenar la IA (S-1, docs/PLAN_SPARRING_IA.md): cada 0,1 s la situación
## de los dos lados (dónde están, qué hacen, vida, PP, recargas, estados, qué amenaza ve la IA y si se está cuidando) y
## los hechos (ataques, golpes, esquives, debilitados, cambios), más tus marcas con F8 ("esto fue tonto"). Un JSON por
## pelea en `user://sparring/`. Lo lee `tools/sparring_report.py` (S-2). Graba cuando el ajuste "Grabar peleas" está
## prendido o cuando la consola GM arma una pelea con `sparring` (`armed`). Nodo del mundo (world.sparring).

const DIR := "user://sparring"
const RATE := 0.1
const VERSION := 2  # 2: + `metrics` (AiFightStats) y hechos "ia" (decisiones del rival, AiTrace)
## Tecla fija para marcar un momento (como F11 para pantalla completa): no se configura.
const MARK_KEY := KEY_F8
## Qué hay en cada muestra (una fila por `RATE` s; posiciones relativas a la arena, en px; velocidades en px/s).
const COLUMNS := ["t", "dist",
	"me_x", "me_y", "me_vx", "me_vy", "me_state", "me_hp", "me_pp", "me_ready", "me_hs", "me_st",
	"foe_x", "foe_y", "foe_vx", "foe_vy", "foe_state", "foe_hp", "foe_pp", "foe_ready", "foe_hs", "foe_st",
	"foe_mode", "foe_threat", "foe_wary", "shots"]

var world: Node
## La consola GM armó una pelea para grabar (se apaga sola al terminar).
var armed := false
var recording := false
## Último archivo guardado (lo lee el test).
var last_file := ""
var data: Dictionary = {}
var _t := 0.0
var _sample_in := 0.0
var _hooked: Array = []  # criaturas con señales conectadas
var _foe_seen: Creature
var _wary_seen := 0


func _ready() -> void:
	world = get_parent()
	Events.trainer_battle_started.connect(_on_started)
	Events.trainer_battle_ended.connect(_on_ended)
	Events.move_used.connect(_on_move_used)
	Events.creature_damaged.connect(_on_damaged)
	Events.creature_fainted.connect(_on_fainted)
	Events.ai_decided.connect(_on_ai_decided)


func should_record() -> bool:
	return armed or bool(GameState.setting("record_fights"))


func _on_started(kind: String) -> void:
	if recording or not should_record() or world.arena == null or not world.arena.active:
		return
	recording = true
	_t = 0.0
	_sample_in = 0.0
	_foe_seen = null
	_wary_seen = 0
	var me: CreatureInstance = GameState.active()
	data = {
		"version": VERSION, "date": Time.get_datetime_string_from_system(), "kind": kind,
		"difficulty": GameState.difficulty_id(), "arena": world.arena.arena_data.id if world.arena.arena_data else "",
		"trainer": world.arena.foe_name, "leader": world.arena.leader,
		"me": _instance_info(me),
		"foe_team": world.arena.foe_team.map(_instance_info),
		"columns": COLUMNS, "samples": [], "events": [], "marks": [], "result": "", "duration": 0.0,
	}
	Events.message_requested.emit("Grabando la pelea (F8 marca un momento para revisar).")


func _on_ended(result: String, _kind: String) -> void:
	if not recording:
		armed = false
		return
	recording = false
	armed = false
	data["result"] = result
	data["duration"] = _t
	var dbg: AiDebug = world.get("ai_debug")
	if dbg != null:
		data["metrics"] = dbg.stats.to_dict()  # (docs/IA_AUDITORIA.md, Fase 1)
	_unhook_all()
	last_file = _save()
	if last_file != "":
		Events.message_requested.emit("Pelea grabada: %s" % last_file.get_file())


func _physics_process(delta: float) -> void:
	if not recording or world.arena == null or not world.arena._fighting:
		return
	_t += delta
	var me: Creature = world.companion if is_instance_valid(world.companion) else null
	var foe: Creature = world.arena.foe if is_instance_valid(world.arena.foe) else null
	for c in [me, foe]:
		if c != null and not _hooked.has(c):
			_hook(c)
	if foe != _foe_seen and foe != null:
		_foe_seen = foe
		_event({"k": "send", "who": "foe", "species": foe.instance.species.id, "level": foe.instance.level})
	if foe != null and foe.mind.wary_count != _wary_seen:
		_wary_seen = foe.mind.wary_count
		_event({"k": "wary", "who": "foe"})
	_sample_in -= delta
	if _sample_in > 0.0:
		return
	_sample_in = RATE
	if me == null or foe == null:
		return
	var origin: Vector2 = world.arena.arena.global_position if is_instance_valid(world.arena.arena) else Vector2.ZERO
	var row: Array = [snappedf(_t, 0.01), roundf(me.global_position.distance_to(foe.global_position))]
	row.append_array(_side(me, origin))
	row.append_array(_side(foe, origin))
	var attack_state: Node = foe.get_node_or_null("StateMachine/Attack")
	var th: Dictionary = foe.mind.threat()
	row.append(str(attack_state.get("_mode")) if attack_state != null and foe.machine.current_name() == "attack" else "")
	row.append(str(th.get("kind", "")))
	row.append(foe.mind.wary())
	var shots := 0
	for n in world.entities.get_children():
		if n is Projectile:
			shots += 1
	row.append(shots)
	data["samples"].append(row)


## Posición, velocidad, estado, vida, PP, ranuras listas (bits), stagger y estados de una criatura.
func _side(c: Creature, origin: Vector2) -> Array:
	var p: Vector2 = c.global_position - origin
	var ready := 0
	for s in MoveUser.SLOT_COUNT:
		if c.moves.can_use(s):
			ready |= 1 << s
	return [roundf(p.x), roundf(p.y), roundf(c.velocity.x), roundf(c.velocity.y), c.machine.current_name(),
		snappedf(c.health.ratio(), 0.01), snappedf(c.moves.pp() / maxf(1.0, c.moves.max_pp()), 0.01), ready,
		snappedf(c.hitstun_left, 0.01), "|".join(c.statuses.active.keys())]


func _who(c: Node) -> String:
	if c == world.companion:
		return "me"
	if world.arena != null and c == world.arena.foe:
		return "foe"
	return ""


func _event(ev: Dictionary) -> void:
	ev["t"] = snappedf(_t, 0.01)
	data["events"].append(ev)


## Marca un momento para revisar (F8).
func mark() -> void:
	if not recording:
		return
	data["marks"].append(snappedf(_t, 0.01))
	Events.message_requested.emit("Momento marcado (%.1f s)." % _t)


func _unhandled_input(event: InputEvent) -> void:
	if recording and event is InputEventKey and event.pressed and not event.echo and event.keycode == MARK_KEY:
		mark()
		get_viewport().set_input_as_handled()


func _on_move_used(user: Node, move: MoveData) -> void:
	if not recording or not world.arena._fighting:
		return
	var who := _who(user)
	if who != "":
		_event({"k": "use", "who": who, "move": move.id})


func _on_damaged(c: Node, amount: float, hit: HitInfo) -> void:
	if not recording or not world.arena._fighting or hit == null or not c is Creature:
		return
	var who := _who(c)
	if who == "":
		return
	var cr: Creature = c
	var attacker: Node = hit.attacker if is_instance_valid(hit.attacker) else null
	var closing := false
	if attacker is Node2D and cr.velocity.length() > 5.0:
		closing = cr.velocity.normalized().dot((attacker.global_position - cr.global_position).normalized()) > 0.5
	_event({"k": "hit", "who": who, "move": hit.move.id if hit.move else "", "amount": snappedf(amount / maxf(1.0, cr.health.max_hp()), 0.001),
		"closing": closing, "hp": snappedf(cr.health.ratio(), 0.01)})


## Lo que decidió la IA del rival (AiTrace): va con los hechos como "ia", para que el informe lo muestre.
func _on_ai_decided(actor: Node, what: String, info: Dictionary) -> void:
	if not recording or world.arena == null or not world.arena._fighting or actor != world.arena.foe:
		return
	var ev := info.duplicate()
	ev.erase("t")
	ev["what"] = what
	ev["k"] = "ia"
	_event(ev)


func _on_fainted(c: Node) -> void:
	if recording and world.arena._fighting:
		var who := _who(c)
		if who != "":
			_event({"k": "faint", "who": who})


func _hook(c: Creature) -> void:
	_hooked.append(c)
	c.dodged.connect(_on_dodged.bind(c))
	c.slot_used.connect(_on_slot_used.bind(c))


func _unhook_all() -> void:
	for c in _hooked:
		if is_instance_valid(c):
			if c.dodged.is_connected(_on_dodged):
				c.dodged.disconnect(_on_dodged)
			if c.slot_used.is_connected(_on_slot_used):
				c.slot_used.disconnect(_on_slot_used)
	_hooked.clear()


## Esquivó: ¿había algo que esquivar? (la amenaza que veía en ese momento, según TacticalMind.threat; para tu Pokémon
## también, mirando al rival).
func _on_dodged(c: Creature) -> void:
	if not recording:
		return
	var who := _who(c)
	if who == "":
		return
	if who == "me" and not is_instance_valid(c.target) and is_instance_valid(world.arena.foe):
		c.target = world.arena.foe
	var th: Dictionary = c.mind.threat()
	_event({"k": "dodge", "who": who, "threat": str(th.get("kind", "")), "eta": snappedf(float(th.get("eta", -1.0)), 0.01)})


func _on_slot_used(slot: int, _aim: Vector2, _point: Vector2, c: Creature) -> void:
	if recording and world.arena._fighting:
		var who := _who(c)
		if who != "":
			var th: Dictionary = c.mind.threat() if who == "foe" else {}
			_event({"k": "slot", "who": who, "slot": slot, "threat": str(th.get("kind", ""))})


static func _instance_info(i: CreatureInstance) -> Dictionary:
	if i == null:
		return {}
	return {"species": i.species.id, "level": i.level, "ability": i.ability,
		"moves": i.equipped_moves.map(func(m): return m.id if m != null else "")}


func _save() -> String:
	var dir := DirAccess.open("user://")
	if dir == null:
		return ""
	dir.make_dir_recursive("sparring")
	var stamp := Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	var trainer: String = str(data.get("trainer", "")).to_lower().replace(" ", "_")
	var path := "%s/%s_%s.json" % [DIR, stamp, trainer if trainer != "" else "pelea"]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_warning("No se pudo guardar la pelea en %s" % path)
		return ""
	f.store_string(JSON.stringify(data))
	f.close()
	return path
