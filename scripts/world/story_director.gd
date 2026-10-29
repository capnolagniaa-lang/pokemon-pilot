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
## Interacciones con lo que hay adelante del entrenador al apretar E (Corte, los basureros del gimnasio de Carmín):
## Callable(zona, celda, posición de adelante) -> bool (true = la tomó; la conversación la arma ella con `lock`/`say`).
var interactions: Array[Callable] = []
## Acciones especiales de las conversaciones (NpcTalk.action): nombre -> Callable que se espera (await).
var actions: Dictionary = {}
var _last_cell := Vector2i(-99999, -99999)
var _last_zone := ""
## Charla común abierta (no traba): dónde estaba el entrenador al empezar. Si se aleja CASUAL_LEAVE, se corta.
var _casual_from := Vector2.INF
const CASUAL_LEAVE := 20.0


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
## Con quién hablás: primero la persona que tenés enfrente (aunque otra esté más cerca al costado: en el Centro de
## Carmín una chica al lado del mostrador te tapaba a la enfermera); si no hay nadie enfrente, la más cercana.
func npc_in_reach() -> StoryNPC:
	var t: Trainer = world.trainer
	var facing := t.facing.normalized() if t.facing != Vector2.ZERO else Vector2.DOWN
	var best: StoryNPC = null
	var best_score := INF
	for npc in npcs.values():
		if not is_instance_valid(npc):
			continue
		var to: Vector2 = npc.global_position - t.global_position
		var d := to.length()
		if d >= TALK_RADIUS:
			continue
		var ahead := d < 1.0 or to.normalized().dot(facing) > 0.7
		var score := d - (1000.0 if ahead else 0.0)
		if score < best_score:
			best_score = score
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
		if npc.data.is_undefeated_trainer() and npc.data.challenge_on_talk and _has_fighter():
			challenge(npc)
		else:
			talk_to(npc)
		return true
	var living := _living_trainer_in_reach()
	if living != null:
		challenge_living(living)
		return true
	var t: Trainer = world.trainer
	var front := t.global_position + t.facing.normalized() * 16.0
	var entry: ZoneEntry = world.streamer.world_data.zone_at(front)
	var zone: Zone = world.streamer.zone_node(entry.id) if entry != null else null
	if zone != null:
		for h in interactions:
			if h.call(entry.id, zone.cell_at(front), front):
				return true
	return false


func register_interaction(handler: Callable) -> void:
	interactions.append(handler)


## Traba al entrenador y dice algo (para las interacciones registradas). Usar `unlock()` al terminar.
func lock() -> void:
	busy = true
	world.trainer.locked = true
	world.trainer.autopilot = Vector2.ZERO


func unlock() -> void:
	world.trainer.locked = false
	busy = false


func talk_to(npc: StoryNPC) -> void:
	var talk := npc.data.talk_now()
	if talk == null:
		return
	npc.look_at_point(world.trainer.global_position)
	await run_talk(talk, npc.data.display_name, true)


## ¿Es una charla común (solo texto, sin pregunta, pelea, regalo, banderas ni nada que pase después)? Esas no
## traban al entrenador: alejarse la corta (decisión del usuario 2026-10-28). Las importantes traban hasta el final.
static func is_casual(talk: NpcTalk) -> bool:
	return talk.confirm == "" and talk.battle_npc == "" and talk.action == "" and talk.give_pokemon == null \
		and not talk.heal and talk.give_items.is_empty() and talk.take_items.is_empty() and talk.set_flags.is_empty() \
		and talk.after_lines.is_empty() and talk.warp_zone == ""


