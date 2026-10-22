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
## Kit del plan de identidad (estilo + mecánica de firma + 4 ataques). Si está, manda sobre `moves`.
@export var kit: Kit
## Movimientos que aprende por nivel (los arma tools/build_learnsets.gd). Si está vacío se usa uno de
## compatibilidad: los 4 del kit (o los sueltos) en los niveles 1, 1, 3 y 5.
@export var learnset: Array[LearnsetEntry] = []

@export_group("Pokédex")
## Categoría ("Pokémon Semilla") y descripción en español (PokeAPI). Altura y peso oficiales.
@export var genus: String = ""
@export_multiline var pokedex_entry: String = ""
@export var height_m: float = 0.0
@export var weight_kg: float = 0.0

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


## Niveles en los que se aprenden los 4 movimientos base (kit o sueltos) cuando no hay learnset.
const BASE_LEVELS := [1, 1, 3, 5]


## Learnset ordenado por nivel (el propio o el de compatibilidad).
func learnset_entries() -> Array[LearnsetEntry]:
	var out: Array[LearnsetEntry] = []
	if learnset.is_empty():
		var base: Array[MoveData] = kit.moves if kit != null else moves
		for i in base.size():
			if base[i] != null:
				var e := LearnsetEntry.new()
				e.level = BASE_LEVELS[mini(i, BASE_LEVELS.size() - 1)]
				e.move = base[i]
				out.append(e)
	else:
		# Orden estable por nivel (los del mismo nivel quedan en el orden en que están cargados).
		var idx := range(learnset.size()).filter(func(i): return learnset[i] != null and learnset[i].move != null)
		idx.sort_custom(func(a, b): return learnset[a].level < learnset[b].level or (learnset[a].level == learnset[b].level and a < b))
		for i in idx:
			out.append(learnset[i])
	return out
