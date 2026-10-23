extends SignatureMechanic
## Jaqueca (Psyduck, caótico): sube al recibir daño y de a poco mientras pelea. Al llenarse estalla: una Confusión
## en área alrededor (ataque `burst_move` del kit: daño psíquico + Desorientado) y vuelve a 0.

var burst_move: MoveData


func _setup() -> void:
	var path: String = param("burst_move", "")
	burst_move = load(path) if path != "" and ResourceLoader.exists(path) else null


func _tick(delta: float) -> void:
	if in_combat():
		set_value(value + param("combat_gain", 3.0) * delta)


func _on_value_changed(_before: float) -> void:
	if value >= data.max_value and burst_move != null and not creature.is_down():
		set_value(0.0)
		var hit := HitInfo.from(creature, burst_move)
		var a := AreaEffect.new()
		creature.get_parent().add_child(a)
		a.trigger(hit, creature.global_position + Vector2(0, -6))
		Events.signature_triggered.emit(creature, "¡Jaqueca!", data.color)
		Events.camera_shake.emit(3.0)


func state_label() -> String:
	return "A PUNTO DE ESTALLAR" if value >= data.max_value * 0.75 else ""
