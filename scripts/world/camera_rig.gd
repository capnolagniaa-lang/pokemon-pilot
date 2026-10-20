class_name CameraRig
extends Camera2D
## Cámara del mundo: sigue a un objetivo (entrenador o Pokémon en combate) con suavizado y tiembla
## cuando se lo pide el bus de eventos.

@export var follow_offset := Vector2(0, -10)
@export var follow_speed := 7.0

var target: Node2D
var _shake := 0.0


func _ready() -> void:
	Events.camera_shake.connect(func(s: float): _shake = maxf(_shake, s))


func snap() -> void:
	if is_instance_valid(target):
		global_position = target.global_position + follow_offset


func _process(delta: float) -> void:
	if is_instance_valid(target):
		var goal := target.global_position + follow_offset
		global_position = global_position.lerp(goal, 1.0 - exp(-follow_speed * delta))
	_shake = move_toward(_shake, 0.0, delta * 30.0)
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
