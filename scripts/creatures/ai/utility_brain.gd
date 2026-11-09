class_name UtilityBrain
extends RefCounted
## Cerebro de utilidad del Pokémon de un entrenador (Fase 3 de docs/IA_AUDITORIA.md). Reemplaza a la lógica del estado
## `attack` cuando la criatura `uses_new_brain()`; la IA clásica sigue intacta para todo lo demás.
##
## Cómo decide: lee la situación (`Situation`, con lo que percibe con retraso: `Perception`), le pone una **utilidad** a
## cada acción posible (atacar con cada ranura, acercarse, alejarse, rodear por un lado o por el otro, mantener la
## distancia, salir de un rincón, juntar PP), le resta lo que **repitió hace poco** y elige con **softmax** (temperatura del
## `AIProfile`: cuanto más baja, más se queda con la mejor; nunca es siempre la misma). Vuelve a pensar cada un rato con
## **ritmo variable** (lognormal, con ráfagas y respiros) o enseguida si pasa algo (le pegan, te ve expuesto, cambia la
## situación). Reacciona a lo que ve venir con un paso al costado o un esquive (sin otro tiempo de reacción que el retraso de
## la percepción). Ejecuta con el cuerpo de siempre (`CombatBody`: rodear obstáculos, paso al costado) y apunta adonde
## **cree** que vas a estar (no adonde estás).
##
## Sin trampas: nada de tus recargas, tus PP ni tus teclas (lo que sabe de eso viene de `Perception`).

enum Act { ATTACK, APPROACH, RETREAT, STRAFE_L, STRAFE_R, HOLD, REPOSITION, WAIT }
const ACT_NAMES := ["atacar", "acercarse", "alejarse", "rodear izq.", "rodear der.", "mantener", "salir del rincón", "juntar PP"]

## Distancias (px): un cuerpo a cuerpo espera a MELEE_SPACING; más cerca que CONTACT no empuja.
const MELEE_RANGE := 45.0
const MELEE_SPACING := 52.0
const CONTACT := 18.0
## Esquive: rueda recién cuando falta esto para que pegue (como CombatBody).
const DODGE_WINDOW := CombatBody.DODGE_WINDOW
## Bajo fuego: golpes recibidos viniendo de frente en esta ventana (s) y cuánto se cuida después.
const FRONT_HITS := 2
const FRONT_WINDOW := 3.0
const WARY_TIME := Vector2(2.0, 4.0)
## Mínimo entre dos decisiones (aunque algo la apure) y máximo.
const THINK_MIN := 0.12
const THINK_MAX := 1.5
## Juntar PP: espera a lo sumo esto por un ataque mejor.
const SAVE_MAX_WAIT := 2.5
## Cuerpo a cuerpo: después de pegar sale para atrás un rato (al azar en este rango).
const BACKOFF := Vector2(0.35, 0.7)

var actor: Creature
var situation: Situation
## La última evaluación: [{"act", "slot", "name", "u", "p"}], ordenada de mayor a menor utilidad.
var options: Array[Dictionary] = []
var chosen := {}
## Cuántas decisiones tomó (lo leen el test y el overlay).
var decisions := 0
var _move_act: int = Act.HOLD
var _strafe_side := 1.0
var _next_think := 0.0
var _history: Array[Array] = []  # [clave, tiempo]
var _last_attack := -100.0
var _backoff_until := -1.0
var _tell_slot := -1
var _tell_left := 0.0
var _seen_threats := {}  # clave de la amenaza -> si va a reaccionar
var _front_hits: Array[float] = []
var _wary_until := -1.0
var _tempo := 1.0
var _tempo_until := -1.0
var _last_primary := -1
var _was_exposed := false
var _hit_flag := false
var _saving := false
## Fase 4 (modelo del jugador): a quién mira, el ataque suyo cuya respuesta está esperando ver, y el corrimiento de la
## puntería hacia donde cree que vas a esquivar (lo usa también `creature_cast` al soltar una carga).
var _watched: Creature
var _watched_inst: CreatureInstance
var _pending := {}
var aim_bias := Vector2.ZERO
## Lo último que predijo de vos (para el overlay).
var last_prediction := {}
## Cuánto esperar para ver cómo respondiste a un ataque suyo.
const RESPONSE_WINDOW := 0.7
## Corrimiento al lado al que vas a esquivar (px): rodando o con un paso.
const READ_DODGE_PX := 55.0
const READ_STEP_PX := 26.0
## Batería de balance (`--no-reads`): el cerebro nuevo sin usar el modelo del jugador, para comparar.
static var reads_off := false


func _init(p_actor: Creature) -> void:
	actor = p_actor
	actor.damage_received.connect(_on_damaged)


func profile() -> AIProfile:
	return AIProfile.of(actor)


static func difficulty() -> AiDifficulty:
	return CombatBody.difficulty()


## Entró al estado de pelea.
func on_enter() -> void:
	_cancel_tell()
	_next_think = actor.now() + randf_range(0.15, 0.4)


func on_exit() -> void:
	_cancel_tell()


