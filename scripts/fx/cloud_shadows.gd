extends ColorRect
## Rectángulo que cubre lo que ve la cámara y dibuja las sombras de nubes (shader en coordenadas del mundo).

@export var margin := 64.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color.WHITE


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var view := get_viewport_rect().size / cam.zoom + Vector2(margin, margin) * 2.0
	size = view
	global_position = cam.get_screen_center_position() - view / 2.0
