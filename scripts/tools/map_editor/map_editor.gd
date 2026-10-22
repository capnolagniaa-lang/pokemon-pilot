extends Node2D
## Editor de mapas (herramienta, no etapa del juego). Se abre con `-- --map-editor` (acceso directo
## "Pokémon Pilot — Editor de mapas") o desde el título con `-- --debug`. Pinta sobre las capas reales de
## una zona con las reglas del juego (MapDocument), guarda en res:// con backup y prueba la zona en el juego.

enum Tool { PENCIL, LINE, RECT, FILL, SELECT, PICK, MARKERS, SPAWN }

const T := ZoneBuilder.T
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
const TOP_H := 76.0
const BOTTOM_H := 60.0
const PANEL_W := 330.0
const TOOLS := [[Tool.PENCIL, "Pincel", "B"], [Tool.LINE, "Línea", "L"], [Tool.RECT, "Rect.", "R"],
	[Tool.FILL, "Balde", "G"], [Tool.SELECT, "Selec.", "M"], [Tool.PICK, "Gotero", "I"], [Tool.MARKERS, "Plaza/salidas", "H"]]
const LAYER_LABELS := ["1 Suelo (Ground)", "2 Agua (Water)", "3 Follaje (Foliage)", "4 Copas (Overhead)", "5 Objetos"]
const HELP := ["B pincel · L línea · R rectángulo (F relleno/borde) · G balde · M selección · I o Alt+clic gotero · H plaza y salidas · [ ] tamaño · 1-5 capa activa · Clic der. borra",
	"Ctrl+Z/Y deshacer/rehacer · Ctrl+C/V copiar/pegar · Supr borra la selección · Ctrl+S guardar · F5 probar en el juego · Rueda zoom · Clic medio o Espacio+arrastrar mueve · F2 grilla · F3 colisión · F4 sin tags"]
const TAB_BRUSHES := 0
const TAB_STAMPS := 1
const TAB_TILES := 2
const TAB_TILE := 3
const TAB_ZONE := 4

var world: WorldData
var roles: TileRoleSet
var tileset: TileSet
var doc: MapDocument
var tool: Tool = Tool.PENCIL
var brush: Dictionary = {}
var brush_size := 1
var rect_filled := true
var active_layer := 0
var solo_layer := false
var layer_visible := [true, true, true, true, true]
var clipboard: Dictionary = {}
var pasting := false
var hover := Vector2i(-1, -1)
var writable := true

var canvas: Node2D
var neighbors_root: Node2D
var overlay: MapOverlay
var cursor: MapCursor
var cam: Camera2D
var root: Control

var _zone_list: OptionButton
var _dirty_label: Label
var _tool_buttons: Dictionary = {}
var _size_buttons: Array[Button] = []
var _fill_button: Button
var _layer_option: OptionButton
var _layers_menu: PopupMenu
var _view_menu: PopupMenu
var _tag_menu: PopupMenu
var _tabs: TabContainer
var _brushes: MapBrushPanel
var _palette: MapTilePalette
var _stamps: MapStampPanel
var _props: MapTileProps
var _zone_panel: MapZonePanel
var _status: Label
var _toast: Label
var _toast_left := 0.0
var _banner: Label

var _stroke := 0          # 0 nada, 1 pinta, 2 borra, 3 marcador, 4 selección
var _anchor := Vector2i.ZERO
var _last_cell := Vector2i.ZERO
var _panning := false
var _prev_tool: Tool = Tool.PENCIL


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	RenderingServer.set_default_clear_color(Color(0.05, 0.06, 0.08))
	DisplayServer.window_set_title("Pokémon Pilot — Editor de mapas")
	roles = ZoneBuilder.load_roles()
	world = MapDocument.load_world_copy()
	tileset = load(ZoneBuilder.TILESET_PATH)
	canvas = Node2D.new()
	canvas.name = "Canvas"
	add_child(canvas)
	neighbors_root = Node2D.new()
	neighbors_root.name = "Neighbors"
	canvas.add_child(neighbors_root)
	overlay = MapOverlay.new()
	overlay.z_index = 100
	add_child(overlay)
	cursor = MapCursor.new()
	cursor.z_index = 101
	add_child(cursor)
	cam = Camera2D.new()
	add_child(cam)
	cam.make_current()
	_build_ui()
	writable = MapDocument.res_writable()
	_banner.visible = not writable
	open_zone(_initial_zone())


func _initial_zone() -> ZoneEntry:
	var args := OS.get_cmdline_user_args()
	var i := args.find("--zone")
	var want := args[i + 1] if i >= 0 and i + 1 < args.size() else ""
	var fallback := world.zone_at(Vector2(world.spawn_cell * world.tile_size) + Vector2.ONE)
	for z in world.zones:
		if z.id == want:
			return z
	return fallback if fallback != null else world.zones[0]


# --- Zona abierta -----------------------------------------------------------------------

func open_zone(e: ZoneEntry) -> void:
	_close_doc()
	_set_doc(MapDocument.open(world, e, roles))


func _set_doc(d: MapDocument) -> void:
	doc = d
	canvas.add_child(doc.zone)
	doc.changed.connect(_on_doc_changed)
	doc.region_changed.connect(_on_region_changed)
	overlay.doc = doc
	cursor.doc = doc
	cursor.selection = Rect2i()
	_build_neighbors()
	_apply_layer_visibility()
	_zone_panel.bind(doc)
	_zone_panel.show_issues(doc.validate())
	_refresh_zone_list()
	_fit_camera()
	_on_doc_changed()


