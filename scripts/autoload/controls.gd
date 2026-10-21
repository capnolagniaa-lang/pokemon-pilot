extends Node
## Registra las acciones de input (teclas físicas, así funciona con cualquier distribución).
## Kit en combate (plan de identidad): Clic izq. básico · Clic der. habilidad 1 · Q habilidad 2 ·
## Espacio movilidad · R definitiva. Los números 1-4 son alternativas (básico, hab.1, hab.2, definitiva).

const KEYS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"run": [KEY_SHIFT],
	"basic": [KEY_1],
	"ability_1": [KEY_2],
	"ability_2": [KEY_Q, KEY_3],
	"mobility": [KEY_SPACE],
	"ultimate": [KEY_R, KEY_4],
	"capture": [KEY_E],
	"switch": [KEY_TAB],
	"battle_toggle": [KEY_F],
}

const MOUSE := {
	"basic": MOUSE_BUTTON_LEFT,
	"ability_1": MOUSE_BUTTON_RIGHT,
}

## Acción de cada ranura del kit (en el orden de Kit.Slot).
const SLOT_ACTIONS := ["basic", "ability_1", "ability_2", "mobility", "ultimate"]
## Cómo se muestran en la interfaz.
const SLOT_KEYS := ["Clic", "Clic der.", "Q", "Espacio", "R"]


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
