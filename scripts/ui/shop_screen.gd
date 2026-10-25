class_name ShopScreen
extends Control
## Pantalla de la Tienda Pokémon (la abre `Mart` al hablar con el vendedor). Comprar: lo que vende la tienda, a su
## precio. Vender: lo de tu Mochila que se vende (a la mitad). Elegís un objeto, la cantidad (−/+, ±10) y confirmás.
## Esc o "Volver" la cierra (señal `closed`).

signal closed

var shop: ShopData
var buying := true
var _list: VBoxContainer
var _detail: VBoxContainer
var _money: Label
var _status: Label
var _selected: ItemData
var _amount := 1


func setup(p_shop: ShopData, p_buying: bool) -> void:
	shop = p_shop
	buying = p_buying


func _ready() -> void:
	theme = UiStyle.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)  # va en su propia CanvasLayer: que ocupe la pantalla
	add_child(UiStyle.dim())
	var root := VBoxContainer.new()
	root.position = Vector2(40, 28)
	root.size = Vector2(1200, 660)
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	root.add_child(head)
	head.add_child(UiStyle.label(shop.display_name.to_upper(), 24, UiStyle.ACCENT))
	head.add_child(UiStyle.label("· Comprar" if buying else "· Vender (a la mitad)", 20))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	_money = UiStyle.label("", 22, UiStyle.ACCENT)
	head.add_child(_money)
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
	_status = UiStyle.label("Elegí un objeto · Esc: volver", 14, UiStyle.TEXT_DIM)
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(_status)
	var back := UiStyle.button("Volver", 140)
	back.pressed.connect(func(): closed.emit())
	foot.add_child(back)
	refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		closed.emit()


## Lo que se muestra en la lista: lo que vende la tienda, o lo tuyo que se puede vender.
func items() -> Array[ItemData]:
	var out: Array[ItemData] = []
	if buying:
		for it in shop.items:
			if it.price > 0:
				out.append(it)
		return out
	for pocket in [ItemData.Pocket.ITEMS, ItemData.Pocket.BALLS]:
		out.append_array(GameState.pocket_items(pocket).filter(func(it): return it.sell_price() > 0))
	return out


func unit_price(it: ItemData) -> int:
	return it.price if buying else it.sell_price()


## Cuántos se pueden comprar (plata y lugar en la Mochila) o vender (los que tenés).
func max_amount(it: ItemData) -> int:
	if not buying:
		return GameState.item_count(it.id)
	return mini(99, mini(GameState.money / maxi(1, it.price), 999 - GameState.item_count(it.id)))


func refresh() -> void:
	_money.text = "$%d" % GameState.money
	for c in _list.get_children():
		c.queue_free()
	var rows: Array[Button] = []
	var list := items()
	if list.is_empty():
		_list.add_child(UiStyle.label("(no tenés nada para vender)" if not buying else "(no hay nada)", 16, UiStyle.TEXT_DIM))
	for it in list:
		var b := Button.new()
		b.custom_minimum_size = Vector2(500, 44)
		b.focus_mode = Control.FOCUS_ALL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.icon = it.icon
		b.expand_icon = false
		b.text = it.display_name
		var right := UiStyle.label("$%d    ×%d" % [unit_price(it), GameState.item_count(it.id)], 16, UiStyle.ACCENT)
		right.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		right.position = Vector2(-150, -11)
		b.add_child(right)
		b.pressed.connect(select.bind(it))
		_list.add_child(b)
		rows.append(b)
	if _selected == null or not list.has(_selected):
		_selected = list[0] if not list.is_empty() else null
	if not rows.is_empty():
		UiStyle.focus_later(rows[maxi(0, list.find(_selected))])
	_show_detail()


func select(it: ItemData) -> void:
	_selected = it
	_amount = 1
	_show_detail()


func set_amount(n: int) -> void:
	_amount = clampi(n, 1, maxi(1, max_amount(_selected))) if _selected != null else 1
	_show_detail()


## Compra o vende la cantidad elegida del objeto elegido. Devuelve si se pudo.
func confirm() -> bool:
	if _selected == null:
		return false
	var it := _selected
	var ok := Mart.buy(shop, it, _amount) if buying else Mart.sell(it, _amount)
	if ok:
		_status.text = ("Compraste %d × %s por $%d." if buying else "Vendiste %d × %s por $%d.") % [_amount, it.display_name,
			unit_price(it) * _amount]
	else:
		_status.text = "No te alcanza la plata." if buying else "No tenés tantos."
	_amount = 1
	refresh()
	return ok


func _show_detail() -> void:
	for c in _detail.get_children():
		c.queue_free()
	var it := _selected
	if it == null:
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
	names.add_child(UiStyle.label("$%d c/u · Tenés ×%d" % [unit_price(it), GameState.item_count(it.id)], 15, UiStyle.ACCENT))
	head.add_child(names)
	_detail.add_child(head)
	var desc := UiStyle.label(it.description, 15)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = 560
	_detail.add_child(desc)
	var top := max_amount(it)
	var qty := HBoxContainer.new()
	qty.add_theme_constant_override("separation", 8)
	for step in [-10, -1]:
		var b := UiStyle.button(str(step), 60)
		b.disabled = _amount <= 1
		b.pressed.connect(func(): set_amount(_amount + step))
		qty.add_child(b)
	var n := UiStyle.label("× %d" % _amount, 22)
	n.custom_minimum_size.x = 80
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qty.add_child(n)
	for step in [1, 10]:
		var b := UiStyle.button("+%d" % step, 60)
		b.disabled = _amount >= top
		b.pressed.connect(func(): set_amount(_amount + step))
		qty.add_child(b)
	_detail.add_child(qty)
	_detail.add_child(UiStyle.label("Total: $%d" % (unit_price(it) * _amount), 20, UiStyle.ACCENT))
	var go := UiStyle.button(("Comprar" if buying else "Vender") + " %d" % _amount, 300)
	go.disabled = top < 1
	go.pressed.connect(confirm)
	_detail.add_child(go)
	if top < 1:
		_detail.add_child(UiStyle.label("No te alcanza la plata." if buying else "No tenés ninguno.", 14, UiStyle.BAD))
