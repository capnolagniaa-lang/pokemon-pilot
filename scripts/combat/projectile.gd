class_name Projectile
extends Hitbox
## Proyectil de un ataque: vuela, choca con paredes (capa 1) o con la hurtbox enemiga.

const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")

var velocity := Vector2.ZERO
var life := 1.0
var radius := 4.0
var color := Color.WHITE
var _time := 0.0
var _dead := false


func launch(p_hit: HitInfo, from: Vector2, dir: Vector2) -> void:
	var m := p_hit.move
	setup(p_hit, true)
	global_position = from
	velocity = dir.normalized() * m.speed
	life = m.lifetime
	radius = m.size
	var glow := m.element.glow
	color = Color(m.element.color.r * glow, m.element.color.g * glow, m.element.color.b * glow)
	var shape := CircleShape2D.new()
	shape.radius = radius
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	z_index = 3
	if glow > 1.2:
		var light := PointLight2D.new()
		light.texture = LIGHT_TEX
		light.color = m.element.color
		light.energy = 0.9
		light.texture_scale = 1.6
		add_child(light)
	add_child(_trail())
	hit_landed.connect(func(_h): _impact())
	body_entered.connect(func(_b): _impact())


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_time += delta
	global_position += velocity * delta
	if _time >= life:
		_impact()
	queue_redraw()


func _impact() -> void:
	if _dead:
		return
	_dead = true
	Events.element_impact.emit(hit.move.element, global_position, radius * 2.0)
	Fx.burst(get_parent(), global_position, color, 10, 60.0)
	queue_free()


func _draw() -> void:
	var pulse := 1.0 + 0.15 * sin(_time * 30.0)
	draw_circle(Vector2.ZERO, radius * 1.9 * pulse, Color(color, 0.25))
	draw_circle(Vector2.ZERO, radius * pulse, color)
	draw_circle(Vector2.ZERO, radius * 0.45, Color(2.0, 2.0, 2.0))


func _trail() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = 14
	p.lifetime = 0.3
	p.local_coords = false
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 8.0
	p.spread = 180.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.5
	var ramp := Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color, 0.0))
	p.color_ramp = ramp
	return p
