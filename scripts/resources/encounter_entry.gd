class_name EncounterEntry
extends Resource
## Una fila de una tabla de encuentros salvajes: qué especie, con qué probabilidad, en qué niveles y dónde.

## Id de la especie (data/species/<id>.tres).
@export var species_id: String = ""
## Peso (en %): la probabilidad relativa frente a las otras filas del mismo lugar.
@export var weight: int = 10
@export var min_level: int = 2
@export var max_level: int = 5
## Dónde aparece: un tag de celda ("pasto_alto", "agua", "arena", "suelo"...).
@export var where: String = "pasto_alto"
## Hora del día ("" = siempre, "dia", "noche"). Reservado para la Etapa 5 (ciclo día/noche): hoy no filtra.
@export var time: String = ""


func copy() -> EncounterEntry:
	var e := EncounterEntry.new()
	e.species_id = species_id
	e.weight = weight
	e.min_level = min_level
	e.max_level = max_level
	e.where = where
	e.time = time
	return e
