extends "res://scripts/creature.gd"
## Criatura controlada por el jugador: WASD para moverse, mouse para apuntar.


func _control(_delta: float) -> Vector2:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var aim := get_global_mouse_position() - global_position
	if aim.length() > 4.0:
		facing = aim.normalized()
	if Input.is_action_just_pressed("dodge"):
		dodge(dir)
	for i in 4:
		if Input.is_action_pressed("attack_%d" % (i + 1)):
			use_move(i, aim)
	return dir
