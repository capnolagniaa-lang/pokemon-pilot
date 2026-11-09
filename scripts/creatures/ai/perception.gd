class_name Perception
extends RefCounted
## Lo que la IA nueva **ve** de su rival (Fase 2 de docs/IA_AUDITORIA.md): solo lo que vería una persona en la pantalla y
## **con retraso**. Cada cuadro guarda una foto de lo visible del rival (dónde está, hacia dónde va, qué está haciendo, su
## barra de vida, si está tambaleando, qué ataque está tirando, la amenaza que viene) y la IA lee la foto de hace
## `AIProfile.delay()` s (± `perception_jitter`, que cambia cada `JITTER_EVERY` s).
##
## **Sin trampas**: nunca mira tus recargas, tu barra de PP ni tus teclas. Lo que no se ve se **estima** con lo que te vio
## hacer y las reglas del juego (cuánto recarga y cuánto cuesta cada ataque, cuánto se recupera la barra): eso es lo que
## sabe cualquiera que juegue. Los ataques que todavía no te vio usar los supone listos.
##
## La usa el cerebro nuevo (Fase 3); hasta entonces la prende el overlay (`AiDebug`) para mostrarla. Una por criatura
## (`Creature.perception`); `tick()` una vez por cuadro de física (si se llama dos veces en el mismo cuadro, no hace nada).

## Segundos de fotos que guarda (más que el retraso más largo + la variación).
const HISTORY := 0.8
## Cada cuánto cambia la variación del retraso.
const JITTER_EVERY := 0.5
## Desde esta potencia un ataque es "fuerte" (el mismo criterio que el aviso de la IA de hoy).
const STRONG_POWER := TacticalMind.TELL_POWER
## Estados en los que el rival quedó expuesto (se ven: carga marcada, chorro, quieto recuperándose, aturdido).
const EXPOSED_STATES := ["cast", "recovery", "channel", "stunned"]
## Estados en los que se ve qué ataque está tirando (la animación y el efecto lo muestran).
const ATTACK_STATES := ["cast", "channel", "step", "lunge", "dash", "ride"]

var actor: Creature
## Fotos: {"t", "pos", "vel", "facing", "state", "hp", "stagger", "can_act", "under", "move", "threat"}.
var _snaps: Array[Dictionary] = []
var _frame := -1
var _jitter := 0.0
var _jitter_at := -100.0
var _foe: Creature
## Usos vistos del rival actual: [{"t", "move"}] (para estimar recargas y PP).
var _uses: Array[Dictionary] = []
## PP estimados del rival (-1 = todavía no lo vio gastar: barra llena) y cuándo se calcularon.
var _pp := -1.0
var _pp_t := 0.0


func _init(p_actor: Creature) -> void:
	actor = p_actor


func profile() -> AIProfile:
	return AIProfile.of(actor)


## Retraso de este momento (el del perfil ± la variación).
func delay() -> float:
	return maxf(0.05, profile().delay() + _jitter)


## Mira la pantalla: guarda la foto de este cuadro. Llamarla una vez por cuadro de física.
func tick() -> void:
	var frame := Engine.get_physics_frames()
	if frame == _frame or not is_instance_valid(actor):
		return
	_frame = frame
	var now := actor.now()
	if now - _jitter_at >= JITTER_EVERY:
		_jitter_at = now
		var j := profile().perception_jitter
		_jitter = randf_range(-j, j)
	var t: Creature = actor.target if is_instance_valid(actor.target) else null
	if t != _foe:
		_watch(t)
	while not _snaps.is_empty() and now - float(_snaps[0].t) > HISTORY:
		_snaps.pop_front()
	if t == null or t.is_down():
		return
	var shown_move: MoveData = t.last_move if t.machine.current_name() in ATTACK_STATES else null
	_snaps.append({
		"t": now, "pos": t.global_position, "vel": t.velocity, "facing": t.facing, "state": t.machine.current_name(),
		"hp": t.health.ratio(), "stagger": t.hitstun_left > 0.0, "can_act": t.statuses.can_act(),
		"under": t.is_burrowed(), "move": shown_move, "threat": actor.mind.threat(),
	})


## Empieza a mirar a otro rival: olvida lo que estimaba del anterior.
func _watch(t: Creature) -> void:
	if is_instance_valid(_foe) and _foe.move_released.is_connected(_on_released):
		_foe.move_released.disconnect(_on_released)
	_foe = t
	_snaps.clear()
	_uses.clear()
	_pp = -1.0
	if t != null:
		t.move_released.connect(_on_released)


## Le vio tirar un ataque (sale el golpe, el disparo o el efecto: se ve).
func _on_released(m: MoveData) -> void:
	if m == null or not is_instance_valid(actor):
		return
	var now := actor.now()
	_uses.append({"t": now, "move": m})
	if _uses.size() > 24:
		_uses.pop_front()
	if MoveUser.pp_on():
		_pp = maxf(0.0, est_pp(now) - MoveUser.pp_cost_of(m))
		_pp_t = now


