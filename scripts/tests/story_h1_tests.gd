class_name StoryH1Tests
extends Node
## Autotest de la historia H-1 (docs/PLAN_HISTORIA.md): partida de historia en tu cuarto sin Pokémon, Oak te frena
## en el pasto, el inicial en la mesa del laboratorio (Sí/No), el rival elige el ventajoso y te desafía al salir.
##   godot --headless --path . --quit-after 100000 -- --autotest-story-h1

var autotest: Node
var world: Node
## Respuesta automática a las preguntas Sí/No (0 = Sí).
var answer := 0


func run() -> void:
	var r := {}
	GameState.new_story()
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	_dialogs()
	await get_tree().create_timer(0.3).timeout
	var zone: ZoneEntry = world.streamer.world_data.zone_at(world.trainer.global_position)
	r["La historia arranca en tu cuarto"] = zone != null and zone.id == "casa_jugador_2p"
	r["Sin Pokémon al empezar"] = GameState.party.is_empty() and not is_instance_valid(world.companion)
	var saved := GameState.to_dict()
	r["Se puede guardar y cargar sin Pokémon (antes del laboratorio)"] = GameState.from_dict(saved) and GameState.party.is_empty()

	# --- Mamá antes del laboratorio ---
	await _go("casa_jugador", DB.npcs["casa_jugador_mom"].cell + Vector2i(-1, 0))
	world.story.try_interact()
	await _until(func(): return world.story.dialog.active, 2.0)
	var mom_talk: NpcTalk = DB.npcs["casa_jugador_mom"].talk_now()
	r["Mamá te manda al laboratorio (y todavía no cura)"] = world.story.dialog.active and mom_talk != null 		and " ".join(mom_talk.lines).contains("Oak") and not mom_talk.heal
	await _idle()

	# --- Oak te frena al querer salir hacia el pasto ---
	await _go("pueblo_paleta", Vector2i(57, 5))
	await _step_to("pueblo_paleta", Vector2i(57, 1))
	await _until(func(): return GameState.has_flag("oak_te_freno") and not world.story.busy, 12.0)
	zone = world.streamer.world_data.zone_at(world.trainer.global_position)
	r["Oak te frena y te lleva al laboratorio"] = GameState.has_flag("oak_te_freno") and zone != null and zone.id == "laboratorio_oak"
	r["En el laboratorio están Oak, el rival y las 3 Poké Balls"] = ["laboratorio_oak_profoak", "laboratorio_oak_rival",
		"laboratorio_oak_bulbasaurball", "laboratorio_oak_squirtleball", "laboratorio_oak_charmanderball"].all(
		func(id): return is_instance_valid(world.story.npcs.get(id)))

	# --- Sin Pokémon no te deja irte ---
	await _step_to("laboratorio_oak", Vector2i(6, 11))
	await _until(func(): return world.story.busy, 3.0)
	await _until(func(): return not world.story.busy, 5.0)
	r["Sin Pokémon, Oak no te deja irte"] = _cell() != Vector2i(6, 11) and _zone_id() == "laboratorio_oak"

	# --- Decir que no y después que sí a Squirtle ---
	await _go("laboratorio_oak", Vector2i(9, 5))
	answer = 1
	_talk_to("laboratorio_oak_squirtleball")
	await _idle()
	r["Decir que no a la Poké Ball no te da nada"] = GameState.party.is_empty()
	answer = 0
	_talk_to("laboratorio_oak_squirtleball")
	await _idle()
	r["Elegir Squirtle te lo da (Nv. 5)"] = GameState.party.size() == 1 and GameState.party[0].species.id == "squirtle" \
		and GameState.party[0].level == DB.config.starting_level and GameState.has_flag("tiene_inicial")
	r["El rival se lleva a Bulbasaur (le gana al agua)"] = GameState.has_flag("rival_bulbasaur")
	await get_tree().process_frame
	r["Las Poké Balls elegidas desaparecen de la mesa"] = not is_instance_valid(world.story.npcs.get("laboratorio_oak_squirtleball")) \
		and not is_instance_valid(world.story.npcs.get("laboratorio_oak_bulbasaurball")) \
		and is_instance_valid(world.story.npcs.get("laboratorio_oak_charmanderball"))
	r["Tu Pokémon sale a acompañarte"] = is_instance_valid(world.companion) and world.companion.instance.species.id == "squirtle"
	_talk_to("laboratorio_oak_charmanderball")
	await _idle()
	r["La otra Poké Ball ya no se puede elegir"] = GameState.party.size() == 1

	# --- El rival te desafía al salir (con el inicial que le gana al tuyo) ---
	GameState.party[0].level = 15
	GameState.party[0].hp = GameState.party[0].max_hp()
	await _step_to("laboratorio_oak", Vector2i(6, 10))
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	r["El rival te desafía al querer salir"] = world.arena.active and world.arena.foe_name == "Azul"
	r["El rival usa a Bulbasaur Nv. 5"] = is_instance_valid(world.arena.foe) and world.arena.foe.instance.species.id == "bulbasaur" \
		and world.arena.foe.instance.level == 5
	_ko(world.arena.foe)
	await _until(func(): return not world.arena.active and not world.story.busy, 15.0)
	r["Ganarle: el rival se va y queda anotado"] = GameState.has_flag("rival_lab_peleado") \
		and not is_instance_valid(world.story.npcs.get("laboratorio_oak_rival")) and _zone_id() == "laboratorio_oak"

	# --- Perder la primera pelea no te manda a ningún lado (la historia sigue) ---
	GameState.set_flag("rival_lab_peleado", false)
	GameState.set_flag("visto_rival_laboratorio", false)
	GameState.set_flag("vencido_laboratorio_oak_rival", false)
	GameState.last_heal_position = Vector2(0, 0)
	await _go("laboratorio_oak", Vector2i(6, 8))
	await _step_to("laboratorio_oak", Vector2i(6, 10))
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	_ko(world.companion)
	await _until(func(): return not world.arena.active and not world.story.busy, 15.0)
	r["Perder con el rival: seguís en el laboratorio y te curan"] = _zone_id() == "laboratorio_oak" and world.arena.result == "lose" \
		and GameState.party[0].hp == GameState.party[0].max_hp() and GameState.has_flag("rival_lab_peleado")

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[historia-h1] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-story-h1] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Avanza los diálogos y contesta las preguntas con `answer`.
func _dialogs() -> void:
	while is_inside_tree():
		await get_tree().create_timer(0.12).timeout
		var d: DialogBox = world.story.dialog
		if d.active:
			if d._choosing:
				d.choose(answer)
			else:
				d.advance()


