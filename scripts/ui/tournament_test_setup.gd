extends Control
## Modo de prueba del torneo (pedido del usuario 2026-10-23; docs/PLAN_TORNEO.md): desde el título, elegís hasta 6
## Pokémon (los que tienen kit: los implementados), el nivel y la copa, y se juega el Torneo de Plateada directo, sin
## historia. **No se guarda nada** (GameState.test_tournament: SaveManager no deja guardar). Al terminar podés
## repetir o volver al título.

const WORLD_SCENE := "res://scenes/world/world.tscn"
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"

var _picked: Array[SpeciesData] = []
var _buttons: Dictionary = {}  # SpeciesData -> Button
var _level: SpinBox
var _cup := 0
var _cup_buttons: Array[Button] = []
var _status: Label
var _cups: Array[TournamentCup] = []
var _scroll: ScrollContainer


func _ready() -> void:
	theme = UiStyle.theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.09, 0.13)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	for f in DirAccess.get_files_at("res://data/tournament"):
		var c = load("res://data/tournament/" + f.trim_suffix(".remap"))
		if c is TournamentCup:
			_cups.append(c)
	_cups.sort_custom(func(a, b): return a.order < b.order)
	var root := VBoxContainer.new()
	root.position = Vector2(40, 24)
	root.size = Vector2(1200, 680)
	root.add_theme_constant_override("separation", 10)
	add_child(root)
	root.add_child(UiStyle.label("PROBAR EL TORNEO (modo de prueba: no se guarda)", 24, UiStyle.ACCENT))
	root.add_child(UiStyle.label("Elegí de 1 a 6 Pokémon (los que ya tienen su estilo de pelea), el nivel y la copa.", 15, UiStyle.TEXT_DIM))
	# Con las evoluciones hay muchos Pokémon con kit: la grilla va en un recuadro con scroll (rueda o barra) y el nivel,
	# la copa y "Empezar" quedan siempre a la vista.
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(1200, 430)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(grid)
	_scroll = scroll
	var kits: Array = DB.species_by_dex().filter(func(sp): return sp.dex <= 151)  # (antes: los que tenían kit)
	for sp: SpeciesData in kits:
		var b := Button.new()
		b.toggle_mode = true
		b.icon = DB.portrait_of(sp)
		b.expand_icon = true
		b.text = sp.display_name
		b.custom_minimum_size = Vector2(140, 64)
		b.toggled.connect(_toggle.bind(sp))
		grid.add_child(b)
		_buttons[sp] = b
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	root.add_child(row)
	row.add_child(UiStyle.label("Nivel:", 18))
	_level = SpinBox.new()
	_level.min_value = 2
	_level.max_value = 100
	_level.value = 15
	row.add_child(_level)
	var cups_row := HBoxContainer.new()
	cups_row.add_theme_constant_override("separation", 6)
	root.add_child(cups_row)
	for i in _cups.size():
		var cb := UiStyle.button(_cups[i].display_name, 190)
		cb.toggle_mode = true
		cb.pressed.connect(_pick_cup.bind(i))
		cups_row.add_child(cb)
		_cup_buttons.append(cb)
	_pick_cup(0)
	_status = UiStyle.label("", 15, UiStyle.TEXT)
	root.add_child(_status)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	root.add_child(actions)
	var go := UiStyle.button("Empezar el torneo", 260)
	go.pressed.connect(_start)
	actions.add_child(go)
	var back := UiStyle.button("Volver", 160)
	back.pressed.connect(func(): get_tree().change_scene_to_file(TITLE_SCENE))
	actions.add_child(back)
	_refresh()


func _toggle(on: bool, sp: SpeciesData) -> void:
	if on and _picked.size() >= 6:
		_buttons[sp].set_pressed_no_signal(false)
		return
	if on:
		_picked.append(sp)
	else:
		_picked.erase(sp)
	_refresh()


func _pick_cup(i: int) -> void:
	_cup = i
	for k in _cup_buttons.size():
		_cup_buttons[k].set_pressed_no_signal(k == i)
	var cap := _cups[i].level_cap
	if cap > 0 and _level.value > cap:
		_level.value = cap
	_refresh()


func _refresh() -> void:
	if _status == null:
		return
	var cup := _cups[_cup]
	_status.text = "Equipo (%d/6): %s  ·  %s: se inscriben %d%s." % [_picked.size(),
		", ".join(_picked.map(func(s): return s.display_name)) if not _picked.is_empty() else "—",
		cup.display_name, cup.team_size, " (Nv. %d o menos)" % cup.level_cap if cup.level_cap > 0 else ""]


func _start() -> void:
	var cup := _cups[_cup]
	if _picked.size() < cup.team_size:
		_status.text = "La %s necesita %d Pokémon: elegí %d más." % [cup.display_name, cup.team_size, cup.team_size - _picked.size()]
		return
	var lvl := int(_level.value)
	if cup.level_cap > 0:
		lvl = mini(lvl, cup.level_cap)
	GameState.new_game(_picked[0])
	GameState.party.clear()
	for sp in _picked:
		GameState.party.append(CreatureInstance.create(sp, lvl))
	GameState.active_index = 0
	GameState.money = 0
	GameState.wilds_enabled = false
	GameState.test_tournament = {"cup": cup.id}
	for z in DB.config.world.zones:
		if z.id == "ciudad_plateada_torneo":
			GameState.trainer_position = Vector2((z.origin + Vector2i(7, 5)) * DB.config.world.tile_size) + Vector2.ONE * 8.0
	Events.party_changed.emit()
	get_tree().change_scene_to_file(WORLD_SCENE)
