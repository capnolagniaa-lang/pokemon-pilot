extends Control
## Pantalla de elección de inicial. Arma las tarjetas a partir de GameConfig.starters.

const WORLD_SCENE := "res://scenes/world/world.tscn"

@onready var cards: HBoxContainer = $Center/VBox/Cards


func _ready() -> void:
	var starters := DB.config.starters
	for i in starters.size():
		cards.add_child(_card(starters[i], i))


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
	for i in DB.config.starters.size():
		if event.is_action_pressed("attack_%d" % (i + 1)) and event is InputEventKey:
			_choose(DB.config.starters[i])


func _choose(sp: SpeciesData) -> void:
	GameState.new_game(sp)
	get_tree().change_scene_to_file(WORLD_SCENE)
