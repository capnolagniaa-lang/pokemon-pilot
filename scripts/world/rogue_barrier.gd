class_name RogueBarrier
extends Node2D
## La barrera de la escalera del castillo de Mew (Modo Desafío, RogueRun): una cortina de luz rosa que late al pie de la
## escalera a la planta alta, cerrada hasta avanzar en la historia del modo (RogueProgress, bandera "planta_alta").
## Es solo el dibujo: la escalera ya choca por el plano de la pintura y el mensaje lo da RogueRun.

var width := 72.0
var _time := 0.0


func _ready() -> void:
	z_index = 2
	NightLight.apply(self)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var k := 0.5 + 0.5 * sin(_time * 2.5)
	var pink := Color(1.6, 0.6, 1.5)
	var half := width / 2.0
	draw_rect(Rect2(-half, -22.0, width, 22.0), Color(pink, 0.10 + 0.06 * k))
	for i in 7:  # hilos de luz que suben
		var x := -half + width * (float(i) + 0.5) / 7.0
		var h := 14.0 + 8.0 * sin(_time * 3.0 + float(i) * 1.7)
		draw_line(Vector2(x, 0), Vector2(x, -h), Color(pink, 0.35 + 0.25 * k), 1.0)
	draw_line(Vector2(-half, 0), Vector2(half, 0), Color(pink, 0.9), 1.5)
	draw_line(Vector2(-half, -22.0), Vector2(half, -22.0), Color(pink, 0.3 + 0.2 * k), 1.0)
	for x in [-half, half]:  # los dos sellos de las puntas
		draw_circle(Vector2(x, 0), 2.5 + k, Color(pink, 0.9))