## Abre la conversación (traba al entrenador, salvo las comunes con una persona: `casual_ok`) y al cerrarla aplica
## sus efectos. Los disparadores siempre traban (te frenan en un paso).
func run_talk(talk: NpcTalk, default_speaker: String = "", casual_ok := false) -> void:
	var t: Trainer = world.trainer
	if casual_ok and is_casual(talk):
		busy = true
		_casual_from = t.global_position
		await dialog.say(talk.speaker if talk.speaker != "" else default_speaker, talk.lines)
		_casual_from = Vector2.INF
		busy = false
		return
	busy = true
	t.locked = true
	t.autopilot = Vector2.ZERO
	var hud: CanvasItem = world.get_node_or_null("UI/HUD")
	if hud != null:
		hud.visible = false  # la caja de diálogo va abajo, donde está el HUD
	var speaker := talk.speaker if talk.speaker != "" else default_speaker
	await dialog.say(speaker, talk.lines)
	if talk.confirm != "" and await dialog.ask(speaker, talk.confirm, PackedStringArray(["Sí", "No"])) != 0:
		if hud != null:
			hud.visible = true
		t.locked = false
		busy = false
		return  # dijo que no: no pasa nada
	if talk.battle_npc != "" and DB.npcs.has(talk.battle_npc):
		if hud != null:
			hud.visible = true
		await fight(DB.npcs[talk.battle_npc], null, talk.battle_no_blackout)
		t.locked = true
	if talk.action != "" and actions.has(talk.action):
		if hud != null:
			hud.visible = true
		await actions[talk.action].call()
		t.locked = true
	var after := PackedStringArray()
	if talk.give_pokemon != null:
		var lvl := talk.give_level if talk.give_level > 0 else DB.config.starting_level
		var inst := CreatureInstance.create(talk.give_pokemon, lvl)
		if GameState.party.is_empty():
			GameState.party.append(inst)
			GameState.active_index = 0
			GameState.mark_fought(inst.species)
			GameState.pokedex_caught[inst.species.id] = true
			Events.party_changed.emit()
		else:
			GameState.add_to_party(inst)
		after.append("¡Recibiste a %s!" % inst.display_name())
	if talk.heal:
		heal_party()
		after.append("¡Tu equipo se recuperó por completo!")
	for id in talk.take_items:
		if GameState.remove_item(id, int(talk.take_items[id])) and DB.items.has(id):
			after.append("Entregaste %s." % DB.items[id].display_name)
	for id in talk.give_items:
		var n := int(talk.give_items[id])
		if DB.items.has(id) and n > 0:
			GameState.add_item(id, n)
			after.append("Recibiste %s%s." % [DB.items[id].display_name, " ×%d" % n if n > 1 else ""])
	for f in talk.set_flags:
		GameState.set_flag(f)
	if not after.is_empty():
		await dialog.say("", after)
	if not talk.after_lines.is_empty():
		await dialog.say(talk.after_speaker, talk.after_lines)
	if talk.warp_zone != "":
		await teleport(talk.warp_zone, talk.warp_cell)
	if hud != null:
		hud.visible = true
	t.locked = false
	busy = false


## Desmayo total (sin ningún Pokémon en pie fuera de una arena): fundido, el equipo curado y volvés al último
## lugar donde te curaron (o al inicio), como en FireRed.
func blackout() -> void:
	if busy or world.arena.active:
		return
	busy = true
	var t: Trainer = world.trainer
	t.locked = true
	await world.arena.fade_to(1.0)
	GameState.heal_party()
	var back: Vector2 = GameState.last_heal_position
	if back == Vector2.INF:
		var data: WorldData = world.streamer.world_data
		back = Vector2(data.spawn_cell * data.tile_size) + Vector2.ONE * data.tile_size / 2.0
	world.streamer.load_around_now(back)
	t.global_position = back
	t.trail = [back]
	world.camera.target = t
	world.camera.snap()
	world.respawn_companion()
	refresh()
	await get_tree().process_frame
	await world.arena.fade_to(0.0)
	await dialog.say("", PackedStringArray(["No te quedó ningún Pokémon en condiciones...",
		"Volviste corriendo a curarlos."]))
	t.locked = false
	busy = false


## Registra una acción especial para NpcTalk.action (la usan otros sistemas, ej. el Torneo).
func register_action(action_name: String, callable: Callable) -> void:
	actions[action_name] = callable


## Te lleva (con fundido) a una celda de una zona: carga la zona, mueve al entrenador y a su Pokémon.
func teleport(zone_id: String, cell: Vector2i) -> void:
	var data: WorldData = world.streamer.world_data
	var entry: ZoneEntry = null
	for z in data.zones:
		if z.id == zone_id:
			entry = z
	if entry == null:
		return
	await world.arena.fade_to(1.0)
	var pos := Vector2((entry.origin + cell) * data.tile_size) + Vector2.ONE * data.tile_size / 2.0
	world.streamer.load_around_now(pos)
	var t: Trainer = world.trainer
	t.global_position = pos
	t.trail = [pos]
	if is_instance_valid(world.companion):
		world.companion.global_position = pos + Vector2(0, -12)
	world.camera.snap()
	refresh()
	_last_cell = cell  # llegaste acá: si el primer paso dispara un bloqueo, te devuelve a esta celda
	_last_zone = zone_id
	await get_tree().process_frame
	await world.arena.fade_to(0.0)


## Cura al equipo: vida llena y sin estados el que está afuera. Si perdés contra un entrenador, volvés acá.
func heal_party() -> void:
	GameState.heal_party()
	Events.party_healed.emit()
	GameState.last_heal_position = world.trainer.global_position
	var c: Creature = world.companion
	if is_instance_valid(c):
		c.statuses.clear()
		c.health.changed.emit(c.instance.hp, c.instance.max_hp())


