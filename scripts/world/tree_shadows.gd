extends Node2D
## Sombras suaves al pie de los árboles de la zona (la luz viene de arriba a la izquierda).

const SHADOW_TEX := preload("res://art/fx/soft_shadow.tres")

@export var offset := Vector2(6, 26)
@export var size := Vector2(34, 12)
@export var opacity := 0.32


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var zone := get_parent() as Zone
	if zone == null:
		return
	for c in zone.tree_cells:
		var center := Vector2(c * Zone.TILE) + offset
		draw_texture_rect(SHADOW_TEX, Rect2(center - size / 2.0, size), false, Color(0, 0, 0, opacity))
