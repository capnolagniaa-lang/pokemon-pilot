extends SignatureMechanic
## Calor (Charmander): sube al pegar y al recibir daño; baja lento fuera de combate.
##  · Desde `burn_threshold` (50): sus ataques aplican Quemado.
##  · Al llegar al máximo: **Mar Llamas** por `blaze_duration` s (más daño, áreas más grandes, regenera).
##  · Al terminar: **Sobrecalentado** por `overheat_duration` s (más lento) y el Calor vuelve a 0.
## La definitiva (Lanzallamas) consume todo el Calor y escala con él: ¿lo gasto ahora o espero Mar Llamas?

var blaze_left := 0.0
var overheat_left := 0.0
var _aura: CPUParticles2D


func _setup() -> void:
	_aura = CPUParticles2D.new()
	_aura.amount = 22
	_aura.lifetime = 0.55
	_aura.texture = StatusEffects._flame_texture()
	_aura.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_aura.emission_rect_extents = Vector2(9, 5)
	_aura.position = Vector2(0, -6)
	_aura.direction = Vector2.UP
	_aura.spread = 25.0
	_aura.gravity = Vector2(0, -60)
	_aura.initial_velocity_min = 6.0
	_aura.initial_velocity_max = 18.0
	_aura.scale_amount_min = 1.2
	_aura.scale_amount_max = 2.2
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.4, 0.75, 0.3))
	ramp.add_point(0.4, Color(1.2, 0.32, 0.1))
	ramp.set_color(1, Color(0.5, 0.1, 0.05, 0.0))
	_aura.color_ramp = ramp
	_aura.z_index = 1
	_aura.emitting = false
	creature.add_child.call_deferred(_aura)


func is_blazing() -> bool:
	return blaze_left > 0.0


func is_overheated() -> bool:
	return overheat_left > 0.0


func _can_gain() -> bool:
	return not is_blazing() and not is_overheated()


func _can_decay() -> bool:
	return not is_blazing()


func _on_value_changed(_before: float) -> void:
	if value >= data.max_value and not is_blazing() and not is_overheated():
		blaze_left = param("blaze_duration", 6.0)
		_aura.emitting = true
		Events.signature_triggered.emit(creature, "¡Mar Llamas!", Color(1.6, 0.6, 0.2))
		Events.camera_shake.emit(4.0)


func _tick(delta: float) -> void:
	if is_blazing():
		blaze_left -= delta
		value = data.max_value * maxf(0.0, blaze_left) / param("blaze_duration", 6.0)
		changed.emit(value)
		creature.health.heal(creature.health.max_hp() * param("blaze_regen", 0.015) * delta)
		if blaze_left <= 0.0:
			blaze_left = 0.0
			value = 0.0
			changed.emit(value)
			_aura.emitting = false
			overheat_left = param("overheat_duration", 3.0)
			Events.signature_triggered.emit(creature, "Sobrecalentado", Color(0.8, 0.5, 0.4))
	elif is_overheated():
		overheat_left = maxf(0.0, overheat_left - delta)


func modify_hit(hit: HitInfo) -> void:
	if is_blazing():
		hit.damage_mult *= param("blaze_damage_mult", 1.25)
		hit.area_mult *= param("blaze_area_mult", 1.6)
	if is_blazing() or value >= param("burn_threshold", 50.0):
		hit.extra_status = DB.statuses.get("quemado")
		hit.extra_status_chance = 1.0


func speed_mult() -> float:
	return param("overheat_speed", 0.7) if is_overheated() else 1.0


func state_label() -> String:
	if is_blazing():
		return "MAR LLAMAS"
	if is_overheated():
		return "SOBRECALENTADO"
	if value >= param("burn_threshold", 50.0):
		return "QUEMA"
	return ""
