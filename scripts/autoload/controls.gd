extends Node
## Registra las acciones de input (teclas físicas, así funciona con cualquier distribución).
## Combate: Clic izq. = ataque 1 · Clic der. = ataque 2 · Q = ataque 3 · R = ataque 4 (el de más recarga) ·
## Espacio = esquive. Los números 1-6 cambian al Pokémon de ese lugar del equipo (también en combate).
## Joystick (2026-11-05, nombres de Xbox): RT, LT, RB y LB = los 4 ataques, que salen hacia donde mira el Pokémon
## (decisión del usuario; CombatInput). `gamepad` dice qué se usó último: tocar el teclado o el mouse vuelve a la mira.

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
	"attack_3": JOY_BUTTON_RIGHT_SHOULDER,
	"attack_4": JOY_BUTTON_LEFT_SHOULDER,
	"dodge": JOY_BUTTON_A,
	"capture": JOY_BUTTON_X,
	"quick_item": JOY_BUTTON_Y,
	"battle_toggle": JOY_BUTTON_B,
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
	"attack_1": [JOY_AXIS_TRIGGER_RIGHT, 1.0],
	"attack_2": [JOY_AXIS_TRIGGER_LEFT, 1.0],
}
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
const SLOT_PAD := ["RT", "LT", "RB", "LB"]

## ¿Lo último que se tocó fue el joystick?
var gamepad := false


## Cómo se llama ahora la tecla de un ataque.
func slot_key(i: int) -> String:
	var names: Array = SLOT_PAD if gamepad else SLOT_KEYS
	return names[i] if i < names.size() else str(i + 1)


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		gamepad = gamepad or event.pressed
	elif event is InputEventJoypadMotion:
		gamepad = gamepad or absf(event.axis_value) >= PAD_WAKE
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
