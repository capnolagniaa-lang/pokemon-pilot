class_name TownMapScreen
extends Control
## Mapa (Esc → Mapa; pedido del usuario 2026-10-25): la región en miniatura (TownMap) con los nombres de ciudades y
## rutas, tu posición, la estrella del objetivo de la Guía, los íconos de Centro / Tienda / Gimnasio y niebla sobre
## lo que todavía no visitaste. Rueda o +/-: zoom; arrastrar o WASD/flechas: mover; Espacio: centrar en vos.

signal closed

const VIEW_SIZE := Vector2(1170, 540)
const FOG := Color(0.05, 0.07, 0.1, 0.98)
const ZOOM_MIN := 0.15
const ZOOM_MAX := 3.0
const PAN_SPEED := 700.0
const ICON_COLORS := {"C": Color(0.9, 0.3, 0.3), "T": Color(0.3, 0.55, 0.95), "G": Color(0.95, 0.75, 0.25)}

var wd: WorldData
var view: Control
var zoom := 0.6
## Centro de la vista, en píxeles de la imagen del mapa.
var cam := Vector2.ZERO
var _tex: ImageTexture
var _ents: Dictionary
var _places: Array
var _icons: Array
var _player := Vector2i(-1, -1)
var _goal := Vector2i(-1, -1)
var _hover: Label
var _time := 0.0
var _dragging := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	wd = DB.config.world
	_ents = TownMap.entrances(wd)
	_places = TownMap.places(wd, _ents)
	_icons = TownMap.icons(wd, _ents)
	_tex = ImageTexture.create_from_image(TownMap.image(wd))
	var world := get_tree().get_first_node_in_group("world")
	if world != null and is_instance_valid(world.get("trainer")):
		_player = TownMap.map_cell(wd, world.trainer.global_position, _ents)
		var here := wd.zone_at(world.trainer.global_position)
		if here != null:
			GameState.visit_zone(here.id)
	var step := StoryGuide.current()
	if step.get("goal", "") != "":
		_goal = TownMap.zone_cell(wd, step["goal"], _ents)
	_build()
	center_on_player()


func _build() -> void:
	add_child(UiStyle.dim())
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.ACCENT.darkened(0.3), 2, 14))
	panel.position = Vector2(40, 24)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 18)
	box.add_child(head)
	head.add_child(UiStyle.label("MAPA", 24, UiStyle.ACCENT))
	_hover = UiStyle.label(_place_name(_player), 18)
	head.add_child(_hover)
	view = Control.new()
	view.custom_minimum_size = VIEW_SIZE
	view.clip_contents = true
	view.mouse_filter = Control.MOUSE_FILTER_STOP
	view.draw.connect(_draw_map)
	view.gui_input.connect(_on_view_input)
	box.add_child(view)
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 16)
	box.add_child(foot)
	foot.add_child(UiStyle.label("●  Vos     ★  Objetivo de la Guía     C Centro   T Tienda   G Gimnasio", 14, UiStyle.TEXT_DIM))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(spacer)
	foot.add_child(UiStyle.label("Rueda/+−: zoom · Arrastrar/WASD: mover · Espacio: vos", 14, UiStyle.TEXT_DIM))
	var back := UiStyle.button("Volver", 140)
	back.pressed.connect(func(): closed.emit())
	foot.add_child(back)


# --- Cámara -----------------------------------------------------------------------------

## Píxel de la imagen del mapa del centro de una celda del mundo.
func cell_to_image(cell: Vector2i) -> Vector2:
	return Vector2((cell - TownMap.origin()) * TownMap.CELL_PX) + Vector2.ONE * TownMap.CELL_PX / 2.0


func image_to_view(p: Vector2) -> Vector2:
	return (p - cam) * zoom + VIEW_SIZE / 2.0


func view_to_image(p: Vector2) -> Vector2:
	return (p - VIEW_SIZE / 2.0) / zoom + cam


func center_on_player() -> void:
	if _player.x >= 0:
		cam = cell_to_image(_player)
	else:
		cam = Vector2(_tex.get_size()) / 2.0
	_clamp()


func set_zoom(z: float, around: Vector2 = VIEW_SIZE / 2.0) -> void:
	var before := view_to_image(around)
	zoom = clampf(z, ZOOM_MIN, ZOOM_MAX)
	cam += before - view_to_image(around)
	_clamp()


