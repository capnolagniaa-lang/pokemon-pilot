extends Control
## Pantalla de nueva partida: solo la historia (el modo libre, empezar ya con un inicial en el mundo abierto, se sacó
## por pedido del usuario 2026-10-29; las partidas viejas del modo libre siguen cargando igual).

const WORLD_SCENE := "res://scenes/world/world.tscn"


func _ready() -> void:
	_build_story_button()
	_build_options()


## Historia (docs/PLAN_HISTORIA.md): arrancás en tu cuarto sin Pokémon y elegís el inicial en el laboratorio de Oak.
func _build_story_button() -> void:
	var b := UiStyle.button("▶  Empezar la historia", 640)
	b.pressed.connect(func():
		GameState.new_story()
		get_tree().change_scene_to_file(WORLD_SCENE))
	$Center/VBox.add_child(b)
	UiStyle.focus_later(b)


## Opciones de la partida: dificultad de la IA y modo práctica. (Entrenadores vivos se sacó por ahora: 2026-10-29.)
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
