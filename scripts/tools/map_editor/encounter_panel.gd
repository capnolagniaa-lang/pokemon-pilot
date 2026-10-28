class_name MapEncounterPanel
extends ScrollContainer
## Pestaña "Salvajes" del editor de mapas: qué Pokémon aparecen en la zona (tabla de encuentros: especie,
## %, niveles y dónde), copiar una tabla real de FireRed, densidad y reaparición, y áreas pintadas en el mapa
## donde el % de algunos Pokémon cambia (o aparecen otros). Edita MapDocument.encounters (con deshacer).

signal paint_area_requested(area: int)

var doc: MapDocument
var _box: VBoxContainer
var _area := -1      # área elegida para ver/editar sus ajustes
var _self_edit := false
var _templates: Array = []


func setup() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_box = VBoxContainer.new()
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_theme_constant_override("separation", 6)
	add_child(_box)
	_templates = EncounterTable.templates()


func bind(p_doc: MapDocument) -> void:
	doc = p_doc
	_area = -1
	doc.encounters_changed.connect(func():
		if not _self_edit:
			refresh())
	refresh()


## Elige un área (por ejemplo al pintarla) y muestra sus ajustes.
func select_area(i: int) -> void:
	_area = i
	refresh()


func current_area() -> int:
	return _area


## Cambia la tabla sin rearmar el panel (para no perder el foco del campo que se está editando).
func _edit(fn: Callable, action: String, rebuild: bool = false) -> void:
	_self_edit = not rebuild
	doc.edit_encounters(fn, action)
	_self_edit = false
	if rebuild:
		refresh()
	else:
		_update_totals()


func refresh() -> void:
	for c in _box.get_children():
		c.queue_free()
	if doc == null:
		return
	var t := doc.effective_encounters()
	var own := doc.encounters != null
	_box.add_child(UiStyle.label("Pokémon salvajes", 16, UiStyle.ACCENT))
	var src := UiStyle.label(("Tabla propia de %s." % doc.entry.display_name) if own else
		("Usa la tabla del bioma \"%s\": cualquier cambio crea la propia de la zona." % doc.entry.biome), 12, UiStyle.TEXT_DIM)
	src.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	src.custom_minimum_size.x = 280
	_box.add_child(src)
	var tpl := OptionButton.new()
	tpl.fit_to_longest_item = false
	tpl.clip_text = true
	tpl.focus_mode = Control.FOCUS_NONE
	tpl.add_item("Copiar de FireRed…")
	for x in _templates:
		tpl.add_item(x["name"])
	tpl.item_selected.connect(func(i: int):
		if i <= 0:
			return
		var src_t := EncounterTable.from_template(_templates[i - 1])
		var apply := func(tt: EncounterTable): tt.entries = src_t.entries
		_edit(apply, "Copiar de FireRed: " + _templates[i - 1]["name"], true))
	_box.add_child(tpl)
	if own:
		var reset := _button("Volver a la tabla del bioma", "Borra la tabla propia de la zona al guardar")
		reset.pressed.connect(func():
			doc.use_biome_encounters()
			refresh())
		_box.add_child(reset)
	var dens := HBoxContainer.new()
	dens.add_child(UiStyle.label("Vivos a la vez", 12, UiStyle.TEXT_DIM))
	var alive := _spin(1, 12, t.max_alive if t else 3)
	alive.value_changed.connect(func(v: float): _edit(func(tt: EncounterTable): tt.max_alive = int(v), "Salvajes a la vez"))
	dens.add_child(alive)
	dens.add_child(UiStyle.label("Reaparece (s)", 12, UiStyle.TEXT_DIM))
	var resp := _spin(3, 300, t.respawn_time if t else 25)
	resp.value_changed.connect(func(v: float): _edit(func(tt: EncounterTable): tt.respawn_time = v, "Tiempo de reaparición"))
	dens.add_child(resp)
	_box.add_child(dens)
	_rows_editor(t.entries if t else [], -1)
	# Áreas pintadas
	_box.add_child(HSeparator.new())
	_box.add_child(UiStyle.label("Áreas pintadas", 16, UiStyle.ACCENT))
	var help := UiStyle.label("Pintá un área en el mapa y cambiá ahí el % de algún Pokémon (o sumá uno que aparezca solo ahí; 0% = ahí no sale).", 12, UiStyle.TEXT_DIM)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.custom_minimum_size.x = 280
	_box.add_child(help)
	var areas: Array = t.areas if t else []
	var list := VBoxContainer.new()
	for i in areas.size():
		var a: EncounterArea = areas[i]
		var row := HBoxContainer.new()
		var sw := ColorRect.new()
		sw.color = a.color
		sw.custom_minimum_size = Vector2(16, 16)
		sw.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(sw)
		var b := Button.new()
		b.text = "%s · %d celdas" % [a.name, a.cells.size()]
		b.toggle_mode = true
		b.button_pressed = i == _area
		b.focus_mode = Control.FOCUS_NONE
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(func(): select_area(i))
		row.add_child(b)
		var paint := Button.new()
		paint.text = "Pintar"
		paint.tooltip_text = "Pintar esta área en el mapa (pincel, rectángulo o balde; clic derecho borra)"
		paint.focus_mode = Control.FOCUS_NONE
		paint.pressed.connect(func():
			select_area(i)
			paint_area_requested.emit(i))
		row.add_child(paint)
		list.add_child(row)
	_box.add_child(list)
	var new_area := _button("Nueva área", "Crea un área vacía y la deja lista para pintar")
	new_area.pressed.connect(func():
		var n: int = areas.size()
		var make := func(tt: EncounterTable):
			var a := EncounterArea.new()
			a.name = "Área %d" % (n + 1)
			a.color = EncounterArea.PALETTE[n % EncounterArea.PALETTE.size()]
			tt.areas.append(a)
		_edit(make, "Nueva área", true)
		select_area(n)
		paint_area_requested.emit(n))
	_box.add_child(new_area)
	if _area >= 0 and _area < areas.size():
		var a: EncounterArea = areas[_area]
		_box.add_child(UiStyle.label("Ajustes de \"%s\"" % a.name, 14, a.color))
		var name_row := HBoxContainer.new()
		var name_edit := LineEdit.new()
		name_edit.text = a.name
		name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var ai := _area
		name_edit.text_submitted.connect(func(txt: String): _edit(func(tt: EncounterTable): tt.areas[ai].name = txt, "Nombre del área", true))
		name_row.add_child(name_edit)
		var del := Button.new()
		del.text = "Borrar área"
		del.focus_mode = Control.FOCUS_NONE
		del.pressed.connect(func():
			_area = -1
			_edit(func(tt: EncounterTable): tt.areas.remove_at(ai), "Borrar área", true))
		name_row.add_child(del)
		_box.add_child(name_row)
		_rows_editor(a.adjustments, _area)
		var result := UiStyle.label(_area_result(t, a), 12, a.color)
		result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		result.custom_minimum_size.x = 280
		result.set_meta("area_result", _area)
		_box.add_child(result)


