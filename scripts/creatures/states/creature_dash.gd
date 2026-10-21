extends State
## Desplazamiento rápido: embestida (con hitbox) o esquive/movilidad (invulnerable, sin hitbox).
## Al terminar una embestida con recuperación, queda expuesto (ventana de castigo).

var _dir := Vector2.RIGHT
var _time := 0.0
var _attack := false
var _recovery := 0.0


func enter(msg: Dictionary = {}) -> void:
	_dir = (msg["dir"] as Vector2).normalized()
	_time = msg["time"]
	_attack = msg["attack"]
	_recovery = msg.get("recovery", 0.0)
	actor.facing = _dir
	actor.dash_hitbox.monitoring = _attack
	actor.sprite.afterimages = true


func exit() -> void:
	actor.dash_hitbox.set_deferred("monitoring", false)
	actor.sprite.afterimages = false


func physics_update(delta: float) -> void:
	_time -= delta
	actor.knockback = Vector2.ZERO
	var before: Vector2 = actor.global_position
	actor.velocity = _dir * Creature.DASH_SPEED
	actor.move_and_slide()
	actor.moved.emit(actor.global_position.distance_to(before))
	if _time <= 0.0 or actor.get_slide_collision_count() > 0:
		if _recovery > 0.0:
			transition("recovery", {"time": _recovery})
		else:
			transition(actor.default_state())
