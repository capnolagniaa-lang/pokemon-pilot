extends Control
## Pantalla de Equipo: 6 casillas fijas (las vacías con "—"). Cada una: retrato, nombre, nivel, tipos,
## estilo, PS y EXP; marca el activo. Enter (o clic) en un Pokémon abre sus acciones: Ver ficha, Poner como
## activo, Mover arriba/abajo. Los cambios van a GameState (que emite party_changed: el mundo re-saca al
## compañero).

signal closed

const SUMMARY_SCENE := preload("res://scenes/ui/summary_screen.tscn")

## El menú de pausa (para apilar la ficha).
var menu: PauseMenu
var _grid: GridContainer
var _cards: Array[Button] = []
var _actions: PanelContainer
var _focus_index := 0
var _hint: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	var root := VBoxContainer.new()
	root.position = Vector2(40, 28)
	root.size = Vector2(1200, 660)
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	var head := HBoxContainer.new()
	root.add_child(head)
	head.add_child(UiStyle.label("EQUIPO", 26, UiStyle.ACCENT))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	_hint = UiStyle.label("", 14, UiStyle.TEXT_DIM)
	head.add_child(_hint)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 16)
	_grid.add_theme_constant_override("v_separation", 14)
	root.add_child(_grid)
	var back := UiStyle.button("Volver", 160)
	back.pressed.connect(func(): closed.emit())
	root.add_child(back)
	refresh()


func refresh() -> void:
	_close_actions()
	for c in _grid.get_children():
		c.queue_free()
	_cards.clear()
	for i in GameState.MAX_PARTY:
		var card := _card(i)
		_grid.add_child(card)
		_cards.append(card)
	_hint.text = "%d/%d · Enter: acciones · Arrastrá con el clic para cambiar de lugar · Esc: volver" % [GameState.party.size(), GameState.MAX_PARTY]
	UiStyle.focus_later(_cards[clampi(_focus_index, 0, maxi(0, GameState.party.size() - 1))])


func _card(i: int) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(592, 168)
	b.focus_mode = Control.FOCUS_ALL
	var inst: CreatureInstance = GameState.party[i] if i < GameState.party.size() else null
	if inst == null:
		b.disabled = true
		b.text = "—"
		b.add_theme_font_size_override("font_size", 28)
		return b
	var active := i == GameState.active_index
	if active:
		b.add_theme_stylebox_override("normal", UiStyle.box(Color(0.12, 0.16, 0.12, 0.96), Color(UiStyle.GOOD, 0.7), 2))
	b.pressed.connect(_open_actions.bind(i))
	b.focus_entered.connect(func(): _focus_index = i)
	# Arrastrar con el clic una tarjeta sobre otra las cambia de lugar (pedido del usuario 2026-10-26).
	b.set_drag_forwarding(func(_at): return _drag_data(i), func(_at, data): return can_drop(i, data),
		func(_at, data): drop(i, data))
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 12
	row.offset_right = -12
	row.offset_top = 10
	row.offset_bottom = -10
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)
	var view := PokemonAnimView.new()
	view.species = inst.species
	view.pixel_scale = 3
	view.custom_minimum_size = Vector2(130, 140)
	row.add_child(view)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 5)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 10)
	info.add_child(name_row)
	name_row.add_child(UiStyle.label(inst.display_name(), 20))
	name_row.add_child(UiStyle.label("Nv. %d" % inst.level, 18, UiStyle.ACCENT))
	if active:
		name_row.add_child(UiStyle.label("ACTIVO", 13, UiStyle.GOOD))
	var types := HBoxContainer.new()
	types.add_theme_constant_override("separation", 6)
	info.add_child(types)
	for t in inst.species.types:
		types.add_child(UiStyle.type_chip(t))
	if inst.ability_data() != null:
		types.add_child(UiStyle.label("  " + inst.ability_data().display_name, 14, UiStyle.TEXT_DIM))
	var ratio := inst.hp / inst.max_hp()
	info.add_child(UiStyle.label("PS %d/%d%s" % [ceili(inst.hp), ceili(inst.max_hp()), "  —  DEBILITADO" if inst.hp <= 0.0 else ""], 13,
		UiStyle.BAD if inst.hp <= 0.0 else UiStyle.TEXT))
	info.add_child(UiStyle.bar(ratio, UiStyle.hp_color(ratio), Vector2(380, 9)))
	info.add_child(UiStyle.label("EXP  (faltan %d para Nv. %d)" % [inst.exp_to_next(), inst.level + 1], 12, UiStyle.TEXT_DIM))
	info.add_child(UiStyle.bar(inst.exp_progress(), Color(0.4, 0.7, 1.0), Vector2(380, 5)))
	for c in info.get_children():
		if c is Control:
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b


## Acciones sobre un Pokémon (al lado de su casilla).
func _open_actions(i: int) -> void:
	_close_actions()
	_actions = PanelContainer.new()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_actions.add_child(box)
	var inst := GameState.party[i]
	var items := [["Ver ficha", _open_summary.bind(i), true],
		["Poner como activo", _set_active.bind(i), i != GameState.active_index and inst.hp > 0.0],
		["Mover arriba", _move.bind(i, -1), i > 0],
		["Mover abajo", _move.bind(i, 1), i < GameState.party.size() - 1],
		["Cancelar", _close_actions_and_focus, true]]
	var first: Button = null
	for it in items:
		var b := UiStyle.button(it[0], 210)
		b.disabled = not it[2]
		b.pressed.connect(it[1])
		box.add_child(b)
		if first == null and not b.disabled:
			first = b
	add_child(_actions)
	var card := _cards[i]
	_actions.position = card.global_position + Vector2(card.size.x - 240, 8)
	first.grab_focus()


func _close_actions() -> void:
	if is_instance_valid(_actions):
		_actions.queue_free()
	_actions = null


func _close_actions_and_focus() -> void:
	_close_actions()
	_cards[_focus_index].grab_focus()


## Esc: primero cierra las acciones; si no hay, vuelve al menú.
func back() -> bool:
	if is_instance_valid(_actions):
		_close_actions_and_focus()
		return false
	return true


## Datos del arrastre: el lugar de donde sale (con una vista chiquita del Pokémon).
func _drag_data(i: int):
	if i >= GameState.party.size():
		return null
	_close_actions()
	var preview := UiStyle.label("↕ " + GameState.party[i].display_name(), 22, UiStyle.ACCENT)
	set_drag_preview(preview)
	return {"party_slot": i}


func can_drop(i: int, data) -> bool:
	return data is Dictionary and data.has("party_slot") and i < GameState.party.size() and data["party_slot"] != i


func drop(i: int, data) -> void:
	if GameState.swap_in_party(int(data["party_slot"]), i):
		_focus_index = i
	refresh()


func _set_active(i: int) -> void:
	var world := get_tree().get_first_node_in_group("world")
	if world != null and world.combat.in_battle:
		world.combat.switch_to(i)  # en combate es un cambio de pelea (con su recarga)
		refresh()
		return
	if GameState.set_active(i):
		Events.message_requested.emit("¡Adelante, %s!" % GameState.active().display_name())
	refresh()


func _move(i: int, dir: int) -> void:
	if GameState.move_in_party(i, i + dir):
		_focus_index = i + dir
	refresh()


func _open_summary(i: int) -> void:
	_close_actions()
	var s: Control = SUMMARY_SCENE.instantiate()
	s.party_index = i
	menu.push(s)
