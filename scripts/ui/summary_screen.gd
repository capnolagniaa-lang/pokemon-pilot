extends Control
## Ficha de un Pokémon del equipo, con dos pestañas (Tab cambia):
##  · Estadísticas: estilo y mecánica de firma, PS, EXP y los 6 stats (valor, base, IV, EV, barra).
##  · Movimientos: las 4 ranuras equipadas y todo el learnset (bloqueados con su nivel). Para equipar:
##    Enter en un movimiento aprendido y después en la ranura (o al revés). Supr vacía una ranura.

signal closed

var party_index := 0
var _inst: CreatureInstance
var _tabs: TabContainer
var _moves_tab: VBoxContainer
var _slot_buttons: Array[Button] = []
var _rows: Array[Button] = []
var _detail: VBoxContainer
var _hint: Label
var _pending_move: MoveData
var _pending_slot := -1
## Botón marcado como elegido (movimiento o ranura) mientras se completa el equipar.
var _marked: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_inst = GameState.party[party_index]
	add_child(UiStyle.dim())
	var root := HBoxContainer.new()
	root.position = Vector2(32, 24)
	root.size = Vector2(1216, 672)
	root.add_theme_constant_override("separation", 18)
	add_child(root)
	root.add_child(_left_column())
	_tabs = TabContainer.new()
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs.custom_minimum_size = Vector2(880, 672)
	root.add_child(_tabs)
	var stats := _stats_tab()
	stats.name = "Estadísticas"
	_tabs.add_child(stats)
	_moves_tab = VBoxContainer.new()
	_moves_tab.name = "Movimientos"
	_moves_tab.add_theme_constant_override("separation", 10)
	_tabs.add_child(_moves_tab)
	_build_moves()
	UiStyle.focus_later(_tabs.get_tab_bar())


func _left_column() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(310, 672)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	var view := PokemonAnimView.new()
	view.species = _inst.species
	view.pixel_scale = 5
	view.custom_minimum_size = Vector2(290, 260)
	box.add_child(view)
	box.add_child(UiStyle.label(_inst.display_name(), 26))
	box.add_child(UiStyle.label("Nv. %d  ·  N.º %03d" % [_inst.level, _inst.species.dex], 18, UiStyle.ACCENT))
	var types := HBoxContainer.new()
	types.add_theme_constant_override("separation", 6)
	for t in _inst.species.types:
		types.add_child(UiStyle.type_chip(t))
	box.add_child(types)
	if party_index == GameState.active_index:
		box.add_child(UiStyle.label("Activo (te sigue)", 14, UiStyle.GOOD))
	if not _inst.species.evolutions.is_empty():  # a qué evoluciona y cómo (Evolution)
		var evo := UiStyle.label("Evoluciona: " + ", ".join(_inst.species.evolutions.map(func(e): return Evolution.describe(e))),
			13, UiStyle.TEXT_DIM)
		evo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		evo.custom_minimum_size.x = 280
		box.add_child(evo)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	box.add_child(UiStyle.label("Tab: cambiar pestaña\nEsc: volver", 13, UiStyle.TEXT_DIM))
	var back := UiStyle.button("Volver", 160)
	back.pressed.connect(func(): closed.emit())
	box.add_child(back)
	return panel


# --- Estadísticas --------------------------------------------------------------------------

