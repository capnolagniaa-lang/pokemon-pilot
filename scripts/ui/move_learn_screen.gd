class_name MoveLearnScreen
extends Control
## Cartel de "quiere aprender un ataque" (pedido del usuario 2026-10-28): cuando un Pokémon del equipo aprende un
## ataque y ya tiene las 4 ranuras llenas. "¿Reemplazar uno?" → Sí: elegís cuál deja de usar (o "No aprenderlo");
## No: lo deja en la ficha (se puede equipar después desde Esc → Equipo). Lo muestra MoveLearnDirector.

const Summary := preload("res://scripts/ui/summary_screen.gd")

## replaced = la ranura que se reemplazó (-1 = ninguna).
signal finished(replaced: int)

var inst: CreatureInstance
var move: MoveData
var _box: VBoxContainer


func setup(p_inst: CreatureInstance, p_move: MoveData) -> void:
	inst = p_inst
	move = p_move


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.ACCENT.darkened(0.3), 2, 18))
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(620, 0)
	panel.position = Vector2(330, 150)
	add_child(panel)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 10)
	panel.add_child(_box)
	_ask()


func _clear() -> void:
	for c in _box.get_children():
		c.queue_free()


func _header() -> void:
	_box.add_child(UiStyle.label("¡%s quiere aprender %s!" % [inst.display_name(), move.display_name], 22, UiStyle.ACCENT))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	if move.element != null:
		row.add_child(UiStyle.type_chip(move.element))
	row.add_child(_wrapped(" · ".join(Summary.describe(move)), 14, UiStyle.TEXT_DIM))
	_box.add_child(row)
	_box.add_child(_wrapped(MoveInfo.what_it_does(move), 15, UiStyle.TEXT))


func _ask() -> void:
	_clear()
	_header()
	_box.add_child(UiStyle.label("Pero ya tiene 4 ataques equipados. ¿Querés reemplazar uno?", 16))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var yes := UiStyle.button("Sí, elegir cuál", 220)
	yes.pressed.connect(_choose)
	var no := UiStyle.button("No", 140)
	no.pressed.connect(func(): finished.emit(-1))
	row.add_child(yes)
	row.add_child(no)
	_box.add_child(row)
	_box.add_child(UiStyle.label("(Igual queda aprendido: lo podés equipar cuando quieras desde Esc → Equipo.)", 12, UiStyle.TEXT_DIM))
	UiStyle.focus_later(yes)


func _choose() -> void:
	_clear()
	_header()
	_box.add_child(UiStyle.label("¿Cuál deja de usar?", 16))
	var first: Button = null
	for i in inst.equipped_moves.size():
		var m: MoveData = inst.equipped_moves[i]
		if m == null:
			continue
		var b := UiStyle.button("%s  —  %s" % [Controls.SLOT_KEYS[i] if i < Controls.SLOT_KEYS.size() else str(i + 1),
			m.display_name], 560)
		b.tooltip_text = MoveInfo.what_it_does(m) + "
" + " · ".join(Summary.describe(m))
		b.pressed.connect(func(): finished.emit(i))
		_box.add_child(b)
		if first == null:
			first = b
	var cancel := UiStyle.button("No aprenderlo (volver)", 300)
	cancel.pressed.connect(_ask)
	_box.add_child(cancel)
	UiStyle.focus_later(first)


func _wrapped(text: String, size: int, color: Color) -> Label:
	var l := UiStyle.label(text, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 480
	return l
