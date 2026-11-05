class_name ControlsScreen
extends Control
## Esc / Options → Controles (pedido del usuario 2026-11-05): dos pestañas, "Teclado y mouse" y "Joystick" (R1 / L1), con
## lo que hace cada tecla. Tocás una fila, apretás la tecla o el botón nuevo y queda guardado (Controls). Si ya lo usaba
## otra acción, se intercambian. El Joystick muestra un dibujo del mando con lo que hace cada botón. Lo que no se cambia: el
## menú (Esc, Options) y, en los menús, Cruz para aceptar y Círculo para volver.

signal closed

var _tabs: TabContainer
var _rows := {"key": {}, "pad": {}}  # acción -> botón
var _capture_kind := ""
var _capture_action := ""
var _status: Label
var _diagram: PadDiagram


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = UiStyle.BG
	bg.size = Vector2(1280, 720)
	add_child(bg)
	var root := VBoxContainer.new()
	root.position = Vector2(40, 12)
	root.size = Vector2(1200, 696)
	root.add_theme_constant_override("separation", 6)
	add_child(root)
	root.add_child(UiStyle.label("CONTROLES", 22, UiStyle.ACCENT))
	_tabs = TabContainer.new()
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tabs.tab_changed.connect(func(_i): _focus_first.call_deferred())
	root.add_child(_tabs)
	_tabs.add_child(_keyboard_tab())
	_tabs.add_child(_pad_tab())
	_tabs.set_tab_title(0, "Teclado y mouse")
	_tabs.set_tab_title(1, "Joystick")
	_status = UiStyle.label("", 15, UiStyle.ACCENT)
	root.add_child(_status)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	root.add_child(row)
	var reset := UiStyle.button("Volver a los de fábrica", 260)
	reset.pressed.connect(_reset)
	row.add_child(reset)
	var back := UiStyle.button("Volver", 160)
	back.pressed.connect(func(): closed.emit())
	row.add_child(back)
	row.add_child(UiStyle.label("Cambiar de pestaña: %s / %s o con el mouse" % [Controls.button_name(JOY_BUTTON_RIGHT_SHOULDER), Controls.button_name(JOY_BUTTON_LEFT_SHOULDER)], 13, UiStyle.TEXT_DIM))
	_tabs.current_tab = 1 if Controls.gamepad else 0
	_refresh()
	_focus_first.call_deferred()


func _exit_tree() -> void:
	MenuNav.blocked = false


func menu_tab(step: int) -> void:
	_tabs.current_tab = posmod(_tabs.current_tab + step, _tabs.get_tab_count())


func _keyboard_tab() -> Control:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 6)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	for row in Controls.KEYBOARD_ROWS:
		grid.add_child(_row("key", row[0], row[1]))
	return scroll


func _pad_tab() -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	_diagram = PadDiagram.new()
	_diagram.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_diagram.custom_minimum_size = Vector2(700, 460)
	box.add_child(_diagram)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 4)
	box.add_child(list)
	for row in Controls.PAD_ROWS:
		list.add_child(_row("pad", row[0], row[1]))
	list.add_child(UiStyle.label("Fijos: stick izquierdo mueve; %s abre el menú." % Controls.button_name(JOY_BUTTON_START), 13, UiStyle.TEXT_DIM))
	list.add_child(UiStyle.label("Ataques de zona: mantené el botón para alejar la marca.", 13, UiStyle.TEXT_DIM))
	return box


func _row(kind: String, action: String, text: String) -> Control:
	var h := HBoxContainer.new()
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_label := UiStyle.label(text, 15)
	name_label.custom_minimum_size.x = 250
	h.add_child(name_label)
	var b := UiStyle.button("", 170)
	b.custom_minimum_size.y = 32.0
	b.add_theme_font_size_override("font_size", 14)
	b.pressed.connect(_start_capture.bind(kind, action))
	b.focus_entered.connect(func(): if _diagram != null and kind == "pad": _diagram.highlight = action)
	h.add_child(b)
	_rows[kind][action] = b
	return h


func _focus_first() -> void:
	var kind := "key" if _tabs.current_tab == 0 else "pad"
	var first: Button = _rows[kind][Controls.rows(kind)[0][0]]
	if first.is_visible_in_tree():
		first.grab_focus()


func _refresh() -> void:
	for kind in _rows:
		for action in _rows[kind]:
			var b: Button = _rows[kind][action]
			var named := []
			for spec in Controls.specs(kind, action):
				named.append(Controls.spec_name(spec))
			b.text = " / ".join(named) if not named.is_empty() else "—"
	if _diagram != null:
		_diagram.queue_redraw()


func _start_capture(kind: String, action: String) -> void:
	_capture_kind = kind
	_capture_action = action
	MenuNav.blocked = true
	_rows[kind][action].text = "Apretá…"
	_status.text = "Apretá la tecla o el clic nuevo (Esc cancela)." if kind == "key" else "Apretá el botón nuevo (%s cancela)." % Controls.button_name(JOY_BUTTON_START)


func capturing() -> bool:
	return _capture_action != ""


func _input(event: InputEvent) -> void:
	if not capturing() or not is_visible_in_tree():
		return
	if event is InputEventMouseMotion:
		return
	get_viewport().set_input_as_handled()
	var cancel: bool = (event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE) \
		or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START)
	if cancel:
		_end_capture("")
		return
	var spec := Controls.spec_of_event(_capture_kind, event)
	if spec.is_empty():
		return
	var action := _capture_action
	var kind := _capture_kind
	Controls.set_binding(kind, action, spec)
	_end_capture("Listo: %s." % Controls.spec_name(spec))


