class_name Fx
extends RefCounted
## Efectos de partículas de un solo uso (chispas de impacto, polvo, etc.).


static func burst(parent: Node, at: Vector2, color: Color, amount: int = 10, speed: float = 60.0) -> void:
	if parent == null:
		return
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = amount
	p.lifetime = 0.35
	p.explosiveness = 0.95
	p.spread = 180.0
	p.gravity = Vector2(0, 40)
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.0
	var ramp := Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color, 0.0))
	p.color_ramp = ramp
	p.z_index = 4
	parent.add_child(p)
	p.global_position = at
	p.emitting = true
	p.finished.connect(p.queue_free)
