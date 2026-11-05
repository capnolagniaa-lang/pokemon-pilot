class_name BallAim
extends Node2D
## La mira de la Pokébola con joystick (PlayerItems): dónde va a caer, con el tamaño real del golpe. Roja y blanca si está
## sobre un salvaje, blanca si está suelta y apagada si el salvaje marcado quedó fuera de alcance. Puntos hasta el entrenador.

const LOCKED := Color(1.0, 0.25, 0.2)
const FREE := Color(1.0, 1.0, 1.0)
const FAR := Color(0.6, 0.6, 0.6)

var from := Vector2.ZERO
var locked := false
var in_range := true
var _time := 0.0


func _ready() -> void:
	z_as_relative = false
	z_index = 30  # por encima de los techos y las copas (Overhead es 20): si no, atrás de una casa no se ve


func place(point: Vector2, p_from: Vector2, p_locked: bool, p_in_range: bool) -> void:
	global_position = point
	from = p_from
	locked = p_locked
	in_range = p_in_range
	visible = true
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var col := FAR if not in_range else LOCKED if locked else FREE
	# Puntos del entrenador a la mira.
	var to_from := to_local(from)
	var dots := int(to_from.length() / 14.0)
	for i in range(1, dots):
		draw_circle(to_from * (float(i) / dots), 1.2, Color(col, 0.55))
	# El aro, aplastado como una sombra en el piso, y una bola que late al medio.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	var radius := BallThrow.HIT_RADIUS + (sin(_time * 7.0) * 1.2 if locked else 0.0)
	draw_circle(Vector2.ZERO, radius, Color(col, 0.16))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(0, 0, 0, 0.6), 3.0)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, col, 1.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(Vector2.ZERO, 3.0, Color(0, 0, 0, 0.6))
	draw_circle(Vector2.ZERO, 2.2, col)
