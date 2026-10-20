extends State
## Sigue al líder por su rastro de migas (así esquiva los obstáculos que él esquivó).

@export var follow_distance := 22.0
## Si queda muy lejos (por ejemplo, trabado), reaparece detrás del líder.
@export var teleport_distance := 160.0


func physics_update(_delta: float) -> void:
	var leader: Trainer = actor.leader
	if leader == null:
		transition("idle")
		return
	var to_leader: float = actor.global_position.distance_to(leader.global_position)
	if to_leader > teleport_distance:
		actor.global_position = _trail_point(leader)
		return
	if to_leader <= follow_distance:
		transition("idle")
		return
	var target := _trail_point(leader)
	var diff: Vector2 = target - actor.global_position
	if diff.length() < 1.0:
		actor.velocity = Vector2.ZERO
		return
	# Va un poco más rápido que el líder si se atrasa.
	var speed := clampf(diff.length() * 6.0, 20.0, leader.run_speed * 1.15)
	actor.move(diff.normalized(), speed)


## Punto del rastro que queda a follow_distance detrás del líder.
func _trail_point(leader: Trainer) -> Vector2:
	var trail := leader.trail
	var acc := 0.0
	var prev := leader.global_position
	for i in range(trail.size() - 1, -1, -1):
		acc += prev.distance_to(trail[i])
		prev = trail[i]
		if acc >= follow_distance:
			return trail[i]
	return trail[0]