func _physics_process(_delta: float) -> void:
	if _casual_from != Vector2.INF and dialog.active and (world.combat.in_battle or world.warps.busy
			or world.trainer.global_position.distance_to(_casual_from) > CASUAL_LEAVE):
		dialog.cancel()
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
	if not is_instance_valid(zone):  # se recargó mientras hablaban
		zone = world.streamer.zone_node(trig.zone_id)
	if trig.push_back and trig.talk.warp_zone == "" and prev != Vector2i(-99999, -99999) and zone != null:
		var t: Trainer = world.trainer
		t.global_position = zone.to_global(zone.ground.map_to_local(prev))
		_last_cell = prev


# --- Entrenadores (E-1) -----------------------------------------------------------------------------------

## Tenés al menos un Pokémon en condiciones de pelear (sin Pokémon nadie te desafía).
func _has_fighter() -> bool:
	return GameState.party.any(func(i): return i.hp > 0.0)


## Un entrenador sin vencer de esta zona que te ve: mirando hacia vos, a `sight` celdas o menos, en línea recta y
## sin nada sólido en el medio.
func _trainer_seeing(zone_id: String, zone: Zone, cell: Vector2i) -> StoryNPC:
	if world.arena.active or world.trainer.locked or not _has_fighter():
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
		if is_instance_valid(npc):
			# Se espera con un timer: si la persona se borra a mitad de camino, su tween nunca termina.
			# (Tope de 3 s: si en el medio te fuiste por una puerta, no queda la historia trabada esperando que llegue.)
			var walk := minf(3.0, maxf(0.0, npc.global_position.distance_to(t.global_position) - 18.0) / 70.0)
			npc.walk_to(t.global_position)
			await get_tree().create_timer(walk + 0.05).timeout
	# Se descargó su zona, ya hay otra pelea o te fuiste lejos (una puerta): no quedar trabado.
	if not is_instance_valid(npc) or world.arena.active or npc.global_position.distance_to(t.global_position) > 96.0:
		t.locked = false
		busy = false
		return
	npc.look_at_point(t.global_position)
	var speaker := ("%s %s" % [td.title, td.display_name]).strip_edges()
	await _say(speaker, _lines(td, "desafio", "¡Peleá conmigo!"))
	await fight(data, npc.sprite.texture)
	busy = false


## Pelea contra el entrenador de una persona (su equipo, con los Pokémon que piden bandera filtrados). Si ganás:
## vencido_<id> y sus premios. Devuelve "win" o "lose".
func fight(data: NpcData, texture: Texture2D = null, no_blackout: bool = false) -> String:
	var td := data.trainer
	var team: Array[CreatureInstance] = []
	for m in td.starting_team:
		if m.requires_flag == "" or GameState.has_flag(m.requires_flag):
			team.append(CreatureInstance.create(m.species, m.level))
	if texture == null and ResourceLoader.exists("res://art/pret/characters/%s.png" % data.gfx):
		texture = load("res://art/pret/characters/%s.png" % data.gfx)
	var r: String = await world.arena.start({"name": td.display_name, "title": td.title, "team": team,
		"arena_id": td.arena_id, "texture": texture, "leader": td.leader, "no_blackout": no_blackout,
		"vs": data.gfx, "vs_color": team[0].species.primary_type().color if not team.is_empty() else Color(0.85, 0.15, 0.15),
		"music": "rival" if td.id.contains("rival") else ("lider" if td.leader else "entrenador"),
		"defeat_lines": _lines(td, "pierde", "¡Me ganaste!")})
	if r == "win":
		GameState.set_flag(data.defeated_flag())  # (el NPC ya no existe: la zona se recargó al volver)
		for f in td.reward_flags:
			GameState.set_flag(f)
		var got := PackedStringArray([td.reward_text]) if td.reward_text != "" else PackedStringArray()
		var cash := prize_of(td, team)
		if cash > 0:
			GameState.add_prize(cash)
			got.append("¡Ganaste $%d!" % cash)
		for id in td.reward_items:
			if DB.items.has(id):
				GameState.add_item(id, int(td.reward_items[id]))
				got.append("Recibiste %s." % DB.items[id].display_name)
		if not got.is_empty():
			await _say("", got)
	elif no_blackout and td.lines.has("gana"):
		await _say(td.display_name, _lines(td, "gana", "¡Te gané!"))
	return r


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


## Premio en dinero de un entrenador (TrainerData.prize o automático según el nivel de su equipo).
static func prize_of(td: TrainerData, team: Array[CreatureInstance]) -> int:
	if td.prize > 0:
		return td.prize
	var top := 0
	for inst in team:
		top = maxi(top, inst.level)
	return top * (60 if td.leader else 20)


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
