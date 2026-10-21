class_name StateMachine
extends Node
## Máquina de estados genérica: los hijos State son los estados posibles.

signal state_changed(from: String, to: String)

@export var initial_state: State

var current: State
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[String(child.name).to_lower()] = child
			child.machine = self
			child.actor = get_parent()
	# El actor termina su _ready después que nosotros: arrancamos al final del frame.
	_start.call_deferred()


func _start() -> void:
	# Si algo ya la hizo cambiar de estado antes de arrancar (ej. la aturdieron al aparecer), se respeta.
	if current != null:
		return
	var first := initial_state if initial_state != null else (get_child(0) as State)
	current = first
	current.enter()


func _process(delta: float) -> void:
	if current:
		current.update(delta)


func _physics_process(delta: float) -> void:
	if current:
		current.physics_update(delta)


func transition_to(state_name: String, msg: Dictionary = {}) -> void:
	var next: State = states.get(state_name)
	if next == null:
		push_error("Estado inexistente: %s" % state_name)
		return
	var prev := current_name()
	if current:
		current.exit()
	current = next
	current.enter(msg)
	state_changed.emit(prev, state_name)


func current_name() -> String:
	return String(current.name).to_lower() if current else ""
