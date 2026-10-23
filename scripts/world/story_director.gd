class_name StoryDirector
extends Node
## Historia en el mundo (docs/PLAN_HISTORIA.md, H-0):
##  · saca a las personas (DB.npcs, NpcData) cuando su zona está cargada y según las banderas (show_if/hide_if:
##    así un bloqueo se va cuando se pone su bandera) y las guarda cuando la zona se descarga;
##  · E contextual (PlayerItems llama a try_interact antes de lanzar la Pokébola): si hay alguien al lado, habla;
##  · disparadores (DB.story_triggers): pisar sus celdas abre su conversación (y con push_back te hace volver);
##  · al terminar una conversación aplica sus efectos: banderas, objetos, curar el equipo.
## Las banderas viven en GameState.story_flags (se guardan).

const NPCScene := preload("res://scenes/characters/story_npc.tscn")
## Hasta qué distancia (px) se puede hablar con alguien.
const TALK_RADIUS := 36.0  # alcanza para hablar por arriba de un mostrador (enfermera, vendedor)

var world: Node
var dialog: DialogBox
## id -> StoryNPC en el mundo.
var npcs: Dictionary = {}
var busy := false
var _last_cell := Vector2i(-99999, -99999)
var _last_zone := ""


func _ready() -> void:
	world = get_parent()
	var layer := CanvasLayer.new()
	layer.layer = 8  # debajo del fundido de las puertas (9) y del menú de pausa (10)
	add_child(layer)
	dialog = DialogBox.new()
	layer.add_child(dialog)
	Events.zone_loaded.connect(func(_z, _n): refresh())
	Events.zone_unloaded.connect(func(_z): refresh.call_deferred())
	Events.story_flag_changed.connect(func(_f, _on): refresh())
	refresh.call_deferred()


## Saca o guarda a cada persona según si su zona está cargada y sus banderas.
func refresh() -> void:
	for data: NpcData in DB.npcs.values():
		var zone: Zone = world.streamer.zone_node(data.zone_id)
		var should := is_instance_valid(zone) and not zone.is_queued_for_deletion() and data.visible_now()
		var npc: StoryNPC = npcs.get(data.id)
		if should and not is_instance_valid(npc):
			npc = NPCScene.instantiate()
			npc.data = data
			npc.global_position = zone.to_global(zone.ground.map_to_local(data.cell))
			world.entities.add_child(npc)
			npcs[data.id] = npc
		elif not should and is_instance_valid(npc):
			npc.queue_free()
			npcs.erase(data.id)
		elif not is_instance_valid(npc):
			npcs.erase(data.id)


## La persona más cercana con la que se puede hablar ahora (o null).
func npc_in_reach() -> StoryNPC:
	var t: Node2D = world.trainer
	var best: StoryNPC = null
	var best_d := TALK_RADIUS
	for npc in npcs.values():
		if not is_instance_valid(npc):
			continue
		var d: float = npc.global_position.distance_to(t.global_position)
		if d < best_d:
			best_d = d
			best = npc
	return best


## E contextual: si hay alguien al lado habla y devuelve true (así no se lanza la Pokébola).
func try_interact() -> bool:
	if busy or dialog.active:
		return true
	if world.combat.in_battle or world.warps.busy:
		return false
	var npc := npc_in_reach()
	if npc == null:
		return false
	talk_to(npc)
	return true


func talk_to(npc: StoryNPC) -> void:
	var talk := npc.data.talk_now()
	if talk == null:
		return
	npc.look_at_point(world.trainer.global_position)
	await run_talk(talk, npc.data.display_name)


## Abre la conversación (traba al entrenador) y al cerrarla aplica sus efectos.
func run_talk(talk: NpcTalk, default_speaker: String = "") -> void:
	busy = true
	var t: Trainer = world.trainer
	t.locked = true
	t.autopilot = Vector2.ZERO
	var hud: CanvasItem = world.get_node_or_null("UI/HUD")
	if hud != null:
		hud.visible = false  # la caja de diálogo va abajo, donde está el HUD
	await dialog.say(talk.speaker if talk.speaker != "" else default_speaker, talk.lines)
	var after := PackedStringArray()
	if talk.heal:
		heal_party()
		after.append("¡Tu equipo se recuperó por completo!")
	for id in talk.give_items:
		var n := int(talk.give_items[id])
		if DB.items.has(id) and n > 0:
			GameState.add_item(id, n)
			after.append("Recibiste %s%s." % [DB.items[id].display_name, " ×%d" % n if n > 1 else ""])
	for f in talk.set_flags:
		GameState.set_flag(f)
	if not after.is_empty():
		await dialog.say("", after)
	if hud != null:
		hud.visible = true
	t.locked = false
	busy = false


## Cura al equipo: vida llena y sin estados el que está afuera.
func heal_party() -> void:
	GameState.heal_party()
	var c: Creature = world.companion
	if is_instance_valid(c):
		c.statuses.clear()
		c.health.changed.emit(c.instance.hp, c.instance.max_hp())


func _physics_process(_delta: float) -> void:
	if busy or world.combat.in_battle or world.warps.busy:
		return
	var t: Trainer = world.trainer
	var entry: ZoneEntry = world.streamer.world_data.zone_at(t.global_position)
	if entry == null:
		return
	var zone: Zone = world.streamer.zone_node(entry.id)
	if zone == null:
		return
	var cell := zone.cell_at(t.global_position)
	if cell == _last_cell and entry.id == _last_zone:
		return
	var prev := _last_cell if entry.id == _last_zone else Vector2i(-99999, -99999)
	_last_cell = cell
	_last_zone = entry.id
	for trig: StoryTrigger in DB.story_triggers.values():
		if trig.zone_id == entry.id and trig.rect.has_point(cell) and trig.ready_to_fire():
			_fire(trig, zone, prev)
			return


func _fire(trig: StoryTrigger, zone: Zone, prev: Vector2i) -> void:
	if trig.once:
		GameState.set_flag(trig.flag())
	await run_talk(trig.talk)
	if trig.push_back and prev != Vector2i(-99999, -99999):
		var t: Trainer = world.trainer
		t.global_position = zone.to_global(zone.ground.map_to_local(prev))
		_last_cell = prev
