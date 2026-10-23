extends SignatureMechanic
## Estática (Pikachu, velocista): moverse y esquivar generan cargas (la barra tiene 5 marcas); quedarse quieto las
## pierde. Rayo gasta todas (resource_cost -1) y escala con ellas. Con la barra llena, el próximo golpe es una
## **Descarga**: además paraliza fuerte, y la barra vuelve a 0.


func _tick(delta: float) -> void:
	if creature.velocity.length() < 8.0 and value > 0.0:
		set_value(value - param("idle_loss", 30.0) * delta)


func modify_hit(hit: HitInfo) -> void:
	if value >= data.max_value and hit.move.power > 0.0 and hit.move.resource_cost == 0.0:
		hit.extra_status = DB.statuses.get("paralizado")
		hit.extra_status_chance = 1.0
		hit.damage_mult *= param("discharge_mult", 1.3)
		set_value(0.0)
		Events.signature_triggered.emit(creature, "¡Descarga!", data.color)


func state_label() -> String:
	var charges := int(value / (data.max_value / 5.0))
	return "DESCARGA LISTA" if value >= data.max_value else ("%d CARGAS" % charges if charges > 0 else "")
