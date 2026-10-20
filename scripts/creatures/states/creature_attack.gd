extends State
## Salvaje peleando: mantiene distancia, rodea, elige ataques según el alcance y esquiva proyectiles.

@export var flee_below := 0.25

var _think := 0.0
var _attack_timer := 0.6
var _strafe := 1.0
var _mode := "strafe"
var _checked: Dictionary = {}


func enter(_msg: Dictionary = {}) -> void:
	_attack_timer = randf_range(0.3, 0.8)


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
		_think = randf_range(0.4, 0.9)
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
		_attack_timer = randf_range(0.6, 1.4)
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
	for m in actor.moves.moves:
		if m.kind == MoveData.Kind.PROJECTILE:
			r = maxf(r, m.reach() * 0.55)
	return r


func _choose_attack(dist: float, dir: Vector2) -> bool:
	var order := range(actor.moves.moves.size())
	order.shuffle()
	for i in order:
		var m: MoveData = actor.moves.moves[i]
		if not actor.moves.can_use(i):
			continue
		var ok := false
		match m.kind:
			MoveData.Kind.PROJECTILE, MoveData.Kind.DASH, MoveData.Kind.AREA:
				ok = dist < m.reach()
			MoveData.Kind.SHIELD:
				ok = actor.health.ratio() < 0.6 and randf() < 0.3
		if ok:
			return actor.use_move(i, dir.rotated(randf_range(-0.12, 0.12)))
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
