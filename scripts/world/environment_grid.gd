class_name EnvironmentGrid
extends Node2D
## Estado dinámico por celda de una zona (entorno reactivo, Etapa 3): qué celdas están ardiendo, quemadas,
## mojadas, congeladas o electrificadas, cuánto les falta y su dibujo (llamas, hollín, charcos, hielo,
## chispas). Lo crea y lo maneja ReactionSystem; vive dentro de la zona, así se va con ella al descargarla.

const TILE := 16
const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")

## celda -> {"state": EnvCellState, "left": float, "prev": EnvCellState, "fx": Node2D}
var cells: Dictionary = {}
var zone: Zone
var system: Node
## Celdas de agua congeladas: celda -> [source_id, atlas_coords, alternative] para restaurar el tile.
var _frozen_water: Dictionary = {}
var _time := 0.0
var _ground: Node2D


func setup(p_zone: Zone, p_system: Node) -> void:
	zone = p_zone
	system = p_system
	name = "EnvironmentGrid"
	z_index = 2  # las llamas, por encima de lo que está parado en la celda
	_ground = Node2D.new()
	_ground.z_index = -6  # hollín, charcos y hielo: sobre el suelo y el agua, debajo de todo lo demás
	_ground.z_as_relative = false
	_ground.draw.connect(_draw_ground)
	add_child(_ground)


func state_at(cell: Vector2i) -> EnvCellState:
	return cells[cell]["state"] if cells.has(cell) else null


func cell_center(cell: Vector2i) -> Vector2:
	return zone.to_global(zone.ground.map_to_local(cell))


## Tags de la celda con el estado aplicado (el pasto quemado ya no es inflamable, etc.).
func tags_of(cell: Vector2i) -> PackedStringArray:
	var tags := zone.get_tags(cell)
	if _frozen_water.has(cell):
		tags.append_array(PackedStringArray(["agua", "congelable"]))
	var st := state_at(cell)
	if st != null:
		var out := PackedStringArray()
		for t in tags:
			if not st.removes_tags.has(t):
				out.append(t)
		out.append_array(st.adds_tags)
		return out
	return tags


func set_state(cell: Vector2i, st: EnvCellState) -> void:
	var prev: EnvCellState = state_at(cell)
	_clear_fx(cell)
	if st == null:
		cells.erase(cell)
		_thaw(cell)
	else:
		cells[cell] = {"state": st, "left": st.duration if st.duration > 0.0 else INF,
			"prev": prev if st.restore_previous else null, "fx": _make_fx(cell, st)}
		if st.walkable_water:
			_freeze(cell)
		elif prev != null and prev.walkable_water:
			_thaw(cell)
	_ground.queue_redraw()


func _physics_process(delta: float) -> void:
	_time += delta
	var expired: Array = []
	for cell in cells:
		var e: Dictionary = cells[cell]
		var st: EnvCellState = e["state"]
		e["left"] -= delta
		if e["left"] <= 0.0:
			expired.append(cell)
		elif st.spread_element != null and st.spread_chance > 0.0:
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if randf() < st.spread_chance * delta:
					system.apply_element_cell(self, cell + d, st.spread_element)
	for cell in expired:
		if not cells.has(cell):
			continue
		var e: Dictionary = cells[cell]
		var st: EnvCellState = e["state"]
		if st.walkable_water and _occupied(cell):
			e["left"] = 0.5  # no se derrite con alguien parado encima
			continue
		var nxt: EnvCellState = e["prev"] if st.restore_previous else system.state_by_id(st.next_state)
		set_state(cell, nxt)
	if not cells.is_empty():
		queue_redraw()
		_ground.queue_redraw()


func _occupied(cell: Vector2i) -> bool:
	var c := cell_center(cell)
	for n in get_tree().get_nodes_in_group("creatures") + get_tree().get_nodes_in_group("trainer"):
		if n is Node2D and n.global_position.distance_to(c) < 12.0:
			return true
	return false


# --- Agua congelada (puente de hielo) --------------------------------------------------------

func _freeze(cell: Vector2i) -> void:
	var w: TileMapLayer = zone.water
	if _frozen_water.has(cell) or w.get_cell_source_id(cell) < 0:
		return
	_frozen_water[cell] = [w.get_cell_source_id(cell), w.get_cell_atlas_coords(cell), w.get_cell_alternative_tile(cell)]
	w.erase_cell(cell)  # sin el tile de agua no hay colisión: se puede caminar encima


func _thaw(cell: Vector2i) -> void:
	if not _frozen_water.has(cell):
		return
	var t: Array = _frozen_water[cell]
	zone.water.set_cell(cell, t[0], t[1], t[2])
	_frozen_water.erase(cell)


# --- Visual ---------------------------------------------------------------------------------