func _idle() -> void:
	await get_tree().process_frame
	await _until(func(): return not world.story.busy and not world.story.dialog.active, 10.0)


func _talk_to(id: String) -> void:
	var npc: StoryNPC = world.story.npcs.get(id)
	if npc != null:
		world.story.talk_to(npc)


func _ko(c: Creature) -> void:
	if is_instance_valid(c):
		c.health.apply_damage(c.instance.max_hp() * 10.0)


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func _zone_id() -> String:
	var z: ZoneEntry = world.streamer.world_data.zone_at(world.trainer.global_position)
	return z.id if z != null else ""


func _cell() -> Vector2i:
	var z: ZoneEntry = world.streamer.world_data.zone_at(world.trainer.global_position)
	return Vector2i(world.trainer.global_position / world.streamer.world_data.tile_size) - z.origin if z != null else Vector2i(-1, -1)


func _pos(zone_id: String, cell: Vector2i) -> Vector2:
	var data: WorldData = world.streamer.world_data
	for z in data.zones:
		if z.id == zone_id:
			return Vector2((z.origin + cell) * data.tile_size) + Vector2.ONE * data.tile_size / 2.0
	return Vector2.ZERO


## Teletransporta al entrenador (sin disparar nada en el camino).
func _go(zone_id: String, cell: Vector2i) -> void:
	var pos := _pos(zone_id, cell)
	world.streamer.load_around_now(pos)
	world.trainer.global_position = pos
	world.camera.snap()
	for i in 3:
		await get_tree().process_frame
	world.story.refresh()
	await get_tree().physics_frame
	await get_tree().physics_frame


## Pasa a una celda (como si caminara hasta ahí: los disparadores la ven).
func _step_to(zone_id: String, cell: Vector2i) -> void:
	world.trainer.global_position = _pos(zone_id, cell)
	for i in 3:
		await get_tree().physics_frame
