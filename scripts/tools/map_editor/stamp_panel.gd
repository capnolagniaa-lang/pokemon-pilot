class_name MapStampPanel
extends VBoxContainer
## Pestaña "Sellos": edificios enteros sacados de los mapas reales de FireRed (casas, Centro Pokémon, Tienda,
## gimnasios...), sin repetidos, filtrables por lugar. Un clic en el mapa pega el edificio (con su parte de
## arriba y su colisión). Salen de data/world/tile_catalog.tres → stamps.

signal stamp_selected(stamp: Dictionary)

var catalog: TileCatalog
var _place: OptionButton
var _list: ItemList
var _places: PackedStringArray = []


func setup(p_catalog: TileCatalog) -> void:
	catalog = p_catalog
	add_theme_constant_override("separation", 4)
	_place = OptionButton.new()
	_place.fit_to_longest_item = false
	_place.clip_text = true
	_place.focus_mode = Control.FOCUS_NONE
	_place.item_selected.connect(func(_i): refresh())
	add_child(_place)
	var tip := UiStyle.label("Clic en el mapa: esquina de arriba a la izquierda del edificio.", 12, UiStyle.TEXT_DIM)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size.x = 260
	add_child(tip)
	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.max_columns = 0
	_list.same_column_width = true
	_list.icon_mode = ItemList.ICON_MODE_TOP
	_list.fixed_icon_size = Vector2i(132, 92)
	_list.max_text_lines = 2
	_list.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_list.focus_mode = Control.FOCUS_NONE
	_list.add_theme_font_size_override("font_size", 11)
	_list.item_selected.connect(func(i: int): stamp_selected.emit(_list.get_item_metadata(i)))
	add_child(_list)
	_place.add_item("Todos los lugares")
	_places.append("")
	if catalog != null:
		var seen := {}
		for s in catalog.stamps:
			if not seen.has(s["place"]):
				seen[s["place"]] = true
				_places.append(s["place"])
				_place.add_item(s["place"])
	refresh()


func refresh() -> void:
	_list.clear()
	if catalog == null:
		return
	var only: String = _places[_place.selected] if _place.selected >= 0 else ""
	for s in catalog.stamps:
		if only != "" and s["place"] != only:
			continue
		var idx := _list.add_item("%s\n%s" % [s["place"], s["name"]], MapIcons.stamp(s))
		_list.set_item_metadata(idx, s)
		_list.set_item_tooltip(idx, "%s (%s)\n%d×%d celdas · aparece en %d mapa(s) de FireRed" % [s["name"], s["place"], s["size"].x, s["size"].y, s["maps"]])


func deselect() -> void:
	_list.deselect_all()
