class_name Projectile
extends Hitbox
## Proyectil de un ataque: vuela, choca con paredes (capa 1) o con la hurtbox enemiga.
## Colores del ElementType: halo y cuerpo con `color`, centro con `core_color` (el fuego es rojizo, no blanco).

const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")

var velocity := Vector2.ZERO
var life := 1.0
var radius := 4.0
var color := Color.WHITE
var core := Color.WHITE
## Ya lo desvió el viento (no se vuelve a desviar).
var deflected := false
var _time := 0.0
var _dead := false


func launch(p_hit: HitInfo, from: Vector2, dir: Vector2) -> void:
	var m := p_hit.move
	var el := m.element
	setup(p_hit, true)
	global_position = from
	velocity = dir.normalized() * m.speed
	life = m.lifetime
	radius = m.size
	color = el.hdr(el.color)
	core = el.hdr(el.core_color, 0.9)
	var shape := CircleShape2D.new()
	shape.radius = radius
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	z_index = 3
	if el.glow > 1.15:
		var light := PointLight2D.new()
		light.texture = LIGHT_TEX
		light.color = el.color
		light.energy = 0.3
		light.texture_scale = 0.75
		add_child(light)
	add_child(_trail())
	hit_landed.connect(func(_h): _impact())
	body_entered.connect(func(_b): _impact())


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_time += delta
	global_position += velocity * delta
	if hit.move.deflects_projectiles:
		Projectile.deflect_around(get_parent(), hit.team, global_position, radius + 4.0)
	if _time >= life:
		_impact()
	queue_redraw()


## Viento (Tornado, Remolino): los proyectiles del otro equipo dentro del radio salen despedidos hacia
## afuera del centro (siguen siendo del otro equipo, así que ya no lastiman a nadie del lado del viento).
static func deflect_around(parent: Node, team: int, center: Vector2, p_radius: float) -> void:
	for p in parent.get_children():
		if p is Projectile and not p._dead and p.hit != null and p.hit.team != team and not p.deflected \
				and p.global_position.distance_to(center) <= p_radius + p.radius:
			var away: Vector2 = p.global_position - center
			if away.length() < 0.5:
				away = -p.velocity
			p.velocity = away.normalized() * p.velocity.length()
			p.deflected = true
			Fx.burst(parent, p.global_position, Color(0.85, 0.9, 1.2), 6, 40.0)


func _impact() -> void:
	if _dead:
		return
	_dead = true
	Events.element_impact.emit(hit.move.element, global_position, radius * 2.0)
	Fx.burst(get_parent(), global_position, color, 10, 60.0)
	queue_free()


func _draw() -> void:
	var pulse := 1.0 + 0.15 * sin(_time * 30.0)
	var base := hit.move.element.color if hit != null else color
	draw_circle(Vector2.ZERO, radius * 1.8 * pulse, Color(base, 0.22))
	draw_circle(Vector2.ZERO, radius * pulse, color)
	draw_circle(Vector2.ZERO, radius * 0.5, core)


func _trail() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = 16
	p.lifetime = 0.3
	p.local_coords = false
	p.gravity = Vector2(0, -15)
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 8.0
	p.spread = 180.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.5
	var ramp := Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color.r * 0.4, color.g * 0.2, color.b * 0.2, 0.0))
	p.color_ramp = ramp
	return p
