extends Node2D
## Escena del mundo abierto: arma al entrenador y su Pokémon y conecta streaming, cámara y combate.

const CreatureScene := preload("res://scenes/creatures/creature.tscn")
const PauseMenuScene := preload("res://scenes/ui/pause_menu.tscn")

@onready var streamer: ZoneStreamer = $ZoneStreamer
@onready var entities: Node2D = $YSort/Entities
@onready var trainer: Trainer = $YSort/Entities/Trainer
@onready var camera: CameraRig = $Camera
@onready var combat: CombatDirector = $CombatDirector
@onready var spawner: WildSpawner = $WildSpawner

var companion: Creature
## Menú de pausa (Esc): equipo, guardar, opciones.
var pause_menu: PauseMenu
## Entorno reactivo (fuego, agua, hielo, eléctrico sobre las celdas).
var reactions: ReactionSystem
## Entrenadores vivos (aparecen solo con el interruptor prendido).
var trainers: TrainerDirector
## Mochila en el mundo: E lanza la Pokébola, C usa el objeto rápido.
var items: PlayerItems
## Puertas entre zonas (casas, Centros, garitas...).
var warps: WarpSystem
## Saltos de los salientes (se bajan, no se suben).
var ledges: LedgeJumper
## Historia: personas que hablan, disparadores, diálogos (docs/PLAN_HISTORIA.md).
var story: StoryDirector
## Torneo de Ciudad Plateada (docs/PLAN_TORNEO.md).
var tournament: Tournament
var mart: Mart
var evolutions: EvolutionDirector
var field_moves: FieldMoves
var vermilion_puzzle: VermilionGymPuzzle
## Combates contra entrenadores en su arena (docs/PLAN_ENTRENADORES.md, E-1).
var arena: TrainerBattle
## Hora del juego y luz del mundo según la hora (docs/PLAN_DIA_NOCHE.md).
var day_night: DayNight


func _ready() -> void:
	var world := DB.config.world
	streamer.world_data = world
	var spawn := Vector2(world.spawn_cell * world.tile_size) + Vector2(world.tile_size / 2.0, world.tile_size / 2.0)
	if GameState.trainer_position != Vector2.INF and world.zone_at(GameState.trainer_position) != null:
		spawn = GameState.trainer_position  # partida cargada: aparece donde guardó
	streamer.load_around_now(spawn)
	spawn = _safe_spawn(spawn)
	trainer.global_position = spawn
	trainer.trail = [spawn]
	camera.target = trainer
	camera.snap()
	# Las zonas se cargan alrededor de lo que mira la cámara (el entrenador o tu Pokémon en combate).
	streamer.target = camera
	trainer.add_to_group("trainer")
	reactions = ReactionSystem.new()
	reactions.name = "ReactionSystem"
	add_child(reactions)
	var dex := PokedexTracker.new()
	dex.name = "PokedexTracker"
	add_child(dex)
	trainers = TrainerDirector.new()
	trainers.name = "TrainerDirector"
	add_child(trainers)
	items = PlayerItems.new()
	items.name = "PlayerItems"
	add_child(items)
	warps = WarpSystem.new()
	warps.name = "WarpSystem"
	add_child(warps)
	ledges = LedgeJumper.new()
	ledges.name = "LedgeJumper"
	add_child(ledges)
	arena = TrainerBattle.new()
	arena.name = "TrainerBattle"
	add_child(arena)
	story = StoryDirector.new()
	story.name = "StoryDirector"
	add_child(story)
	tournament = Tournament.new()
	tournament.name = "Tournament"
	add_child(tournament)
	mart = Mart.new()  # el mercado: Tiendas Pokémon (data/shops)
	mart.name = "Mart"
	add_child(mart)
	evolutions = EvolutionDirector.new()  # evoluciones al subir de nivel o con piedras
	evolutions.name = "EvolutionDirector"
	add_child(evolutions)
	field_moves = FieldMoves.new()  # Corte (MO01)
	field_moves.name = "FieldMoves"
	add_child(field_moves)
	vermilion_puzzle = VermilionGymPuzzle.new()  # los basureros del gimnasio de Carmín
	vermilion_puzzle.name = "VermilionGymPuzzle"
	add_child(vermilion_puzzle)
	day_night = DayNight.new()
	day_night.name = "DayNight"
	add_child(day_night)
	Events.zone_entered.connect(func(z: ZoneEntry): $CloudShadows.visible = not z.interior)
	Events.zone_entered.connect(func(z: ZoneEntry): GameState.visit_zone(z.id))
	# Paredes invisibles donde una zona da al vacío (no se sale a lo no dibujado).
	Events.zone_loaded.connect(func(z: ZoneEntry, node: Node): ZoneBounds.attach(node, z, streamer.world_data))
	# Sombras largas de casas, árboles y cercas según el sol (DayNight; solo afuera).
	Events.zone_loaded.connect(func(z: ZoneEntry, node: Node): ZoneShadows.attach(node, z, streamer.world_data))
	# Ventanas prendidas de noche (DayNight; solo afuera).
	Events.zone_loaded.connect(func(z: ZoneEntry, node: Node): ZoneLights.attach(node, z, streamer.world_data))
	# Antorchas y cristales que alumbran las cuevas.
	Events.zone_loaded.connect(func(z: ZoneEntry, node: Node): CaveLights.attach(node, z, streamer.world_data))
	# Faroles al costado de los caminos (se prenden de noche).
	Events.zone_loaded.connect(func(z: ZoneEntry, node: Node): StreetLamps.attach(node, z, streamer.world_data))
	for id in streamer.loaded:
		for z in streamer.world_data.zones:
			if z.id == id:
				ZoneBounds.attach(streamer.loaded[id], z, streamer.world_data)
				ZoneShadows.attach(streamer.loaded[id], z, streamer.world_data)
				ZoneLights.attach(streamer.loaded[id], z, streamer.world_data)
				CaveLights.attach(streamer.loaded[id], z, streamer.world_data)
				StreetLamps.attach(streamer.loaded[id], z, streamer.world_data)
	var loot := FieldItemSpawner.new()
	loot.name = "FieldItemSpawner"
	add_child(loot)
	Events.party_changed.connect(_on_party_changed)
	Events.equipment_changed.connect(_on_equipment_changed)
	var menu_layer := CanvasLayer.new()
	menu_layer.layer = 10  # encima del HUD
	menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(menu_layer)
	pause_menu = PauseMenuScene.instantiate()
	menu_layer.add_child(pause_menu)
	respawn_companion()