func _close_doc() -> void:
	if doc != null:
		doc.dispose()
		doc = null


func _build_neighbors() -> void:
	for c in neighbors_root.get_children():
		c.queue_free()
	var near := doc.entry.world_rect(1).grow(1)
	for z in world.zones:
		if z == doc.entry or not z.world_rect(1).intersects(near) or not ResourceLoader.exists(z.scene_path):
			continue
		var packed: PackedScene = ResourceLoader.load(z.scene_path, "", ResourceLoader.CACHE_MODE_REPLACE)
		var n: Node2D = packed.instantiate()
		n.position = Vector2((z.origin - doc.entry.origin) * T)
		n.modulate = Color(0.8, 0.8, 0.8)
		neighbors_root.add_child(n)
	neighbors_root.visible = overlay.show_neighbors


func _on_doc_changed() -> void:
	overlay.queue_redraw()
	cursor.queue_redraw()
	_dirty_label.text = "● Sin guardar" if doc.is_dirty() else "Guardado"
	_dirty_label.add_theme_color_override("font_color", Color(1, 0.75, 0.3) if doc.is_dirty() else UiStyle.TEXT_DIM)
	_update_status()


func _on_region_changed() -> void:
	_zone_panel.refresh()
	_refresh_zone_list()


func _refresh_zone_list() -> void:
	_zone_list.clear()
	for i in world.zones.size():
		var z := world.zones[i]
		_zone_list.add_item("%s (%s)" % [z.display_name, z.id])
		if doc != null and z == doc.entry:
			_zone_list.select(i)


## Si hay cambios sin guardar, pregunta antes de seguir (guardar / descartar / cancelar).
func confirm_unsaved(then: Callable) -> void:
	if doc == null or not doc.is_dirty():
		then.call()
		return
	var d := ConfirmDialog.ask(root, "Hay cambios sin guardar en %s. ¿Guardarlos?" % doc.entry.display_name, ["Guardar", "Descartar", "Cancelar"])
	d.chosen.connect(func(i: int):
		if i == 0 and save():
			then.call()
		elif i == 1:
			_discard()
			then.call()
		else:
			_refresh_zone_list())


func _discard() -> void:
	var id := doc.entry.id
	_close_doc()
	world = MapDocument.load_world_copy()  # vuelve atrás lo que se cambió de la región
	for z in world.zones:
		if z.id == id:
			_set_doc(MapDocument.open(world, z, roles))
			return
	_set_doc(MapDocument.open(world, _initial_zone(), roles))


func _on_zone_selected(i: int) -> void:
	var id := world.zones[i].id
	if doc != null and id == doc.entry.id:
		return
	confirm_unsaved(func():
		for z in world.zones:
			if z.id == id:
				open_zone(z))


func _exit_tree() -> void:
	_close_doc()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		confirm_unsaved(func(): get_tree().quit())


