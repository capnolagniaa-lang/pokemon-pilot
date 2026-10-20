class_name SpeciesData
extends Resource
## Definición de una especie. Cada .tres en data/species es una especie.

@export var id: String = ""
@export var display_name: String = ""
## Número de Pokédex: se usa para buscar sus sprites.
@export var dex: int = 0
@export var types: Array[ElementType] = []
@export var base_hp: float = 50.0
@export var base_atk: float = 10.0
## Velocidad de movimiento en píxeles por segundo.
@export var move_speed: float = 70.0
@export var moves: Array[MoveData] = []
@export_range(0.0, 1.0) var catch_rate: float = 0.5


func primary_type() -> ElementType:
	return types[0] if not types.is_empty() else null
