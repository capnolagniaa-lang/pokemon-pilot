extends Node2D
## Sombra suave bajo un personaje. Si tiene un Sprite2D hermano ("Sprite"), le suma su sombra larga según el sol
## (SunShadow).

const SHADOW_TEX := preload("res://art/fx/soft_shadow.tres")

@export var size := Vector2(16, 6)
@export var opacity := 0.4


func _ready() -> void:
	var sprite := get_parent().get_node_or_null("Sprite") as Sprite2D
	if sprite != null:
		SunShadow.attach_to(sprite)


func _draw() -> void:
	draw_texture_rect(SHADOW_TEX, Rect2(-size / 2.0, size), false, Color(0, 0, 0, opacity))
