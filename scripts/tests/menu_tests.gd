class_name MenuTests
extends Node
## Menús con joystick, controles configurables y zonas que se apuntan manteniendo:
##   godot --headless --path . --quit-after 60000 -- --autotest-menus
##   godot --path . --quit-after 90 --write-movie out/f.png --fixed-fps 30 -- --showcase-controls  # la pantalla de controles

const CFG := "user://controles_test.cfg"

var autotest: Node
var world: Node
var r := {}


func run() -> void:
	world = await autotest._setup_kit_world("charmander")
	Controls.config_path = CFG
	if "--showcase-controls" in OS.get_cmdline_user_args():
		await _showcase()
		return
	await _aimed_zones()
	world.combat.end_battle()
	await _frames(3)
	await _menus()
	await _bindings()
	DirAccess.remove_absolute(CFG)
	Controls.reset("key")
	Controls.reset("pad")
	DirAccess.remove_absolute(CFG)
	var ok := true
	for k: String in r:
		print("[menus] %s %s" % ["OK   " if r[k] else "FALLO", k])
		ok = ok and r[k]
	print("[autotest-menus] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)


func _showcase() -> void:
	world.combat.end_battle()
	Controls.gamepad = true
	Controls.pad_name = "DualSense Wireless Controller"
	world.pause_menu.try_open()
	var screen := ControlsScreen.new()
	world.pause_menu.push(screen)
	await get_tree().create_timer(1.0, true, false, true).timeout
	screen.menu_tab(1)  # la pestaña de teclado y mouse


## Rayo con joystick: un toque cae encima, mantener lo aleja, sale al soltar.
func _aimed_zones() -> void:
	var me: Creature = world.companion
	var input := CombatInput.new()
	me.input_source = input
	me.machine.transition_to("controlled")
	var rayo: MoveData = DB.moves["rayo"]
	me.instance.level = 40  # (a Nv. 10 no le alcanzan los PP para Rayo)
	me.moves.set_pp(me.moves.max_pp())
	me.moves.slots[0] = rayo
	me.facing = Vector2.RIGHT
	Controls.gamepad = true
	await _frames(2)
	var strikes := func() -> Array: return world.entities.get_children().filter(func(c): return c is SkyStrike)

	# Toque: cae encima
	me.moves.reset_cooldown(0)
	await _press(JOY_BUTTON_X, true)
	await _frames(2)
	r["Al apretar se ve la marca y todavía no cae"] = input.is_aiming() and me.telegraph.shape == Telegraph.Shape.CIRCLE and strikes.call().is_empty()
	await _press(JOY_BUTTON_X, false)
	await _frames(3)
	var hit: Array = strikes.call()
	r["Un toque: cae encima tuyo"] = hit.size() >= 1 and hit[0].global_position.distance_to(me.global_position) < 20.0
	r["Al soltar se va la marca"] = me.telegraph.shape == Telegraph.Shape.NONE
	await get_tree().create_timer(1.2).timeout

	# Mantener poco: un tramo
	me.moves.reset_cooldown(0)
	me.moves.set_pp(me.moves.max_pp())
	await _press(JOY_BUTTON_X, true)
	await get_tree().create_timer(CombatInput.AIM_TIME * 0.5).timeout
	var mid: Vector2 = me.telegraph.global_position
	var mid_dist: float = mid.distance_to(me.global_position)
	r["Mantener un poco: la marca avanza un tramo"] = mid_dist > rayo.placement_range * 0.25 and mid_dist < rayo.placement_range * 0.8

	# Mantener mucho: alcance máximo, y no pasa
	await get_tree().create_timer(CombatInput.AIM_TIME).timeout
	r["Mantener: llega al alcance máximo y no sigue"] = absf(me.telegraph.global_position.distance_to(me.global_position) - rayo.placement_range) < 3.0
	await _press(JOY_BUTTON_X, false)
	await _frames(3)
	hit = strikes.call()
	r["Al soltar cae en la marca"] = not hit.is_empty() and absf(hit[-1].global_position.distance_to(me.global_position) - rayo.placement_range) < 6.0
	await get_tree().create_timer(1.2).timeout

	# Excavar no se apunta
	me.moves.slots[1] = DB.moves["excavar"]
	r["Excavar no se apunta: sale donde estés"] = not CombatInput.is_aimed(me, 1) and CombatInput.is_aimed(me, 0)
	# Con mouse, como siempre
	Controls.gamepad = false
	await _frames(2)
	r["Con teclado y mouse no cambia nada"] = not input.is_aiming() and input.wants_slot(0) == false
	me.input_source = null


func _menus() -> void:
	Controls.gamepad = true
	Controls.pad_name = "DualSense Wireless Controller"
	var menu = world.pause_menu
	# Options abre, con el foco en un botón
	await _tap(JOY_BUTTON_START)
	await _frames(3)
	r["Options abre el menú, con un botón elegido"] = menu.visible and get_viewport().gui_get_focus_owner() != null
	# Mochila: pestañas y volver
	menu._open_bag()
	await _frames(4)
	var bag: Node = menu._stack[-1]
	var pocket: int = bag._pocket
	await _tap(JOY_BUTTON_RIGHT_SHOULDER)
	await _frames(2)
	r["R1: la pestaña de la derecha"] = bag._pocket == pocket + 1
	await _tap(JOY_BUTTON_LEFT_SHOULDER)
	await _frames(2)
	r["L1: la de la izquierda"] = bag._pocket == pocket
	await _tap(JOY_BUTTON_LEFT_SHOULDER)
	await _frames(2)
	r["L1 en la primera: da la vuelta"] = bag._pocket == bag.POCKETS.size() - 1
	await _frames(3)
	r["Al cambiar de pestaña hay algo elegido"] = get_viewport().gui_get_focus_owner() != null
	await _tap(JOY_BUTTON_B)
	await _frames(3)
	r["Círculo vuelve al menú"] = menu._stack.is_empty() and menu.visible
	# Lista larga: la Pokédex baja siguiendo el foco
	var scroll := ScrollContainer.new()
	r["Las listas con barra siguen al foco"] = await _follow_focus(scroll)
	await _long_list(menu)
	# Círculo cierra
	await _tap(JOY_BUTTON_B)
	await _frames(3)
	r["Círculo cierra el menú"] = not menu.visible and not get_tree().paused


func _follow_focus(scroll: ScrollContainer) -> bool:
	add_child(scroll)
	await get_tree().process_frame
	var on := scroll.follow_focus
	scroll.queue_free()
	return on


## Una lista más larga que la pantalla: bajar con la cruceta, con el botón mantenido, y el stick derecho.
func _long_list(menu: Node) -> void:
	for i in 40:
		GameState.box.append(CreatureInstance.create(DB.species["pidgey"], 5))
	menu._open_box()
	await _frames(4)
	var owner := get_viewport().gui_get_focus_owner()
	r["La Caja tiene un botón elegido"] = owner != null
	var target: ScrollContainer = MenuNav.scroll_target()
	r["Encuentra la barra de la lista"] = target != null
	if target != null:
		var ev := InputEventJoypadButton.new()
		ev.button_index = JOY_BUTTON_DPAD_DOWN
		ev.pressed = true
		Input.parse_input_event(ev)
		Input.flush_buffered_events()
		await get_tree().create_timer(1.2).timeout
		var up := ev.duplicate()
		up.pressed = false
		Input.parse_input_event(up)
		Input.flush_buffered_events()
		await _frames(3)
		r["Mantener abajo sigue bajando y la lista acompaña"] = get_viewport().gui_get_focus_owner() != owner and target.scroll_vertical > 0
		var was := target.scroll_vertical
		var stick := InputEventJoypadMotion.new()
		stick.axis = JOY_AXIS_RIGHT_Y
		stick.axis_value = -1.0
		Input.parse_input_event(stick)
		Input.flush_buffered_events()
		await get_tree().create_timer(0.2).timeout
		stick = stick.duplicate()
		stick.axis_value = 0.0
		Input.parse_input_event(stick)
		Input.flush_buffered_events()
		await _frames(2)
		r["El stick derecho mueve la barra"] = target.scroll_vertical < was
	await _tap(JOY_BUTTON_B)
	await _frames(3)
	GameState.box.resize(GameState.box.size() - 40)


func _bindings() -> void:
	var menu = world.pause_menu
	menu.try_open()
	menu._open_controls()
	await _frames(4)
	var screen: ControlsScreen = menu._stack[-1]
	r["Con joystick abre en la pestaña Joystick"] = screen._tabs.current_tab == 1
	r["El dibujo dice qué hace cada botón"] = screen._diagram._what_does({"btn": JOY_BUTTON_LEFT_SHOULDER}) == "Esquivar"
	r["Con DualSense: nombres de PlayStation"] = screen._rows["pad"]["attack_1"].text == "Cuadrado"
	# Cambiar un botón: esquivar a R3
	var b: Button = screen._rows["pad"]["dodge"]
	b.pressed.emit()
	await _frames(1)
	r["Espera el botón nuevo y no navega"] = screen.capturing() and MenuNav.blocked and b.text == "Apretá…"
	await _tap(JOY_BUTTON_RIGHT_STICK)
	await _frames(2)
	r["Queda asignado"] = not screen.capturing() and b.text == "R3" and not MenuNav.blocked
	var ev := InputEventJoypadButton.new()
	ev.button_index = JOY_BUTTON_RIGHT_STICK
	r["El botón nuevo hace la acción"] = InputMap.event_is_action(ev, "dodge")
	ev.button_index = JOY_BUTTON_LEFT_SHOULDER
	r["El de antes ya no"] = not InputMap.event_is_action(ev, "dodge")
	# Si ya lo usaba otro, se intercambian
	screen._rows["pad"]["run"].pressed.emit()
	await _tap(JOY_BUTTON_RIGHT_STICK)
	await _frames(2)
	r["Si ya lo usaba otro, se intercambian"] = Controls.pad_label("run") == "R3" and Controls.pad_label("dodge") == "L3"
	# Cancelar
	screen._rows["pad"]["capture"].pressed.emit()
	await _tap(JOY_BUTTON_START)
	await _frames(2)
	r["Options cancela sin cambiar nada"] = not screen.capturing() and Controls.pad_label("capture") == "Triángulo"
	# Con un mando de Xbox, los nombres de Xbox en todos lados
	Controls.pad_name = "Xbox Series Controller"
	r["Xbox: botones de Xbox"] = Controls.slot_key(0) == "X" and Controls.slot_key(1) == "A" and Controls.slot_key(3) == "RB" \
		and Controls.pad_label("battle_toggle") == "RT" and Controls.pad_label("quick_item") == "LT" and Controls.button_name(JOY_BUTTON_B) == "B"
	Controls.pad_name = "XInput Gamepad"
	r["XInput también es de Xbox"] = Controls.slot_key(0) == "X"
	var xbox_text: String = "{attack_1} {aceptar} {volver} {menu}".format(Controls.pad_tokens())
	r["Los textos también: %s" % xbox_text] = xbox_text == "X A B Start"
	var fresh := ControlsScreen.new()
	add_child(fresh)
	await _frames(2)
	r["La pantalla de controles también"] = fresh._rows["pad"]["attack_1"].text == "X"
	fresh.queue_free()
	Controls.pad_name = "DualSense Wireless Controller"
	r["Con DualSense los textos son los suyos"] = "{volver}".format(Controls.pad_tokens()) == "Círculo"
	# Teclado
	Controls.set_binding("key", "dodge", {"key": KEY_G})
	r["Teclado: se cambia la tecla"] = Controls.key_label("dodge") == "G"
	Controls.gamepad = false
	r["Y en pantalla sale la nueva"] = Controls.label("dodge") == "G" and Controls.slot_key(0) == "Clic"
	Controls.gamepad = true
	Controls.set_binding("key", "dodge", {"mouse": MOUSE_BUTTON_LEFT})
	r["Teclado: también un clic, y se intercambia"] = Controls.key_label("dodge") == "Clic" and Controls.key_label("attack_1") == "G"
	# Se guarda
	var saved := {"key": Controls.bindings["key"].duplicate(), "pad": Controls.bindings["pad"].duplicate()}
	var cfg := ConfigFile.new()
	r["Se guarda en su archivo"] = cfg.load(CFG) == OK and cfg.get_value("controles", "pad", {}) == saved["pad"]
	Controls.reset("pad")
	r["Volver a los de fábrica"] = Controls.pad_label("dodge") == "L1"
	Controls.reset("key")
	r["De fábrica también en teclado"] = Controls.key_label("attack_1") == "Clic" and Controls.specs("key", "move_up").size() == 2
	await _tap(JOY_BUTTON_B)
	await _frames(3)
	menu.close()


func _press(button: JoyButton, down: bool) -> void:
	await get_tree().physics_frame
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	ev.pressed = down
	Input.parse_input_event(ev)
	Input.flush_buffered_events()


func _tap(button: JoyButton) -> void:
	await get_tree().process_frame
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	ev.pressed = true
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	await get_tree().process_frame
	await get_tree().process_frame
	var up := ev.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
	Input.flush_buffered_events()
	await get_tree().process_frame


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
