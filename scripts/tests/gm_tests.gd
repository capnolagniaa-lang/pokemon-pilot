class_name GmTests
extends StoryH1Tests
## Consola de Game Master (GmConsole, GmCommands, GmFlight).
##   godot --headless --path . --quit-after 30000 -- --autotest-gm


func run() -> void:
	var r := {}
	GameState.new_game(DB.species["charmander"])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	_dialogs()
	await get_tree().create_timer(0.3).timeout
	var gm: GmConsole = world.gm_console
	r["La consola está (fuera de la versión portable)"] = gm != null and not gm.is_open()
	# Ctrl+Shift+G la abre (pausa) y la cierra.
	var key := InputEventKey.new()
	key.physical_keycode = KEY_G
	key.ctrl_pressed = true
	key.shift_pressed = true
	key.pressed = true
	Input.parse_input_event(key)
	await get_tree().process_frame
	await get_tree().process_frame
	r["Ctrl+Shift+G la abre y pausa el juego"] = gm.is_open() and get_tree().paused
	var inst := GameState.active()
	var lvl := inst.level
	gm.submit("exp 1000")
	r["exp suma experiencia y sube de nivel"] = inst.level > lvl
	gm.submit("nivel 30")
	r["nivel lo lleva a ese nivel"] = inst.level == 30
	r["nivel no baja"] = gm.submit("nivel 5").contains("no se puede") and inst.level == 30
	gm.submit("objeto caramelo raro 3")
	r["objeto (por nombre con espacios y cantidad)"] = GameState.item_count("caramelo_raro") == 3
	r["objeto con parte del nombre lista los posibles"] = gm.submit("objeto mt0").begins_with("¿Cuál?")
	var money := GameState.money
	gm.submit("dinero 5000")
	r["dinero suma"] = GameState.money == money + 5000
	gm.submit("pokemon pikachu 12")
	r["pokemon lo suma al equipo"] = GameState.party.size() == 2 and GameState.party[1].species.id == "pikachu" \
		and GameState.party[1].level == 12
	gm.submit("exp 500 2")
	r["exp al lugar 2"] = GameState.party[1].experience > CreatureInstance.exp_for_level(GameState.party[1].species.growth_rate, 12)
	inst.hp = 1.0
	gm.submit("curar")
	r["curar"] = inst.hp == inst.max_hp()
	gm.submit("hora 22")
	r["hora"] = int(GameState.time_of_day) == 22
	r["Un comando que no existe avisa"] = gm.submit("volarr").begins_with("No conozco")
	r["ayuda lista los comandos"] = gm.submit("ayuda").contains("volar")
	gm.close()
	r["Al cerrarla el juego sigue"] = not get_tree().paused

	# --- volar: la cámara se va lejos (otra ciudad) y al volver todo está como antes ---
	var t: Trainer = world.trainer
	var start := t.global_position
	var here := _zone_id()
	GameState.visited_zones = {here: true}
	gm.open()
	gm.submit("volar")
	await get_tree().process_frame
	await get_tree().process_frame
	var fl: GmFlight = world.gm_flight
	r["volar: cámara libre con el juego en pausa"] = fl.active and get_tree().paused and not gm.is_open() \
		and world.camera.target != t
	fl._eye.global_position = _pos("ciudad_plateada", Vector2i(20, 20))
	await _until(func(): return world.streamer.loaded.has("ciudad_plateada") \
		and world.streamer.current != null and world.streamer.current.id == "ciudad_plateada", 10.0)
	r["volando se carga el mapa que mirás"] = world.streamer.loaded.has("ciudad_plateada")
	var esc := InputEventKey.new()
	esc.physical_keycode = KEY_ESCAPE
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	Input.parse_input_event(esc)
	await get_tree().process_frame
	await get_tree().process_frame
	r["Esc vuelve (sin abrir el menú de pausa)"] = not fl.active and not get_tree().paused \
		and not world.pause_menu.is_open() and world.camera.target == t
	r["El entrenador no se movió"] = t.global_position == start
	r["Lo que cruzaste volando no queda visitado (Mapa, globos)"] = GameState.visited_zones.keys() == [here]
	await get_tree().create_timer(0.5).timeout
	r["Vuelve a estar en su zona (música, luz)"] = world.streamer.current != null and world.streamer.current.id == here

	# --- ir: a una zona o a una celda de cualquier zona ---
	gm.open()
	r["ir sin zona explica el uso"] = gm.submit("ir").begins_with("Uso:")
	r["ir a una celda fuera de la zona avisa"] = gm.submit("ir ciudad celeste 999,999").contains("afuera")
	gm.open()
	gm.submit("ir ciudad celeste 22,32")
	r["ir cierra la consola"] = not gm.is_open()
	await _until(func(): return world.streamer.current != null and world.streamer.current.id == "ciudad_celeste", 6.0)
	await get_tree().create_timer(0.8).timeout
	r["ir <zona> x,y: a esa celda"] = _zone_id() == "ciudad_celeste" 		and t.global_position.distance_to(_pos("ciudad_celeste", Vector2i(22, 32))) < 24.0
	var ok := r.values().all(func(v): return v)
	for k in r:
		print("[gm] %s %s" % ["OK   " if r[k] else "FALLO", k])
	print("[autotest-gm] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)