func _exit_editor() -> void:
	confirm_unsaved(func():
		if "--map-editor" in OS.get_cmdline_user_args():
			get_tree().quit()
			return
		# Volviendo al título del mismo proceso: que el juego use la región y las zonas recién guardadas.
		DB.config.world = ResourceLoader.load(ZoneBuilder.WORLD_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
		get_tree().set_auto_accept_quit(true)
		get_tree().change_scene_to_file(TITLE_SCENE))


# --- Guardar, validar, probar ---------------------------------------------------------

func save() -> bool:
	if not writable:
		toast("No se puede escribir en res:// (¿el juego está exportado?). No se guardó.", true)
		return false
	var issues := doc.validate()
	_zone_panel.show_issues(issues)
	if issues.any(func(it: Dictionary) -> bool: return it["level"] == "error"):
		_tabs.current_tab = TAB_ZONE
		toast("No se guardó: hay errores que romperían el juego (ver pestaña Zona).", true)
		return false
	var err := doc.save()
	if err != OK:
		toast("Error al guardar (%s)." % error_string(err), true)
		return false
	_refresh_zone_list()
	var warns := issues.size()
	toast("Guardado %s%s." % [doc.entry.scene_path.get_file(), (" (%d avisos, ver Zona)" % warns) if warns > 0 else ""])
	_on_doc_changed()
	return true


func validate() -> void:
	var issues := doc.validate()
	_zone_panel.show_issues(issues)
	_tabs.current_tab = TAB_ZONE
	toast("Sin problemas." if issues.is_empty() else "%d problemas (ver pestaña Zona)." % issues.size(), not issues.is_empty())


## F5: guarda y abre el juego (proceso aparte) en esta zona, con el entrenador en la celda del mouse
## (o en la plaza si el mouse no está sobre una celda transitable).
func test_in_game() -> void:
	if doc.is_dirty() and not save():
		return
	var cell := hover if doc.inside(hover) and MapRules.is_walkable(doc.zone, hover) else doc.entry.hub
	var args := PackedStringArray(["--path", ProjectSettings.globalize_path("res://"), "--", "--debug",
		"--start-zone", doc.entry.id, "--start-cell", "%d,%d" % [cell.x, cell.y]])
	var pid := OS.create_process(OS.get_executable_path(), args)
	toast("Abriendo el juego en %s, celda %s…" % [doc.entry.display_name, cell] if pid > 0 else "No se pudo abrir el juego.", pid <= 0)


func _new_zone() -> void:
	var d := MapNewZoneDialog.open(root, world)
	d.created.connect(func(e: ZoneEntry, generated: bool, _link: bool):
		confirm_unsaved(func():
			_close_doc()
			world.zones.append(e)
			var nd := MapDocument.create(world, e, roles, tileset, generated)
			nd.region_dirty = true
			_set_doc(nd)
			toast("Zona nueva %s: guardala para que quede en la región." % e.display_name)))


# --- Cámara ---------------------------------------------------------------------------

func _canvas_rect() -> Rect2:
	var vp := get_viewport_rect().size
	return Rect2(0, TOP_H, vp.x - PANEL_W, vp.y - TOP_H - BOTTOM_H)


func _fit_camera() -> void:
	var view := _canvas_rect()
	var zsize := Vector2(doc.entry.size * T)
	var z := minf(view.size.x / zsize.x, view.size.y / zsize.y) * 0.94
	cam.zoom = Vector2(z, z)
	_center_on(zsize / 2.0)


## Centra la cámara en un punto (local de la zona) dentro del área del lienzo.
func _center_on(p: Vector2) -> void:
	var vp := get_viewport_rect().size
	cam.position = p - (_canvas_rect().get_center() - vp / 2.0) / cam.zoom.x


func _zoom_at(screen: Vector2, factor: float) -> void:
	var vp := get_viewport_rect().size
	var before := cam.position + (screen - vp / 2.0) / cam.zoom.x
	var z := clampf(cam.zoom.x * factor, 0.25, 8.0)
	cam.zoom = Vector2(z, z)
	cam.position = before - (screen - vp / 2.0) / z


func _mouse_cell() -> Vector2i:
	var vp := get_viewport_rect().size
	var p := cam.position + (get_viewport().get_mouse_position() - vp / 2.0) / cam.zoom.x
	return Vector2i((p / T).floor())


# --- Entrada ----------------------------------------------------------------------------

func _process(delta: float) -> void:
	if _toast_left > 0.0:
		_toast_left -= delta
		_toast.modulate.a = clampf(_toast_left / 0.5, 0.0, 1.0)


func _modal_open() -> bool:
	for c in root.get_children():
		if c is ConfirmDialog or c is MapNewZoneDialog:
			return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	if doc == null or _modal_open():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if _shortcut(event):
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		var cell := _mouse_cell()
		match mb.button_index:
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
				if mb.pressed:
					_zoom_at(mb.position, 1.15 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.15)
			MOUSE_BUTTON_MIDDLE:
				_panning = mb.pressed
			MOUSE_BUTTON_LEFT:
				if mb.pressed and Input.is_key_pressed(KEY_SPACE):
					_panning = true
				elif not mb.pressed and _panning:
					_panning = false
				elif mb.pressed and mb.alt_pressed:
					pick(cell)
				elif mb.pressed:
					_press(cell, false)
				else:
					_release(cell)
			MOUSE_BUTTON_RIGHT:
				if mb.pressed:
					_press(cell, true)
				else:
					_release(cell)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _panning:
			cam.position -= mm.relative / cam.zoom.x
			return
		var cell := _mouse_cell()
		if cell != hover:
			hover = cell
			_drag(cell)
			_update_hover()


func _shortcut(e: InputEventKey) -> bool:
	var k := e.keycode
	if e.ctrl_pressed:
		match k:
			KEY_Z:
				if e.shift_pressed:
					_redo()
				else:
					_undo()
			KEY_Y: _redo()
			KEY_S: save()
			KEY_C: _copy()
			KEY_V: _start_paste()
			_: return false
		return true
	match k:
		KEY_B: set_tool(Tool.PENCIL)
		KEY_L: set_tool(Tool.LINE)
		KEY_R: set_tool(Tool.RECT)
		KEY_G: set_tool(Tool.FILL)
		KEY_M: set_tool(Tool.SELECT)
		KEY_I: set_tool(Tool.PICK)
		KEY_H: set_tool(Tool.MARKERS)
		KEY_F:
			rect_filled = not rect_filled
			_fill_button.set_pressed_no_signal(rect_filled)
			_update_status()
		KEY_BRACKETLEFT: set_brush_size(brush_size - 1)
		KEY_BRACKETRIGHT: set_brush_size(brush_size + 1)
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5: set_active_layer(k - KEY_1)
		KEY_F5: test_in_game()
		KEY_F2: _toggle_view(0)
		KEY_F3: _toggle_view(1)
		KEY_F4: _toggle_view(2)
		KEY_DELETE:
			if cursor.selection.size != Vector2i.ZERO:
				doc.erase(_rect_cells(cursor.selection.position, cursor.selection.end - Vector2i.ONE, true), -1)
				doc.commit("Borrar selección")
		KEY_ESCAPE:
			pasting = false
			cursor.paste_rect = Rect2i()
			cursor.selection = Rect2i()
			cursor.preview.clear()
			_stroke = 0
			if tool in [Tool.MARKERS, Tool.SPAWN]:
				set_tool(Tool.PENCIL)
			cursor.queue_redraw()
		_: return false
	return true


func _undo() -> void:
	if doc.do_undo():
		toast("Deshacer: " + doc.undo.get_current_action_name() if doc.undo.get_current_action_name() != "" else "Deshecho.")
	_zone_panel.refresh()


func _redo() -> void:
	if doc.do_redo():
		toast("Rehacer: " + doc.undo.get_current_action_name())
	_zone_panel.refresh()


# --- Herramientas ---------------------------------------------------------------------

func set_tool(t: Tool) -> void:
	if t == Tool.SPAWN or t == Tool.MARKERS:
		if tool != Tool.SPAWN and tool != Tool.MARKERS:
			_prev_tool = tool
	tool = t
	for k in _tool_buttons:
		_tool_buttons[k].set_pressed_no_signal(k == t)
	cursor.preview.clear()
	cursor.show_markers = cursor.show_markers or t == Tool.MARKERS
	if t == Tool.SPAWN:
		toast("Clic en la celda donde empieza una partida nueva.")
	_update_status()
	cursor.queue_redraw()


func set_brush(b: Dictionary) -> void:
	brush = b
	_brushes.mark(b.get("key", ""))
	if b.get("kind") != "raw":
		_palette.deselect()
	if b.get("kind") != "stamp":
		_stamps.deselect()
	if tool in [Tool.PICK, Tool.SELECT, Tool.MARKERS, Tool.SPAWN]:
		set_tool(Tool.PENCIL)
	_update_status()


func set_brush_size(n: int) -> void:
	brush_size = clampi(n, 1, 3)
	for i in _size_buttons.size():
		_size_buttons[i].set_pressed_no_signal(i + 1 == brush_size)
	_update_status()


func set_active_layer(li: int) -> void:
	active_layer = clampi(li, 0, 4)
	_layer_option.select(active_layer)
	_apply_layer_visibility()
	_update_status()


func _footprint(c: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var off := (brush_size - 1) / 2
	for dy in brush_size:
		for dx in brush_size:
			out.append(c + Vector2i(dx - off, dy - off))
	return out


func _is_tree_brush() -> bool:
	return brush.get("kind") == "role" and (brush["role"] as TileRole).kind == TileRole.Kind.TREE


func _press(cell: Vector2i, erase: bool) -> void:
	if pasting:
		if not erase:
			doc.paste(clipboard, cell)
			doc.commit("Pegar")
		else:
			pasting = false
			cursor.paste_rect = Rect2i()
		return
	_anchor = cell
	_last_cell = cell
	if not erase and brush.get("kind") == "stamp" and tool in [Tool.PENCIL, Tool.LINE, Tool.RECT, Tool.FILL]:
		doc.place_stamp(brush["stamp"], cell)
		doc.commit("Sello: " + str(brush["stamp"]["name"]))
		return
	match tool:
		Tool.MARKERS:
			var m := cursor.marker_at(cell)
			if m != "":
				cursor.dragging = m
				cursor.drag_cell = doc.entry.hub if m == "hub" else doc.entry.exits[m]
				_stroke = 3
		Tool.SPAWN:
			doc.set_spawn(doc.entry.origin + cell)
			toast("Inicio del juego: celda %s del mundo." % (doc.entry.origin + cell))
			set_tool(_prev_tool)
		Tool.PICK:
			pick(cell)
		Tool.FILL:
			if erase:
				doc.erase(doc.flood(cell, _fill_layer()), -1)
			elif _is_tree_brush():
				toast("El balde no pone árboles: usá el rectángulo.", true)
				return
			else:
				apply_brush(doc.flood(cell, _fill_layer()), false)
			doc.commit("Balde")
		Tool.SELECT:
			cursor.selection = Rect2i(cell, Vector2i.ONE)
			_stroke = 4
		Tool.PENCIL:
			_stroke = 2 if erase else 1
			_paint_at(cell, erase, true)
		Tool.LINE, Tool.RECT:
			_stroke = 2 if erase else 1
			_update_preview(cell)
	cursor.queue_redraw()


func _drag(cell: Vector2i) -> void:
	match _stroke:
		1, 2:
			if tool == Tool.PENCIL:
				for c in _line(_last_cell, cell):
					_paint_at(c, _stroke == 2, false)
				_last_cell = cell
			else:
				_update_preview(cell)
		3:
			cursor.drag_cell = cell.clamp(Vector2i.ZERO, doc.entry.size - Vector2i(2, 2)) if cursor.dragging == "hub" else doc.clamp_exit(cursor.dragging, cell)
		4:
			var lo := Vector2i(mini(_anchor.x, cell.x), mini(_anchor.y, cell.y))
			var hi := Vector2i(maxi(_anchor.x, cell.x), maxi(_anchor.y, cell.y))
			cursor.selection = Rect2i(lo, hi - lo + Vector2i.ONE)
	cursor.queue_redraw()


func _release(cell: Vector2i) -> void:
	match _stroke:
		1, 2:
			var erase := _stroke == 2
			if tool == Tool.LINE or tool == Tool.RECT:
				var cells: Array[Vector2i] = []
				if _is_tree_brush() and not erase:
					cells = _tree_origins(_anchor, cell)
				elif tool == Tool.LINE:
					for c in _line(_anchor, cell):
						for f in _footprint(c):
							if not cells.has(f):
								cells.append(f)
				else:
					cells = _rect_cells(_anchor, cell, rect_filled)
				apply_brush(cells, erase)
			doc.commit("Borrar" if erase else "Pintar")
		3:
			if cursor.dragging == "hub":
				doc.set_entry_prop("hub", cursor.drag_cell, "Plaza")
			else:
				doc.set_exit(cursor.dragging, cursor.drag_cell)
			cursor.dragging = ""
			_zone_panel.refresh()
	_stroke = 0
	cursor.preview.clear()
	cursor.queue_redraw()


func _paint_at(cell: Vector2i, erase: bool, first: bool) -> void:
	if _is_tree_brush() and not erase:
		# Arrastrando no pisa árboles ya puestos (si no, se reemplazarían todo el tiempo).
		for d in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
			if not first and doc.tree_origin_at(cell + d) != MapDocument.NO_TREE:
				return
		apply_brush([cell], false)
		return
	apply_brush(_footprint(cell), erase)


## Aplica el pincel actual a las celdas (el clic derecho borra: todo lo de la celda, o la capa activa con un tile crudo).
func apply_brush(cells: Array, erase: bool) -> void:
	if erase:
		doc.erase(cells, active_layer if brush.get("kind") == "raw" else -1)
		return
	match brush.get("kind", ""):
		"role":
			doc.paint_role(cells, brush["role"])
		"object":
			for c in cells:
				doc.place_object(c, brush["path"])
		"erase":
			doc.erase(cells, active_layer if brush["layer"] == -2 else -1)
		"raw":
			if active_layer == MapDocument.OBJECTS:
				toast("Elegí una capa de tiles (1-4) para pintar un tile crudo.", true)
				return
			doc.paint_raw(cells, active_layer, brush["source"], brush["coords"])
		_:
			toast("Elegí un pincel en la pestaña Pinceles o un tile en Tiles.", true)


func _fill_layer() -> int:
	if brush.get("kind") == "role":
		return ZoneBuilder.LAYERS.find((brush["role"] as TileRole).layer)
	if brush.get("kind") == "object":
		return MapDocument.OBJECTS
	return active_layer


func _update_preview(cell: Vector2i) -> void:
	var cells: Array[Vector2i] = []
	if _is_tree_brush() and _stroke == 1:
		for o in _tree_origins(_anchor, cell):
			for d in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
				cells.append(o + d)
	elif tool == Tool.LINE:
		for c in _line(_anchor, cell):
			cells.append_array(_footprint(c))
	else:
		cells = _rect_cells(_anchor, cell, rect_filled)
	cursor.preview = cells
	cursor.preview_color = Color(1, 0.3, 0.3, 0.35) if _stroke == 2 else Color(1, 1, 1, 0.3)


## Árboles a lo largo de una línea o dentro de un rectángulo (cada 2 celdas, que entren enteros).
func _tree_origins(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if tool == Tool.LINE:
		var line := _line(a, b)
		for i in range(0, line.size(), 2):
			out.append(line[i])
		return out
	var lo := Vector2i(mini(a.x, b.x), mini(a.y, b.y))
	var hi := Vector2i(maxi(a.x, b.x), maxi(a.y, b.y))
	for y in range(lo.y, hi.y, 2):
		for x in range(lo.x, hi.x, 2):
			if rect_filled or x == lo.x or y == lo.y or x + 2 >= hi.x or y + 2 >= hi.y:
				out.append(Vector2i(x, y))
	if out.is_empty():
		out.append(lo)
	return out


static func _line(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var d := b - a
	var n := maxi(absi(d.x), absi(d.y))
	for i in n + 1:
		var t := float(i) / maxf(1.0, float(n))
		var c := Vector2i(roundi(lerpf(a.x, b.x, t)), roundi(lerpf(a.y, b.y, t)))
		if out.is_empty() or out[-1] != c:
			out.append(c)
	return out


static func _rect_cells(a: Vector2i, b: Vector2i, filled: bool) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var lo := Vector2i(mini(a.x, b.x), mini(a.y, b.y))
	var hi := Vector2i(maxi(a.x, b.x), maxi(a.y, b.y))
	for y in range(lo.y, hi.y + 1):
		for x in range(lo.x, hi.x + 1):
			if filled or x == lo.x or x == hi.x or y == lo.y or y == hi.y:
				out.append(Vector2i(x, y))
	return out


## Gotero: toma el pincel de la celda (o el tile crudo, si se está pintando con tiles).
func pick(cell: Vector2i) -> void:
	if not doc.inside(cell):
		return
	var top := -1
	for li in [MapDocument.OVERHEAD, MapDocument.FOLIAGE, MapDocument.WATER, MapDocument.GROUND]:
		if li != MapDocument.OVERHEAD and top < 0 and doc.metatile(li, cell) >= 0:
			top = li
	var raw_mode: bool = brush.get("kind") == "raw" or _tabs.current_tab == TAB_TILES
	if raw_mode:
		var li := active_layer if active_layer < MapDocument.OBJECTS and doc.layer(active_layer).get_cell_source_id(cell) >= 0 else top
		if li < 0:
			return
		var raw := doc.get_raw(li, cell)
		var m := ZoneBuilder.metatile_of(raw[0], raw[1])
		set_brush({"kind": "raw", "key": "raw:%d:%s" % [raw[0], raw[1]], "source": raw[0], "coords": raw[1], "metatile": m})
		_props.show_metatile(m)
		toast("Tile %d de %s." % [m, ZoneBuilder.LAYERS[li]])
	else:
		var obj := doc.object_at(cell)
		var b := {}
		if obj != null:
			b = _brushes.brush("object:" + obj.scene_file_path)
		else:
			var r := doc.role_at(cell)
			if r != null:
				b = _brushes.brush("role:" + r.id)
		if b.is_empty() and top >= 0:
			var raw := doc.get_raw(top, cell)
			b = {"kind": "raw", "key": "raw", "source": raw[0], "coords": raw[1], "metatile": ZoneBuilder.metatile_of(raw[0], raw[1])}
		if not b.is_empty():
			set_brush(b)
			toast("Pincel: " + _brush_name())
		if top >= 0:
			_props.show_metatile(doc.metatile(top, cell))
	if tool == Tool.PICK:
		set_tool(Tool.PENCIL)


func _copy() -> void:
	if cursor.selection.size == Vector2i.ZERO:
		toast("Primero seleccioná un rectángulo (M).", true)
		return
	clipboard = doc.copy_region(cursor.selection)
	toast("Copiado %d×%d. Ctrl+V para pegar." % [cursor.selection.size.x, cursor.selection.size.y])


func _start_paste() -> void:
	if clipboard.is_empty():
		toast("No hay nada copiado.", true)
		return
	pasting = true
	cursor.paste_rect = Rect2i(hover, clipboard["size"])
	toast("Clic para pegar · Clic der. o Esc cancela.")
	cursor.queue_redraw()


func _update_hover() -> void:
	cursor.hover = hover
	cursor.hover_inside = doc.inside(hover)
	if pasting:
		cursor.paste_rect = Rect2i(hover, clipboard["size"])
	if _stroke == 0 and brush.get("kind") == "stamp" and tool in [Tool.PENCIL, Tool.LINE, Tool.RECT, Tool.FILL]:
		cursor.preview = _stamp_footprint(brush["stamp"], hover)
		cursor.preview_color = Color(0.5, 0.85, 1.0, 0.3)
	elif _stroke == 0 and tool in [Tool.PENCIL] and doc.inside(hover):
		if _is_tree_brush():
			cursor.preview = [hover, hover + Vector2i(1, 0), hover + Vector2i(0, 1), hover + Vector2i(1, 1)]
		else:
			cursor.preview = _footprint(hover)
		cursor.preview_color = Color(1, 1, 1, 0.25)
	elif _stroke == 0:
		cursor.preview.clear()
	cursor.queue_redraw()
	_update_status()


static func _stamp_footprint(st: Dictionary, at: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var size: Vector2i = st["size"]
	var cells: PackedInt32Array = st["cells"]
	for i in cells.size():
		if cells[i] >= 0:
			out.append(at + Vector2i(i % size.x, i / size.x))
	return out


func _brush_name() -> String:
	match brush.get("kind", ""):
		"role": return (brush["role"] as TileRole).display_name
		"object": return MapIcons.object_name(brush["path"])
		"erase": return "Borrar todo" if brush["layer"] == -1 else "Borrar capa activa"
		"raw": return "Tile %d" % brush.get("metatile", -1)
		"stamp": return "Sello %s (%s)" % [brush["stamp"]["name"], brush["stamp"]["place"]]
	return "—"


func _update_status() -> void:
	if _status == null or doc == null:
		return
	var parts := []
	if doc.inside(hover):
		var r := doc.role_at(hover)
		var tags := overlay._tags(hover, MapRules.objects_by_cell(doc.zone))
		var obj := doc.object_at(hover)
		parts.append("(%d, %d)" % [hover.x, hover.y])
		parts.append(r.display_name if r != null else "tile %d" % doc.metatile(0, hover))
		if obj != null:
			parts.append(MapIcons.object_name(obj.scene_file_path))
		parts.append("tags: " + (", ".join(tags) if not tags.is_empty() else "—"))
	parts.append("Herramienta: " + _tool_name())
	parts.append("Pincel: %s ×%d" % [_brush_name(), brush_size])
	parts.append("Capa: " + LAYER_LABELS[active_layer].substr(2))
	_status.text = "   ·   ".join(parts)


func _tool_name() -> String:
	for t in TOOLS:
		if t[0] == tool:
			return t[1] + ("" if tool != Tool.RECT else (" relleno" if rect_filled else " borde"))
	return "Inicio del juego" if tool == Tool.SPAWN else "—"


func toast(text: String, bad: bool = false) -> void:
	_toast.text = text
	_toast.add_theme_color_override("font_color", Color(1, 0.6, 0.5) if bad else UiStyle.TEXT)
	_toast_left = 3.5
	_toast.modulate.a = 1.0


# --- Capas y vistas --------------------------------------------------------------------

func _apply_layer_visibility() -> void:
	if doc == null:
		return
	for li in 4:
		doc.layer(li).visible = layer_visible[li] and (not solo_layer or li == active_layer)
	var objects := doc.zone.get_node("Objects") as Node2D
	objects.visible = layer_visible[4] and (not solo_layer or active_layer == MapDocument.OBJECTS)
	(doc.zone.get_node("TreeShadows") as Node2D).visible = doc.layer(MapDocument.GROUND).visible


func _toggle_view(idx: int) -> void:
	_view_menu.toggle_item_checked(idx)
	_on_view(idx)


func _on_view(idx: int) -> void:
	var on := _view_menu.is_item_checked(idx)
	match idx:
		0: overlay.show_grid = on
		1: overlay.show_collision = on
		2: overlay.show_untagged = on
		3: cursor.show_markers = on
		4: cursor.show_spawn = on
		5:
			overlay.show_neighbors = on
			neighbors_root.visible = on
	overlay.queue_redraw()
	cursor.queue_redraw()


# --- UI ---------------------------------------------------------------------------------

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "UI"
	add_child(layer)
	root = Control.new()
	root.name = "Root"
	root.theme = UiStyle.theme()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	# Barra de arriba (2 filas)
	var top := PanelContainer.new()
	top.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.BORDER, 1, 4))
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.custom_minimum_size.y = TOP_H
	root.add_child(top)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 4)
	top.add_child(rows)
	var r1 := _row(rows)
	r1.add_child(UiStyle.label("Zona", 14, UiStyle.TEXT_DIM))
	_zone_list = OptionButton.new()
	_zone_list.focus_mode = Control.FOCUS_NONE
	_zone_list.custom_minimum_size.x = 230
	_zone_list.item_selected.connect(_on_zone_selected)
	r1.add_child(_zone_list)
	_tb(r1, "Nueva zona…", "Crear una zona en un lugar libre de la región", _new_zone)
	_tb(r1, "Guardar", "Ctrl+S · guarda la zona (con backup) y la región", func(): save())
	_tb(r1, "Probar ▶", "F5 · guarda y abre el juego en esta zona, en la celda del mouse", test_in_game)
	_tb(r1, "Validar", "Revisa salidas, caminos, inicio y pasto alto", validate)
	r1.add_child(VSeparator.new())
	_tb(r1, "↶", "Deshacer (Ctrl+Z)", _undo)
	_tb(r1, "↷", "Rehacer (Ctrl+Y)", _redo)
	r1.add_child(VSeparator.new())
	var layers_btn := MenuButton.new()
	layers_btn.text = "Capas ▾"
	layers_btn.flat = false
	_layers_menu = layers_btn.get_popup()
	for i in LAYER_LABELS.size():
		_layers_menu.add_check_item(LAYER_LABELS[i].substr(2), i)
		_layers_menu.set_item_checked(i, true)
	_layers_menu.add_separator()
	_layers_menu.add_check_item("Solo capa activa", 10)
	_layers_menu.hide_on_checkable_item_selection = false
	_layers_menu.id_pressed.connect(_on_layers_menu)
	r1.add_child(layers_btn)
	var view_btn := MenuButton.new()
	view_btn.text = "Ver ▾"
	view_btn.flat = false
	_view_menu = view_btn.get_popup()
	_view_menu.hide_on_checkable_item_selection = false
	for v in [["Grilla (F2)", true], ["Colisión: sólido rojo, agua azul (F3)", false], ["Celdas sin tags (F4)", false],
			["Plaza y salidas", true], ["Inicio del juego", true], ["Zonas vecinas", true]]:
		_view_menu.add_check_item(v[0])
		_view_menu.set_item_checked(_view_menu.item_count - 1, v[1])
	_tag_menu = PopupMenu.new()
	_tag_menu.id_pressed.connect(_on_tag_menu)
	_view_menu.add_submenu_node_item("Resaltar tag", _tag_menu)
	_view_menu.index_pressed.connect(func(i: int):
		if i < 6:
			_view_menu.toggle_item_checked(i)
			_on_view(i))
	r1.add_child(view_btn)
	_fill_tag_menu()
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r1.add_child(spacer)
	_dirty_label = UiStyle.label("", 14, UiStyle.TEXT_DIM)
	r1.add_child(_dirty_label)
	_tb(r1, "Salir", "Cerrar el editor (pregunta si hay cambios sin guardar)", _exit_editor)

	var r2 := _row(rows)
	r2.add_child(UiStyle.label("Herramienta", 14, UiStyle.TEXT_DIM))
	for t in TOOLS:
		var b := _tb(r2, t[1], "%s (%s)" % [t[1], t[2]], set_tool.bind(t[0]))
		b.toggle_mode = true
		_tool_buttons[t[0]] = b
	r2.add_child(VSeparator.new())
	r2.add_child(UiStyle.label("Tamaño", 14, UiStyle.TEXT_DIM))
	for n in 3:
		var b := _tb(r2, str(n + 1), "Tamaño del pincel ([ y ])", set_brush_size.bind(n + 1))
		b.toggle_mode = true
		b.custom_minimum_size.x = 30
		_size_buttons.append(b)
	_fill_button = _tb(r2, "Relleno", "Rectángulo relleno o solo el borde (F)", func():
		rect_filled = _fill_button.button_pressed
		_update_status())
	_fill_button.toggle_mode = true
	_fill_button.set_pressed_no_signal(true)
	r2.add_child(VSeparator.new())
	r2.add_child(UiStyle.label("Capa activa", 14, UiStyle.TEXT_DIM))
	_layer_option = OptionButton.new()
	_layer_option.focus_mode = Control.FOCUS_NONE
	for l in LAYER_LABELS:
		_layer_option.add_item(l)
	_layer_option.item_selected.connect(set_active_layer)
	r2.add_child(_layer_option)

	# Panel derecho
	_tabs = TabContainer.new()
	_tabs.anchor_left = 1.0
	_tabs.anchor_right = 1.0
	_tabs.anchor_bottom = 1.0
	_tabs.offset_left = -PANEL_W
	_tabs.offset_top = TOP_H
	_tabs.offset_bottom = -BOTTOM_H
	_tabs.focus_mode = Control.FOCUS_NONE
	root.add_child(_tabs)
	_brushes = MapBrushPanel.new()
	_brushes.name = "Pinceles"
	_tabs.add_child(_brushes)
	_brushes.setup(roles)
	_brushes.brush_selected.connect(set_brush)
	_brushes.tree_border.connect(func(side: String):
		doc.tree_border(side)
		doc.commit("Borde de árboles"))
	_stamps = MapStampPanel.new()
	_stamps.name = "Sellos"
	_tabs.add_child(_stamps)
	_stamps.setup(roles.catalog)
	_stamps.stamp_selected.connect(func(st: Dictionary):
		set_brush({"kind": "stamp", "key": "stamp", "stamp": st})
		if tool not in [Tool.PENCIL, Tool.LINE, Tool.RECT, Tool.FILL]:
			set_tool(Tool.PENCIL))
	_palette = MapTilePalette.new()
	_palette.name = "Tiles"
	_tabs.add_child(_palette)
	_palette.setup(roles)
	_palette.tile_selected.connect(func(src: int, coords: Vector2i, m: int):
		set_brush({"kind": "raw", "key": "raw", "source": src, "coords": coords, "metatile": m})
		_props.show_metatile(m))
	_props = MapTileProps.new()
	_props.name = "Tile"
	_tabs.add_child(_props)
	_props.setup(roles, tileset)
	_props.applied.connect(func(m: int):
		_palette.refresh()
		_fill_tag_menu()
		overlay.queue_redraw()
		toast("Metatile %d actualizado en el TileSet (todas las zonas)." % m))
	_zone_panel = MapZonePanel.new()
	_zone_panel.name = "Zona"
	_tabs.add_child(_zone_panel)
	_zone_panel.setup()
	_zone_panel.tool_requested.connect(func(t: String): set_tool(Tool.MARKERS if t == "markers" else Tool.SPAWN))
	_zone_panel.validate_requested.connect(validate)
	_zone_panel.new_zone_requested.connect(_new_zone)
	_zone_panel.issue_clicked.connect(func(c: Vector2i): _center_on(Vector2(c * T)))

	# Barra de abajo: estado + ayuda de atajos
	var bottom := PanelContainer.new()
	bottom.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.BORDER, 1, 3))
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -BOTTOM_H
	root.add_child(bottom)
	var bl := VBoxContainer.new()
	bl.add_theme_constant_override("separation", 0)
	bottom.add_child(bl)
	_status = UiStyle.label("", 13)
	_status.clip_text = true
	bl.add_child(_status)
	for line in HELP:
		var help := UiStyle.label(line, 12, UiStyle.TEXT_DIM)
		help.clip_text = true
		bl.add_child(help)

	_toast = UiStyle.label("", 15)
	_toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_toast.add_theme_constant_override("outline_size", 6)
	_toast.position = Vector2(16, TOP_H + 10)
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_toast)
	_banner = UiStyle.label("No se puede escribir en res:// (¿juego exportado?): el editor no va a poder guardar.", 15, UiStyle.BAD)
	_banner.position = Vector2(16, TOP_H + 36)
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_banner)

	set_tool(Tool.PENCIL)
	set_brush_size(1)
	set_brush(_brushes.brush("role:" + roles.base_role))


