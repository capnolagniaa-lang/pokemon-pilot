extends State
## Paso del golpe cuerpo a cuerpo (pedido del usuario 2026-10-28: "los golpes físicos tienen que tener mínimo un rango
## para avanzar y golpear"): antes del corte se adelanta `MoveData.melee_step` px hacia donde apunta (menos si el rival
## ya está cerca, para no pasarlo de largo) y recién ahí suelta el golpe (Creature.swing_melee).

const SPEED := 430.0

var _msg: Dictionary
var _dir := Vector2.RIGHT
var _left := 0.0


func enter(msg: Dictionary = {}) -> void:
	_msg = msg
	_dir = (msg["aim"] as Vector2).normalized()
	_left = msg["distance"]
	actor.facing = _dir


func physics_update(delta: float) -> void:
	actor.knockback = Vector2.ZERO
	var before: Vector2 = actor.global_position
	var want := minf(SPEED * delta, _left)
	actor.velocity = _dir * want / maxf(delta, 0.001)
	actor.move_and_slide()
	var d: float = actor.global_position.distance_to(before)
	_left -= d
	actor.moved.emit(d)
	# Frena al llegar o si algo lo para (rozar una pared y deslizarse no cuenta).
	if _left <= 0.5 or d < want * 0.3:
		actor.swing_melee(_msg)
