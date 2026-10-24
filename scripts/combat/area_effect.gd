class_name AreaEffect
extends Hitbox
## Ataque en área alrededor del usuario: onda expansiva que golpea a todo lo que alcanza.

const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")
const DURATION := 0.4

var radius := 48.0
var color := Color.WHITE
var _time := 0.0
var _light: PointLight2D


func trigger(p_hit: HitInfo, at: Vector2) -> void:
	var m := p_hit.move
	setup(p_hit, false)
	global_position = at
	radius = m.radius * p_hit.area_mult
	var glow := minf(m.element.glow, 1.3)
	color = m.element.hdr(m.element.color, glow / m.element.glow)
	var shape := CircleShape2D.new()
	shape.radius = radius
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	z_index = -6
	if glow > 1.0:
		_light = PointLight2D.new()
		_light.texture = LIGHT_TEX
		_light.color = m.element.color
		_light.energy = 0.35
		_light.texture_scale = radius / 32.0
		add_child(_light)
	Events.element_impact.emit(m.element, at, radius)
	if m.crater_radius > 0.0:
		Events.ground_impact.emit(at, m.crater_radius)
	Fx.burst(get_parent(), at, color, 20, radius * 2.0)


func _physics_process(delta: float) -> void:
	_time += delta
	# Golpea solo durante el primer instante de la onda.
	if _time > 0.1 and monitoring:
		set_deferred("monitoring", false)
	if _light:
		_light.energy = 0.35 * (1.0 - _time / DURATION)
	if _time >= DURATION:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var k := clampf(_time / DURATION, 0.0, 1.0)
	var r := radius * (0.25 + 0.75 * sqrt(k))
	draw_circle(Vector2.ZERO, r, Color(color.r * 0.6, color.g * 0.6, color.b * 0.6, 0.16 * (1.0 - k)))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(color, 1.0 - k), 3.0)
	draw_arc(Vector2.ZERO, r * 0.7, 0.0, TAU, 40, Color(color, 0.5 * (1.0 - k)), 1.5)
