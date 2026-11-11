extends Control
## Modo Desafío (roguelike, docs/PROPUESTA_ROGUELIKE.md): desde el título, elegís uno de 3 Pokémon de los que tenés
## desbloqueados (RogueProgress; con más de 3, al azar) y arranca la partida (RogueRun). No toca la partida de la historia.

const WORLD_SCENE := "res://scenes/world/world.tscn"
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"

var options: Array[SpeciesData] = []
var cards: Array[Button] = []


func _ready() -> void:
	theme = UiStyle.theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.09, 0.07)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var f := RogueRun.load_floor()
	options = RogueRun.offer()
	var root := VBoxContainer.new()
	root.position = Vector2(40, 30)
	root.size = Vector2(1200, 660)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 14)
	add_child(root)
	var title := UiStyle.label("MODO DESAFÍO", 34, UiStyle.ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	var sub := UiStyle.label("%s: %d salas con oleadas de salvajes y, al final, %s %s.\nUn solo Pokémon de Nv. %d, %d Pociones y %d Pokébolas. Si se debilita, se termina.\nAtrapar un Pokémon lo desbloquea como inicial para las próximas partidas (tenés %d)." % [
		"De bioma en bioma", f["slots"].size(), f["boss"]["title"], f["boss"]["name"], int(f["level"]), int(f["potions"]), int(f.get("balls", 0)),
		RogueProgress.unlocked().size()], 16, UiStyle.TEXT_DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(sub)
	var pick := UiStyle.label("Elegí a tu Pokémon:", 20)
	pick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(pick)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	root.add_child(row)
	for sp in options:
		var b := _card(sp, int(f["level"]))
		row.add_child(b)
		cards.append(b)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	root.add_child(actions)
	if RogueProgress.unlocked().size() > options.size():  # (con 3 o menos no hay otros para ofrecer)
		var again := UiStyle.button("Otros tres", 200)
		again.pressed.connect(func(): get_tree().reload_current_scene())
		actions.add_child(again)
	var back := UiStyle.button("Volver", 200)
	back.pressed.connect(func(): get_tree().change_scene_to_file(TITLE_SCENE))
	actions.add_child(back)
	if not cards.is_empty():
		UiStyle.focus_later(cards[0])


## La tarjeta de un Pokémon: animación, nombre, tipos y los ataques con los que arranca.
func _card(sp: SpeciesData, level: int) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(340, 400)
	b.pressed.connect(start.bind(sp))
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 14
	box.offset_right = -14
	box.offset_top = 12
	box.offset_bottom = -12
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 6)
	b.add_child(box)
	var view := PokemonAnimView.new()
	view.species = sp
	view.pixel_scale = 3
	view.custom_minimum_size = Vector2(300, 150)
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(view)
	var name_l := UiStyle.label("%s  ·  Nv. %d" % [sp.display_name, level], 22, UiStyle.ACCENT)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(name_l)
	var types := UiStyle.label(" / ".join(sp.types.map(func(t): return t.display_name)), 16)
	types.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(types)
	var sample := CreatureInstance.create(sp, level)  # (solo para mostrar con qué ataques viene)
	for m: MoveData in sample.equipped_moves:
		if m != null:
			var line := UiStyle.label("· %s" % m.display_name, 15, UiStyle.TEXT_DIM)
			line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			box.add_child(line)
	return b


func start(sp: SpeciesData) -> void:
	RogueRun.begin(sp)
	get_tree().change_scene_to_file(WORLD_SCENE)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(TITLE_SCENE)
