class_name BubbleFx
extends Node2D
## Burbuja que envuelve a la criatura (estado con StatusEffect.fx_bubble, ej. Encerrado en burbuja de Poliwag).

var color := Color(0.6, 0.85, 1.0)
var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var r := 12.0 + sin(_time * 7.0) * 0.8
	draw_circle(Vector2.ZERO, r, Color(color.r, color.g, color.b, 0.22))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(color.r * 1.2, color.g * 1.2, color.b * 1.3, 0.8), 1.2)
	draw_arc(Vector2.ZERO, r * 0.7, -2.4, -1.6, 8, Color(1.4, 1.4, 1.5, 0.8), 1.5)
