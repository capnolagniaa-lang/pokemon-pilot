class_name BoonScreen
extends CanvasLayer
## La elección de una bendición (Modo Desafío, R-2): el legendario que te la ofrece, con su cartel pintado y su frase, y
## hasta 3 tarjetas (ícono, nombre, rareza, a qué se engancha y qué hace). El juego queda en pausa hasta elegir.
## La abre RogueRun con `open(boons, oferta)`; `chosen(índice)` avisa cuál. Con joystick anda sola (MenuNav).

signal chosen(index: int)

const ICONS := "res://sprites/ui/bendiciones/iconos/%s.png"

var boons: RogueBoons
var offer: Dictionary = {}
var cards: Array[Button] = []
var _done := false
var _was_paused := false


static func open(parent: Node, p_boons: RogueBoons, p_offer: Dictionary) -> BoonScreen:
	var s := BoonScreen.new()
	s.boons = p_boons
	s.offer = p_offer
	parent.add_child(s)
	return s


func _ready() -> void:
	layer = 11
	process_mode = Node.PROCESS_MODE_ALWAYS
	_was_paused = get_tree().paused
	get_tree().paused = true
	var giver: Dictionary = boons.config["givers"][offer["giver"]]
	var tint := Color(giver["color"][0], giver["color"][1], giver["color"][2])
	var root := Control.new()
	root.theme = UiStyle.theme()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.05, 0.86)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	# El cartel del dador: su paisaje pintado, él animado encima, su nombre y su frase.
	var banner := TextureRect.new()
	banner.position = Vector2(0, 0)
	banner.size = Vector2(1280, 250)
	banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists(giver["banner"]):
		banner.texture = load(giver["banner"])
	root.add_child(banner)
	var fade := ColorRect.new()  # (para que el texto se lea sobre la pintura)
	fade.color = Color(0.02, 0.02, 0.05, 0.38)
	fade.position = Vector2(0, 0)
	fade.size = Vector2(1280, 250)
	root.add_child(fade)
	var line := ColorRect.new()
	line.color = Color(tint, 0.9)
	line.position = Vector2(0, 250)
	line.size = Vector2(1280, 3)
	root.add_child(line)
	if DB.species.has(giver["species"]):
		var view := PokemonAnimView.new()
		view.species = DB.species[giver["species"]]
		view.pixel_scale = 4
		view.position = Vector2(60, 20)
		view.size = Vector2(260, 220)
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(view)
	var name_l := UiStyle.label(str(giver["name"]).to_upper(), 38, tint)
	name_l.position = Vector2(340, 40)
	name_l.size = Vector2(900, 46)
	_outline(name_l, 8)
	root.add_child(name_l)
	var title_l := UiStyle.label(str(giver["title"]), 18, UiStyle.TEXT)
	title_l.position = Vector2(342, 88)
	title_l.size = Vector2(900, 24)
	_outline(title_l, 6)
	root.add_child(title_l)
	var say := UiStyle.label(str(offer.get("line", "")), 19, UiStyle.TEXT)
	say.position = Vector2(342, 126)
	say.size = Vector2(880, 100)
	say.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_outline(say, 6)
	root.add_child(say)
	var pick := UiStyle.label("Elegí una bendición", 20, UiStyle.ACCENT)
	pick.position = Vector2(0, 268)
	pick.size = Vector2(1280, 28)
	pick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(pick)
	var row := HBoxContainer.new()
	row.position = Vector2(40, 306)
	row.size = Vector2(1200, 380)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 22)
	root.add_child(row)
	for i in offer["options"].size():
		var b := _card(i, offer["options"][i])
		row.add_child(b)
		cards.append(b)
	if not cards.is_empty():
		UiStyle.focus_later(cards[0])


func _outline(l: Label, size: int) -> void:
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	l.add_theme_constant_override("outline_size", size)


func _card(index: int, option: Dictionary) -> Button:
	var boon: BoonData = DB.boons[option["id"]]
	var rar: Dictionary = boons.rarity(option["rarity"])
	var rar_color := Color(rar["color"][0], rar["color"][1], rar["color"][2])
	var mine: Dictionary = boons.entry(boon.id)
	var level := int(mine.get("level", 0)) + 1  # (si ya la tenés, la tarjeta muestra el nivel que pasaría a tener)
	var b := Button.new()
	b.custom_minimum_size = Vector2(380, 370)
	b.pressed.connect(choose.bind(index))
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 18
	box.offset_right = -18
	box.offset_top = 14
	box.offset_bottom = -14
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 6)
	b.add_child(box)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(0, 112)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(ICONS % boon.id):
		icon.texture = load(ICONS % boon.id)
	box.add_child(icon)
	var name_l := UiStyle.label(boon.display_name, 24, UiStyle.ACCENT)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(name_l)
	var rar_text := str(rar["name"]) + ("  ·  sube a Nv. %d" % level if level > 1 else "")
	var rar_l := UiStyle.label(rar_text, 16, rar_color)
	rar_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(rar_l)
	var slot_l := UiStyle.label(boon.slot_label(), 15, UiStyle.TEXT_DIM)
	slot_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(slot_l)
	var desc := UiStyle.label(boons.describe(boon, option["rarity"], level), 17)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(desc)
	return b


## Elegir una tarjeta (también lo llaman los tests y el bot).
func choose(index: int) -> void:
	if _done or index < 0 or index >= offer["options"].size():
		return
	_done = true
	get_tree().paused = _was_paused
	chosen.emit(index)
	queue_free()
