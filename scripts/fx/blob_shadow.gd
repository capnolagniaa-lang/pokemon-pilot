extends Node2D
## Sombra suave bajo un personaje.

const SHADOW_TEX := preload("res://art/fx/soft_shadow.tres")

@export var size := Vector2(16, 6)
@export var opacity := 0.4


func _draw() -> void:
	draw_texture_rect(SHADOW_TEX, Rect2(-size / 2.0, size), false, Color(0, 0, 0, opacity))
