class_name Projectile
extends Hitbox
## Proyectil de un ataque: vuela, choca con paredes (capa 1), con la hurtbox enemiga o con un proyectil enemigo (`clash`).
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
## Cuerpo con sprite (DB.vfx_for); sin él se dibuja con círculos.
var _vfx: VfxSprite


## Balance (2026-10-28, batería IA contra IA): los disparos pegaban la mitad de las veces que los golpes. Van más rápido
## (mismo alcance: dura menos) y su zona de impacto es un poco más grande que el dibujo.
const SPEED_MULT := 1.25
const HIT_PAD := 2.0
## Choque de proyectiles (pedido del usuario 2026-11-07): gana el más fuerte, con potencia × efectividad de tipos. Si la
## diferencia es menor a CLASH_TIE se destruyen los dos; si no, el otro desaparece y el que gana sigue con menos daño (nunca
## menos de CLASH_MIN_LEFT). Desde CLASH_RING_POWER de potencia el choque es el grande (con anillo). Dos de distintos
## Pokémon del mismo bando se destruyen los dos, sin importar la potencia (decisión del usuario). Los del mismo Pokémon no
## chocan: un abanico se destruiría solo al salir.
const CLASH_TIE := 1.25
const CLASH_MIN_LEFT := 0.25
const CLASH_RING_POWER := 60.0
## Lo que le queda de fuerza después de ganar un choque.
var clash_left := 1.0


func launch(p_hit: HitInfo, from: Vector2, dir: Vector2) -> void:
	var m := p_hit.move
	var el := m.element
	setup(p_hit, true)
	global_position = from
	velocity = dir.normalized() * m.speed * SPEED_MULT
	life = m.lifetime / SPEED_MULT
	radius = m.size
	color = el.hdr(el.color)
	core = el.hdr(el.core_color, 0.9)
	var shape := CircleShape2D.new()
	shape.radius = radius + HIT_PAD
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
	var frames := DB.vfx_for(m)
	if frames != null:
		_vfx = VfxSprite.attach(self, frames, velocity.angle())
	hit_landed.connect(func(_h): _impact())
	body_entered.connect(func(_b): _impact())
	NightLight.apply(self)  # día y noche: no se oscurece con la noche y su luz crece (docs/PLAN_DIA_NOCHE.md)

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_time += delta
	global_position += velocity * delta
	if _vfx != null:
		_vfx.rotation = velocity.angle()  # sigue la dirección aunque lo desvíe el viento
	if hit.move.deflects_projectiles:
		Projectile.deflect_around(get_parent(), hit.team, global_position, radius + 4.0)
	_try_clash()
	if _dead:
		return
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


func _try_clash() -> void:
	for p in get_parent().get_children():
		if p is Projectile and p != self and not p._dead and p.hit != null and p.hit.attacker != hit.attacker \
				and p.global_position.distance_squared_to(global_position) <= pow(p.radius + radius, 2.0):
			Projectile.clash(self, p)
			if _dead:
				return


## Fuerza contra ese otro proyectil. Los que no tienen potencia (los que solo dejan un estado) cuentan 1: pierden siempre.
func clash_strength(other: Projectile) -> float:
	var m := hit.move
	var other_type: Array[ElementType] = [other.hit.move.element]
	var eff: float = DB.type_chart.get_multiplier(m.element, other_type) if DB.type_chart != null else 1.0
	return maxf(m.power * m.power_mult * TacticalMind.hits_of(m) * eff * clash_left, 1.0)


static func clash(a: Projectile, b: Projectile) -> void:
	var sa := a.clash_strength(b)
	var sb := b.clash_strength(a)
	var at: Vector2 = a.global_position.lerp(b.global_position, 0.5)
	var axis: Vector2 = (b.global_position - a.global_position).normalized()
	if axis == Vector2.ZERO:
		axis = a.velocity.normalized()
	var top := maxf(a.hit.move.power * a.hit.move.power_mult, b.hit.move.power * b.hit.move.power_mult)
	Events.projectiles_clashed.emit(a.get_parent(), at, a.hit.move.element, b.hit.move.element, axis, top >= CLASH_RING_POWER)
	if a.hit.team == b.hit.team or maxf(sa, sb) / minf(sa, sb) < CLASH_TIE:
		a._impact()
		b._impact()
	elif sa > sb:
		a._won_clash(sb / sa)
		b._impact()
	else:
		b._won_clash(sa / sb)
		a._impact()


func _won_clash(lost: float) -> void:
	var left := maxf(1.0 - lost, CLASH_MIN_LEFT)
	clash_left *= left
	hit = hit.copy()  # (los otros disparos del mismo ataque no pierden nada)
	hit.damage_mult *= left


func _impact() -> void:
	if _dead:
		return
	_dead = true
	Events.element_impact.emit(hit.move.element, global_position, radius * 2.0)
	if hit.move.crater_radius > 0.0:
		Events.ground_impact.emit(global_position, hit.move.crater_radius, HitInfo.source_key(hit), hit.move.crater_max)
	Fx.burst(get_parent(), global_position, color, 10, 60.0)
	queue_free()


func _draw() -> void:
	var pulse := 1.0 + 0.15 * sin(_time * 30.0)
	var base := hit.move.element.color if hit != null else color
	draw_circle(Vector2.ZERO, radius * 1.8 * pulse, Color(base, 0.22))
	if _vfx != null:
		return  # el halo queda debajo del sprite (el glow lo sigue haciendo brillar)
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
