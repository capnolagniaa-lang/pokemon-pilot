class_name ArenaDecor
extends Node2D
## Ambientación de una arena (ArenaData), encima de sus tiles: líneas de la cancha con el círculo del centro (como
## en el anime), emblema del tipo en el medio, braseros con fuego en las esquinas, rayos de luz que entran desde
## arriba y partículas que flotan (polvo de roca, hojas...). Lo pone TrainerBattle al entrar y se va con la arena.

const T := 16
const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")

var data: ArenaData
var _time := 0.0
var _rect: Rect2  # la cancha en px locales de la arena


func setup(p_data: ArenaData) -> void:
	data = p_data
	z_index = -6  # sobre el suelo, debajo de las criaturas
	_rect = Rect2(Vector2(data.field.position * T), Vector2(data.field.size * T))
	if data.particles != "":
		_add_particles()
	if data.braziers:
		for corner in [_rect.position, Vector2(_rect.end.x, _rect.position.y), Vector2(_rect.position.x, _rect.end.y), _rect.end]:
			_add_brazier(corner)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var c := data.line_color
	var r := _rect.grow(-4)
	# Cancha: borde, línea del medio, círculo central y los puntos de salida.
	draw_rect(r, c, false, 2.0)
	var mid := r.position.y + r.size.y / 2.0
	draw_line(Vector2(r.position.x, mid), Vector2(r.end.x, mid), c, 2.0)
	var center := Vector2(r.position.x + r.size.x / 2.0, mid)
	var rad := minf(r.size.x, r.size.y) * 0.18
	draw_arc(center, rad, 0.0, TAU, 48, c, 2.0)
	draw_arc(center, rad * 0.35, 0.0, TAU, 32, c, 1.5)
	for cell in [data.foe_mon_cell, data.player_mon_cell]:
		draw_arc(Vector2(cell * T) + Vector2(T / 2.0, T / 2.0), 10.0, 0.0, TAU, 24, Color(c.r, c.g, c.b, c.a * 0.8), 1.5)
	if data.epic:
		if data.element_id == "":
			_draw_pokeball(center, rad * 0.8)
		else:
			_draw_emblem(center, rad * 0.9)
		_draw_rays()
	if data.crowd:
		_draw_crowd()


## Emblema del estadio (sin tipo): una Poké Ball pintada en el centro de la cancha.
func _draw_pokeball(center: Vector2, size: float) -> void:
	draw_circle(center, size, Color(0.9, 0.2, 0.2, 0.1))
	draw_arc(center, size, 0.0, TAU, 48, Color(1, 1, 1, 0.45), 2.0)
	draw_line(center - Vector2(size, 0), center + Vector2(size, 0), Color(1, 1, 1, 0.45), 2.0)
	draw_circle(center, size * 0.25, Color(1, 1, 1, 0.3))
	draw_arc(center, size * 0.25, 0.0, TAU, 24, Color(1, 1, 1, 0.5), 2.0)


## Público en las tribunas: filas de cabecitas de colores sobre la pared de arriba y la de abajo, que saltan
## cuando hay pelea (más rápido cuanto más tiempo pasa).
func _draw_crowd() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var cols := [Color(0.95, 0.35, 0.3), Color(0.35, 0.6, 0.95), Color(0.95, 0.85, 0.35), Color(0.45, 0.85, 0.45),
		Color(0.85, 0.5, 0.9), Color(0.95, 0.6, 0.3), Color(0.9, 0.9, 0.9)]
	var left := 2.0 * T
	var right := _rect.end.x + (_rect.position.x - left)
	for band in [[0.6 * T, 2.6 * T], [_rect.end.y + 5.2 * T, _rect.end.y + 6.6 * T]]:
		var y: float = band[0]
		while y < band[1]:
			var x := left + rng.randf() * 6.0
			while x < right:
				var hop := maxf(0.0, sin(_time * 7.0 + x * 0.3 + y)) * 2.5
				var c: Color = cols[rng.randi() % cols.size()]
				draw_circle(Vector2(x, y - hop), 3.2, c.darkened(0.15))
				draw_circle(Vector2(x, y - hop - 4.0), 2.4, Color(0.98, 0.85, 0.7))
				x += 9.0 + rng.randf() * 3.0
			y += 9.0


## Emblema del tipo del gimnasio en el centro de la cancha (roca: la Medalla Roca, un octógono de piedra).
func _draw_emblem(center: Vector2, size: float) -> void:
	var pts := PackedVector2Array()
	for i in 8:
		pts.append(center + Vector2.from_angle(TAU * i / 8.0 + TAU / 16.0) * size)
	var el: ElementType = DB.types.get(data.element_id)
	var col: Color = el.color if el != null else Color(0.7, 0.6, 0.5)
	draw_colored_polygon(pts, Color(col.r, col.g, col.b, 0.16))
	pts.append(pts[0])
	draw_polyline(pts, Color(col.r * 1.2, col.g * 1.2, col.b * 1.2, 0.45), 2.0)
	var inner := PackedVector2Array()
	for i in 8:
		inner.append(center + Vector2.from_angle(TAU * i / 8.0 + TAU / 16.0) * size * 0.55)
	inner.append(inner[0])
	draw_polyline(inner, Color(col.r, col.g, col.b, 0.35), 1.5)


