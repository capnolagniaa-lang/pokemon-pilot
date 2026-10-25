extends SignatureMechanic
## Núcleo (Staryu y Starmie; Starmie es la jefa de Misty, como Onix con Brock):
##  · girando (`spin_move`, Giro Rápido) desvía los proyectiles rivales que lo tocan (`deflect_radius`);
##  · le pega `wet_bonus` más a lo que está Empapado (Pistola Agua / Hidropulso lo dejan así);
##  · la barra sube al pegar y al recibir: llena, el núcleo se regenera (cura `core_heal` de la vida) y vuelve a 0;
##  · jefa (`phase_at` > 0): cuerpo más grande (`scale`), casi no la empujan (`knockback_mult`) y al bajar de
##    `phase_at` de vida el núcleo brilla una vez: lanza `pulse_move` (onda que empuja y moja) y queda con
##    `phase_status` hasta el final de la pelea.

var _pulse: MoveData
var _phased := false
## Tiempo que le queda girando (lo arranca soltar el ataque de giro).
var _spin_time := 0.0


func _setup() -> void:
	_pulse = load(param("pulse_move", "")) if param("pulse_move", "") != "" else null
	if param("phase_at", 0.0) > 0.0:
		creature.health.changed.connect(func(_hp, _max): _check_phase())


func _on_move_released(m: MoveData) -> void:
	if m.id.begins_with(param("spin_move", "giro_rapido")):
		_spin_time = m.dash_time + 0.05


func _tick(delta: float) -> void:
	if _spin_time > 0.0:
		_spin_time -= delta
		Projectile.deflect_around(creature.get_parent(), creature.team, creature.global_position,
			param("deflect_radius", 20.0))
	if _phased and not creature.statuses.has_status(param("phase_status", "")):
		var s: StatusEffect = DB.statuses.get(param("phase_status", ""))
		if s != null and not creature.is_down():
			creature.statuses.apply(s)  # el brillo dura toda la pelea


func _on_value_changed(_before: float) -> void:
	if value < data.max_value or creature.is_down():
		return
	var healed := creature.health.heal(creature.health.max_hp() * param("core_heal", 0.1))
	set_value(0.0)
	if healed > 0.0:
		Events.signature_triggered.emit(creature, "¡Núcleo regenerado!", data.color)


func _check_phase() -> void:
	if _phased or creature.is_down() or creature.health.ratio() > param("phase_at", 0.5):
		return
	_phased = true
	var s: StatusEffect = DB.statuses.get(param("phase_status", ""))
	if s != null:
		creature.statuses.apply(s)
	if _pulse != null:
		var a := AreaEffect.new()
		creature.get_parent().add_child(a)
		a.trigger(HitInfo.from(creature, _pulse), creature.global_position + Vector2(0, -6))
	Events.camera_shake.emit(7.0)
	Events.signature_triggered.emit(creature, "¡EL NÚCLEO DE %s BRILLA!" % creature.instance.species.display_name.to_upper(),
		data.color)


func damage_mult_against(_hit: HitInfo, target: Creature) -> float:
	return param("wet_bonus", 1.25) if target.statuses.has_status("empapado") else 1.0


func knockback_taken_mult() -> float:
	return param("knockback_mult", 1.0)


func body_scale() -> float:
	return param("scale", 1.0)


func state_label() -> String:
	if _spin_time > 0.0:
		return "GIRANDO"
	return "NÚCLEO BRILLANTE" if _phased else ""