func _on_damaged(amount: float, hit: HitInfo) -> void:
	if amount <= 0.0 or hit == null or not is_instance_valid(actor.target) or hit.attacker != actor.target:
		return
	_hit_flag = true
	var to: Vector2 = actor.target.global_position - actor.global_position
	if actor.velocity.length() > 5.0 and to.length() > 1.0 and actor.velocity.normalized().dot(to.normalized()) > 0.5:
		var now := actor.now()
		_front_hits.append(now)
		while not _front_hits.is_empty() and now - _front_hits[0] >= FRONT_WINDOW:
			_front_hits.pop_front()
		if _front_hits.size() >= FRONT_HITS:
			_front_hits.clear()
			_wary_until = now + randf_range(WARY_TIME.x, WARY_TIME.y)
			AiTrace.note(actor, "bajo fuego", {})


func wary() -> bool:
	return actor.now() < _wary_until and not (situation != null and (situation.window or situation.foe_exposed))


## Un cuadro de pelea (lo llama el estado `attack`).
func update(delta: float) -> void:
	var t: Creature = actor.target
	var p := actor.perception
	p.tick()
	var now := actor.now()
	situation = Situation.read(actor, p)
	_watch_foe(t)
	_resolve_pending()
	var dist := situation.dist if situation.foe_seen else actor.global_position.distance_to(t.global_position)
	var foe_pos: Vector2 = p.predicted_pos(0.0) if situation.foe_seen else t.global_position
	var dir := (foe_pos - actor.global_position).normalized()
	actor.facing = dir
	# Avisando un ataque fuerte: quieto, mirándote; al terminar lo suelta (o amaga).
	if _tell_slot >= 0:
		if not actor.can_act():
			_cancel_tell()
		else:
			_tell_left -= delta
			if _tell_left <= 0.0:
				var slot := _tell_slot
				_cancel_tell()
				if randf() < difficulty().feint_chance + _feint_bonus():
					AiTrace.note(actor, "finta", {"ataque": _move_name(slot)})
					_next_think = now + 0.2
				else:
					_fire(slot)
			return
	if _react():
		return
	var step: Vector2 = actor.body.sidestep_dir()
	if step != Vector2.ZERO:
		actor.move(actor.body.steer(step), actor.speed() * CombatBody.SIDESTEP_SPEED)
		return
	var escape := _hazard_escape()
	if escape != Vector2.ZERO:
		actor.move(escape, actor.speed())
		return
	if actor.spook_left > 0.0:
		actor.move(actor.body.steer(-dir), actor.speed() * 0.9)
		return
	if _should_think(now):
		_decide(now, dist)
	_execute_move(dist, dir, foe_pos)


func _should_think(now: float) -> bool:
	var urgent := false
	if situation.primary != _last_primary:
		_last_primary = situation.primary
		urgent = true
	if situation.foe_exposed and not _was_exposed:
		urgent = true
	_was_exposed = situation.foe_exposed
	if _hit_flag:
		_hit_flag = false
		urgent = true
	if urgent:
		_next_think = minf(_next_think, now + THINK_MIN)
	return now >= _next_think


# --- Decidir ---

func _decide(now: float, dist: float) -> void:
	options = evaluate(dist)
	_next_think = now + _think_interval(now)
	if options.is_empty():
		return
	var pick := softmax_pick(options, temperature())
	chosen = pick
	decisions += 1
	_remember(pick.name, now)
	if pick.act == Act.ATTACK:
		_saving = false
		_start_attack(int(pick.slot))
		_set_move(_pick_move(int(_move_act)))  # y se sigue moviendo (con lo que predice de vos)
	elif pick.act == Act.WAIT:
		if not _saving:
			actor.emote("...", 0.8)
		_saving = true
		_set_move(Act.RETREAT if dist < maxf(_ideal_range(), 90.0) else (Act.STRAFE_L if _strafe_side < 0.0 else Act.STRAFE_R))
	else:
		_saving = false
		_set_move(_pick_move(int(pick.act)))
	if AiTrace.enabled():
		AiTrace.note(actor, "decide", {"elige": pick.name, "p": snappedf(float(pick.p), 0.01), "situacion": situation.to_dict().tactica,
			"top": options.slice(0, 3).map(func(o): return "%s %.2f (%d%%)" % [o.name, o.u, roundi(float(o.p) * 100.0)])})


## Elige con qué moverse entre las opciones de movimiento, ahora sí con lo que predice de vos (`read_bonus`). Sin
## opciones, `fallback`.
func _pick_move(fallback: int) -> int:
	var moves: Array = []
	for o in options:
		if int(o.act) != Act.ATTACK and int(o.act) != Act.WAIT:
			moves.append({"act": o.act, "name": o.name, "u": float(o.u) + float(o.get("read_bonus", 0.0))})
	if moves.is_empty():
		return fallback
	return int(softmax_pick(moves, temperature()).act)


func _set_move(act: int) -> void:
	_move_act = act
	if act == Act.STRAFE_L:
		_strafe_side = -1.0
	elif act == Act.STRAFE_R:
		_strafe_side = 1.0


