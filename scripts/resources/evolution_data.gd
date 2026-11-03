class_name EvolutionData
extends Resource
## Una evolución de una especie (SpeciesData.evolutions; la arma tools/apply_evolutions.gd desde
## data/source/evolutions.json, que sale de PokeAPI). La especie destino va por id (no por recurso: sin ciclos).
## Formas: "nivel" (al llegar a `level`), "piedra" (usar el objeto `item`), "intercambio" y "amistad" (todavía no
## hay intercambio ni amistad en el juego: apply_evolutions las pasa a nivel u objeto, como los fangames).

@export var to_id: String = ""
@export var method: String = "nivel"
@export var level: int = 0
## Piedra (id de data/items) o el objeto que lleva en un intercambio.
@export var item: String = ""
## Tyrogue: 1 = ataque > defensa, -1 = ataque < defensa, 0 = iguales. Vacío (99) = sin condición.
@export var stats_cond: int = 99

## Solo a esta hora: "dia" (de 5 a 20 h) o "noche". Vacío = a cualquier hora (Espeon y Umbreon).
@export var time: String = ""
