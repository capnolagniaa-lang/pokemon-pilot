extends Control
## Caja (Esc → Caja; como el PC, docs/PLAN_CAPTURA_MOCHILA.md): a la izquierda tu equipo, a la derecha lo que
## está guardado (lo que atrapaste con el equipo lleno). Enter en uno de la Caja lo pasa al equipo (si hay
## lugar); en uno del equipo lo deja en la Caja (nunca el último). Más adelante se ata a los Centros Pokémon.

signal closed

const COLUMNS := 4

var _party_list: VBoxContainer
var _grid: GridContainer
var _status: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	var root := VBoxContainer.new()
	root.position = Vector2(40, 28)
	root.size = Vector2(1200, 660)
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	root.add_child(UiStyle.label("CAJA", 26, UiStyle.ACCENT))
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 6)
	body.add_child(left)
	left.add_child(UiStyle.label("Equipo (Enter: dejar en la Caja)", 15, UiStyle.TEXT_DIM))
	_party_list = VBoxContainer.new()
	_party_list.add_theme_constant_override("separation", 6)
	left.add_child(_party_list)
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 6)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	right.add_child(UiStyle.label("Caja (Enter: pasar al equipo)", 15, UiStyle.TEXT_DIM))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(700, 540)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_grid)
	var foot := HBoxContainer.new()
	root.add_child(foot)
	_status = UiStyle.label("Esc: volver", 14, UiStyle.TEXT_DIM)
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(_status)
	var back := UiStyle.button("Volver", 140)
	back.pressed.connect(func(): closed.emit())
	foot.add_child(back)
	refresh()


func refresh() -> void:
	for c in _party_list.get_children() + _grid.get_children():
		c.queue_free()
	var first: Button = null
	for i in GameState.party.size():
		var b := _mon_button(GameState.party[i], Vector2(380, 64))
		b.pressed.connect(_to_box.bind(i))
		b.disabled = GameState.party.size() <= 1
		_party_list.add_child(b)
		if first == null:
			first = b
	if GameState.box.is_empty():
		_grid.add_child(UiStyle.label("Vacía. Lo que atrapes con el equipo lleno viene acá.", 15, UiStyle.TEXT_DIM))
	for i in GameState.box.size():
		var b := _mon_button(GameState.box[i], Vector2(168, 64))
		b.pressed.connect(_to_party.bind(i))
		_grid.add_child(b)
	if first != null:
		UiStyle.focus_later(first)


func _mon_button(inst: CreatureInstance, size: Vector2) -> Button:
	var b := Button.new()
	b.custom_minimum_size = size
	b.focus_mode = Control.FOCUS_ALL
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.icon = DB.idle_frame_of(inst.species)
	b.expand_icon = false
	b.text = "%s  Nv. %d" % [inst.display_name(), inst.level]
	return b


func _to_box(i: int) -> void:
	var inst := GameState.party[i]
	_status.text = ("%s quedó en la Caja." % inst.display_name()) if GameState.party_to_box(i) else "Tiene que quedar al menos uno en el equipo."
	refresh()


func _to_party(i: int) -> void:
	var inst := GameState.box[i]
	_status.text = ("%s se sumó al equipo." % inst.display_name()) if GameState.box_to_party(i) else "El equipo está lleno (6)."
	refresh()
