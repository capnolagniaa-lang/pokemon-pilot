class_name ConfirmDialog
extends Control
## Pregunta modal con varias opciones (teclado y mouse). Emite `chosen(index)`; Esc elige la última
## opción (la de cancelar). Se crea con ConfirmDialog.ask(padre, texto, opciones).

signal chosen(index: int)

var _buttons: Array[Button] = []


static func ask(parent: Node, text: String, options: Array) -> ConfirmDialog:
	var d := ConfirmDialog.new()
	d.process_mode = Node.PROCESS_MODE_ALWAYS
	d.theme = UiStyle.theme()
	d.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(d)
	d._build(text, options)
	return d


func _build(text: String, options: Array) -> void:
	add_child(UiStyle.dim())
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var l := UiStyle.label(text, 18)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size.x = 420
	box.add_child(l)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	for i in options.size():
		var b := UiStyle.button(str(options[i]), 120)
		b.pressed.connect(_choose.bind(i))
		row.add_child(b)
		_buttons.append(b)
	UiStyle.focus_later(_buttons[0])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_choose(_buttons.size() - 1)


func _choose(i: int) -> void:
	chosen.emit(i)
	queue_free()
