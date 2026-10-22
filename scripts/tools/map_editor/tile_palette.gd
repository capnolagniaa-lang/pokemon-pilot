class_name MapTilePalette
extends VBoxContainer
## Pestaña "Tiles" (modo tile crudo): todos los metatiles de FireRed importados, organizados por tipo
## (edificios, terreno, agua, escaleras, rocas...; categorías de data/world/tile_catalog.tres), con filtros por
## grupo (exteriores / interiores), tileset y tags. Pasando el mouse se ve el metatile, su tileset y sus tags.

signal tile_selected(source: int, coords: Vector2i, metatile: int)

const GROUPS := [["exterior", "Exteriores"], ["interior", "Interiores"], ["", "Todos los grupos"]]
const EXTRA := ["Con colisión", "Sin tags", "Animados", "Parte de arriba (Overhead)"]
## Más que esto no se muestra de una vez (la lista se vuelve lenta): pedir un filtro más fino.
const MAX_ITEMS := 1500

var roles: TileRoleSet
var _group: OptionButton
var _set: OptionButton
var _category: OptionButton
var _tag: OptionButton
var _list: ItemList
var _count: Label
var _set_names: PackedStringArray = []
var _cat_keys: PackedStringArray = []


func setup(p_roles: TileRoleSet) -> void:
	roles = p_roles
	add_theme_constant_override("separation", 4)
	_group = _option()
	for g in GROUPS:
		_group.add_item(g[1])
	_group.item_selected.connect(func(_i): _fill_sets(); refresh())
	_set = _option()
	_set.item_selected.connect(func(_i): refresh())
	_category = _option()
	_category.item_selected.connect(func(_i): refresh())
	_tag = _option()
	_tag.item_selected.connect(func(_i): refresh())
	_count = UiStyle.label("", 12, UiStyle.TEXT_DIM)
	add_child(_count)
	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.max_columns = 0
	_list.same_column_width = true
	_list.icon_mode = ItemList.ICON_MODE_TOP
	_list.fixed_icon_size = Vector2i(32, 32)
	_list.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_list.focus_mode = Control.FOCUS_NONE
	_list.item_selected.connect(_on_selected)
	add_child(_list)
	_fill_categories()
	_fill_sets()
	_fill_tags()
	refresh()


func _option() -> OptionButton:
	var o := OptionButton.new()
	o.fit_to_longest_item = false
	o.clip_text = true
	o.focus_mode = Control.FOCUS_NONE
	o.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(o)
	return o


func _fill_sets() -> void:
	var group: String = GROUPS[maxi(0, _group.selected)][0]
	_set.clear()
	_set_names.clear()
	_set.add_item("Todos los tilesets")
	_set_names.append("")
	var entries := []
	for n in ZoneBuilder.set_names():
		var info := ZoneBuilder.set_info(n)
		if group == "" or info.get("group", "exterior") == group:
			entries.append([info.get("display", n), n])
	entries.sort()
	for e in entries:
		_set.add_item(e[0])
		_set_names.append(e[1])
	# Por defecto: el general (exteriores) o el primero del grupo, así no se cargan miles de tiles de una.
	var default := _set_names.find("general") if group != "interior" else _set_names.find("building")
	_set.select(maxi(default, 1 if _set_names.size() > 1 else 0))


func _fill_categories() -> void:
	_category.clear()
	_cat_keys.clear()
	_category.add_item("Todos los tipos")
	_cat_keys.append("")
	if roles.catalog != null:
		for k in roles.catalog.category_order:
			_category.add_item(roles.catalog.category_name(k))
			_cat_keys.append(k)
	for i in EXTRA.size():
		_category.add_item(EXTRA[i])
		_cat_keys.append("extra:%d" % i)


func _fill_tags() -> void:
	var keep := _tag.get_item_text(_tag.selected) if _tag.selected > 0 else ""
	_tag.clear()
	_tag.add_item("Cualquier tag")
	for t in roles.known_tags():
		_tag.add_item(t)
		if t == keep:
			_tag.select(_tag.item_count - 1)


## Elige filtros desde afuera (tileset y categoría); "" = todos.
func set_filters(set_name: String, category: String) -> void:
	if set_name != "":
		var info := ZoneBuilder.set_info(set_name)
		_group.select(0 if info.get("group", "exterior") == "exterior" else 1)
		_fill_sets()
		_set.select(maxi(0, _set_names.find(set_name)))
	elif _set_names.size() > 0:
		_set.select(0)
	_category.select(maxi(0, _cat_keys.find(category)))
	refresh()


## Rearma la lista (después de editar tags, colisión o categoría de un tile).
func refresh() -> void:
	_fill_tags()
	_list.clear()
	var group: String = GROUPS[maxi(0, _group.selected)][0]
	var only_set: String = _set_names[_set.selected] if _set.selected >= 0 else ""
	var cat: String = _cat_keys[_category.selected] if _category.selected >= 0 else ""
	var tag := _tag.get_item_text(_tag.selected) if _tag.selected > 0 else ""
	var above_mode := cat == "extra:3"
	var order := {}
	if roles.catalog != null:
		for i in roles.catalog.category_order.size():
			order[roles.catalog.category_order[i]] = i
	var entries := []
	for n in ZoneBuilder.set_names():
		var info := ZoneBuilder.set_info(n)
		if (only_set != "" and n != only_set) or (group != "" and info.get("group", "exterior") != group):
			continue
		var base := ZoneBuilder.base_of(n)
		for l in int(info["count"]):
			var id := base + l
			if not ZoneBuilder.exists(id) or (above_mode and not info["above_used"][l]):
				continue
			var c := roles.category_for(id)
			var tags := roles.tags_for(id)
			var keep := true
			match cat:
				"", "extra:3":
					keep = true
				"extra:0":
					keep = roles.physics_for(id) >= 0
				"extra:1":
					keep = tags.is_empty()
				"extra:2":
					keep = ZoneBuilder.is_animated(id)
				_:
					keep = c == cat
			if not keep:
				continue
			if tag != "" and not tags.has(tag):
				continue
			entries.append([order.get(c, 99), id])
	entries.sort()
	var shown := mini(entries.size(), MAX_ITEMS)
	for i in shown:
		var id: int = entries[i][1]
		var idx := _list.add_icon_item(MapIcons.metatile(id, true) if above_mode else MapIcons.metatile_full(id))
		var ref: Array = ZoneBuilder.above_ref(id) if above_mode else ZoneBuilder.below_ref(id)
		_list.set_item_metadata(idx, [ref[0], ref[1], id])
		_list.set_item_tooltip(idx, tooltip(roles, id, above_mode))
	_count.text = "%d tiles · ordenados por tipo" % entries.size() if shown == entries.size() \
		else "Mostrando %d de %d: elegí un tileset o un tipo" % [shown, entries.size()]


static func tooltip(p_roles: TileRoleSet, id: int, above: bool = false) -> String:
	var tags := p_roles.tags_for(id)
	var phys: int = p_roles.physics_for(id)
	var set_name := ZoneBuilder.set_of(id)
	var cat := p_roles.category_for(id)
	var lines := ["Metatile %d de %s%s" % [ZoneBuilder.local_of(id), ZoneBuilder.set_info(set_name).get("display", set_name), " (parte de arriba)" if above else ""],
		"Tipo: " + (p_roles.catalog.category_name(cat) if p_roles.catalog != null and cat != "" else "—"),
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
