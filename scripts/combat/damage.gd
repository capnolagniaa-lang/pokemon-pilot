class_name Damage
extends RefCounted
## Fórmula de daño: poder x ataque x efectividad de tipo x bonus por mismo tipo (STAB) x variación x escala.

const STAB := 1.25
## Escala global: con esto un combate parejo dura ~10-15 golpes (hay tiempo para esquivar y posicionarse).
const SCALE := 0.4


static func resolve(hit: HitInfo, defender_types: Array[ElementType]) -> float:
	var move := hit.move
	hit.effectiveness = DB.type_chart.get_multiplier(move.element, defender_types)
	var stab := STAB if move.element in hit.attacker_types else 1.0
	return move.power * (hit.attack / 10.0) * hit.effectiveness * stab * randf_range(0.9, 1.1) * SCALE
