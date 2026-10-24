extends State
## Embestida con combo (Arañazo de Charmander): se lanza hacia el punto apuntado (hasta `lunge_range`).
## Si conecta (1er golpe = el contacto), se frena y tras `followup_delay` da el 2º golpe, que empuja.
## Si no conecta, termina y queda la recuperación.

enum Phase { DASH, FOLLOWUP }

var _move: MoveData
var _dir := Vector2.RIGHT
var _left := 0.0
var _phase := Phase.DASH
var _timer := 0.0


func enter(msg: Dictionary = {}) -> void:
	_move = msg["move"]
	_dir = (msg["dir"] as Vector2).normalized()
	_left = msg["distance"]
	_phase = Phase.DASH
	actor.facing = _dir
	actor.dash_hitbox.monitoring = true
	actor.dash_hitbox.hit_landed.connect(_on_contact)
	actor.sprite.afterimages = true


func exit() -> void:
	if actor.dash_hitbox.hit_landed.is_connected(_on_contact):
		actor.dash_hitbox.hit_landed.disconnect(_on_contact)
	actor.dash_hitbox.set_deferred("monitoring", false)
	actor.sprite.afterimages = false


func _on_contact(_hurtbox: Hurtbox) -> void:
	if _phase != Phase.DASH:
		return
	_phase = Phase.FOLLOWUP
	_timer = _move.followup_delay
	actor.dash_hitbox.set_deferred("monitoring", false)
	actor.velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	actor.knockback = Vector2.ZERO
	if _phase == Phase.DASH:
		var before: Vector2 = actor.global_position
		actor.velocity = _dir * _move.lunge_speed
		actor.move_and_slide()
		var d: Vector2 = actor.global_position - before
		_left -= d.length()
		actor.moved.emit(d.length())
		for i in actor.get_slide_collision_count():
			var obj = actor.get_slide_collision(i).get_collider()
			if obj is EnvObject:
				Events.env_object_struck.emit(obj, _move.power * _move.power_mult)
		if _phase == Phase.DASH and (_left <= 0.0 or actor.get_slide_collision_count() > 0):
			_finish()
		return
	_timer -= delta
	if _timer <= 0.0:
		# 2º golpe del combo: corte delante con más empuje.
		var hit := HitInfo.from(actor, _move)
		hit.damage_mult *= _move.followup_power_mult
		hit.knockback = _move.followup_knockback
		var s := MeleeSwing.new()
		actor.get_parent().add_child(s)
		s.swing(hit, actor.global_position + Vector2(0, -8) + _dir * _move.melee_range, _move.swing_radius * hit.area_mult, _dir)
		actor.sprite.play_chain("swing", 0.3)
		_finish()


func _finish() -> void:
	if _move.recovery > 0.0:
		transition("recovery", {"time": _move.recovery})
	else:
		transition(actor.default_state())
