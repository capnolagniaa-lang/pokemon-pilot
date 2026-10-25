class_name Chapter2Tests
extends StoryH1Tests
## Capítulo 2 de la historia (docs/PLAN_CAPITULO_2.md: de Ciudad Plateada al Gimnasio de Ciudad Celeste):
##   godot --headless --path . --quit-after 150000 -- --autotest-story-h2
## Datos (entrenadores con los equipos de FireRed, arena de Misty, tienda, objetos) y el recorrido con la historia:
## Miguel y el fósil, el rival en Celeste, el Rocket del Puente Pepita, Bill, el Magikarp, Misty y la Guía.
## Vitrina de la arena de Misty (Staryu y Starmie en el gimnasio de agua):
##   godot --path . --quit-after 600 --write-movie out/f.png --fixed-fps 30 -- --showcase-misty

const TRAINERS_PER_ZONE := {"ruta3": 8, "mt_moon": 7, "mt_moon_s2": 5, "ruta24": 7, "ruta25": 9, "ciudad_celeste_gimnasio": 3}


func run() -> void:
	var r := {}
	var arena: ArenaData = load("res://data/arenas/arena_gimnasio_agua.tres")
	r["Arena de agua de Misty (gimnasio épico)"] = arena != null and arena.epic and arena.element_id == "agua" \
		and ResourceLoader.exists(arena.scene_path)
	var counts := {}
	for n: NpcData in DB.npcs.values():
		if n.trainer != null:
			counts[n.zone_id] = counts.get(n.zone_id, 0) + 1
	var bad := TRAINERS_PER_ZONE.keys().filter(func(z): return counts.get(z, 0) != TRAINERS_PER_ZONE[z])
	r["Entrenadores de FireRed por zona %s" % str(TRAINERS_PER_ZONE)] = bad.is_empty()
	var misty: NpcData = DB.npcs.get("ciudad_celeste_gimnasio_misty")
	r["Misty: líder con Staryu 18 + Starmie 21 en la arena de agua"] = misty != null and misty.trainer.leader \
		and misty.trainer.arena_id == "arena_gimnasio_agua" \
		and misty.trainer.starting_team.map(func(m): return [m.species.id, m.level]) == [["staryu", 18], ["starmie", 21]]
	var shop: ShopData = load("res://data/shops/ciudad_celeste.tres")
	r["La Tienda de Celeste vende Superpoción"] = shop.items.has(DB.items["superpocion"])
	r["Objetos nuevos: fósiles, Pepita, Caramelo Raro, Piedra Lunar, Ticket"] = ["fosil_domo", "fosil_helix", "pepita",
		"caramelo_raro", "piedra_lunar", "ticket_barco", "trozo_estrella"].all(func(id): return DB.items.has(id))

	# --- Una partida de historia con la Medalla Roca y un equipo fuerte ---
	GameState.new_story()
	for f in ["oak_te_freno", "tiene_inicial", "rival_lab_peleado", "rival_charmander", "tiene_paquete", "paquete_entregado", "tiene_pokedex",
			"rival_ruta22_peleado", "medalla_roca"]:
		GameState.set_flag(f)
	GameState.party.append(CreatureInstance.create(DB.species["pikachu"], 40))
	GameState.party.append(CreatureInstance.create(DB.species["bulbasaur"], 40))
	GameState.active_index = 0
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	_dialogs()
	await get_tree().create_timer(0.3).timeout
	r["La Guía arranca el capítulo 2 (Mt. Moon)"] = StoryGuide.current().get("title", "") == "El Mt. Moon" \
		and StoryGuide.chapter_name(StoryGuide.current()["index"]).begins_with("Capítulo 2")

	# --- Caramelo Raro: sube un nivel ---
	GameState.add_item("caramelo_raro", 1)
	var lvl: int = GameState.party[1].level
	r["El Caramelo Raro sube un nivel"] = GameState.use_item_on("caramelo_raro", GameState.party[1]) != "" \
		and GameState.party[1].level == lvl + 1

	# --- Mt. Moon: Miguel y el fósil ---
	var fossil: NpcData = DB.npcs["mt_moon_s2_domefossil"]
	r["Antes de ganarle a Miguel, el fósil no se puede agarrar"] = fossil.talk_now() != null and fossil.talk_now().give_items.is_empty()
	await _win(DB.npcs["mt_moon_s2_miguel"])
	r["Le ganás a Miguel"] = GameState.has_flag("vencido_mt_moon_s2_miguel")
	await _go("mt_moon_s2", fossil.cell + Vector2i(0, 1))
	_talk_to("mt_moon_s2_domefossil")
	await _idle()
	r["Elegís el Fósil Domo (y el Hélix se lo queda Miguel)"] = GameState.item_count("fosil_domo") == 1 \
		and GameState.has_flag("fosil_elegido") and not DB.npcs["mt_moon_s2_helixfossil"].visible_now()
	r["La Guía pasa a Ciudad Celeste"] = StoryGuide.current().get("title", "") == "Ciudad Celeste"

	# --- Centro de la Ruta 4: el Magikarp de $500 ---
	GameState.money = 800
	var party_n := GameState.party.size()
	await _go("ruta4_centro", DB.npcs["ruta4_centro_magikarpsalesman"].cell + Vector2i(1, 0))
	_talk_to("ruta4_centro_magikarpsalesman")
	await _idle()
	r["Comprás el Magikarp por $500 (una vez)"] = GameState.money == 300 and GameState.party.size() == party_n + 1 \
		and GameState.party[-1].species.id == "magikarp" and GameState.has_flag("magikarp_comprado")

	# --- Ciudad Celeste: el rival al ir al Puente Pepita ---
	for inst in GameState.party:
		inst.hp = inst.max_hp()
	await _go("ciudad_celeste", Vector2i(39, 7))
	r["El rival espera al norte de Celeste"] = is_instance_valid(world.story.npcs.get("ciudad_celeste_0x0"))
	await _step_to("ciudad_celeste", Vector2i(39, 4))
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	r["El rival te frena (Pidgeotto, Abra, Rattata y Squirtle)"] = world.arena.active and world.arena.foe_team.size() == 4
	await _ko_all()
	r["Le ganás al rival en Celeste"] = GameState.has_flag("rival_celeste_peleado")

	# --- Puente Pepita: los cinco y el Rocket (la Pepita es el premio) ---
	for id in ["cale", "ali", "timmy", "reli", "ethan"]:
		GameState.set_flag("vencido_ruta24_" + id)
	await _go("ruta24", Vector2i(5, 31))
	await _step_to("ruta24", Vector2i(5, 28))
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	await _ko_all()
	r["El Rocket del puente: le ganás y te da la Pepita"] = GameState.has_flag("rocket_puente_peleado") \
		and GameState.item_count("pepita") == 1

	# --- Casa de Bill ---
	await _go("casa_bill", DB.npcs["casa_bill_bill_2"].cell + Vector2i(0, 1))
	_talk_to("casa_bill_bill_2")
	await _idle()
	r["Bill-Clefairy: activás el Separador"] = GameState.has_flag("bill_ayudado")
	await _go("casa_bill", DB.npcs["casa_bill_bill"].cell + Vector2i(0, 1))
	_talk_to("casa_bill_bill")
	await _idle()
	r["Bill te da el Ticket del barco"] = GameState.item_count("ticket_barco") == 1

	# --- La Tienda de Celeste ---
	r["El vendedor de Celeste abre la tienda"] = DB.npcs["ciudad_celeste_tienda_clerk"].talk_now().action == "tienda_ciudad_celeste" \
		and world.story.actions.has("tienda_ciudad_celeste")

	# --- Gimnasio: Misty ---
	for inst in GameState.party:
		inst.hp = inst.max_hp()
	await _win(misty)
	r["Le ganás a Misty: Medalla Cascada"] = GameState.has_flag("medalla_cascada")
	r["Con la Medalla Cascada, la Guía pasa al capítulo 3"] = StoryGuide.current().get("title", "") == "Rumbo al S.S. Anne"

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[historia-h2] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-story-h2] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Pelea contra un entrenador de la historia y le gana (debilita a sus Pokémon de un golpe).
func _win(data: NpcData) -> void:
	await _go(data.zone_id, data.cell + Vector2i(0, 2))
	world.story.fight.call_deferred(data)
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	await _ko_all()


func _ko_all() -> void:
	for k in 6:
		if not world.arena.active:
			break
		_ko(world.arena.foe)
		await _until(func(): return not world.arena.active or (is_instance_valid(world.arena.foe) and not world.arena.foe.is_down()), 6.0)
	# fight() directo no traba la historia: esperar también a que se cierre el cartel del premio.
	for k in 2:
		await _until(func(): return not world.arena.active and not world.story.busy and not world.story.dialog.active, 15.0)
		await get_tree().create_timer(0.5).timeout


func showcase_misty() -> void:
	var w: Node = await autotest._setup_kit_world("pikachu")
	w.combat.end_battle()
	await get_tree().physics_frame
	var team: Array[CreatureInstance] = [CreatureInstance.create(DB.species["staryu"], 18),
		CreatureInstance.create(DB.species["starmie"], 21)]
	w.arena.start({"name": "Misty", "title": "Líder", "team": team, "arena_id": "arena_gimnasio_agua",
		"no_blackout": true, "leader": true})
	await get_tree().create_timer(18.0).timeout
	get_tree().quit()
