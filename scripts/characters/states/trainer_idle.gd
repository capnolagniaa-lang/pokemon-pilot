extends State
## Entrenador quieto.


func enter(_msg: Dictionary = {}) -> void:
	actor.velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	actor.animate(false, false, delta)
	if actor.input_dir() != Vector2.ZERO:
		transition("walk")
