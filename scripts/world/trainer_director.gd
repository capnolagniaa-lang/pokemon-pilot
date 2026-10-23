class_name TrainerDirector
extends Node
## Entrenadores vivos en el mundo (docs/PLAN_ENTRENADORES.md). Con el interruptor prendido
## (GameState.living_trainers) saca a cada entrenador de DB.trainers en el lugar de su rutina cuando esa zona
## está cargada, y lo guarda cuando la zona se descarga o se apaga el interruptor. Su estado (equipo, memoria)
## no vive en el nodo sino en GameState.trainers, así sobrevive a que el NPC aparezca y desaparezca.
## Fase E-0: el lugar es el del primer bloque de la rutina (el reloj y las rutinas llegan en E-5).

const NPCScene := preload("res://scenes/characters/trainer_npc.tscn")

var world: Node
## id del entrenador -> TrainerNPC en el mundo.
var npcs: Dictionary = {}


func _ready() -> void:
	world = get_parent()
	Events.zone_loaded.connect(func(_z, _n): refresh())
	Events.zone_unloaded.connect(func(_z): refresh.call_deferred())
	Events.living_trainers_changed.connect(func(_on): refresh())
	refresh.call_deferred()


## Saca o guarda a cada entrenador según el interruptor y si su zona está cargada.
func refresh() -> void:
	for data: TrainerData in DB.trainers.values():
		var zone := _zone_for(data)
		var should := GameState.living_trainers and zone != null
		var npc: TrainerNPC = npcs.get(data.id)
		if should and not is_instance_valid(npc):
			_spawn(data, zone)
		elif not should and is_instance_valid(npc):
			npc.queue_free()
			npcs.erase(data.id)
		elif not is_instance_valid(npc):
			npcs.erase(data.id)


## Zona (cargada) donde tiene que estar ahora, o null.
func _zone_for(data: TrainerData) -> Zone:
	var block := current_block(data)
	if block == null:
		return null
	var zone: Zone = world.streamer.zone_node(block.zone_id)
	return zone if is_instance_valid(zone) and not zone.is_queued_for_deletion() else null


## Bloque de rutina actual. E-0: siempre el primero (todavía no hay reloj del juego).
func current_block(data: TrainerData) -> RoutineBlock:
	return data.routine[0] if not data.routine.is_empty() else null


func _spawn(data: TrainerData, zone: Zone) -> void:
	var block := current_block(data)
	var entry: ZoneEntry = null
	for z in world.streamer.world_data.zones:
		if z.id == block.zone_id:
			entry = z
	var cell := MapRules.nearest_walkable(zone, entry, block.cell) if entry != null else block.cell
	var npc: TrainerNPC = NPCScene.instantiate()
	npc.data = data
	npc.global_position = zone.to_global(zone.ground.map_to_local(cell))
	world.entities.add_child(npc)
	npcs[data.id] = npc
	GameState.trainer_state(data)  # que exista su estado (equipo inicial) desde que aparece
