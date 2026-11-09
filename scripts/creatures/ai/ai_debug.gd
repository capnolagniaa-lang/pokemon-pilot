class_name AiDebug
extends Node
## Herramientas para mirar la IA de los entrenadores (Fase 1 de docs/IA_AUDITORIA.md). Nodo del mundo (`world.ai_debug`):
##  · **métricas** de cada pelea de arena (`AiFightStats`): se miden siempre (son contadores); al terminar quedan en
##    `last_stats` (las guarda el JSON de sparring) y en el registro;
##  · **registro** a archivo de cada decisión (`AiTrace`, consola GM `ia log`): `user://ia_log/<fecha>.log`;
##  · **overlay** (consola GM `ia ver`): la situación del rival, lo que está haciendo, los 3 mejores ataques con su
##    puntaje, lo que te tiene leído y las métricas de la pelea en curso.
## Nada de esto cambia cómo pelea la IA.

const LOG_DIR := "user://ia_log"
## Cada cuánto se rearma el texto del overlay.
const OVERLAY_RATE := 0.15
## Estados en los que uno quedó expuesto por algo que hizo (o aturdido): ventanas de castigo.
const OPEN_STATES := ["cast", "channel", "recovery", "stunned"]

var world: Node
## Las métricas de la pelea en curso (o de la última, ya terminada).
var stats := AiFightStats.new()
var last_stats: Dictionary = {}
var fighting := false
## Últimas decisiones del rival (para el overlay): textos "12.3 s · ataque Placaje (elige)".
var recent: Array[String] = []
## Archivo del registro abierto (vacío si no hay).
var log_path := ""
var _log: FileAccess
var _layer: CanvasLayer
var _panel: PanelContainer
var _label: Label
var _overlay_in := 0.0
var _companion: Creature
var _your_mon: CreatureInstance
## La situación que lee la IA nueva del rival que mira el overlay (Fase 2: Perception + Situation) y la última anotada.
var situation: Situation
var _situation_logged := -1


func _ready() -> void:
	world = get_parent()
	Events.trainer_battle_started.connect(_on_started)
	Events.trainer_battle_ended.connect(_on_ended)
	Events.creature_damaged.connect(_on_damaged)
	Events.move_used.connect(_on_move_used)
	Events.ai_decided.connect(_on_decided)
	_build_overlay()


func _exit_tree() -> void:
	AiTrace.measuring = false
	_close_log()


# --- Prender y apagar (consola GM) ---

## Prende o apaga el registro a archivo. Devuelve el texto para la consola.
func set_log(on: bool) -> String:
	AiTrace.log_on = on
	if not on:
		var was := log_path
		_close_log()
		return "Registro de la IA apagado%s." % ((": " + was) if was != "" else "")
	_open_log()
	return "Registro de la IA prendido: %s" % ProjectSettings.globalize_path(log_path)


func set_overlay(on: bool) -> String:
	AiTrace.overlay_on = on
	_layer.visible = on
	_overlay_in = 0.0
	return "Overlay de la IA %s." % ("prendido" if on else "apagado")


# --- La pelea ---

func _on_started(_kind: String) -> void:
	if world.arena == null or not world.arena.active:
		return
	stats = AiFightStats.new()
	fighting = true
	recent.clear()
	AiTrace.measuring = true
	_your_mon = null
	_write("=== Pelea contra %s (estilo %s) · dificultad %s ===" % [world.arena.foe_name, _style_name(world.arena.style),
		GameState.difficulty_id()])


func _on_ended(result: String, _kind: String) -> void:
	if not fighting:
		return
	fighting = false
	AiTrace.measuring = false
	last_stats = stats.to_dict()
	last_stats["resultado"] = result
	_write("=== Terminó: %s · %s ===" % [result, stats.summary()])
	_write(JSON.stringify(last_stats))


func _physics_process(delta: float) -> void:
	if fighting and world.arena != null and world.arena._fighting:
		_measure(delta)
	if AiTrace.overlay_on:
		_perceive()
		_overlay_in -= delta
		if _overlay_in <= 0.0:
			_overlay_in = OVERLAY_RATE
			_label.text = overlay_text()


