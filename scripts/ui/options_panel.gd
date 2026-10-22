extends Control
## Opciones editables en partida: dificultad de la IA y modo práctica (las mismas que al iniciar).

signal closed

var _first: Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(UiStyle.label("OPCIONES", 20, UiStyle.ACCENT))
	box.add_child(UiStyle.label("Dificultad de la IA", 16))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)
	var group := ButtonGroup.new()
	for id in ["facil", "normal", "dificil"]:
		var diff: AiDifficulty = DB.difficulties.get(id)
		if diff == null:
			continue
		var b := UiStyle.button(diff.display_name, 150)
		b.toggle_mode = true
		b.button_group = group
		b.button_pressed = GameState.difficulty == diff
		b.pressed.connect(GameState.set_difficulty.bind(id))
		row.add_child(b)
		if b.button_pressed or _first == null:
			_first = b
	var practice := CheckBox.new()
	practice.text = "Modo práctica (si tu Pokémon se debilita, vuelve al instante)"
	practice.button_pressed = GameState.practice_mode
	practice.toggled.connect(func(on: bool): GameState.practice_mode = on)
	box.add_child(practice)
	var back := UiStyle.button("Volver", 160)
	back.pressed.connect(func(): closed.emit())
	box.add_child(back)
	_first.grab_focus.call_deferred()
