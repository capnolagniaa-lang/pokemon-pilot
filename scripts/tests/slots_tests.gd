class_name SlotsTests
extends Node
## Autotest de varias partidas con nombre, de que los Pokémon no se curan solos (desmayo total) y del modo de prueba
## del torneo (no guarda):  godot --headless --path . --quit-after 60000 -- --autotest-slots

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	var before_path := SaveManager.slot_path
	var before_name := SaveManager.current_name
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await get_tree().physics_frame

	# --- Varias partidas con nombre ---
	SaveManager.use_name("Autotest Uno")
	r["El nombre arma el archivo de la partida"] = SaveManager.slot_path == "user://saves/autotest_uno.json"
	var ok1 := SaveManager.save_game()
	SaveManager.use_name("Autotest Dos")
	GameState.party[0].level = 33
	var ok2 := SaveManager.save_game()
	var names := SaveManager.list_saves().map(func(s): return s["name"])
	r["Se guardan dos partidas distintas"] = ok1 and ok2 and names.has("Autotest Uno") and names.has("Autotest Dos")
	var uno := SaveManager.list_saves().filter(func(s): return s["name"] == "Autotest Uno")
	r["Cargar una partida de la lista la deja como la actual"] = not uno.is_empty() and SaveManager.load_from(uno[0]["path"]) \
		and SaveManager.current_name == "Autotest Uno" and GameState.party[0].level != 33
	GameState.party.clear()
	GameState.set_flag("historia")
	r["En la historia se puede guardar antes de tener Pokémon"] = SaveManager.can_save()
	GameState.set_flag("historia", false)
	for f in ["user://saves/autotest_uno.json", "user://saves/autotest_dos.json"]:
		DirAccess.remove_absolute(f)
	SaveManager.slot_path = before_path
	SaveManager.current_name = before_name

	# --- Los Pokémon no se curan solos; si cae uno sale el siguiente; sin ninguno, desmayo total ---
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.practice_mode = false
	GameState.add_to_party(CreatureInstance.create(DB.species["pidgey"], 10))
	var lead: CreatureInstance = GameState.party[0]
	lead.hp = lead.max_hp() * 0.4
	await get_tree().create_timer(2.0).timeout
	r["Fuera de combate no se curan solos"] = absf(lead.hp - lead.max_hp() * 0.4) < 0.01
	world.companion.health.apply_damage(9999.0)
	await get_tree().create_timer(CombatDirector.NEXT_MON_DELAY + 0.5).timeout
	r["Si cae tu Pokémon sale el siguiente sano"] = GameState.active_index == 1 and is_instance_valid(world.companion) \
		and world.companion.instance.species.id == "pidgey"
	var heal_at: Vector2 = world.trainer.global_position + Vector2(48, 0)
	GameState.last_heal_position = heal_at
	world.companion.health.apply_damage(9999.0)
	await get_tree().create_timer(CombatDirector.NEXT_MON_DELAY + 0.3).timeout
	for i in 60:
		if world.story.dialog.active:
			world.story.dialog.advance()
		if not world.story.busy and world.trainer.global_position.distance_to(heal_at) < 2.0:
			break
		await get_tree().create_timer(0.1).timeout
	r["Sin ninguno en pie: desmayo total, al último lugar donde te curaron y curados"] = \
		world.trainer.global_position.distance_to(heal_at) < 2.0 and GameState.party.all(func(i): return i.hp == i.max_hp())

	# --- Modo de prueba del torneo: no se guarda ---
	GameState.test_tournament = {"cup": "nv15_3"}
	SaveManager.slot_path = "user://saves/autotest_prueba.json"
	r["En el modo de prueba del torneo no se guarda"] = not SaveManager.save_game() and not FileAccess.file_exists("user://saves/autotest_prueba.json")
	GameState.test_tournament = {}
	SaveManager.slot_path = before_path
	var setup: Control = load("res://scenes/ui/tournament_test.tscn").instantiate()
	add_child(setup)
	await get_tree().process_frame
	r["La pantalla de prueba del torneo ofrece los Pokémon con kit"] = setup._buttons.size() == DB.species.values().filter(func(s): return s.kit != null).size()
	setup.queue_free()

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[partidas] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-slots] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)
