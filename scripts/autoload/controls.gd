extends Node
## Registra las acciones de input (teclas físicas, así funciona con cualquier distribución) y los controles que eligió el
## jugador (Esc → Controles, `ControlsScreen`; de esta PC, no de la partida: `config_path`).
## Por defecto: Clic izq. = ataque 1 · Clic der. = ataque 2 · Q = ataque 3 · R = ataque 4 · Espacio = esquive. Los números 1-6
## cambian al Pokémon de ese lugar del equipo (también en combate).
## Joystick (2026-11-05, botones elegidos por el usuario; los nombres de JOY_BUTTON son de Xbox): Cuadrado, Cruz, Círculo y
## R1 = los 4 ataques, que salen hacia donde mira el Pokémon (CombatInput); L1 = esquive; L3 = correr (Trainer).
## `gamepad` dice qué se usó último: tocar el teclado o el mouse vuelve a la mira. En los menús (MenuNav) los botones son
## fijos: Cruz acepta, Círculo vuelve, R1/L1 cambian de pestaña.

const KEYS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"run": [KEY_SHIFT],
	"attack_1": [],
	"attack_2": [],
	"attack_3": [KEY_Q],
	"attack_4": [KEY_R],
	## Cambiar al Pokémon del lugar 1-6 del equipo (pedido del usuario, 2026-10-23).
	"switch_1": [KEY_1],
	"switch_2": [KEY_2],
	"switch_3": [KEY_3],
	"switch_4": [KEY_4],
	"switch_5": [KEY_5],
	"switch_6": [KEY_6],
	"dodge": [KEY_SPACE],
	"capture": [KEY_E],  # lanzar la Pokébola elegida (docs/PLAN_CAPTURA_MOCHILA.md)
	"quick_item": [KEY_C],  # usar el objeto de la ranura rápida
	"minimap": [KEY_TAB],  # mostrar u ocultar el minimapa (Minimap)
	"battle_toggle": [KEY_F],
	"pause": [KEY_ESCAPE],
	## Solo con `-- --debug` (o desde el editor): suma un Pokémon al azar al equipo.
	"debug_add_pokemon": [KEY_F9],
	## Cruceta: el Pokémon anterior o el siguiente (el cambio directo 1-6 es del teclado).
	"switch_prev": [],
	"switch_next": [],
	## Ruleta de Pokémon (solo joystick, PokemonWheel).
	"pokemon_wheel": [],
	## Menús (MenuNav): siempre los mismos botones, no se configuran.
	"menu_tab_next": [],
	"menu_tab_prev": [],
	"menu_scroll_up": [],
	"menu_scroll_down": [],
	## Mover la mira de la Pokébola (stick derecho, PlayerItems): tampoco se configura.
	"aim_left": [],
	"aim_right": [],
	"aim_up": [],
	"aim_down": [],
}

const PAD_BUTTONS := {
	"attack_1": JOY_BUTTON_X,
	"attack_2": JOY_BUTTON_A,
	"attack_3": JOY_BUTTON_B,
	"attack_4": JOY_BUTTON_RIGHT_SHOULDER,
	"dodge": JOY_BUTTON_LEFT_SHOULDER,
	"capture": JOY_BUTTON_Y,
	"run": JOY_BUTTON_LEFT_STICK,
	"pause": JOY_BUTTON_START,
	"minimap": JOY_BUTTON_BACK,
	"switch_prev": JOY_BUTTON_DPAD_LEFT,
	"switch_next": JOY_BUTTON_DPAD_RIGHT,
	"pokemon_wheel": JOY_BUTTON_RIGHT_STICK,
	"menu_tab_next": JOY_BUTTON_RIGHT_SHOULDER,
	"menu_tab_prev": JOY_BUTTON_LEFT_SHOULDER,
}
## [eje, sentido]. Con la zona muerta de `PAD_DEADZONE`.
const PAD_AXES := {
	"move_left": [JOY_AXIS_LEFT_X, -1.0],
	"move_right": [JOY_AXIS_LEFT_X, 1.0],
	"move_up": [JOY_AXIS_LEFT_Y, -1.0],
	"move_down": [JOY_AXIS_LEFT_Y, 1.0],
	"battle_toggle": [JOY_AXIS_TRIGGER_RIGHT, 1.0],
	"quick_item": [JOY_AXIS_TRIGGER_LEFT, 1.0],
	"menu_scroll_up": [JOY_AXIS_RIGHT_Y, -1.0],
	"menu_scroll_down": [JOY_AXIS_RIGHT_Y, 1.0],
	"aim_left": [JOY_AXIS_RIGHT_X, -1.0],
	"aim_right": [JOY_AXIS_RIGHT_X, 1.0],
	"aim_up": [JOY_AXIS_RIGHT_Y, -1.0],
	"aim_down": [JOY_AXIS_RIGHT_Y, 1.0],
}
## Los menús y las charlas (si Godot no los trae ya).
const UI_PAD := {"ui_accept": JOY_BUTTON_A, "ui_cancel": JOY_BUTTON_B, "ui_up": JOY_BUTTON_DPAD_UP, "ui_down": JOY_BUTTON_DPAD_DOWN,
	"ui_left": JOY_BUTTON_DPAD_LEFT, "ui_right": JOY_BUTTON_DPAD_RIGHT}
