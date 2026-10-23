extends SignatureMechanic
## Adaptación (Eevee, adaptativo): cuando recibe un golpe con daño, durante `duration` s recibe menos
## (`resist_mult`) de ese tipo. Se adapta al último tipo que le pegó. Sin barra: el estado dice a qué se adaptó.

var _type: ElementType
var _left := 0.0


func _setup() -> void:
	creature.damage_received.connect(func(amount, hit):
		if hit != null and amount > 0.0 and hit.move.power > 0.0:
			if _type != hit.move.element:
				Events.signature_triggered.emit(creature, "Adaptado: %s" % hit.move.element.display_name, hit.move.element.color)
			_type = hit.move.element
			_left = param("duration", 8.0))


func _tick(delta: float) -> void:
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0:
		_type = null


func damage_taken_mult(hit: HitInfo) -> float:
	return param("resist_mult", 0.7) if _type != null and hit.move.element == _type else 1.0


func state_label() -> String:
	return "ADAPTADO: %s" % _type.display_name.to_upper() if _type != null else ""