func _measure(delta: float) -> void:
	var me: Creature = world.companion if is_instance_valid(world.companion) and not world.companion.is_down() else null
	var foe: Creature = world.arena.foe if is_instance_valid(world.arena.foe) and not world.arena.foe.is_down() else null
	if me != _companion:
		if is_instance_valid(_companion) and _companion.dodged.is_connected(_on_your_dodge):
			_companion.dodged.disconnect(_on_your_dodge)
		_companion = me
		if me != null:
			me.dodged.connect(_on_your_dodge)
	if me != null and me.instance != _your_mon:
		if _your_mon != null and _your_mon.hp > 0.0:
			stats.on_your_switch()  # (si el anterior cayó, no lo cambiaste vos)
		_your_mon = me.instance
	if me == null or foe == null:
		return
	var dist := me.global_position.distance_to(foe.global_position)
	var mode := ""
	if foe.machine.current_name() == "attack" and foe._brain != null and foe.uses_new_brain():
		mode = foe.brain.move_name()
	elif foe.machine.current_name() == "attack":
		var st: Node = foe.get_node_or_null("StateMachine/Attack")
		if st != null and st.has_method("mode"):
			mode = st.mode()
	else:
		mode = foe.machine.current_name()
	stats.tick(delta, is_open(foe), is_open(me), can_hit(foe, dist), can_hit(me, dist), mode)


## Expuesto por algo que hizo (cargando, canalizando, recuperándose) o aturdido. El stagger de un golpe no cuenta.
static func is_open(c: Creature) -> bool:
	return c.machine.current_name() in OPEN_STATES or not c.statuses.can_act()


## Tiene un ataque con daño listo que llega desde esta distancia.
static func can_hit(c: Creature, dist: float) -> bool:
	for slot in MoveUser.SLOT_COUNT:
		var m: MoveData = c.moves.slots[slot]
		if m != null and m.power > 0.0 and m.category != MoveData.Category.STATUS and c.body.fits(slot, dist):
			return true
	return false


func _who(c: Node) -> String:
	if not fighting or c == null:
		return ""
	if c == world.companion:
		return "vos"
	if world.arena != null and c == world.arena.foe:
		return "ia"
	return ""


func _on_damaged(c: Node, amount: float, _hit: HitInfo) -> void:
	var who := _who(c)
	if who != "" and amount > 0.0 and c is Creature:
		stats.on_hit(who, amount / maxf(1.0, c.health.max_hp()))


func _on_move_used(user: Node, move: MoveData) -> void:
	var who := _who(user)
	if who != "" and move != null:
		stats.on_use(who, move.display_name)


func _on_your_dodge() -> void:
	if fighting:
		stats.on_your_dodge()


func _on_decided(actor: Node, what: String, data: Dictionary) -> void:
	var mine := _who(actor) == "ia"
	if mine:
		stats.on_decision(what, data)
	if not mine and fighting:
		return  # (en una pelea de arena solo interesa el rival)
	var t: float = stats.duration if fighting else float(data.get("t", 0.0))  # (en la arena, el reloj de la pelea)
	var line := "%.1f s · %s %s" % [t, what, AiTrace.describe(data)]
	if AiTrace.overlay_on and (mine or actor == _overlay_target()):
		recent.push_front(line)
		if recent.size() > 6:
			recent.pop_back()
	if AiTrace.log_on:
		_write("[%.2f] %s %s %s" % [t, AiTrace.who(actor), what, AiTrace.describe(data)])


# --- Registro a archivo ---

func _open_log() -> void:
	if _log != null:
		return
	DirAccess.make_dir_recursive_absolute(LOG_DIR)
	var stamp := Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	log_path = "%s/%s.log" % [LOG_DIR, stamp]
	_log = FileAccess.open(log_path, FileAccess.WRITE)
	if _log == null:
		push_warning("No se pudo abrir el registro de la IA en %s" % log_path)
		log_path = ""


func _close_log() -> void:
	if _log != null:
		_log.close()
	_log = null
	log_path = ""


func _write(line: String) -> void:
	if not AiTrace.log_on:
		return
	if _log == null:
		_open_log()
	if _log != null:
		_log.store_line(line)
		_log.flush()


# --- Overlay ---

func _build_overlay() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 15
	_layer.visible = false
	add_child(_layer)
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", UiStyle.box(Color(0, 0, 0, 0.72), Color(1, 0.75, 0.3, 0.8), 1, 8))
	_panel.position = Vector2(884, 92)  # (a la derecha, debajo del cartel del rival)
	_panel.custom_minimum_size = Vector2(384, 0)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_panel)
	_label = UiStyle.label("", 11)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(384, 0)
	_panel.add_child(_label)


## A quién mira el overlay: el Pokémon del entrenador en la arena o, si no, el primer rival del combate.
func _overlay_target() -> Creature:
	if world.arena != null and world.arena.active and is_instance_valid(world.arena.foe):
		return world.arena.foe
	if world.get("combat") != null:
		for e in world.combat.enemies:
			if is_instance_valid(e) and e is Creature and not e.is_down():
				return e
	return null


