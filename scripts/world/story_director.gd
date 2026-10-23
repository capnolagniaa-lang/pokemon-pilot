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
	if npc != null:
		if npc.data.is_undefeated_trainer():
			challenge(npc)
		else:
			talk_to(npc)
		return true
	var living := _living_trainer_in_reach()
	if living != null:
		challenge_living(living)
		return true
	return false


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


## Cura al equipo: vida llena y sin estados el que está afuera. Si perdés contra un entrenador, volvés acá.
func heal_party() -> void:
	GameState.heal_party()
	GameState.last_heal_position = world.trainer.global_position
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
	var spotter := _trainer_seeing(entry.id, zone, cell)
	if spotter != null:
		challenge(spotter, true)
		return
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


# --- Entrenadores (E-1) -----------------------------------------------------------------------------------

## Un entrenador sin vencer de esta zona que te ve: mirando hacia vos, a `sight` celdas o menos, en línea recta y
## sin nada sólido en el medio.
func _trainer_seeing(zone_id: String, zone: Zone, cell: Vector2i) -> StoryNPC:
	if world.arena.active or world.trainer.locked:
		return null
	for npc: StoryNPC in npcs.values():
		if not is_instance_valid(npc) or npc.data.zone_id != zone_id or npc.data.sight <= 0 				or not npc.data.is_undefeated_trainer():
			continue
		var from := zone.cell_at(npc.global_position)
		var d := cell - from
		var f: Vector2i = npc.data.facing
		var along := d.x * f.x + d.y * f.y
		var across := d.x * f.y + d.y * f.x
		if across != 0 or along <= 0 or along > npc.data.sight:
			continue
		var clear := true
		for k in range(1, along):
			if not MapRules.is_walkable(zone, from + f * k):
				clear = false
				break
		if clear:
			return npc
	return null


## Un entrenador de la historia te desafía: "¡!", se acerca, dice su frase y van a la arena. Si le ganás queda la
## bandera vencido_<id> (y sus premios); si perdés, te va a volver a desafiar.
func challenge(npc: StoryNPC, spotted: bool = false) -> void:
	if busy or world.arena.active:
		return
	busy = true
	var t: Trainer = world.trainer
	t.locked = true
	t.autopilot = Vector2.ZERO
	var data := npc.data
	var td := data.trainer
	if spotted:
		npc.show_emote("!")
		await get_tree().create_timer(0.6).timeout
		await npc.walk_to(t.global_position)
	npc.look_at_point(t.global_position)
	var speaker := ("%s %s" % [td.title, td.display_name]).strip_edges()
	await _say(speaker, _lines(td, "desafio", "¡Peleá conmigo!"))
	var team: Array[CreatureInstance] = []
	for m in td.starting_team:
		team.append(CreatureInstance.create(m.species, m.level))
	var r: String = await world.arena.start({"name": td.display_name, "title": td.title, "team": team,
		"arena_id": td.arena_id, "texture": npc.sprite.texture, "leader": td.leader,
		"defeat_lines": _lines(td, "pierde", "¡Me ganaste!")})
	if r == "win":
		GameState.set_flag(data.defeated_flag())  # (el NPC ya no existe: la zona se recargó al volver)
		for f in td.reward_flags:
			GameState.set_flag(f)
		if td.reward_text != "":
			await _say("", PackedStringArray([td.reward_text]))
	busy = false


## Un entrenador vivo (docs/PLAN_ENTRENADORES.md) al alcance para hablarle (o null).
func _living_trainer_in_reach() -> TrainerNPC:
	for n in get_tree().get_nodes_in_group("trainer_npcs"):
		if n.global_position.distance_to(world.trainer.global_position) < TALK_RADIUS:
			return n
	return null


## Pelea contra un entrenador vivo con su equipo actual; queda anotado en su TrainerState (victorias/derrotas).
func challenge_living(npc: TrainerNPC) -> void:
	if busy or world.arena.active:
		return
	busy = true
	world.trainer.locked = true
	var td := npc.data
	var st := npc.state()
	await _say(td.display_name, _lines(td, "saludo", "¡Hola!") + _lines(td, "desafio", "¡Peleemos!"))
	for inst in st.team:
		inst.hp = inst.max_hp()  # entre peleas descansa
	var r: String = await world.arena.start({"name": td.display_name, "title": td.title, "team": st.team,
		"arena_id": td.arena_id, "texture": td.sprite, "leader": td.leader,
		"defeat_lines": _lines(td, "pierde", "¡Me ganaste!")})
	if r == "win":
		st.losses += 1
	else:
		st.wins += 1
		await _say(td.display_name, _lines(td, "gana", "¡Te gané!"))
	busy = false


## Frase de un entrenador ("|" separa globos).
func _lines(td: TrainerData, key: String, fallback: String) -> PackedStringArray:
	return str(td.lines.get(key, fallback)).split("|")


func _say(speaker: String, lines: PackedStringArray) -> void:
	var hud: CanvasItem = world.get_node_or_null("UI/HUD")
	if hud != null:
		hud.visible = false
	await dialog.say(speaker, lines)
	if hud != null:
		hud.visible = true
