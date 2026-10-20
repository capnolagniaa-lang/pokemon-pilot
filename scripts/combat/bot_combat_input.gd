class_name BotCombatInput
extends CombatInput
## Órdenes automáticas para el Pokémon controlado (autotest): mantiene distancia, rodea, ataca y esquiva.

var world: Node
var _choice := -1
var _choice_time := 0.0
var _strafe := 1.0


func _init(p_world: Node) -> void:
	world = p_world


func _enemy(actor: Creature) -> Creature:
	var best: Creature = null
	for e in world.combat.enemies:
		if is_instance_valid(e) and (best == null or e.global_position.distance_to(actor.global_position) < best.global_position.distance_to(actor.global_position)):
			best = e
	return best


func move_dir(actor: Creature) -> Vector2:
	var e := _enemy(actor)
	if e == null:
		return Vector2.ZERO
	var to := e.global_position - actor.global_position
	var d := to.length()
	if randf() < 0.01:
		_strafe = -_strafe
	if d > 70.0:
		return to.normalized()
	if d < 35.0:
		return -to.normalized()
	return to.normalized().orthogonal() * _strafe


func aim(actor: Creature) -> Vector2:
	var e := _enemy(actor)
	return (e.global_position - actor.global_position) if e != null else actor.facing


func wants_move(i: int) -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _choice_time > 0.35:
		_choice_time = now
		_choice = randi() % 4
	return i == _choice


func wants_dodge() -> bool:
	return randf() < 0.01