func temperature() -> float:
	var st: TrainerStyle = actor.trainer_style
	var smarts := clampf(st.smarts_mult, 0.5, 2.0) if st != null else 1.0
	return maxf(0.02, profile().temperature / smarts)


## Cada cuánto vuelve a pensar: lognormal alrededor de `think_mean`, por el ritmo de su clase y por la fase de ráfaga o
## respiro en la que esté.
func _think_interval(now: float) -> float:
	var prof := profile()
	if now >= _tempo_until:
		_tempo_until = now + randf_range(1.5, 3.5)
		_tempo = 1.0 + randf_range(-1.0, 1.0) * prof.tempo_swing
	var pace: float = actor.trainer_style.pace if actor.trainer_style != null else 1.0
	if now < actor.mind.pace_boost_until:
		pace *= actor.mind.pace_boost
	var z := randfn(0.0, prof.think_sigma)
	return clampf(prof.think_mean * pace * _tempo * exp(z), THINK_MIN, THINK_MAX)


## Elige una opción con softmax sobre la utilidad (`u`) y anota en cada una su probabilidad (`p`).
static func softmax_pick(opts: Array, temp: float) -> Dictionary:
	if opts.is_empty():
		return {}
	var top := -INF
	for o in opts:
		top = maxf(top, float(o.u))
	var total := 0.0
	for o in opts:
		o["p"] = exp((float(o.u) - top) / maxf(temp, 0.001))
		total += o.p
	var roll := randf() * total
	var pick: Dictionary = opts[-1]
	for o in opts:
		o["p"] = float(o.p) / total
	for o in opts:
		roll -= float(o.p) * total
		if roll <= 0.0:
			pick = o
			break
	return pick


## Cuánto hizo esto hace poco (0..1): la parte de lo último que eligió que fue esto, con decaimiento.
func recent_share(key: String, now: float) -> float:
	var hl := maxf(0.1, profile().repeat_half_life)
	var mine := 0.0
	var all := 0.0
	for h in _history:
		var w := pow(0.5, (now - float(h[1])) / hl)
		all += w
		if h[0] == key:
			mine += w
	return mine / all if all > 0.0 else 0.0


func _remember(key: String, now: float) -> void:
	_history.append([key, now])
	var hl := maxf(0.1, profile().repeat_half_life)
	while not _history.is_empty() and now - float(_history[0][1]) > hl * 4.0:
		_history.pop_front()


