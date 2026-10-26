extends Control
## Mochila (Esc → Mochila; docs/PLAN_CAPTURA_MOCHILA.md): bolsillos como en FireRed (Objetos, Pokéballs,
## Objetos clave; Tab cambia), lista con cantidades y descripción oficial. Acciones: usar un objeto sobre un
## Pokémon del equipo, elegir la bola que lanza E y el objeto de la ranura rápida (C).

signal closed

const POCKETS := [["Objetos", ItemData.Pocket.ITEMS], ["Pokéballs", ItemData.Pocket.BALLS], ["Objetos clave", ItemData.Pocket.KEY]]

var _pocket := 0
var _pocket_buttons: Array[Button] = []
var _list: VBoxContainer
var _detail: VBoxContainer
var _status: Label
var _chooser: PanelContainer
var _selected: ItemData
var _rows: Array[Button] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	var root := VBoxContainer.new()
	root.position = Vector2(40, 28)
	root.size = Vector2(1200, 660)
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	root.add_child(head)
	head.add_child(UiStyle.label("MOCHILA", 26, UiStyle.ACCENT))
	for i in POCKETS.size():
		var b := UiStyle.button(POCKETS[i][0], 150)
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(_show_pocket.bind(i))
		head.add_child(b)
		_pocket_buttons.append(b)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	head.add_child(UiStyle.label("$%d" % GameState.money, 22, UiStyle.ACCENT))  # dinero (docs/PLAN_TORNEO.md)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 16)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(520, 560)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 6)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(panel)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 10)
	panel.add_child(_detail)
	var foot := HBoxContainer.new()
	root.add_child(foot)
	_status = UiStyle.label("Tab: cambiar bolsillo · Enter: elegir · Esc: volver", 14, UiStyle.TEXT_DIM)
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(_status)
	var back := UiStyle.button("Volver", 140)
	back.pressed.connect(func(): closed.emit())
	foot.add_child(back)
	_show_pocket(0)


func refresh() -> void:
	_show_pocket(_pocket)


func _show_pocket(i: int) -> void:
	_close_chooser()
	_pocket = i
	for k in _pocket_buttons.size():
		_pocket_buttons[k].button_pressed = k == i
	for c in _list.get_children():
		c.queue_free()
	_rows.clear()
	var items := GameState.pocket_items(POCKETS[i][1])
	if items.is_empty():
		_list.add_child(UiStyle.label("(vacío)", 16, UiStyle.TEXT_DIM))
		_show_detail(null)
		return
	for it in items:
		var b := Button.new()
		b.custom_minimum_size = Vector2(500, 44)
		b.focus_mode = Control.FOCUS_ALL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.icon = it.icon
		b.expand_icon = false
		var tags := ""
		if it.id == GameState.selected_ball:
			tags = "   [E]"
		elif it.id == GameState.quick_item:
			tags = "   [C]"
		b.text = "%s%s" % [it.display_name, tags]
		var count := UiStyle.label("×%d" % GameState.item_count(it.id), 16, UiStyle.ACCENT)
		count.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		count.position = Vector2(-60, -11)
		b.add_child(count)
		b.focus_entered.connect(_show_detail.bind(it))
		b.pressed.connect(_show_detail.bind(it, true))
		_list.add_child(b)
		_rows.append(b)
	var keep := _rows.filter(func(r): return r.text.begins_with(_selected.display_name)) if _selected != null else []
	UiStyle.focus_later(keep[0] if not keep.is_empty() else _rows[0])


