extends Control
## Guía (Esc → Guía): en qué parte de la historia estás, qué hacer para seguir y lo opcional que te queda
## (StoryGuide). En el modo libre avisa que no hay historia.

signal closed


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.ACCENT.darkened(0.3), 2, 22))
	panel.position = Vector2(240, 90)
	panel.custom_minimum_size = Vector2(800, 0)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	box.add_child(UiStyle.label("GUÍA", 26, UiStyle.ACCENT))
	var step := StoryGuide.current()
	if step.is_empty():
		box.add_child(_wrapped("Estás en el modo libre: no hay historia. Explorá, atrapá Pokémon y probá los combates.", 18))
	else:
		var done: int = step["index"]
		box.add_child(UiStyle.label("Capítulo 1: de Pueblo Paleta a la Medalla Roca  ·  paso %d de %d" % [mini(done + 1, step["total"]), step["total"]], 15, UiStyle.TEXT_DIM))
		box.add_child(UiStyle.bar(float(done) / step["total"], UiStyle.ACCENT, Vector2(756, 8)))
		box.add_child(UiStyle.label(step["title"], 22))
		box.add_child(_wrapped(step["text"], 18))
		var extra := StoryGuide.optional_left()
		if not extra.is_empty():
			box.add_child(UiStyle.label("También podés:", 16, UiStyle.ACCENT))
			for t in extra:
				box.add_child(_wrapped("•  " + t, 15, UiStyle.TEXT_DIM))
	var back := UiStyle.button("Volver", 160)
	back.pressed.connect(func(): closed.emit())
	box.add_child(back)
	UiStyle.focus_later(back)


func _wrapped(text: String, size: int, color: Color = UiStyle.TEXT) -> Label:
	var l := UiStyle.label(text, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 756
	return l
