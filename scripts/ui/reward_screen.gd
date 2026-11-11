class_name RewardScreen
extends CanvasLayer
## Elegir una tarjeta entre varias (Modo Desafío, R-3: Caramelo Raro, MT, Tienda...). Genérica: título, bajada y hasta 5
## tarjetas con ícono, nombre, etiqueta y texto. El juego queda en pausa hasta elegir. `chosen(índice)` avisa cuál.
## (Las bendiciones tienen la suya, con el cartel del legendario: BoonScreen.)

signal chosen(index: int)

## Cada tarjeta: {icon: ruta o Texture2D, title, tag, tag_color: Color, text, disabled: bool}.
var cards_data: Array = []
var title := ""
var subtitle := ""
var tint := UiStyle.ACCENT
var cards: Array[Button] = []
## Reroll pagado (RogueRewards): costo, o -1 si esta pantalla no lo tiene. Elegirlo avisa `chosen(-1)`.
var reroll_cost := -1
var reroll: Button
var _done := false
var _was_paused := false


static func open(parent: Node, p_title: String, p_subtitle: String, p_cards: Array, p_tint: Color = UiStyle.ACCENT, p_reroll := -1) -> RewardScreen:
	var s := RewardScreen.new()
	s.reroll_cost = p_reroll
	s.title = p_title
	s.subtitle = p_subtitle
	s.cards_data = p_cards
	s.tint = p_tint
	parent.add_child(s)
	return s


func _ready() -> void:
	layer = 11
	process_mode = Node.PROCESS_MODE_ALWAYS
	_was_paused = get_tree().paused
	get_tree().paused = true
	var root := Control.new()
	root.theme = UiStyle.theme()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.05, 0.86)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	var title_l := UiStyle.label(title.to_upper(), 34, tint)
	title_l.position = Vector2(0, 70)
	title_l.size = Vector2(1280, 44)
	title_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title_l)
	var sub_l := UiStyle.label(subtitle, 18, UiStyle.TEXT)
	sub_l.position = Vector2(140, 122)
	sub_l.size = Vector2(1000, 56)
	sub_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(sub_l)
	var line := ColorRect.new()
	line.color = Color(tint, 0.8)
	line.position = Vector2(340, 186)
	line.size = Vector2(600, 2)
	root.add_child(line)
	var row := HBoxContainer.new()
	row.position = Vector2(20, 206)
	row.size = Vector2(1240, 400)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	root.add_child(row)
	var width := clampf(1180.0 / maxf(1.0, float(cards_data.size())) - 16.0, 200.0, 380.0)
	for i in cards_data.size():
		var b := _card(i, cards_data[i], width)
		row.add_child(b)
		cards.append(b)
	for b in cards:
		if not b.disabled:
			UiStyle.focus_later(b)
			break
	_reroll_button(root)


## El botón de cambiar las opciones (reroll pagado). Apagado si no alcanza la plata.
func _reroll_button(root: Control) -> void:
	if reroll_cost < 0:
		return
	reroll = UiStyle.button("Cambiar las opciones  ·  $%d  (tenés $%d)" % [reroll_cost, GameState.money], 420)
	reroll.position = Vector2(430, 668)
	reroll.disabled = GameState.money < reroll_cost
	reroll.pressed.connect(choose.bind(-1))
	root.add_child(reroll)


func _card(index: int, data: Dictionary, width: float) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(width, 380)
	b.disabled = bool(data.get("disabled", false))
	b.pressed.connect(choose.bind(index))
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 14
	box.offset_right = -14
	box.offset_top = 14
	box.offset_bottom = -14
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 6)
	box.modulate.a = 0.45 if b.disabled else 1.0
	b.add_child(box)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(0, 104)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex = data.get("icon")
	if tex is String and tex != "" and ResourceLoader.exists(tex):
		icon.texture = load(tex)
	elif tex is Texture2D:
		icon.texture = tex
	box.add_child(icon)
	var name_l := UiStyle.label(str(data.get("title", "")), 22 if width >= 300.0 else 18, UiStyle.ACCENT)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(name_l)
	if str(data.get("tag", "")) != "":
		var tag_l := UiStyle.label(str(data["tag"]), 15, data.get("tag_color", UiStyle.TEXT_DIM))
		tag_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(tag_l)
	var desc := UiStyle.label(str(data.get("text", "")), 16 if width >= 300.0 else 14)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(desc)
	return b


## Elegir una tarjeta (también lo llaman los tests y el bot). Las apagadas no se pueden.
func choose(index: int) -> void:
	if index == -1 and not _done and reroll != null and not reroll.disabled:
		_done = true
		get_tree().paused = _was_paused
		chosen.emit(-1)
		queue_free()
		return
	if _done or index < 0 or index >= cards.size() or cards[index].disabled:
		return
	_done = true
	get_tree().paused = _was_paused
	chosen.emit(index)
	queue_free()


## La última tarjeta que se puede elegir (los bots: suele ser "Salir" o la más fuerte), o -1.
func last_enabled() -> int:
	for i in range(cards.size() - 1, -1, -1):
		if not cards[i].disabled:
			return i
	return -1
