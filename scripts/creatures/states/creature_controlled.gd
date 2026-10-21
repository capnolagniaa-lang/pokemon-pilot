extends State
## Lo controla el jugador: WASD para moverse, mouse para apuntar, Espacio esquiva y 4 ataques
## (Clic izq., Clic der., Q, R).

## Orden en que se revisan: el ataque 4 (el grande) primero, así no lo tapa un clic que se mantiene.
const ORDER := [3, 2, 1, 0]


func physics_update(_delta: float) -> void:
	var input: CombatInput = actor.input_source
	if input == null:
		return
	var dir := input.move_dir(actor)
	var aim := input.aim(actor)
	actor.move(dir, actor.speed())
	if aim.length() > 4.0:
		actor.facing = aim.normalized()
	if input.wants_dodge() and actor.dodge(dir if dir.length() > 0.1 else aim):
		return
	for slot in ORDER:
		if input.wants_slot(slot) and actor.use_slot(slot, aim, input.aim_point(actor)):
			return