func _make_fx(cell: Vector2i, st: EnvCellState) -> Node2D:
	if st.look != EnvCellState.Look.FIRE:
		return null
	var p := CPUParticles2D.new()
	p.position = to_local(cell_center(cell)) + Vector2(0, 4)
	p.amount = 7
	p.lifetime = 0.55
	p.texture = StatusEffects._flame_texture()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(6, 3)
	p.direction = Vector2.UP
	p.spread = 18.0
	p.gravity = Vector2(0, -50)
	p.initial_velocity_min = 4.0
	p.initial_velocity_max = 14.0
	p.scale_amount_min = 1.3
	p.scale_amount_max = 2.4
	var ramp := Gradient.new()
	# Rojizo, no amarillo (pedido del usuario): sin valores HDR altos que el glow vuelve blancos.
	ramp.set_color(0, Color(0.8, 0.28, 0.08, 0.9))
	ramp.add_point(0.45, Color(0.7, 0.14, 0.04, 0.8))
	ramp.set_color(1, Color(0.25, 0.05, 0.02, 0.0))
	p.color_ramp = ramp
	add_child(p)
	if (cell.x + cell.y) % 3 == 0:  # pocas luces y suaves (si no, el suelo se satura a amarillo)
		var l := PointLight2D.new()
		l.texture = LIGHT_TEX
		l.color = Color(1.0, 0.45, 0.2)
		l.energy = 0.15
		l.texture_scale = 0.6
		p.add_child(l)
	return p


func _clear_fx(cell: Vector2i) -> void:
	if cells.has(cell) and is_instance_valid(cells[cell]["fx"]):
		var fx: CPUParticles2D = cells[cell]["fx"]
		fx.emitting = false
		get_tree().create_timer(0.6).timeout.connect(fx.queue_free)


func _draw_ground() -> void:
	for cell in cells:
		var st: EnvCellState = cells[cell]["state"]
		var r := Rect2(_ground.to_local(cell_center(cell)) - Vector2(TILE, TILE) / 2.0, Vector2(TILE, TILE))
		var k: float = clampf(cells[cell]["left"] / 0.6, 0.0, 1.0)  # se desvanece al terminar
		var seed := float((cell.x * 73 + cell.y * 31) % 17)
		match st.look:
			EnvCellState.Look.FIRE:
				_ground.draw_rect(r, Color(0.16, 0.08, 0.05, 0.55))
				_ground.draw_rect(r.grow(-3), Color(1.0, 0.35, 0.1, 0.22 + 0.08 * sin(_time * 9.0 + seed)))
			EnvCellState.Look.SCORCH:
				_ground.draw_rect(r, Color(0.12, 0.1, 0.08, 0.62 * k))
				_ground.draw_circle(r.get_center() + Vector2(seed * 0.3 - 2.5, 1), 2.5, Color(0.05, 0.04, 0.04, 0.5 * k))
			EnvCellState.Look.WET:
				_ground.draw_rect(r, Color(0.25, 0.45, 0.8, 0.28 * k))
				_ground.draw_line(r.position + Vector2(3, 5 + seed * 0.3), r.position + Vector2(9, 5 + seed * 0.3), Color(0.8, 0.9, 1.0, 0.45 * k), 1.0)
			EnvCellState.Look.ICE:
				_ground.draw_rect(r, Color(0.72, 0.9, 1.0, 0.85 * k))
				_ground.draw_rect(r, Color(1.0, 1.1, 1.25, 0.6 * k), false, 1.0)
				_ground.draw_line(r.position + Vector2(3, 4), r.position + Vector2(8, 4), Color(1.4, 1.5, 1.6, 0.9 * k), 1.0)
				_ground.draw_line(r.position + Vector2(10, 10), r.position + Vector2(13, 7), Color(1.2, 1.3, 1.5, 0.7 * k), 1.0)
			EnvCellState.Look.CRATER:
				# Pozo redondo: borde de tierra removida, fondo oscuro y piedritas (las celdas vecinas se funden en un
				# cráter). Se desvanece al final.
				var c0 := r.get_center() + Vector2(seed * 0.2 - 1.7, seed * 0.15 - 1.2)
				_ground.draw_circle(c0, 10.5, Color(0.42, 0.33, 0.24, 0.45 * k))
				_ground.draw_circle(c0 + Vector2(0, 1), 7.5, Color(0.2, 0.15, 0.1, 0.62 * k))
				_ground.draw_arc(c0, 9.0, PI * 1.1, PI * 1.9, 10, Color(0.62, 0.52, 0.4, 0.55 * k), 1.5)
				_ground.draw_circle(c0 + Vector2(6, -6 + seed * 0.3), 1.6, Color(0.55, 0.47, 0.38, 0.8 * k))
				_ground.draw_circle(c0 + Vector2(-7, 4), 1.2, Color(0.55, 0.47, 0.38, 0.7 * k))
			EnvCellState.Look.SPARK:
				_ground.draw_rect(r, Color(1.0, 0.9, 0.3, 0.18))
				var a := r.position + Vector2(2, 8 + sin(_time * 30.0 + seed) * 4.0)
				var b := r.get_center() + Vector2(0, cos(_time * 27.0 + seed) * 5.0)
				var c := r.end - Vector2(2, 8 + sin(_time * 33.0 + seed) * 4.0)
				_ground.draw_polyline(PackedVector2Array([a, b, c]), Color(1.6, 1.5, 0.6, 0.9), 1.0)
