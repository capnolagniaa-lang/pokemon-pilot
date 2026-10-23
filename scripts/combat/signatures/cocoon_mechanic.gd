extends SignatureMechanic
## Capullo (Metapod y Kakuna, tanques): quieto se endurece (la barra sube `harden_per_s` por segundo) y recibe
## menos daño (hasta −`max_reduction` con la barra llena); moverse la baja rápido (`soften_per_s`). Con
## `poison_contact` > 0 (Kakuna), al que le pega cuerpo a cuerpo endurecido lo envenena con esa probabilidad.


func _tick(delta: float) -> void:
	if creature.velocity.length() < 8.0:
		set_value(value + param("harden_per_s", 50.0) * delta)
	else:
		set_value(value - param("soften_per_s", 120.0) * delta)


func damage_taken_mult(hit: HitInfo) -> float:
	var contact: float = param("poison_contact", 0.0)
	if contact > 0.0 and ratio() >= 0.5 and hit.move.kind in [MoveData.Kind.MELEE, MoveData.Kind.DASH, MoveData.Kind.LUNGE] \
			and is_instance_valid(hit.attacker) and randf() < contact:
		hit.attacker.statuses.apply(DB.statuses["envenenado"])
		Events.signature_triggered.emit(hit.attacker, "¡Púas!", data.color)
	return 1.0 - param("max_reduction", 0.5) * ratio()


func state_label() -> String:
	return "ENDURECIDO" if ratio() >= 0.99 else ""
