class_name CombatInput
extends RefCounted
## De dónde salen las órdenes del Pokémon que controlás. La versión base lee teclado y mouse, o el joystick: con joystick
## los ataques salen hacia donde mira el Pokémon (decisión del usuario 2026-11-05) y las zonas caen adelante, a `PAD_ZONE`.
## El autotest usa otra (bot) con la misma interfaz.

const PAD_ZONE := 90.0


func move_dir(_actor: Creature) -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func aim(actor: Creature) -> Vector2:
	if Controls.gamepad:
		return actor.facing.normalized() * 40.0
	return actor.get_global_mouse_position() - (actor.global_position + Vector2(0, -8))


## Punto del mundo apuntado (para ubicar zonas y para el Arañazo de Charmander).
func aim_point(actor: Creature) -> Vector2:
	if Controls.gamepad:
		return actor.global_position + actor.facing.normalized() * PAD_ZONE
	return actor.get_global_mouse_position()


## ¿Quiere usar el ataque de esta ranura (0-3)? Mientras se mantenga apretado.
func wants_slot(slot: int) -> bool:
	return Input.is_action_pressed(Controls.SLOT_ACTIONS[slot])


## ¿Quiere esquivar? (Espacio, al apretar).
func wants_dodge() -> bool:
	return Input.is_action_just_pressed("dodge")