## Las opciones con su utilidad (ya descontado lo que repitió hace poco), de mayor a menor, con su probabilidad (`p`).
func evaluate(dist: float) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var s := situation
	var now := actor.now()
	var prof := profile()
	var st: TrainerStyle = actor.trainer_style
	var ideal := _ideal_range()
	var melee := ideal <= MELEE_RANGE
	var shot: bool = actor.body.clear_shot(actor.target)
	var plan: String = actor.mind.low_hp_plan()
	var all_in := plan == "todo"
	var careful := plan == "cuidado"
	var ref := _ref_value()
	var ready_k := clampf((now - _last_attack) / maxf(0.05, prof.attack_gap * _tempo), 0.0, 1.0)
	var best_attack := 0.0
	var melee_ready := false
	# Atacar con cada ranura.
	for slot in MoveUser.SLOT_COUNT:
		var m: MoveData = actor.moves.slots[slot]
		if m == null or not actor.moves.can_use(slot):
			continue
		var v: float = actor.mind.move_value(slot, dist, shot, false, true)
		if v <= 0.0:
			continue
		var damaging := m.power > 0.0 and m.category != MoveData.Category.STATUS
		if damaging and m.kind in TacticalMind.MELEE_KINDS:
			melee_ready = true
		var u := 0.55 * minf(v / ref, 1.6)
		if damaging:
			if s.foe_exposed:
				u *= prof.punish_skill * (1.15 if _startup(m) < 0.3 else 1.0)
			elif m.kind == MoveData.Kind.PROJECTILE and dist > 120.0:
				u *= 0.8  # de lejos le da menos
			if s.can_finish and TacticalMind.hit_share(m, actor.instance, actor.target.instance) >= float(actor.perception.foe().get("hp", 1.0)) * Situation.FINISH_MARGIN:
				u += 0.4 - actor.moves.pp_cost(slot) / 2000.0  # rematar, mejor con el barato
			# Riesgo: lo que tarda en salir y en recuperarse, si el rival tiene con qué castigarlo.
			var risk := m.cast_time + m.recovery
			u -= risk * (0.12 if s.window or dist > 160.0 else 0.35)
		if s.has(Situation.Tactic.INCOMING):
			u *= 0.5
		var cost: float = actor.moves.pp_cost(slot)
		if cost > 0.0 and not all_in and actor.moves.pp() - cost < actor.moves.max_pp() * TacticalMind.PP_RESERVE:
			u *= 0.6
		if all_in:
			u *= 1.25
		if st != null and st.counter:
			u *= 1.3 if s.foe_exposed or s.window else 0.8
		u *= ready_k
		best_attack = maxf(best_attack, u)
		out.append({"act": Act.ATTACK, "slot": slot, "name": "atk:" + m.display_name, "u": u})
	# Juntar PP: si lo de ahora rinde poco y algo bastante mejor está por llegar.
	var later := 0.0
	for slot in MoveUser.SLOT_COUNT:
		var m: MoveData = actor.moves.slots[slot]
		if m == null or m.power <= 0.0 or m.category == MoveData.Category.STATUS or actor.moves.can_use(slot):
			continue
		var wait: float = actor.moves.seconds_until_ready(slot)
		if wait > SAVE_MAX_WAIT or not actor.moves.can_use(slot, true):
			continue
		var v: float = actor.mind.move_value(slot, minf(dist, m.reach() * 0.9), shot, true, true)
		later = maxf(later, 0.55 * minf(v / ref, 1.6) * (1.0 - wait / (SAVE_MAX_WAIT * 2.0)))
	var patience: float = st.patience if st != null else 0.5
	if later > 0.0 and not all_in and not s.foe_exposed:
		out.append({"act": Act.WAIT, "slot": -1, "name": ACT_NAMES[Act.WAIT], "u": clampf((later - best_attack) * patience * 1.5, 0.0, 0.8)})
	# Moverse.
	var far_k := clampf((dist - ideal) / maxf(ideal, 30.0), 0.0, 1.0)
	var near_k := clampf((ideal * 0.8 - dist) / maxf(ideal, 30.0), 0.0, 1.0)
	var backing := now < _backoff_until
	var approach := 0.25 + 0.55 * far_k
	if melee and melee_ready and ready_k > 0.7 and not s.my_reach_now:
		approach += 0.4  # entra a pegar
	if (s.window or s.foe_exposed) and not s.my_reach_now:
		approach += 0.35
	if s.my_reach_now and best_attack > 0.0:
		approach *= 0.4  # ya llega: pegar, no acercarse más
	if not shot and dist > 40.0:
		approach += 0.4  # una pared en el medio: rodearla
	if wary():
		approach *= 0.3
	if s.has(Situation.Tactic.INCOMING):
		approach *= 0.4
	if careful:
		approach *= 0.5
	if backing:
		approach *= 0.1
	if dist <= CONTACT:
		approach = 0.0
	out.append({"act": Act.APPROACH, "slot": -1, "name": ACT_NAMES[Act.APPROACH], "u": approach})
	var retreat := 0.08 + (0.6 * near_k if not melee else 0.0) + (0.6 if backing else 0.0) + (0.3 if careful else 0.0)
	if melee and dist < MELEE_SPACING * 0.75 and not melee_ready:
		retreat += 0.3
	if s.cornered:
		retreat *= 0.2
	out.append({"act": Act.RETREAT, "slot": -1, "name": ACT_NAMES[Act.RETREAT], "u": retreat})
	var strafe := 0.25 + (0.25 if absf(dist - ideal) < ideal * 0.35 else 0.0) + (0.35 if wary() else 0.0) \
		+ (0.2 if s.has(Situation.Tactic.INCOMING) else 0.0)
	for side in [-1.0, 1.0]:
		var dir_side: Vector2 = (actor.perception.predicted_pos() - actor.global_position).normalized().orthogonal() * side
		var blocked: bool = actor.test_move(actor.global_transform, dir_side * 20.0)
		var act: int = Act.STRAFE_L if side < 0.0 else Act.STRAFE_R
		out.append({"act": act, "slot": -1, "name": ACT_NAMES[act], "u": 0.0 if blocked else strafe})
	var hold := (0.35 if melee and absf(dist - MELEE_SPACING) < 25.0 and not melee_ready else 0.12)
	out.append({"act": Act.HOLD, "slot": -1, "name": ACT_NAMES[Act.HOLD], "u": hold})
	if s.cornered:
		out.append({"act": Act.REPOSITION, "slot": -1, "name": ACT_NAMES[Act.REPOSITION], "u": 0.7})
	_apply_reads(out, dist, melee)
	# Penalidad por repetir y orden.
	for o in out:
		o.u = float(o.u) * (1.0 - prof.repeat_penalty * recent_share(o.name, now))
	out = out.filter(func(o): return float(o.u) > 0.0)
	out.sort_custom(func(a, b): return float(a.u) > float(b.u))
	# (las probabilidades, para el overlay y el registro)
	if not out.is_empty():
		var top := float(out[0].u)
		var total := 0.0
		for o in out:
			total += exp((float(o.u) - top) / temperature())
		for o in out:
			o["p"] = exp((float(o.u) - top) / temperature()) / total
	return out


## Valor de referencia para normalizar: lo que vale su mejor ataque con daño contra este rival.
func _ref_value() -> float:
	var best := 1.0
	var t: Creature = actor.target
	for m in actor.moves.moves:
		if m.power > 0.0 and m.category != MoveData.Category.STATUS:
			var stab := Damage.STAB if m.element in actor.instance.types() else 1.0
			best = maxf(best, m.power * m.power_mult * TacticalMind.hits_of(m) * stab * TacticalMind.effectiveness(m.element, t)
				* actor.mind.stat_edge(m, t))
	return best


