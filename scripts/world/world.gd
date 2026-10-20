extends Node2D
## Escena del mundo abierto: arma al entrenador y su Pokémon y conecta el streaming de zonas.

const CreatureScene := preload("res://scenes/creatures/creature.tscn")

@onready var streamer: ZoneStreamer = $ZoneStreamer
@onready var entities: Node2D = $YSort/Entities
@onready var trainer: Trainer = $YSort/Entities/Trainer

var companion: Creature


func _ready() -> void:
	var world := DB.config.world
	streamer.world_data = world
	var spawn := Vector2(world.spawn_cell * world.tile_size) + Vector2(world.tile_size / 2.0, world.tile_size / 2.0)
	trainer.global_position = spawn
	trainer.trail = [spawn]
	streamer.load_around_now(spawn)
	streamer.target = trainer
	Events.party_changed.connect(_spawn_companion)
	_spawn_companion()


## Tags de la celda del mundo en una posición global (vacío si la zona no está cargada).
func tags_at(global_pos: Vector2) -> PackedStringArray:
	var entry := streamer.world_data.zone_at(global_pos)
	if entry == null:
		return PackedStringArray()
	var zone := streamer.zone_node(entry.id)
	if zone == null:
		return PackedStringArray()
	return zone.get_tags(zone.cell_at(global_pos))


func _spawn_companion() -> void:
	if companion != null:
		companion.queue_free()
		companion = null
	var inst := GameState.active()
	if inst == null:
		return
	companion = CreatureScene.instantiate()
	companion.instance = inst
	companion.leader = trainer
	companion.position = trainer.global_position + Vector2(0, -12)
	entities.add_child(companion)
