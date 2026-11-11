class_name RogueDoor
extends Node2D
## La salida de una sala del Modo Desafío (RogueRun), cuando ya está limpia: un círculo de luz que late en el piso con
## una flecha y su cartel. Es solo el dibujo: RogueRun mira si tu Pokémon llegó.

var text := ""
var _time := 0.0


func _ready() -> void:
	z_index = -5  # sobre el piso pintado, debajo de las criaturas
	NightLight.apply(self)
	var label := UiStyle.label(text, 9, Color(1.0, 0.95, 0.7))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-80, -40)
	label.size = Vector2(160, 12)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 3)
	label.z_index = 30
	add_child(label)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var k := 0.5 + 0.5 * sin(_time * 4.0)
	var gold := Color(1.6, 1.3, 0.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.55))  # acostado en el piso
	draw_circle(Vector2.ZERO, 18.0 + k * 3.0, Color(gold, 0.16 + k * 0.1))
	draw_arc(Vector2.ZERO, 16.0 + k * 3.0, 0.0, TAU, 32, Color(gold, 0.85), 1.5)
	draw_arc(Vector2.ZERO, 9.0 + k * 2.0, 0.0, TAU, 24, Color(gold, 0.5), 1.0)
	draw_set_transform(Vector2(0, -20.0 - k * 4.0))
	draw_colored_polygon(PackedVector2Array([Vector2(-5, 0), Vector2(5, 0), Vector2(0, -7)]), Color(gold, 0.9))
