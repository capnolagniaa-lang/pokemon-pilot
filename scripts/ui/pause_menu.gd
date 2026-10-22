class_name PauseMenu
extends Control
## Menú de pausa (Esc en el mundo): Equipo, Pokédex, Guardar, Opciones, Volver al título y Cerrar. Pausa el mundo
## (get_tree().paused) y no se abre durante un combate. Las pantallas (Equipo, ficha, opciones) se apilan
## encima; Esc vuelve a la anterior.

const PARTY_SCENE := preload("res://scenes/ui/party_screen.tscn")
const OPTIONS_SCENE := preload("res://scenes/ui/options_panel.tscn")
const POKEDEX_SCENE := preload("res://scenes/ui/pokedex_screen.tscn")
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"

## Pantallas abiertas encima del menú (la última es la que recibe Esc).
var _stack: Array[Control] = []
var _main: Control
var _first: Button
var _status: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiStyle.theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build()


func is_open() -> bool:
	return visible


## Abre el menú si se puede (no en combate, con un Pokémon en el equipo). Devuelve si se abrió.
func try_open() -> bool:
	if visible:
		return true
	var world := get_tree().get_first_node_in_group("world")
	if world != null and world.combat.in_battle:
		Events.message_requested.emit("No podés abrir el menú durante un combate.")
		return false
	if GameState.party.is_empty():
		return false
	visible = true
	_status.text = ""
	get_tree().paused = true
	_first.grab_focus()
	return true


func close() -> void:
	for s in _stack:
		s.queue_free()
	_stack.clear()
	visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	get_viewport().set_input_as_handled()
	if not visible:
		try_open()
	elif _stack.is_empty():
		close()
	else:
		_pop()


func _build() -> void:
	add_child(UiStyle.dim())
	_main = PanelContainer.new()
	_main.position = Vector2(1280 - 300, 40)
	_main.custom_minimum_size = Vector2(260, 0)
	add_child(_main)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	_main.add_child(box)
	box.add_child(UiStyle.label("MENÚ", 20, UiStyle.ACCENT))
	var entries := [["Equipo", _open_party], ["Pokédex", _open_pokedex], ["Guardar", _save], ["Opciones", _open_options],
		["Volver al título", _to_title], ["Cerrar", close]]
	for e in entries:
		var b := UiStyle.button(e[0], 240)
		b.pressed.connect(e[1])
		box.add_child(b)
		if _first == null:
			_first = b
	_status = UiStyle.label("", 13, UiStyle.TEXT_DIM)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size.x = 240
	box.add_child(_status)
	box.add_child(UiStyle.label("Esc: volver", 12, UiStyle.TEXT_DIM))


## Abre una pantalla encima del menú.
func push(screen: Control) -> void:
	if not _stack.is_empty():
		_stack[-1].visible = false
	add_child(screen)
	_stack.append(screen)
	_main.visible = false
	if screen.has_signal("closed"):
		screen.closed.connect(_pop)


func _pop() -> void:
	if _stack.is_empty():
		return
	var top: Control = _stack.pop_back()
	if top.has_method("back") and not top.back():
		_stack.append(top)  # la pantalla manejó el Esc (ej. cancelar una elección)
		return
	top.queue_free()
	if _stack.is_empty():
		_main.visible = true
		_first.grab_focus()
	else:
		_stack[-1].visible = true
		if _stack[-1].has_method("refresh"):
			_stack[-1].refresh()


func _open_party() -> void:
	var p: Control = PARTY_SCENE.instantiate()
	p.menu = self
	push(p)


func _open_pokedex() -> void:
	push(POKEDEX_SCENE.instantiate())


func _open_options() -> void:
	push(OPTIONS_SCENE.instantiate())


func _save() -> void:
	# Se guarda con el mundo pausado; la posición del entrenador es la de ahora.
	if SaveManager.save_game():
		_status.text = "Partida guardada (%s)." % SaveManager.format_time(GameState.play_time)
	else:
		_status.text = "No se pudo guardar."


func _to_title() -> void:
	var d := ConfirmDialog.ask(self, "¿Guardar antes de volver al título?", ["Guardar y salir", "Salir sin guardar", "Cancelar"])
	d.chosen.connect(func(i: int):
		if i == 2:
			_first.grab_focus()
			return
		if i == 0 and not SaveManager.save_game():
			_status.text = "No se pudo guardar."
			_first.grab_focus()
			return
		get_tree().paused = false
		get_tree().change_scene_to_file(TITLE_SCENE))
