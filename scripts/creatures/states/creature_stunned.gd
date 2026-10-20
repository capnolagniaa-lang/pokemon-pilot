extends State
## Aturdido (golpe fuerte, parálisis) o congelado: no actúa; solo lo mueve el empuje del golpe.

var _time := 0.0


func enter(msg: Dictionary = {}) -> void:
	_time = msg.get("time", 0.3)


func physics_update(delta: float) -> void:
	_time -= delta
	actor.move(Vector2.ZERO, 0.0)
	# Congelado: no sale hasta que se le pasa el estado (o se lo derriten).
	if _time <= 0.0 and actor.statuses.can_act():
		transition(actor.default_state())
	elif actor.statuses.can_act() and _time > 0.6:
		_time = 0.6
