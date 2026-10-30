extends State
## Peleando (salvajes y Pokémon de entrenador). Mantiene su distancia, rodea, y ataca: abre siempre igual (si está
## lejos, con su ataque de acercamiento: instinto, se lee) y después elige el ataque que mejor le sirve en la situación
## (TacticalMind: potencia, tipos, si estás expuesto; docs/PLAN_IA.md, IA-1). Con el cruce de tipos en contra se cuida
## (más lejos, ataca menos seguido); a favor, presiona. Los ataques fuertes sin carga se avisan (brillo + pausa corta).
## La ejecución (apuntar, esquivar con tiempo de reacción, puntería según la dificultad) la hace CombatBody. Huye con
## poca vida según su temperamento, se espanta con golpes fuertes y sale de las celdas peligrosas.

## Si no tiene temperamento (no debería pasar), huye con menos de esto.
@export var flee_below := 0.25

var _think := 0.0
var _attack_timer := 0.6
var _strafe := 1.0
var _mode := "strafe"
## Ataque avisado que espera soltar (-1 = ninguno) y cuánto le falta al aviso.
var _tell_slot := -1
var _tell_left := 0.0
## Con un estilo de hasta esta distancia es de cuerpo a cuerpo (no retrocede para mantener distancia).
const MELEE_RANGE := 45.0


func enter(_msg: Dictionary = {}) -> void:
	_attack_timer = randf_range(0.3, 0.8) * CombatBody.difficulty().attack_interval_mult
	_cancel_tell()


func exit() -> void:
	_cancel_tell()


func _cancel_tell() -> void:
	_tell_slot = -1
	_tell_left = 0.0
	if actor != null and actor.sprite != null:
		actor.sprite.tell_left = 0.0


func physics_update(delta: float) -> void:
	var t: Creature = actor.target
	if not is_instance_valid(t) or t.is_down():
		transition("wander")
		return
	var to: Vector2 = t.global_position - actor.global_position
	var dist := to.length()
	var dir := to.normalized()
	if dist > 260.0:
		transition("chase")
		return
	var temp: Temperament = actor.temperament
	var flee_at: float = temp.flee_below if temp != null else flee_below
	if actor.health.ratio() < flee_at and randf() < 0.5 * delta:
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
				actor.body.use(slot)
			return
	if actor.body.try_dodge():
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
		if dist > ideal * 1.3 or (dist > 40.0 and not actor.body.clear_shot(t)):
			_mode = "approach"  # lejos, o con una pared/árbol en el medio: se acerca rodeando
		elif dist < ideal * 0.6 and ideal > MELEE_RANGE:
			_mode = "retreat"  # los de distancia se alejan; los de cuerpo a cuerpo no retroceden solos
		else:
			_mode = "strafe"
		if randf() < 0.2:
			_strafe = -_strafe

	_attack_timer -= delta
	if _attack_timer <= 0.0:
		if _choose_attack(dist):
			_attack_timer = randf_range(0.5, 1.1) * CombatBody.difficulty().attack_interval_mult * _pace()
			return
		# Ningún ataque llega desde acá: no se queda esperando, se acomoda y vuelve a probar enseguida.
		_attack_timer = 0.2
		if dist > _ideal_range() * 0.8:
			_mode = "approach"

	var move := Vector2.ZERO
	match _mode:
		"approach":
			move = dir
		"retreat":
			move = -dir
		_:
			move = dir.orthogonal() * _strafe * 0.8 + dir * 0.15
	var steered: Vector2 = actor.body.steer(move.normalized(), t.global_position if _mode == "approach" else Vector2.INF)
	if _mode == "strafe" and steered.dot(move.normalized()) < 0.5:
		_strafe = -_strafe  # rodeando contra una pared: cambia de lado
	actor.move(steered, actor.speed() * (0.95 if _mode == "approach" else 0.8))
	actor.facing = dir


func _ideal_range() -> float:
	var r := 28.0
	if actor.instance.boss and actor.instance.species.boss_kit != null:
		return actor.instance.species.boss_kit.preferred_range
	for m in actor.moves.moves:
		if m.kind == MoveData.Kind.PROJECTILE:
			r = maxf(r, m.reach() * 0.55)
	if r > MELEE_RANGE and actor.mind.matchup() == "cuidate":
		r *= 1.25  # los de distancia, con los tipos en contra, se quedan más lejos
	return r


## Ritmo de ataque según el cruce de tipos: con los tipos en contra ataca menos seguido; a favor, presiona.
func _pace() -> float:
	match actor.mind.matchup():
		"cuidate":
			return 1.2
		"presiona":
			return 0.85
	return 1.0


## La primera vez, si está lejos, abre con su ataque de acercamiento (instinto); después elige con TacticalMind.
## Los fuertes sin carga se avisan antes (`AiDifficulty.telegraph`).
func _choose_attack(dist: float) -> bool:
	if not actor.fight_opened:
		actor.fight_opened = true
		var opener: int = actor.body.gap_closer(dist)
		if opener >= 0 and dist > 40.0 and actor.body.use(opener):
			actor.mind.last_slot = opener
			return true
	var slot: int = actor.mind.pick(dist)
	if slot < 0:
		return false
	actor.mind.last_slot = slot
	var tell := CombatBody.difficulty().telegraph
	if TacticalMind.needs_tell(actor.moves.slots[slot]) and tell > 0.0:
		_tell_slot = slot
		_tell_left = tell
		actor.sprite.tell_left = tell
		return true
	return actor.body.use(slot)
