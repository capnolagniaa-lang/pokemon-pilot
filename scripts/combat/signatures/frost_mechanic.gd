extends SignatureMechanic
## Escarcha (Seel, tanque helado): sus ataques de hielo dejan escarcha en el rival (estado `escarcha`, hasta 3;
## lo ponen los ataques con statuses_on_hit). Al llegar a 3, la escarcha se convierte en Congelado (con la
## resistencia a control de siempre). Sin barra.


func _setup() -> void:
	creature.status_inflicted.connect(_on_inflicted)


func _on_inflicted(target: Creature, status: StatusEffect) -> void:
	if status.id != "escarcha" or not is_instance_valid(target) or target.statuses.stacks("escarcha") < param("stacks_to_freeze", 3):
		return
	target.statuses.cure(status)
	target.statuses.apply(DB.statuses["congelado"])
	Events.signature_triggered.emit(target, "¡Congelado!", data.color)


func state_label() -> String:
	var t: Creature = creature.target
	var n: int = t.statuses.stacks("escarcha") if is_instance_valid(t) else 0
	return "ESCARCHA %d/3" % n if n > 0 else ""
