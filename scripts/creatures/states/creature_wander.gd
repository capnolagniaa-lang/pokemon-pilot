extends State
## Salvaje deambulando cerca de su lugar. Si ve a tu Pokémon o al entrenador, lo persigue.

@export var wander_radius := 56.0
## Distancia a la que detecta.
@export var aggro_radius := 70.0

var _goal := Vector2.ZERO
var _pause := 0.0
var _scan := 0.0


func enter(_msg: Dictionary = {}) -> void:
	actor.target = null
	_pick_goal()


func physics_update(delta: float) -> void:
	_scan -= delta
	if _scan <= 0.0:
		_scan = 0.25
		var seen := _spot_target()
		if seen != null:
			actor.target = seen
			Events.wild_aggro.emit(actor, seen)
			transition("chase")
			return
	if _pause > 0.0:
		_pause -= delta
		actor.move(Vector2.ZERO, 0.0)
		return
	var diff: Vector2 = _goal - actor.global_position
	if diff.length() < 3.0 or actor.get_slide_collision_count() > 0:
		_pause = randf_range(0.8, 2.5)
		_pick_goal()
		return
	actor.move(diff.normalized(), actor.speed() * 0.35)


func _pick_goal() -> void:
	_goal = actor.home + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(8.0, wander_radius)


## El objetivo es tu Pokémon (si está afuera y en pie); si no hay, el entrenador.
func _spot_target() -> Creature:
	for c in actor.get_tree().get_nodes_in_group("ally_creatures"):
		if c.is_down() or not c.visible:
			continue
		if actor.global_position.distance_to(c.global_position) < aggro_radius:
			return c
		if is_instance_valid(c.leader) and actor.global_position.distance_to(c.leader.global_position) < aggro_radius * 0.8:
			return c
	return null
