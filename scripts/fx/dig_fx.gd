class_name DigFx
extends RefCounted
## Los gráficos de Excavar (hojas hechas con Qwen, docs/COMFYUI.md): el pozo y el Pokémon que se hunde, el montículo que
## viaja con su rastro de tierra removida y la erupción de la salida. Es tierra de verdad: de noche se oscurece como el piso.

const ENTRY := "res://sprites/fx/moves/excavar_entrada.png"
const MOUND := "res://sprites/fx/moves/excavar_monticulo.png"
const ERUPTION := "res://sprites/fx/moves/excavar_salida.png"
## Dónde está el suelo dentro de cada hoja (el montículo y la erupción suben desde ahí).
const MOUND_LIFT := 8.0
const ERUPTION_LIFT := 27.0
const ERUPTION_SPEED := 0.8
const SINK_TIME := 0.22
const POP_HEIGHT := 16.0
const POP_TIME := 0.34
## El último cuadro del pozo es un montoncito de tierra: lo que queda atrás al pasar.
const TRAIL_FRAME := 5
const TRAIL_TIME := 1.6
const GROUND_Z := -5


## Se abre el pozo y el Pokémon se hunde en él (una copia suya: el de verdad ya está bajo tierra).
static func dive(c: Creature) -> void:
	var parent := c.get_parent()
	_once(parent, ENTRY, c.global_position, GROUND_Z)
	trail(parent, c.global_position)
	var ghost: Sprite2D = c.sprite.snapshot()
	if ghost == null:
		return
	parent.add_child(ghost)
	ghost.global_position = c.global_position
	var at: AtlasTexture = ghost.texture
	var from := at.region
	var top := ghost.offset
	# Lo corta a la altura de los pies y lo va bajando: se pierde en el suelo sin achicarse.
	var sink := func(d: float) -> void:
		var h := maxf(-top.y - d, 1.0)
		at.region = Rect2(from.position, Vector2(from.size.x, minf(h, from.size.y)))
		ghost.offset = Vector2(top.x, top.y + d)
	sink.call(0.0)
	var tw := ghost.create_tween()
	tw.tween_method(sink, 0.0, -top.y, SINK_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(ghost.queue_free)


## El montículo, en bucle: lo lleva el que excava.
static func mound(parent: Node2D) -> AnimatedSprite2D:
	var s := _sprite(MOUND)
	if s == null:
		return null
	s.position = Vector2(0, -MOUND_LIFT)
	s.speed_scale = 0.6
	parent.add_child(s)
	s.play("default")
	return s


## Tierra removida que queda en el piso y se va borrando.
static func trail(parent: Node, at: Vector2) -> void:
	var frames := DB.vfx_sheet(ENTRY)
	if frames == null:
		return
	var s := Sprite2D.new()
	s.texture = frames.get_frame_texture("default", TRAIL_FRAME)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.flip_h = randf() < 0.5
	s.scale = Vector2.ONE * randf_range(0.6, 0.85)
	s.z_index = GROUND_Z - 1
	parent.add_child(s)
	s.global_position = at
	var tw := s.create_tween()
	tw.tween_property(s, "modulate:a", 0.0, TRAIL_TIME).set_ease(Tween.EASE_IN)
	tw.tween_callback(s.queue_free)


## La erupción de la salida, y el Pokémon que salta de adentro.
static func erupt(parent: Node, at: Vector2, c: Creature = null) -> void:
	_once(parent, ERUPTION, at + Vector2(0, -ERUPTION_LIFT), 1, ERUPTION_SPEED)
	if c == null:
		return
	var tw := c.sprite.create_tween()
	tw.tween_property(c.sprite, "lift", POP_HEIGHT, POP_TIME * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(c.sprite, "lift", 0.0, POP_TIME * 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


static func _once(parent: Node, sheet: String, at: Vector2, z: int, speed: float = 1.0) -> void:
	var s := _sprite(sheet)
	if s == null:
		return
	s.z_index = z
	s.speed_scale = speed
	parent.add_child(s)
	s.global_position = at
	s.animation_looped.connect(s.queue_free)
	s.play("default")


static func _sprite(sheet: String) -> AnimatedSprite2D:
	var frames := DB.vfx_sheet(sheet)
	if frames == null:
		return null
	var s := AnimatedSprite2D.new()
	s.sprite_frames = frames
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return s