func _stats_tab() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	var kit := _inst.species.kit
	if kit != null:
		var arch: String = UiStyle.ARCHETYPES.get(kit.archetype, kit.archetype)
		box.add_child(_wrapped("Estilo de pelea: %s — %s" % [arch, UiStyle.ARCHETYPE_INFO.get(kit.archetype, "")], 16))
		if kit.signature != null:
			box.add_child(UiStyle.label("Mecánica de firma: " + kit.signature.display_name, 16, kit.signature.color.lightened(0.2)))
			box.add_child(_wrapped(kit.signature.description, 14, UiStyle.TEXT_DIM))
	else:
		box.add_child(UiStyle.label("Estilo de pelea: todavía sin kit propio (usa sus movimientos sueltos).", 15, UiStyle.TEXT_DIM))
	box.add_child(HSeparator.new())
	var ratio := _inst.hp / _inst.max_hp()
	box.add_child(UiStyle.label("PS  %d / %d" % [ceili(_inst.hp), ceili(_inst.max_hp())], 16))
	box.add_child(UiStyle.bar(ratio, UiStyle.hp_color(ratio), Vector2(520, 10)))
	box.add_child(UiStyle.label("EXP total %d  ·  faltan %d para Nv. %d  ·  curva %s" % [_inst.experience, _inst.exp_to_next(), _inst.level + 1, _inst.species.growth_rate], 14))
	box.add_child(UiStyle.bar(_inst.exp_progress(), Color(0.4, 0.7, 1.0), Vector2(520, 6)))
	box.add_child(HSeparator.new())
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 8)
	for h in ["Stat", "Valor", "Base", "IV", "EV", ""]:
		grid.add_child(UiStyle.label(h, 13, UiStyle.TEXT_DIM))
	for s in CreatureInstance.STATS:
		var base := _inst.species.base_stat(s)
		grid.add_child(UiStyle.label(UiStyle.STAT_NAMES[s], 16))
		grid.add_child(UiStyle.label(str(_inst.stat(s)) if s != "hp" else "%d (×%d)" % [_inst.stat(s), int(CreatureInstance.hp_scale())], 16, UiStyle.ACCENT))
		grid.add_child(UiStyle.label(str(base), 16))
		grid.add_child(UiStyle.label(str(_inst.ivs.get(s, 0)), 16))
		grid.add_child(UiStyle.label(str(_inst.evs.get(s, 0)), 16))
		var col := Color(0.95, 0.45, 0.3).lerp(Color(0.35, 0.85, 0.45), clampf((base - 30.0) / 70.0, 0.0, 1.0))
		var b := UiStyle.bar(base / 130.0, col, Vector2(240, 10))
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		grid.add_child(b)
	box.add_child(grid)
	box.add_child(UiStyle.label("La barra compara el stat base. IV 31 en todo por ahora (en la Etapa 6 van a variar).", 12, UiStyle.TEXT_DIM))
	box.add_child(UiStyle.label("Velocidad de movimiento: %d px/s" % roundi(Creature.move_speed_for(_inst.stat("speed"))), 14, UiStyle.TEXT_DIM))
	return box


func _wrapped(text: String, size: int, color: Color = UiStyle.TEXT) -> Label:
	var l := UiStyle.label(text, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 820
	return l


# --- Movimientos ---------------------------------------------------------------------------

func _build_moves() -> void:
	for c in _moves_tab.get_children():
		c.queue_free()
	_slot_buttons.clear()
	_rows.clear()
	_moves_tab.add_child(UiStyle.label("Equipados", 15, UiStyle.TEXT_DIM))
	var slots := HBoxContainer.new()
	slots.add_theme_constant_override("separation", 8)
	_moves_tab.add_child(slots)
	for i in CreatureInstance.SLOT_COUNT:
		var m: MoveData = _inst.equipped_moves[i] if i < _inst.equipped_moves.size() else null
		var b := Button.new()
		b.custom_minimum_size = Vector2(206, 64)
		b.focus_mode = Control.FOCUS_ALL
		b.text = "%s\n%s" % [Controls.SLOT_KEYS[i], m.display_name if m != null else "—"]
		if m != null:
			b.add_theme_stylebox_override("normal", UiStyle.box(UiStyle.BG_SOFT, Color(m.element.color, 0.8), 2))
		b.pressed.connect(_on_slot.bind(i))
		b.focus_entered.connect(func():
			# Con un movimiento elegido, el detalle sigue mostrando ese (no el de la ranura que se recorre).
			if _pending_move == null:
				_show_detail(_inst.equipped_moves[i] if i < _inst.equipped_moves.size() else null, 0))
		slots.add_child(b)
		_slot_buttons.append(b)
	var mid := HBoxContainer.new()
	mid.add_theme_constant_override("separation", 12)
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_moves_tab.add_child(mid)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(470, 440)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mid.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 4)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	list.add_child(UiStyle.label("Aprende por nivel", 15, UiStyle.TEXT_DIM))
	for e in _inst.species.learnset_entries():
		list.add_child(_row(e))
	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_child(detail_panel)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 6)
	detail_panel.add_child(_detail)
	_hint = UiStyle.label("", 14, UiStyle.ACCENT)
	_moves_tab.add_child(_hint)
	_update_hint()
	_show_detail(_inst.equipped_moves[0] if not _inst.equipped_moves.is_empty() else null, 0)


