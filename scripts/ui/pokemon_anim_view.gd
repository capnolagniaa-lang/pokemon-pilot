class_name PokemonAnimView
extends Control
## Dibuja la animación PMD (Idle por defecto) de una especie, mirando hacia abajo y escalada en enteros
## (pixel art nítido). Si la especie no tiene hojas de animación, usa el retrato.

var species: SpeciesData:
	set(value):
		species = value
		queue_redraw()
var anim_name := "Idle"
## Escala del pixel art (entera para que no se deforme).
var pixel_scale := 3
var _time := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if species == null:
		return
	var anims := DB.anims_of(species)
	if not anims.has(anim_name):
		var tex := DB.portrait_of(species)
		if tex != null:
			var s := minf(size.x / tex.get_width(), size.y / tex.get_height())
			var d := tex.get_size() * floorf(maxf(1.0, s))
			draw_texture_rect(tex, Rect2((size - d) / 2.0, d), false)
		return
	var a: Dictionary = anims[anim_name]
	var durations: Array = a["durations"]
	var total := 0
	for d in durations:
		total += d
	var t := int(_time * 60.0) % maxi(1, total)
	var frame := 0
	var acc := 0
	for i in durations.size():
		acc += durations[i]
		if t < acc:
			frame = i
			break
	var fw: float = a["w"]
	var fh: float = a["h"]
	var dst := Vector2(fw, fh) * pixel_scale
	# Sombra a los pies
	# En las hojas PMD los pies quedan ~8 px debajo del centro del frame (igual que CreatureSprite.foot_offset).
	var center := Vector2(size.x / 2.0, size.y / 2.0 + 8.0 * pixel_scale)
	draw_set_transform(center, 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 7.0 * pixel_scale, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_texture_rect_region(DB.texture(a["file"]), Rect2((size - dst) / 2.0, dst), Rect2(frame * fw, 0, fw, fh))
