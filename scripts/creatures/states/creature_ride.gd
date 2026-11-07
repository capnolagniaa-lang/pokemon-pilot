extends State
## Surf (MoveData.ride_range): viaja montado en la ola hasta el punto apuntado y recién ahí revienta y golpea alrededor.
## Una pared o el agua lo frenan antes (y revienta ahí). Un golpe no lo corta.

const SPEED := 300.0
const WAVE_SHEET := "res://sprites/fx/moves/surf.png"
## Cuadros de la hoja en los que la ola está entera (los demás son el final, que muestra el golpe).
const WAVE_FRAMES := 4
const WAVE_SIZE := 56.0
## La base de la ola queda en los pies, y el Pokémon, arriba de ella.
const WAVE_Y := -19.0
const RIDER_LIFT := 16.0
const SPRAY_SPACING := 14.0

static var _wave_frames: SpriteFrames

var _hit: HitInfo
var _to := Vector2.ZERO
var _recovery := 0.0
var _left := 0.0
var _since_spray := 0.0
var _wave: VfxSprite


func enter(msg: Dictionary = {}) -> void:
	_hit = msg["hit"]
	_to = msg["to"]
	_recovery = msg.get("recovery", 0.0)
	_left = actor.global_position.distance_to(_to) / SPEED + 0.3
	_since_spray = 0.0
	actor.sprite.lift = RIDER_LIFT
	var frames := _frames()
	if frames != null:
		_wave = VfxSprite.attach(actor, frames, 0.0, WAVE_SIZE)
		_wave.position = Vector2(0.0, WAVE_Y)
		_wave.z_index = -1  # (detrás del Pokémon)
		_wave.flip_h = _to.x < actor.global_position.x
		NightLight.compensate(_wave)


func exit() -> void:
	actor.sprite.lift = 0.0
	if is_instance_valid(_wave):
		_wave.queue_free()
	_wave = null


func physics_update(delta: float) -> void:
	_left -= delta
	actor.knockback = Vector2.ZERO
	var off: Vector2 = _to - actor.global_position
	var step: float = SPEED * delta
	if off.length() <= step or _left <= 0.0:
		_finish()
		return
	var before: Vector2 = actor.global_position
	actor.facing = off.normalized()
	actor.velocity = off.normalized() * SPEED
	actor.move_and_slide()
	var dist: float = actor.global_position.distance_to(before)
	actor.moved.emit(dist)
	_since_spray += dist
	if _since_spray >= SPRAY_SPACING:
		_since_spray = 0.0
		Fx.burst(actor.get_parent(), actor.global_position, _hit.move.element.color, 4, 40.0)
	if actor.get_slide_collision_count() > 0:
		_finish()  # una pared: revienta ahí


func _finish() -> void:
	var a := AreaEffect.new()
	actor.get_parent().add_child(a)
	a.trigger(_hit, actor.global_position + Vector2(0, -6))
	if _recovery > 0.0:
		transition("recovery", {"time": _recovery})
	else:
		transition(actor.default_state())


static func _frames() -> SpriteFrames:
	if _wave_frames != null:
		return _wave_frames
	var sheet: SpriteFrames = DB.vfx_sheet(WAVE_SHEET)
	if sheet == null:
		return null
	_wave_frames = SpriteFrames.new()
	_wave_frames.set_animation_speed("default", 15.0)
	_wave_frames.set_animation_loop("default", true)
	for i in mini(WAVE_FRAMES, sheet.get_frame_count("default")):
		_wave_frames.add_frame("default", sheet.get_frame_texture("default", i))
	return _wave_frames
