class_name MapTileProps
extends ScrollContainer
## Pestaña "Propiedades": ver y editar los tags y la colisión de un metatile del TileSet. Guarda el ajuste en
## data/world/tile_roles.tres (así build_world --force no lo pierde) y en art/tiles/world_tileset.tres
## (con backup). Afecta a todas las zonas.

signal applied(metatile: int)

const PHYSICS := ["Ninguna", "Sólida (mundo)", "Agua"]

var roles: TileRoleSet
var tileset: TileSet
var metatile := -1
var _icon: TextureRect
var _icon_above: TextureRect
var _title: Label
var _info: Label
var _tags: LineEdit
var _chips: HFlowContainer
var _physics: OptionButton
var _category: OptionButton
var _cat_keys: PackedStringArray = []
var _hint: Button
var _apply: Button
var _box: VBoxContainer


func setup(p_roles: TileRoleSet, p_tileset: TileSet) -> void:
	roles = p_roles
	tileset = p_tileset
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_box = VBoxContainer.new()
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_theme_constant_override("separation", 8)
	add_child(_box)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	_icon = _tex_rect()
	top.add_child(_icon)
	_icon_above = _tex_rect()
	top.add_child(_icon_above)
	var tb := VBoxContainer.new()
	_title = UiStyle.label("Elegí un tile", 18, UiStyle.ACCENT)
	tb.add_child(_title)
	_info = UiStyle.label("Desde la paleta, o con Alt+clic en el mapa.", 12, UiStyle.TEXT_DIM)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info.custom_minimum_size.x = 150
	tb.add_child(_info)
	top.add_child(tb)
	_box.add_child(top)
	_box.add_child(UiStyle.label("Tags (separados por coma)", 13, UiStyle.TEXT_DIM))
	_tags = LineEdit.new()
	_tags.text_changed.connect(func(_t): _sync_chips())
	_box.add_child(_tags)
	_chips = HFlowContainer.new()
	_box.add_child(_chips)
	_box.add_child(UiStyle.label("Tipo (para la paleta)", 13, UiStyle.TEXT_DIM))
	_category = OptionButton.new()
	_category.focus_mode = Control.FOCUS_NONE
	_category.fit_to_longest_item = false
	if roles.catalog != null:
		for k in roles.catalog.category_order:
			_category.add_item(roles.catalog.category_name(k))
			_cat_keys.append(k)
	_box.add_child(_category)
	_box.add_child(UiStyle.label("Colisión (cuadrado de 16x16)", 13, UiStyle.TEXT_DIM))
	_physics = OptionButton.new()
	_physics.focus_mode = Control.FOCUS_NONE
	for p in PHYSICS:
		_physics.add_item(p)
	_box.add_child(_physics)
	_hint = Button.new()
	_hint.focus_mode = Control.FOCUS_NONE
	_hint.pressed.connect(_use_hint)
	_box.add_child(_hint)
	_apply = UiStyle.button("Aplicar al TileSet…", 200)
	_apply.focus_mode = Control.FOCUS_NONE
	_apply.pressed.connect(_confirm)
	_box.add_child(_apply)
	var warn := UiStyle.label("Cambia este tile en TODAS las zonas. Antes se hace un backup del TileSet.", 12, Color(1, 0.75, 0.4))
	warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warn.custom_minimum_size.x = 260
	_box.add_child(warn)
	_set_enabled(false)


func _tex_rect() -> TextureRect:
	var t := TextureRect.new()
	t.custom_minimum_size = Vector2(64, 64)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return t


func _set_enabled(on: bool) -> void:
	_tags.editable = on
	_physics.disabled = not on
	_category.disabled = not on
	_apply.disabled = not on
	_hint.visible = false


func show_metatile(m: int) -> void:
	metatile = m
	_set_enabled(m >= 0)
	if m < 0:
		return
	_icon.texture = MapIcons.metatile(m)
	_icon_above.texture = MapIcons.metatile(m, true) if ZoneBuilder.has_above(m) else null
	var set_name := ZoneBuilder.set_of(m)
	_title.text = "Metatile %d" % ZoneBuilder.local_of(m)
	var behavior := ZoneBuilder.behavior_of(m)
	var role := roles.role_of(m)
	var info := ["Tileset: " + str(ZoneBuilder.set_info(set_name).get("display", set_name)),
		"Rol: " + (role.display_name if role != null else "—"),
		"Behavior FireRed: 0x%02X" % behavior]
	if ZoneBuilder.is_animated(m):
		info.append("Animado")
	if ZoneBuilder.has_above(m):
		info.append("Con parte de arriba (Overhead)")
	if roles.overrides.has(m):
		info.append("Editado a mano")
	_info.text = "\n".join(info)
	_tags.text = ", ".join(roles.tags_for(m))
	_physics.select(roles.physics_for(m) + 1)
	_category.select(maxi(0, _cat_keys.find(roles.category_for(m))))
	var h: Dictionary = roles.behavior_hints.get(behavior, {})
	_hint.visible = not h.is_empty()
	if not h.is_empty():
		_hint.text = "Sugerir: %s (%s)" % [h["name"], ", ".join(h["tags"])]
	_sync_chips()


func _sync_chips() -> void:
	for c in _chips.get_children():
		c.queue_free()
	var current := _current_tags()
	for t in roles.known_tags():
		var b := Button.new()
		b.text = t
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 11)
		b.set_pressed_no_signal(current.has(t))
		b.toggled.connect(func(on: bool):
			var tags := _current_tags()
			if on and not tags.has(t):
				tags.append(t)
			elif not on:
				tags.remove_at(tags.find(t))
			_tags.text = ", ".join(tags))
		_chips.add_child(b)


func _current_tags() -> PackedStringArray:
	var out := PackedStringArray()
	for t in _tags.text.split(",", false):
		var s := t.strip_edges()
		if s != "" and not out.has(s):
			out.append(s)
	return out


func _use_hint() -> void:
	var h: Dictionary = roles.behavior_hints.get(ZoneBuilder.behavior_of(metatile), {})
	if h.is_empty():
		return
	_tags.text = ", ".join(h["tags"])
	_physics.select(int(h["physics"]) + 1)
	_sync_chips()


func _confirm() -> void:
	var d := ConfirmDialog.ask(get_tree().current_scene.get_node("UI/Root"),
		"¿Aplicar tipo, tags y colisión a este metatile? Cambia en TODAS las zonas (se hace backup del TileSet).",
		["Aplicar", "Cancelar"])
	d.chosen.connect(func(i: int):
		if i == 0:
			var cat: String = _cat_keys[_category.selected] if _category.selected >= 0 and not _cat_keys.is_empty() else ""
			var err := apply_props(roles, tileset, metatile, _current_tags(), _physics.selected - 1, cat)
			if err == OK:
				applied.emit(metatile)
				show_metatile(metatile))


## Guarda tipo, tags y colisión de un metatile: ajuste en tile_roles.tres + TileSet (con backup).
static func apply_props(p_roles: TileRoleSet, p_tileset: TileSet, m: int, tags: PackedStringArray, physics: int, category: String = "") -> Error:
	if FileAccess.file_exists(ZoneBuilder.TILESET_PATH):
		MapDocument.backup_file(ZoneBuilder.TILESET_PATH)
	p_roles.set_override(m, tags, physics, category)
	ZoneBuilder.apply_tile_props(p_tileset, p_roles, m)
	var err := ResourceSaver.save(p_tileset, ZoneBuilder.TILESET_PATH)
	if err == OK:
		err = ResourceSaver.save(p_roles, ZoneBuilder.ROLES_PATH)
	return err
