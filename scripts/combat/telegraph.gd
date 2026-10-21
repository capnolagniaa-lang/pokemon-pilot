class_name Telegraph
extends Node2D
## Indicador en el suelo de un ataque que se está cargando (regla: "todo gran efecto se telegrafía").
## Círculo para áreas, línea para proyectiles/embestidas. Se llena a medida que avanza la carga.

enum Shape { NONE, CIRCLE, LINE }

var shape := Shape.NONE
var radius := 40.0
var length := 120.0
var width := 10.0
var direction := Vector2.RIGHT
var color := Color.WHITE
## Progreso de la carga (0..1).
var progress := 0.0


func _ready() -> void:
	z_as_relative = false
	z_index = -6


func show_circle(p_radius: float, p_color: Color) -> void:
	shape = Shape.CIRCLE
	radius = p_radius
	color = p_color
	progress = 0.0
	queue_redraw()


func show_line(p_dir: Vector2, p_length: float, p_width: float, p_color: Color) -> void:
	shape = Shape.LINE
	direction = p_dir.normalized()
	length = p_length
	width = p_width
	color = p_color
	progress = 0.0
	queue_redraw()


func clear() -> void:
	shape = Shape.NONE
	queue_redraw()


func _process(_delta: float) -> void:
	if shape != Shape.NONE:
		queue_redraw()


func _draw() -> void:
	var edge := Color(color.r, color.g, color.b, 0.75)
	var fill := Color(color.r, color.g, color.b, 0.16)
	var done := Color(color.r, color.g, color.b, 0.3)
	match shape:
		Shape.CIRCLE:
			draw_set_transform(Vector2(0, -2), 0.0, Vector2(1.0, 0.75))  # perspectiva top-down
			draw_circle(Vector2.ZERO, radius, fill)
			draw_circle(Vector2.ZERO, radius * progress, done)
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, edge, 1.0)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		Shape.LINE:
			var a := direction.angle()
			draw_set_transform(Vector2(0, -6), a, Vector2.ONE)
			var r := Rect2(0, -width / 2.0, length, width)
			draw_rect(r, fill)
			draw_rect(Rect2(0, -width / 2.0, length * progress, width), done)
			draw_rect(r, edge, false, 1.0)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
