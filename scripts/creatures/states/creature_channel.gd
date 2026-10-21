extends State
## Canalizado (Lanzallamas): mantiene un cono que golpea en ticks durante `channel_time`. Se mueve muy
## lento y gira el cono hacia donde apunta (con giro limitado). Un golpe fuerte lo corta (pasa a stunned).
## Al terminar, recuperación (ventana de castigo).

const MOVE_FACTOR := 0.2
const TURN_SPEED := 2.5  # radianes por segundo

var _move: MoveData
var _cone: ChannelCone
var _aim := Vector2.RIGHT
var _time := 0.0


func enter(msg: Dictionary = {}) -> void:
	_move = msg["move"]
	_aim = (msg["aim"] as Vector2).normalized()
	_time = 0.0
	_cone = ChannelCone.new()
	actor.add_child(_cone)
	_cone.position = Vector2(0, -8)
	_cone.open(msg["hit"])
	_cone.aim(_aim)


func exit() -> void:
	if is_instance_valid(_cone):
		_cone.close()
	_cone = null


func physics_update(delta: float) -> void:
	_time += delta
	var dir := Vector2.ZERO
	var want := _aim
	if actor.player_controlled and actor.input_source != null:
		dir = actor.input_source.move_dir(actor)
		var a: Vector2 = actor.input_source.aim(actor)
		if a.length() > 4.0:
			want = a.normalized()
	elif is_instance_valid(actor.target):
		want = (actor.target.global_position - actor.global_position).normalized()
	var diff := _aim.angle_to(want)
	_aim = _aim.rotated(clampf(diff, -TURN_SPEED * delta, TURN_SPEED * delta))
	actor.facing = _aim
	_cone.aim(_aim)
	actor.move(dir, actor.speed() * MOVE_FACTOR)
	actor.facing = _aim
	if _time >= _move.channel_time:
		if _move.recovery > 0.0:
			transition("recovery", {"time": _move.recovery})
		else:
			transition(actor.default_state())
