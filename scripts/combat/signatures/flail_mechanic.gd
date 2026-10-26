extends SignatureMechanic
## Determinación (Magikarp; docs/PROPUESTA_KITS_PENDIENTES.md): el chiste de un Pokémon que "solo salta y salpica"...
##  · Su ataque `flail_move` (Azote) pega más cuanto menos vida tiene: hasta ×`flail_max` con la vida casi en 0.
##  · Cada pelea en la que derriba a un rival y sigue en pie le da `exp_bonus` de EXP extra (para llegar a Gyarados).

func _setup() -> void:
	creature.killed.connect(_on_killed)


func _can_decay() -> bool:
	return false


func damage_mult_against(hit: HitInfo, _target: Creature) -> float:
	if not hit.move.id.begins_with(param("flail_move", "azote")):
		return 1.0
	return 1.0 + (param("flail_max", 3.0) - 1.0) * (1.0 - creature.health.ratio())


func _on_killed(_t: Creature) -> void:
	if creature.is_down() or creature.team != Creature.Team.ALLY or creature.instance == null:
		return
	var bonus: int = param("exp_bonus", 20)
	if GameState.has_method("grant_exp"):
		GameState.grant_exp(creature.instance, bonus)
	Events.signature_triggered.emit(creature, "¡Determinación! +%d EXP" % bonus, data.color)


func _tick(_delta: float) -> void:
	set_value(data.max_value * (1.0 - creature.health.ratio()))


func state_label() -> String:
	return "¡AZOTE ×%.1f!" % (1.0 + (param("flail_max", 3.0) - 1.0) * (1.0 - creature.health.ratio())) \
		if creature.health.ratio() < 0.4 else ""
