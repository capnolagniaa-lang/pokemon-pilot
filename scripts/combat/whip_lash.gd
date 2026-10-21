class_name WhipLash
extends Hitbox
## Latigazo en línea (Látigo Cepa): sale hasta `whip_length` y agarra al PRIMER enemigo que alcanza
## (los estados del ataque lo enraízan y el empuje negativo lo atrae hacia el atacante).

const EXTEND_TIME := 0.1
const RETRACT_TIME := 0.25

var length := 70.0
var direction := Vector2.RIGHT
var color := Color(0.35, 0.65, 0.2)
var _time := 0.0
var _grabbed: Area2D
var _grab_dist := 0.0


func lash(p_hit: HitInfo, from: Vector2, dir: Vector2) -> void:
	setup(p_hit, false)
	var m := p_hit.move
	global_position = from
	direction = dir.normalized()
	rotation = direction.angle()
	length = m.whip_length
	color = m.element.color.darkened(0.15)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(length, m.whip_width)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(length / 2.0, 0.0)
	add_child(col)
	z_index = 3


## Agarra solo al primero.
func _on_area_entered(area: Area2D) -> void:
	if _grabbed != null or not area is Hurtbox:
		return
	_grabbed = area
	_grab_dist = global_position.distance_to(area.global_position)
	set_deferred("monitoring", false)
	area.receive(hit)
	hit_landed.emit(area)


func _physics_process(delta: float) -> void:
	_time += delta
	if _time > EXTEND_TIME and monitoring:
		set_deferred("monitoring", false)
	if _time >= EXTEND_TIME + RETRACT_TIME:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var reach := length
	if _grabbed != null and is_instance_valid(_grabbed):
		reach = minf(length, to_local(_grabbed.global_position).x)
	var k: float = clampf(_time / EXTEND_TIME, 0.0, 1.0) if _time < EXTEND_TIME else 1.0 - clampf((_time - EXTEND_TIME) / RETRACT_TIME, 0.0, 1.0)
	var tip := Vector2(reach * k, 0.0)
	draw_line(Vector2.ZERO, tip, color.darkened(0.3), 3.0)
	draw_line(Vector2.ZERO, tip, color, 1.5)
	for i in int(reach * k / 10.0):  # hojitas a lo largo del látigo
		var p := Vector2(i * 10.0 + 5.0, -2.0 if i % 2 == 0 else 2.0)
		draw_circle(p, 1.5, color.lightened(0.2))
	draw_circle(tip, 2.0, color.lightened(0.3))
