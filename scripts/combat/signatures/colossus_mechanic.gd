extends SignatureMechanic
## Coloso (Onix, tanque jefe; el Onix de Brock tiene que sentirse como un BOSS):
##  · cuerpo enorme (`scale`): sprite y hurtbox más grandes; no lo empujan ni lo tambalean (`knockback_mult`);
##  · cuerpo de roca: recibe `physical_mult` del daño físico;
##  · aplasta lo atrapado: pega `stagger_bonus` más a lo que está ralentizado (Atadura y Tumba Rocas lo dejan así);
##  · segunda fase: al bajar de `phase_at` de vida ruge una vez (el ataque `roar_move`: onda que empuja y deja
##    Expuesto, con temblor de pantalla) y queda furioso (`phase_status`) hasta el final de la pelea.
## La barra muestra cuánto le falta para la segunda fase.

var _roar: MoveData
var _raged := false


func _setup() -> void:
	_roar = load(param("roar_move", "")) if param("roar_move", "") != "" else null
	creature.health.changed.connect(func(_hp, _max): _check_phase())


func _check_phase() -> void:
	if _raged or creature.is_down() or creature.health.ratio() > param("phase_at", 0.5):
		return
	_raged = true
	set_value(data.max_value)
	var s: StatusEffect = DB.statuses.get(param("phase_status", "furia_roca"))
	if s != null:
		creature.statuses.apply(s)
	if _roar != null:
		var a := AreaEffect.new()
		creature.get_parent().add_child(a)
		a.trigger(HitInfo.from(creature, _roar), creature.global_position + Vector2(0, -6))
	creature.sprite.play_once("Attack", 0.6)
	Events.camera_shake.emit(8.0)
	Events.signature_triggered.emit(creature, "¡%s RUGE!" % creature.instance.species.display_name.to_upper(), data.color)


func _tick(_delta: float) -> void:
	if not _raged:
		# Barra: cuánto falta para la furia (llena = segunda fase).
		var k := clampf((1.0 - creature.health.ratio()) / maxf(0.01, 1.0 - param("phase_at", 0.5)), 0.0, 1.0)
		set_value(data.max_value * k)
	elif not creature.statuses.has_status(param("phase_status", "furia_roca")):
		var s: StatusEffect = DB.statuses.get(param("phase_status", "furia_roca"))
		if s != null and not creature.is_down():
			creature.statuses.apply(s)  # la furia dura toda la pelea


func damage_taken_mult(hit: HitInfo) -> float:
	return param("physical_mult", 0.75) if hit.move.category == MoveData.Category.PHYSICAL else 1.0


func damage_mult_against(_hit: HitInfo, target: Creature) -> float:
	return param("stagger_bonus", 1.3) if target.statuses.has_status("ralentizado") else 1.0


func knockback_taken_mult() -> float:
	return param("knockback_mult", 0.0)


func body_scale() -> float:
	return param("scale", 1.4)


func state_label() -> String:
	return "FURIA DE ROCA" if _raged else ""
