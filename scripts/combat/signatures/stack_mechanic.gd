extends SignatureMechanic
## Seda (Caterpie, control): sus ataques dejan stacks de `stack_status` (seda) en el rival; al llegar a `stacks`
## se los saca y le aplica `trigger_status` (enraizado: no se mueve un rato). Sin barra.


func _setup() -> void:
	creature.status_inflicted.connect(_on_status_inflicted)


func _on_status_inflicted(target: Node, s: StatusEffect) -> void:
	if s.id != param("stack_status", "seda") or not is_instance_valid(target):
		return
	if target.statuses.stacks(s.id) < int(param("stacks", 3)):
		return
	target.statuses.cure(s)
	var trig: StatusEffect = DB.statuses.get(param("trigger_status", "enraizado"))
	if trig != null:
		target.statuses.apply(trig)
	Events.signature_triggered.emit(target, param("text", "¡Enredado!"), data.color)
