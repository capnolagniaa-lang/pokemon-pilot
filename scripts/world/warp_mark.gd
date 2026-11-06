class_name WarpMark
extends Node2D
## Marca de una puerta que sobre el mapa parece piso común (la Mansión Pokémon: en FireRed esas celdas son solo donde caés
## desde arriba, y acá te suben; pedido del usuario 2026-11-06). Escalera de mano con una flecha que sube y baja. Es decorado.

const SIZE := 16.0
const WOOD := Color(0.47, 0.27, 0.13)
const WOOD_LIGHT := Color(0.76, 0.52, 0.28)
const ARROW := Color(1.0, 0.86, 0.32)
const ARROW_EDGE := Color(0.36, 0.20, 0.06)
## Sobre el suelo, debajo de los personajes (como CaveLights).
const Z := -5

var _t := 0.0


static func attach(zone: Node2D, cell: Vector2i) -> WarpMark:
	var mark := WarpMark.new()
	mark.name = "WarpMark_%d_%d" % [cell.x, cell.y]
	mark.z_index = Z
	mark.position = (Vector2(cell) + Vector2.ONE * 0.5) * SIZE
	zone.add_child(mark)
	return mark


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	for x: float in [-5.0, 3.0]:
		draw_rect(Rect2(x, -7.0, 2.0, 15.0), WOOD)
		draw_rect(Rect2(x, -7.0, 1.0, 15.0), WOOD_LIGHT)
	for y: float in [-5.0, -1.0, 3.0, 6.0]:
		draw_rect(Rect2(-3.0, y, 6.0, 1.0), WOOD_LIGHT)
	var lift := roundf(sin(_t * 3.0) * 1.5)
	var tip := Vector2(0.0, -13.0 + lift)
	var outline := PackedVector2Array([tip + Vector2(0, -2), tip + Vector2(6, 5), tip + Vector2(-6, 5)])
	var fill := PackedVector2Array([tip, tip + Vector2(4, 4), tip + Vector2(-4, 4)])
	draw_colored_polygon(outline, ARROW_EDGE)
	draw_colored_polygon(fill, ARROW)
