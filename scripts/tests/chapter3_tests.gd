class_name Chapter3Tests
extends Chapter2Tests
## Capítulo 3 de la historia (docs/PLAN_CAPITULO_3.md: de Ciudad Celeste al Gimnasio de Ciudad Carmín):
##   godot --headless --path . --quit-after 150000 -- --autotest-story-h3
## Datos (entrenadores de FireRed, arena eléctrica, tienda, MO01/MT28) y el recorrido: el Rocket de la casa robada, el
## Ticket en el muelle, el rival en el S.S. Anne, el capitán y Corte, cortar el árbol, los basureros y Lt. Surge.
## Vitrina de la arena de Surge:
##   godot --path . --quit-after 600 --write-movie out/f.png --fixed-fps 30 -- --showcase-surge

const TRAINERS_CH3 := {"ruta6": 6, "ciudad_carmin_gimnasio": 4}


func run() -> void:
	var r := {}
	var arena: ArenaData = load("res://data/arenas/arena_gimnasio_electrico.tres")
	r["Arena eléctrica de Surge (gimnasio épico)"] = arena != null and arena.epic and arena.element_id == "electrico"
	var counts := {}
	for n: NpcData in DB.npcs.values():
		if n.trainer != null:
			var key: String = "ss_anne" if n.zone_id.begins_with("ss_anne") else n.zone_id
			counts[key] = counts.get(key, 0) + 1
	r["Entrenadores: Ruta 6 (6), gimnasio (4) y S.S. Anne (16 + rival) %s" % str(counts.get("ss_anne", 0))] = \
		TRAINERS_CH3.keys().all(func(z): return counts.get(z, 0) == TRAINERS_CH3[z]) and counts.get("ss_anne", 0) == 17
	var surge: NpcData = DB.npcs.get("ciudad_carmin_gimnasio_ltsurge")
	r["Lt. Surge: Voltorb 21, Pikachu 18 y Raichu 24 en la arena eléctrica"] = surge != null and surge.trainer.leader \
		and surge.trainer.arena_id == "arena_gimnasio_electrico" \
		and surge.trainer.starting_team.map(func(m): return [m.species.id, m.level]) == [["voltorb", 21], ["pikachu", 18], ["raichu", 24]]
	r["Tienda de Carmín (Antihielo), MO01 Corte y MT28 Excavar"] = load("res://data/shops/ciudad_carmin.tres").items.has(DB.items["antihielo"]) \
		and DB.items.has("mo01") and DB.items["mt28"].teaches_move != null
	r["Vecinos del basurero 0 (esquina): 1 y 5"] = VermilionGymPuzzle.neighbors(0) == [1, 5] and VermilionGymPuzzle.neighbors(7).size() == 4

	# --- Partida de historia con la Medalla Cascada ---
	GameState.new_story()
	for f in ["oak_te_freno", "tiene_inicial", "rival_lab_peleado", "rival_charmander", "tiene_paquete", "paquete_entregado",
			"tiene_pokedex", "rival_ruta22_peleado", "medalla_roca", "fosil_elegido", "rival_celeste_peleado", "medalla_cascada"]:
		GameState.set_flag(f)
	GameState.party.append(CreatureInstance.create(DB.species["pikachu"], 45))
	GameState.party.append(CreatureInstance.create(DB.species["geodude"], 45))
	GameState.active_index = 0
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	_dialogs()
	await get_tree().create_timer(0.3).timeout
	r["La Guía arranca el capítulo 3"] = StoryGuide.current().get("title", "") == "Rumbo al S.S. Anne" \
		and StoryGuide.chapter_name(StoryGuide.current()["index"]).begins_with("Capítulo 3")

	# --- Celeste: el policía ya no está y el Rocket devuelve la MT28 ---
	r["Con la Medalla Cascada el policía deja la puerta"] = not DB.npcs["ciudad_celeste_policeman"].visible_now()
	await _win(DB.npcs["ciudad_celeste_grunt"])
	r["Le ganás al Rocket de la casa robada: MT28"] = GameState.has_flag("rocket_celeste_peleado") and GameState.item_count("mt28") == 1

	# --- El muelle: sin Ticket no se sube ---
	await _go("ciudad_carmin", Vector2i(39, 46))
	await _step_to("ciudad_carmin", Vector2i(39, 48))
	await _until(func(): return world.story.busy, 3.0)
	await _idle()
	r["Sin Ticket el marinero no te deja subir"] = _zone_id() == "ciudad_carmin" and _cell().y < 48
	GameState.add_item("ticket_barco", 1)
	GameState.set_flag("ticket_barco_recibido")
	await _step_to("ciudad_carmin", Vector2i(39, 48))
	await get_tree().create_timer(0.4).timeout
	r["Con el Ticket pasás"] = not world.story.busy

	# --- S.S. Anne: el rival y el capitán ---
	for inst in GameState.party:
		inst.hp = inst.max_hp()
	await _go("ss_anne_2p", Vector2i(31, 6))
	await _step_to("ss_anne_2p", Vector2i(31, 4))
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	r["El rival te frena en el 2º piso (Pidgeotto, Raticate, Kadabra y Charmeleon)"] = world.arena.active and world.arena.foe_team.size() == 4 \
		and world.arena.foe_team.any(func(i): return i.species.id == "charmeleon")
	await _ko_all()
	r["Le ganás al rival en el barco"] = GameState.has_flag("rival_ss_anne_peleado")
	var captain: NpcData = DB.npcs["ss_anne_capitan_captain"]
	await _go("ss_anne_capitan", captain.cell + Vector2i(0, 1))
	_talk_to("ss_anne_capitan_captain")
	await _idle()
	r["El capitán te da la MO01 Corte"] = GameState.item_count("mo01") == 1 and GameState.has_flag("tiene_corte")

	# --- Corte: el árbol que tapa el gimnasio ---
	await _go("ciudad_carmin", Vector2i(34, 41))
	var tree: EnvObject = world.field_moves.cuttable_near(world.trainer.global_position + Vector2(16, 0))
	r["Hay un árbol cortable frente al gimnasio"] = tree != null
	world.trainer.facing = Vector2.RIGHT
	answer = 0
	r["E frente al árbol pregunta si usás Corte"] = world.story.try_interact()
	await _idle()
	await get_tree().create_timer(0.4).timeout
	r["Lo cortaste"] = not is_instance_valid(tree) or tree._gone

	# --- Los basureros (al entrar al gimnasio se vuelven a esconder, como en FireRed) ---
	for id in ["tucker", "dwayne", "baily"]:  # los entrenadores del gimnasio ya vencidos (si no, te ven y desafían)
		GameState.set_flag("vencido_ciudad_carmin_gimnasio_" + id)
	await _go("ciudad_carmin_gimnasio", Vector2i(5, 16))
	var pz: VermilionGymPuzzle = world.vermilion_puzzle
	pz.switch1 = 7
	pz.switch2 = 8
	pz.found_first = false
	r["Un basurero cualquiera: nada"] = pz.check_can(0) == "nada"
	r["El primer interruptor"] = pz.check_can(7) == "primero"
	var reset := pz.check_can(2)
	r["Errar el segundo reinicia (y cambian de lugar)"] = reset == "reinicio" and not pz.found_first
	pz.check_can(pz.switch1)
	var gym: Zone = world.streamer.zone_node("ciudad_carmin_gimnasio")
	r["Con la barrera puesta no se pasa"] = not MapRules.is_walkable(gym, Vector2i(5, 6))
	r["El segundo interruptor abre la barrera"] = pz.check_can(pz.switch2) == "abierta" and GameState.has_flag("surge_puerta_abierta") \
		and MapRules.is_walkable(gym, Vector2i(5, 6)) and MapRules.is_walkable(gym, Vector2i(5, 7))
	await _go("ciudad_carmin_gimnasio", VermilionGymPuzzle.CANS[5] + Vector2i(0, 1))
	world.trainer.facing = Vector2.UP
	r["E frente a un basurero lo revisa"] = world.story.try_interact()
	await _idle()

	# --- Lt. Surge ---
	for inst in GameState.party:
		inst.hp = inst.max_hp()
	await _win(surge)
	r["Le ganás a Lt. Surge: Medalla Trueno"] = GameState.has_flag("medalla_trueno")
	r["Con la Medalla Trueno, capítulo 3 completo"] = StoryGuide.current().get("title", "") == "¡Capítulo 3 completo!"

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[historia-h3] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-story-h3] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase_surge() -> void:
	var w: Node = await autotest._setup_kit_world("geodude")
	w.combat.end_battle()
	await get_tree().physics_frame
	var team: Array[CreatureInstance] = [CreatureInstance.create(DB.species["voltorb"], 21),
		CreatureInstance.create(DB.species["raichu"], 24)]
	w.arena.start({"name": "Lt. Surge", "title": "Líder", "team": team, "arena_id": "arena_gimnasio_electrico",
		"no_blackout": true, "leader": true})
	await get_tree().create_timer(18.0).timeout
	get_tree().quit()
