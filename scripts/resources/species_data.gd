class_name SpeciesData
extends Resource
## Definición de una especie. Cada .tres en data/species es una especie.
## Los stats base, la experiencia y la curva de crecimiento son los oficiales
## (data/source/official.json, aplicados con tools/apply_official_data.gd).

@export var id: String = ""
@export var display_name: String = ""
## Número de Pokédex: se usa para buscar sus sprites.
@export var dex: int = 0
@export var types: Array[ElementType] = []
## Ataques sueltos (para los Pokémon que todavía no tienen kit propio).
@export var moves: Array[MoveData] = []
## Kit del plan de identidad (arquetipo + mecánica de firma + 5 habilidades). Si está, manda sobre `moves`.
@export var kit: Kit

@export_group("Stats base oficiales")
@export var base_hp: int = 50
@export var base_attack: int = 50
@export var base_defense: int = 50
@export var base_sp_attack: int = 50
@export var base_sp_defense: int = 50
@export var base_speed: int = 50

@export_group("Progresión")
## Experiencia base que da al ser derrotado.
@export var base_experience: int = 60
## Curva de experiencia: fast, medium, medium-slow, slow, slow-then-very-fast, fast-then-very-slow.
@export var growth_rate: String = "medium"
## Tasa de captura oficial (0-255, más alto = más fácil).
@export_range(0, 255) var capture_rate: int = 45


func primary_type() -> ElementType:
	return types[0] if not types.is_empty() else null


func base_stat(stat: String) -> int:
	return get("base_" + stat)