# --- Lo que ve (con retraso) ---

## La foto del rival de hace `delay()` s ({} si todavía no vio nada: recién empieza la pelea o recién salió).
func foe() -> Dictionary:
	var when := actor.now() - delay()
	var best := {}
	for s in _snaps:
		if float(s.t) <= when:
			best = s
		else:
			break
	return best


## Hace cuánto es la foto que está mirando (s).
func age() -> float:
	var s := foe()
	return actor.now() - float(s.t) if not s.is_empty() else 0.0


## La amenaza que vio venir, con el tiempo que pasó desde la foto descontado ({} si no hay o ya pasó).
func threat() -> Dictionary:
	var s := foe()
	if s.is_empty() or (s.threat as Dictionary).is_empty():
		return {}
	var th: Dictionary = (s.threat as Dictionary).duplicate()
	var key = th.get("key")
	if typeof(key) == TYPE_OBJECT and not is_instance_valid(key):  # (el disparo ya no existe)
		return {}
	th["eta"] = float(th.eta) - (actor.now() - float(s.t))
	return th if th.eta > -0.1 else {}


## Dónde cree que está el rival dentro de `ahead` s: lo que vio, siguiendo en línea recta lo que venía haciendo.
func predicted_pos(ahead: float = 0.0) -> Vector2:
	var s := foe()
	if s.is_empty():
		return actor.target.global_position if is_instance_valid(actor.target) else actor.global_position
	return s.pos + s.vel * (actor.now() - float(s.t) + ahead)


## El rival estaba expuesto en la foto (cargando, canalizando, recuperándose, aturdido, tambaleando o sin poder actuar).
func foe_exposed() -> bool:
	var s := foe()
	return not s.is_empty() and (s.state in EXPOSED_STATES or s.stagger or not s.can_act)


# --- Lo que estima (lo que no se ve) ---

## Recarga de un ataque según las reglas del juego (no según la recarga real del rival).
static func rule_cooldown(m: MoveData) -> float:
	var base := m.cooldown
	if MoveUser.pp_on():
		base = clampf(base * MoveUser.PP_COOLDOWN, MoveUser.PP_COOLDOWN_MIN, MoveUser.PP_COOLDOWN_MAX)
	return base * float(GameState.setting("cooldown_mult"))


## Barra de PP del rival según las reglas: 100 + 4 × nivel (el nivel se ve en su cartel).
func foe_max_pp() -> float:
	if not is_instance_valid(_foe) or _foe.instance == null:
		return MoveUser.PP_BASE
	return MoveUser.PP_BASE + MoveUser.PP_PER_LEVEL * _foe.instance.level


## PP que cree que le quedan al rival en `now` (llena si todavía no lo vio gastar).
func est_pp(now: float = -1.0) -> float:
	if now < 0.0:
		now = actor.now()
	var full := foe_max_pp()
	if _pp < 0.0:
		return full
	var regen := full * MoveUser.PP_REGEN_FIGHT * float(GameState.setting("pp_regen"))
	return minf(full, _pp + regen * maxf(0.0, now - _pp_t))


## Cuánto cree que le falta al rival para poder volver a usar ese ataque (0 = listo o nunca se lo vio usar). Solo
## cuentan los usos que ya alcanzó a ver (con el retraso).
func est_ready_in(m: MoveData) -> float:
	var now := actor.now()
	var seen_until := now - delay()
	var last := -1.0
	for u in _uses:
		if u.move == m and float(u.t) <= seen_until:
			last = float(u.t)
	var left := 0.0
	if last >= 0.0:
		left = maxf(0.0, last + rule_cooldown(m) - now)
	if MoveUser.pp_on():
		var need := MoveUser.pp_cost_of(m) - est_pp(now)
		if need > 0.0:
			left = maxf(left, need / maxf(0.001, foe_max_pp() * MoveUser.PP_REGEN_FIGHT * float(GameState.setting("pp_regen"))))
	return left


## Los ataques fuertes que le vio usar (los que no vio no los conoce).
func seen_strong() -> Array[MoveData]:
	var out: Array[MoveData] = []
	for u in _uses:
		var m: MoveData = u.move
		if not m in out and m.power * m.power_mult >= STRONG_POWER and m.category != MoveData.Category.STATUS:
			out.append(m)
	return out


## Cree que tenés todos tus ataques fuertes (los que te vio) en recarga o sin PP para tirarlos.
func strong_down_est() -> bool:
	var strong := seen_strong()
	if strong.is_empty():
		return false
	for m in strong:
		if est_ready_in(m) <= 0.0:
			return false
	return true


## Ventana para atacar: en la foto te estabas recuperando, o cree que tus fuertes no están listos.
func window_est() -> bool:
	var s := foe()
	return (not s.is_empty() and s.state == "recovery") or strong_down_est()
