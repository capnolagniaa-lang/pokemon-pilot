extends State
## Aturdido (golpe fuerte, parálisis llena, interacción) o inmovilizado por un estado (congelado, dormido):
## no actúa; solo lo mueve el empuje del golpe. Si era un control, al terminar activa la resistencia a control.

var _time := 0.0
var _cc := false
var _held := false


func enter(msg: Dictionary = {}) -> void:
	_time = msg.get("time", 0.3)
	_cc = msg.get("cc", false)
	# Si lo causa un estado (dormido, congelado), dura lo que dure el estado (y se corta si se lo curan).
	_held = not actor.statuses.can_act()


func exit() -> void:
	if _cc:
		actor.cc_resist_left = Creature.CC_RESIST_TIME


func physics_update(delta: float) -> void:
	actor.move(Vector2.ZERO, 0.0)
	# Mientras un estado le impida actuar (congelado, dormido) se queda; si se lo curan, se levanta enseguida.
	if not actor.statuses.can_act():
		_held = true
		if actor.napping:
			WildSociety.sleep_tick(actor, delta)  # salvaje durmiendo en su hora: si pasás al lado, se despierta
		return
	if _held:  # se le terminó o le curaron el estado: se levanta casi enseguida
		_held = false
		_time = minf(_time, 0.15)
	_time -= delta
	if _time <= 0.0:
		transition(actor.default_state())
