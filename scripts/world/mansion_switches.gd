class_name MansionSwitches
extends Node
## Interruptores secretos de la Mansión Pokémon de Isla Canela (como en FireRed: PokemonMansion_EventScript_SecretSwitch).
## Las estatuas de cada piso son el mismo interruptor: apretarlo da vuelta TODAS las barreras de la Mansión (las abiertas
## se cierran y al revés), y hay que ir y volver para llegar al sótano (MT14, MT22 y la Llave Secreta). Bandera
## mansion_interruptor (se guarda). Nodo del mundo (world.mansion_switches); se engancha a la E con
## StoryDirector.register_interaction.

const FLAG := "mansion_interruptor"
## Estatuas: la celda de la base (la del cartel de FireRed); también sirve mirando la de arriba.
const STATUES := {"mansion_pokemon_1p": [Vector2i(5, 5)], "mansion_pokemon_2p": [Vector2i(2, 16)],
	"mansion_pokemon_3p": [Vector2i(12, 5)], "mansion_pokemon_s1": [Vector2i(24, 29), Vector2i(27, 5)]}
## Celdas que cambia el interruptor, sacadas de los scripts de FireRed (PressSwitch_* = apretado, ResetSwitch_* = como
## arranca): zona -> {apretado: [[x, y, metatile, sólido]]}. Sin apretar es como viene el mapa.
const TILES := {
	"mansion_pokemon_1p": {
		true: [[22,10, 38005, 0], [23,10, 38004, 0], [24,10, 38004, 0], [22,11, 38005, 0], [23,11, 38004, 0],
			[24,11, 38004, 0], [27,25, 38005, 0], [28,25, 38004, 0], [29,25, 38004, 0], [27,26, 38005, 0], [28,26, 38004, 0],
			[29,26, 38004, 0], [32,25, 38005, 0], [33,25, 38004, 0], [34,25, 38004, 0], [32,26, 38005, 0], [33,26, 38004, 0],
			[34,26, 38004, 0], [31,18, 38120, 1], [32,18, 38121, 1], [33,18, 38122, 1], [31,19, 38128, 1], [32,19, 38129, 1],
			[33,19, 38130, 1], [5,4, 38205, 0]],
		false: [[22,10, 38120, 1], [23,10, 38121, 1], [24,10, 38122, 1], [22,11, 38128, 1], [23,11, 38129, 1],
			[24,11, 38130, 1], [27,25, 38120, 1], [28,25, 38121, 1], [29,25, 38122, 1], [27,26, 38128, 1], [28,26, 38129, 1],
			[29,26, 38130, 1], [32,25, 38120, 1], [33,25, 38121, 1], [34,25, 38122, 1], [32,26, 38128, 1], [33,26, 38129, 1],
			[34,26, 38130, 1], [31,18, 38005, 0], [32,18, 38004, 0], [33,18, 38004, 0], [31,19, 38005, 0], [32,19, 38004, 0],
			[33,19, 38004, 0], [5,4, 38148, 0]],
	},
	"mansion_pokemon_2p": {
		true: [[24,14, 38005, 0], [25,14, 38004, 0], [26,14, 38004, 0], [24,15, 38005, 0], [25,15, 38004, 0],
			[26,15, 38004, 0], [10,28, 38037, 1], [10,29, 38045, 1], [10,30, 38005, 0], [10,31, 38004, 0], [10,32, 38053, 0],
			[12,4, 38208, 1], [12,5, 38216, 1], [12,6, 38224, 1], [12,7, 38232, 1], [12,8, 38240, 1], [2,15, 38205, 0]],
		false: [[24,14, 38120, 1], [25,14, 38121, 1], [26,14, 38122, 1], [24,15, 38128, 1], [25,15, 38129, 1],
			[26,15, 38130, 1], [10,28, 38208, 1], [10,29, 38216, 1], [10,30, 38224, 1], [10,31, 38232, 1], [10,32, 38240, 1],
			[12,4, 38037, 1], [12,5, 38045, 1], [12,6, 38005, 0], [12,7, 38004, 0], [12,8, 38053, 0], [2,15, 38148, 0]],
	},
	"mansion_pokemon_3p": {
		true: [[17,11, 38005, 0], [18,11, 38004, 0], [19,11, 38004, 0], [17,12, 38005, 0], [18,12, 38004, 0],
			[19,12, 38004, 0], [21,4, 38208, 1], [21,5, 38216, 1], [21,6, 38224, 1], [21,7, 38232, 1], [21,8, 38240, 1],
			[12,4, 38205, 0]],
		false: [[17,11, 38120, 1], [18,11, 38121, 1], [19,11, 38122, 1], [17,12, 38128, 1], [18,12, 38129, 1],
			[19,12, 38130, 1], [21,4, 38037, 1], [21,5, 38045, 1], [21,6, 38005, 0], [21,7, 38004, 0], [21,8, 38053, 0],
			[12,4, 38148, 0]],
	},
	"mansion_pokemon_s1": {
		true: [[33,20, 38120, 1], [34,20, 38121, 1], [35,20, 38122, 1], [33,21, 38212, 1], [34,21, 38213, 1],
			[35,21, 38214, 1], [16,26, 38208, 1], [16,27, 38216, 1], [16,28, 38226, 1], [16,29, 38234, 1], [16,30, 38242, 1],
			[12,8, 38037, 1], [12,9, 38045, 1], [12,10, 38007, 0], [12,11, 38006, 0], [12,12, 38048, 0], [20,22, 38007, 0],
			[21,22, 38006, 0], [22,22, 38006, 0], [20,23, 38007, 0], [21,23, 38006, 0], [22,23, 38006, 0], [24,28, 38207, 0],
			[27,4, 38207, 0]],
		false: [[33,20, 38007, 0], [34,20, 38006, 0], [35,20, 38006, 0], [33,21, 38007, 0], [34,21, 38006, 0],
			[35,21, 38006, 0], [16,26, 38037, 1], [16,27, 38045, 1], [16,28, 38007, 0], [16,29, 38006, 0], [16,30, 38048, 0],
			[12,8, 38208, 1], [12,9, 38216, 1], [12,10, 38226, 1], [12,11, 38234, 1], [12,12, 38242, 1], [20,22, 38120, 1],
			[21,22, 38121, 1], [22,22, 38122, 1], [20,23, 38212, 1], [21,23, 38213, 1], [22,23, 38214, 1], [24,28, 38150, 0],
			[27,4, 38150, 0]],
	},
}