func _button(text: String, tip: String) -> Button:
	var b := UiStyle.button(text, 260)
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size.y = 30
	b.tooltip_text = tip
	return b


func _spin(lo: float, hi: float, v: float) -> SpinBox:
	var s := SpinBox.new()
	s.min_value = lo
	s.max_value = hi
	s.value = v
	s.custom_minimum_size.x = 58
	s.select_all_on_focus = true
	s.get_line_edit().add_theme_constant_override("minimum_character_width", 1)  # que entren en el panel
	s.get_line_edit().add_theme_font_size_override("font_size", 13)
	return s


## Filas de la tabla (area = -1) o de los ajustes de un área.
func _rows_editor(rows: Array, area: int) -> void:
	var holder := VBoxContainer.new()
	holder.add_theme_constant_override("separation", 4)
	for i in rows.size():
		holder.add_child(_row(rows[i], i, area))
	_box.add_child(holder)
	var total := UiStyle.label("", 12, UiStyle.TEXT_DIM)
	total.set_meta("totals", area)
	_box.add_child(total)
	var add := _button("Agregar Pokémon" if area < 0 else "Agregar ajuste (Pokémon y su % acá)", "")
	add.pressed.connect(func():
		var picker := MapSpeciesPicker.open(get_tree().current_scene.get_node("UI/Root"))
		picker.picked.connect(func(id: String): add_species(id, area)))
	_box.add_child(add)
	_update_totals()


## Suma un Pokémon a la tabla (area = -1) o a los ajustes de un área (arranca con los niveles y el lugar
## que tiene en la tabla de la zona, si está).
func add_species(id: String, area: int) -> void:
	var fn := func(tt: EncounterTable):
		var e := EncounterEntry.new()
		e.species_id = id
		var base := _base_row(tt, id)
		if base != null:
			e.min_level = base.min_level
			e.max_level = base.max_level
			e.where = base.where
			e.weight = base.weight
		_rows_of(tt, area).append(e)
	_edit(fn, "Agregar " + id, true)


