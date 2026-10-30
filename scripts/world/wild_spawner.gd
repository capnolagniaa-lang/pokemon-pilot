class_name WildSpawner
extends Node
## Pone Pokémon salvajes en las zonas cargadas según su tabla de encuentros (EncounterTable: la propia de la
## zona en data/world/encounters/<zona>.tres o la de su bioma). Cada fila dice especie, peso, niveles y dónde
## aparece (un tag de celda: pasto alto, agua...). Las tablas se arman en el editor de mapas.
## Con GameState.wild_test_pool (Opciones → "Salvajes de prueba") aparecen solo los 4 de la fase de prueba del
## combate, en el pasto alto y al nivel de tu Pokémon, como antes.

const CreatureScene := preload("res://scenes/creatures/creature.tscn")

## Fase de prueba del combate: los 4 con estilo de pelea propio.
const TEST_POOL := ["pidgey", "bellsprout", "rattata", "vulpix"]
## Lugares de agua: el salvaje que aparece ahí nada (no choca con el agua).
const WATER_WHERE := ["agua"]

## zone_id -> Array[Creature]
var _alive: Dictionary = {}
var _timers: Dictionary = {}
## zone_id -> EncounterTable (o null)
var _tables: Dictionary = {}
## zone_id -> {lugar: [celdas]}
var _cells: Dictionary = {}
## zone_id -> celdas donde puede aparecer algo (para max_alive)
var _spawn_cells: Dictionary = {}
var _rng := RandomNumberGenerator.new()

@onready var world: Node = get_parent()


func _ready() -> void:
	_rng.randomize()
	Events.zone_loaded.connect(_on_zone_loaded)
	Events.zone_unloaded.connect(_on_zone_unloaded)
	Events.time_changed.connect(_on_time_changed)
	Events.wild_aggro.connect(func(w, t): if w is Creature and t is Creature: WildSociety.call_pack(w, t))


func _process(delta: float) -> void:
	if not GameState.wilds_enabled:
		return
	for id in _alive.keys():
		var list: Array = _alive[id].filter(func(c): return is_instance_valid(c))
		_alive[id] = list
		if list.size() < max_alive(id):
			var respawn := respawn_time(id)
			_timers[id] = _timers.get(id, respawn) - delta
			if _timers[id] <= 0.0:
				_timers[id] = respawn
				_spawn_in(id)


## Salvajes vivos a la vez: en zonas grandes más (EncounterTable.alive_for, según las celdas donde pueden aparecer).
func max_alive(zone_id: String) -> int:
	var t: EncounterTable = _tables.get(zone_id)
	var n: int = 3 if GameState.wild_test_pool or t == null else t.alive_for(_spawn_cells.get(zone_id, 0))
	return maxi(0, roundi(n * float(GameState.setting("wild_mult"))))  # Ajustes del juego: cantidad de salvajes


## Cada cuánto aparece otro: más seguido cuantos más tiene que reponer (así una zona grande se llena igual de rápido).
func respawn_time(zone_id: String) -> float:
	var t: EncounterTable = _tables.get(zone_id)
	if GameState.wild_test_pool or t == null:
		return 25.0
	return t.respawn_time * t.max_alive / float(maxi(1, max_alive(zone_id)))


func _on_zone_loaded(zone: ZoneEntry, _node: Node) -> void:
	_alive[zone.id] = []
	_timers[zone.id] = 0.0
	_tables[zone.id] = EncounterTable.for_zone(zone)
	_cells.erase(zone.id)
	_spawn_cells[zone.id] = _count_spawn_cells(zone.id, _node)
	if GameState.wilds_enabled:
		for i in max_alive(zone.id):
			_spawn_in(zone.id)


func _on_zone_unloaded(zone: ZoneEntry) -> void:
	for c in _alive.get(zone.id, []):
		if is_instance_valid(c) and not is_instance_valid(c.target):
			c.queue_free()
	_alive.erase(zone.id)
	_tables.erase(zone.id)
	_cells.erase(zone.id)
	_spawn_cells.erase(zone.id)


func _count_spawn_cells(zone_id: String, zone: Node) -> int:
	var t: EncounterTable = _tables.get(zone_id)
	if t == null or not zone is Zone:
		return 0
	var n := 0
	var by := cells_for(zone_id, zone, t.wheres())
	for w in t.wheres():
		n += by[w].size()
	return n


