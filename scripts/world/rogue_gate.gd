class_name RogueGate
extends StaticBody2D
## Portón que tapa el paso entre dos salas del Modo Desafío (RogueRun): una empalizada de troncos con enredaderas.
## Choca como una pared; `open()` lo saca. Con `shown` = false es solo la pared (los extremos de la cadena de salas).

var width := 64.0
var shown := true
const HEIGHT := 14.0
const WOOD := Color(0.36, 0.24, 0.14)
const WOOD_LIGHT := Color(0.52, 0.36, 0.2)
const VINE := Color(0.2, 0.5, 0.22)


func _ready() -> void:
	collision_layer = 1  # "mundo": frena a todos, también los disparos
	collision_mask = 0
	z_index = 2
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, HEIGHT)
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)


func _draw() -> void:
	if not shown:
		return
	var n := maxi(3, int(width / 9.0))
	var step := width / n
	for i in n:
		var x := -width / 2.0 + step * (i + 0.5)
		var tall := 22.0 + float((i * 7) % 5)
		draw_rect(Rect2(x - 3.5, -tall + 6.0, 7.0, tall), WOOD)
		draw_rect(Rect2(x - 3.5, -tall + 6.0, 2.0, tall), WOOD_LIGHT)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 3.5, -tall + 6.0), Vector2(x + 3.5, -tall + 6.0), Vector2(x, -tall)]), WOOD_LIGHT)
	draw_rect(Rect2(-width / 2.0, -9.0, width, 3.0), WOOD.darkened(0.25))
	draw_rect(Rect2(-width / 2.0, 0.0, width, 3.0), WOOD.darkened(0.25))
	var pts := PackedVector2Array()
	for i in int(width / 4.0) + 1:
		pts.append(Vector2(-width / 2.0 + i * 4.0, -5.0 + sin(i * 1.3) * 5.0))
	draw_polyline(pts, VINE, 2.0)


## Se abre: astillas y hojas, y deja de tapar.
func open() -> void:
	Fx.burst(get_parent(), global_position + Vector2(0, -8), WOOD_LIGHT, 18, 70.0)
	Fx.burst(get_parent(), global_position + Vector2(0, -8), VINE, 10, 50.0)
	queue_free()
