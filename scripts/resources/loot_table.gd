class_name LootTable
extends Resource
## Tabla de objetos con pesos (docs/PLAN_CAPTURA_MOCHILA.md): qué aparece tirado en el mapa (campo.tres) y qué
## sueltan los salvajes debilitados (salvajes.tres). Datos en data/items/loot/.

@export var items: Array[ItemData] = []
## Peso de cada objeto (misma posición que en `items`).
@export var weights: PackedFloat32Array = []
## Salvajes: probabilidad de que suelte algo al debilitarse.
@export_range(0.0, 1.0) var drop_chance: float = 0.15


func pick(rng: RandomNumberGenerator = null) -> ItemData:
	var total := 0.0
	for i in items.size():
		total += weights[i] if i < weights.size() else 1.0
	var roll := (rng.randf() if rng != null else randf()) * total
	for i in items.size():
		roll -= weights[i] if i < weights.size() else 1.0
		if roll <= 0.0:
			return items[i]
	return items[-1] if not items.is_empty() else null