## Rayos de luz que entran desde arriba en diagonal y respiran despacio.
func _draw_rays() -> void:
	var top := _rect.position.y - 4.0 * T
	for i in 4:
		var x := _rect.position.x + _rect.size.x * (0.15 + 0.23 * i)
		var a := 0.05 + 0.03 * sin(_time * 0.7 + i * 1.7)
		var w := 22.0 + 8.0 * (i % 3)
		var pts := PackedVector2Array([Vector2(x, top), Vector2(x + w, top),
			Vector2(x + w + 90.0, _rect.end.y), Vector2(x + 50.0, _rect.end.y)])
		draw_colored_polygon(pts, Color(1.0, 0.95, 0.8, a))


func _add_particles() -> void:
	var p := CPUParticles2D.new()
	p.amount = 60 if data.particles == "polvo" else 26
	p.lifetime = 6.0
	p.preprocess = 6.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.position = _rect.get_center()
	p.emission_rect_extents = _rect.size / 2.0 + Vector2(40, 40)
	p.direction = Vector2(1, 0.3) if data.particles == "hojas" else (Vector2(0, 1) if data.particles == "confeti" else Vector2(0.4, -1))
	if data.particles == "confeti":  # papelitos de colores que caen girando
		p.amount = 70
		p.hue_variation_min = -1.0
		p.hue_variation_max = 1.0
		p.color = Color(1.0, 0.4, 0.4)
	p.spread = 40.0
	p.gravity = Vector2(0, 6) if data.particles == "hojas" else Vector2(0, -2)
	p.initial_velocity_min = 4.0
	p.initial_velocity_max = 14.0
	p.angular_velocity_min = -90.0
	p.angular_velocity_max = 90.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.6 if data.particles == "polvo" else 3.0
	var ramp := Gradient.new()
	var c := data.particle_color if data.particles != "confeti" else Color(1, 1, 1, 0.85)
	ramp.set_color(0, Color(c.r, c.g, c.b, 0.0))
	ramp.add_point(0.25, c)
	ramp.add_point(0.75, c)
	ramp.set_color(1, Color(c.r, c.g, c.b, 0.0))
	p.color_ramp = ramp
	p.z_index = 30  # por encima de todo (flota en el aire)
	add_child(p)


## Brasero de piedra con fuego y luz (energía baja: las luces saturan el suelo claro).
func _add_brazier(at: Vector2) -> void:
	var b := Node2D.new()
	b.position = at
	b.z_index = 8
	add_child(b)
	var base := Polygon2D.new()
	base.polygon = PackedVector2Array([Vector2(-7, 0), Vector2(7, 0), Vector2(5, -10), Vector2(-5, -10)])
	base.color = Color(0.32, 0.28, 0.25)
	b.add_child(base)
	var rim := Polygon2D.new()
	rim.polygon = PackedVector2Array([Vector2(-8, -10), Vector2(8, -10), Vector2(8, -13), Vector2(-8, -13)])
	rim.color = Color(0.45, 0.4, 0.35)
	b.add_child(rim)
	var fire := CPUParticles2D.new()
	fire.position = Vector2(0, -14)
	fire.amount = 22
	fire.lifetime = 0.6
	fire.texture = StatusEffects._flame_texture()
	fire.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fire.emission_rect_extents = Vector2(5, 1)
	fire.direction = Vector2.UP
	fire.spread = 18.0
	fire.gravity = Vector2(0, -40)
	fire.initial_velocity_min = 8.0
	fire.initial_velocity_max = 22.0
	fire.scale_amount_min = 1.2
	fire.scale_amount_max = 2.4
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.55, 0.15, 0.95))
	ramp.add_point(0.5, Color(0.85, 0.22, 0.06, 0.8))
	ramp.set_color(1, Color(0.3, 0.06, 0.02, 0.0))
	fire.color_ramp = ramp
	b.add_child(fire)
	var light := PointLight2D.new()
	light.texture = LIGHT_TEX
	light.color = Color(1.0, 0.55, 0.25)
	light.energy = 0.3
	light.texture_scale = 1.4
	light.position = Vector2(0, -14)
	b.add_child(light)
	var tw := light.create_tween().set_loops()
	tw.tween_property(light, "energy", 0.18, 0.11)
	tw.tween_property(light, "energy", 0.32, 0.16)
