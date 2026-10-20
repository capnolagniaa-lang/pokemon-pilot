extends State
## Desplazamiento rápido: embestida (con hitbox) o esquive (invulnerable, sin hitbox).

var _dir := Vector2.RIGHT
var _time := 0.0
var _attack := false


func enter(msg: Dictionary = {}) -> void:
	_dir = (msg["dir"] as Vector2).normalized()
	_time = msg["time"]
	_attack = msg["attack"]
	actor.facing = _dir
	actor.dash_hitbox.monitoring = _attack
	actor.sprite.afterimages = true


func exit() -> void:
	actor.dash_hitbox.set_deferred("monitoring", false)
	actor.sprite.afterimages = false


func physics_update(delta: float) -> void:
	_time -= delta
	actor.knockback = Vector2.ZERO
	actor.velocity = _dir * Creature.DASH_SPEED
	actor.move_and_slide()
	if _time <= 0.0 or actor.get_slide_collision_count() > 0:
		transition(actor.default_state())
