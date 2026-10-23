extends SignatureMechanic
## Rabia (Mankey, bruiser): la barra sube al recibir daño (y un poco al pegar). Llena, se enfurece: se aplica
## `self_status` (enfurecido: pega más y corre más) y la barra vuelve a 0.


func _on_value_changed(_before: float) -> void:
	if value < data.max_value:
		return
	var s: StatusEffect = DB.statuses.get(param("self_status", "enfurecido"))
	if s != null:
		creature.statuses.apply(s)
	set_value(0.0)
	Events.signature_triggered.emit(creature, "¡Furia!", data.color)


func _can_gain() -> bool:
	return not creature.statuses.has_status(param("self_status", "enfurecido"))


func state_label() -> String:
	return "ENFURECIDO" if creature.statuses.has_status(param("self_status", "enfurecido")) else ""
