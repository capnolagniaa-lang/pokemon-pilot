class_name MapZonePanel
extends ScrollContainer
## Pestaña "Zona": datos de la zona en la región (nombre, bioma), plaza y salidas, inicio del juego,
## validaciones y crear una zona nueva.

signal tool_requested(tool: String)
signal validate_requested
signal new_zone_requested
signal issue_clicked(cell: Vector2i)

const SIDES := [["up", "Arriba"], ["down", "Abajo"], ["left", "Izquierda"], ["right", "Derecha"]]

var doc: MapDocument
var _box: VBoxContainer
var _info: Label
var _name: LineEdit
var _biome: OptionButton
var _exits: Dictionary = {}  # lado -> CheckBox
var _spawn: Label
var _issues: ItemList
var _issue_cells: Array[Vector2i] = []


func setup() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_box = VBoxContainer.new()
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_theme_constant_override("separation", 6)
	add_child(_box)
	_info = UiStyle.label("", 12, UiStyle.TEXT_DIM)
	_box.add_child(_info)
	_box.add_child(UiStyle.label("Nombre", 13, UiStyle.TEXT_DIM))
	_name = LineEdit.new()
	_name.text_submitted.connect(func(_t): _commit_name())
	_name.focus_exited.connect(_commit_name)
	_box.add_child(_name)
	_box.add_child(UiStyle.label("Bioma (generador y salvajes)", 13, UiStyle.TEXT_DIM))
	_biome = OptionButton.new()
	_biome.focus_mode = Control.FOCUS_NONE
	for b in ZoneGenerator.BIOMES:
		_biome.add_item(b)
	_biome.item_selected.connect(func(i: int): doc.set_entry_prop("biome", _biome.get_item_text(i), "Bioma"))
	_box.add_child(_biome)
	_box.add_child(UiStyle.label("Plaza (H) y salidas", 14, UiStyle.ACCENT))
	var markers := _button("Mover plaza y salidas (H)", "Arrastrá los marcadores sobre el mapa")
	markers.pressed.connect(func(): tool_requested.emit("markers"))
	var grid := GridContainer.new()
	grid.columns = 2
	for s in SIDES:
		var cb := CheckBox.new()
		cb.text = "Salida " + s[1].to_lower()
		cb.focus_mode = Control.FOCUS_NONE
		cb.toggled.connect(_toggle_exit.bind(s[0]))
		grid.add_child(cb)
		_exits[s[0]] = cb
	_box.add_child(grid)
	_box.add_child(UiStyle.label("Inicio del juego", 14, UiStyle.ACCENT))
	_spawn = UiStyle.label("", 12, UiStyle.TEXT_DIM)
	_spawn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_spawn.custom_minimum_size.x = 260
	_box.add_child(_spawn)
	var spawn := _button("Elegir inicio (clic en el mapa)", "Celda donde empieza una partida nueva")
	spawn.pressed.connect(func(): tool_requested.emit("spawn"))
	_box.add_child(UiStyle.label("Validaciones", 14, UiStyle.ACCENT))
	var val := _button("Validar zona", "También se valida al guardar")
	val.pressed.connect(func(): validate_requested.emit())
	_issues = ItemList.new()
	_issues.custom_minimum_size = Vector2(0, 150)
	_issues.focus_mode = Control.FOCUS_NONE
	_issues.item_selected.connect(func(i: int):
		if _issue_cells[i].x >= 0:
			issue_clicked.emit(_issue_cells[i]))
	_box.add_child(_issues)
	var nz := _button("Nueva zona…", "Crea una zona en un lugar libre de la región")
	nz.pressed.connect(func(): new_zone_requested.emit())


func _button(text: String, tip: String) -> Button:
	var b := UiStyle.button(text, 260)
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size.y = 32
	b.tooltip_text = tip
	_box.add_child(b)
	return b


func bind(p_doc: MapDocument) -> void:
	doc = p_doc
	refresh()


func refresh() -> void:
	if doc == null:
		return
	var e := doc.entry
	_info.text = "id: %s · origen: %s · tamaño: %d×%d" % [e.id, e.origin, e.size.x, e.size.y]
	if not _name.has_focus():
		_name.text = e.display_name
	for i in _biome.item_count:
		if _biome.get_item_text(i) == e.biome:
			_biome.select(i)
	for side in _exits:
		_exits[side].set_pressed_no_signal(e.exits.has(side))
	var sz := doc.world.zone_at(Vector2(doc.world.spawn_cell * doc.world.tile_size) + Vector2.ONE)
	_spawn.text = "Celda %s del mundo (%s)." % [doc.world.spawn_cell, sz.display_name if sz != null else "fuera de las zonas"]


func _commit_name() -> void:
	if doc != null and _name.text.strip_edges() != "" and _name.text != doc.entry.display_name:
		doc.set_entry_prop("display_name", _name.text.strip_edges(), "Nombre de la zona")


func _toggle_exit(on: bool, side: String) -> void:
	if on:
		var mid := Vector2i(doc.entry.size.x / 2 - 2, doc.entry.size.y / 2 - 2)
		doc.set_exit(side, mid)
	else:
		doc.remove_exit(side)


func show_issues(issues: Array[Dictionary]) -> void:
	_issues.clear()
	_issue_cells.clear()
	if issues.is_empty():
		_issues.add_item("✔ Sin problemas")
		_issue_cells.append(Vector2i(-1, -1))
		return
	for it in issues:
		var idx := _issues.add_item(("✖ " if it["level"] == "error" else "⚠ ") + it["msg"])
		_issues.set_item_custom_fg_color(idx, UiStyle.BAD if it["level"] == "error" else Color(1, 0.8, 0.4))
		_issues.set_item_tooltip(idx, it["msg"])
		_issue_cells.append(it["cell"])
