class_name DialogBox
extends Control
## Caja de diálogo de la historia (docs/PLAN_HISTORIA.md, H-0): globo abajo con el nombre de quien habla y el
## texto que se va escribiendo. E, Espacio, Enter o clic: si el texto se está escribiendo lo completa; si no, pasa
## al siguiente globo. `await say(...)` vuelve cuando se cierra. Mientras está abierta el entrenador no se mueve
## (lo traba StoryDirector) y Events avisa dialog_started / dialog_finished.

signal _advance

const CHARS_PER_SECOND := 55.0

var active := false
var _text: Label
var _speaker: Label
var _arrow: Label
var _shown := 0.0
var _armed := false  # la tecla que abrió el diálogo no lo avanza
var _mouse_was := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.ACCENT.darkened(0.3), 2, 16))
	panel.position = Vector2(190, 548)
	panel.size = Vector2(900, 132)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	_speaker = UiStyle.label("", 17, UiStyle.ACCENT)
	box.add_child(_speaker)
	_text = UiStyle.label("", 19)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(860, 60)
	box.add_child(_text)
	_arrow = UiStyle.label("▼", 14, UiStyle.ACCENT)
	_arrow.position = Vector2(1062, 650)
	add_child(_arrow)


## Muestra los globos uno por uno y vuelve cuando el jugador cierra el último.
func say(speaker: String, lines: PackedStringArray) -> void:
	if lines.is_empty():
		return
	active = true
	visible = true
	Events.dialog_started.emit()
	for line in lines:
		_speaker.text = speaker
		_speaker.visible = speaker != ""
		_text.text = line
		_shown = 0.0
		_text.visible_characters = 0
		_armed = false
		await _advance
	visible = false
	active = false
	Events.dialog_finished.emit()


func is_typing() -> bool:
	return _text.visible_characters >= 0 and _text.visible_characters < _text.text.length()


func _process(delta: float) -> void:
	if not active:
		return
	if is_typing():
		_shown += CHARS_PER_SECOND * delta
		_text.visible_characters = mini(int(_shown), _text.text.length())
		if _text.visible_characters >= _text.text.length():
			_text.visible_characters = -1
	_arrow.visible = not is_typing() and fmod(Time.get_ticks_msec() / 400.0, 2.0) < 1.4
	var pressed := Input.is_action_just_pressed("capture") or Input.is_action_just_pressed("ui_accept") \
		or Input.is_action_just_pressed("dodge") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not _mouse_was
	_mouse_was = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if not _armed:
		_armed = not (Input.is_action_pressed("capture") or Input.is_action_pressed("ui_accept") \
			or Input.is_action_pressed("dodge") or _mouse_was)
		return
	if pressed:
		advance()



## Completa el texto que se está escribiendo o pasa al siguiente globo (también lo usa el autotest).
func advance() -> void:
	if is_typing():
		_text.visible_characters = -1
	else:
		_advance.emit()
