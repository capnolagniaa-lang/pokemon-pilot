class_name StatusEffects
extends Node
## Estados alterados activos de una criatura: duración, daño por tiempo, parálisis, congelamiento y partículas.

## id -> {"status": StatusEffect, "time": float, "fx": CPUParticles2D}
var active: Dictionary = {}
var _dot_accum := 0.0
var _dot_timer := 0.0

@onready var creature = get_parent()


func apply(s: StatusEffect) -> void:
	if active.has(s.id):
		active[s.id]["time"] = s.duration
		return
	active[s.id] = {"status": s, "time": s.duration, "fx": _make_fx(s)}
	if not s.can_act:
		creature.stun(s.duration)
	Events.status_applied.emit(creature, s)


func cure(s: StatusEffect) -> void:
	if not active.has(s.id):
		return
	var fx: Node = active[s.id]["fx"]
	if is_instance_valid(fx):
		fx.queue_free()
	active.erase(s.id)
	Events.status_removed.emit(creature, s)


func clear() -> void:
	for id in active.keys():
		cure(active[id]["status"])


## Al recibir un golpe: algunos estados se curan con ciertos elementos (el fuego descongela).
func on_hit(hit: HitInfo) -> void:
	for id in active.keys():
		var s: StatusEffect = active[id]["status"]
		if hit.move.element in s.cured_by:
			cure(s)


func has_status(id: String) -> bool:
	return active.has(id)


func can_act() -> bool:
	for id in active:
		if not active[id]["status"].can_act:
			return false
	return true


func speed_mult() -> float:
	var m := 1.0
	for id in active:
		m *= active[id]["status"].speed_mult
	return m


func attack_mult() -> float:
	var m := 1.0
	for id in active:
		m *= active[id]["status"].attack_mult
	return m


## Color del estado más reciente (para teñir el sprite e indicarlo en la interfaz).
func tint() -> Color:
	var c := Color.WHITE
	for id in active:
		c = active[id]["status"].color
	return c


func tint_strength() -> float:
	var t := 0.0
	for id in active:
		t = active[id]["status"].tint_strength
	return t


func _physics_process(delta: float) -> void:
	if active.is_empty() or creature.health.is_dead():
		return
	for id in active.keys():
		var entry: Dictionary = active[id]
		var s: StatusEffect = entry["status"]
		entry["time"] -= delta
		if s.damage_per_second > 0.0:
			_dot_accum += creature.health.max_hp() * s.damage_per_second * delta
		if s.stun_chance_per_second > 0.0 and randf() < s.stun_chance_per_second * delta:
			creature.stun(s.stun_time)
		if entry["time"] <= 0.0:
			cure(s)
	# El daño por tiempo se aplica de a un número por segundo (no spamea la pantalla).
	_dot_timer += delta
	if _dot_timer >= 1.0 and _dot_accum > 0.0:
		_dot_timer = 0.0
		creature.take_status_damage(_dot_accum)
		_dot_accum = 0.0


## Partículas (y luz opcional) del estado, configuradas desde el StatusEffect.
func _make_fx(s: StatusEffect) -> CPUParticles2D:
	var el := s.element
	var p := CPUParticles2D.new()
	p.amount = s.fx_amount
	p.lifetime = 0.65
	p.texture = _flame_texture() if s.fx_gravity < 0.0 else null
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(7, 6)
	p.position = Vector2(0, -9)
	p.direction = Vector2.UP if s.fx_gravity < 0.0 else Vector2.DOWN
	p.spread = 30.0 if s.fx_gravity != 0.0 else 180.0
	p.gravity = Vector2(0, s.fx_gravity)
	p.initial_velocity_min = 4.0
	p.initial_velocity_max = 14.0 if s.fx_gravity != 0.0 else 30.0
	p.scale_amount_min = s.fx_size * 0.6
	p.scale_amount_max = s.fx_size
	var ramp := Gradient.new()
	var core := el.hdr(el.core_color) if el != null else s.color
	var body := el.hdr(s.color) if el != null else s.color
	ramp.set_color(0, core)
	ramp.set_color(1, Color(body.r * 0.5, body.g * 0.3, body.b * 0.3, 0.0))
	ramp.add_point(0.45, body)
	p.color_ramp = ramp
	p.z_index = 2
	creature.add_child(p)
	if s.fx_light:
		var light := PointLight2D.new()
		light.texture = preload("res://art/fx/soft_shadow.tres")
		light.color = s.color
		light.energy = 0.22
		light.texture_scale = 0.45
		p.add_child(light)
		var tw := light.create_tween().set_loops()
		tw.tween_property(light, "energy", 0.1, 0.09)
		tw.tween_property(light, "energy", 0.26, 0.13)
	return p


static var _flame: Texture2D


## Llamita de 3x5 píxeles (más ancha abajo) para las partículas de la quemadura.
static func _flame_texture() -> Texture2D:
	if _flame == null:
		var img := Image.create(3, 5, false, Image.FORMAT_RGBA8)
		for p in [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2),
				Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(1, 4)]:
			img.set_pixelv(p, Color.WHITE)
		_flame = ImageTexture.create_from_image(img)
	return _flame
