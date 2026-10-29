extends Control
## Pokédex (menú de pausa): las 386 especies de Kanto, Johto y Hoenn, por región. Solo se ven las que ya
## viste o contra las que peleaste (GameState.pokedex_seen); las demás aparecen como "?????" con la silueta
## oscura estilo "¿Quién es ese Pokémon?". Tab cambia de región; flechas/WASD recorren la grilla.
## Visto: datos de la Pokédex + su estilo de pelea (kit: arquetipo, mecánica de firma y sus 4 ataques).
## Luchado: además las estadísticas base.

signal closed

const REGIONS := [["Kanto", 1, 151], ["Johto", 152, 251], ["Hoenn", 252, 386]]
const COLUMNS := 6
const Summary := preload("res://scripts/ui/summary_screen.gd")

var _region := 0
var _region_buttons: Array[Button] = []
var _grid: GridContainer
var _scroll: ScrollContainer
var _detail: VBoxContainer
var _stage: Control
var _view: PokemonAnimView
var _cells: Array[Button] = []
var _species: Array[SpeciesData] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	_species = DB.species_by_dex()
	var root := VBoxContainer.new()
	root.position = Vector2(28, 20)
	root.size = Vector2(1224, 680)
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	root.add_child(head)
	head.add_child(UiStyle.label("POKÉDEX", 26, UiStyle.ACCENT))
	for i in REGIONS.size():
		var b := UiStyle.button(REGIONS[i][0], 110)
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(_show_region.bind(i))
		head.add_child(b)
		_region_buttons.append(b)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	head.add_child(UiStyle.label("Vistos %d · Luchados %d · Atrapados %d · Total %d" % [GameState.pokedex_seen.size(),
		GameState.pokedex_fought.size(), GameState.pokedex_caught.size(), _species.size()], 15, UiStyle.TEXT))

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	_scroll = ScrollContainer.new()
	_scroll.custom_minimum_size = Vector2(612, 600)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(_scroll)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	_scroll.add_child(_grid)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(panel)
	var detail_scroll := ScrollContainer.new()
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_scroll.custom_minimum_size = Vector2(580, 600)
	panel.add_child(detail_scroll)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 8)
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.add_child(_detail)
	_stage = WhoStage.new()
	_stage.custom_minimum_size = Vector2(560, 230)
	_stage.clip_contents = true  # los rayos no se salen del recuadro
	_detail.add_child(_stage)
	_view = PokemonAnimView.new()
	_view.pixel_scale = 4
	_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage.add_child(_view)

	var foot := HBoxContainer.new()
	root.add_child(foot)
	foot.add_child(UiStyle.label("Tab: cambiar región · Flechas/WASD: recorrer · Esc: volver", 13, UiStyle.TEXT_DIM))
	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(spacer2)
	var back := UiStyle.button("Volver", 140)
	back.pressed.connect(func(): closed.emit())
	foot.add_child(back)

	# Arranca en la región del Pokémon activo.
	var lead := GameState.active()
	for i in REGIONS.size():
		if lead != null and lead.species.dex >= REGIONS[i][1] and lead.species.dex <= REGIONS[i][2]:
			_region = i
	_show_region(_region)


func _show_region(i: int) -> void:
	_region = i
	for k in _region_buttons.size():
		_region_buttons[k].button_pressed = k == i
	for c in _grid.get_children():
		c.queue_free()
	_cells.clear()
	var first: Button = null
	var focus_target: Button = null
	for sp in _species:
		if sp.dex < REGIONS[i][1] or sp.dex > REGIONS[i][2]:
			continue
		var b := _cell(sp)
		_grid.add_child(b)
		_cells.append(b)
		if first == null:
			first = b
		if focus_target == null and GameState.active() != null and sp == GameState.active().species:
			focus_target = b
	if first != null:
		UiStyle.focus_later((focus_target if focus_target != null else first))


func _cell(sp: SpeciesData) -> Button:
	var seen := GameState.has_seen(sp)
	var b := Button.new()
	b.custom_minimum_size = Vector2(96, 96)
	b.focus_mode = Control.FOCUS_ALL
	var pic := TextureRect.new()
	pic.texture = DB.idle_frame_of(sp)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pic.set_anchors_preset(Control.PRESET_FULL_RECT)
	pic.offset_top = 4
	pic.offset_bottom = -18
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not seen:
		pic.modulate = Color(0.06, 0.07, 0.12)  # silueta
	b.add_child(pic)
	var num := UiStyle.label("%03d" % sp.dex, 12, UiStyle.TEXT if seen else UiStyle.TEXT_DIM)
	num.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.position = Vector2(-30, -18)
	num.size = Vector2(60, 16)
	num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(num)
	if GameState.has_caught(sp):
		var ball := TextureRect.new()  # atrapado: una Pokéball en la esquina
		ball.texture = DB.items["poke_ball"].icon if DB.items.has("poke_ball") else null
		ball.position = Vector2(2, 0)
		ball.size = Vector2(20, 20)
		ball.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ball.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ball.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(ball)
	elif GameState.has_fought(sp):
		var mark := UiStyle.label("●", 10, UiStyle.ACCENT)  # luchado
		mark.position = Vector2(6, 2)
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(mark)
	b.focus_entered.connect(_show_detail.bind(sp))
	b.pressed.connect(_show_detail.bind(sp))
	return b


