class_name EnvObject
extends StaticBody2D
## Objeto del entorno con tags (roca frágil, roca pesada, arbusto cortable...).
## El entorno reactivo (ReactionSystem) rompe lo frágil con una embestida de al menos `break_power` de potencia.

## Nombre para mostrar (editor de mapas).
@export var display_name: String = ""
@export var tags: PackedStringArray = []
## Potencia mínima de la embestida que lo rompe (si es "fragil").
@export var break_power: float = 30.0

var _gone := false

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	add_to_group("env_objects")


func has_tag(tag: String) -> bool:
	return tags.has(tag)


## Lo cortan con Corte (árbol fino: FieldMoves). Vuelve a crecer cuando se recarga la zona, como en los juegos.
func cut() -> void:
	if _gone:
		return
	_gone = true
	collision_layer = 0
	Fx.burst(get_parent(), global_position + Vector2(0, -8), Color(0.35, 0.7, 0.3), 16, 60.0)
	Events.env_reaction.emit(global_position, "¡Cortado!")
	var tw := create_tween()
	tw.tween_property(sprite, "scale:y", 0.0, 0.18)
	tw.parallel().tween_property(sprite, "modulate:a", 0.0, 0.18)
	tw.tween_callback(queue_free)


## Se rompe en pedazos (roca frágil).
func shatter() -> void:
	if _gone:
		return
	_gone = true
	collision_layer = 0
	Fx.burst(get_parent(), global_position + Vector2(0, -6), Color(0.75, 0.68, 0.6), 18, 70.0)
	Events.camera_shake.emit(3.0)
	Events.env_reaction.emit(global_position, "¡Se rompió!")
	var tw := create_tween()
	tw.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tw.tween_callback(queue_free)

