class_name BotCombatInput
extends CombatInput
## Órdenes automáticas para el Pokémon controlado (autotest): mantiene distancia, rodea, usa los 4 ataques
## al azar y esquiva de vez en cuando.

var world: Node
## Distancia a la que pelea (el bot de siempre, cerca; con 110 pelea de lejos y se mueve, como un jugador que
## kitea con proyectiles).
var keep_distance := 40.0
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
	if d > keep_distance * 1.5:
		return to.normalized()
	if d < keep_distance * 0.55:
		return -to.normalized()
	return to.normalized().orthogonal() * _strafe


func aim(actor: Creature) -> Vector2:
	var e := _enemy(actor)
	return (e.global_position - actor.global_position) if e != null else actor.facing


func aim_point(actor: Creature) -> Vector2:
	var e := _enemy(actor)
	return e.global_position if e != null else actor.global_position + actor.facing * 40.0


func wants_slot(slot: int) -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _choice_time > 0.35:
		_choice_time = now
		_choice = randi() % MoveUser.SLOT_COUNT
	return slot == _choice


func wants_dodge() -> bool:
	return randf() < 0.01