## Lo que tarda en salir un ataque (carga + aviso si es fuerte).
func _startup(m: MoveData) -> float:
	return m.cast_time + (difficulty().telegraph if TacticalMind.needs_tell(m) else 0.0)


func _ideal_range() -> float:
	var r := 28.0
	if actor.instance.boss and actor.instance.species.boss_kit != null:
		return actor.instance.species.boss_kit.preferred_range
	for m in actor.moves.moves:
		if m.kind == MoveData.Kind.PROJECTILE:
			r = maxf(r, m.reach() * 0.55)
	if r > MELEE_RANGE:
		if situation != null and situation.matchup < 0.8:
			r *= 1.2  # el cruce en contra: más lejos
		if actor.mind.foe_style() == "cerca":
			r *= 1.2
		if actor.mind.low_hp_plan() == "cuidado":
			r *= 1.3
	return r


# --- Ejecutar ---

func _start_attack(slot: int) -> void:
	var m: MoveData = actor.moves.slots[slot]
	var tell: float = difficulty().telegraph
	if TacticalMind.needs_tell(m) and tell > 0.0:
		_tell_slot = slot
		_tell_left = tell
		actor.sprite.tell_left = tell
		_open_pending("aviso")
		return
	_fire(slot)


## Tira el ataque apuntando adonde cree que vas a estar cuando llegue (con el error de puntería de la dificultad).
func _fire(slot: int) -> bool:
	var m: MoveData = actor.moves.slots[slot]
	if m == null:
		return false
	var p := actor.perception
	var here: Vector2 = p.predicted_pos(0.0)
	var flight := 0.0
	match m.kind:
		MoveData.Kind.PROJECTILE:
			if m.speed > 0.0 and m.beam_length <= 0.0:
				flight = actor.global_position.distance_to(here) / (m.speed * Projectile.SPEED_MULT)
		MoveData.Kind.ZONE:
			flight = m.strike_delay if m.zone_strike else 0.2
		MoveData.Kind.LUNGE, MoveData.Kind.DASH, MoveData.Kind.MELEE:
			flight = 0.1
	_open_pending(attack_context(m))
	aim_bias = _read_bias(m, here)
	var aim_at: Vector2 = p.predicted_pos(m.cast_time + flight) + aim_bias
	var err := deg_to_rad(difficulty().aim_error_deg)
	var off := aim_at - actor.global_position
	var dir := off.normalized().rotated(randf_range(-err, err))
	var point := actor.global_position + off.rotated(randf_range(-err, err)) * randf_range(1.0 - err, 1.0 + err)
	var ok: bool = actor.use_slot(slot, dir, point)
	if ok:
		_last_attack = actor.now()
		if m.kind in TacticalMind.MELEE_KINDS:
			_backoff_until = actor.now() + randf_range(BACKOFF.x, BACKOFF.y)
		AiTrace.note(actor, "ataque", {"ataque": m.display_name, "por": "cerebro nuevo"})
	return ok


func _execute_move(dist: float, dir: Vector2, foe_pos: Vector2) -> void:
	var move := Vector2.ZERO
	var speed_k := 0.8
	var ortho := dir.orthogonal()
	match _move_act:
		Act.APPROACH:
			speed_k = 0.95
			if dist > CONTACT:
				move = (dir + ortho * _strafe_side * 0.9).normalized() if wary() else dir
		Act.RETREAT:
			move = -dir
			speed_k = 0.85
		Act.STRAFE_L, Act.STRAFE_R:
			move = ortho * _strafe_side * 0.85 + dir * clampf((dist - _ideal_range()) / 60.0, -0.4, 0.4)
		Act.HOLD:
			move = ortho * _strafe_side * 0.5 + dir * clampf((dist - MELEE_SPACING) / 20.0, -0.6, 0.6)
			speed_k = 0.4
		Act.REPOSITION:
			move = _open_dir(dir)
			speed_k = 0.95
	if move == Vector2.ZERO:
		actor.move(Vector2.ZERO, 0.0)
		return
	var steered: Vector2 = actor.body.steer(move.normalized(), foe_pos if _move_act == Act.APPROACH else Vector2.INF)
	if _move_act in [Act.STRAFE_L, Act.STRAFE_R, Act.HOLD] and steered.dot(move.normalized()) < 0.5:
		_strafe_side = -_strafe_side  # contra una pared: para el otro lado
	if _danger(actor.global_position + steered * 14.0) and not _danger(actor.global_position):
		steered = Vector2.ZERO
	actor.move(steered, actor.speed() * speed_k)


## Celda peligrosa **que se ve** (ya electrificada, en llamas...). La IA de hoy además supone lo que le harías con tus
## ataques (TacticalMind.danger_at mira tus 4): acá no, porque eso no se ve.
func _danger(pos: Vector2) -> bool:
	var rs: ReactionSystem = actor.mind._reactions()
	if rs == null:
		return false
	var st := rs.state_at(pos)
	return st != null and st.creature_status != null