func _row(e: LearnsetEntry) -> Button:
	var m := e.move
	var locked := e.level > _inst.level
	var b := Button.new()
	b.focus_mode = Control.FOCUS_ALL
	b.custom_minimum_size = Vector2(450, 34)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var equipped := _inst.equipped_moves.has(m)
	b.text = "Nv. %2d   %s%s" % [e.level, m.display_name, "   (equipado)" if equipped else ""]
	if locked:
		b.text = "Nv. %2d   %s   — BLOQUEADO" % [e.level, m.display_name]
		b.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
		b.add_theme_color_override("font_focus_color", Color(1, 1, 1, 0.55))
	else:
		b.add_theme_color_override("font_color", m.element.color.lightened(0.45))
	b.pressed.connect(_on_row.bind(m, locked, b))
	b.focus_entered.connect(func():
		if _pending_move == null:
			_show_detail(m, e.level))
	_rows.append(b)
	return b


func _show_detail(m: MoveData, level: int) -> void:
	if _detail == null:
		return
	for c in _detail.get_children():
		c.queue_free()
	if m == null:
		_detail.add_child(UiStyle.label("Ranura vacía", 16, UiStyle.TEXT_DIM))
		return
	_detail.add_child(UiStyle.label(m.display_name, 22, m.element.color.lightened(0.3)))
	var chips := HBoxContainer.new()
	chips.add_theme_constant_override("separation", 6)
	chips.add_child(UiStyle.type_chip(m.element))
	chips.add_child(UiStyle.label("%s · %s" % [UiStyle.CATEGORY.get(m.category, ""), UiStyle.KIND.get(m.kind, "")], 14))
	_detail.add_child(chips)
	for line in describe(m):
		var l := UiStyle.label(line, 14)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 330
		_detail.add_child(l)
	if level > _inst.level:
		_detail.add_child(UiStyle.label("Se aprende al Nv. %d" % level, 14, UiStyle.BAD))


## Líneas con los datos de un movimiento (potencia, recarga, carga, estados, recurso de firma...).
static func describe(m: MoveData) -> Array[String]:
	var out: Array[String] = []
	if m.zone_strike:
		out.append("Sale bajo tierra donde apuntás" if m.strike_burrow else ("Cae del cielo donde apuntás" + (" (×%d)" % m.strike_count if m.strike_count > 1 else "")))
	if m.power > 0.0:
		var p := roundi(m.power * m.power_mult)
		if m.kind == MoveData.Kind.PROJECTILE and m.projectile_count > 1:
			out.append("Potencia: %d × %d proyectiles" % [p, m.projectile_count])
		elif m.kind == MoveData.Kind.MELEE and m.combo_steps > 1:
			out.append("Potencia: %d por golpe (combo de %d)" % [p, m.combo_steps])
		elif m.kind == MoveData.Kind.CHANNEL:
			out.append("Potencia: %d por tick durante %.1f s" % [p, m.channel_time])
		else:
			out.append("Potencia: %d" % p)
	else:
		out.append("Sin daño")
	out.append("Recarga: %.1f s" % m.cooldown)
	if m.cast_time > 0.0:
		out.append("Carga: %.2f s (se telegrafía)" % m.cast_time)
	if m.recovery > 0.0:
		out.append("Recuperación: %.2f s" % m.recovery)
	var st: Array[String] = []
	if m.status != null and m.status_chance > 0.0:
		st.append("%s %d%%" % [m.status.display_name, roundi(m.status_chance * 100.0)])
	for s in m.statuses_on_hit:
		st.append(s.display_name)
	if m.dwell_status != null:
		st.append("%s si se queda %.1f s" % [m.dwell_status.display_name, m.dwell_time])
	if m.trail_status != null:
		st.append("estela: %s" % m.trail_status.display_name)
	if m.self_status != null:
		st.append("a sí mismo: %s" % m.self_status.display_name)
	if not st.is_empty():
		out.append("Estados: " + ", ".join(st))
	if m.execute_below > 0.0:
		out.append("Remata si el objetivo tiene menos del %d%% de vida" % roundi(m.execute_below * 100.0))
	if m.drain > 0.0:
		out.append("Se cura el %d%% del daño" % roundi(m.drain * 100.0))
	if m.cooldown_lock > 0.0:
		out.append("Alarga %.1f s las recargas del rival" % m.cooldown_lock)
	if m.deflects_projectiles:
		out.append("Desvía proyectiles enemigos")
	if m.resource_cost != 0.0 or m.resource_scaling > 0.0:
		out.append("Usa el recurso de la mecánica de firma")
	return out