const UI_AXES := {"ui_up": [JOY_AXIS_LEFT_Y, -1.0], "ui_down": [JOY_AXIS_LEFT_Y, 1.0],
	"ui_left": [JOY_AXIS_LEFT_X, -1.0], "ui_right": [JOY_AXIS_LEFT_X, 1.0]}
const PAD_DEADZONE := 0.3
## Cuánto hay que mover un stick o gatillo para que cuente como "ahora uso el joystick" (un stick gastado queda algo corrido).
const PAD_WAKE := 0.5
## Cuánto hay que mover el mouse para volver a la mira (que un roce sin querer no la cambie).
const MOUSE_WAKE := 6.0

## Los menús también se manejan con WASD (además de las flechas que ya trae Godot).
const UI_EXTRA := {"ui_up": KEY_W, "ui_down": KEY_S, "ui_left": KEY_A, "ui_right": KEY_D}

const MOUSE := {
	"attack_1": MOUSE_BUTTON_LEFT,
	"attack_2": MOUSE_BUTTON_RIGHT,
}

## Acción de cada uno de los 4 ataques (en el orden del kit).
const SLOT_ACTIONS := ["attack_1", "attack_2", "attack_3", "attack_4"]

## Lo que se puede cambiar: [acción, nombre]. El menú (Esc, Options) queda fijo para no quedarte sin poder entrar.
const KEYBOARD_ROWS := [["move_up", "Caminar arriba"], ["move_down", "Caminar abajo"], ["move_left", "Caminar a la izquierda"],
	["move_right", "Caminar a la derecha"], ["run", "Correr"], ["attack_1", "Ataque 1"], ["attack_2", "Ataque 2"], ["attack_3", "Ataque 3"],
	["attack_4", "Ataque 4"], ["dodge", "Esquivar"], ["capture", "Hablar / lanzar bola"], ["quick_item", "Objeto rápido"],
	["battle_toggle", "Sacar o guardar al Pokémon"], ["minimap", "Minimapa"], ["switch_1", "Pokémon 1"], ["switch_2", "Pokémon 2"],
	["switch_3", "Pokémon 3"], ["switch_4", "Pokémon 4"], ["switch_5", "Pokémon 5"], ["switch_6", "Pokémon 6"]]
const PAD_ROWS := [["attack_1", "Ataque 1"], ["attack_2", "Ataque 2"], ["attack_3", "Ataque 3"], ["attack_4", "Ataque 4"],
	["dodge", "Esquivar"], ["run", "Correr"], ["capture", "Hablar / lanzar bola"], ["quick_item", "Objeto rápido"],
	["battle_toggle", "Sacar o guardar al Pokémon"], ["switch_prev", "Pokémon anterior"], ["switch_next", "Pokémon siguiente"], ["pokemon_wheel", "Ruleta de Pokémon"], ["minimap", "Minimapa"]]

## Nombres de los botones (índice JOY_BUTTON_*) en cada mando, en palabras: la letra del juego no trae los símbolos de PlayStation.
const NAMES_XBOX := {JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y", JOY_BUTTON_LEFT_SHOULDER: "LB",
	JOY_BUTTON_RIGHT_SHOULDER: "RB", JOY_BUTTON_LEFT_STICK: "L3", JOY_BUTTON_RIGHT_STICK: "R3", JOY_BUTTON_START: "Start",
	JOY_BUTTON_BACK: "Select", JOY_BUTTON_DPAD_UP: "Arriba", JOY_BUTTON_DPAD_DOWN: "Abajo", JOY_BUTTON_DPAD_LEFT: "Izquierda", JOY_BUTTON_DPAD_RIGHT: "Derecha"}
