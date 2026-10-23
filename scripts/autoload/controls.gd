extends Node
## Registra las acciones de input (teclas físicas, así funciona con cualquier distribución).
## Combate: Clic izq. = ataque 1 · Clic der. = ataque 2 · Q = ataque 3 · R = ataque 4 (el de más recarga) ·
## Espacio = esquive. Los números 1-6 cambian al Pokémon de ese lugar del equipo (también en combate).

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
	"switch": [KEY_TAB],
	"battle_toggle": [KEY_F],
	"pause": [KEY_ESCAPE],
	## Solo con `-- --debug` (o desde el editor): suma un Pokémon al azar al equipo.
	"debug_add_pokemon": [KEY_F9],
}

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


func _ready() -> void:
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
