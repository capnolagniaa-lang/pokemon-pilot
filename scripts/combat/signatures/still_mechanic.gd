extends SignatureMechanic
## Quieto y listo (genérica por parámetros; docs/PROPUESTA_KITS_PENDIENTES.md): si se queda quieto `still_time` s
## entra en postura (la barra llena) y moverse la pierde. Lo usan:
##  · Enroscarse (Ekans): el próximo golpe sale como un resorte: `burst_mult` de daño y un envión hacia adelante
##    (`burst_push`); gasta la postura.
##  · Ancla (Horsea): mientras está anclado sus disparos pegan `anchored_mult` más y no lo empujan.
##  · Camuflaje (Voltorb): quieto se ve como una Poké Ball (`camo_alpha`); el próximo golpe es crítico.
## `consume_on_hit` = el primer golpe gasta la postura (Ekans, Voltorb); si no, dura mientras no se mueva (Horsea).
## `selfdestruct_move` (prefijo de id): al soltar ese ataque queda con 1 de vida y aturdido `selfdestruct_stun` s
## (Autodestrucción de Voltorb: explota sin debilitarse, decisión 2026-10-26).

var _still := 0.0


func _on_move_released(m: MoveData) -> void:
	var prefix: String = param("selfdestruct_move", "")
	if prefix == "" or not m.id.begins_with(prefix):
		return
	creature.instance.hp = minf(creature.instance.hp, 1.0)
	creature.health.changed.emit(creature.instance.hp, creature.instance.max_hp())
	creature.stun(param("selfdestruct_stun", 2.0))


func _tick(delta: float) -> void:
	if creature.velocity.length() < 6.0 and not creature.is_down():
		_still += delta
	else:
		_still = 0.0
		if value > 0.0:
			set_value(0.0)
	if _still >= param("still_time", 0.8) and value < data.max_value:
		set_value(data.max_value)
		if param("ready_text", "") != "":
			Events.signature_triggered.emit(creature, param("ready_text", ""), data.color)
	if param("camo_alpha", 1.0) < 1.0:
		creature.sprite.modulate.a = param("camo_alpha", 1.0) if poised() else 1.0


func _can_decay() -> bool:
	return false


func poised() -> bool:
	return value >= data.max_value


func modify_hit(hit: HitInfo) -> void:
	if not poised() or hit.move.power <= 0.0:
		return
	var kinds: Array = param("kinds", [])
	if not kinds.is_empty() and not MoveData.Kind.keys()[hit.move.kind] in kinds:
		return
	hit.damage_mult *= param("burst_mult", 1.0)
	var push: float = param("burst_push", 0.0)
	if push > 0.0:
		creature.knockback += creature.facing.normalized() * push
	if param("consume_on_hit", true):
		_still = 0.0
		set_value(0.0)
		if param("hit_text", "") != "":
			Events.signature_triggered.emit(creature, param("hit_text", ""), data.color)


func knockback_taken_mult() -> float:
	return param("anchored_knockback", 1.0) if poised() else 1.0


func state_label() -> String:
	return param("label", "") if poised() else ""
