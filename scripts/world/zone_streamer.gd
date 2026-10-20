class_name ZoneStreamer
extends Node
## Carga en segundo plano las zonas cercanas al objetivo y descarga las lejanas.
## Emite Events.zone_entered cuando el objetivo cambia de zona.

@export var world_data: WorldData
@export var zones_root: Node2D
## Distancia (en celdas) desde el borde de una zona a la que empieza a cargarse.
@export var load_margin := 14
## Distancia (en celdas) a la que se descarga (mayor que load_margin para no oscilar).
@export var unload_margin := 22
@export var check_interval := 0.25

var target: Node2D
var loaded: Dictionary = {}   # id -> Zone
var pending: Dictionary = {}  # id -> ZoneEntry
var current: ZoneEntry

var _timer := 0.0


## Carga sincrónicamente las zonas alrededor de una posición (para el arranque).
func load_around_now(pos: Vector2) -> void:
	for z in world_data.zones:
		if _rect(z, load_margin).has_point(pos) and not loaded.has(z.id):
			_add_zone(z, load(z.scene_path))


func _process(delta: float) -> void:
	_poll_pending()
	_timer -= delta
	if _timer > 0.0 or target == null:
		return
	_timer = check_interval
	var pos := target.global_position
	for z in world_data.zones:
		var near := _rect(z, load_margin).has_point(pos)
		if near and not loaded.has(z.id) and not pending.has(z.id):
			ResourceLoader.load_threaded_request(z.scene_path)
			pending[z.id] = z
		elif loaded.has(z.id) and not _rect(z, unload_margin).has_point(pos):
			loaded[z.id].queue_free()
			loaded.erase(z.id)
			Events.zone_unloaded.emit(z)
	var here := world_data.zone_at(pos)
	if here != null and here != current:
		current = here
		Events.zone_entered.emit(here)


func _poll_pending() -> void:
	for id in pending.keys():
		var z: ZoneEntry = pending[id]
		var status := ResourceLoader.load_threaded_get_status(z.scene_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			pending.erase(id)
			_add_zone(z, ResourceLoader.load_threaded_get(z.scene_path))
		elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			pending.erase(id)
			push_error("No se pudo cargar la zona %s" % z.scene_path)


func _add_zone(z: ZoneEntry, scene: PackedScene) -> void:
	var node := scene.instantiate()
	node.position = Vector2(z.origin * world_data.tile_size)
	zones_root.add_child(node)
	loaded[z.id] = node
	Events.zone_loaded.emit(z, node)


func _rect(z: ZoneEntry, margin_cells: int) -> Rect2:
	return z.world_rect(world_data.tile_size).grow(margin_cells * world_data.tile_size)


func zone_node(id: String) -> Zone:
	return loaded.get(id)
