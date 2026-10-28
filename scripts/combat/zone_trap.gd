class_name ZoneTrap
extends Node2D
## Zona en el suelo que atrapa: los enemigos que están adentro al aparecer no pueden salir; si tocan el
## borde reciben el golpe de la zona y rebotan hacia adentro (Giro Fuego de Charmander).

const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")
const TOUCH_COOLDOWN := 0.6

var hit: HitInfo
var radius := 30.0
var duration := 3.0
var color := Color.WHITE
var _time := 0.0
var _trapped: Array = []
var _touch: Dictionary = {}  # criatura -> tiempo hasta poder volver a dañarla


func place(p_hit: HitInfo, center: Vector2) -> void:
	hit = p_hit
	var m := p_hit.move
	global_position = center
	radius = m.zone_radius * p_hit.area_mult
	duration = m.zone_duration
	color = m.element.hdr(m.element.color)
	z_index = -5
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.team != hit.team and not c.is_down() and c.global_position.distance_to(center) <= radius:
			_trapped.append(c)
	var ring := CPUParticles2D.new()
	ring.amount = 40
	ring.lifetime = 0.5
	ring.texture = StatusEffects._flame_texture()
	ring.emission_shape = CPUParticles2D.EMISSION_SHAPE_RING
	ring.emission_ring_radius = radius
	ring.emission_ring_inner_radius = radius - 2.0
	ring.direction = Vector2.UP
	ring.spread = 15.0
	ring.gravity = Vector2(0, -50)
	ring.initial_velocity_min = 4.0
	ring.initial_velocity_max = 12.0
	ring.scale_amount_min = 1.0
	ring.scale_amount_max = 2.0
	var ramp := Gradient.new()
	ramp.set_color(0, m.element.hdr(m.element.core_color))
	ramp.set_color(1, Color(color.r * 0.5, color.g * 0.2, color.b * 0.1, 0.0))
	ring.color_ramp = ramp
	ring.z_index = 4
	add_child(ring)
	var light := PointLight2D.new()
	light.texture = LIGHT_TEX
	light.color = m.element.color
	light.energy = 0.3
	light.texture_scale = radius / 28.0
	add_child(light)
	Events.element_impact.emit(m.element, center, radius)
	NightLight.apply(self)  # día y noche: no se oscurece con la noche y su luz crece (docs/PLAN_DIA_NOCHE.md)

func _physics_process(delta: float) -> void:
	_time += delta
	for c in _touch.keys():
		_touch[c] -= delta
	for c in _trapped:
		if not is_instance_valid(c) or c.is_down():
			continue
		var d: Vector2 = c.global_position - global_position
		if d.length() > radius - 3.0:
			var n := d.normalized()
			c.global_position = global_position + n * (radius - 3.0)
			c.knockback = -n * 110.0
			if _touch.get(c, 0.0) <= 0.0:
				_touch[c] = TOUCH_COOLDOWN
				hit.origin = global_position + n * (radius + 10.0)
				c.hurtbox.receive(hit)
	if _time >= duration:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var fade := clampf((duration - _time) / 0.4, 0.0, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.8))
	draw_circle(Vector2.ZERO, radius, Color(color.r * 0.5, color.g * 0.3, color.b * 0.2, 0.12 * fade))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(color, 0.9 * fade), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
