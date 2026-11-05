extends Node
## Registra las acciones de input (teclas físicas, así funciona con cualquier distribución).
## Combate: Clic izq. = ataque 1 · Clic der. = ataque 2 · Q = ataque 3 · R = ataque 4 (el de más recarga) ·
## Espacio = esquive. Los números 1-6 cambian al Pokémon de ese lugar del equipo (también en combate).
## Joystick (2026-11-05, botones elegidos por el usuario; los nombres de JOY_BUTTON son de Xbox): Cuadrado, Cruz, Círculo y
## R1 = los 4 ataques, que salen hacia donde mira el Pokémon (CombatInput); L1 = esquive; L3 = correr (Trainer). `gamepad` dice qué se usó último: tocar el teclado o el mouse vuelve a la mira.

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
}
## [eje, sentido]. Con el zona muerta de `PAD_DEADZONE`.
const PAD_AXES := {
	"move_left": [JOY_AXIS_LEFT_X, -1.0],
	"move_right": [JOY_AXIS_LEFT_X, 1.0],
	"move_up": [JOY_AXIS_LEFT_Y, -1.0],
	"move_down": [JOY_AXIS_LEFT_Y, 1.0],
	"battle_toggle": [JOY_AXIS_TRIGGER_RIGHT, 1.0],
	"quick_item": [JOY_AXIS_TRIGGER_LEFT, 1.0],
}
## Los menús y las charlas (si Godot no los trae ya).
const UI_PAD := {"ui_accept": JOY_BUTTON_A, "ui_cancel": JOY_BUTTON_B, "ui_up": JOY_BUTTON_DPAD_UP, "ui_down": JOY_BUTTON_DPAD_DOWN,
	"ui_left": JOY_BUTTON_DPAD_LEFT, "ui_right": JOY_BUTTON_DPAD_RIGHT}
## Cómo se llaman los botones en cada mando (en palabras: la letra del juego no trae los símbolos de PlayStation).
const PAD_XBOX := {"attack_1": "X", "attack_2": "A", "attack_3": "B", "attack_4": "RB", "dodge": "LB", "capture": "Y",
	"battle_toggle": "RT", "quick_item": "LT", "pause": "Start"}
const PAD_PS := {"attack_1": "Cuadrado", "attack_2": "Cruz", "attack_3": "Círculo", "attack_4": "R1", "dodge": "L1", "capture": "Triángulo",
	"battle_toggle": "R2", "quick_item": "L2", "pause": "Options"}
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
## Cómo se muestran en la interfaz.
const SLOT_KEYS := ["Clic", "Clic der.", "Q", "R"]

## ¿Lo último que se tocó fue el joystick?
var gamepad := false


## Nombre del último mando que se tocó (de ahí salen los nombres de los botones).
var pad_name := ""


## Cómo se llama ahora la tecla de un ataque.
func slot_key(i: int) -> String:
	if i >= SLOT_ACTIONS.size():
		return str(i + 1)
	return pad_label(SLOT_ACTIONS[i]) if gamepad else SLOT_KEYS[i]


## Cómo se llama el botón de una acción en el mando que estás usando.
func pad_label(action: String) -> String:
	return (PAD_PS if is_playstation(pad_name) else PAD_XBOX).get(action, "")


static func is_playstation(joy_name: String) -> bool:
	var n := joy_name.to_lower()
	return "dualsense" in n or "dualshock" in n or "playstation" in n or n.begins_with("ps") or n == "wireless controller"


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var woke: bool = event.pressed if event is InputEventJoypadButton else absf(event.axis_value) >= PAD_WAKE
		if woke:
			gamepad = true
			pad_name = Input.get_joy_name(event.device)
	elif event is InputEventKey or event is InputEventMouseButton:
		gamepad = gamepad and not event.pressed
	elif event is InputEventMouseMotion:
		gamepad = gamepad and event.relative.length() < MOUSE_WAKE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for action in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for k in KEYS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)
	for action in UI_EXTRA:
		var ui := InputEventKey.new()
		ui.physical_keycode = UI_EXTRA[action]
		InputMap.action_add_event(action, ui)
	for action in MOUSE:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE[action]
		InputMap.action_add_event(action, ev)
	for action in PAD_BUTTONS:
		var ev := InputEventJoypadButton.new()
		ev.button_index = PAD_BUTTONS[action]
		ev.device = -1
		InputMap.action_add_event(action, ev)
	for action in PAD_AXES:
		var ev := InputEventJoypadMotion.new()
		ev.axis = PAD_AXES[action][0]
		ev.axis_value = PAD_AXES[action][1]
		ev.device = -1
		InputMap.action_add_event(action, ev)
		InputMap.action_set_deadzone(action, PAD_DEADZONE)
	for action in UI_PAD:
		var ev := InputEventJoypadButton.new()
		ev.button_index = UI_PAD[action]
		ev.device = -1
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)
