extends State
## Salvaje persiguiendo a su objetivo hasta tenerlo a tiro.

## Si se aleja tanto de su lugar, abandona.
@export var leash := 360.0


func physics_update(_delta: float) -> void:
	var t: Creature = actor.target
	if not is_instance_valid(t) or t.is_down():
		transition("wander")
		return
	if actor.global_position.distance_to(actor.home) > leash:
		transition("wander")
		return
	var diff: Vector2 = t.global_position - actor.global_position
	if diff.length() < _preferred_range() * 1.1:
		transition("attack")
		return
	actor.move(diff.normalized(), actor.speed())


func _preferred_range() -> float:
	if actor.instance.species.kit != null:
		return actor.instance.species.kit.preferred_range
	var best := 30.0
	for m in actor.moves.moves:
		if m.kind == MoveData.Kind.PROJECTILE:
			best = maxf(best, m.reach() * 0.6)
	return best
