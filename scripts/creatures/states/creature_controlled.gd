extends State
## Lo controla el jugador: WASD para moverse, mouse para apuntar, Espacio esquiva y 4 ataques
## (Clic izq., Clic der., Q, R).

## Orden en que se revisan: el ataque 4 (el grande) primero, así no lo tapa un clic que se mantiene.
const ORDER := [3, 2, 1, 0]


func physics_update(delta: float) -> void:
	var input: CombatInput = actor.input_source
	if input == null:
		return
	input.tick(actor, delta)
	var dir := input.move_dir(actor)
	actor.move(dir, actor.speed())
	var aim := input.aim(actor)  # (después de moverse: con joystick se apunta hacia donde mira)
	if aim.length() > 4.0:
		actor.facing = aim.normalized()
	if input.wants_dodge() and actor.dodge(dir if dir.length() > 0.1 else aim, aim):
		return
	if actor.is_burrowed() and actor.burrow.slot >= 0 and not input.wants_slot(actor.burrow.slot):
		actor.burrow.armed = true  # soltó la tecla: ahora sí, apretarla lo saca
	for slot in ORDER:
		if input.wants_slot(slot) and actor.use_slot(slot, aim, input.aim_point(actor)):
			return