func _clamp() -> void:
	cam = cam.clamp(Vector2.ZERO, Vector2(_tex.get_size()))
	if view != null:
		view.queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	var dir := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	if dir != Vector2.ZERO:
		cam += dir * PAN_SPEED * delta / zoom
		_clamp()
	view.queue_redraw()  # el punto de tu posición late


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey and event.pressed):
		return
	match event.physical_keycode:
		KEY_EQUAL, KEY_KP_ADD, KEY_PLUS:
			set_zoom(zoom * 1.25)
		KEY_MINUS, KEY_KP_SUBTRACT:
			set_zoom(zoom / 1.25)
		KEY_SPACE:
			center_on_player()
		_:
			return
	get_viewport().set_input_as_handled()


func _on_view_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			set_zoom(zoom * 1.15, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			set_zoom(zoom / 1.15, event.position)
		elif event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			_dragging = event.pressed
	elif event is InputEventMouseMotion:
		if _dragging:
			cam -= event.relative / zoom
			_clamp()
		var cell := Vector2i((view_to_image(event.position) / TownMap.CELL_PX).floor()) + TownMap.origin()
		_hover.text = _place_name(cell)


## Nombre del lugar de una celda del mundo (si ya lo visitaste; si no, "???").
func _place_name(cell: Vector2i) -> String:
	var id := TownMap.map_zone_at(wd, cell)
	if id == "":
		return ""
	for z in wd.zones:
		if z.id == id:
			return z.display_name if visited(id) else "???"
	return ""


func visited(zone_id: String) -> bool:
	return GameState.visited_zones.has(zone_id)


# --- Dibujo -----------------------------------------------------------------------------

func _draw_map() -> void:
	view.draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(0.04, 0.05, 0.08))
	var tl := image_to_view(Vector2.ZERO)
	view.draw_texture_rect(_tex, Rect2(tl, Vector2(_tex.get_size()) * zoom), false)
	var font := get_theme_default_font()
	# Niebla sobre lo no visitado.
	for z in TownMap.map_zones(wd):
		if not visited(z.id):
			var r := Rect2(image_to_view(cell_to_image(z.origin) - Vector2.ONE * TownMap.CELL_PX / 2.0),
				Vector2(z.size * TownMap.CELL_PX) * zoom)
			view.draw_rect(r, FOG)
	# Íconos (Centro, Tienda, Gimnasio) de las zonas visitadas.
	for ic in _icons:
		if not visited(TownMap.map_zone_at(wd, ic["cell"])):
			continue
		var p := image_to_view(cell_to_image(ic["cell"]))
		var rad := clampf(7.0 * zoom / 0.6, 5.0, 11.0)
		view.draw_circle(p, rad + 1.5, Color(0, 0, 0, 0.7))
		view.draw_circle(p, rad, ICON_COLORS[ic["letter"]])
		var fs := int(rad * 1.4)
		var w := font.get_string_size(ic["letter"], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		view.draw_string(font, p + Vector2(-w / 2.0, fs * 0.36), ic["letter"], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	# Nombres: ciudades grandes, rutas chicas, y los lugares de fuera del mapa (bosque, cuevas, barco).
	for z in TownMap.map_zones(wd):
		if visited(z.id):
			var city := z.id.begins_with("ciudad_") or z.id.begins_with("pueblo_")
			_label(font, z.display_name, image_to_view(cell_to_image(z.origin + z.size / 2)), 18 if city else 13,
				UiStyle.TEXT if city else Color(0.85, 0.9, 0.95))
	for pl in _places:
		if visited(pl["zone"]):
			_label(font, pl["name"], image_to_view(cell_to_image(pl["cell"])) + Vector2(0, -14), 13, Color(0.75, 0.95, 0.75))
	# Objetivo de la Guía.
	if _goal.x >= 0:
		_star(image_to_view(cell_to_image(_goal)), 11.0 + sin(_time * 4.0) * 1.5)
	# Vos.
	if _player.x >= 0:
		var p := image_to_view(cell_to_image(_player))
		var pulse := 0.5 + 0.5 * sin(_time * 6.0)
		view.draw_circle(p, 10.0 + pulse * 4.0, Color(1, 0.3, 0.3, 0.25 * (1.0 - pulse)))
		view.draw_circle(p, 7.0, Color.WHITE)
		view.draw_circle(p, 5.0, Color(0.9, 0.2, 0.25))


func _label(font: Font, text: String, at: Vector2, size: int, color: Color) -> void:
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var pos := at + Vector2(-w / 2.0, size * 0.35)
	view.draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 5, Color(0, 0, 0, 0.85))
	view.draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _star(at: Vector2, r: float) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2.0 + i * PI / 5.0
		pts.append(at + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * 0.45))
	var outline := PackedVector2Array()
	for p in pts:
		outline.append(at + (p - at) * 1.25)
	view.draw_colored_polygon(outline, Color(0, 0, 0, 0.75))
	view.draw_colored_polygon(pts, UiStyle.ACCENT)
