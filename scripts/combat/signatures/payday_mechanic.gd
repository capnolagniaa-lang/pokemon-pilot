extends SignatureMechanic
## Día de Pago (Meowth; docs/PROPUESTA_KITS_PENDIENTES.md): cada golpe que conecta hace saltar monedas (`coins_per_hit`).
## Si el Meowth es tuyo, se suman a **tu dinero** (`GameState.add_money`; decisión 2026-10-26). Cada `coins_for_rush`
## monedas le bajan `rush_cut` s todas las recargas (la barra muestra cuánto falta).

var coins := 0


func _setup() -> void:
	creature.hit_dealt.connect(_on_hit_dealt)


func _can_decay() -> bool:
	return false


func _on_hit_dealt(_target: Creature, hit: HitInfo, dealt: float) -> void:
	if hit == null or hit.move == null or hit.move.power <= 0.0 or dealt <= 0.0:
		return
	var n: int = param("coins_per_hit", 5)
	coins += n
	Fx.burst(creature.get_parent(), creature.global_position + Vector2(0, -10), Color(1.0, 0.85, 0.25), 6, 50.0)
	if creature.team == Creature.Team.ALLY and creature.player_controlled:
		GameState.add_money(n)
	set_value(value + data.max_value / float(param("hits_for_rush", 4)))
	if value >= data.max_value:
		set_value(0.0)
		for i in creature.moves.cooldowns.size():
			creature.moves.cooldowns[i] = maxf(0.0, creature.moves.cooldowns[i] - param("rush_cut", 0.5))
		Events.signature_triggered.emit(creature, "¡Día de Pago!", data.color)


func state_label() -> String:
	return "$%d" % coins if coins > 0 else ""
