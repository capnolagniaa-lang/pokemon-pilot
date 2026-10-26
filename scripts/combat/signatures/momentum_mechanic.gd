extends SignatureMechanic
## Impulso (Geodude, tanque de roca): cada ataque con id `roll_move` (Rodar) lanzado dentro de `chain_time` s del
## anterior pega `step_bonus` más (hasta ×`max_mult`). Con Rizo Defensa activo (estado `rizo`), Rodar pega el
## doble (como en los juegos). La barra muestra el impulso acumulado.

var _last_roll := -100.0
var _chain := 0


func modify_hit(hit: HitInfo) -> void:
	if not hit.move.id.begins_with(param("roll_move", "rodar")):  # el Rodar del kit y el oficial
		return
	if creature.now() - _last_roll <= param("chain_time", 3.0):
		_chain = mini(_chain + 1, int(param("max_chain", 2)))
	else:
		_chain = 0
	_last_roll = creature.now()
	hit.damage_mult *= minf(1.0 + param("step_bonus", 0.5) * _chain, param("max_mult", 2.0))
	if creature.statuses.has_status("rizo"):
		hit.damage_mult *= param("curl_mult", 2.0)
	set_value(data.max_value * _chain / maxf(1.0, param("max_chain", 2)))
	if _chain > 0:
		Events.signature_triggered.emit(creature, "¡Impulso ×%d!" % (_chain + 1), data.color)


func _tick(_delta: float) -> void:
	if _chain > 0 and creature.now() - _last_roll > param("chain_time", 3.0):
		_chain = 0
		set_value(0.0)


func state_label() -> String:
	if creature.statuses.has_status("rizo"):
		return "RIZO: RODAR ×2"
	return "IMPULSO ×%d" % (_chain + 1) if _chain > 0 else ""
