class_name MapNewZoneDialog
extends Control
## Diálogo "Nueva zona" del editor de mapas: id, nombre, bioma, tamaño y lugar libre en la región
## (grilla de 48×32 pegada a las zonas que ya existen). Arranca en pasto o generada con el bioma.

signal created(entry: ZoneEntry, generated: bool, link: bool)

const GRID := Vector2i(48, 32)

var world: WorldData
var _id: LineEdit
var _name: LineEdit
var _biome: OptionButton
var _slot: OptionButton
var _w: SpinBox
var _h: SpinBox
var _generate: CheckBox
var _connect: CheckBox
var _error: Label
var _slots: Array[Vector2i] = []


static func open(parent: Node, p_world: WorldData) -> MapNewZoneDialog:
	var d := MapNewZoneDialog.new()
	d.world = p_world
	d.theme = UiStyle.theme()
	d.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(d)
	d._build()
	return d


## Lugares libres de la grilla de la región (celdas de zona) pegados a alguna zona existente.
static func free_slots(p_world: WorldData, size: Vector2i = GRID) -> Array[Vector2i]:
	var taken := {}
	for z in p_world.zones:
		taken[Vector2i(floori(z.origin.x / float(GRID.x)), floori(z.origin.y / float(GRID.y)))] = true
	var out: Array[Vector2i] = []
	for t: Vector2i in taken:
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var s: Vector2i = t + d
			if taken.has(s) or out.has(s):
				continue
			var r := Rect2(Vector2(s * GRID), Vector2(size))
			if not p_world.zones.any(func(z: ZoneEntry) -> bool: return z.world_rect(1).intersects(r)):
				out.append(s)
	out.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return out


## Arma la ZoneEntry nueva. Con `link`, agrega salidas hacia las vecinas (y la de vuelta en cada vecina).
static func make_entry(p_world: WorldData, id: String, display_name: String, biome: String, origin: Vector2i, size: Vector2i, link: bool) -> ZoneEntry:
	var e := ZoneEntry.new()
	e.id = id
	e.display_name = display_name
	e.biome = biome
	e.origin = origin
	e.size = size
	e.scene_path = "%s/%s.tscn" % [ZoneBuilder.ZONES_DIR, id]
	e.hub = Vector2i(size.x / 4 * 2 - 2, size.y / 4 * 2 - 2)
	if link:
		for side in MapRules.SIDE_DIR:
			var other := MapRules.neighbor(p_world, e, side)
			if other == null:
				continue
			var mine := Vector2i(size.x / 4 * 2 - 2, 0)
			match side:
				"down": mine = Vector2i(size.x / 4 * 2 - 2, size.y - 2)
				"left": mine = Vector2i(0, size.y / 4 * 2 - 2)
				"right": mine = Vector2i(size.x - 2, size.y / 4 * 2 - 2)
			var theirs := origin + mine - other.origin
			match side:
				"up": theirs.y = other.size.y - 2
				"down": theirs.y = 0
				"left": theirs.x = other.size.x - 2
				"right": theirs.x = 0
			e.exits[side] = mine
			var ex: Dictionary = other.exits.duplicate()
			ex[MapRules.OPPOSITE[side]] = theirs.clamp(Vector2i.ZERO, other.size - Vector2i(2, 2))
			other.exits = ex
	return e


func _build() -> void:
	add_child(UiStyle.dim())
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(UiStyle.label("Nueva zona", 20, UiStyle.ACCENT))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	box.add_child(grid)
	_id = _field(grid, "Id (archivo)", "zona_nueva")
	_name = _field(grid, "Nombre", "Zona nueva")
	grid.add_child(UiStyle.label("Bioma", 14))
	_biome = OptionButton.new()
	for b in ZoneGenerator.BIOMES:
		_biome.add_item(b)
	grid.add_child(_biome)
	grid.add_child(UiStyle.label("Lugar", 14))
	_slot = OptionButton.new()
	_slots = free_slots(world)
	for s in _slots:
		_slot.add_item("Columna %d, fila %d%s" % [s.x, s.y, _beside(s)])
	grid.add_child(_slot)
	grid.add_child(UiStyle.label("Tamaño", 14))
	var size_row := HBoxContainer.new()
	_w = _spin(GRID.x)
	_h = _spin(GRID.y)
	size_row.add_child(_w)
	size_row.add_child(UiStyle.label("×", 14))
	size_row.add_child(_h)
	grid.add_child(size_row)
	_generate = CheckBox.new()
	_generate.text = "Generar con el bioma (si no, todo pasto)"
	_generate.button_pressed = true
	box.add_child(_generate)
	_connect = CheckBox.new()
	_connect.text = "Salidas hacia las vecinas (después abrí el camino en ellas)"
	_connect.button_pressed = true
	box.add_child(_connect)
	_error = UiStyle.label("", 13, UiStyle.BAD)
	_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error.custom_minimum_size.x = 400
	box.add_child(_error)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var ok := UiStyle.button("Crear", 140)
	ok.pressed.connect(_create)
	row.add_child(ok)
	var cancel := UiStyle.button("Cancelar", 140)
	cancel.pressed.connect(queue_free)
	row.add_child(cancel)
	box.add_child(row)
	_id.grab_focus.call_deferred()


func _field(grid: GridContainer, label: String, value: String) -> LineEdit:
	grid.add_child(UiStyle.label(label, 14))
	var l := LineEdit.new()
	l.text = value
	l.custom_minimum_size.x = 260
	grid.add_child(l)
	return l


func _spin(v: int) -> SpinBox:
	var s := SpinBox.new()
	s.min_value = 16
	s.max_value = 128
	s.step = 2
	s.value = v
	return s


func _beside(slot: Vector2i) -> String:
	for d in [[Vector2i.RIGHT, "a la izquierda de"], [Vector2i.LEFT, "a la derecha de"], [Vector2i.DOWN, "arriba de"], [Vector2i.UP, "abajo de"]]:
		var o: Vector2i = (slot + d[0]) * GRID
		for z in world.zones:
			if z.origin == o:
				return " (%s %s)" % [d[1], z.display_name]
	return ""


func _create() -> void:
	var id := _id.text.strip_edges().to_snake_case()
	if id == "" or not id.is_valid_identifier():
		_error.text = "El id tiene que ser una palabra sin espacios ni acentos (ej.: ruta_2)."
		return
	if world.zones.any(func(z: ZoneEntry) -> bool: return z.id == id) or ResourceLoader.exists("%s/%s.tscn" % [ZoneBuilder.ZONES_DIR, id]):
		_error.text = "Ya existe una zona con ese id."
		return
	if _slots.is_empty():
		_error.text = "No hay lugares libres pegados a la región."
		return
	var size := Vector2i(int(_w.value), int(_h.value))
	var origin := _slots[_slot.selected] * GRID
	var r := Rect2(Vector2(origin), Vector2(size))
	for z in world.zones:
		if z.world_rect(1).intersects(r):
			_error.text = "Con ese tamaño se encima con %s." % z.display_name
			return
	var e := make_entry(world, id, _name.text.strip_edges(), _biome.get_item_text(_biome.selected), origin, size, _connect.button_pressed)
	created.emit(e, _generate.button_pressed, _connect.button_pressed)
	queue_free()
