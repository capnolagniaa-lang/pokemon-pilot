extends Control
## Pantalla de título (escena principal): Continuar (lista de partidas guardadas: cargar o borrar), Nueva
## partida (pide el nombre de la partida; avisa si ya hay una con ese nombre) y Salir. Fondo con cielo en degradé, colinas y Pokémon animados.

const STARTER_SCENE := "res://scenes/ui/starter_select.tscn"
const WORLD_SCENE := "res://scenes/world/world.tscn"
const MAP_EDITOR_SCENE := "res://scenes/tools/map_editor.tscn"
## Partida de prueba del editor de mapas: guarda aparte para no pisar la partida real.
const TEST_SLOT := "user://saves/map_editor_test.json"

var _menu: VBoxContainer
var _continue: Button
var _summary: Dictionary
var _saves: Array[Dictionary] = []
var _overlay: Control
var _time := 0.0
var _parade: Array = []  # [PokemonAnimView, x base, fase]


func _ready() -> void:
	theme = UiStyle.theme()
	get_tree().paused = false
	var args := OS.get_cmdline_user_args()
	if "--map-editor" in args:
		get_tree().change_scene_to_file.call_deferred(MAP_EDITOR_SCENE)
		return
	if "--start-zone" in args:
		_start_in_zone.call_deferred(args)
		return
	_saves = SaveManager.list_saves()
	_summary = _saves[0] if not _saves.is_empty() else {}
	_build_background()
	_build_menu()


func _process(delta: float) -> void:
	_time += delta
	for p in _parade:
		var v: PokemonAnimView = p[0]
		v.position.y = p[2] + sin(_time * 1.7 + p[1]) * 3.0
	queue_redraw()


func _draw() -> void:
	# Cielo en degradé de atardecer, sol y colinas en capas (pixel art simple, colores de FireRed).
	var h := size.y
	var bands := 24
	for i in bands:
		var k := i / float(bands - 1)
		var c := Color(0.16, 0.22, 0.42).lerp(Color(0.98, 0.62, 0.42), k * k)
		draw_rect(Rect2(0, h * 0.62 * i / bands, size.x, h * 0.62 / bands + 1), c)
	draw_circle(Vector2(size.x * 0.78, h * 0.5), 70.0, Color(1.3, 0.85, 0.5, 0.9))
	draw_circle(Vector2(size.x * 0.78, h * 0.5), 96.0, Color(1.0, 0.7, 0.4, 0.15))
	for layer in 3:
		var base := h * (0.55 + layer * 0.08)
		var col: Color = [Color(0.24, 0.42, 0.36), Color(0.2, 0.5, 0.32), Color(0.25, 0.62, 0.3)][layer]
		var pts := PackedVector2Array([Vector2(0, h)])
		for x in range(0, int(size.x) + 40, 40):
			pts.append(Vector2(x, base + sin(x * 0.006 + layer * 1.7 + _time * 0.05) * (26.0 - layer * 6.0)))
		pts.append(Vector2(size.x, h))
		draw_colored_polygon(pts, col)
	draw_rect(Rect2(0, h * 0.8, size.x, h * 0.2), Color(0.32, 0.68, 0.33))
	# Brillitos que suben
	for i in 26:
		var x := fmod(i * 97.0 + _time * (8.0 + i % 5), size.x)
		var y := h - fmod(i * 53.0 + _time * (14.0 + i % 7), h)
		draw_circle(Vector2(x, y), 1.5, Color(1.2, 1.1, 0.8, 0.35))


func _build_background() -> void:
	# Desfile: el equipo guardado o los iniciales, con su animación Idle.
	var species: Array = _summary.get("species", [])
	if species.is_empty():
		species = DB.config.starters
	var n := species.size()
	for i in n:
		var v := PokemonAnimView.new()
		v.species = species[i]
		v.pixel_scale = 3
		v.size = Vector2(150, 150)
		var x := 640.0 + (i - (n - 1) / 2.0) * 150.0 - 75.0
		v.position = Vector2(x, 500)
		add_child(v)
		_parade.append([v, float(i), 500.0])


