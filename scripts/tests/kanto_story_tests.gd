class_name KantoStoryTests
extends Chapter2Tests
## Capítulos 4 a 8 (docs/PLAN_RESTO_KANTO.md: de Carmín a la Liga Pokémon):
##   godot --headless --path . --quit-after 400000 -- --autotest-story-h4
## Datos (entrenadores automáticos de FireRed, líderes, Alto Mando, tiendas) y el recorrido de los hitos con la historia:
## rival en la Torre, Giovanni y el Scope Silph, el Té y los guardias de Azafrán, Erika, Marowak, Sr. Fuji y la Poké
## Flauta, la Zona Safari (Surf y Fuerza), Koga, Silph S.A., Sabrina, la llave de Canela, Blaine, el gimnasio de Ciudad
## Verde, el rival en la Ruta 22, la garita de las 8 medallas, el Alto Mando y el Campeón.

const LEADERS := {"ciudad_azulona_gimnasio": "medalla_arcoiris", "ciudad_fucsia_gimnasio": "medalla_alma",
	"ciudad_azafran_gimnasio": "medalla_pantano", "isla_canela_gimnasio": "medalla_volcan", "ciudad_verde_gimnasio": "medalla_tierra"}


func run() -> void:
	var r := {}
	var trainers := DB.npcs.values().filter(func(n): return n.trainer != null)
	r["Entrenadores de todo Kanto (%d)" % trainers.size()] = trainers.size() >= 330
	for zone in LEADERS:
		var lead := _leader(zone)
		r["Líder de %s: %s, medalla %s" % [zone, lead.trainer.display_name if lead else "?", LEADERS[zone]]] = lead != null \
			and lead.trainer.reward_flags.has(LEADERS[zone]) and lead.trainer.arena_id.begins_with("arena_gimnasio_")
	for e in ["liga_lorelei_lorelei", "liga_bruno_bruno", "liga_agatha_agatha", "liga_lance_lance", "liga_campeon_0x0"]:
		r["Alto Mando / Campeón: %s" % e] = DB.npcs.has(e) and DB.npcs[e].trainer != null and DB.npcs[e].trainer.starting_team.size() >= 5
	r["Tiendas de todas las ciudades"] = ["pueblo_lavanda", "ciudad_azulona", "ciudad_azafran", "ciudad_fucsia", "isla_canela",
		"meseta_anil"].all(func(s): return ResourceLoader.exists("res://data/shops/%s.tres" % s))

	GameState.new_story()
	for f in ["oak_te_freno", "tiene_inicial", "rival_lab_peleado", "rival_squirtle", "tiene_paquete", "paquete_entregado", "tiene_pokedex",
			"rival_ruta22_peleado", "medalla_roca", "fosil_elegido", "rival_celeste_peleado", "medalla_cascada", "rival_ss_anne_peleado",
			"tiene_corte", "surge_puerta_abierta", "medalla_trueno"]:
		GameState.set_flag(f)
	GameState.add_item("mo01", 1)
	GameState.party.append(CreatureInstance.create(DB.species["mewtwo"], 90))
	GameState.party.append(CreatureInstance.create(DB.species["dragonite"], 90))
	GameState.active_index = 0
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	_dialogs()
	await get_tree().create_timer(0.3).timeout
	r["La Guía arranca el capítulo 4"] = StoryGuide.current().get("title", "") == "El Escondite Rocket"

	# --- Cap. 4 ---
	await _go("ruta5_garita", Vector2i(4, 7))
	await _step_to("ruta5_garita", Vector2i(4, 5))
	await _until(func(): return world.story.busy, 3.0)
	await _idle()
	r["Sin Té el guardia de Azafrán no te deja pasar"] = _cell().y > 5
	await _rival_trigger("torre_pokemon_2p", Vector2i(9, 8), Vector2i(9, 7))
	r["El rival en la Torre Pokémon"] = GameState.has_flag("rival_torre_peleado")
	await _win(DB.npcs["escondite_rocket_s4_giovanni"])
	r["Giovanni en el Escondite Rocket"] = GameState.has_flag("giovanni_escondite_vencido")
	await _talk("escondite_rocket_s4_silphscope")
	r["Queda el Scope Silph"] = GameState.item_count("silph_scope") == 1
	await _talk("ciudad_azulona_mansion_1p_teawoman")
	r["La abuela de la Mansión te da el Té"] = GameState.item_count("te") == 1
	await _talk("ciudad_azulona_mansion_cuarto_eeveeball")
	r["El Eevee de regalo"] = GameState.party.any(func(i): return i.species.id == "eevee")
	await _beat_gym("ciudad_azulona_gimnasio")
	r["Erika: Medalla Arcoíris"] = GameState.has_flag("medalla_arcoiris")

	# --- Cap. 5 ---
	await _go("torre_pokemon_6p", Vector2i(11, 14))
	await _step_to("torre_pokemon_6p", Vector2i(11, 15))
	await _until(func(): return world.story.busy, 3.0)
	await _idle()
	r["Con el Scope Silph, el fantasma era Marowak (descansa en paz)"] = GameState.has_flag("marowak_en_paz")
	for g in ["grunt1", "grunt2", "grunt3"]:
		GameState.set_flag("vencido_torre_pokemon_7p_" + g)
	await _talk("torre_pokemon_7p_mrfuji")
	r["El Sr. Fuji te da la Poké Flauta"] = GameState.item_count("poke_flauta") == 1 and GameState.has_flag("fuji_rescatado")
	await _talk("ruta16_snorlax")
	r["La Poké Flauta despierta al Snorlax de la Ruta 16"] = GameState.has_flag("snorlax_ruta16_despierto")
	await _talk("zona_safari_casa_secreta_attendant")
	r["La Casa Secreta de la Zona Safari: MO03 Surf"] = GameState.item_count("mo03") == 1
	GameState.add_item("dientes_oro", 1)
	GameState.set_flag("objeto_zona_safari_oeste_itemgoldteeth")
	await _talk("casa_guarda_warden")
	r["El guarda cambia los Dientes de Oro por la MO04 Fuerza"] = GameState.item_count("mo04") == 1 and GameState.item_count("dientes_oro") == 0
	await _beat_gym("ciudad_fucsia_gimnasio")
	r["Koga: Medalla Alma"] = GameState.has_flag("medalla_alma")

	# --- Cap. 6 ---
	await _go("ruta5_garita", Vector2i(4, 7))
	await _step_to("ruta5_garita", Vector2i(4, 5))
	await _until(func(): return world.story.busy, 3.0)
	await _idle()
	await _step_to("ruta5_garita", Vector2i(4, 4))
	await get_tree().create_timer(0.3).timeout
	r["Con el Té el guardia te deja pasar"] = _cell().y <= 5 and not world.story.busy
	await _rival_trigger("silph_7p", Vector2i(3, 9), Vector2i(3, 8))
	r["El rival en Silph S.A."] = GameState.has_flag("rival_silph_peleado")
	await _talk("silph_7p_laprasguy")
	r["El Lapras de regalo"] = GameState.party.any(func(i): return i.species.id == "lapras") or GameState.box.any(func(i): return i.species.id == "lapras")
	await _win(DB.npcs["silph_11p_0x0"])
	r["Giovanni en Silph: Azafrán liberada"] = GameState.has_flag("silph_liberada") and not DB.npcs["ciudad_azafran_rocketgrunt1"].visible_now()
	await _talk("silph_11p_president")
	r["El presidente te da la Master Ball"] = GameState.item_count("master_ball") >= 1
	await _beat_gym("ciudad_azafran_gimnasio")
	r["Sabrina: Medalla Pantano"] = GameState.has_flag("medalla_pantano")

	# --- Cap. 7 ---
	await _go("isla_canela", Vector2i(38, 7))
	await _step_to("isla_canela", Vector2i(38, 5))
	await _until(func(): return world.story.busy, 3.0)
	await _idle()
	r["Sin la Llave Secreta el gimnasio de Canela está cerrado"] = _cell().y > 5
	GameState.set_flag("objeto_mansion_pokemon_s1_itemsecretkey")
	await _beat_gym("isla_canela_gimnasio")
	r["Blaine: Medalla Volcán"] = GameState.has_flag("medalla_volcan")

	# --- Cap. 8 ---
	await _beat_gym("ciudad_verde_gimnasio")
	r["Giovanni, líder de Ciudad Verde: Medalla Tierra"] = GameState.has_flag("medalla_tierra")
	await _rival_trigger("ruta22", Vector2i(49, 30), Vector2i(50, 30))
	r["El rival en la Ruta 22 (antes de la Liga)"] = GameState.has_flag("rival_ruta22_final_peleado")
	for e in ["liga_lorelei_lorelei", "liga_bruno_bruno", "liga_agatha_agatha", "liga_lance_lance"]:
		for inst in GameState.party:
			inst.hp = inst.max_hp()
		await _win(DB.npcs[e])
	r["El Alto Mando: Lorelei, Bruno, Agatha y Lance"] = ["lorelei", "bruno", "agatha", "lance"].all(
		func(n): return GameState.has_flag("alto_mando_" + n))
	await _rival_trigger("liga_campeon", Vector2i(6, 12), Vector2i(6, 10))
	r["Le ganás al Campeón"] = GameState.has_flag("campeon")
	r["La Guía: ¡Sos el Campeón de Kanto!"] = StoryGuide.current().get("title", "") == "¡Sos el Campeón de Kanto!"

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[historia-h4] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-story-h4] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _leader(zone: String) -> NpcData:
	for n: NpcData in DB.npcs.values():
		if n.zone_id == zone and n.trainer != null and n.trainer.leader:
			return n
	return null


## Le gana a todo el gimnasio (los entrenadores ya vencidos, si no te ven) y al líder.
func _beat_gym(zone: String) -> void:
	for n: NpcData in DB.npcs.values():
		if n.zone_id == zone and n.trainer != null and not n.trainer.leader:
			GameState.set_flag(n.defeated_flag())
	for inst in GameState.party:
		inst.hp = inst.max_hp()
	await _win(_leader(zone))


func _talk(id: String) -> void:
	var n: NpcData = DB.npcs[id]
	await _go(n.zone_id, n.cell + Vector2i(0, 1))
	_talk_to(id)
	await _idle()
	await get_tree().create_timer(0.2).timeout


## Pasa por un disparador de rival y le gana.
func _rival_trigger(zone: String, from: Vector2i, onto: Vector2i) -> void:
	for inst in GameState.party:
		inst.hp = inst.max_hp()
	await _go(zone, from)
	await _step_to(zone, onto)
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	await _ko_all()
