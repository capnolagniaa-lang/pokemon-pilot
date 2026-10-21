extends State
## Salvaje peleando: mantiene distancia, rodea, elige ataques según el alcance y esquiva proyectiles.

@export var flee_below := 0.25

var _think := 0.0
var _attack_timer := 0.6
var _strafe := 1.0
var _mode := "strafe"
var _checked: Dictionary = {}


## Dificultad elegida al iniciar (Fácil / Normal / Difícil).
func _diff() -> AiDifficulty:
	return GameState.difficulty if GameState.difficulty != null else AiDifficulty.new()


func enter(_msg: Dictionary = {}) -> void:
	_attack_timer = randf_range(0.3, 0.8) * _diff().attack_interval_mult


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
	if actor.health.ratio() < flee_below and randf() < 0.5 * delta:
		transition("flee")
		return
	actor.facing = dir
	if _try_dodge():
		return

	_think -= delta
	if _think <= 0.0:
		_think = randf_range(0.4, 0.9) * _diff().think_interval_mult
		var ideal := _ideal_range()
		if dist > ideal * 1.3:
			_mode = "approach"
		elif dist < ideal * 0.6:
			_mode = "retreat"
		else:
			_mode = "strafe"
		if randf() < 0.35:
			_strafe = -_strafe

	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_attack_timer = randf_range(0.6, 1.4) * _diff().attack_interval_mult
		if _choose_attack(dist, dir):
			return

	var move := Vector2.ZERO
	match _mode:
		"approach":
			move = dir
		"retreat":
			move = -dir
		_:
			move = dir.orthogonal() * _strafe * 0.8 + dir * 0.15
	actor.move(move.normalized(), actor.speed() * 0.8)
	actor.facing = dir


func _ideal_range() -> float:
	var r := 28.0
	if actor.instance.species.kit != null:
		return actor.instance.species.kit.preferred_range
	for m in actor.moves.moves:
		if m.kind == MoveData.Kind.PROJECTILE:
			r = maxf(r, m.reach() * 0.55)
	return r


## Elige uno de los 4 ataques según el alcance (las recargas ya regulan cuánto usa cada uno).
## Las mejoras propias (Arraigo, Síntesis) las usa cuando está herido.
func _choose_attack(dist: float, dir: Vector2) -> bool:
	var order := range(MoveUser.SLOT_COUNT)
	order.shuffle()
	for slot in order:
		var m: MoveData = actor.moves.slots[slot]
		if m == null or not actor.moves.can_use(slot):
			continue
		var ok := false
		match m.kind:
			MoveData.Kind.SHIELD, MoveData.Kind.SELF_BUFF:
				ok = actor.health.ratio() < 0.6 and randf() < 0.3
			MoveData.Kind.DASH:
				ok = m.dash_hits and dist < m.reach()
			_:
				ok = dist < m.reach()
		if ok:
			var err := deg_to_rad(_diff().aim_error_deg)
			var target_point: Vector2 = Vector2.INF
			if is_instance_valid(actor.target):
				# Mismo error de puntería para las zonas y el Arañazo (apuntan a un punto).
				var off: Vector2 = actor.target.global_position - actor.global_position
				target_point = actor.global_position + off.rotated(randf_range(-err, err)) * randf_range(1.0 - err, 1.0 + err)
			return actor.use_slot(slot, dir.rotated(randf_range(-err, err)), target_point)
	return false


## Esquiva proyectiles enemigos que vienen hacia él (decide una vez por proyectil).
func _try_dodge() -> bool:
	if not actor.moves.can_dodge():
		return false
	for p in actor.get_parent().get_children():
		if not p is Projectile or p.hit == null or p.hit.team == actor.team or _checked.has(p):
			continue
		var rel: Vector2 = actor.global_position - p.global_position
		if rel.length() < 70.0 and p.velocity.dot(rel) > 0.0:
			_checked[p] = true
			if randf() < 0.3:
				var perp: Vector2 = p.velocity.orthogonal().normalized()
				return actor.dodge(perp if randf() < 0.5 else -perp)
	return false
