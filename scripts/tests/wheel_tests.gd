class_name WheelTests
extends Node
## Ruleta de Pokémon (R3) con el botón y el stick simulados, en el mundo de verdad.
##   godot --headless --path . --quit-after 30000 -- --autotest-wheel
## Vitrina: godot --path . --quit-after 60 --write-movie out/f.png --fixed-fps 30 -- --showcase-wheel
## Lo que no se prueba acá: la pelea online de verdad y cómo se siente con el mando en la mano.

var autotest: Node
var world: Node
var r := {}


func run() -> void:
	world = await autotest._setup_kit_world("charmander")
	var wheel: PokemonWheel = world.wheel
	var events := InputMap.action_get_events("pokemon_wheel")
	r["R3 abre la ruleta"] = events.any(func(e): return e is InputEventJoypadButton and e.button_index == JOY_BUTTON_RIGHT_STICK)
	await _press()
	r["Con un solo Pokémon no se abre"] = not wheel.is_open
	await _release()

	GameState.party.append(CreatureInstance.create(DB.species["pidgey"], 10))
	GameState.party.append(CreatureInstance.create(DB.species["rattata"], 10))
	var down := CreatureInstance.create(DB.species["geodude"], 10)
	down.hp = 0.0
	GameState.party.append(down)
	world.combat.end_battle()
	await _frames(2)
	var normal := Engine.time_scale

	# Fuera de combate: el primer gajo va arriba a la derecha y a la derecha está el segundo (Pidgey).
	await _press()
	r["Se abre con el equipo y frena el tiempo"] = wheel.is_open and wheel.slots == [0, 1, 2, 3, -1, -1] and is_equal_approx(Engine.time_scale, normal * PokemonWheel.SLOW)
	await _stick("move_right")
	r["El stick marca el gajo y no mueve al entrenador"] = wheel.marked == 1 and world.trainer.input_dir() == Vector2.ZERO
	Input.action_release("move_right")
	await _frames(2)
	r["Sigue marcado aunque sueltes el stick"] = wheel.marked == 1
	await _release()
	r["Al soltar R3 sale el marcado y vuelve el tiempo"] = not wheel.is_open and GameState.active().species.id == "pidgey" and is_equal_approx(Engine.time_scale, normal)
	await _stick("move_right")
	r["Cerrada, el stick vuelve a mover"] = world.trainer.input_dir() != Vector2.ZERO
	Input.action_release("move_right")

	# Sin marcar nada, o cancelando, no cambia.
	await _press()
	await _release()
	r["Sin mover el stick no cambia"] = GameState.active().species.id == "pidgey"
	await _press()
	await _stick("move_down")
	await _stick("move_right")
	r["Abajo a la derecha marca al tercero"] = wheel.marked == 2
	Input.action_release("move_down")
	Input.action_release("move_right")
	Input.action_press("ui_cancel")
	await _frames(2)
	Input.action_release("ui_cancel")
	await _release()
	r["Círculo cancela"] = not wheel.is_open and GameState.active().species.id == "pidgey"

	# El debilitado (abajo a la izquierda) y los gajos vacíos no se marcan.
	await _press()
	await _stick("move_left")
	r["Un gajo vacío no se marca"] = wheel.marked == -1
	await _stick("move_down")
	r["Un debilitado no se marca"] = wheel.marked == -1
	Input.action_release("move_down")
	Input.action_release("move_left")
	await _release()

	# Se cierra si se pausa.
	await _press()
	get_tree().paused = true
	await _frames(2)
	r["Si se pausa, se cierra y vuelve el tiempo"] = not wheel.is_open and is_equal_approx(Engine.time_scale, normal)
	get_tree().paused = false
	await _release()

	# En combate: el cambio de pelea, sin atacar mientras está abierta.
	world.combat.start_battle()
	await _frames(2)
	var input: CombatInput = CombatInput.new()
	await _press()
	Input.action_press("attack_1")
	r["Abierta no se ataca ni se esquiva"] = not input.wants_slot(0) and not input.wants_dodge() and input.move_dir(world.companion) == Vector2.ZERO
	Input.action_release("attack_1")
	await _stick("move_up")
	await _stick("move_right")
	Input.action_release("move_up")
	Input.action_release("move_right")
	await _release()
	r["En combate cambia, y el nuevo sigue peleando"] = GameState.active().species.id == "charmander" and world.combat.in_battle and is_instance_valid(world.companion) and world.companion.instance == GameState.active()
	await _press()
	await _stick("move_right")
	Input.action_release("move_right")
	await _release()
	r["Respeta la recarga de los cambios"] = GameState.active().species.id == "charmander"

	# El dibujo de Controles: un punto por botón, sin repetir, y los carteles parejos a cada lado.
	var spots: Array = ControlsScreen.PadDiagram.SPOTS
	var specs := spots.map(func(x): return x[0])
	r["El dibujo del joystick marca cada botón una vez"] = spots.size() == 16 and specs.all(func(x): return specs.count(x) == 1)
	r["...con R3 y Círculo"] = specs.has({"btn": JOY_BUTTON_RIGHT_STICK}) and specs.has({"btn": JOY_BUTTON_B})

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[ruleta] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-wheel] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	for sid in ["pidgey", "pikachu", "geodude", "onix", "squirtle"]:
		GameState.party.append(CreatureInstance.create(DB.species[sid], 22))
	GameState.party[3].hp = 0.0
	GameState.party[4].shiny = true
	GameState.party[2].hp = GameState.party[2].max_hp() * 0.25
	await get_tree().create_timer(0.3, true, false, true).timeout
	await _press()
	await get_tree().create_timer(0.5, true, false, true).timeout
	Input.action_press("move_right")
	await get_tree().create_timer(1.0, true, false, true).timeout
	get_tree().quit()


func _press() -> void:
	await get_tree().process_frame
	Input.action_press("pokemon_wheel")
	await _frames(2)


func _release() -> void:
	await get_tree().process_frame
	Input.action_release("pokemon_wheel")
	await _frames(2)


func _stick(action: String) -> void:
	await get_tree().process_frame
	Input.action_press(action, 1.0)
	await _frames(2)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
