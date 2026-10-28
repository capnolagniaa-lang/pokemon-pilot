class_name ChannelCone
extends Hitbox
## Cono canalizado (Lanzallamas): golpea a todo lo que esté adentro cada `tick_interval` mientras dure.
## Lo maneja el estado "channel" de la criatura (que lo orienta y lo apaga).

const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")

var direction := Vector2.RIGHT
var _tick := 0.0
var _flames: CPUParticles2D
var _poly: CollisionPolygon2D


func open(p_hit: HitInfo) -> void:
	setup(p_hit, false)
	var m := p_hit.move
	var half := deg_to_rad(m.cone_angle_deg * 0.5)
	var length := m.cone_length * p_hit.area_mult
	_poly = CollisionPolygon2D.new()
	var pts := PackedVector2Array([Vector2.ZERO])
	for k in 7:
		pts.append(Vector2.RIGHT.rotated(lerpf(-half, half, k / 6.0)) * length)
	_poly.polygon = pts
	add_child(_poly)
	_flames = CPUParticles2D.new()
	_flames.amount = 70
	_flames.lifetime = 0.35
	_flames.texture = StatusEffects._flame_texture()
	_flames.direction = Vector2.RIGHT
	_flames.spread = rad_to_deg(half) * 0.8
	_flames.gravity = Vector2(0, -30)
	_flames.initial_velocity_min = length / 0.4
	_flames.initial_velocity_max = length / 0.3
	_flames.scale_amount_min = 1.2
	_flames.scale_amount_max = 3.0
	_flames.local_coords = false
	var el := m.element
	var ramp := Gradient.new()
	ramp.set_color(0, el.hdr(el.core_color))
	ramp.add_point(0.35, el.hdr(el.color))
	ramp.set_color(1, Color(0.35, 0.08, 0.04, 0.0))
	_flames.color_ramp = ramp
	_flames.z_index = 4
	add_child(_flames)
	var light := PointLight2D.new()
	light.texture = LIGHT_TEX
	light.color = el.color
	light.energy = 0.35
	light.texture_scale = length / 40.0
	light.position = Vector2(length * 0.5, 0)
	add_child(light)
	z_index = 3
	NightLight.apply(self)  # día y noche: no se oscurece con la noche y su luz crece (docs/PLAN_DIA_NOCHE.md)

func aim(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	_tick -= delta
	if _tick <= 0.0 and hit != null:
		_tick = hit.move.tick_interval
		for a in get_overlapping_areas():
			if a is Hurtbox:
				hit.origin = global_position
				a.receive(hit)


## Deja de quemar y se borra cuando terminan de caer las últimas llamas.
func close() -> void:
	set_deferred("monitoring", false)
	hit = null
	_flames.emitting = false
	get_tree().create_timer(0.4).timeout.connect(queue_free)


## Solo golpea en los ticks (no al entrar).
func _on_area_entered(_area: Area2D) -> void:
	pass
