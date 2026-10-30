extends Node2D
## Partículas ambientales alrededor de la cámara (hojas, polen, motas de luz).
## Cambian según el bioma de la zona actual. De noche (DayNight) las motas son luciérnagas y titilan estrellitas
## (solo afuera: en interiores, cuevas y arenas se apagan en el acto).

## Estrellitas de noche (con oscuridad 1). Rehechas el 2026-10-30 (al usuario no le gustaban las cruces que
## brillaban con el glow): puntitos de 1 px que titilan despacio, unos pocos destellos en cruz y alguna fugaz; van
## "más arriba" que el suelo (se corren con la cámara a STAR_PARALLAX), no pegados al pasto.
const STARS := 60
const STAR_PARALLAX := 0.2
const STAR_COLORS := [Color(1.0, 1.0, 1.0), Color(0.80, 0.88, 1.0), Color(1.0, 0.93, 0.78)]
const SHOOTING_EVERY := 14.0  # segundos promedio entre estrellas fugaces

## Cantidades por bioma: [hojas, motas]
const BIOMES := {
	"pradera": [5, 18],
	"pradera_florida": [4, 26],
	"bosque": [30, 14],
	"bosque_denso": [40, 10],
	"lago": [4, 20],
	"rocoso": [2, 8],
	"humedal": [6, 30],
	"arboleda": [18, 18],
}

@export var area := Vector2(520, 320)

var _leaves: CPUParticles2D
var _motes: CPUParticles2D
## [posición base (0-1), fase, período, tipo (0 punto, 1 punto con halo, 2 destello), color] por estrella.
var _stars := []
## Cuánto se ven (0-1): sigue a la oscuridad despacio; afuera de golpe a 0.
var _star_fade := 0.0
## Estrella fugaz en curso: [desde (local), dirección, tiempo] o [].
var _shooting := []
var _rng := RandomNumberGenerator.new()
var _drawn := false


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
	for i in STARS:
		var kind := 2 if i % 9 == 0 else (1 if i % 3 == 0 else 0)
		_stars.append([Vector2(_rng.randf(), _rng.randf()), _rng.randf() * TAU, _rng.randf_range(2.5, 6.0), kind,
			STAR_COLORS[_rng.randi() % STAR_COLORS.size()]])
	Events.zone_entered.connect(_on_zone_entered)
	Events.time_changed.connect(_on_time_changed)


func _process(delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam:
		global_position = cam.get_screen_center_position()
	var dn: DayNight = get_parent().get("day_night")
	var outside: bool = dn != null and dn.casts_shadows
	var target := clampf((dn.darkness - 0.5) * 2.0, 0.0, 1.0) if outside else 0.0
	_star_fade = move_toward(_star_fade, target, delta * 0.5) if outside else 0.0
	if _star_fade > 0.0 or _drawn:
		_update_shooting(delta)
		queue_redraw()


func _draw() -> void:
	_drawn = _star_fade > 0.0
	if not _drawn:
		_shooting = []
		return
	var view := _view_size()
	var drift := global_position * STAR_PARALLAX
	var now := Time.get_ticks_msec() / 1000.0
	for s in _stars:
		var p := Vector2(fposmod(s[0].x * view.x - drift.x, view.x), fposmod(s[0].y * view.y - drift.y, view.y)) - view / 2.0
		p = p.floor()
		var b := pow(0.5 + 0.5 * sin(TAU * now / s[2] + s[1]), 3.0)
		var a := (0.25 + 0.75 * b) * _star_fade
		var c: Color = s[4]
		draw_rect(Rect2(p, Vector2.ONE), Color(c, a))
		if s[3] >= 1 and b > 0.4:
			var halo := Color(c, a * 0.35 * (b - 0.4) / 0.6)
			for o in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
				draw_rect(Rect2(p + o, Vector2.ONE), halo)
		if s[3] == 2 and b > 0.75:
			var arm := Color(c, a * 0.25 * (b - 0.75) / 0.25)
			for o in [Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2)]:
				draw_rect(Rect2(p + o, Vector2.ONE), arm)
	if not _shooting.is_empty():
		var t: float = _shooting[2]
		var head: Vector2 = _shooting[0] + _shooting[1] * t * 140.0
		var fade := sin(PI * clampf(t / 0.7, 0.0, 1.0)) * _star_fade
		for i in 12:
			draw_rect(Rect2((head - _shooting[1] * i * 1.5).floor(), Vector2.ONE), Color(1, 1, 1, fade * (1.0 - i / 12.0)))


## Lo que muestra la cámara, en píxeles del mundo.
func _view_size() -> Vector2:
	var cam := get_viewport().get_camera_2d()
	return get_viewport_rect().size / (cam.zoom if cam else Vector2.ONE)


func _update_shooting(delta: float) -> void:
	if _shooting.is_empty():
		if _rng.randf() < delta / SHOOTING_EVERY:
			var view := _view_size() / 2.0
			_shooting = [Vector2(_rng.randf_range(-view.x, view.x), _rng.randf_range(-view.y, 0.0)),
				Vector2(_rng.randf_range(-1.0, 1.0), 0.45).normalized(), 0.0]
		return
	_shooting[2] += delta
	if _shooting[2] > 0.7:
		_shooting = []


func _on_zone_entered(zone: ZoneEntry) -> void:
	var amounts: Array = BIOMES.get(zone.biome, [10, 20])
	_set_amount(_leaves, amounts[0])
	_set_amount(_motes, amounts[1])


func _on_time_changed(_hour: float, _phase: String) -> void:
	var dn: DayNight = get_parent().get("day_night")
	var dark := dn.darkness if dn != null and not dn.indoor else 0.0
	# Color > 1: el glow las hace brillar (de noche, verde amarillento y más fuerte, contra el oscurecido).
	_motes.color_ramp = _fade(Color(1.9, 1.75, 1.2, 1).lerp(Color(2.6, 3.0, 0.9, 1), dark))
	_motes.scale_amount_min = 1.0 + dark
	_motes.scale_amount_max = 1.0 + dark * 1.5


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