func _process(delta: float) -> void:
	GameState.play_time += delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_add_pokemon") and debug_enabled():
		debug_add_pokemon()


## Si el mapa cambió (editor de mapas) y la posición guardada quedó en algo sólido o en el agua, lleva al
## entrenador al centro de la celda transitable más cercana.
func _safe_spawn(pos: Vector2) -> Vector2:
	var entry := streamer.world_data.zone_at(pos)
	var zone: Zone = streamer.zone_node(entry.id) if entry != null else null
	if zone == null:
		return pos
	var cell := zone.cell_at(pos)
	var free := MapRules.nearest_walkable(zone, entry, cell)
	if free == cell:
		return pos
	return zone.to_global(zone.ground.map_to_local(free))


## Herramientas de debug: solo con `-- --debug` o corriendo desde el editor (no en la versión portable, feature "portable").
static func debug_enabled() -> bool:
	return "--debug" in OS.get_cmdline_user_args() or (OS.has_feature("editor") and not OS.has_feature("portable"))


## Debug (F9): suma al equipo un Pokémon al azar al nivel del líder. Hasta que exista la captura (Etapa 6).
func debug_add_pokemon() -> bool:
	var leader := GameState.active()
	var sp: SpeciesData = DB.species.values().pick_random()
	var ok := GameState.add_to_party(CreatureInstance.create(sp, leader.level if leader != null else 5))
	Events.message_requested.emit(("Debug: %s se sumó al equipo." % sp.display_name) if ok else "El equipo ya tiene 6 Pokémon.")
	return ok


## Zona en la que está el entrenador (para el guardado).
func trainer_zone() -> ZoneEntry:
	return streamer.world_data.zone_at(trainer.global_position)


func _on_equipment_changed(inst: CreatureInstance) -> void:
	# Movimientos nuevos del que está afuera: fuera de combate lo sacamos de nuevo; en plena pelea (subió de nivel o
	# los equipaste desde el menú de combate) se actualizan sus ranuras ahí mismo (antes no se aplicaban hasta el final).
	if not is_instance_valid(companion) or companion.instance != inst:
		return
	if combat.in_battle:
		companion.moves.refresh(inst)
	else:
		respawn_companion()


## Tags de la celda del mundo en una posición global, con el estado del entorno reactivo aplicado (el pasto
## alto quemado deja de serlo). Vacío si la zona no está cargada.
func tags_at(global_pos: Vector2) -> PackedStringArray:
	return reactions.tags_at(global_pos) if reactions != null else PackedStringArray()


func _on_party_changed() -> void:
	# Si cambió el Pokémon activo, sacamos el nuevo.
	if not is_instance_valid(companion) or companion.instance != GameState.active():
		respawn_companion()


## Saca al Pokémon activo junto al entrenador (al empezar o cuando se recupera de un debilitamiento).
func respawn_companion() -> void:
	if is_instance_valid(companion):
		companion.queue_free()
	companion = null
	var inst := GameState.active()
	if inst == null or inst.hp <= 0.0:
		return
	companion = CreatureScene.instantiate()
	companion.instance = inst
	companion.leader = trainer
	companion.team = Creature.Team.ALLY
	companion.position = trainer.global_position + Vector2(0, -12)
	companion.add_to_group("ally_creatures")
	entities.add_child(companion)
