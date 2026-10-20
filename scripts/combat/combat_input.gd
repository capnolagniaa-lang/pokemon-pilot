class_name CombatInput
extends RefCounted
## De dónde salen las órdenes del Pokémon que controlás. La versión base lee teclado y mouse;
## el autotest usa otra (bot) con la misma interfaz.


func move_dir(_actor: Creature) -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func aim(actor: Creature) -> Vector2:
	return actor.get_global_mouse_position() - (actor.global_position + Vector2(0, -8))


func wants_move(i: int) -> bool:
	return Input.is_action_pressed("attack_%d" % (i + 1))


func wants_dodge() -> bool:
	return Input.is_action_just_pressed("dodge")