func _hazard_escape() -> Vector2:
	if not _danger(actor.global_position):
		return Vector2.ZERO
	var start := actor.get_instance_id() % 8
	for k in 8:
		var d := Vector2.RIGHT.rotated((start + k) * TAU / 8.0)
		if not _danger(actor.global_position + d * 18.0) and not actor.test_move(actor.global_transform, d * 18.0):
			return d
	return Vector2.ZERO


## Para los tests y el overlay: lee la situación y evalúa las opciones sin hacer nada.
func evaluate_now() -> Array[Dictionary]:
	actor.perception.tick()
	situation = Situation.read(actor, actor.perception)
	options = evaluate(situation.dist if situation.foe_seen else actor.global_position.distance_to(actor.target.global_position))
	return options


## La dirección más despejada (para salir de un rincón), sin ir derecho hacia el rival.
func _open_dir(to_foe: Vector2) -> Vector2:
	var best := Vector2.ZERO
	var best_free := -1.0
	for k in 8:
		var d := Vector2.RIGHT.rotated(k * TAU / 8.0)
		if d.dot(to_foe) > 0.7:
			continue
		var free := 0.0
		for step in [16.0, 32.0, 48.0]:
			if actor.test_move(actor.global_transform, d * step):
				break
			free = step
		if free > best_free:
			best_free = free
			best = d
	return best


# --- Reaccionar ---

## Lo que ve venir (con el retraso de la percepción): decide una vez por amenaza si reacciona (`evade_skill`, más si es
## fuerte) y cómo: paso al costado con tiempo, rodar si es fuerte y viene justo o no se alcanza caminando.
func _react() -> bool:
	var th: Dictionary = actor.perception.threat()
	for k in _seen_threats.keys():
		if (typeof(k) == TYPE_OBJECT and not is_instance_valid(k)) or (k is String and (th.is_empty() or str(th.get("key")) != k)):
			_seen_threats.erase(k)
	if th.is_empty():
		return false
	var key = th.key if typeof(th.key) == TYPE_OBJECT else str(th.key)
	if not _seen_threats.has(key):
		var chance := profile().evade_skill + (0.15 if th.strong else 0.0)
		_seen_threats[key] = randf() < chance
		if AiTrace.enabled():
			AiTrace.note(actor, "ve", {"amenaza": th.kind, "eta": snappedf(float(th.eta), 0.01), "reacciona": _seen_threats[key]})
	if not _seen_threats[key]:
		return false
	var eta := float(th.eta)
	var step_time: float = clampf(float(th.clear), CombatBody.SIDESTEP_MIN, CombatBody.SIDESTEP_MAX) / maxf(1.0, actor.speed() * CombatBody.SIDESTEP_SPEED)
	var can_walk := eta > step_time * 1.3
	var roll: bool = actor.moves.can_dodge() and (not can_walk or (th.strong and eta < step_time * CombatBody.STRONG_STEP_MARGIN))
	if can_walk and not roll:
		_seen_threats[key] = false
		if actor.body.sidestep(th.out, float(th.clear)):
			AiTrace.note(actor, "paso", {"amenaza": th.kind, "eta": snappedf(eta, 0.01)})
			return true
		return false
	if roll:
		if eta > DODGE_WINDOW:
			return false  # todavía no: rueda cuando está por pegar
		_seen_threats[key] = false
		if actor.dodge(th.out):
			AiTrace.note(actor, "esquive", {"amenaza": th.kind, "eta": snappedf(eta, 0.01)})
			return true
	_seen_threats[key] = false
	return actor.body.sidestep(th.out, float(th.clear))


func _cancel_tell() -> void:
	_tell_slot = -1
	_tell_left = 0.0
	if actor != null and actor.sprite != null:
		actor.sprite.tell_left = 0.0


func _move_name(slot: int) -> String:
	var m: MoveData = actor.moves.slots[slot] if slot >= 0 and slot < actor.moves.slots.size() else null
	return m.display_name if m != null else "?"


# --- Modelo del jugador (Fase 4) ---

func model() -> PlayerModel:
	return actor.mind.memory.model


## Cuánto usa lo que predice: el `read_skill` del perfil por lo que lee su clase.
func reads() -> float:
	var st: TrainerStyle = actor.trainer_style
	return clampf(profile().read_skill * (st.reads if st != null else 0.6), 0.0, 1.0)


func _hl() -> float:
	return profile().memory_half_life


func _k() -> float:
	return profile().adapt_k


## Clase de un ataque suyo para saber cómo le respondés.
static func attack_context(m: MoveData) -> String:
	if TacticalMind.needs_tell(m):
		return "aviso"
	if m.cast_time > 0.0:
		return "carga"
	match m.kind:
		MoveData.Kind.PROJECTILE, MoveData.Kind.WHIP, MoveData.Kind.CHANNEL:
			return "disparo"
		MoveData.Kind.ZONE:
			return "zona"
		MoveData.Kind.AREA:
			return "area"
	return "cuerpo"