func _row(parent: Control) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 5)
	parent.add_child(r)
	return r


func _tb(parent: Control, text: String, tip: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.tooltip_text = tip
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, 30)
	b.add_theme_font_size_override("font_size", 14)
	b.pressed.connect(action)
	parent.add_child(b)
	return b


func _on_layers_menu(id: int) -> void:
	var idx := _layers_menu.get_item_index(id)
	_layers_menu.toggle_item_checked(idx)
	if id == 10:
		solo_layer = _layers_menu.is_item_checked(idx)
	else:
		layer_visible[id] = _layers_menu.is_item_checked(idx)
	_apply_layer_visibility()


func _fill_tag_menu() -> void:
	_tag_menu.clear()
	_tag_menu.add_radio_check_item("(ninguno)", 0)
	_tag_menu.set_item_checked(0, overlay.tag == "")
	var tags := roles.known_tags()
	for i in tags.size():
		_tag_menu.add_radio_check_item(tags[i], i + 1)
		_tag_menu.set_item_checked(i + 1, overlay.tag == tags[i])


func _on_tag_menu(id: int) -> void:
	overlay.tag = "" if id == 0 else _tag_menu.get_item_text(_tag_menu.get_item_index(id))
	for i in _tag_menu.item_count:
		_tag_menu.set_item_checked(i, _tag_menu.get_item_id(i) == id)
	overlay.queue_redraw()
