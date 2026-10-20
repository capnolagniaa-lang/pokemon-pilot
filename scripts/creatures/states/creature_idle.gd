extends State
## Quieto. Si tiene líder y se aleja, pasa a seguirlo. De vez en cuando mira a otro lado.

@export var follow_distance := 22.0

var _look_timer := 0.0


func enter(_msg: Dictionary = {}) -> void:
	actor.velocity = Vector2.ZERO
	_look_timer = randf_range(1.5, 4.0)


func physics_update(delta: float) -> void:
	var leader: Trainer = actor.leader
	if leader != null and actor.global_position.distance_to(leader.global_position) > follow_distance + 8.0:
		transition("follow")
		return
	_look_timer -= delta
	if _look_timer <= 0.0:
		_look_timer = randf_range(1.5, 4.0)
		if leader != null and randf() < 0.6:
			actor.facing = (leader.global_position - actor.global_position).normalized()
		else:
			actor.facing = Vector2.RIGHT.rotated(randf() * TAU)