## Empieza a mirar a tu Pokémon (y anota si lo cambiaste).
func _watch_foe(t: Creature) -> void:
	if t == _watched:
		if is_instance_valid(t) and t.instance != _watched_inst:
			_watched_inst = t.instance
			_on_foe_switched()
		return
	if is_instance_valid(_watched):
		if _watched.move_released.is_connected(_on_foe_move):
			_watched.move_released.disconnect(_on_foe_move)
		if _watched.dodged.is_connected(_on_foe_dodged):
			_watched.dodged.disconnect(_on_foe_dodged)
	var was := _watched_inst
	_watched = t
	_watched_inst = t.instance if is_instance_valid(t) else null
	if is_instance_valid(t):
		t.move_released.connect(_on_foe_move)
		t.dodged.connect(_on_foe_dodged)
	if was != null and _watched_inst != null and was != _watched_inst:
		_on_foe_switched()


func _on_foe_switched() -> void:
	var now := PlayerModel.clock()
	model().note_action("cambio", now, _hl())
	model().note_switch(now, _hl())


func _on_foe_move(m: MoveData) -> void:
	if m == null or not is_instance_valid(actor):
		return
	var now := PlayerModel.clock()
	model().note_action("atk:" + m.id, now, _hl())
	if situation != null and situation.foe_seen:
		model().note_attack_at(band_of(situation.dist), m.id, now, _hl())
	if not _pending.is_empty():
		_pending["hit_back"] = true


func _on_foe_dodged() -> void:
	if not is_instance_valid(_watched) or not is_instance_valid(actor):
		return
	model().note_action("esq", PlayerModel.clock(), _hl())
	if not _pending.is_empty() and str(_pending.get("dodged", "")) == "":
		var side := PlayerModel.side_of(_watched.last_dodge_dir, _watched.global_position - actor.global_position)
		_pending["dodged"] = "esq_" + (side if side in ["izq", "der"] else "atras")


static func band_of(dist: float) -> String:
	if dist <= Situation.CLOSE:
		return "cerca"
	return "media" if dist <= Situation.FAR_MIN else "lejos"


## Le tiró algo (o lo avisó): mira cómo respondés en los próximos RESPONSE_WINDOW s.
func _open_pending(ctx: String) -> void:
	if not _pending.is_empty() or situation == null or not situation.foe_seen:
		return
	var at: Vector2 = actor.perception.foe().get("pos", actor.target.global_position)
	_pending = {"ctx": ctx, "until": actor.now() + RESPONSE_WINDOW, "from": at, "line": at - actor.global_position, "dodged": ""}


func _resolve_pending() -> void:
	if _pending.is_empty() or actor.now() < float(_pending.until):
		return
	var outcome: String = _pending.dodged
	if outcome == "":
		var now_pos: Vector2 = actor.perception.foe().get("pos", _pending.from)
		var moved: Vector2 = now_pos - _pending.from
		var across := absf(moved.dot((_pending.line as Vector2).normalized().orthogonal()))
		if across > 18.0:
			outcome = "paso_" + PlayerModel.side_of(moved, _pending.line)
			if not outcome in ["paso_izq", "paso_der"]:
				outcome = "nada"
		elif _pending.get("hit_back", false):
			outcome = "pega"
		else:
			outcome = "nada"
	model().note_response(_pending.ctx, outcome, PlayerModel.clock(), _hl())
	AiTrace.note(actor, "aprende", {"a": _pending.ctx, "respondiste": outcome})
	_pending = {}


## Corrimiento de la puntería hacia el lado al que cree que vas a esquivar este ataque (ZERO si no te tiene leído o esta
## vez no se la juega). Solo conviene si ir a ese lado es **más probable que todo lo demás** (quedarte, ir al otro lado):
## la probabilidad de jugársela es esa ventaja × lo seguro que está × cuánto lee. Contra alguien que esquiva para cualquier
## lado no corre la puntería (antes sí, y erraba más: duelo de la batería 2026-11-09).
func _read_bias(m: MoveData, foe_at: Vector2) -> Vector2:
	if m.kind in [MoveData.Kind.AREA, MoveData.Kind.SHIELD, MoveData.Kind.SELF_BUFF]:
		return Vector2.ZERO
	var ctx := attack_context(m)
	var pr := model().predict_response(ctx, PlayerModel.clock(), _hl(), _k())
	if pr.is_empty():
		return Vector2.ZERO
	var side_p := {"izq": 0.0, "der": 0.0}
	var dodge_p := {"izq": 0.0, "der": 0.0}
	for o in pr.dist:
		var key := str(o)
		for s in ["izq", "der"]:
			if key.ends_with(s) and (key.begins_with("esq_") or key.begins_with("paso_")):
				side_p[s] += float(pr.dist[o])
				if key.begins_with("esq_"):
					dodge_p[s] += float(pr.dist[o])
	var side := "der" if side_p.der >= side_p.izq else "izq"
	var other := "izq" if side == "der" else "der"
	var stay: float = 1.0 - side_p.der - side_p.izq
	var edge: float = float(side_p[side]) - maxf(stay, float(side_p[other]))
	if reads_off or edge <= 0.0 or randf() >= edge * float(pr.conf) * reads():
		return Vector2.ZERO
	var best := ("esq_" if float(dodge_p[side]) * 2.0 >= float(side_p[side]) else "paso_") + side
	var best_p: float = side_p[side]
	var line := foe_at - actor.global_position
	var px := READ_DODGE_PX if best.begins_with("esq") else READ_STEP_PX
	AiTrace.note(actor, "lee", {"a": ctx, "esperas": best, "p": snappedf(best_p, 0.01), "conf": snappedf(float(pr.conf), 0.01)})
	return PlayerModel.side_dir(best, line) * px