var world: Node
var _roles: TileRoleSet


func _ready() -> void:
	world = get_parent()
	_roles = ZoneBuilder.load_roles()
	world.story.register_interaction(_on_interact)
	Events.zone_loaded.connect(func(z: ZoneEntry, node: Node):
		if TILES.has(z.id) and GameState.has_flag(FLAG) and node is Zone:
			apply(node, z.id, true))


## Aprieta (o suelta) el interruptor: cambia la bandera y las barreras de los pisos cargados.
func toggle() -> void:
	var pressed := not GameState.has_flag(FLAG)
	GameState.set_flag(FLAG, pressed)
	for id in TILES:
		var zone: Zone = world.streamer.zone_node(id)
		if zone != null:
			apply(zone, id, pressed)


## Pone las celdas de un piso como quedan con el interruptor apretado o sin apretar.
func apply(zone: Zone, id: String, pressed: bool) -> void:
	var ts := zone.ground.tile_set
	var overhead: TileMapLayer = zone.get_node("Overhead")
	for t: Array in TILES[id][pressed]:
		var c := Vector2i(t[0], t[1])
		var m: int = t[2]
		var ref := ZoneBuilder.below_ref(m)
		zone.ground.set_cell(c, ref[0], ref[1], ZoneBuilder.collision_alt(ts, _roles, m, t[3] != 0))
		if ZoneBuilder.has_above(m):
			ZoneBuilder.set_above(overhead, c, m)
		else:
			overhead.erase_cell(c)


func _on_interact(zone_id: String, cell: Vector2i, _front: Vector2) -> bool:
	if not STATUES.has(zone_id) or not (STATUES[zone_id].has(cell) or STATUES[zone_id].has(cell + Vector2i(0, 1))):
		return false
	_press()
	return true


func _press() -> void:
	var story: StoryDirector = world.story
	story.lock()
	if await story.dialog.ask("", "¡Un interruptor secreto! ¿Lo apretás?", PackedStringArray(["Sí", "No"])) == 0:
		toggle()
		Events.camera_shake.emit(2.0)
		await story._say("", PackedStringArray(["¿Quién se resistiría? ¡Clic!", "Se oyó algo moverse en la mansión..."]))
	else:
		await story._say("", PackedStringArray(["Mejor no tocar nada... por ahora."]))
	story.unlock()
