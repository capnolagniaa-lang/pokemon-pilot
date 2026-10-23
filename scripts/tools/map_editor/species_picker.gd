class_name MapSpeciesPicker
extends Control
## Elegir un Pokémon (los 386, por número de Pokédex) con buscador por nombre o número.

signal picked(species_id: String)

var _search: LineEdit
var _list: ItemList


static func open(parent: Node) -> MapSpeciesPicker:
	var d := MapSpeciesPicker.new()
	d.theme = UiStyle.theme()
	d.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(d)
	d._build()
	return d


func _build() -> void:
	add_child(UiStyle.dim())
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 520)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(UiStyle.label("Elegí un Pokémon", 18, UiStyle.ACCENT))
	_search = LineEdit.new()
	_search.placeholder_text = "Buscar por nombre o número (ej.: pika, 25)"
	_search.text_changed.connect(func(_t): _fill())
	_search.text_submitted.connect(func(_t):
		if _list.item_count > 0:
			_choose(0))
	box.add_child(_search)
	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.max_columns = 0
	_list.same_column_width = true
	_list.fixed_column_width = 120
	_list.icon_mode = ItemList.ICON_MODE_TOP
	_list.fixed_icon_size = Vector2i(40, 40)
	_list.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_list.add_theme_font_size_override("font_size", 12)
	_list.item_activated.connect(_choose)
	_list.item_clicked.connect(func(i: int, _p, _b): _choose(i))
	box.add_child(_list)
	var cancel := UiStyle.button("Cancelar", 140)
	cancel.pressed.connect(queue_free)
	box.add_child(cancel)
	_fill()
	_search.grab_focus.call_deferred()


func _fill() -> void:
	_list.clear()
	var q := _search.text.strip_edges().to_lower()
	for sp in DB.species_by_dex():
		var label := "#%03d %s" % [sp.dex, sp.display_name]
		if q != "" and not label.to_lower().contains(q) and not sp.id.contains(q) and str(sp.dex) != q:
			continue
		var i := _list.add_item(label, DB.portrait_of(sp))
		_list.set_item_metadata(i, sp.id)


func _choose(i: int) -> void:
	picked.emit(_list.get_item_metadata(i))
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
