class_name MapStampPanel
extends VBoxContainer
## Pestaña "Sellos": edificios y piezas del mundo sacados de los mapas reales de FireRed con las hojas de
## referencia (data/world/stamps.json → tile_catalog.tres): casas, Centro y Tienda, gimnasios, edificios
## especiales, garitas y piezas (árboles grandes, estatuas, escalinatas, puentes...). Filtro por grupo y por
## lugar; los edificios con variantes de color tienen un selector. Un clic en el mapa pega el sello.

signal stamp_selected(stamp: Dictionary, variant: int)

var catalog: TileCatalog
var _group: OptionButton
var _place: OptionButton
var _variant: OptionButton
var _list: ItemList
var _info: Label
var _groups: PackedStringArray = []
var _places: PackedStringArray = []
var _current: Dictionary = {}


func setup(p_catalog: TileCatalog) -> void:
	catalog = p_catalog
	add_theme_constant_override("separation", 4)
	_group = _option()
	_group.item_selected.connect(func(_i): _fill_places(); refresh())
	_place = _option()
	_place.item_selected.connect(func(_i): refresh())
	_variant = _option()
	_variant.visible = false
	_variant.item_selected.connect(func(i: int):
		if not _current.is_empty():
			stamp_selected.emit(_current, i))
	_info = UiStyle.label("Clic en el mapa: esquina de arriba a la izquierda del sello.", 12, UiStyle.TEXT_DIM)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info.custom_minimum_size.x = 260
	add_child(_info)
	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.max_columns = 0
	_list.same_column_width = true
	_list.icon_mode = ItemList.ICON_MODE_TOP
	_list.fixed_icon_size = Vector2i(132, 92)
	_list.max_text_lines = 2
	_list.fixed_column_width = 136  # dos columnas aunque haya nombres largos
	_list.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_list.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_list.focus_mode = Control.FOCUS_NONE
	_list.add_theme_font_size_override("font_size", 11)
	_list.item_selected.connect(_on_selected)
	add_child(_list)
	_group.add_item("Todos los grupos")
	_groups.append("")
	if catalog != null:
		var order := Array(catalog.stamp_groups)
		for s in catalog.stamps:
			if not order.has(s["group"]):
				order.append(s["group"])
		for g in order:
			if catalog.stamps.any(func(s: Dictionary) -> bool: return s["group"] == g):
				_groups.append(g)
				_group.add_item(g)
	_fill_places()
	refresh()


func _option() -> OptionButton:
	var o := OptionButton.new()
	o.fit_to_longest_item = false
	o.clip_text = true
	o.focus_mode = Control.FOCUS_NONE
	add_child(o)
	return o


func _fill_places() -> void:
	_place.clear()
	_places.clear()
	_place.add_item("Todos los lugares")
	_places.append("")
	if catalog == null:
		return
	var only: String = _groups[_group.selected] if _group.selected >= 0 else ""
	var seen := {}
	var list := []
	for s in catalog.stamps:
		if (only == "" or s["group"] == only) and s["place"] != "" and not seen.has(s["place"]):
			seen[s["place"]] = true
			list.append(s["place"])
	list.sort()
	for p in list:
		_places.append(p)
		_place.add_item(p)


func refresh() -> void:
	_list.clear()
	if catalog == null:
		return
	var group: String = _groups[_group.selected] if _group.selected >= 0 else ""
	var place: String = _places[_place.selected] if _place.selected >= 0 else ""
	for s in catalog.stamps:
		if (group != "" and s["group"] != group) or (place != "" and s["place"] != place):
			continue
		var label: String = s["name"] + ("\n" + s["place"] if s["place"] != "" and not (s["name"] as String).contains(s["place"]) else "")
		if s["variants"].size() > 1:
			label += " · %d colores" % s["variants"].size()
		var idx := _list.add_item(label, MapIcons.stamp(s))
		_list.set_item_metadata(idx, s)
		var v: Dictionary = s["variants"][0]
		_list.set_item_tooltip(idx, "%s (%s)\n%d×%d celdas · grupo: %s\nOrigen: mapa %s de FireRed · %d puerta(s)" % [
			s["name"], s["place"], s["size"].x, s["size"].y, s["group"], v["map"], (v["doors"] as PackedInt32Array).size()])


func _on_selected(i: int) -> void:
	_current = _list.get_item_metadata(i)
	_variant.clear()
	for v in _current["variants"]:
		_variant.add_item("Variante: " + (v["name"] if v["name"] != "" else v["map"]))
	_variant.visible = _current["variants"].size() > 1
	stamp_selected.emit(_current, 0)


func deselect() -> void:
	_list.deselect_all()
	_current = {}
	_variant.visible = false
