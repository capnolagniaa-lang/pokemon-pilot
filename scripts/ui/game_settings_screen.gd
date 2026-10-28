class_name GameSettingsScreen
extends Control
## Ajustes del juego de esta partida (Esc → Opciones → Ajustes del juego; pedido del usuario 2026-10-26): progresión,
## combate, mundo y dificultad de la IA (con modo personalizado). Se guardan con la partida (GameState.settings);
## cada cambio se aplica al instante. "Valores por defecto" vuelve a los de siempre.

signal closed

## [clave, texto, mínimo, máximo, paso, formato] (deslizadores) o [clave, texto] (casillas). Por sección.
const SECTIONS := [
	["Progresión", [
		["exp_mult", "Experiencia (×)", 0.1, 3.0, 0.05, "×%.2f"],
		["money_mult", "Dinero de los premios (×)", 0.0, 5.0, 0.1, "×%.1f"],
		["catch_mult", "Facilidad de captura (×)", 0.25, 4.0, 0.05, "×%.2f"],
	]],
	["Combate", [
		["dealt_mult", "Daño que hacés (×)", 0.25, 3.0, 0.05, "×%.2f"],
		["taken_mult", "Daño que recibís (×)", 0.25, 3.0, 0.05, "×%.2f"],
		["hp_scale", "Vida de los Pokémon (× la oficial)", 1.0, 6.0, 0.5, "×%.1f"],
		["combos", "Combos con nombre (arena)"],
		["arena_everywhere", "Reglas de arena en todo el mundo (cráteres, estilos)"],
	]],
	["Mundo", [
		["wild_mult", "Cantidad de salvajes (×)", 0.0, 3.0, 0.1, "×%.1f"],
		["regen", "Curación sola fuera de combate (1% por segundo)"],
		["field_items", "Objetos tirados en las rutas"],
		["time_lock", "Hora fija (todo a la izquierda: el tiempo corre)", -1.0, 23.5, 0.5, "%.1f h", "Corre"],
		["tile_pack", "Árboles y pasto alto nuevos (hechos con IA; apagado = los de FireRed)"],
	]],
	["IA personalizada (se usa con la dificultad «Personalizada»)", [
		["ai_attack_interval", "Tiempo entre ataques (×)", 0.5, 3.0, 0.05, "×%.2f"],
		["ai_aim_error", "Error de puntería (°)", 0.0, 40.0, 1.0, "%.0f°"],
		["ai_dodge", "Esquive", 0.0, 1.0, 0.05, "%.0f%%"],
		["ai_lead", "Anticipación de tus movimientos", 0.0, 1.0, 0.1, "%.0f%%"],
		["ai_damage", "Daño de los salvajes (×)", 0.25, 2.0, 0.05, "×%.2f"],
		["ai_think", "Tiempo para cambiar de táctica (×)", 0.5, 3.0, 0.1, "×%.1f"],
	]],
]

## clave -> control (HSlider o CheckBox), para refrescar.
var controls: Dictionary = {}
var _values: Dictionary = {}
var _diff_buttons: Dictionary = {}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.ACCENT.darkened(0.3), 2, 16))
	panel.position = Vector2(140, 24)
	panel.custom_minimum_size = Vector2(1000, 0)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	box.add_child(UiStyle.label("AJUSTES DEL JUEGO (de esta partida)", 22, UiStyle.ACCENT))
	# Dificultad de la IA.
	var diff_row := HBoxContainer.new()
	diff_row.add_theme_constant_override("separation", 8)
	diff_row.add_child(UiStyle.label("Dificultad de la IA:", 16))
	var group := ButtonGroup.new()
	for id in ["facil", "normal", "dificil", "personalizado"]:
		var name: String = "Personalizada" if id == "personalizado" else DB.difficulties[id].display_name
		var b := UiStyle.button(name, 150)
		b.toggle_mode = true
		b.button_group = group
		b.pressed.connect(func():
			GameState.set_difficulty(id)
			refresh())
		diff_row.add_child(b)
		_diff_buttons[id] = b
	box.add_child(diff_row)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(980, 470)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 6)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for section in SECTIONS:
		list.add_child(UiStyle.label(section[0], 18, UiStyle.ACCENT))
		for row in section[1]:
			list.add_child(_row(row))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	box.add_child(foot)
	var reset := UiStyle.button("Valores por defecto", 240)
	reset.pressed.connect(func():
		GameState.reset_settings()
		refresh())
	foot.add_child(reset)
	var back := UiStyle.button("Volver", 160)
	back.pressed.connect(func(): closed.emit())
	foot.add_child(back)
	refresh()
	UiStyle.focus_later(back)


func _row(row: Array) -> Control:
	var key: String = row[0]
	if row.size() == 2:
		var cb := CheckBox.new()
		cb.text = row[1]
		cb.toggled.connect(func(on: bool): GameState.set_setting(key, on))
		controls[key] = cb
		return cb
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	var name := UiStyle.label(row[1], 15)
	name.custom_minimum_size.x = 380
	h.add_child(name)
	var slider := HSlider.new()
	slider.min_value = row[2]
	slider.max_value = row[3]
	slider.step = row[4]
	slider.custom_minimum_size = Vector2(380, 24)
	h.add_child(slider)
	var value := UiStyle.label("", 15, UiStyle.TEXT_DIM)
	value.custom_minimum_size.x = 90
	h.add_child(value)
	slider.value_changed.connect(func(v: float):
		GameState.set_setting(key, v)
		value.text = _format(row, v))
	controls[key] = slider
	_values[key] = value
	return h


## Pone cada control con el valor actual de la partida (sin volver a escribirlo).
func refresh() -> void:
	for key in controls:
		var c: Control = controls[key]
		var v = GameState.setting(key)
		if c is CheckBox:
			c.set_pressed_no_signal(bool(v))
		else:
			c.set_value_no_signal(float(v))
			_values[key].text = _format(_find_row(key), float(v))
	var current := GameState.difficulty_id()
	for id in _diff_buttons:
		_diff_buttons[id].set_pressed_no_signal(id == current)


## Texto del valor de un deslizador. Un 7.º elemento en la fila = texto para los valores bajo cero (la hora fija:
## "Corre").
func _format(row: Array, v: float) -> String:
	if row.size() > 6 and v < 0.0:
		return row[6]
	var fmt: String = row[5]
	return fmt % (v * 100.0 if fmt.contains("%%") else v)


func _find_row(key: String) -> Array:
	for section in SECTIONS:
		for row in section[1]:
			if row[0] == key:
				return row
	return []
