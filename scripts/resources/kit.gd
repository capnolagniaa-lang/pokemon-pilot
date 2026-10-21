class_name Kit
extends Resource
## Kit de un Pokémon (plan de identidad, capas 1 y 3): arquetipo, mecánica de firma y 5 habilidades.
## Controles: Clic izq. básico · Clic der. habilidad 1 · Q habilidad 2 · Espacio movilidad · R definitiva.
## Cada .tres en data/kits/<pokémon>/kit.tres; la especie lo referencia en SpeciesData.kit.

enum Slot { BASIC, ABILITY_1, ABILITY_2, MOBILITY, ULTIMATE }
const SLOT_COUNT := 5

## bruiser, tanque, control, velocista, hostigador, desgaste, espaciador, asesino
@export var archetype: String = ""
## Rango en el que quiere pelear (lo usa la IA).
@export var preferred_range: float = 50.0
@export var signature: SignatureData
@export var basic: MoveData
@export var ability_1: MoveData
@export var ability_2: MoveData
@export var mobility: MoveData
@export var ultimate: MoveData


func slots() -> Array[MoveData]:
	return [basic, ability_1, ability_2, mobility, ultimate]