const NAMES_PS := {JOY_BUTTON_A: "Cruz", JOY_BUTTON_B: "Círculo", JOY_BUTTON_X: "Cuadrado", JOY_BUTTON_Y: "Triángulo", JOY_BUTTON_LEFT_SHOULDER: "L1",
	JOY_BUTTON_RIGHT_SHOULDER: "R1", JOY_BUTTON_LEFT_STICK: "L3", JOY_BUTTON_RIGHT_STICK: "R3", JOY_BUTTON_START: "Options",
	JOY_BUTTON_BACK: "Create", JOY_BUTTON_DPAD_UP: "Arriba", JOY_BUTTON_DPAD_DOWN: "Abajo", JOY_BUTTON_DPAD_LEFT: "Izquierda", JOY_BUTTON_DPAD_RIGHT: "Derecha"}

## Ruleta de Pokémon abierta: el stick elige ahí y no mueve, no se ataca (PokemonWheel).
var wheel_open := false
## ¿Lo último que se tocó fue el joystick?
var gamepad := false
## Nombre del último mando que se tocó (de ahí salen los nombres de los botones).
var pad_name := ""
## Lo que cambió el jugador: {"key": {acción: spec}, "pad": {acción: spec}}. Spec: {"key": físico}, {"mouse": botón},
## {"btn": botón} o {"axis": [eje, sentido]}.
var bindings := {"key": {}, "pad": {}}
var config_path := "user://controles.cfg"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for action in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	for action in UI_EXTRA:
		var ui := InputEventKey.new()
		ui.physical_keycode = UI_EXTRA[action]
		InputMap.action_add_event(action, ui)
	for action in UI_PAD:
		_add_if_missing(action, _event_of({"btn": UI_PAD[action]}))
	for action in UI_AXES:
		_add_if_missing(action, _event_of({"axis": UI_AXES[action]}))
	load_config()
	if not Input.get_connected_joypads().is_empty():
		pad_name = Input.get_joy_name(Input.get_connected_joypads()[0])


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var woke: bool = event.pressed if event is InputEventJoypadButton else absf(event.axis_value) >= PAD_WAKE
		if woke:
			gamepad = true
			var joy := Input.get_joy_name(event.device)
			pad_name = joy if joy != "" else pad_name
	elif event is InputEventKey or event is InputEventMouseButton:
		gamepad = gamepad and not event.pressed
	elif event is InputEventMouseMotion:
		gamepad = gamepad and event.relative.length() < MOUSE_WAKE


func _add_if_missing(action: String, ev: InputEvent) -> void:
	if not InputMap.action_has_event(action, ev):
		InputMap.action_add_event(action, ev)


# --- Controles elegidos -------------------------------------------------------------------------------------------------

## Lee lo guardado y arma todo. (Los autotests y vitrinas usan siempre los de fábrica.)
func load_config() -> void:
	bindings = {"key": {}, "pad": {}}
	var cfg := ConfigFile.new()
	if not _automated() and cfg.load(config_path) == OK:
		for kind in bindings:
			var saved: Variant = cfg.get_value("controles", kind, {})
			if saved is Dictionary:
				bindings[kind] = saved
	for action in KEYS:
		_apply(action)


func save_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("controles", "key", bindings["key"])
	cfg.set_value("controles", "pad", bindings["pad"])
	cfg.save(config_path)


static func _automated() -> bool:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--autotest") or a.begins_with("--showcase") or a == "--overview" or a == "--server":
			return true
	return false


func _apply(action: String) -> void:
	InputMap.action_erase_events(action)
	for spec in specs("key", action) + specs("pad", action):
		InputMap.action_add_event(action, _event_of(spec))
	if PAD_AXES.has(action) or action in SLOT_ACTIONS or bindings["pad"].has(action):
		InputMap.action_set_deadzone(action, PAD_DEADZONE)


## Lo que tiene asignado una acción ("key" = teclado y mouse, "pad" = joystick).
func specs(kind: String, action: String) -> Array:
	if bindings[kind].has(action):
		return [bindings[kind][action]]
	var out := []
	if kind == "key":
		for k in KEYS.get(action, []):
			out.append({"key": k})
		if MOUSE.has(action):
			out.append({"mouse": MOUSE[action]})
	else:
		if PAD_BUTTONS.has(action):
			out.append({"btn": PAD_BUTTONS[action]})
		if PAD_AXES.has(action):
			out.append({"axis": PAD_AXES[action]})
	return out


## Asigna. Si eso ya lo usaba otra acción, se intercambian (así nunca quedan dos en lo mismo ni una sin nada).
func set_binding(kind: String, action: String, spec: Dictionary) -> void:
	var mine: Array = specs(kind, action)
	if mine.has(spec):
		return
	for row in rows(kind):
		var other: String = row[0]
		if other != action and specs(kind, other).has(spec):
			if mine.is_empty():
				bindings[kind].erase(other)
			else:
				bindings[kind][other] = mine[0]
			_apply(other)
	bindings[kind][action] = spec
	_apply(action)
	save_config()


