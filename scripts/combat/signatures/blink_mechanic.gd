extends SignatureMechanic
## Mente Rápida (Kadabra, control psíquico): después de teletransportarse (el ataque `blink_move`), durante
## `window` s el próximo golpe es un **Golpe Mental**: pega `bonus` más y desorienta seguro. La barra muestra la
## ventana. Pregunta del jugador: ¿me teletransporto para escapar o para preparar el golpe?

var _window := 0.0


func _on_move_released(m: MoveData) -> void:
	if m.id.begins_with(param("blink_move", "teletransporte")):
		_window = param("window", 2.0)
		set_value(data.max_value)


func _tick(delta: float) -> void:
	if _window > 0.0:
		_window -= delta
		set_value(data.max_value * maxf(0.0, _window) / param("window", 2.0))


func _can_decay() -> bool:
	return false


func modify_hit(hit: HitInfo) -> void:
	if _window <= 0.0 or hit.move.power <= 0.0:
		return
	_window = 0.0
	set_value(0.0)
	hit.damage_mult *= param("bonus", 1.5)
	hit.extra_status = DB.statuses.get("desorientado")
	hit.extra_status_chance = 1.0
	Events.signature_triggered.emit(creature, "¡Golpe Mental!", data.color)


func state_label() -> String:
	return "GOLPE MENTAL LISTO" if _window > 0.0 else ""
