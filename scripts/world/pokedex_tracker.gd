class_name PokedexTracker
extends Node
## Registra en la Pokédex (GameState) lo que el jugador ve y contra lo que pelea:
##  · visto: un salvaje que aparece dentro de la pantalla;
##  · luchado: un salvaje que entra en combate con tu Pokémon (te detecta o lo atacás).
## El primer avistamiento de cada especie muestra un mensaje.

const CHECK_INTERVAL := 0.4

var world: Node
var _timer := 0.0


func _ready() -> void:
	world = get_parent()
	Events.wild_aggro.connect(func(wild, _t): if wild is Creature: GameState.mark_fought(wild.instance.species))
	Events.pokedex_registered.connect(func(sp: SpeciesData):
		if world.is_inside_tree() and not GameState.party.is_empty():
			Events.message_requested.emit("Pokédex: %s registrado." % sp.display_name))


func _process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = CHECK_INTERVAL
	var view := visible_rect()
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.team == Creature.Team.WILD and not c.is_down() and view.has_point(c.global_position):
			GameState.mark_seen(c.instance.species)


## Lo que se ve en pantalla, en coordenadas del mundo.
func visible_rect() -> Rect2:
	var cam: Camera2D = world.camera
	var size := get_viewport().get_visible_rect().size / cam.zoom
	return Rect2(cam.get_screen_center_position() - size / 2.0, size)
