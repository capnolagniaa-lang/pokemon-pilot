class_name TypeChart
extends Resource
## Tabla de efectividad: multipliers[id_ataque][id_defensor] = multiplicador (1.0 si no figura).

@export var multipliers: Dictionary = {}


func get_multiplier(attack: ElementType, defender_types: Array[ElementType]) -> float:
	var row: Dictionary = multipliers.get(attack.id, {})
	var mult := 1.0
	for t in defender_types:
		mult *= float(row.get(t.id, 1.0))
	return mult
