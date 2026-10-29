extends Control
## Opciones editables en partida: dificultad de la IA y modo práctica (las mismas que al iniciar).

signal closed

var _first: Control
var _diff_buttons: Dictionary = {}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(UiStyle.label("OPCIONES", 20, UiStyle.ACCENT))
	box.add_child(UiStyle.label("Dificultad de la IA", 16))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)
	var group := ButtonGroup.new()
	for id in ["facil", "normal", "dificil"]:
		var diff: AiDifficulty = DB.difficulties.get(id)
		if diff == null:
			continue
		var b := UiStyle.button(diff.display_name, 150)
		b.toggle_mode = true
		b.button_group = group
		b.button_pressed = GameState.difficulty == diff
		b.pressed.connect(GameState.set_difficulty.bind(id))
		row.add_child(b)
		_diff_buttons[id] = b
		if b.button_pressed or _first == null:
			_first = b
	var practice := CheckBox.new()
	practice.text = "Modo práctica (si tu Pokémon se debilita, vuelve al instante)"
	practice.button_pressed = GameState.practice_mode
	practice.toggled.connect(func(on: bool): GameState.practice_mode = on)
	box.add_child(practice)
	var test_pool := CheckBox.new()
	test_pool.text = "Salvajes de prueba (solo Pidgey, Bellsprout, Rattata y Vulpix)"
	test_pool.tooltip_text = "Apagado: en cada zona aparecen los Pokémon de su tabla (se arman en el editor de mapas)."
	test_pool.button_pressed = GameState.wild_test_pool
	test_pool.toggled.connect(func(on: bool): GameState.wild_test_pool = on)
	box.add_child(test_pool)
	# (Entrenadores vivos: sacado de las opciones por ahora, pedido del usuario 2026-10-29.)
	# Volumen (de esta PC, no de la partida): user://audio.cfg (Sound).
	box.add_child(UiStyle.label("Volumen", 16))
	for vol in [["Música", "music_volume"], ["Efectos", "sfx_volume"], ["Gritos", "cry_volume"]]:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 10)
		var name := UiStyle.label(vol[0], 14)
		name.custom_minimum_size.x = 90
		h.add_child(name)
		var slider := HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.custom_minimum_size = Vector2(300, 22)
		slider.value = Sound.get(vol[1])
		var prop: String = vol[1]
		slider.value_changed.connect(func(v: float):
			var vols := {"music_volume": Sound.music_volume, "sfx_volume": Sound.sfx_volume, "cry_volume": Sound.cry_volume}
			vols[prop] = v
			Sound.set_volumes(vols["music_volume"], vols["sfx_volume"], vols["cry_volume"])
			if prop != "music_volume":
				Sound.sfx("menu_mover"))
		h.add_child(slider)
		box.add_child(h)
	# Online (de esta PC, no de la partida): user://online.cfg (Net). Se usa en el Centro de Combate Online.
	box.add_child(UiStyle.label("Online", 16))
	var online := HBoxContainer.new()
	online.add_theme_constant_override("separation", 10)
	var name_edit := LineEdit.new()
	name_edit.placeholder_text = "Tu nombre (%s)" % SaveManager.current_name
	name_edit.text = Net.player_name
	name_edit.max_length = NetPeer.NAME_MAX
	name_edit.custom_minimum_size.x = 200
	name_edit.text_changed.connect(func(t: String): Net.player_name = t; Net.save_config())
	online.add_child(name_edit)
	var addr_edit := LineEdit.new()
	addr_edit.placeholder_text = "Servidor: el del juego"
	addr_edit.tooltip_text = "Avanzado: vacío = el servidor del juego. Otro (ej. 192.168.0.10:%d) solo para probar." % NetPeer.DEFAULT_PORT
	addr_edit.text = Net.server_override
	addr_edit.custom_minimum_size.x = 260
	addr_edit.text_changed.connect(func(t: String): Net.set_server(t); Net.save_config())
	online.add_child(addr_edit)
	box.add_child(online)
	var settings := UiStyle.button("Ajustes del juego…", 260)
	settings.tooltip_text = "Experiencia, dinero, captura, daño, vida, salvajes, curación y la IA personalizada (por partida)."
	settings.pressed.connect(func():
		var menu := get_parent()
		if menu != null and menu.has_method("push"):
			menu.push(GameSettingsScreen.new()))
	box.add_child(settings)
	var back := UiStyle.button("Volver", 160)
	back.pressed.connect(func(): closed.emit())
	box.add_child(back)
	UiStyle.focus_later(_first)


## Al volver de Ajustes del juego (puede haber elegido la dificultad Personalizada, que no tiene botón acá).
func refresh() -> void:
	for id in _diff_buttons:
		_diff_buttons[id].set_pressed_no_signal(GameState.difficulty_id() == id)
