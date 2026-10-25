class_name FieldMoves
extends Node
## Habilidades fuera de combate (MO). Por ahora Corte (docs/PLAN_CAPITULO_3.md): con la MO01 (te la da el capitán del
## S.S. Anne) y la Medalla Cascada, E frente a un árbol fino (EnvObject con el tag "cortable") lo corta. Vuelve a
## crecer al recargarse la zona, como en los juegos. En el modo libre alcanza con la MO01. Nodo del mundo
## (world.field_moves); se engancha a la E con StoryDirector.register_interaction.

const CUT_ITEM := "mo01"
## Distancia máxima entre el árbol y el punto de adelante del entrenador.
const REACH := 14.0

var world: Node


func _ready() -> void:
	world = get_parent()
	world.story.register_interaction(_try_cut)


## Si puede usar Corte ahora (la MO01 y, en la historia, la Medalla Cascada).
static func can_cut() -> bool:
	if GameState.item_count(CUT_ITEM) <= 0:
		return false
	return GameState.has_flag("medalla_cascada") or not GameState.has_flag("historia")


## El árbol cortable más cercano a un punto (o null).
func cuttable_near(pos: Vector2) -> EnvObject:
	var best: EnvObject = null
	var best_d := REACH
	for o in get_tree().get_nodes_in_group("env_objects"):
		if o is EnvObject and o.has_tag("cortable") and not o._gone:
			var d: float = o.global_position.distance_to(pos)
			if d < best_d:
				best_d = d
				best = o
	return best


func _try_cut(_zone_id: String, _cell: Vector2i, front: Vector2) -> bool:
	var tree := cuttable_near(front)
	if tree == null:
		return false
	_cut_dialog(tree)
	return true


func _cut_dialog(tree: EnvObject) -> void:
	var story: StoryDirector = world.story
	story.lock()
	if not can_cut():
		var why := "Necesitás la MO01 Corte." if GameState.item_count(CUT_ITEM) <= 0 else "Te falta la Medalla Cascada para usarlo fuera de combate."
		await story._say("", PackedStringArray(["Este árbol se ve fino... se podría cortar.", why]))
	elif await story.dialog.ask("", "Este árbol se puede cortar. ¿Usás Corte?", PackedStringArray(["Sí", "No"])) == 0:
		var mon: CreatureInstance = GameState.active()
		await story._say("", PackedStringArray(["¡%s usó Corte!" % (mon.display_name() if mon != null else "Tu Pokémon")]))
		tree.cut()
	story.unlock()
