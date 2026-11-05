extends Node
## Los menús con joystick, en todas las pantallas sin tocarlas una por una (pedido del usuario 2026-11-05):
##  · Cruz (ui_accept) acepta y Círculo (ui_cancel) vuelve: los maneja Godot / cada pantalla.
##  · Si nada tiene el foco, lo agarra el primer botón de la pantalla de arriba.
##  · Toda lista con barra baja sola siguiendo al foco (también con el teclado); stick derecho = bajar sin mover el foco; en
##    una con puro texto, también la cruceta y el stick izquierdo.
##  · Mantener una dirección sigue avanzando.
##  · R1 / L1: pestañas. Una pantalla con pestañas propias tiene `menu_tab(paso)`; si no, se usa su TabContainer.

const REPEAT_DELAY := 0.35
const REPEAT_EVERY := 0.09
const SCROLL_SPEED := 700.0
const DIRS := {"ui_up": SIDE_TOP, "ui_down": SIDE_BOTTOM, "ui_left": SIDE_LEFT, "ui_right": SIDE_RIGHT}

## Mientras se elige una tecla (ControlsScreen) no se navega.
var blocked := false
var _held := ""
var _held_time := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().node_added.connect(func(n: Node): if n is ScrollContainer: n.follow_focus = true)


## ¿Hay un menú abierto? (mundo en pausa, o una pantalla suelta como el título; no el editor de mapas)
func menu_open() -> bool:
	if get_tree().paused:
		return true
	var scene := get_tree().current_scene
	return scene != null and scene.scene_file_path.begins_with("res://scenes/ui/")


func _input(event: InputEvent) -> void:
	if blocked or not menu_open():
		return
	var step := 1 if event.is_action_pressed("menu_tab_next") else -1 if event.is_action_pressed("menu_tab_prev") else 0
	if step != 0 and change_tab(step):
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if blocked or not menu_open():
		_held = ""
		return
	if Controls.gamepad:
		_ensure_focus()
		_repeat(delta)
	_scroll(delta)


# --- Pestañas -----------------------------------------------------------------------------------------------------------

func change_tab(step: int) -> bool:
	var found: Array[Control] = []
	_collect(get_tree().root, func(c: Control) -> bool: return c.has_method("menu_tab") or c is TabContainer, found)
	if found.is_empty():
		return false
	# La de más arriba, y entre una pantalla y su TabContainer de adentro, la pantalla.
	var top := found[-1]
	for c in found:
		if c.has_method("menu_tab") and c.is_ancestor_of(top):
			top = c
			break
	if top.has_method("menu_tab"):
		top.menu_tab(step)
	else:
		var tabs := top as TabContainer
		tabs.current_tab = posmod(tabs.current_tab + step, tabs.get_tab_count())
	return true


# --- Foco ---------------------------------------------------------------------------------------------------------------

func _ensure_focus() -> void:
	if get_viewport().gui_get_focus_owner() != null:
		return
	var target := first_focusable()
	if target != null:
		target.grab_focus()


## El primer botón de la pantalla de más arriba.
func first_focusable() -> Control:
	var all: Array[Control] = []
	_collect(get_tree().root, func(c: Control) -> bool: return c.focus_mode == Control.FOCUS_ALL and not (c is BaseButton and c.disabled), all)
	if all.is_empty():
		return null
	# Sube desde el último hasta justo debajo de lo que tienen en común todos: esa rama es la pantalla de arriba (un
	# cartel encima de otra pantalla). Si los botones están todos en una misma lista, es el primero.
	var branch: Node = all[-1]
	while branch.get_parent() != null and not all.all(func(c: Control) -> bool: return branch.get_parent().is_ancestor_of(c)):
		branch = branch.get_parent()
	if branch == all[-1]:
		return all[0]
	for c in all:
		if branch.is_ancestor_of(c):
			return c
	return all[0]


## Lo visible que cumple `test`, en el orden en que se dibuja: las capas (CanvasLayer) de más arriba, al final.
func _collect(node: Node, test: Callable, out: Array[Control]) -> void:
	var by_layer := {}
	_walk(node, 0, test, by_layer)
	var layers := by_layer.keys()
	layers.sort()
	for l in layers:
		out.append_array(by_layer[l])


func _walk(node: Node, layer: int, test: Callable, by_layer: Dictionary) -> void:
	if node is CanvasLayer:
		if not node.visible:
			return
		layer = node.layer
	if node is CanvasItem and not node.visible:
		return
	if node is Control and test.call(node):
		if not by_layer.has(layer):
			by_layer[layer] = [] as Array[Control]
		by_layer[layer].append(node)
	for c in node.get_children():
		_walk(c, layer, test, by_layer)


## Mantener una dirección sigue moviendo el foco (el teclado ya lo hace solo).
func _repeat(delta: float) -> void:
	var now := ""
	for action in DIRS:
		if Input.is_action_pressed(action):
			now = action
			break
	if now != _held:
		_held = now
		_held_time = 0.0
		return
	if now == "":
		return
	_held_time += delta
	if _held_time < REPEAT_DELAY:
		return
	_held_time -= REPEAT_EVERY
	var owner := get_viewport().gui_get_focus_owner()
	if owner == null or owner is Slider:
		return
	var next := owner.find_valid_focus_neighbor(DIRS[now])
	if next != null:
		next.grab_focus()


# --- Barras -------------------------------------------------------------------------------------------------------------

func _scroll(delta: float) -> void:
	var target := scroll_target()
	if target == null:
		return
	var amount := Input.get_action_strength("menu_scroll_down") - Input.get_action_strength("menu_scroll_up")
	if amount == 0.0 and not has_focusable(target):  # puro texto: no hay foco que seguir
		amount = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if amount != 0.0:
		target.scroll_vertical += int(signf(amount) * ceilf(absf(amount) * SCROLL_SPEED * delta))


## La barra del foco o, si el foco no está en una, la más grande que se vea que tenga para bajar.
func scroll_target() -> ScrollContainer:
	var owner: Node = get_viewport().gui_get_focus_owner()
	while owner != null:
		if owner is ScrollContainer:
			return owner
		owner = owner.get_parent()
	var all: Array[Control] = []
	_collect(get_tree().root, func(c: Control) -> bool: return c is ScrollContainer and c.get_v_scroll_bar().max_value > c.size.y, all)
	var best: ScrollContainer = null
	for c in all:
		if best == null or c.size.y > best.size.y:
			best = c
	return best


func has_focusable(scroll: ScrollContainer) -> bool:
	var found: Array[Control] = []
	_collect(scroll, func(c: Control) -> bool: return c != scroll and c.focus_mode == Control.FOCUS_ALL, found)
	return not found.is_empty()
