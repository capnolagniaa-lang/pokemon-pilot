class_name CombatInput
extends RefCounted
## De dónde salen las órdenes del Pokémon que controlás. La versión base lee teclado y mouse;
## el autotest usa otra (bot) con la misma interfaz.


func move_dir(_actor: Creature) -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func aim(actor: Creature) -> Vector2:
	return actor.get_global_mouse_position() - (actor.global_position + Vector2(0, -8))


## Punto del mundo apuntado (para ubicar zonas como Giro Fuego).
func aim_point(actor: Creature) -> Vector2:
	return actor.get_global_mouse_position()


## ¿Quiere usar la habilidad de esta ranura (Kit.Slot)? La movilidad se activa al apretar; el resto
## mientras se mantenga apretado (así el combo básico sale manteniendo el clic).
func wants_slot(slot: int) -> bool:
	var action: String = Controls.SLOT_ACTIONS[slot]
	if slot == Kit.Slot.MOBILITY:
		return Input.is_action_just_pressed(action)
	return Input.is_action_pressed(action)
