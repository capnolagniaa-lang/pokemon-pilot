class_name VfxSprite
extends AnimatedSprite2D
## Efecto de ataque con sprite (hojas hechas con PixelLab/Sorceress, ver docs/TUTORIAL_PIXELLAB_SORCERESS.md).
## Las hojas se dibujan apuntando a la derecha: el que lo usa lo rota según la dirección del ataque.
## `attach` = sigue al padre y se repite (cuerpo del proyectil); `burst` = se reproduce una vez y se borra.

## Si nadie la cambia, la hoja se ve a su tamaño real; `size` > 0 la escala para que su ancho mida eso.
static func _make(frames: SpriteFrames, rot: float, size: float) -> VfxSprite:
	var s := VfxSprite.new()
	s.sprite_frames = frames
	s.rotation = rot
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if size > 0.0:
		var tex := frames.get_frame_texture("default", 0)
		if tex != null and tex.get_width() > 0:
			s.scale = Vector2.ONE * size / tex.get_width()
	return s


## Cuerpo que acompaña al nodo (en bucle).
static func attach(parent: Node2D, frames: SpriteFrames, rot: float = 0.0, size: float = 0.0) -> VfxSprite:
	var s := _make(frames, rot, size)
	parent.add_child(s)
	s.play("default")
	return s


## Efecto suelto en el mundo: una pasada de la animación y se borra.
static func burst(parent: Node, frames: SpriteFrames, at: Vector2, rot: float = 0.0, size: float = 0.0, z: int = 4) -> VfxSprite:
	var s := _make(frames, rot, size)
	s.z_index = z
	parent.add_child(s)
	s.global_position = at
	NightLight.compensate(s)  # de noche no se oscurece
	s.animation_finished.connect(s.queue_free)
	s.animation_looped.connect(s.queue_free)
	s.play("default")
	return s
