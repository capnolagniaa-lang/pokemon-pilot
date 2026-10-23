class_name FieldItemSpawner
extends Node
## Objetos tirados en el mapa y botín de los salvajes (docs/PLAN_CAPTURA_MOCHILA.md):
##  · solo las rutas (zonas al aire libre que no son ciudad ni interior: rutas y Bosque Verde) tienen objetos:
##    entre `PER_ROUTE_MIN` y `PER_ROUTE_MAX` lugares fijos (elegidos al azar pero siempre los mismos para esa
##    zona, en celdas caminables sin agua) con un objeto de data/items/loot/campo.tres. Al recogerlo se anota en
##    GameState.field_picked y vuelve a aparecer después de `RESPAWN_TIME` segundos de juego;
##  · un salvaje debilitado suelta, con la probabilidad de data/items/loot/salvajes.tres, un objeto que dura
##    `DROP_LIFETIME` segundos en el suelo.

const PER_ROUTE_MIN := 3
const PER_ROUTE_MAX := 4
## Biomas sin objetos tirados (además de los interiores).
const NO_ITEMS_BIOMES := ["ciudad"]
const RESPAWN_TIME := 900.0
const DROP_LIFETIME := 60.0

var world: Node
var field_table: LootTable
var drop_table: LootTable


func _ready() -> void:
	world = get_parent()
	field_table = load("res://data/items/loot/campo.tres")
	drop_table = load("res://data/items/loot/salvajes.tres")
	Events.zone_loaded.connect(func(z, node): _populate.call_deferred(z, node))
	Events.creature_fainted.connect(_on_fainted)
	for id in world.streamer.loaded:
		_populate.call_deferred(_entry(id), world.streamer.loaded[id])


func _entry(id: String) -> ZoneEntry:
	for z in world.streamer.world_data.zones:
		if z.id == id:
			return z
	return null


## Pone los objetos de una zona (los que no se recogieron hace poco).
func _populate(entry: ZoneEntry, zone: Node) -> void:
	if entry == null or not is_instance_valid(zone) or field_table == null or not is_inside_tree():
		return
	if not has_items(entry):
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(entry.id + ":objetos")
	var count := rng.randi_range(PER_ROUTE_MIN, PER_ROUTE_MAX)
	var cells: Array[Vector2i] = zone.ground.get_used_cells()
	var placed := 0
	var tries := 0
	while placed < count and tries < 200 and not cells.is_empty():
		tries += 1
		var cell: Vector2i = cells[rng.randi_range(0, cells.size() - 1)]
		var item := field_table.pick(rng)  # se elige siempre, así el lugar y el objeto no cambian
		if not MapRules.is_walkable(zone, cell) or zone.get_tags(cell).has("agua"):
			continue
		placed += 1
		var key := "%s:%d,%d" % [entry.id, cell.x, cell.y]
		var picked_at: float = GameState.field_picked.get(key, -INF)
		if GameState.play_time - picked_at < RESPAWN_TIME or _exists(key):
			continue
		GameState.field_picked.erase(key)
		var f := FieldItem.new()
		f.item = item
		f.key = key
		f.position = zone.to_global(zone.ground.map_to_local(cell))
		world.entities.add_child(f)
		zone.tree_exiting.connect(f.queue_free)


## Si en la zona aparecen objetos tirados (solo en las rutas).
static func has_items(entry: ZoneEntry) -> bool:
	return not entry.interior and not entry.biome in NO_ITEMS_BIOMES


func _exists(key: String) -> bool:
	return get_tree().get_nodes_in_group("field_items").any(func(f): return f.key == key and not f.is_queued_for_deletion())


## Botín: a veces un salvaje debilitado suelta un objeto.
func _on_fainted(c: Node) -> void:
	if not c is Creature or c.team != Creature.Team.WILD or drop_table == null or randf() >= drop_table.drop_chance:
		return
	drop(c.global_position, drop_table.pick())


func drop(at: Vector2, item: ItemData) -> FieldItem:
	if item == null:
		return null
	var f := FieldItem.new()
	f.item = item
	f.lifetime = DROP_LIFETIME
	f.position = at
	world.entities.add_child.call_deferred(f)
	return f
