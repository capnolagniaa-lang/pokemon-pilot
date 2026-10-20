extends Node2D
## Efecto visual de un ataque en área (onda expansiva).

const DURATION := 0.35

var radius := 100.0
var color := Color.WHITE
var t := 0.0


func _process(delta: float) -> void:
	t += delta
	if t >= DURATION:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var k := clampf(t / DURATION, 0.0, 1.0)
	var r := radius * (0.3 + 0.7 * k)
	draw_circle(Vector2.ZERO, r, Color(color, 0.35 * (1.0 - k)))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(color, 1.0 - k), 4.0)
