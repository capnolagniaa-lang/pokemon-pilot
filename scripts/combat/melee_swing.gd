class_name MeleeSwing
extends Hitbox
## Golpe cuerpo a cuerpo: un instante de hitbox delante del atacante, con un arco de corte visible.

const LIFETIME := 0.12

var radius := 11.0
var direction := Vector2.RIGHT
var color := Color.WHITE
var _time := 0.0
## Corte con sprite (DB.vfx_for): no se dibujan los arcos.
var _has_vfx := false


func swing(p_hit: HitInfo, center: Vector2, p_radius: float, dir: Vector2) -> void:
	setup(p_hit, false)
	global_position = center
	radius = p_radius
	direction = dir.normalized()
	var el := p_hit.move.element
	color = el.hdr(el.core_color, 1.1)
	var shape := CircleShape2D.new()
	shape.radius = radius
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	z_index = 3
	var frames := DB.vfx_for(p_hit.move)
	if frames != null:
		_has_vfx = true
		VfxSprite.burst(get_parent(), frames, center, direction.angle())
	NightLight.apply(self)  # día y noche: no se oscurece con la noche y su luz crece (docs/PLAN_DIA_NOCHE.md)

func _physics_process(delta: float) -> void:
	_time += delta
	if _time > 0.06 and monitoring:
		set_deferred("monitoring", false)
	if _time >= LIFETIME:
		queue_free()
	queue_redraw()


func _draw() -> void:
	if _has_vfx:
		return
	var k := clampf(_time / LIFETIME, 0.0, 1.0)
	var a := direction.angle()
	draw_arc(-direction * radius * 0.4, radius, a - 1.1, a + 1.1, 12, Color(color, 1.0 - k), 2.0)
	draw_arc(-direction * radius * 0.4, radius * 0.75, a - 0.9, a + 0.9, 10, Color(color, 0.6 * (1.0 - k)), 1.0)
