class_name EnvObject
extends StaticBody2D
## Objeto del entorno con tags (roca frágil, roca pesada, arbusto cortable...).
## El sistema de entorno reactivo (Etapa 3) le aplica elementos según sus tags.

@export var tags: PackedStringArray = []

@onready var sprite: Sprite2D = $Sprite


func has_tag(tag: String) -> bool:
	return tags.has(tag)