## Con el overlay prendido, el rival que se mira percibe y lee su situación como lo hará el cerebro nuevo (Fase 2). No
## cambia lo que hace: la IA de hoy no usa nada de esto.
func _perceive() -> void:
	var c := _overlay_target()
	if c == null:
		situation = null
		return
	c.perception.tick()
	var bench: Array = []
	if world.arena != null and world.arena.active and c == world.arena.foe:
		bench = world.arena.foe_team
	situation = Situation.read(c, c.perception, bench)
	if situation.primary != _situation_logged:
		_situation_logged = situation.primary
		AiTrace.note(c, "situacion", situation.to_dict())


## El texto del overlay (público para el test).
func overlay_text() -> String:
	var c := _overlay_target()
	if c == null:
		return "IA · no hay rival"
	var t: Creature = c.target if is_instance_valid(c.target) else null
	var mind: TacticalMind = c.mind
	var lines: PackedStringArray = []
	var style_id: String = ("estilo " + _style_name(c.trainer_style)) if c.trainer_style != null else "salvaje"
	lines.append("IA · %s Nv. %d · %s · %s" % [c.instance.display_name(), c.instance.level, style_id, GameState.difficulty_id()])
	var mode := c.machine.current_name()
	var st: Node = c.get_node_or_null("StateMachine/Attack")
	if mode == "attack" and c._brain != null and c.uses_new_brain():
		mode = "attack/" + c.brain.move_name()
	elif mode == "attack" and st != null and st.has_method("mode"):
		mode = "attack/" + st.mode()
	var dist := c.global_position.distance_to(t.global_position) if t != null else -1.0
	var flags: PackedStringArray = []
	if t != null and TacticalMind.exposed(t):
		flags.append("vos expuesto")
	if mind.window_open():
		flags.append("ventana")
	if mind.wary():
		flags.append("cuidándose")
	if mind.saving:
		flags.append("juntando PP (%.1f s)" % mind.save_left())
	if mind.all_in:
		flags.append("se juega todo")
	var plan := mind.low_hp_plan()
	if plan != "":
		flags.append("vida baja: " + plan)
	lines.append("Situación: dist %d · %s · cruce %s · vida %d%% · PP %d%%%s" % [roundi(dist), mode,
		mind.matchup() if mind.matchup() != "" else "parejo", roundi(c.health.ratio() * 100.0),
		roundi(c.moves.pp() / maxf(1.0, c.moves.max_pp()) * 100.0), (" · " + ", ".join(flags)) if not flags.is_empty() else ""])
	var th := mind.threat()
	lines.append("Amenaza: %s" % ("%s en %.2f s%s" % [th.kind, th.eta, " (fuerte)" if th.strong else ""] if not th.is_empty() else "—"))
	var top := AiTrace.top3(c)
	lines.append("Top: %s (%s)" % [" · ".join(top) if not top.is_empty() else "—", mind.last_reason if mind.last_reason != "" else "—"])
	lines.append("Te lee: %s" % prediction_text(mind))
	if situation != null:
		lines.append("IA nueva (ve hace %.2f s): %s" % [c.perception.age(), situation.to_text()])
	if c.uses_new_brain():
		lines.append("Cerebro nuevo: " + c.brain.describe())
		if world.arena != null and world.arena.active and world.arena.coach != null and not world.arena.coach.chosen.is_empty():
			lines.append("Entrenador: %s (%d%%)" % [world.arena.coach.chosen.name, roundi(float(world.arena.coach.chosen.p) * 100.0)])
	if fighting and c == _overlay_target() and world.arena != null and world.arena.active:
		lines.append("Pelea: " + stats.summary())
	if not recent.is_empty():
		lines.append("Últimas: " + "\n  ".join(recent.slice(0, 3)))
	return "\n".join(lines)


static func _style_name(st: TrainerStyle) -> String:
	return "-" if st == null else (st.id if st.id != "" else "por defecto")


## Lo que la IA cree de vos (de lo que vio): hacia dónde esquivás, de qué distancia peleás y qué repetís.
static func prediction_text(mind: TacticalMind) -> String:
	var parts: PackedStringArray = []
	var read := mind.dodge_read()
	if int(read[0]) != 0:
		parts.append("esquivás hacia un lado (%d%%)" % roundi(float(read[1]) * 100.0))
	else:
		parts.append("esquives: %d vistos, sin lado claro" % mind.dodge_sides.size())
	var style := mind.foe_style()
	parts.append("peleás de " + style if style != "" else "distancia: no sabe")
	var habit: MoveData = mind.memory.habit()
	parts.append("repetís " + habit.display_name if habit != null else "sin costumbre")
	return " · ".join(parts)
