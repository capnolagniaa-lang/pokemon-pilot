extends State
## Peleando (salvajes y Pokémon de entrenador). Mantiene su distancia, rodea, y ataca: abre siempre igual (si está
## lejos, con su ataque de acercamiento: instinto, se lee) y después elige el ataque que mejor le sirve en la situación
## (TacticalMind: potencia, tipos, si estás expuesto; docs/PLAN_IA.md, IA-1). Con el cruce de tipos en contra se cuida
## (más lejos, ataca menos seguido); a favor, presiona. Los ataques fuertes sin carga se avisan (brillo + pausa corta).
## La ejecución (apuntar, esquivar con tiempo de reacción, puntería según la dificultad) la hace CombatBody. Huye con
## poca vida según su temperamento, se espanta con golpes fuertes y sale de las celdas peligrosas.
## Memoria corta (IA-2, TacticalMind): castiga cuando tenés tus ataques fuertes en recarga, se aleja más si peleás
## de cerca, con poca vida huye / se juega todo / se cubre según el temperamento, y a veces amaga (finta).
## Juntando PP (TacticalMind.saving, H-1): no ataca; si le falta bastante se aleja y da vueltas, sin dejar de esquivar.
## Bajo fuego (S-0, docs/PLAN_SPARRING_IA.md): si se come golpes viniendo de frente, deja de venir de frente un rato
## ("wary"): los de distancia rodean, los de cuerpo a cuerpo esperan más lejos y entran recién con tus fuertes en recarga
## o con vos expuesto, y cuando entran lo hacen en zigzag. Los pasos al costado y esquives los decide CombatBody.

## Si no tiene temperamento (no debería pasar), huye con menos de esto.
@export var flee_below := 0.25

var _think := 0.0
var _attack_timer := 0.6
var _strafe := 1.0
var _mode := "strafe"
## Ataque avisado que espera soltar (-1 = ninguno) y cuánto le falta al aviso.
var _tell_slot := -1
var _tell_left := 0.0
## Cuerpo a cuerpo: después de pegar sale para atrás este rato (entra, pega, sale).
var _backoff := 0.0
## Con un estilo de hasta esta distancia es de cuerpo a cuerpo (no retrocede para mantener distancia).
const MELEE_RANGE := 45.0
## Cuerpo a cuerpo con el ataque en espera (pedido del usuario 2026-10-31: "se quedan dando vueltas arriba de uno"):
## se queda a esta distancia, de frente, amagando de costado despacio, y entra recién cuando va a pegar
## (como un melee de MOBA: entra, pega, sale).
const MELEE_SPACING := 52.0
## Entra a pegar cuando le falta esto para atacar.
const MELEE_ENTER := 0.45
## Más cerca que esto no empuja (no se le sube encima).
const CONTACT := 18.0
## Juntando PP se queda por lo menos a esta distancia.
const SAVE_DISTANCE := 90.0
## Bajo fuego (TacticalMind.wary, S-0): los de cuerpo a cuerpo esperan a WARY_SPACING.
const WARY_SPACING := 95.0
## Para notar cuándo la mente se acaba de poner a cubierto (cambia de lado y deja de venir de frente).
var _seen_wary := 0
## Para el registro (AiTrace): por qué está en el modo actual y el último modo anotado.
var _why := ""
var _logged_mode := ""


func enter(_msg: Dictionary = {}) -> void:
	_attack_timer = randf_range(0.3, 0.8) * CombatBody.difficulty().attack_interval_mult
	_cancel_tell()
	_seen_wary = actor.mind.wary_count


func exit() -> void:
	_cancel_tell()
	if actor.mind != null:
		actor.mind.saving = false


func wary() -> bool:
	if actor.mind.wary_count != _seen_wary:
		_seen_wary = actor.mind.wary_count
		_strafe = -_strafe
		_mode = "strafe"
	return actor.mind.wary()


func _cancel_tell() -> void:
	_tell_slot = -1
	_tell_left = 0.0
	if actor != null and actor.sprite != null:
		actor.sprite.tell_left = 0.0