## Celdas de la zona con cada lugar ("dónde") de su tabla.
func cells_for(zone_id: String, zone: Zone, wheres: PackedStringArray) -> Dictionary:
	if not _cells.has(zone_id):
		_cells[zone_id] = {}
	var by: Dictionary = _cells[zone_id]
	for w in wheres:
		if by.has(w):
			continue
		var used: Array = zone.ground.get_used_cells()
		var out: Array[Vector2i] = []
		for c in used:
			if zone.get_tags(c).has(w):
				out.append(c)
		by[w] = out
	return by


## Lo que aparecería en la zona: [especie, nivel, celda, lugar] (o [] si no hay nada que poner). Con
## `water` = false no salen los del agua (como en FireRed, salen solo mientras navegás con Surf).
func roll(zone_id: String, water: bool = true) -> Array:
	var zone: Zone = world.streamer.zone_node(zone_id)
	if zone == null:
		return []
	if GameState.wild_test_pool:
		var grass: Array = cells_for(zone_id, zone, PackedStringArray(["pasto_alto"]))["pasto_alto"]
		if grass.is_empty():
			return []
		var lvl: int = maxi(2, (GameState.active().level if GameState.active() else 5) + _rng.randi_range(-2, 1))
		return [DB.species[TEST_POOL[_rng.randi() % TEST_POOL.size()]], lvl, grass[_rng.randi() % grass.size()], "pasto_alto"]
	var table: EncounterTable = _tables.get(zone_id)
	if table == null or table.entries.is_empty():
		return []
	# Primero la celda (entre todos los lugares de la tabla) y después qué aparece ahí: así cada área pintada
	# usa sus propios porcentajes.
	var wheres := table.wheres()
	var by := cells_for(zone_id, zone, wheres)
	var pool: Array[Vector2i] = []
	for w in wheres:  # solo los lugares de esta tabla (el caché puede tener otros)
		if not water and w in WATER_WHERE:
			continue
		for c in by[w]:
			pool.append(c)
	for attempt in 6:
		if pool.is_empty():
			return []
		var cell: Vector2i = pool[_rng.randi() % pool.size()]
		var row := table.pick_at(_rng, cell, zone.get_tags(cell))
		if row != null and row.species_id == "":
			return []  # fila "nada": esta vez no aparece nadie (Squirtle 12% en las flores de Celeste)
		if row == null or not DB.species.has(row.species_id):
			continue
		var level := _rng.randi_range(mini(row.min_level, row.max_level), maxi(row.min_level, row.max_level))
		return [DB.species[row.species_id], level, cell, row.where]
	return []


func _spawn_in(zone_id: String) -> void:
	var fm = world.get("field_moves")
	var r := roll(zone_id, fm != null and fm.surfing)
	if r.is_empty():
		return
	var zone: Zone = world.streamer.zone_node(zone_id)
	var pos: Vector2 = zone.to_global(zone.ground.map_to_local(r[2]))
	if pos.distance_to(world.trainer.global_position) < 120.0:
		return
	var c := spawn(r[0], r[1], pos)
	if r[3] in WATER_WHERE:
		c.swims = true
	_alive[zone_id].append(c)
	# Salvajes vivos (docs/PLAN_IA.md, IA-5): si es su hora de dormir, muchos aparecen durmiendo.
	if WildSociety.sleepy(c.instance.species, GameState.time_of_day, _in_cave()) and randf() < WildSociety.rules().sleep_chance:
		WildSociety.nap.call_deferred(c)


func _in_cave() -> bool:
	var dn = world.get("day_night")
	return dn != null and dn.in_cave


## Cambió la hora: los que duermen y ya es su hora se despiertan solos; los tranquilos a los que les toca, se duermen.
func _on_time_changed(hour: float, _phase: String) -> void:
	for list in _alive.values():
		for c in list:
			if not is_instance_valid(c) or c.is_down():
				continue
			var sleepy := WildSociety.sleepy(c.instance.species, hour, _in_cave())
			if c.napping and not sleepy:
				WildSociety.wake(c)
			elif not c.napping and sleepy and c.machine.current_name() == "wander" and not is_instance_valid(c.target) 					and randf() < WildSociety.rules().sleep_chance * 0.5:
				WildSociety.nap(c)


## Crea un salvaje en una posición (también lo usa el autotest).
func spawn(sp: SpeciesData, level: int, pos: Vector2) -> Creature:
	var c: Creature = CreatureScene.instantiate()
	c.instance = CreatureInstance.create(sp, level)
	c.instance.roll_ivs()  # IVs al azar (Etapa 6): lo que atrapás conserva los suyos
	c.team = Creature.Team.WILD
	c.position = pos
	world.entities.add_child(c)
	return c
