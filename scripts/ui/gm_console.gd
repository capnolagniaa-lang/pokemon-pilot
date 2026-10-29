class_name GmConsole
extends CanvasLayer
## Consola de Game Master (pedido del usuario 2026-10-29): Ctrl + Shift + G la abre y la cierra (también Esc).
## Mientras está abierta el juego queda en pausa. Los comandos están en GmCommands (escribí "ayuda"); flechas
## arriba/abajo = comandos anteriores, Tab completa el comando. No está en la versión portable (la de los amigos):
## ahí también hay peleas online.

const TOGGLE_KEY := KEY_G

var world: Node
var commands: GmCommands
var history: PackedStringArray = []

var _root: Control
var _log: RichTextLabel
var _input_line: LineEdit
var _was_paused := false
var _hist_pos := 0


static func enabled() -> bool:
	return not OS.has_feature("portable")


func _ready() -> void:
	layer = 15
	process_mode = Node.PROCESS_MODE_ALWAYS
	world = get_parent()
	commands = GmCommands.new(world)
	_build()
	_root.visible = false


func is_open() -> bool:
	return _root.visible


func open() -> void:
	if is_open():
		return
	_was_paused = get_tree().paused
	get_tree().paused = true
	_root.visible = true
	_hist_pos = history.size()
	_input_line.clear()
	_input_line.grab_focus.call_deferred()


func close() -> void:
	if not is_open():
		return
	_root.visible = false
	_input_line.release_focus()
	# (si volar arrancó, la pausa la maneja GmFlight; si estaba el menú de pausa abierto, sigue en pausa)
	var flight: GmFlight = world.get("gm_flight")
	if not _was_paused and not (flight != null and flight.active):
		get_tree().paused = false


## Ejecuta una línea como si la hubieras escrito (también la usa el autotest).
func submit(line: String) -> String:
	line = line.strip_edges()
	if line == "":
		return ""
	if history.is_empty() or history[-1] != line:
		history.append(line)
	_hist_pos = history.size()
	print_line("> " + line, UiStyle.ACCENT)
	if GmCommands.norm(line) == "limpiar":
		_log.clear()
		return ""
	var out := commands.run(line)
	print_line(out)
	if GmCommands.norm(line.split(" ", false)[0]) in ["volar", "fly"] and world.gm_flight.why_not() == "":
		close()  # (vuela al cerrar: start va diferido)
	return out


func print_line(text: String, color: Color = UiStyle.TEXT) -> void:
	_log.push_color(color)
	_log.add_text(text + "\n")
	_log.pop()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: InputEventKey = event
	if key.physical_keycode == TOGGLE_KEY and key.ctrl_pressed and key.shift_pressed:
		get_viewport().set_input_as_handled()
		if is_open():
			close()
		elif not world.gm_flight.active:
			open()
		return
	if not is_open():
		return
	match key.physical_keycode:
		KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			close()
		KEY_UP, KEY_DOWN:
			get_viewport().set_input_as_handled()
			if history.is_empty():
				return
			_hist_pos = clampi(_hist_pos + (-1 if key.physical_keycode == KEY_UP else 1), 0, history.size())
			_input_line.text = history[_hist_pos] if _hist_pos < history.size() else ""
			_input_line.caret_column = _input_line.text.length()
		KEY_TAB:
			get_viewport().set_input_as_handled()
			_complete()


## Tab: completa el nombre del comando (si hay uno solo que empiece así) o muestra los posibles.
func _complete() -> void:
	var typed := GmCommands.norm(_input_line.text)
	if typed == "" or _input_line.text.contains(" "):
		return
	var hits := PackedStringArray()
	for h in GmCommands.HELP:
		var name: String = str(h[0]).split(" ")[0]
		if name.begins_with(typed):
			hits.append(name)
	if hits.size() == 1:
		_input_line.text = hits[0] + " "
		_input_line.caret_column = _input_line.text.length()
	elif hits.size() > 1:
		print_line("  ".join(hits), UiStyle.TEXT_DIM)


func _build() -> void:
	_root = Control.new()
	_root.theme = UiStyle.theme()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(Color(0.03, 0.05, 0.07, 0.94), UiStyle.ACCENT, 2, 10))
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.offset_bottom = 330
	_root.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	panel.add_child(col)
	col.add_child(UiStyle.label("Consola de Game Master   (Ctrl+Shift+G o Esc la cierra · ayuda = comandos)", 15, UiStyle.ACCENT))
	_log = RichTextLabel.new()
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log.scroll_following = true
	_log.selection_enabled = true
	_log.add_theme_font_size_override("normal_font_size", 15)
	col.add_child(_log)
	_input_line = LineEdit.new()
	_input_line.placeholder_text = "Escribí un comando (ej.: exp 5000, nivel 30 2, objeto caramelo raro 3, volar)"
	_input_line.keep_editing_on_text_submit = true
	_input_line.text_submitted.connect(func(t: String): _input_line.clear(); submit(t))
	col.add_child(_input_line)
	print_line("Ojo: lo que hagas acá se guarda con la partida (salvo volar, que no cambia nada).", UiStyle.TEXT_DIM)
