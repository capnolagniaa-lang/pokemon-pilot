extends Node
## Registra las acciones de input (teclas físicas, así funciona con cualquier distribución).

const KEYS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"run": [KEY_SHIFT],
	"attack_1": [KEY_1, KEY_J],
	"attack_2": [KEY_2, KEY_K],
	"attack_3": [KEY_3, KEY_L],
	"attack_4": [KEY_4],
	"dodge": [KEY_SPACE],
	"capture": [KEY_E],
	"switch": [KEY_TAB, KEY_Q],
	"battle_toggle": [KEY_F],
}

const MOUSE := {
	"attack_1": MOUSE_BUTTON_LEFT,
	"attack_2": MOUSE_BUTTON_RIGHT,
}


func _ready() -> void:
	for action in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for k in KEYS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)
	for action in MOUSE:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE[action]
		InputMap.action_add_event(action, ev)
