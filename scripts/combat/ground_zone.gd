class_name GroundZone
extends Node2D
## Zona en el suelo que no atrapa (estilo control): parche de esporas que, cada `zone_tick`, aplica su golpe
## (daño de la zona + statuses_on_hit, ej. ralentizar y envenenar) a los enemigos que están adentro; o nube
## que duerme (`dwell_status`) a quien se quede adentro `dwell_time` segundos seguidos (Somnífero).

var hit: HitInfo
var radius := 20.0
var duration := 5.0
var tick := 0.5
var dwell_time := 0.0
var dwell_status: StatusEffect
var color := Color.WHITE
var _time := 0.0
var _tick_left := 0.0
var _inside: Dictionary = {}  # criatura -> segundos seguidos adentro
var _expiring := false
var _spores: CPUParticles2D


func place(p_hit: HitInfo, center: Vector2) -> void:
	hit = p_hit
	var m := p_hit.move
	global_position = center
	radius = m.zone_radius * p_hit.area_mult
	duration = m.zone_duration
	tick = m.zone_tick
	dwell_time = m.dwell_time
	dwell_status = m.dwell_status
	color = m.element.color
	z_index = -5
	_spores = CPUParticles2D.new()
	_spores.amount = int(clampf(radius * 0.8, 8.0, 40.0))
	_spores.lifetime = 1.4
	_spores.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_spores.emission_sphere_radius = radius * 0.85
	_spores.direction = Vector2.UP
	_spores.spread = 60.0
	_spores.gravity = Vector2(0, -6)
	_spores.initial_velocity_min = 2.0
	_spores.initial_velocity_max = 6.0
	_spores.scale_amount_min = 1.0
	_spores.scale_amount_max = 1.8
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color.r, color.g, color.b, 0.0))
	ramp.add_point(0.3, Color(color.r * 1.2, color.g * 1.2, color.b * 1.2, 0.9))
	ramp.set_color(1, Color(color.r, color.g, color.b, 0.0))
	_spores.color_ramp = ramp
	_spores.z_index = 4
	add_child(_spores)
	Events.element_impact.emit(m.element, center, radius)


## Se va antes de tiempo (ej. al pasarse del máximo de zonas de ese ataque).
func expire() -> void:
	if _expiring:
		return
	_expiring = true
	duration = minf(duration, _time + 0.3)


func _physics_process(delta: float) -> void:
	_time += delta
	_tick_left -= delta
	var do_tick := _tick_left <= 0.0
	if do_tick:
		_tick_left = tick
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.team == hit.team or c.is_down():
			continue
		if c.global_position.distance_to(global_position) > radius:
			_inside.erase(c)
			continue
		_inside[c] = _inside.get(c, 0.0) + delta
		if dwell_status != null and dwell_time > 0.0 and _inside[c] >= dwell_time:
			c.statuses.apply(dwell_status)
			_inside[c] = -INF  # ya lo durmió: no repetir mientras siga adentro
		if do_tick and (hit.move.power > 0.0 or not hit.move.statuses_on_hit.is_empty()):
			hit.origin = global_position
			c.hurtbox.receive(hit)
	if _time >= duration:
		queue_free()
	if _time >= duration - 0.4:
		_spores.emitting = false
	queue_redraw()


func _draw() -> void:
	var fade := clampf((duration - _time) / 0.4, 0.0, 1.0) * clampf(_time / 0.2, 0.0, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.75))
	draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, 0.3 * fade))
	draw_circle(Vector2.ZERO, radius * 0.6, Color(color.r, color.g, color.b, 0.18 * fade))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(color.r * 1.3, color.g * 1.3, color.b * 1.3, 0.85 * fade), 1.5)
	if dwell_time > 0.0:
		# Nube telegrafiada: muestra cuánto le falta a cada uno para dormirse.
		for c in _inside:
			if is_instance_valid(c) and _inside[c] > 0.0:
				var k: float = clampf(_inside[c] / dwell_time, 0.0, 1.0)
				var p: Vector2 = c.global_position - global_position
				draw_arc(Vector2(p.x, p.y / 0.75), 9.0, -PI / 2.0, -PI / 2.0 + TAU * k, 16, Color(0.85, 0.85, 1.4, 0.9 * fade), 1.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
