class_name HazardPatch
extends Hitbox
## Parche de suelo peligroso (estela de fuego de la Embestida Ígnea): daña y aplica estado a los enemigos
## que lo pisan, una vez cada `TICK` segundos mientras sigan encima. Los parches de una misma estela comparten
## `shared` (hurtbox → cuadro de física en que puede volver a pegar): toda la estela pega como UN fuego, aunque el
## rival pise varios parches a la vez (antes cada parche pegaba por su cuenta y la embestida pegaba muchísimo).

const TICK := 0.5

var duration := 2.5
var radius := 7.0
var color := Color.WHITE
var _time := 0.0
var _tick := 0.0
var _shared: Dictionary = {}


func lay(p_hit: HitInfo, at: Vector2, p_duration: float, shared: Dictionary = {}) -> void:
	_shared = shared
	setup(p_hit, false)
	global_position = at
	duration = p_duration
	var el := p_hit.move.element
	color = el.hdr(el.color)
	var shape := CircleShape2D.new()
	shape.radius = radius
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	z_index = -5
	var p := CPUParticles2D.new()
	p.amount = 5
	p.lifetime = 0.45
	p.texture = StatusEffects._flame_texture()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(5, 2)
	p.direction = Vector2.UP
	p.spread = 15.0
	p.gravity = Vector2(0, -40)
	p.initial_velocity_min = 3.0
	p.initial_velocity_max = 9.0
	var ramp := Gradient.new()
	ramp.set_color(0, el.hdr(el.core_color))
	ramp.set_color(1, Color(color.r * 0.4, color.g * 0.15, 0.05, 0.0))
	p.color_ramp = ramp
	p.z_index = 4
	add_child(p)


func _physics_process(delta: float) -> void:
	_time += delta
	_tick -= delta
	if _tick <= 0.0:
		_tick = TICK
		var frame := Engine.get_physics_frames()
		for a in get_overlapping_areas():
			if a is Hurtbox and frame >= _shared.get(a, 0):
				_shared[a] = frame + int(TICK * Engine.physics_ticks_per_second) - 1
				hit.origin = global_position
				a.receive(hit)
	if _time >= duration:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var fade := clampf((duration - _time) / 0.5, 0.0, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.55))
	draw_circle(Vector2.ZERO, radius, Color(color.r * 0.6, color.g * 0.25, 0.05, 0.35 * fade))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Solo golpea en los ticks (no al entrar).
func _on_area_entered(_area: Area2D) -> void:
	pass