func _build_menu() -> void:
	var title := UiStyle.label("Pokémon Pilot", 64, Color(1.0, 0.88, 0.35))
	title.add_theme_color_override("font_outline_color", Color(0.12, 0.2, 0.55))
	title.add_theme_constant_override("outline_size", 14)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(-300, 48)
	title.size = Vector2(600, 80)
	add_child(title)
	var sub := UiStyle.label("Kanto en tiempo real", 20, Color(1, 1, 1, 0.85))
	sub.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	sub.add_theme_constant_override("outline_size", 6)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	sub.position = Vector2(-300, 128)
	sub.size = Vector2(600, 30)
	add_child(sub)

	_menu = VBoxContainer.new()
	_menu.add_theme_constant_override("separation", 10)
	_menu.position = Vector2(640 - 170, 200)
	_menu.custom_minimum_size = Vector2(340, 0)
	add_child(_menu)
	if not _saves.is_empty():
		_continue = UiStyle.button("Continuar" if _saves.size() == 1 else "Continuar (%d partidas)" % _saves.size(), 340)
		_continue.pressed.connect(_show_saves)
		_menu.add_child(_continue)
		_menu.add_child(_summary_panel(_summary))
	var new_game := UiStyle.button("Nueva partida", 340)
	new_game.pressed.connect(_on_new_game)
	_menu.add_child(new_game)
	var test := UiStyle.button("Probar el torneo (prueba)", 340)
	test.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/tournament_test.tscn"))
	_menu.add_child(test)
	if "--debug" in OS.get_cmdline_user_args() or (OS.has_feature("editor") and not OS.has_feature("portable")):  # como World.debug_enabled()
		var editor := UiStyle.button("Editor de mapas", 340)
		editor.pressed.connect(func(): get_tree().change_scene_to_file(MAP_EDITOR_SCENE))
		_menu.add_child(editor)
	var quit := UiStyle.button("Salir", 340)
	quit.pressed.connect(func(): get_tree().quit())
	_menu.add_child(quit)
	UiStyle.focus_later((_continue if _continue != null else new_game))
	var hint := UiStyle.label("Flechas/WASD para elegir · Enter o Espacio para aceptar", 13, Color(1, 1, 1, 0.7))
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(-300, -30)
	hint.size = Vector2(600, 20)
	add_child(hint)


## Resumen de una partida: nombre, retratos del equipo, nivel del líder, zona, tiempo jugado y fecha.
func _summary_panel(s: Dictionary) -> Control:
	var panel := PanelContainer.new()
	var box := VBoxContainer.new()
	panel.add_child(box)
	box.add_child(UiStyle.label(str(s.get("name", "Partida")), 16, UiStyle.ACCENT))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	for sp: SpeciesData in s["species"]:
		var pic := TextureRect.new()
		pic.texture = DB.portrait_of(sp)
		pic.custom_minimum_size = Vector2(44, 44)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		row.add_child(pic)
	box.add_child(row)
	var zone: String = s.get("zone", "")
	if s["species"].is_empty():
		box.add_child(UiStyle.label("Todavía sin Pokémon%s" % (("  ·  " + zone) if zone != "" else ""), 14))
	else:
		var leader: SpeciesData = s["species"][0]
		box.add_child(UiStyle.label("%s Nv. %d%s" % [leader.display_name, s["leader_level"], ("  ·  " + zone) if zone != "" else ""], 14))
	var when := str(s.get("saved_at", "")).replace("T", " ").left(16)
	box.add_child(UiStyle.label("Tiempo: %s  ·  %s" % [SaveManager.format_time(s["play_time"]), when], 13, UiStyle.TEXT_DIM))
	return panel


# --- Partidas guardadas -----------------------------------------------------------------------------------

## Lista de partidas: Cargar o Borrar cada una.
func _show_saves() -> void:
	_close_overlay()
	_overlay = _overlay_panel("PARTIDAS GUARDADAS")
	var list: VBoxContainer = _overlay.get_meta("box")
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(620, 380)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(rows)
	list.add_child(scroll)
	var first: Button = null
	for s in _saves:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var p := _summary_panel(s)
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(p)
		var actions := VBoxContainer.new()
		var load_b := UiStyle.button("Cargar", 110)
		load_b.pressed.connect(_load.bind(s["path"]))
		actions.add_child(load_b)
		var del_b := UiStyle.button("Borrar", 110)
		del_b.pressed.connect(_ask_delete.bind(s))
		actions.add_child(del_b)
		row.add_child(actions)
		rows.add_child(row)
		if first == null:
			first = load_b
	var back := UiStyle.button("Volver", 200)
	back.pressed.connect(_close_overlay)
	list.add_child(back)
	UiStyle.focus_later(first if first != null else back)


