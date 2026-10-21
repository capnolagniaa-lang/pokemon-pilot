extends State
## Carga de un ataque (cast time): se mueve lento, muestra el telegrafiado en el suelo y al terminar
## lanza el ataque. Si recibe un golpe fuerte pasa a "stunned" y el ataque se pierde.

const MOVE_FACTOR := 0.3

var _move: MoveData
var _aim := Vector2.RIGHT
var _time := 0.0


func enter(msg: Dictionary = {}) -> void:
	_move = msg["move"]
	_aim = msg["aim"]
	_time = 0.0
	actor.sprite.charge_color = _move.element.color
	actor.sprite.charge = 0.0
	match _move.kind:
		MoveData.Kind.AREA:
			actor.telegraph.show_circle(_move.radius, _move.element.color)
		MoveData.Kind.PROJECTILE:
			actor.telegraph.show_line(_aim, _move.reach(), _move.size * 2.0 + 4.0, _move.element.color)
		MoveData.Kind.DASH:
			actor.telegraph.show_line(_aim, _move.reach(), 14.0, _move.element.color)


func exit() -> void:
	actor.sprite.charge = -1.0
	actor.telegraph.clear()


func physics_update(delta: float) -> void:
	_time += delta
	var k := clampf(_time / _move.cast_time, 0.0, 1.0)
	actor.sprite.charge = k
	actor.telegraph.progress = k
	var dir := Vector2.ZERO
	if actor.player_controlled and actor.input_source != null:
		dir = actor.input_source.move_dir(actor)
		var aim: Vector2 = actor.input_source.aim(actor)
		if aim.length() > 4.0:
			_aim = aim.normalized()
	elif is_instance_valid(actor.target):
		_aim = (actor.target.global_position - actor.global_position).normalized()
	actor.facing = _aim
	actor.telegraph.direction = _aim
	actor.move(dir, actor.speed() * MOVE_FACTOR)
	if _time >= _move.cast_time:
		var m := _move
		transition(actor.default_state())
		actor.release_move(m, _aim)
