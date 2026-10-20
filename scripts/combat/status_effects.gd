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


func _make_fx(s: StatusEffect) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = 6
	p.lifetime = 0.7
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(7, 5)
	p.position = Vector2(0, -10)
	p.direction = Vector2.UP
	p.spread = 25.0
	p.gravity = Vector2(0, -20) if s.damage_per_second > 0.0 else Vector2(0, 10)
	p.initial_velocity_min = 6.0
	p.initial_velocity_max = 14.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 1.5
	var glow := s.element.glow if s.element != null else 1.0
	p.color = Color(s.color.r * glow, s.color.g * glow, s.color.b * glow)
	p.z_index = 2
	creature.add_child(p)
	return p
