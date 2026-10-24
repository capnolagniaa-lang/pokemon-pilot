class_name SkyStrike
extends Node2D
## Golpe desde el cielo (MoveData.zone_strike): marca un círculo en el suelo, y a los `strike_delay` segundos cae
## y golpea una sola vez a los enemigos que siguen adentro. Eléctrico = un rayo (Rayo de Pikachu); cualquier otro
## elemento = piedras que caen (Tumba Rocas de Onix). Con `burrower` (Excavar, MoveData.strike_burrow) no cae nada:
## el que lo usó se mete bajo tierra, el suelo se agrieta donde va a salir y emerge ahí golpeando alrededor.

const BOLT_TIME := 0.28
const BOLT_HEIGHT := 150.0
const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")

var hit: HitInfo
var radius := 30.0
var delay := 0.3
var color := Color.WHITE
var _time := 0.0
var _struck := false
var _bolt: PackedVector2Array = []
var burrower: Creature
var _cracks: Array = []  # [ángulo, largo] de las grietas de Excavar


func strike(p_hit: HitInfo, center: Vector2, extra_delay: float = 0.0, p_burrower: Creature = null) -> void:
	hit = p_hit
	var m := p_hit.move
	global_position = center
	radius = m.zone_radius * p_hit.area_mult
	delay = m.strike_delay + extra_delay
	color = m.element.color
	z_index = -5
	burrower = p_burrower
	if burrower != null:
		for i in 7:
			_cracks.append([randf() * TAU, randf_range(0.5, 1.0)])
		# Se mete bajo tierra: no se ve, no lo pueden golpear y no actúa hasta salir.
		Fx.burst(get_parent(), burrower.global_position, Color(0.55, 0.45, 0.35), 16, 60.0)
		burrower.health.invulnerable_time = maxf(burrower.health.invulnerable_time, delay + 0.15)
		burrower.sprite.visible = false
		burrower.stun(delay)
		Events.camera_shake.emit(2.0)


func _physics_process(delta: float) -> void:
	_time += delta
	if not _struck and _time >= delay:
		_struck = true
		_fall()
	if _time >= delay + BOLT_TIME:
		queue_free()
	queue_redraw()


func _fall() -> void:
	if is_instance_valid(burrower):
		burrower.global_position = global_position
		burrower.sprite.visible = true
		burrower.knockback = Vector2.ZERO
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.team == hit.team or c.is_down() or c.global_position.distance_to(global_position) > radius:
			continue
		hit.origin = global_position
		c.hurtbox.receive(hit)
	# Rayo quebrado del cielo al centro.
	var y := -BOLT_HEIGHT
	_bolt.append(Vector2(randf_range(-6, 6), y))
	while y < -10.0:
		y += randf_range(14.0, 24.0)
		_bolt.append(Vector2(randf_range(-9, 9), minf(y, 0.0)))
	_bolt.append(Vector2.ZERO)
	if not _is_bolt():
		_bolt.clear()
	var light := PointLight2D.new()
	light.texture = LIGHT_TEX
	light.color = color
	light.energy = 0.35
	light.texture_scale = radius / 32.0
	add_child(light)
	light.create_tween().tween_property(light, "energy", 0.0, BOLT_TIME)
	Events.element_impact.emit(hit.move.element, global_position, radius)
	if hit.move.crater_radius > 0.0:
		Events.ground_impact.emit(global_position, hit.move.crater_radius, HitInfo.source_key(hit), hit.move.crater_max)
	Events.camera_shake.emit(6.0 if burrower != null else 3.0)
	Fx.burst(get_parent(), global_position, hit.move.element.hdr(color), 18, radius * 2.0)
	if burrower != null or not _is_bolt():
		Fx.burst(get_parent(), global_position, Color(0.55, 0.45, 0.35), 26, radius * 3.0)  # polvo y piedras


func _is_bolt() -> bool:
	return hit != null and hit.move.element.id == "electrico"


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.75))
	if not _struck:
		# Aviso: el círculo se va llenando hasta que cae el rayo.
		var k := clampf(_time / maxf(delay, 0.01), 0.0, 1.0)
		draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, 0.12 + 0.12 * k))
		draw_circle(Vector2.ZERO, radius * k, Color(color.r, color.g, color.b, 0.25))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(color.r * 1.3, color.g * 1.3, color.b * 1.3, 0.9), 1.5)
		if burrower != null:
			# Grietas que crecen y tiemblan donde va a salir.
			var shake := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 1.5 * k
			for cr in _cracks:
				var end: Vector2 = Vector2.from_angle(cr[0]) * radius * cr[1] * k
				var mid: Vector2 = end * 0.5 + end.orthogonal().normalized() * 3.0
				draw_polyline(PackedVector2Array([shake, mid + shake, end + shake]), Color(0.25, 0.18, 0.12, 0.9), 2.0)
		elif not _is_bolt():
			# Piedras cayendo hacia el círculo.
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			for i in 3:
				var off := Vector2(cos(i * 2.1) * radius * 0.5, sin(i * 2.1) * radius * 0.35)
				var p := off + Vector2(0, -BOLT_HEIGHT * (1.0 - k))
				draw_circle(p, 5.0, Color(0.42, 0.36, 0.3, 0.95))
				draw_circle(p + Vector2(-1.4, -1.4), 2.2, Color(0.66, 0.6, 0.52, 0.95))
		return
	var fade := clampf(1.0 - (_time - delay) / BOLT_TIME, 0.0, 1.0)
	draw_circle(Vector2.ZERO, radius, Color(color.r * 1.4, color.g * 1.4, color.b * 1.4, 0.45 * fade))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _bolt.size() > 1:
		draw_polyline(_bolt, Color(color.r * 1.5, color.g * 1.5, color.b * 1.2, 0.6 * fade), 5.0)
		draw_polyline(_bolt, Color(1.6, 1.6, 1.4, fade), 2.0)
