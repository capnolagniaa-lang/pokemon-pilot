class_name CameraRig
extends Camera2D
## Cámara del mundo: sigue a un objetivo (entrenador o Pokémon en combate) con suavizado y tiembla
## cuando se lo pide el bus de eventos. La rueda del mouse acerca y aleja (pedido del usuario 2026-11-01: "un poco
## más de zoom out para ver más del mapa"), entre MIN_ZOOM y MAX_ZOOM; se recuerda en ZOOM_PATH.

const MAX_ZOOM := 3.0
const MIN_ZOOM := 2.0
const ZOOM_STEP := 0.25
const ZOOM_SPEED := 10.0
const ZOOM_PATH := "user://camara.cfg"

@export var follow_offset := Vector2(0, -10)
@export var follow_speed := 7.0

var target: Node2D
var _shake := 0.0
## El zoom al que va la cámara (la rueda lo cambia; se llega suave).
var zoom_goal := MAX_ZOOM
## Hasta dónde se puede alejar (el Modo Desafío lo baja en las salas: `RogueRun.ROOM_ZOOM`).
var zoom_floor := MIN_ZOOM
var _zooming := false  # solo se anima lo que pidió la rueda (las vitrinas ponen el zoom a mano)


func _ready() -> void:
	Events.camera_shake.connect(func(s: float): _shake = maxf(_shake, s))
	var cfg := ConfigFile.new()
	if not _automated() and cfg.load(ZOOM_PATH) == OK:  # los tests y vitrinas, siempre con el de siempre
		zoom_goal = clampf(float(cfg.get_value("camara", "zoom", MAX_ZOOM)), MIN_ZOOM, MAX_ZOOM)
	zoom = Vector2.ONE * zoom_goal


func _unhandled_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or get_tree().paused:
		return
	if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
		set_zoom_goal(zoom_goal + ZOOM_STEP)
	elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		set_zoom_goal(zoom_goal - ZOOM_STEP)


func set_zoom_goal(z: float) -> void:
	z = clampf(z, zoom_floor, MAX_ZOOM)
	if is_equal_approx(z, zoom_goal):
		return
	zoom_goal = z
	_zooming = true
	if _automated():
		return
	var cfg := ConfigFile.new()
	cfg.set_value("camara", "zoom", zoom_goal)
	cfg.save(ZOOM_PATH)


static func _automated() -> bool:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--autotest") or a.begins_with("--showcase") or a == "--overview":
			return true
	return false


func snap() -> void:
	if is_instance_valid(target):
		global_position = target.global_position + follow_offset


func _process(delta: float) -> void:
	if is_instance_valid(target):
		var goal := target.global_position + follow_offset
		global_position = global_position.lerp(goal, 1.0 - exp(-follow_speed * delta))
	if _zooming:
		var z := lerpf(zoom.x, zoom_goal, 1.0 - exp(-ZOOM_SPEED * delta))
		_zooming = absf(z - zoom_goal) >= 0.002
		zoom = Vector2.ONE * (z if _zooming else zoom_goal)
	_shake = move_toward(_shake, 0.0, delta * 30.0)
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
