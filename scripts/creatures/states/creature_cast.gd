extends State
## Carga de una habilidad (cast time): se mueve lento, muestra el telegrafiado en el suelo y al terminar
## la lanza. Si recibe un golpe fuerte pasa a "stunned" y la habilidad se pierde.

const MOVE_FACTOR := 0.3

var _msg: Dictionary
var _move: MoveData
var _aim := Vector2.RIGHT
var _time := 0.0
var _gather: VfxSprite


func enter(msg: Dictionary = {}) -> void:
	_msg = msg
	_move = msg["move"]
	_aim = msg["aim"]
	_time = 0.0
	actor.sprite.charge_color = _move.element.color
	actor.sprite.charge = 0.0
	actor.sprite.play_charge(_move.cast_time)
	_gather = null
	var gather_sheet := DB.vfx_part(_move, "carga") if _move.beam_length > 0.0 else null
	if gather_sheet != null:  # Rayo Solar: la luz se junta adelante del Pokémon
		_gather = VfxSprite.attach(actor, gather_sheet)
		_gather.z_index = 5
		_gather.position = Vector2(0, -8) + _aim * 10.0
	match _move.kind:
		MoveData.Kind.AREA:
			actor.telegraph.show_circle(_move.radius, _move.element.color)
		MoveData.Kind.ZONE:
			actor.telegraph.show_circle(_move.zone_radius, _move.element.color)
		MoveData.Kind.PROJECTILE, MoveData.Kind.CHANNEL:
			var w := _move.size * 2.0 + 4.0 if _move.kind == MoveData.Kind.PROJECTILE else _move.cone_length * 0.5
			actor.telegraph.show_line(_aim, _move.reach(), w, _move.element.color)
		MoveData.Kind.DASH, MoveData.Kind.MELEE, MoveData.Kind.LUNGE:
			actor.telegraph.show_line(_aim, _move.reach(), 14.0, _move.element.color)


func exit() -> void:
	actor.sprite.charge = -1.0
	actor.sprite.stop_forced("Charge")
	actor.telegraph.clear()
	if is_instance_valid(_gather):
		_gather.queue_free()


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
		_msg["point"] = actor.input_source.aim_point(actor)
	elif is_instance_valid(actor.target):
		var off: Vector2 = actor.target.global_position - actor.global_position
		# Al soltar un disparo, la IA anticipa hacia dónde va el rival (como con los disparos sin carga).
		if _move.kind == MoveData.Kind.PROJECTILE and _move.speed > 0.0 and _move.beam_length <= 0.0:  # (un rayo llega al instante)
			off += actor.target.velocity * (off.length() / (_move.speed * Projectile.SPEED_MULT)) * CombatBody.difficulty().lead
		_aim = off.normalized()
		if _move.ride_range > 0.0:
			_msg["point"] = actor.target.global_position  # (Surf va adonde estás al soltarlo)
	actor.facing = _aim
	actor.telegraph.direction = _aim
	if is_instance_valid(_gather):
		_gather.position = Vector2(0, -8) + _aim * 10.0
		_gather.scale = Vector2.ONE * lerpf(0.5, 1.0, k)
	if _move.kind == MoveData.Kind.ZONE:
		actor.telegraph.position = actor.zone_point(_move, _msg.get("point", Vector2.INF), _aim) - actor.global_position
	elif _move.ride_range > 0.0:
		actor.telegraph.position = actor.ride_point(_move, _msg.get("point", Vector2.INF), _aim) - actor.global_position
	actor.move(dir, actor.speed() * MOVE_FACTOR)
	if _time >= _move.cast_time:
		_msg["aim"] = _aim
		var msg := _msg
		transition(actor.default_state())
		actor.release_move(msg)
