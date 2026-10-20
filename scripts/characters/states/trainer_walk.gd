extends State
## Entrenador caminando o corriendo (Shift).


func physics_update(delta: float) -> void:
	var dir: Vector2 = actor.input_dir()
	if dir == Vector2.ZERO:
		transition("idle")
		return
	var running: bool = actor.wants_run()
	actor.move(dir, actor.run_speed if running else actor.walk_speed)
	actor.animate(true, running, delta)
