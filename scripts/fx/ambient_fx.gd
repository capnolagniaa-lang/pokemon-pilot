extends Node2D
## Partículas ambientales alrededor de la cámara (hojas, polen, motas de luz).
## Cambian según el bioma de la zona actual.

## Cantidades por bioma: [hojas, motas]
const BIOMES := {
	"pradera": [5, 18],
	"bosque": [30, 14],
}

@export var area := Vector2(520, 320)

var _leaves: CPUParticles2D
var _motes: CPUParticles2D


func _ready() -> void:
	_leaves = _make(_leaf_texture(), 30, 6.0)
	_leaves.gravity = Vector2(12, 14)
	_leaves.initial_velocity_min = 4.0
	_leaves.initial_velocity_max = 12.0
	_leaves.angular_velocity_min = -90.0
	_leaves.angular_velocity_max = 90.0
	_leaves.angle_min = 0.0
	_leaves.angle_max = 360.0
	_leaves.color_ramp = _fade(Color(1, 1, 1, 1))
	_motes = _make(_dot_texture(), 30, 5.0)
	_motes.gravity = Vector2(0, -3)
	_motes.initial_velocity_min = 2.0
	_motes.initial_velocity_max = 6.0
	# Color > 1: el glow las hace brillar.
	_motes.color_ramp = _fade(Color(1.9, 1.75, 1.2, 1))
	Events.zone_entered.connect(_on_zone_entered)


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam:
		global_position = cam.get_screen_center_position()


func _on_zone_entered(zone: ZoneEntry) -> void:
	var amounts: Array = BIOMES.get(zone.biome, [10, 20])
	_set_amount(_leaves, amounts[0])
	_set_amount(_motes, amounts[1])


func _set_amount(p: CPUParticles2D, amount: int) -> void:
	p.emitting = amount > 0
	if amount > 0 and p.amount != amount:
		p.amount = amount


func _make(tex: Texture2D, amount: int, life: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = tex
	p.amount = amount
	p.lifetime = life
	p.preprocess = life
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = area / 2.0
	p.local_coords = false
	p.direction = Vector2(1, 0.3)
	p.spread = 40.0
	add_child(p)
	return p


func _fade(c: Color) -> Gradient:
	var g := Gradient.new()
	g.set_color(0, Color(c, 0.0))
	g.set_color(1, Color(c, 0.0))
	g.add_point(0.2, c)
	g.add_point(0.8, c)
	return g


func _leaf_texture() -> Texture2D:
	var img := Image.create(4, 3, false, Image.FORMAT_RGBA8)
	var dark := Color8(72, 136, 56)
	var light := Color8(128, 196, 88)
	for p in [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(3, 1), Vector2i(1, 2), Vector2i(2, 2)]:
		img.set_pixelv(p, dark)
	img.set_pixel(1, 1, light)
	img.set_pixel(2, 1, light)
	return ImageTexture.create_from_image(img)


func _dot_texture() -> Texture2D:
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	return ImageTexture.create_from_image(img)