func physics_update(delta: float) -> void:
	if not is_instance_valid(actor.target):
		transition("wander")  # (su rival ya no existe: lo guardaron o se fue de la zona)
		return
	var t: Creature = actor.target
	if t.is_down():
		transition("wander")
		return
	var to: Vector2 = t.global_position - actor.global_position
	var dist := to.length()
	var dir := to.normalized()
	if actor.is_burrowed():  # bajo tierra: va hasta abajo tuyo y sale
		actor.move(actor.body.steer(dir, t.global_position), actor.speed())
		if dist < actor.burrow.move.zone_radius * 0.6:
			actor.burrow.emerge()
		return
	if dist > 260.0:
		transition("chase")
		return
	actor.mind.observe()
	var temp: Temperament = actor.temperament
	var flee_at: float = temp.flee_below if temp != null else flee_below
	var plan: String = actor.mind.low_hp_plan()
	if plan == "todo" and not actor.mind.all_in:
		actor.mind.all_in = true
		actor.emote("!", 1.0)  # se juega todo
	if plan != "todo" and actor.health.ratio() < flee_at and randf() < 0.5 * delta:
		actor.emote("gota", 1.0)
		transition("flee")
		return
	if temp != null and temp.on_notice == Temperament.OnNotice.TERRITORY and not actor.engaged() \
			and t.global_position.distance_to(actor.home) > temp.territory_radius * 1.8:
		actor.give_up_fight()  # saliste de su territorio sin pelear: te deja ir
		return
	actor.facing = dir
	# Avisando un ataque fuerte: quieto, mirándote; al terminar lo suelta apuntando adonde estás ahora.
	if _tell_slot >= 0:
		if not actor.can_act():
			_cancel_tell()
		else:
			_tell_left -= delta
			if _tell_left <= 0.0:
				var slot := _tell_slot
				_cancel_tell()
				if randf() < CombatBody.difficulty().feint_chance:
					# Finta: amagó y no sale; ataca enseguida (castiga si esquivaste al vacío).
					actor.mind.feints += 1
					_attack_timer = 0.25
					_mode = "approach"
					AiTrace.note(actor, "finta", {"ataque": _move_name(slot)})
				else:
					actor.body.use(slot)
					AiTrace.note(actor, "ataque", {"ataque": _move_name(slot), "por": "tras el aviso"})
			return
	if actor.body.try_dodge():
		return
	var step: Vector2 = actor.body.sidestep_dir()
	if step != Vector2.ZERO:  # paso al costado en curso (S-0)
		actor.move(actor.body.steer(step), actor.speed() * CombatBody.SIDESTEP_SPEED)
		actor.facing = dir
		return
	var escape: Vector2 = actor.body.hazard_escape()
	if escape != Vector2.ZERO:
		actor.move(escape, actor.speed())
		return
	if actor.spook_left > 0.0:
		actor.move(actor.body.steer(-dir), actor.speed() * 0.9)  # espantado: retrocede sin atacar
		actor.facing = dir
		return

	_think -= delta
	if _think <= 0.0:
		_think = randf_range(0.4, 0.9) * CombatBody.difficulty().think_interval_mult
		var ideal := _ideal_range()
		var why := ""
		if actor.mind.window_open() and dist > MELEE_RANGE:
			_mode = "approach"  # tus ataques fuertes están en recarga: se te viene encima
			why = "ventana"
		elif wary() and dist < 200.0 and actor.body.clear_shot(t):
			_mode = "strafe"  # bajo fuego: no viene de frente, rodea
			why = "bajo fuego"
			if randf() < 0.5:
				_strafe = -_strafe
		elif dist > ideal * 1.3 or (dist > 40.0 and not actor.body.clear_shot(t)):
			_mode = "approach"  # lejos, o con una pared/árbol en el medio: se acerca rodeando
			why = "lejos" if dist > ideal * 1.3 else "sin tiro"
		elif dist < ideal * 0.6 and ideal > MELEE_RANGE:
			_mode = "retreat"  # los de distancia se alejan; los de cuerpo a cuerpo no retroceden solos
			why = "muy cerca"
		else:
			_mode = "strafe"
			why = "a su distancia"
		if randf() < 0.2:
			_strafe = -_strafe
		_why = why

	_attack_timer -= delta
	if _attack_timer <= 0.0 and wary() and _ideal_range() <= MELEE_RANGE and dist > MELEE_SPACING:
		_attack_timer = 0.3  # bajo fuego, un cuerpo a cuerpo no se tira de lejos (la embestida es venir de frente): espera
	if _attack_timer <= 0.0 and not t.is_burrowed():  # (no le tira a alguien que está bajo tierra)
		if _choose_attack(dist):
			_attack_timer = randf_range(0.5, 1.1) * CombatBody.difficulty().attack_interval_mult * _pace()
			if _ideal_range() <= MELEE_RANGE and not actor.mind.all_in:
				_backoff = randf_range(0.4, 0.65)
				_attack_timer = maxf(_attack_timer, _backoff + MELEE_ENTER + 0.15)
			return
		# Ningún ataque llega desde acá: no se queda esperando, se acomoda y vuelve a probar enseguida.
		_attack_timer = 0.2
		if dist > _ideal_range() * 0.8:
			_mode = "approach"

	var speed_k := 0.95 if _mode == "approach" else 0.8
	if actor.mind.saving and actor.mind.save_left() >= TacticalMind.SAVE_BACK_OFF:
		_mode = "retreat" if dist < maxf(_ideal_range(), SAVE_DISTANCE) else "strafe"
		_why = "juntando PP"
		speed_k = 0.85
	elif _ideal_range() <= MELEE_RANGE:
		_mode = _melee_mode(dist)
		_why = "cuerpo a cuerpo"
		speed_k = 0.95 if _mode == "approach" else (0.6 if _mode == "retreat" else 0.35)
	if _mode != _logged_mode and AiTrace.enabled():
		_logged_mode = _mode
		AiTrace.note(actor, "modo", {"modo": _mode, "por": _why, "dist": roundi(dist)})
	var move := Vector2.ZERO
	var spacing := WARY_SPACING if wary() else MELEE_SPACING
	match _mode:
		"approach":
			if dist <= CONTACT:
				move = Vector2.ZERO
			elif wary():
				move = (dir + dir.orthogonal() * _strafe * 0.9).normalized()  # bajo fuego entra en zigzag, no en línea
			else:
				move = dir
		"retreat":
			move = -dir
		"hold":
			move = dir.orthogonal() * _strafe * 0.6 + dir * clampf((dist - spacing) / 20.0, -0.6, 0.6)
		_:
			move = dir.orthogonal() * _strafe * 0.8 + dir * 0.15
	var flank: Vector2 = actor.mind.flank_point(_ideal_range())
	if flank != Vector2.INF and actor.global_position.distance_to(flank) > 16.0 and _mode != "retreat":
		move = (flank - actor.global_position).normalized()  # en manada: te rodea (cada uno de un lado)
	if move == Vector2.ZERO:
		actor.move(Vector2.ZERO, 0.0)  # pegado: espera el golpe de frente, sin dar vueltas
		actor.facing = dir
		return
	var steered: Vector2 = actor.body.steer(move.normalized(), t.global_position if _mode == "approach" else Vector2.INF)
	if _mode in ["strafe", "hold"] and steered.dot(move.normalized()) < 0.5:
		_strafe = -_strafe  # rodeando contra una pared: cambia de lado
	if actor.mind.danger_at(actor.global_position + steered * 14.0) and not actor.mind.danger_at(actor.global_position):
		# Adelante hay un lugar peligroso (agua frente a un eléctrico...): rodea para el otro lado, o se queda.
		# (si ya está en uno sin salida cerca, como un nadador en medio del lago, pelea igual)
		_strafe = -_strafe
		steered = actor.body.steer(dir.orthogonal() * _strafe, Vector2.INF)
		if actor.mind.danger_at(actor.global_position + steered * 14.0):
			steered = Vector2.ZERO
	actor.move(steered, actor.speed() * speed_k)
	actor.facing = dir


