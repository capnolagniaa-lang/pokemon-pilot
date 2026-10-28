extends SignatureMechanic
## Transformación (Ditto; pedido del usuario 2026-10-28, kits de todos los Pokémon del juego): al soltar su ataque
## `transform_move` (prefijo de id) copia los 4 ataques del rival más cercano (hasta `range` px) y pelea con ellos
## `duration` s; después vuelve a ser un Ditto. Mientras está transformado se tiñe del color del rival copiado. La
## barra muestra cuánto le queda transformado.

var _original: Array[MoveData] = []
var _left := 0.0
var _copied := ""


func _on_move_released(m: MoveData) -> void:
	if _left > 0.0 or not m.id.begins_with(param("transform_move", "transformacion")):
		return
	var foe := _pick_target()
	if foe == null:
		Events.signature_triggered.emit(creature, "Nada que copiar...", data.color)
		return
	_original = creature.moves.slots.duplicate()
	var mu: MoveUser = creature.moves
	for i in MoveUser.SLOT_COUNT:
		var copy: MoveData = foe.moves.slots[i] if i < foe.moves.slots.size() else null
		mu.slots[i] = copy if copy != null else _original[i]
		mu.cooldowns[i] = 0.0
	_left = param("duration", 25.0)
	_copied = foe.instance.species.display_name
	creature.sprite.modulate = foe.instance.species.types[0].color.lightened(0.4) if not foe.instance.species.types.is_empty() else Color(1, 0.8, 1)
	set_value(data.max_value)
	Events.signature_triggered.emit(creature, "¡Se transformó en %s!" % _copied, data.color)


func _pick_target() -> Creature:
	if is_instance_valid(creature.target) and not creature.target.is_down():
		return creature.target
	var best: Creature = null
	var best_d: float = param("range", 180.0)
	for c in creature.get_tree().get_nodes_in_group("creatures"):
		if c == creature or c.team == creature.team or c.is_down():
			continue
		var d: float = c.global_position.distance_to(creature.global_position)
		if d < best_d:
			best_d = d
			best = c
	return best


func _tick(delta: float) -> void:
	if _left <= 0.0:
		return
	_left -= delta
	if data.max_value > 0.0:
		set_value(data.max_value * _left / param("duration", 25.0))
	if _left <= 0.0:
		_revert()


func _revert() -> void:
	var mu: MoveUser = creature.moves
	for i in mini(_original.size(), MoveUser.SLOT_COUNT):
		mu.slots[i] = _original[i]
	creature.sprite.modulate = Color.WHITE
	_left = 0.0
	set_value(0.0)
	Events.signature_triggered.emit(creature, "Volvió a ser Ditto", data.color)


func _can_decay() -> bool:
	return false


func state_label() -> String:
	return "COMO %s" % _copied.to_upper() if _left > 0.0 else ""
