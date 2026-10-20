extends Node2D
## Escena del mundo abierto: arma al entrenador y su Pokémon y conecta streaming, cámara y combate.

const CreatureScene := preload("res://scenes/creatures/creature.tscn")

@onready var streamer: ZoneStreamer = $ZoneStreamer
@onready var entities: Node2D = $YSort/Entities
@onready var trainer: Trainer = $YSort/Entities/Trainer
@onready var camera: CameraRig = $Camera
@onready var combat: CombatDirector = $CombatDirector
@onready var spawner: WildSpawner = $WildSpawner

var companion: Creature


func _ready() -> void:
	var world := DB.config.world
	streamer.world_data = world
	var spawn := Vector2(world.spawn_cell * world.tile_size) + Vector2(world.tile_size / 2.0, world.tile_size / 2.0)
	trainer.global_position = spawn
	trainer.trail = [spawn]
	camera.target = trainer
	camera.snap()
	streamer.load_around_now(spawn)
	# Las zonas se cargan alrededor de lo que mira la cámara (el entrenador o tu Pokémon en combate).
	streamer.target = camera
	Events.party_changed.connect(_on_party_changed)
	respawn_companion()


## Tags de la celda del mundo en una posición global (vacío si la zona no está cargada).
func tags_at(global_pos: Vector2) -> PackedStringArray:
	var entry := streamer.world_data.zone_at(global_pos)
	if entry == null:
		return PackedStringArray()
	var zone := streamer.zone_node(entry.id)
	if zone == null:
		return PackedStringArray()
	return zone.get_tags(zone.cell_at(global_pos))


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
