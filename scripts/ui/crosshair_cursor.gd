class_name CrosshairCursor
extends Node
## El mouse del juego es una mira roja (pedido del usuario 2026-10-28: "el mouse lo termino perdiendo"). World la
## agrega; mientras jugás se ve la mira y con el juego pausado (menú, mochila, tienda...) vuelve la flecha. Al salir del
## mundo (título) también vuelve la flecha. La mira se dibuja por código: aro, cruz con un hueco en el medio y un punto,
## en rojo con borde oscuro para que se vea sobre el pasto claro y en las cuevas.

const SIZE := 32
const RED := Color(1.0, 0.16, 0.16)
const EDGE := Color(0.08, 0.02, 0.02, 0.9)

static var _tex: ImageTexture
var _on := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_use_crosshair(true)


func _process(_delta: float) -> void:
	var want := not get_tree().paused
	if want != _on:
		_use_crosshair(want)


func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null)
	_on = false


func _use_crosshair(on: bool) -> void:
	_on = on
	if on:
		Input.set_custom_mouse_cursor(texture(), Input.CURSOR_ARROW, Vector2(SIZE, SIZE) / 2.0)
	else:
		Input.set_custom_mouse_cursor(null)


static func texture() -> ImageTexture:
	if _tex == null:
		var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
		var c := Vector2(SIZE, SIZE) / 2.0 - Vector2(0.5, 0.5)
		# Primero el borde oscuro (la forma engordada 1 px), después el rojo encima.
		for pass_i in 2:
			var grow := 1.0 if pass_i == 0 else 0.0
			var col := EDGE if pass_i == 0 else RED
			for y in SIZE:
				for x in SIZE:
					var p := Vector2(x, y)
					var d := p.distance_to(c)
					var ring := absf(d - 10.0) <= 1.0 + grow
					var dx := absf(p.x - c.x)
					var dy := absf(p.y - c.y)
					var arm := (dx <= 0.5 + grow and dy >= 4.0 - grow and dy <= 15.0 + grow) \
						or (dy <= 0.5 + grow and dx >= 4.0 - grow and dx <= 15.0 + grow)
					var dot := d <= 1.2 + grow
					if ring or arm or dot:
						img.set_pixel(x, y, col)
		_tex = ImageTexture.create_from_image(img)
	return _tex
