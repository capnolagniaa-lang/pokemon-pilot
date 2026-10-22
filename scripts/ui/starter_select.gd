extends Control
## Pantalla de elección de inicial. Arma las tarjetas a partir de GameConfig.starters.

const WORLD_SCENE := "res://scenes/world/world.tscn"

@onready var cards: HBoxContainer = $Center/VBox/Cards


func _ready() -> void:
	var starters := DB.config.starters
	for i in starters.size():
		cards.add_child(_card(starters[i], i))
	_build_options()


## Opciones de la partida: dificultad de la IA y modo práctica.
func _build_options() -> void:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	$Center/VBox.add_child(box)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	var label := Label.new()
	label.text = "Dificultad de la IA:"
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	var group := ButtonGroup.new()
	for id in ["facil", "normal", "dificil"]:
		var diff: AiDifficulty = DB.difficulties.get(id)
		if diff == null:
			continue
		var b := Button.new()
		b.text = diff.display_name
		b.toggle_mode = true
		b.button_group = group
		b.custom_minimum_size = Vector2(110, 36)
		b.add_theme_color_override("font_pressed_color", Color(1.0, 0.85, 0.3))
		b.add_theme_color_override("font_hover_pressed_color", Color(1.0, 0.85, 0.3))
		b.button_pressed = GameState.difficulty == diff
		b.pressed.connect(GameState.set_difficulty.bind(id))
		row.add_child(b)

	var practice := CheckBox.new()
	practice.text = "Modo práctica (si tu Pokémon se debilita, vuelve al instante con la vida al máximo)"
	practice.button_pressed = GameState.practice_mode
	practice.toggled.connect(func(on: bool): GameState.practice_mode = on)
	var center := CenterContainer.new()
	center.add_child(practice)
	box.add_child(center)


func _card(sp: SpeciesData, index: int) -> Control:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(220, 250)
	btn.focus_mode = Control.FOCUS_ALL
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pic := TextureRect.new()
	pic.texture = DB.portrait_of(sp)
	pic.custom_minimum_size = Vector2(120, 120)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(pic)
	var name_label := Label.new()
	name_label.text = "%s\n%s\n[%d]" % [sp.display_name, sp.primary_type().display_name, index + 1]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", sp.primary_type().color.lightened(0.3))
	name_label.add_theme_font_size_override("font_size", 20)
	box.add_child(name_label)
	btn.add_child(box)
	btn.pressed.connect(_choose.bind(sp))
	return btn


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
		return
	for i in DB.config.starters.size():
		if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_1 + i:
			_choose(DB.config.starters[i])


func _choose(sp: SpeciesData) -> void:
	GameState.new_game(sp)
	get_tree().change_scene_to_file(WORLD_SCENE)