func _on_slot(i: int) -> void:
	if _pending_move != null:
		_equip(i, _pending_move)
		return
	_pending_slot = i
	_mark(_slot_buttons[i])
	_update_hint()
	for r in _rows:
		if not r.disabled:
			r.grab_focus()
			break


func _on_row(m: MoveData, locked: bool, row: Button) -> void:
	if locked:
		_hint.text = "Todavía no lo aprendió."
		return
	if _pending_slot >= 0:
		_equip(_pending_slot, m)
		return
	# Queda seleccionado (marcado y con su detalle a la vista) hasta elegir la ranura o cancelar.
	_pending_move = m
	_mark(row)
	_show_detail(m, 0)
	_update_hint()
	_slot_buttons[0].grab_focus()


## Marca el botón elegido (movimiento o ranura) mientras se completa la elección.
func _mark(b: Button) -> void:
	_unmark()
	_marked = b
	var style := UiStyle.box(Color(0.24, 0.2, 0.08, 0.98), UiStyle.ACCENT, 2)
	for state in ["normal", "hover", "focus"]:
		b.add_theme_stylebox_override(state, style)


func _unmark() -> void:
	if is_instance_valid(_marked):
		for state in ["normal", "hover", "focus"]:
			_marked.remove_theme_stylebox_override(state)
	_marked = null


func _equip(slot: int, m: MoveData) -> void:
	var ok := _inst.equip(slot, m)
	var msg := ("%s equipado en %s." % [m.display_name, Controls.SLOT_KEYS[slot]]) if m != null else "Ranura vaciada."
	if not ok:
		msg = "No se puede: tiene que quedar al menos un movimiento." if m == null else "No se puede equipar."
	_pending_move = null
	_pending_slot = -1
	if ok:
		Events.equipment_changed.emit(_inst)
	_build_moves()
	_hint.text = msg
	UiStyle.focus_later(_slot_buttons[slot])


func _update_hint() -> void:
	if _pending_move != null:
		_hint.text = "Elegí la ranura para %s (Esc cancela)." % _pending_move.display_name
	elif _pending_slot >= 0:
		_hint.text = "Elegí el movimiento para %s (Esc cancela)." % Controls.SLOT_KEYS[_pending_slot]
	else:
		_hint.text = "Enter en un movimiento y después en una ranura para equiparlo · Supr vacía una ranura."


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_TAB:
		_tabs.current_tab = (_tabs.current_tab + 1) % _tabs.get_tab_count()
		if _tabs.current_tab == 1 and not _slot_buttons.is_empty():
			_slot_buttons[0].grab_focus()
		else:
			_tabs.get_tab_bar().grab_focus()
		get_viewport().set_input_as_handled()
	elif event.physical_keycode == KEY_DELETE or event.physical_keycode == KEY_BACKSPACE:
		var i := _slot_buttons.find(get_viewport().gui_get_focus_owner())
		if i >= 0:
			_equip(i, null)
			get_viewport().set_input_as_handled()


## Esc: primero cancela una elección a medias; si no hay, vuelve al Equipo.
func back() -> bool:
	if _pending_move != null or _pending_slot >= 0:
		_pending_move = null
		_pending_slot = -1
		_unmark()
		_update_hint()
		return false
	return true