func _end_capture(text: String) -> void:
	_capture_action = ""
	_capture_kind = ""
	MenuNav.blocked = false
	_status.text = text
	_refresh()


func _reset() -> void:
	Controls.reset("key" if _tabs.current_tab == 0 else "pad")
	_status.text = "Volvieron los de fábrica."
	_refresh()


## Dibujo sencillo del mando con lo que hace cada botón, a los costados (hecho por código: sirve para PlayStation y Xbox).
class PadDiagram extends Control:
	## La acción que se está por cambiar: se marca en el dibujo.
	var highlight := ""

	## Botón, dónde está en el dibujo y de qué lado va su cartel.
	## El dibujo (sprites/ui/joystick.png, tools/make_wheel_art.py): las celdas de los botones están medidas en la imagen de
	## Qwen de 1408 px (art_src/ui/joystick_qwen.png) y `ART_SCALE` / `ART_AT` las pasan a este cuadro.
	const ART := preload("res://sprites/ui/joystick.png")
	const ART_SCALE := 0.31
	const ART_AT := Vector2(131.5, 46)

	const SPOTS := [
		[{"axis": [JOY_AXIS_TRIGGER_LEFT, 1.0]}, ART_AT + ART_SCALE * Vector2(335, 165), "izq"],
		[{"btn": JOY_BUTTON_LEFT_SHOULDER}, ART_AT + ART_SCALE * Vector2(420, 165), "izq"],
		[{"btn": JOY_BUTTON_DPAD_UP}, ART_AT + ART_SCALE * Vector2(378, 300), "izq"],
		[{"btn": JOY_BUTTON_DPAD_LEFT}, ART_AT + ART_SCALE * Vector2(320, 355), "izq"],
		[{"btn": JOY_BUTTON_DPAD_RIGHT}, ART_AT + ART_SCALE * Vector2(430, 355), "izq"],
		[{"btn": JOY_BUTTON_BACK}, ART_AT + ART_SCALE * Vector2(600, 380), "izq"],
		[{"btn": JOY_BUTTON_DPAD_DOWN}, ART_AT + ART_SCALE * Vector2(378, 430), "izq"],
		[{"btn": JOY_BUTTON_LEFT_STICK}, ART_AT + ART_SCALE * Vector2(530, 510), "izq"],
		[{"axis": [JOY_AXIS_TRIGGER_RIGHT, 1.0]}, ART_AT + ART_SCALE * Vector2(1070, 165), "der"],
		[{"btn": JOY_BUTTON_RIGHT_SHOULDER}, ART_AT + ART_SCALE * Vector2(985, 165), "der"],
		[{"btn": JOY_BUTTON_Y}, ART_AT + ART_SCALE * Vector2(1035, 275), "der"],
		[{"btn": JOY_BUTTON_BACK}, ART_AT + ART_SCALE * Vector2(600, 380), "izq"],
		[{"btn": JOY_BUTTON_START}, ART_AT + ART_SCALE * Vector2(810, 380), "der"],
		[{"btn": JOY_BUTTON_X}, ART_AT + ART_SCALE * Vector2(950, 358), "der"],
		[{"btn": JOY_BUTTON_A}, ART_AT + ART_SCALE * Vector2(1035, 435), "der"],
		[{"btn": JOY_BUTTON_RIGHT_STICK}, ART_AT + ART_SCALE * Vector2(875, 510), "der"],
	]

	func _draw() -> void:
		_draw_body()
		var font := get_theme_default_font()
		var rows := {"izq": 0, "der": 0}
		for s in SPOTS:
			var spec: Dictionary = s[0]
			var at: Vector2 = s[1]
			var side: String = s[2]
			var what := _what_does(spec)
			var hot: bool = highlight != "" and Controls.specs("pad", highlight).has(spec)
			var col: Color = UiStyle.ACCENT if hot else UiStyle.TEXT
			draw_circle(at, 8.0 if hot else 4.0, UiStyle.ACCENT if hot else Color(0.85, 0.72, 0.4))
			var y: float = 40.0 + rows[side] * 52.0
			rows[side] += 1
			var x := 6.0 if side == "izq" else 512.0
			var line_end := Vector2(186.0 if side == "izq" else 506.0, y + 6.0)
			draw_line(at, line_end, Color(col, 0.45), 1.0)
			draw_string(font, Vector2(x, y), Controls.spec_name(spec), HORIZONTAL_ALIGNMENT_LEFT, 180, 15, col)
			draw_string(font, Vector2(x, y + 19.0), what, HORIZONTAL_ALIGNMENT_LEFT, 182, 13, col if what != "—" else UiStyle.TEXT_DIM)

	func _draw_body() -> void:
		draw_texture_rect(ART, Rect2(ART_AT, ART.get_size() * ART_SCALE * 2.0), false)

	## Qué hace ese botón, o "—".
	func _what_does(spec: Dictionary) -> String:
		for row in Controls.PAD_ROWS:
			if Controls.specs("pad", row[0]).has(spec):
				return row[1]
		if spec.get("btn", -1) == JOY_BUTTON_START:
			return "Menú"
		return "—"
