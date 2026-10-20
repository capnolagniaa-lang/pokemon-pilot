extends State
## Lo controla el jugador: WASD para moverse, mouse para apuntar, 1-4/clic para atacar, espacio para esquivar.


func physics_update(_delta: float) -> void:
	var input: CombatInput = actor.input_source
	if input == null:
		return
	var dir := input.move_dir(actor)
	var aim := input.aim(actor)
	actor.move(dir, actor.speed())
	if aim.length() > 4.0:
		actor.facing = aim.normalized()
	if input.wants_dodge() and actor.dodge(dir):
		return
	for i in 4:
		if input.wants_move(i) and actor.use_move(i, aim):
			return
