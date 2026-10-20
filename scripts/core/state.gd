class_name State
extends Node
## Un estado de una StateMachine. El nombre del nodo (en minúsculas) es su id.

var machine: StateMachine
## El nodo que controla la máquina (el padre de la StateMachine).
var actor: Node


func enter(_msg: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func transition(state_name: String, msg: Dictionary = {}) -> void:
	machine.transition_to(state_name, msg)
