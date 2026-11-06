class_name CinnabarGymQuiz
extends Node
## Puertas con preguntas del Gimnasio de Isla Canela (como en FireRed: CinnabarIsland_Gym/scripts.inc). Cada una tiene una
## máquina: si acertás se abre; si errás te reta el entrenador de esa puerta y al ganarle también se abre. Queda abierta
## (bandera `canela_puerta_N`, o haberle ganado a ese entrenador o a Blaine). Nodo del mundo (world.cinnabar_quiz); se
## engancha a la E con StoryDirector.register_interaction.

const ZONE := "isla_canela_gimnasio"
const BLAINE_FLAG := "medalla_volcan"
## Metatiles del gimnasio (base 12000 + los de pret metatile_labels.h).
const FLOOR := 12001
const SHADE_DIAGONAL := 12002
const SHADE_FULL := 12009
const LEFT_CORNER := 12071
const RIGHT_CORNER := 12070
const LEFT_EDGE := 12079
const RIGHT_EDGE := 12078
const RETRACTED := 12081
## Una por puerta: máquina (se le habla mirando cualquiera de sus dos celdas), entrenador, pregunta y respuesta.
const DOORS := [
	{"machine": [Vector2i(22, 10), Vector2i(23, 10)], "trainer": "isla_canela_gimnasio_quinn", "yes": true,
		"question": "¿Caterpie evoluciona a Metapod?", "corner": Vector2i(26, 8)},
	{"machine": [Vector2i(15, 2), Vector2i(16, 2)], "trainer": "isla_canela_gimnasio_avery", "yes": false,
		"question": "¿Hay nueve medallas oficiales de la Liga Pokémon?", "corner": Vector2i(17, 8)},
	{"machine": [Vector2i(13, 10), Vector2i(14, 10)], "trainer": "isla_canela_gimnasio_ramon", "yes": false,
		"question": "¿Poliwag evoluciona tres veces?", "corner": Vector2i(17, 15)},
	{"machine": [Vector2i(13, 17), Vector2i(14, 17)], "trainer": "isla_canela_gimnasio_derek", "yes": false,
		"question": "¿Los ataques eléctricos son efectivos contra los Pokémon de tipo Tierra?", "barrier": true},
	{"machine": [Vector2i(1, 18), Vector2i(2, 18)], "trainer": "isla_canela_gimnasio_dusty", "yes": true,
		"question": "¿Dos Pokémon de la misma especie y el mismo nivel pueden ser distintos?", "corner": Vector2i(5, 16)},
	{"machine": [Vector2i(1, 10), Vector2i(2, 10)], "trainer": "isla_canela_gimnasio_zac", "yes": false,
		"question": "¿La MT28 enseña Tumba Rocas?", "corner": Vector2i(5, 8)},
]

var world: Node
var _roles: TileRoleSet


func _ready() -> void:
	world = get_parent()
	_roles = ZoneBuilder.load_roles()
	world.story.register_interaction(_on_interact)
	Events.zone_loaded.connect(func(z: ZoneEntry, node: Node):
		if z.id == ZONE and node is Zone:
			apply_all(node))
	Events.story_flag_changed.connect(func(_flag: String, _on: bool):
		var zone: Zone = world.streamer.zone_node(ZONE)
		if zone != null:
			apply_all(zone))
	var zone: Zone = world.streamer.zone_node(ZONE)  # ya estaba cargado al armar el mundo: partida guardada acá adentro
	if zone != null:
		apply_all(zone)


static func flag_of(door: int) -> String:
	return "canela_puerta_%d" % (door + 1)


## Abierta: acertaste, le ganaste a su entrenador o ya le ganaste a Blaine.
static func is_open(door: int) -> bool:
	if GameState.has_flag(flag_of(door)) or GameState.has_flag(BLAINE_FLAG):
		return true
	var npc: NpcData = DB.npcs.get(DOORS[door]["trainer"])
	return npc != null and GameState.has_flag(npc.defeated_flag())


func apply_all(zone: Zone) -> void:
	for door in DOORS.size():
		if is_open(door):
			_open(zone, door)


## Las mismas celdas que CinnabarIsland_Gym_EventScript_OpenDoorN.
func _open(zone: Zone, door: int) -> void:
	var d: Dictionary = DOORS[door]
	if d.get("barrier", false):
		_put(zone, Vector2i(11, 21), RETRACTED, true)
		_put(zone, Vector2i(11, 22), SHADE_FULL, false)
		_put(zone, Vector2i(11, 23), FLOOR, false)
		return
	var c: Vector2i = d["corner"]
	_put(zone, c, LEFT_CORNER, false)
	_put(zone, c + Vector2i(1, 0), RIGHT_CORNER, false)
	_put(zone, c + Vector2i(0, 1), LEFT_EDGE, false)
	_put(zone, c + Vector2i(1, 1), RIGHT_EDGE, false)
	_put(zone, c + Vector2i(0, 2), SHADE_FULL, false)
	_put(zone, c + Vector2i(1, 2), FLOOR, false)
	_put(zone, c + Vector2i(2, 2), SHADE_DIAGONAL, false)


func _put(zone: Zone, c: Vector2i, m: int, solid: bool) -> void:
	var ref := ZoneBuilder.below_ref(m)
	zone.ground.set_cell(c, ref[0], ref[1], ZoneBuilder.collision_alt(zone.ground.tile_set, _roles, m, solid))
	var overhead: TileMapLayer = zone.get_node("Overhead")
	if ZoneBuilder.has_above(m):
		ZoneBuilder.set_above(overhead, c, m)
	else:
		overhead.erase_cell(c)


func _on_interact(zone_id: String, cell: Vector2i, _front: Vector2) -> bool:
	if zone_id != ZONE:
		return false
	for door in DOORS.size():
		if (DOORS[door]["machine"] as Array).has(cell):
			_quiz(door)
			return true
	return false


func _quiz(door: int) -> void:
	var story: StoryDirector = world.story
	story.lock()
	if is_open(door):
		await story._say("", PackedStringArray(["Esta puerta ya está abierta. ¡Seguí nomás!"]))
		story.unlock()
		return
	await story._say("", PackedStringArray(["¡Pregunta Pokémon! Si acertás, se abre la puerta a la sala siguiente.",
		"Si errás, te toca pelear con un entrenador. ¡Guardá fuerzas para Blaine!"]))
	var d: Dictionary = DOORS[door]
	var said_yes: bool = await story.dialog.ask("", d["question"], PackedStringArray(["Sí", "No"])) == 0
	if said_yes == d["yes"]:
		GameState.set_flag(flag_of(door))
		Events.camera_shake.emit(2.0)
		await story._say("", PackedStringArray(["¡Correcto! ¡Pasá!"]))
	else:
		await story._say("", PackedStringArray(["¡Incorrecto!"]))
		var npc: NpcData = DB.npcs[d["trainer"]]
		await story._say(npc.trainer.display_name, story._lines(npc.trainer, "desafio", "¡Peleemos!"))
		await story.fight(npc)
	story.unlock()