func _show_detail(sp: SpeciesData) -> void:
	var seen := GameState.has_seen(sp)
	for c in _detail.get_children():
		if c != _stage:
			c.queue_free()
	_view.species = sp
	_view.silhouette = not seen
	_stage.reveal = seen
	_stage.queue_redraw()
	var title := HBoxContainer.new()
	title.add_theme_constant_override("separation", 12)
	_detail.add_child(title)
	title.add_child(UiStyle.label("N.º %03d" % sp.dex, 20, UiStyle.ACCENT))
	title.add_child(UiStyle.label(sp.display_name if seen else "?????", 26))
	if not seen:
		_detail.add_child(UiStyle.label("Todavía no viste a este Pokémon.", 15, UiStyle.TEXT_DIM))
		return
	if sp.genus != "":
		_detail.add_child(UiStyle.label(sp.genus, 15, UiStyle.TEXT_DIM))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	for t in sp.types:
		row.add_child(UiStyle.type_chip(t))
	row.add_child(UiStyle.label("   Altura %.1f m · Peso %.1f kg" % [sp.height_m, sp.weight_kg], 14))
	_detail.add_child(row)
	var entry := UiStyle.label(sp.pokedex_entry, 14)
	entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry.custom_minimum_size.x = 540
	_detail.add_child(entry)
	if not sp.evolutions.is_empty() or sp.evolves_from != "":
		var parts := PackedStringArray()
		if sp.evolves_from != "" and DB.species.has(sp.evolves_from):
			parts.append("Evoluciona de %s" % DB.species[sp.evolves_from].display_name)
		if not sp.evolutions.is_empty():
			parts.append("Evoluciona en " + ", ".join(sp.evolutions.map(func(e): return Evolution.describe(e))))
		_detail.add_child(UiStyle.label(" · ".join(parts), 14, UiStyle.ACCENT))
	_add_kit(sp)
	if not GameState.has_fought(sp):
		_detail.add_child(UiStyle.label("Peleá contra él para conocer sus estadísticas.", 14, UiStyle.TEXT_DIM))
		return
	_detail.add_child(UiStyle.label("%s · Estadísticas base" % ("Atrapado" if GameState.has_caught(sp) else "Luchado ●"), 14, UiStyle.ACCENT))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 4)
	for s in CreatureInstance.STATS:
		var base := sp.base_stat(s)
		grid.add_child(UiStyle.label(UiStyle.STAT_NAMES[s], 14))
		grid.add_child(UiStyle.label(str(base), 14, UiStyle.ACCENT))
		var col := Color(0.95, 0.45, 0.3).lerp(Color(0.35, 0.85, 0.45), clampf((base - 30.0) / 90.0, 0.0, 1.0))
		var b := UiStyle.bar(base / 160.0, col, Vector2(320, 8))
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		grid.add_child(b)
	_detail.add_child(grid)


## Habilidades (se ven apenas lo viste) y, si es jefe de un gimnasio, su kit de jefe.
func _add_kit(sp: SpeciesData) -> void:
	for ab in sp.abilities:
		_detail.add_child(UiStyle.label("Habilidad: " + ab.display_name, 15, ab.color.lightened(0.2)))
		_detail.add_child(_wrapped(ab.description, 13, UiStyle.TEXT_DIM))
	var kit := sp.boss_kit
	if kit == null:
		return
	_detail.add_child(_wrapped("Con un líder de gimnasio pelea como JEFE, con su kit propio:", 15, UiStyle.ACCENT))
	if kit.signature != null:
		_detail.add_child(UiStyle.label("Mecánica de firma: " + kit.signature.display_name, 15, kit.signature.color.lightened(0.2)))
		_detail.add_child(_wrapped(kit.signature.description, 13, UiStyle.TEXT_DIM))
	for i in kit.moves.size():
		var m: MoveData = kit.moves[i]
		if m == null:
			continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.add_child(UiStyle.label(Controls.SLOT_KEYS[i] if i < Controls.SLOT_KEYS.size() else "", 14, UiStyle.ACCENT))
		if m.element != null:
			row.add_child(UiStyle.type_chip(m.element))
		row.add_child(UiStyle.label(m.display_name, 15))
		_detail.add_child(row)
		_detail.add_child(_wrapped(MoveInfo.what_it_does(m), 13))
		_detail.add_child(_wrapped(" · ".join(Summary.describe(m)), 13, UiStyle.TEXT_DIM))


func _wrapped(text: String, size: int, color: Color = UiStyle.TEXT) -> Label:
	var l := UiStyle.label(text, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 540
	return l


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		_show_region((_region + (-1 if event.shift_pressed else 1) + REGIONS.size()) % REGIONS.size())
		get_viewport().set_input_as_handled()


## Fondo del Pokémon elegido: rayos de colores como en "¿Quién es ese Pokémon?" (más apagado si ya se vio).
class WhoStage extends Control:
	var reveal := false
	var _time := 0.0

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		var c := size / 2.0
		var r := size.length()
		var base := Color(0.12, 0.3, 0.62) if not reveal else Color(0.14, 0.2, 0.28)
		draw_rect(Rect2(Vector2.ZERO, size), base)
		var rays := 16
		for i in rays:
			if i % 2 == 0:
				continue
			var a0 := TAU * i / rays + _time * 0.15
			var a1 := TAU * (i + 1) / rays + _time * 0.15
			var col := Color(1.0, 0.85, 0.2, 0.55) if not reveal else Color(0.3, 0.42, 0.55, 0.35)
			draw_colored_polygon(PackedVector2Array([c, c + Vector2.from_angle(a0) * r, c + Vector2.from_angle(a1) * r]), col)
		draw_circle(c, size.y * 0.42, Color(1, 1, 1, 0.12 if not reveal else 0.06))
		if not reveal:
			draw_string(ThemeDB.fallback_font, Vector2(14, size.y - 14), "¿Quién es ese Pokémon?", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1, 0.9))