func reset(kind: String) -> void:
	bindings[kind] = {}
	for action in KEYS:
		_apply(action)
	save_config()


func rows(kind: String) -> Array:
	return KEYBOARD_ROWS if kind == "key" else PAD_ROWS


## Lo que un evento le asignaría a una acción, o {} si no sirve para eso.
static func spec_of_event(kind: String, event: InputEvent) -> Dictionary:
	if not event.is_pressed() or event.is_echo():
		return {}
	if kind == "key":
		if event is InputEventKey:
			return {"key": event.physical_keycode}
		if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_XBUTTON1, MOUSE_BUTTON_XBUTTON2]:
			return {"mouse": event.button_index}
		return {}
	if event is InputEventJoypadButton:
		return {"btn": event.button_index}
	if event is InputEventJoypadMotion and event.axis in [JOY_AXIS_TRIGGER_LEFT, JOY_AXIS_TRIGGER_RIGHT] and event.axis_value > 0.6:
		return {"axis": [event.axis, 1.0]}
	return {}


static func _event_of(spec: Dictionary) -> InputEvent:
	if spec.has("key"):
		var k := InputEventKey.new()
		k.physical_keycode = spec["key"]
		return k
	if spec.has("mouse"):
		var m := InputEventMouseButton.new()
		m.button_index = spec["mouse"]
		return m
	if spec.has("btn"):
		var b := InputEventJoypadButton.new()
		b.button_index = spec["btn"]
		b.device = -1
		return b
	var a := InputEventJoypadMotion.new()
	a.axis = spec["axis"][0]
	a.axis_value = spec["axis"][1]
	a.device = -1
	return a


# --- Nombres en pantalla ------------------------------------------------------------------------------------------------

## Cómo se llama ahora la tecla de un ataque.
func slot_key(i: int) -> String:
	return label(SLOT_ACTIONS[i]) if i < SLOT_ACTIONS.size() else str(i + 1)


## Cómo se llama lo que hace una acción, con lo que estás usando ahora.
func label(action: String) -> String:
	return pad_label(action) if gamepad else key_label(action)


func key_label(action: String) -> String:
	var all := specs("key", action)
	return spec_name(all[0]) if not all.is_empty() else "—"


func pad_label(action: String) -> String:
	var all := specs("pad", action)
	return spec_name(all[0]) if not all.is_empty() else "—"


func spec_name(spec: Dictionary) -> String:
	if spec.has("key"):
		var code: int = spec["key"]
		if DisplayServer.get_name() == "headless":  # (sin pantalla no hay teclado: daría un error por cuadro)
			return OS.get_keycode_string(code)
		var named := OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(code))
		return named if named != "" else OS.get_keycode_string(code)
	if spec.has("mouse"):
		return {MOUSE_BUTTON_LEFT: "Clic", MOUSE_BUTTON_RIGHT: "Clic der.", MOUSE_BUTTON_MIDDLE: "Clic medio"}.get(spec["mouse"], "Botón %d" % spec["mouse"])
	var ps := is_playstation(pad_name)
	if spec.has("btn"):
		return (NAMES_PS if ps else NAMES_XBOX).get(spec["btn"], "Botón %d" % spec["btn"])
	var left: bool = spec["axis"][0] == JOY_AXIS_TRIGGER_LEFT
	return ("L2" if left else "R2") if ps else ("LT" if left else "RT")


## Nombre de un botón fijo en el mando que se está usando ("Círculo" o "B"...).
func button_name(button: JoyButton) -> String:
	return (NAMES_PS if is_playstation(pad_name) else NAMES_XBOX)[button]


## Para los textos: {attack_1}, {dodge}... (lo que tiene asignado cada acción) y {aceptar}, {volver}, {pestana_der}, {pestana_izq},
## {menu} (los botones fijos), con los nombres de este mando.
func pad_tokens() -> Dictionary:
	var out := {"aceptar": button_name(JOY_BUTTON_A), "volver": button_name(JOY_BUTTON_B), "pestana_der": button_name(JOY_BUTTON_RIGHT_SHOULDER),
		"pestana_izq": button_name(JOY_BUTTON_LEFT_SHOULDER), "menu": button_name(JOY_BUTTON_START)}
	for row in PAD_ROWS:
		out[row[0]] = pad_label(row[0])
	return out


static func is_playstation(joy_name: String) -> bool:
	var n := joy_name.to_lower()
	return "dualsense" in n or "dualshock" in n or "playstation" in n or n.begins_with("ps") or n == "wireless controller"
