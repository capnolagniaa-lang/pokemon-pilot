class_name StatusEffects
extends Node
## Estados alterados activos de una criatura: duración, stacks, barra de acumulación, daño por tiempo,
## multiplicadores y partículas. Las interacciones con elementos las resuelve Creature (StatusInteraction).

## id -> {"status": StatusEffect, "time": float, "stacks": int, "meter": float, "fx": CPUParticles2D}
var active: Dictionary = {}
var _dot_accum := 0.0
var _dot_timer := 0.0

@onready var creature = get_parent()


## Aplica (o refuerza) un estado. `duration_mult` alarga o acorta la duración de esta aplicación.
func apply(s: StatusEffect, duration_mult: float = 1.0) -> void:
	var fresh := not active.has(s.id)
	if fresh:
		active[s.id] = {"status": s, "time": 0.0, "stacks": 0, "meter": 0.0, "fx": _make_fx(s)}
	var e: Dictionary = active[s.id]
	if s.buildup:
		e["meter"] += s.buildup_per_apply
		e["time"] = INF
		if e["meter"] >= 1.0:
			e["meter"] = 0.0
			creature.stun(s.stun_time, true)
			cure(s)
			return
	else:
		e["stacks"] = mini(e["stacks"] + 1, s.max_stacks)
		e["time"] = maxf(e["time"], s.duration * duration_mult)
	if not s.can_act:
		creature.stun(e["time"], s.is_cc)
	if fresh or s.max_stacks > 1:
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


## Al recibir daño: los estados que se curan con daño (Dormido) se van.
func on_damaged() -> void:
	for id in active.keys():
		if active[id]["status"].wake_on_damage:
			cure(active[id]["status"])


func extend(s: StatusEffect, mult: float) -> void:
	if active.has(s.id) and active[s.id]["time"] != INF:
		active[s.id]["time"] *= mult


func has_status(id: String) -> bool:
	return active.has(id)


func stacks(id: String) -> int:
	return active[id]["stacks"] if active.has(id) else 0


## Barra de acumulación (0..1) de un estado como Paralizado.
func meter(id: String) -> float:
	return active[id]["meter"] if active.has(id) else 0.0


func can_act() -> bool:
	for id in active:
		if not active[id]["status"].can_act:
			return false
	return true


func can_move() -> bool:
	for id in active:
		var s: StatusEffect = active[id]["status"]
		if not s.can_move or not s.can_act:
			return false
	return true


func speed_mult() -> float:
	return _product("speed_mult")


## Multiplica el daño físico que hace (Quemado).
func attack_mult() -> float:
	return _product("attack_mult")


func heal_mult() -> float:
	return _product("heal_mult")


## Multiplica el daño que recibe (Arraigo).
func damage_taken_mult() -> float:
	return _product("damage_taken_mult")


## Multiplica el empuje que recibe (0 = inamovible).
func knockback_mult() -> float:
	return _product("knockback_mult")


## Desvío máximo de apuntado/movimiento en radianes (Desorientado).
func aim_jitter() -> float:
	var j := 0.0
	for id in active:
		j = maxf(j, active[id]["status"].aim_jitter_deg)
	return deg_to_rad(j)


func _product(prop: String) -> float:
	var m := 1.0
	for id in active:
		m *= active[id]["status"].get(prop)
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
		if s.buildup:
			entry["meter"] -= s.buildup_decay * delta
			if entry["meter"] <= 0.0:
				cure(s)
			continue
		entry["time"] -= delta
		if s.heal_per_second > 0.0:
			creature.health.heal(creature.health.max_hp() * s.heal_per_second * delta)
		if s.damage_per_second > 0.0:
			_dot_accum += creature.health.max_hp() * s.damage_per_second * entry["stacks"] * delta
		if entry["time"] <= 0.0:
			cure(s)
	# El daño por tiempo se aplica de a un número por segundo (no spamea la pantalla).
	_dot_timer += delta
	if _dot_timer >= 1.0:
		_dot_timer = 0.0
		if _dot_accum > 0.0:
			creature.take_status_damage(_dot_accum)
			_dot_accum = 0.0


## Partículas (y luz opcional) del estado, configuradas desde el StatusEffect.
func _make_fx(s: StatusEffect) -> CPUParticles2D:
	var el := s.element
	var p := CPUParticles2D.new()
	p.amount = maxi(1, s.fx_amount)
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
	p.emitting = s.fx_amount > 0
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
