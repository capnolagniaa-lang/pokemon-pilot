extends SignatureMechanic
## Inflado y Marcador (Jigglypuff; docs/PROPUESTA_KITS_PENDIENTES.md):
##  · cada golpe que recibe lo infla (estado `puff_status`, hasta sus stacks): inflado recibe menos empuje;
##  · su ataque `roll_move` (Rodar) gasta el inflado: +`roll_per_stack` de daño por cada stack;
##  · sus golpes contra un rival dormido le dejan un **garabato** en la cara (`doodle_status`: Expuesto), como en el
##    anime cuando se ofende porque se durmieron con su canción.

func _setup() -> void:
	creature.damage_received.connect(func(amount, _hit): _puff(amount))


func _puff(amount: float) -> void:
	if amount <= 0.0 or creature.is_down():
		return
	var s: StatusEffect = DB.statuses.get(param("puff_status", ""))
	if s != null:
		creature.statuses.apply(s)


func damage_mult_against(hit: HitInfo, target: Creature) -> float:
	var mult := 1.0
	if target.statuses.has_status("dormido") and hit.move.power > 0.0:
		var doodle: StatusEffect = DB.statuses.get(param("doodle_status", "expuesto"))
		if doodle != null and not target.statuses.has_status(doodle.id):
			target.statuses.apply(doodle)
			Events.signature_triggered.emit(creature, "¡Garabato!", data.color)
	if hit.move.id.begins_with(param("roll_move", "rodar")):
		var n := creature.statuses.stacks(param("puff_status", ""))
		if n > 0:
			mult *= 1.0 + param("roll_per_stack", 0.25) * n
			creature.statuses.cure(DB.statuses[param("puff_status", "")])
	return mult


func state_label() -> String:
	var n := creature.statuses.stacks(param("puff_status", ""))
	return "INFLADO ×%d" % n if n > 0 else ""