## Cuerpo a cuerpo: entra cuando va a pegar (o tenés tus fuertes en recarga, o se juega todo); si no, sale a su
## distancia y espera de frente.
func _melee_mode(dist: float) -> String:
	_backoff -= get_physics_process_delta_time()
	if dist > 40.0 and not actor.body.clear_shot(actor.target):
		return "approach"  # una pared o un árbol en el medio: la rodea
	if _backoff > 0.0:
		return "retreat" if dist < MELEE_SPACING else "hold"
	if wary() and dist > MELEE_SPACING:
		# Bajo fuego y todavía lejos: espera a WARY_SPACING, de costado; entra recién con tus fuertes en recarga o con vos
		# expuesto (wary() ya lo mira) y, si entra, en zigzag. Ya pegado pelea normal: irse sería meterse en la línea de tiro.
		return "hold" if dist < WARY_SPACING * 1.5 else "approach"
	if _attack_timer <= MELEE_ENTER or actor.mind.window_open() or actor.mind.all_in:
		return "approach"
	if dist < MELEE_SPACING * 0.75:
		return "retreat"
	if dist > MELEE_SPACING * 1.6:
		return "approach"
	return "hold"


func _ideal_range() -> float:
	var r := 28.0
	if actor.instance.boss and actor.instance.species.boss_kit != null:
		return actor.instance.species.boss_kit.preferred_range
	for m in actor.moves.moves:
		if m.kind == MoveData.Kind.PROJECTILE:
			r = maxf(r, m.reach() * 0.55)
	if r > MELEE_RANGE:
		if actor.mind.matchup() == "cuidate":
			r *= 1.25  # los de distancia, con los tipos en contra, se quedan más lejos
		if actor.mind.foe_style() == "cerca":
			r *= 1.2  # peleás de cerca: te mantiene a raya
		if actor.mind.low_hp_plan() == "cuidado":
			r *= 1.3
	return r


