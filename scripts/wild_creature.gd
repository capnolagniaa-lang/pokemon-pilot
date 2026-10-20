extends "res://scripts/creature.gd"
## IA de criatura salvaje: se acerca, rodea, se aleja, ataca y esquiva disparos.

var think_timer := 0.0
var attack_timer := 1.2
var mode := "approach"
var strafe_sign := 1.0
var aggression := 1.0


func setup(entry: Dictionary, p_team: int) -> void:
	super.setup(entry, p_team)
	aggression = 0.8 + level * 0.03


func _control(delta: float) -> Vector2:
	var target = arena.player
	if target == null or not is_instance_valid(target) or target.hp <= 0.0:
		return Vector2.ZERO
	var to: Vector2 = target.global_position - global_position
	var dist := to.length()
	var dir_to := to.normalized()
	facing = dir_to

	think_timer -= delta
	if think_timer <= 0.0:
		think_timer = randf_range(0.4, 0.9)
		if dist > 300.0:
			mode = "approach"
		elif dist < 110.0:
			mode = "retreat" if randf() < 0.6 else "strafe"
		else:
			mode = "strafe" if randf() < 0.7 else "approach"
		if randf() < 0.3:
			strafe_sign *= -1.0

	_try_dodge()

	attack_timer -= delta
	if attack_timer <= 0.0:
		attack_timer = randf_range(0.5, 1.3) / aggression
		_choose_attack(dist, dir_to)

	match mode:
		"approach":
			return dir_to
		"retreat":
			return -dir_to
		_:
			return dir_to.orthogonal() * strafe_sign * 0.9 + dir_to * 0.1


func _choose_attack(dist: float, dir_to: Vector2) -> void:
	var order := range(moves.size())
	order.shuffle()
	for i in order:
		if not can_use(i):
			continue
		var m: Dictionary = Game.MOVES[moves[i]]
		var ok := false
		match m["kind"]:
			"projectile":
				ok = dist < 520.0
			"dash":
				ok = dist < 230.0
			"area":
				ok = dist < m["radius"] * 0.9
			"shield":
				ok = hp < max_hp * 0.5 and randf() < 0.3
		if ok:
			use_move(i, dir_to.rotated(randf_range(-0.15, 0.15)))
			return


func _try_dodge() -> void:
	if dodge_cooldown > 0.0:
		return
	for p in get_tree().get_nodes_in_group("projectiles"):
		if p.team == team or p.has_meta("ai_checked_%d" % get_instance_id()):
			continue
		var rel: Vector2 = global_position - p.global_position
		if rel.length() < 140.0 and p.velocity.dot(rel) > 0.0:
			p.set_meta("ai_checked_%d" % get_instance_id(), true)
			if randf() < 0.35 * aggression:
				var perp: Vector2 = p.velocity.orthogonal().normalized()
				dodge(perp if randf() < 0.5 else -perp)
				return