func _load(path: String) -> void:
	if SaveManager.load_from(path):
		get_tree().change_scene_to_file(WORLD_SCENE)
	else:
		ConfirmDialog.ask(self, "No se pudo cargar la partida (el archivo está dañado).", ["Aceptar"])


func _ask_delete(s: Dictionary) -> void:
	var d := ConfirmDialog.ask(self, "¿Borrar la partida \"%s\"? No se puede deshacer." % s["name"], ["Borrar", "Cancelar"])
	d.chosen.connect(func(i: int):
		if i == 0:
			DirAccess.remove_absolute(s["path"])
			get_tree().reload_current_scene())


## Nombre de la partida nueva.
func _ask_name() -> void:
	_close_overlay()
	_overlay = _overlay_panel("NUEVA PARTIDA")
	var box: VBoxContainer = _overlay.get_meta("box")
	box.add_child(UiStyle.label("Nombre de la partida:", 18))
	var edit := LineEdit.new()
	edit.text = "Partida %d" % (_saves.size() + 1)
	edit.max_length = 24
	edit.custom_minimum_size = Vector2(420, 44)
	edit.add_theme_font_size_override("font_size", 20)
	box.add_child(edit)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var ok := UiStyle.button("Empezar", 200)
	var cancel := UiStyle.button("Volver", 200)
	row.add_child(ok)
	row.add_child(cancel)
	box.add_child(row)
	ok.pressed.connect(func(): _start_named(edit.text))
	edit.text_submitted.connect(func(t: String): _start_named(t))
	cancel.pressed.connect(_close_overlay)
	edit.grab_focus.call_deferred()
	edit.select_all.call_deferred()


func _start_named(save_name: String) -> void:
	save_name = save_name.strip_edges()
	if save_name == "":
		return
	if FileAccess.file_exists(SaveManager.path_for_name(save_name)):
		var d := ConfirmDialog.ask(self, "Ya hay una partida \"%s\". Si empezás otra con ese nombre y guardás, se reemplaza. ¿Empezar igual?" % save_name,
			["Empezar", "Cancelar"])
		d.chosen.connect(func(i: int):
			if i == 0:
				SaveManager.use_name(save_name)
				get_tree().change_scene_to_file(STARTER_SCENE))
		return
	SaveManager.use_name(save_name)
	get_tree().change_scene_to_file(STARTER_SCENE)


func _overlay_panel(title: String) -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(UiStyle.dim())
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.ACCENT.darkened(0.3), 2, 18))
	panel.position = Vector2(300, 90)
	panel.custom_minimum_size = Vector2(680, 0)
	root.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	box.add_child(UiStyle.label(title, 24, UiStyle.ACCENT))
	root.set_meta("box", box)
	add_child(root)
	return root


func _close_overlay() -> void:
	if is_instance_valid(_overlay):
		_overlay.queue_free()
	_overlay = null
	UiStyle.focus_later(_menu.get_child(0))


## "Probar en el juego" del editor de mapas (-- --debug --start-zone <id> --start-cell x,y): arranca con el
## equipo de la partida guardada (o un inicial) parado en esa celda. Lo que se guarde va a un slot aparte.
func _start_in_zone(args: PackedStringArray) -> void:
	var zone_id := args[args.find("--start-zone") + 1] if args.find("--start-zone") + 1 < args.size() else ""
	var cell := Vector2i.ZERO
	var i := args.find("--start-cell")
	if i >= 0 and i + 1 < args.size():
		var parts := args[i + 1].split(",")
		if parts.size() == 2:
			cell = Vector2i(int(parts[0]), int(parts[1]))
	if not SaveManager.load_game():
		GameState.new_game(DB.config.starters[0])
	SaveManager.slot_path = TEST_SLOT
	var world := DB.config.world
	for z in world.zones:
		if z.id == zone_id:
			GameState.trainer_position = Vector2((z.origin + cell) * world.tile_size) + Vector2(world.tile_size / 2.0, world.tile_size / 2.0)
	get_tree().change_scene_to_file(WORLD_SCENE)


func _on_new_game() -> void:
	_ask_name()
