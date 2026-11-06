class_name FullscreenTests
extends Node
## Pantalla completa: F11, el botón de Opciones, que se guarde sin pisar el minimapa. Con ventana de verdad (sin --headless)
## también mira el modo de la ventana.
##   godot --path . --screen 1 --quit-after 3000 -- --autotest-fullscreen

const CFG := "user://test_interfaz.cfg"

var r := {}


func run() -> void:
	DirAccess.remove_absolute(CFG)
	Controls.display_path = CFG
	var minimap := ConfigFile.new()
	minimap.set_value("minimapa", "visible", false)
	minimap.save(CFG)
	var real_window := DisplayServer.get_name() != "headless"
	r["Arranca en ventana (los tests no miran lo guardado)"] = not Controls.fullscreen

	var panel: Control = load("res://scripts/ui/options_panel.gd").new()
	add_child(panel)
	await _frames(3)
	var height: float = panel.get_child(0).get_child(0).size.y
	r["Opciones entra en la pantalla (%d px de alto)" % height] = height <= 720.0
	await _f11()
	r["F11 la prende y Opciones se entera"] = Controls.fullscreen and panel.fullscreen_button.button_pressed
	if real_window:
		await _frames(10)
		var mode := DisplayServer.window_get_mode()
		r["La ventana pasa a pantalla completa"] = mode == DisplayServer.WINDOW_MODE_FULLSCREEN
		r["El juego se adapta a la pantalla (%s)" % get_viewport().get_visible_rect().size] = get_viewport().get_visible_rect().size == Vector2(1280, 720)
	var saved := ConfigFile.new()
	saved.load(CFG)
	r["Se guarda y no pisa el minimapa"] = saved.get_value("ventana", "pantalla_completa", false) == true and saved.get_value("minimapa", "visible", true) == false

	panel.fullscreen_button.button_pressed = false
	await _frames(10)
	r["El botón de Opciones la apaga"] = not Controls.fullscreen
	if real_window:
		r["La ventana vuelve a ser ventana"] = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED
	saved.load(CFG)
	r["Queda guardado apagado"] = saved.get_value("ventana", "pantalla_completa", true) == false
	panel.free()
	await _f11()
	r["F11 sigue andando con el panel cerrado"] = Controls.fullscreen
	await _f11()
	get_tree().paused = true
	await _f11()
	r["F11 anda también en pausa (en los menús)"] = Controls.fullscreen
	get_tree().paused = false
	await _f11()
	DirAccess.remove_absolute(CFG)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[pantalla-completa] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-fullscreen] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _f11() -> void:
	var key := InputEventKey.new()
	key.physical_keycode = KEY_F11
	key.pressed = true
	Input.parse_input_event(key)
	await _frames(2)
	var up := InputEventKey.new()
	up.physical_keycode = KEY_F11
	Input.parse_input_event(up)
	await _frames(2)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