## Más fintas si suele esquivar al ver el aviso (esquiva al vacío y queda a tiro).
func _feint_bonus() -> float:
	if reads_off:
		return 0.0
	var ev := model().evade_share("aviso", PlayerModel.clock(), _hl(), _k())
	return 0.35 * float(ev[0]) * float(ev[1]) * reads()


## Lo que predice de vos cambia **cómo se mueve** (no cuánto ataca): si viene un ataque tuyo conocido, se corre antes;
## si sabe a qué distancia te gusta pelear, no se queda ahí. Va en `read_bonus` de cada opción de movimiento, que solo
## cuenta al elegir con qué moverse (`_pick_move`). Antes sumaba directo a la utilidad y competía con los ataques: atacaba
## menos y perdía la carrera de daño (duelo de la batería 2026-11-09: 161 a 217).
func _apply_reads(out: Array[Dictionary], dist: float, melee: bool) -> void:
	var now := PlayerModel.clock()
	var r := 0.0 if reads_off else reads()
	var pred := model().predict_next(now, _hl(), _k())
	last_prediction = pred
	if not pred.is_empty() and str(pred.outcome).begins_with("atk:"):
		var m: MoveData = DB.moves.get(str(pred.outcome).trim_prefix("atk:"))
		var x := float(pred.p) * float(pred.conf) * r
		if m != null and x > 0.2 and m.power > 0.0:
			for o in out:
				match int(o.act):
					Act.RETREAT:
						if m.kind in TacticalMind.MELEE_KINDS and dist < m.reach() + 25.0:
							o["read_bonus"] = float(o.get("read_bonus", 0.0)) + 0.35 * x  # viene tu golpe: se sale del alcance
					Act.STRAFE_L, Act.STRAFE_R:
						if float(o.u) > 0.0:
							o["read_bonus"] = float(o.get("read_bonus", 0.0)) + (0.3 if m.kind in TacticalMind.RANGED_KINDS else 0.15) * x
	var fav := model().favorite_band(now, _hl(), _k())
	if not fav.is_empty() and float(fav.p) > 0.55:
		var x := float(fav.p) * float(fav.conf) * r
		var here := band_of(dist)
		if fav.outcome == here:
			for o in out:
				if int(o.act) == Act.RETREAT and here == "cerca" and not melee:
					o["read_bonus"] = float(o.get("read_bonus", 0.0)) + 0.3 * x  # ahí es donde más pegás: no quedarse
				elif int(o.act) == Act.APPROACH and here == "lejos" and melee:
					o["read_bonus"] = float(o.get("read_bonus", 0.0)) + 0.25 * x


## Lo que cree de vos, en una línea (overlay).
func prediction_text() -> String:
	var now := PlayerModel.clock()
	var parts: PackedStringArray = []
	if not last_prediction.is_empty():
		var tok := str(last_prediction.outcome)
		var name := tok
		if tok.begins_with("atk:") and DB.moves.has(tok.trim_prefix("atk:")):
			name = DB.moves[tok.trim_prefix("atk:")].display_name
		parts.append("próximo: %s %d%% (conf %.2f, %s)" % [name, roundi(float(last_prediction.p) * 100.0), float(last_prediction.conf),
			last_prediction.get("from", "")])
	for ctx in ["aviso", "disparo", "carga"]:
		var pr := model().predict_response(ctx, now, _hl(), _k())
		if not pr.is_empty() and float(pr.conf) > 0.3:
			parts.append("al %s: %s %d%%" % [ctx, pr.outcome, roundi(float(pr.p) * 100.0)])
	var cs := model().counter_switch(now, _hl(), _k())
	if float(cs[1]) > 0.3:
		parts.append("contracambiás %d%%" % roundi(float(cs[0]) * 100.0))
	return " · ".join(parts) if not parts.is_empty() else "todavía nada"


## El movimiento que está haciendo ("rodear izq."...).
func move_name() -> String:
	return "juntar PP" if _saving else ACT_NAMES[_move_act]


## En pocas palabras, para el overlay.
func describe() -> String:
	if options.is_empty():
		return "pensando..."
	var top := options.slice(0, 3).map(func(o): return "%s %.2f (%d%%)" % [o.name, o.u, roundi(float(o.p) * 100.0)])
	return "eligió %s · %s · T %.2f%s" % [chosen.get("name", "-"), " · ".join(top), temperature(), " · bajo fuego" if wary() else ""]
