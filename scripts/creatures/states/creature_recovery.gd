extends State
## Recuperación después de un ataque fuerte: ventana de castigo. No puede atacar ni esquivar y se mueve
## muy lento (regla: "la recuperación es la ventana de castigo").

const MOVE_FACTOR := 0.35

var _time := 0.0


func enter(msg: Dictionary = {}) -> void:
	_time = msg.get("time", 0.2)


func physics_update(delta: float) -> void:
	_time -= delta
	var dir := Vector2.ZERO
	if actor.player_controlled and actor.input_source != null:
		dir = actor.input_source.move_dir(actor)
	actor.move(dir, actor.speed() * MOVE_FACTOR)
	if _time <= 0.0:
		transition(actor.default_state())
