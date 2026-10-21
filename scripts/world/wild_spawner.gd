class_name WildSpawner
extends Node
## Spawner PROVISORIO de la Etapa 2: pone algunos salvajes en el pasto alto de las zonas cargadas.
## En la Etapa 4 lo reemplaza el sistema de spawns por bioma y hora.

const CreatureScene := preload("res://scenes/creatures/creature.tscn")

## Especies posibles por bioma (ids de data/species).
const BY_BIOME := {
	"pradera": ["rattata", "pidgey", "oddish", "eevee"],
	"pradera_florida": ["oddish", "bellsprout", "pidgey", "vulpix"],
	"bosque": ["oddish", "bellsprout", "pikachu", "pidgey"],
	"bosque_denso": ["bellsprout", "oddish", "pikachu"],
	"lago": ["psyduck", "poliwag", "seel"],
	"rocoso": ["growlithe", "vulpix", "rattata"],
	"humedal": ["poliwag", "psyduck", "oddish"],
	"arboleda": ["pikachu", "eevee", "pidgey", "growlithe"],
}

## Especies por zona puntual (mandan sobre el bioma).
const BY_ZONE := {
	"ruta1": ["pidgey", "bellsprout", "rattata", "vulpix"],
}

## Fase de prueba del combate (pedido del usuario): en TODAS las zonas aparecen solo estos 4, porque las
## zonas vecinas a Ruta 1 (lago, humedal) se cargan al acercarse a sus bordes y metían Pokémon de agua.
## Los demás Pokémon no se borran: al poner `use_test_pool = false` vuelven los spawns por zona/bioma.
const TEST_POOL := ["pidgey", "bellsprout", "rattata", "vulpix"]
@export var use_test_pool := true

@export var per_zone := 3
@export var respawn_time := 25.0

## zone_id -> Array[Creature]
var _alive: Dictionary = {}
var _timers: Dictionary = {}

@onready var world: Node = get_parent()


func _ready() -> void:
	Events.zone_loaded.connect(_on_zone_loaded)
	Events.zone_unloaded.connect(_on_zone_unloaded)


func _process(delta: float) -> void:
	if not GameState.wilds_enabled:
		return
	for id in _alive.keys():
		var list: Array = _alive[id].filter(func(c): return is_instance_valid(c))
		_alive[id] = list
		if list.size() < per_zone:
			_timers[id] = _timers.get(id, respawn_time) - delta
			if _timers[id] <= 0.0:
				_timers[id] = respawn_time
				_spawn_in(id)


func _on_zone_loaded(zone: ZoneEntry, _node: Node) -> void:
	_alive[zone.id] = []
	_timers[zone.id] = 0.0
	if GameState.wilds_enabled:
		for i in per_zone:
			_spawn_in(zone.id)


func _on_zone_unloaded(zone: ZoneEntry) -> void:
	for c in _alive.get(zone.id, []):
		if is_instance_valid(c) and not is_instance_valid(c.target):
			c.queue_free()
	_alive.erase(zone.id)


func _spawn_in(zone_id: String) -> void:
	var zone: Zone = world.streamer.zone_node(zone_id)
	var entry: ZoneEntry = null
	for z in world.streamer.world_data.zones:
		if z.id == zone_id:
			entry = z
	if zone == null or entry == null:
		return
	var cells: Array = zone.foliage.get_used_cells().filter(func(c): return zone.get_tags(c).has("pasto_alto"))
	if cells.is_empty():
		return
	var pos: Vector2 = zone.to_global(zone.ground.map_to_local(cells[randi() % cells.size()]))
	if pos.distance_to(world.trainer.global_position) < 120.0:
		return
	var options: Array = TEST_POOL if use_test_pool else BY_ZONE.get(zone_id, BY_BIOME.get(entry.biome, ["rattata"]))
	var sp: SpeciesData = DB.species[options[randi() % options.size()]]
	var level: int = maxi(2, (GameState.active().level if GameState.active() else 5) + randi_range(-2, 1))
	_alive[zone_id].append(spawn(sp, level, pos))


## Crea un salvaje en una posición (también lo usa el autotest).
func spawn(sp: SpeciesData, level: int, pos: Vector2) -> Creature:
	var c: Creature = CreatureScene.instantiate()
	c.instance = CreatureInstance.create(sp, level)
	c.team = Creature.Team.WILD
	c.position = pos
	world.entities.add_child(c)
	return c
