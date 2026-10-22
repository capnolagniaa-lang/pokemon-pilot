class_name EnvObject
extends StaticBody2D
## Objeto del entorno con tags (roca frágil, roca pesada, arbusto cortable...).
## El entorno reactivo (ReactionSystem) le aplica elementos según sus tags: lo inflamable se quema y lo
## frágil se rompe con una embestida de al menos `break_power` de potencia.

@export var tags: PackedStringArray = []
## Potencia mínima de la embestida que lo rompe (si es "fragil").
@export var break_power: float = 30.0

var _gone := false

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	add_to_group("env_objects")


func has_tag(tag: String) -> bool:
	return tags.has(tag)


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


## Se quema y desaparece (árbol cortable, arbustos).
func burn_away() -> void:
	if _gone:
		return
	_gone = true
	var fire := CPUParticles2D.new()
	fire.position = Vector2(0, -8)
	fire.amount = 16
	fire.lifetime = 0.6
	fire.texture = StatusEffects._flame_texture()
	fire.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fire.emission_rect_extents = Vector2(6, 6)
	fire.direction = Vector2.UP
	fire.gravity = Vector2(0, -60)
	fire.initial_velocity_min = 5.0
	fire.initial_velocity_max = 15.0
	fire.scale_amount_min = 1.5
	fire.scale_amount_max = 2.6
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.3, 0.6, 0.25))
	ramp.add_point(0.45, Color(1.1, 0.28, 0.08))
	ramp.set_color(1, Color(0.3, 0.08, 0.04, 0.0))
	fire.color_ramp = ramp
	fire.z_index = 2
	add_child(fire)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(0.25, 0.15, 0.1), 1.2)
	tw.tween_callback(func(): collision_layer = 0; fire.emitting = false)
	tw.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tw.tween_interval(0.6)
	tw.tween_callback(queue_free)
