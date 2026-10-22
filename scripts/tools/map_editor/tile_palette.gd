class_name MapTilePalette
extends VBoxContainer
## Pestaña "Tiles" (modo tile crudo): todos los metatiles del TileSet (abajo, animados y parte de arriba),
## agrupados por tags y con filtros. Pasando el mouse se ve el número de metatile y sus tags.

signal tile_selected(source: int, coords: Vector2i, metatile: int)

const FILTERS := ["Todos", "Con tags", "Sin tags", "Con colisión", "Animados", "Parte de arriba (Overhead)"]

var roles: TileRoleSet
var _filter: OptionButton
var _tag: OptionButton
var _list: ItemList
var _count: Label


func setup(p_roles: TileRoleSet) -> void:
	roles = p_roles
	add_theme_constant_override("separation", 6)
	var row := VBoxContainer.new()
	_filter = OptionButton.new()
	_filter.fit_to_longest_item = false
	_filter.clip_text = true
	for f in FILTERS:
		_filter.add_item(f)
	_filter.focus_mode = Control.FOCUS_NONE
	_filter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_filter.item_selected.connect(func(_i): refresh())
	row.add_child(_filter)
	_tag = OptionButton.new()
	_tag.fit_to_longest_item = false
	_tag.clip_text = true
	_tag.focus_mode = Control.FOCUS_NONE
	_tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tag.item_selected.connect(func(_i): refresh())
	row.add_child(_tag)
	add_child(row)
	_count = UiStyle.label("", 12, UiStyle.TEXT_DIM)
	add_child(_count)
	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.max_columns = 0
	_list.same_column_width = true
	_list.icon_mode = ItemList.ICON_MODE_TOP
	_list.fixed_icon_size = Vector2i(32, 32)
	_list.icon_scale = 1.0
	_list.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_list.focus_mode = Control.FOCUS_NONE
	_list.item_selected.connect(_on_selected)
	add_child(_list)
	_fill_tags()
	refresh()


func _fill_tags() -> void:
	var keep := _tag.get_item_text(_tag.selected) if _tag.selected >= 0 else ""
	_tag.clear()
	_tag.add_item("Cualquier tag")
	for t in roles.known_tags():
		_tag.add_item(t)
		if t == keep:
			_tag.select(_tag.item_count - 1)


## Rearma la lista (después de editar tags o colisión de un tile).
func refresh() -> void:
	_fill_tags()
	_list.clear()
	var m := ZoneBuilder.manifest()
	var count := int(m["count"])
	var tag := _tag.get_item_text(_tag.selected) if _tag.selected > 0 else ""
	var above_mode := _filter.selected == 5
	var entries := []
	for i in count:
		if above_mode and not m["above_used"][i]:
			continue
		var tags := roles.tags_for(i)
		var physics := roles.physics_for(i)
		var keep: bool = [true, not tags.is_empty(), tags.is_empty(), physics >= 0, ZoneBuilder.is_animated(i), true][_filter.selected]
		if not keep or (tag != "" and not tags.has(tag)):
			continue
		entries.append([",".join(tags) if not tags.is_empty() else "~", i, tags, physics])
	entries.sort_custom(func(a, b): return a[0] < b[0] or (a[0] == b[0] and a[1] < b[1]))
	for e in entries:
		var id: int = e[1]
		var idx := _list.add_icon_item(MapIcons.metatile(id, above_mode))
		var ref: Array = [ZoneBuilder.SRC_ABOVE, Vector2i(id % 16, id / 16)] if above_mode else ZoneBuilder.below_ref(id)
		_list.set_item_metadata(idx, [ref[0], ref[1], id])
		_list.set_item_tooltip(idx, tooltip(roles, id, above_mode))
	_count.text = "%d tiles · agrupados por tags" % entries.size()


static func tooltip(p_roles: TileRoleSet, id: int, above: bool = false) -> String:
	var tags := p_roles.tags_for(id)
	var phys: int = p_roles.physics_for(id)
	var lines := ["Metatile %d%s" % [id, " (parte de arriba)" if above else ""],
		"Tags: " + (", ".join(tags) if not tags.is_empty() else "—"),
		"Colisión: " + ["ninguna", "sólida", "agua"][phys + 1]]
	if ZoneBuilder.is_animated(id):
		lines.append("Animado")
	if ZoneBuilder.has_above(id) and not above:
		lines.append("Tiene parte de arriba (va también en Overhead)")
	return "\n".join(lines)


func _on_selected(idx: int) -> void:
	var meta: Array = _list.get_item_metadata(idx)
	tile_selected.emit(meta[0], meta[1], meta[2])


func deselect() -> void:
	_list.deselect_all()
