class_name MapBrushPanel
extends ScrollContainer
## Pestaña "Pinceles" del editor de mapas: pinceles semánticos (salen de los roles de tile_roles.tres),
## árboles y borde de árboles, objetos (todo lo de scenes/world/objects) y borrar.
## Un pincel es un diccionario: {"kind": "role"|"object"|"erase"|"raw", "key": String, ...}.

signal brush_selected(brush: Dictionary)
signal tree_border(side: String)

var _group := ButtonGroup.new()
var _buttons: Dictionary = {}  # key -> Button
var _brushes: Dictionary = {}  # key -> pincel
var _box: VBoxContainer


func setup(roles: TileRoleSet) -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_box = VBoxContainer.new()
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_theme_constant_override("separation", 6)
	add_child(_box)
	_section("Terreno (con las reglas del juego)")
	var grid := _grid()
	var tree: TileRole = null
	for r in roles.roles:
		if not r.brush:
			continue
		if r.kind == TileRole.Kind.TREE:
			tree = r
			continue
		_add(grid, {"kind": "role", "key": "role:" + r.id, "role": r}, r.display_name, MapIcons.role(r), r.color)
	if tree != null:
		_section("Árboles")
		var tg := _grid()
		_add(tg, {"kind": "role", "key": "role:" + tree.id, "role": tree}, tree.display_name + " (2x2)", MapIcons.role(tree), tree.color)
		var row := HBoxContainer.new()
		row.add_child(UiStyle.label("Borde:", 13, UiStyle.TEXT_DIM))
		for side in [["up", "↑"], ["down", "↓"], ["left", "←"], ["right", "→"]]:
			var b := _small(side[1], "Hilera doble de árboles sobre ese lado de la zona")
			b.pressed.connect(func(): tree_border.emit(side[0]))
			row.add_child(b)
		_box.add_child(row)
	_section("Objetos")
	var og := _grid()
	for path in MapDocument.object_scenes():
		_add(og, {"kind": "object", "key": "object:" + path, "path": path}, MapIcons.object_name(path), MapIcons.object(path), Color.WHITE)
	_section("Borrar")
	var eg := _grid()
	_add(eg, {"kind": "erase", "key": "erase:all", "layer": -1}, "Todo (deja pasto)", null, UiStyle.BAD)
	_add(eg, {"kind": "erase", "key": "erase:layer", "layer": -2}, "Solo capa activa", null, UiStyle.BAD)
	var tip := UiStyle.label("Clic izq. pinta · Clic der. borra todo lo de la celda · Alt+clic toma el pincel de la celda.", 12, UiStyle.TEXT_DIM)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size.x = 260
	_box.add_child(tip)


func _section(text: String) -> void:
	_box.add_child(UiStyle.label(text, 14, UiStyle.ACCENT))


func _grid() -> GridContainer:
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 4)
	g.add_theme_constant_override("v_separation", 4)
	_box.add_child(g)
	return g


func _add(parent: Control, brush: Dictionary, text: String, icon: Texture2D, color: Color) -> void:
	var b := Button.new()
	b.text = text
	b.icon = icon
	b.expand_icon = false
	b.toggle_mode = true
	b.button_group = _group
	b.focus_mode = Control.FOCUS_NONE
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(134, 34)
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("icon_normal_color", Color.WHITE)
	b.add_theme_stylebox_override("normal", UiStyle.box(UiStyle.BG_SOFT, Color(color, 0.55), 1, 4))
	b.tooltip_text = text
	b.pressed.connect(func(): brush_selected.emit(brush))
	parent.add_child(b)
	_buttons[brush["key"]] = b
	_brushes[brush["key"]] = brush


func _small(text: String, tip: String) -> Button:
	var b := Button.new()
	b.text = text
	b.tooltip_text = tip
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(34, 30)
	return b


func brush(key: String) -> Dictionary:
	return _brushes.get(key, {})


## Marca el botón del pincel (por ejemplo después del gotero). Un pincel crudo no tiene botón acá.
func mark(key: String) -> void:
	if _buttons.has(key):
		_buttons[key].set_pressed_no_signal(true)
	else:
		var pressed := _group.get_pressed_button()
		if pressed != null:
			pressed.set_pressed_no_signal(false)