func _show_detail(it: ItemData, focus_actions: bool = false) -> void:
	_selected = it
	for c in _detail.get_children():
		c.queue_free()
	if it == null:
		_detail.add_child(UiStyle.label("No tenés objetos en este bolsillo.", 16, UiStyle.TEXT_DIM))
		return
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	var pic := TextureRect.new()
	pic.texture = it.icon
	pic.custom_minimum_size = Vector2(60, 60)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	head.add_child(pic)
	var names := VBoxContainer.new()
	names.add_child(UiStyle.label(it.display_name, 24))
	names.add_child(UiStyle.label("Tenés ×%d" % GameState.item_count(it.id), 15, UiStyle.ACCENT))
	head.add_child(names)
	_detail.add_child(head)
	var desc := UiStyle.label(it.description, 15)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = 560
	_detail.add_child(desc)
	_detail.add_child(UiStyle.label(_effect_text(it), 14, UiStyle.TEXT_DIM))
	var actions: Array[Button] = []
	if it.is_ball():
		var b := UiStyle.button("Lanzar esta con E" if it.id != GameState.selected_ball else "Es la que lanza E", 300)
		b.disabled = it.id == GameState.selected_ball
		b.pressed.connect(func(): GameState.selected_ball = it.id; _status.text = "E lanza %s." % it.display_name; refresh())
		actions.append(b)
	else:
		var use := UiStyle.button("Usar", 300)
		use.pressed.connect(_open_chooser.bind(it))
		var fighting := _in_battle()
		use.disabled = fighting and not it.usable_in_battle
		if use.disabled:
			use.text = "No se puede usar en combate"
		actions.append(use)
		if it.usable_in_battle:
			var quick := UiStyle.button("Poner en la ranura rápida (C)" if it.id != GameState.quick_item else "Está en la ranura rápida (C)", 300)
			quick.disabled = it.id == GameState.quick_item
			quick.pressed.connect(func(): GameState.quick_item = it.id; _status.text = "C usa %s." % it.display_name; refresh())
			actions.append(quick)
	for b in actions:
		_detail.add_child(b)
	if focus_actions:
		for b in actions:
			if not b.disabled:
				b.grab_focus()
				break


func _effect_text(it: ItemData) -> String:
	if it.catch_mult >= 255.0:
		return "Atrapa siempre."
	if it.is_ball():
		return "Captura ×%s." % str(it.catch_mult)
	if it.revive_ratio > 0.0:
		return "Revive con el %d%% de la vida. Fuera de combate o con la ranura rápida." % roundi(it.revive_ratio * 100)
	var parts: Array[String] = []
	if it.heal_full:
		parts.append("cura toda la vida")
	elif it.heal_hp > 0.0:
		parts.append("cura %d PS (×%d en el juego)" % [roundi(it.heal_hp), int(CreatureInstance.hp_scale())])
	if not it.cures.is_empty():
		parts.append("cura " + ("todos los problemas de estado" if it.cures.has("all") else ", ".join(it.cures)))
	var text := ", ".join(parts) if not parts.is_empty() else "sin efecto"
	text = text.left(1).to_upper() + text.substr(1)
	return text + (". En combate te deja expuesto %.1f s." % it.use_time if it.usable_in_battle else ".")


## Elegir sobre qué Pokémon del equipo usar el objeto.
func _open_chooser(it: ItemData) -> void:
	_close_chooser()
	_chooser = PanelContainer.new()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_chooser.add_child(box)
	box.add_child(UiStyle.label("¿Sobre quién usás %s?" % it.display_name, 16, UiStyle.ACCENT))
	var world := get_tree().get_first_node_in_group("world")
	var first: Button = null
	for inst in GameState.party:
		var comp: Creature = world.companion if world != null and is_instance_valid(world.companion) and world.companion.instance == inst else null
		var statuses: StatusEffects = comp.statuses if comp != null else null
		var useful := it.can_use_on(inst, statuses.active.keys() if statuses != null else [])
		var b := UiStyle.button("%s  Nv. %d   PS %d/%d%s" % [inst.display_name(), inst.level, ceili(inst.hp), ceili(inst.max_hp()),
			"  (debilitado)" if inst.hp <= 0.0 else ""], 420)
		b.disabled = not useful
		b.pressed.connect(_use.bind(it, inst, statuses))
		box.add_child(b)
		if first == null and useful:
			first = b
	var cancel := UiStyle.button("Cancelar", 420)
	cancel.pressed.connect(func(): _close_chooser(); refresh())
	box.add_child(cancel)
	add_child(_chooser)
	_chooser.position = Vector2(640, 220)
	(first if first != null else cancel).grab_focus()


func _use(it: ItemData, inst: CreatureInstance, statuses: StatusEffects) -> void:
	var text := GameState.use_item_on(it.id, inst, statuses)
	_status.text = text if text != "" else "No tendría efecto."
	_close_chooser()
	refresh()


func _close_chooser() -> void:
	if is_instance_valid(_chooser):
		_chooser.queue_free()
	_chooser = null


## Esc: primero cierra la elección de Pokémon.
func back() -> bool:
	if is_instance_valid(_chooser):
		_close_chooser()
		refresh()
		return false
	return true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		_show_pocket((_pocket + 1) % POCKETS.size())
		get_viewport().set_input_as_handled()


## Abierta con el menú de combate (pelea en pausa).
func _in_battle() -> bool:
	var world := get_tree().get_first_node_in_group("world")
	return world != null and world.combat.in_battle
