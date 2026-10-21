extends State
## Lo controla el jugador: WASD para moverse, mouse para apuntar y las 5 ranuras del kit
## (Clic izq. básico · Clic der. habilidad 1 · Q habilidad 2 · Espacio movilidad · R definitiva).

## Orden en que se revisan las ranuras: movilidad primero (para esquivar a tiempo), definitiva al final.
const ORDER := [Kit.Slot.MOBILITY, Kit.Slot.ABILITY_1, Kit.Slot.ABILITY_2, Kit.Slot.ULTIMATE, Kit.Slot.BASIC]


func physics_update(_delta: float) -> void:
	var input: CombatInput = actor.input_source
	if input == null:
		return
	var dir := input.move_dir(actor)
	var aim := input.aim(actor)
	actor.move(dir, actor.speed())
	if aim.length() > 4.0:
		actor.facing = aim.normalized()
	for slot in ORDER:
		if not input.wants_slot(slot):
			continue
		var a: Vector2 = (dir if dir.length() > 0.1 else aim) if slot == Kit.Slot.MOBILITY else aim
		if actor.use_slot(slot, a, input.aim_point(actor)):
			return
