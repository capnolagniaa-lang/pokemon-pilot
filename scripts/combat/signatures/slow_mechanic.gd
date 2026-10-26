extends SignatureMechanic
## Reacción Tardía (Slowpoke, tanque despistado; docs/PROPUESTA_KITS_PENDIENTES.md): reacciona tarde, como en el anime.
##  · De cada golpe recibe ahora solo `now_part`; el resto le llega `delay` s después, salvo que en ese tiempo él
##    conecte un golpe: ahí "se olvida" de lo pendiente.
##  · Cuando le pone al rival el estado `yawn_status` (Bostezo), si a los `yawn_delay` s lo sigue teniendo, se duerme.
## La barra muestra el daño pendiente.

var _pending := 0.0
var _pending_time := 0.0


func _setup() -> void:
	creature.hit_dealt.connect(_on_hit_dealt)
	creature.damage_received.connect(_on_damage)
	creature.status_inflicted.connect(func(target, st): if st != null and st.id == param("yawn_status", ""): _yawn(target))


func _can_decay() -> bool:
	return false


func damage_taken_mult(_hit: HitInfo) -> float:
	return param("now_part", 0.7)


func _on_damage(amount: float, hit: HitInfo) -> void:
	if hit == null or amount <= 0.0:
		return  # el daño diferido mismo (sin HitInfo) no se vuelve a diferir
	var part: float = param("now_part", 0.7)
	_pending += amount / part * (1.0 - part)
	_pending_time = param("delay", 2.0)
	set_value(minf(data.max_value, _pending / maxf(1.0, creature.health.max_hp()) * data.max_value * 3.0))


func _on_hit_dealt(_target: Creature, hit: HitInfo, dealt: float) -> void:
	if hit == null or hit.move == null:
		return
	if dealt > 0.0 and _pending > 0.0:
		_pending = 0.0
		set_value(0.0)
		Events.signature_triggered.emit(creature, "...¿qué me pasó?", data.color)


func _yawn(target: Node) -> void:
	await creature.get_tree().create_timer(param("yawn_delay", 2.0)).timeout
	if is_instance_valid(target) and not target.is_down() and target.statuses.has_status(param("yawn_status", "")):
		var sleep: StatusEffect = DB.statuses.get("dormido")
		if sleep != null:
			target.statuses.apply(sleep)


func _tick(delta: float) -> void:
	if _pending_time <= 0.0:
		return
	_pending_time -= delta
	if _pending_time <= 0.0 and _pending > 0.0 and not creature.is_down():
		var d := _pending
		_pending = 0.0
		set_value(0.0)
		creature.health.apply_damage(d)
		Events.signature_triggered.emit(creature, "¡Ay! (tarde)", data.color)


func state_label() -> String:
	return "TARDE..." if _pending > 0.0 else ""