## Ritmo de ataque según el cruce de tipos: con los tipos en contra ataca menos seguido; a favor, presiona.
func _pace() -> float:
	var k := 1.0
	match actor.mind.matchup():
		"cuidate":
			k = 1.2
		"presiona":
			k = 0.85
	if actor.mind.window_open():
		k *= 0.75  # ventana: tus ataques fuertes en recarga
	match actor.mind.low_hp_plan():
		"todo":
			k *= 0.7
		"cuidado":
			k *= 1.25
	return k * actor.mind.trainer_pace()


## La primera vez, si está lejos, abre con su ataque de acercamiento (instinto); después elige con TacticalMind.
## Los fuertes sin carga se avisan antes (`AiDifficulty.telegraph`).
func _choose_attack(dist: float) -> bool:
	if not actor.fight_opened:
		actor.fight_opened = true
		var opener: int = actor.body.gap_closer(dist)
		if opener >= 0 and dist > 40.0 and actor.body.use(opener):
			actor.mind.last_slot = opener
			AiTrace.note(actor, "ataque", {"ataque": _move_name(opener), "por": "apertura", "dist": roundi(dist)})
			return true
	var was_saving: bool = actor.mind.saving
	var slot: int = actor.mind.pick(dist)
	if slot < 0:
		if actor.mind.saving and not was_saving and AiTrace.enabled():
			AiTrace.note(actor, "juntar", {"falta": snappedf(actor.mind.save_left(), 0.1), "top": AiTrace.top3(actor)})
		return false
	actor.mind.last_slot = slot
	var tell: float = CombatBody.difficulty().telegraph
	if TacticalMind.needs_tell(actor.moves.slots[slot]) and tell > 0.0:
		_tell_slot = slot
		_tell_left = tell
		actor.sprite.tell_left = tell
		if AiTrace.enabled():
			AiTrace.note(actor, "aviso", {"ataque": _move_name(slot), "por": actor.mind.last_reason, "dist": roundi(dist), "top": AiTrace.top3(actor)})
		return true
	var used: bool = actor.body.use(slot)
	if used and AiTrace.enabled():
		AiTrace.note(actor, "ataque", {"ataque": _move_name(slot), "por": actor.mind.last_reason, "dist": roundi(dist), "top": AiTrace.top3(actor)})
	return used


## Modo de movimiento actual ("approach", "strafe"...; lo lee el overlay).
func mode() -> String:
	return _mode


func _move_name(slot: int) -> String:
	var m: MoveData = actor.moves.slots[slot] if slot >= 0 and slot < actor.moves.slots.size() else null
	return m.display_name if m != null else "?"