func _row(e: EncounterEntry, i: int, area: int) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG_SOFT, UiStyle.BORDER, 1, 4))
	var v := VBoxContainer.new()
	panel.add_child(v)
	var top := HBoxContainer.new()
	var sp: SpeciesData = DB.species.get(e.species_id)
	var pic := TextureRect.new()
	pic.texture = DB.portrait_of(sp) if sp != null else null
	pic.custom_minimum_size = Vector2(28, 28)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	top.add_child(pic)
	var name := Button.new()
	name.text = ("#%03d %s" % [sp.dex, sp.display_name]) if sp != null else ("(nada)" if e.species_id == "" else "¿%s?" % e.species_id)
	name.tooltip_text = "Cambiar de Pokémon"
	name.focus_mode = Control.FOCUS_NONE
	name.flat = true
	name.clip_text = true
	name.custom_minimum_size.x = 40
	name.add_theme_font_size_override("font_size", 13)
	name.alignment = HORIZONTAL_ALIGNMENT_LEFT
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.pressed.connect(func():
		var picker := MapSpeciesPicker.open(get_tree().current_scene.get_node("UI/Root"))
		picker.picked.connect(func(id: String): _edit(func(tt: EncounterTable): _rows_of(tt, area)[i].species_id = id, "Cambiar Pokémon", true)))
	top.add_child(name)
	var where := OptionButton.new()
	where.fit_to_longest_item = false
	where.clip_text = true
	where.custom_minimum_size.x = 88
	where.add_theme_font_size_override("font_size", 12)
	where.focus_mode = Control.FOCUS_NONE
	var keys := EncounterTable.WHERE.keys()
	for k in keys:
		where.add_item(EncounterTable.WHERE[k])
	where.select(maxi(0, keys.find(e.where)))
	where.item_selected.connect(func(k: int): _edit(func(tt: EncounterTable): _rows_of(tt, area)[i].where = keys[k], "Dónde aparece"))
	top.add_child(where)
	var del := Button.new()
	del.text = "✕"
	del.tooltip_text = "Sacar"
	del.focus_mode = Control.FOCUS_NONE
	del.pressed.connect(func(): _edit(func(tt: EncounterTable): _rows_of(tt, area).remove_at(i), "Sacar Pokémon", true))
	top.add_child(del)
	v.add_child(top)
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 3)
	var w := _spin(0, 100, e.weight)
	w.suffix = "%"
	w.tooltip_text = "Probabilidad (peso frente a los demás del mismo lugar)"
	w.value_changed.connect(func(x: float): _edit(func(tt: EncounterTable): _rows_of(tt, area)[i].weight = int(x), "% de aparición"))
	bottom.add_child(w)
	bottom.add_child(UiStyle.label("Nv", 12, UiStyle.TEXT_DIM))
	var lo := _spin(1, 100, e.min_level)
	lo.custom_minimum_size.x = 50
	lo.value_changed.connect(func(x: float): _edit(func(tt: EncounterTable): _rows_of(tt, area)[i].min_level = int(x), "Nivel mínimo"))
	bottom.add_child(lo)
	var hi := _spin(1, 100, e.max_level)
	hi.custom_minimum_size.x = 50
	hi.value_changed.connect(func(x: float): _edit(func(tt: EncounterTable): _rows_of(tt, area)[i].max_level = int(x), "Nivel máximo"))
	bottom.add_child(hi)

	v.add_child(bottom)
	return panel


static func _rows_of(t: EncounterTable, area: int) -> Array[EncounterEntry]:
	return t.entries if area < 0 else t.areas[area].adjustments


## Fila de la tabla de la zona de una especie (para copiar niveles y lugar a un ajuste de área).
static func _base_row(t: EncounterTable, id: String) -> EncounterEntry:
	for e in t.entries:
		if e.species_id == id:
			return e
	return null


## Cómo queda el área en porcentajes reales (los % de la tabla son pesos: un ajuste de 40 frente a otros cuatro
## de 25 termina en 29%).
func _area_result(t: EncounterTable, a: EncounterArea) -> String:
	for c in a.cells:
		var ch := t.chances_at(c, doc.zone.get_tags(c))
		if ch.is_empty():
			continue
		var keys := ch.keys()
		keys.sort_custom(func(x, y): return ch[x] > ch[y])
		var bits := []
		for k in keys:
			bits.append("%s %d%%" % [DB.species[k].display_name if DB.species.has(k) else k, roundi(ch[k] * 100.0)])
		return "Queda así en el área: " + ", ".join(bits)
	return "Pintá el área en el mapa para ver cómo queda." if a.cells.is_empty() else "En el área no puede aparecer nada."


## "Suma de %" por lugar (los % son pesos: no hace falta que den 100, pero ayuda verlo).
func _update_totals() -> void:
	var t := doc.effective_encounters()
	for c in _box.get_children():
		if not c.has_meta("totals"):
			continue
		var area: int = c.get_meta("totals")
		var rows: Array = (t.entries if area < 0 else (t.areas[area].adjustments if area < t.areas.size() else [])) if t else []
		var by := {}
		for e in rows:
			by[e.where] = by.get(e.where, 0) + e.weight
		var parts := []
		for w in by:
			parts.append("%s %d%%" % [EncounterTable.WHERE.get(w, w), by[w]])
		(c as Label).text = ("Suma: " + " · ".join(parts)) if not parts.is_empty() else "Sin Pokémon."
	for c in _box.get_children():
		if c.has_meta("area_result") and t != null and int(c.get_meta("area_result")) < t.areas.size():
			(c as Label).text = _area_result(t, t.areas[int(c.get_meta("area_result"))])
