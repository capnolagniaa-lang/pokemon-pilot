class_name GamepadTests
extends Node
## Joystick con botones simulados (Input.parse_input_event, como si vinieran del mando), sobre el combate de verdad:
##   godot --headless --path . --quit-after 30000 -- --autotest-gamepad
## Lo que no se puede probar acá es cómo se siente: eso, jugando con uno en la mano.

var autotest: Node
var world: Node
var r := {}


func run() -> void:
	world = await autotest._setup_kit_world("charmander")
	GameState.party.append(CreatureInstance.create(DB.species["pidgey"], 10))
	GameState.party.append(CreatureInstance.create(DB.species["rattata"], 10))
	var me: Creature = world.companion
	me.input_source = CombatInput.new()
	me.machine.transition_to("controlled")
	await get_tree().physics_frame

	# Todas las acciones tienen su botón
	var missing := []
	for action: String in Controls.PAD_BUTTONS.keys() + Controls.PAD_AXES.keys():
		if not InputMap.action_get_events(action).any(func(e): return e is InputEventJoypadButton or e is InputEventJoypadMotion):
			missing.append(action)
	r["Cada acción tiene su botón %s" % str(missing)] = missing.is_empty()
	r["Arranca con teclado y mouse"] = not Controls.gamepad and Controls.slot_key(0) == "Clic"

	# Stick: mueve y gira
	await _stick(Vector2(-1, 0))
	var x0: float = me.global_position.x
	await get_tree().create_timer(0.3).timeout
	r["Tocar el joystick cambia de modo y el nombre de los botones"] = Controls.gamepad and Controls.slot_key(0) == "X" and Controls.slot_key(3) == "RB"
	r["El stick mueve al Pokémon"] = me.global_position.x < x0 - 5.0
	r["Y lo hace mirar para ese lado"] = me.facing.x < -0.9
	await _stick(Vector2.ZERO)
	await _frames(3)

	# Ataques hacia donde mira, sin tocar el stick
	var used := []
	Events.move_used.connect(func(_u, m): used.append(m.id))
	me.moves.slots[0] = DB.moves["ascuas"]
	me.moves.reset_cooldown(0)
	await _hold(JOY_BUTTON_X)
	r["Cuadrado (X) tira el ataque 1"] = used.has("ascuas")
	r["El ataque sale para donde mira"] = me.facing.x < -0.9
	var shots: Array = world.entities.get_children().filter(func(c): return c is Projectile)
	r["El disparo va hacia allá"] = not shots.is_empty() and shots.all(func(s): return s.velocity.x < 0.0)
	var input: CombatInput = me.input_source
	r["Apuntar = hacia donde mira, aunque esté quieto"] = input.aim(me).normalized().distance_to(me.facing.normalized()) < 0.01
	r["Las zonas caen adelante"] = input.aim_point(me).x < me.global_position.x - 50.0
	await get_tree().create_timer(0.6).timeout

	# Girar y tirar enseguida
	await _stick(Vector2(1, 0))
	await _frames(3)
	r["Al girar el stick cambia para dónde apunta"] = input.aim(me).x > 0.0
	await _stick(Vector2.ZERO)
	await _frames(3)

	# Botones
	await _hold(JOY_BUTTON_LEFT_SHOULDER)
	r["L1 (LB) esquiva"] = me.machine.current_name() == "dash" or me.health.invulnerable_time > 0.0
	await get_tree().create_timer(0.5).timeout
	me = await _switch_check(me)

	# Lanzar bola
	var wild: Creature = autotest._dummy(world, "rattata", world.trainer.global_position + Vector2(60, 0))
	await get_tree().physics_frame
	r["La bola va al salvaje más cercano"] = world.items._pad_throw_point().distance_to(wild.global_position) < 1.0
	wild.queue_free()
	await get_tree().physics_frame
	r["Sin salvajes, adelante"] = world.items._pad_throw_point().distance_to(world.trainer.global_position) > 20.0

	# F vuelve a sacarlo con B
	var was: bool = world.combat.in_battle
	await _axis(JOY_AXIS_TRIGGER_RIGHT, 1.0)
	await _frames(2)
	await _axis(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	await _frames(2)
	r["R2 (RT) saca o guarda al Pokémon"] = world.combat.in_battle != was

	# Correr con L3: una vez y sigue hasta que te parás
	if world.combat.in_battle:
		world.combat.end_battle()
	await _frames(3)
	var t: Trainer = world.trainer
	await _stick(Vector2(1, 0))
	await _frames(3)
	r["Caminando no corre solo"] = not t.wants_run()
	await _hold(JOY_BUTTON_LEFT_STICK)
	await _frames(3)
	r["L3 una vez: sigue corriendo con el botón suelto"] = t.wants_run()
	await _stick(Vector2.ZERO)
	await _frames(3)
	await _stick(Vector2(1, 0))
	await _frames(3)
	r["Al pararse deja de correr"] = not t.wants_run()
	await _stick(Vector2.ZERO)
	await _frames(2)

	# Nombres según el mando, y los botones de las charlas
	r["Reconoce los mandos de PlayStation"] = Controls.is_playstation("DualSense Wireless Controller") \
		and Controls.is_playstation("PS4 Controller") and not Controls.is_playstation("Xbox Series Controller")
	Controls.pad_name = "DualSense Wireless Controller"
	r["Con DualSense los nombres son los suyos"] = Controls.slot_key(0) == "Cuadrado" and Controls.slot_key(3) == "R1" and Controls.pad_label("dodge") == "L1"
	Controls.pad_name = ""
	var accept := InputEventJoypadButton.new()
	accept.button_index = JOY_BUTTON_A
	r["Cruz (A) acepta en las charlas y los menús"] = InputMap.event_is_action(accept, "ui_accept")

	# Volver al teclado o al mouse
	var key := InputEventKey.new()
	key.physical_keycode = KEY_W
	key.pressed = true
	Input.parse_input_event(key)
	await _frames(2)
	key = key.duplicate()
	key.pressed = false
	Input.parse_input_event(key)
	r["Tocar el teclado vuelve a la mira"] = not Controls.gamepad and Controls.slot_key(0) == "Clic"
	await _stick(Vector2(0.2, 0))
	await _frames(2)
	r["Un stick apenas corrido no cambia de modo"] = not Controls.gamepad

	var ok := true
	for k: String in r:
		print("[joystick] %s %s" % ["OK   " if r[k] else "FALLO", k])
		ok = ok and r[k]
	print("[autotest-gamepad] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)


## La cruceta: siguiente, anterior, y salta a los debilitados.
func _switch_check(me: Creature) -> Creature:
	var first: int = GameState.active_index
	await _button(JOY_BUTTON_DPAD_RIGHT)
	await _frames(4)
	r["Cruceta derecha: el siguiente"] = GameState.active_index == posmod(first + 1, GameState.party.size())
	world.combat._switch_cd = 0.0
	await _button(JOY_BUTTON_DPAD_LEFT)
	await _frames(4)
	r["Cruceta izquierda: el anterior"] = GameState.active_index == first
	world.combat._switch_cd = 0.0
	GameState.party[posmod(first + 1, GameState.party.size())].hp = 0.0
	await _button(JOY_BUTTON_DPAD_RIGHT)
	await _frames(4)
	r["Saltea a los debilitados"] = GameState.active_index == posmod(first + 2, GameState.party.size())
	await get_tree().create_timer(0.3).timeout
	var now: Creature = world.companion
	now.input_source = CombatInput.new()
	if now.machine.current_name() != "controlled":
		now.machine.transition_to("controlled")
	return now


func _stick(v: Vector2) -> void:
	await get_tree().physics_frame
	for pair in [[JOY_AXIS_LEFT_X, v.x], [JOY_AXIS_LEFT_Y, v.y]]:
		var ev := InputEventJoypadMotion.new()
		ev.axis = pair[0]
		ev.axis_value = pair[1]
		Input.parse_input_event(ev)
	Input.flush_buffered_events()


func _axis(axis: JoyAxis, value: float) -> void:
	await get_tree().physics_frame
	var ev := InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = value
	Input.parse_input_event(ev)
	Input.flush_buffered_events()


func _button(button: JoyButton) -> void:
	await get_tree().process_frame
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	ev.pressed = true
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	await get_tree().process_frame
	await get_tree().process_frame
	var up := InputEventJoypadButton.new()
	up.button_index = button
	up.pressed = false
	Input.parse_input_event(up)
	Input.flush_buffered_events()


## Apretado unos cuadros, como un toque de verdad (lo leen en _physics_process).
func _hold(button: JoyButton) -> void:
	await get_tree().physics_frame
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	ev.pressed = true
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	await _frames(3)
	var up := InputEventJoypadButton.new()
	up.button_index = button
	up.pressed = false
	Input.parse_input_event(up)
	Input.flush_buffered_events()
	await _frames(1)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame
