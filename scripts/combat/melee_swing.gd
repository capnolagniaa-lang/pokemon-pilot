class_name MeleeSwing
extends Hitbox
## Golpe cuerpo a cuerpo: un instante de hitbox delante del atacante, con un arco de corte visible.

const LIFETIME := 0.12

var radius := 11.0
var direction := Vector2.RIGHT
var color := Color.WHITE
var _time := 0.0


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


func _physics_process(delta: float) -> void:
	_time += delta
	if _time > 0.06 and monitoring:
		set_deferred("monitoring", false)
	if _time >= LIFETIME:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var k := clampf(_time / LIFETIME, 0.0, 1.0)
	var a := direction.angle()
	draw_arc(-direction * radius * 0.4, radius, a - 1.1, a + 1.1, 12, Color(color, 1.0 - k), 2.0)
	draw_arc(-direction * radius * 0.4, radius * 0.75, a - 0.9, a + 0.9, 10, Color(color, 0.6 * (1.0 - k)), 1.0)
