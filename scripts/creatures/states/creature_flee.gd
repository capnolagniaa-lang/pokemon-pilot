extends State
## Salvaje con poca vida huyendo de su objetivo. Al alejarse lo suficiente, se calma.

@export var safe_distance := 200.0
@export var max_time := 4.0

var _time := 0.0


func enter(_msg: Dictionary = {}) -> void:
	_time = 0.0


func physics_update(delta: float) -> void:
	_time += delta
	var t: Creature = actor.target
	if not is_instance_valid(t) or _time > max_time or actor.global_position.distance_to(t.global_position) > safe_distance:
		actor.home = actor.global_position
		transition("wander")
		return
	var away: Vector2 = (actor.global_position - t.global_position).normalized()
	if actor.get_slide_collision_count() > 0:
		away = away.rotated(PI / 2.0)
	actor.move(away, actor.speed() * 1.1)
