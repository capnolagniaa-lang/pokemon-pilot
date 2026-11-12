class_name RogueThreshold
extends Node2D
## El umbral de piedra de un paso entre salas del Modo Desafío (salas por piezas): dos pilares a los costados del
## corredor y una losa en el piso. Cada sala pone uno en su paso de arriba y otro en el de abajo, así en la unión de dos
## salas (aunque sean de biomas distintos) quedan los pilares de las dos formando un portal, y el cambio de bioma no
## queda cortado en seco. Dibujado por código, en pixel art. No choca: los pilares van sobre la pared.

## Ancho del corredor (px) y hacia dónde mira (1 = es el paso de arriba de su sala, -1 = el de abajo).
var width := 96.0
var side := 1

const STONE := Color(0.46, 0.44, 0.42)
const LIGHT := Color(0.62, 0.60, 0.57)
const DARK := Color(0.27, 0.26, 0.26)
const RUNE := Color(1.25, 0.85, 1.35)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	NightLight.apply(self)


func _draw() -> void:
	var half := width / 2.0
	# Losa del umbral, en el piso.
	draw_rect(Rect2(-half, -5, width, 10), DARK)
	draw_rect(Rect2(-half, -4, width, 7), STONE)
	for i in 6:
		draw_rect(Rect2(-half + float(i) * width / 6.0, -4, 1, 7), DARK)
	draw_rect(Rect2(-half, -4, width, 1), LIGHT)
	# Los dos pilares (el origen está en sus pies: quedan en el y-sort y tapan a quien pasa por detrás).
	for x: float in [-half - 9.0, half + 9.0]:
		_pillar(Vector2(x, 4))


func _pillar(feet: Vector2) -> void:
	var w := 14.0
	var h := 38.0
	var r := Rect2(feet.x - w / 2.0, feet.y - h, w, h)
	draw_rect(Rect2(r.position + Vector2(-2, h - 5), Vector2(w + 4, 6)), DARK)  # base
	draw_rect(r, STONE)
	draw_rect(Rect2(r.position, Vector2(3, h)), LIGHT)
	draw_rect(Rect2(r.position + Vector2(w - 3, 0), Vector2(3, h)), DARK)
	for y in [10.0, 20.0, 30.0]:
		draw_rect(Rect2(r.position + Vector2(0, y), Vector2(w, 1)), DARK)
	draw_rect(Rect2(r.position + Vector2(-2, -4), Vector2(w + 4, 5)), LIGHT)  # capitel
	draw_rect(Rect2(r.position + Vector2(-2, 0), Vector2(w + 4, 1)), DARK)
	draw_rect(Rect2(feet.x - 1.5, r.position.y + 13.0, 3, 5), RUNE)  # una runa que brilla
