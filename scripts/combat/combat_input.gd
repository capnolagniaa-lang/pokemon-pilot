class_name CombatInput
extends RefCounted
## De dónde salen las órdenes del Pokémon que controlás. La versión base lee teclado y mouse, o el joystick: con joystick
## los ataques salen hacia donde mira el Pokémon (decisión del usuario 2026-11-05). Los de zona (Rayo, Trueno...) se apuntan
## manteniendo el botón: un toque cae encima tuyo y, mientras lo mantenés, la marca avanza hasta su alcance máximo
## (`AIM_TIME`); sale al soltar. Se resuelve acá, antes de `wants_slot`, así la pelea online recibe un ataque común.
## El autotest usa otra (bot) con la misma interfaz.

## Segundos manteniendo el botón hasta llegar al alcance máximo.
const AIM_TIME := 0.7
## Cuánto dura el "apretado" al soltar, en ms (la pelea online lo manda en varios paquetes; la recarga evita que salga dos veces).
const FIRE_WINDOW := 120

var _actor: Creature
var _aiming := -1
var _aim_time := 0.0
var _fire_slot := -1
var _fire_until := 0
var _fire_point := Vector2.ZERO


func move_dir(_actor_now: Creature) -> Vector2:
	if Controls.wheel_open:
		return Vector2.ZERO
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func aim(actor: Creature) -> Vector2:
	if Controls.gamepad:
		return actor.facing.normalized() * 40.0
	return actor.get_global_mouse_position() - (actor.global_position + Vector2(0, -8))


## Punto del mundo apuntado (para ubicar zonas y para el Arañazo de Charmander).
func aim_point(actor: Creature) -> Vector2:
	if Controls.gamepad:
		if _firing():
			return _fire_point
		return actor.global_position + actor.facing.normalized() * 90.0
	return actor.get_global_mouse_position()


## ¿Quiere usar el ataque de esta ranura (0-3)? Mientras se mantenga apretado.
func wants_slot(slot: int) -> bool:
	if Controls.wheel_open:
		return false
	if Controls.gamepad and is_instance_valid(_actor) and is_aimed(_actor, slot):
		return slot == _fire_slot and _firing()
	return Input.is_action_pressed(Controls.SLOT_ACTIONS[slot])


## ¿Quiere esquivar? (Espacio, al apretar).
func wants_dodge() -> bool:
	return not Controls.wheel_open and Input.is_action_just_pressed("dodge")


## Una vez por cuadro, desde el estado "controlled".
func tick(actor: Creature, delta: float) -> void:
	if actor != _actor:
		_stop_aiming()
		_actor = actor
	if not Controls.gamepad or Controls.wheel_open:
		_stop_aiming()
		return
	if _aiming < 0:
		if not _firing():
			_try_start_aiming(actor)
		return
	if not actor.can_act() or actor.moves.slots[_aiming] == null:
		_stop_aiming()
		return
	var m: MoveData = actor.moves.slots[_aiming]
	if Input.is_action_pressed(Controls.SLOT_ACTIONS[_aiming]):
		_aim_time += delta
		_show_mark(actor, m)
		return
	_fire_slot = _aiming
	_fire_point = aimed_point(actor, m)
	_fire_until = Time.get_ticks_msec() + FIRE_WINDOW
	_stop_aiming()


## ¿Es de los que se apuntan manteniendo? (Excavar sale donde estés: no.)
static func is_aimed(actor: Creature, slot: int) -> bool:
	if slot < 0 or slot >= actor.moves.slots.size() or actor.moves.slots[slot] == null:
		return false
	var m: MoveData = actor.moves.slots[slot]
	return m.kind == MoveData.Kind.ZONE and m.burrow_time <= 0.0


## Dónde caería ahora: de los pies hasta su alcance, según cuánto hace que se mantiene.
func aimed_point(actor: Creature, m: MoveData) -> Vector2:
	return actor.global_position + actor.facing.normalized() * m.placement_range * clampf(_aim_time / AIM_TIME, 0.0, 1.0)


func is_aiming() -> bool:
	return _aiming >= 0


func _firing() -> bool:
	return _fire_slot >= 0 and Time.get_ticks_msec() < _fire_until


func _try_start_aiming(actor: Creature) -> void:
	if not actor.can_act():
		return
	for slot in actor.moves.slots.size():
		if is_aimed(actor, slot) and Input.is_action_pressed(Controls.SLOT_ACTIONS[slot]) and actor.moves.can_use(slot):
			_aiming = slot
			_aim_time = 0.0
			var m: MoveData = actor.moves.slots[slot]
			actor.telegraph.show_circle(m.zone_radius, m.element.color)
			_show_mark(actor, m)
			return


func _show_mark(actor: Creature, m: MoveData) -> void:
	actor.telegraph.global_position = aimed_point(actor, m)
	actor.telegraph.progress = clampf(_aim_time / AIM_TIME, 0.0, 1.0)


func _stop_aiming() -> void:
	if _aiming >= 0 and is_instance_valid(_actor):
		_actor.telegraph.clear()
	_aiming = -1
	_aim_time = 0.0
