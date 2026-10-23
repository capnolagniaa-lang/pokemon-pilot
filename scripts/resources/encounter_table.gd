class_name EncounterTable
extends Resource
## Tabla de encuentros salvajes de una zona (data/world/encounters/<zona>.tres) o de un bioma
## (data/world/encounters/biomas/<bioma>.tres, la que usan las zonas sin tabla propia). La arma el editor de
## mapas (pestaña Zona → Pokémon salvajes) y la usa WildSpawner.

const DIR := "res://data/world/encounters"
const TEMPLATES := "res://data/world/encounters/plantillas_frlg.json"
## Lugares para el "dónde" (tag de celda -> nombre para mostrar).
const WHERE := {"pasto_alto": "Pasto alto", "agua": "Agua", "arena": "Arena", "suelo": "Cualquier suelo",
	"flores": "Flores", "tierra": "Tierra"}

@export var entries: Array[EncounterEntry] = []
## Áreas pintadas en la zona con ajustes de probabilidad (ver EncounterArea).
@export var areas: Array[EncounterArea] = []
## Salvajes vivos a la vez en la zona (mínimo: en zonas grandes se suman más, ver cells_per_wild).
@export var max_alive: int = 3
## Un salvaje más cada tantas celdas donde pueden aparecer (pasto alto, agua...). 0 = siempre max_alive.
@export var cells_per_wild: int = 150
## Tope de salvajes vivos a la vez, por grande que sea la zona.
@export var max_alive_cap: int = 16
## Segundos para que aparezca otro cuando hay menos de max_alive.
@export var respawn_time: float = 25.0


static func zone_path(zone_id: String) -> String:
	return "%s/%s.tres" % [DIR, zone_id]


static func biome_path(biome: String) -> String:
	return "%s/biomas/%s.tres" % [DIR, biome]


## La tabla que usa una zona: la propia o, si no tiene, la de su bioma (null si tampoco hay).
static func for_zone(entry: ZoneEntry) -> EncounterTable:
	for p in [zone_path(entry.id), biome_path(entry.biome)]:
		if ResourceLoader.exists(p):
			return ResourceLoader.load(p, "", ResourceLoader.CACHE_MODE_REPLACE)
	return null


func copy() -> EncounterTable:
	var t := EncounterTable.new()
	for e in entries:
		t.entries.append(e.copy())
	for a in areas:
		t.areas.append(a.copy())
	t.max_alive = max_alive
	t.cells_per_wild = cells_per_wild
	t.max_alive_cap = max_alive_cap
	t.respawn_time = respawn_time
	return t


## Cuántos salvajes vivos a la vez para una zona con `cells` celdas donde pueden aparecer.
func alive_for(cells: int) -> int:
	if cells_per_wild <= 0:
		return max_alive
	return clampi(max_alive + cells / cells_per_wild, max_alive, maxi(max_alive, max_alive_cap))


## Índice del área que contiene la celda (-1 si ninguna).
func area_at(cell: Vector2i) -> int:
	for i in areas.size():
		if areas[i].cells.has(cell):
			return i
	return -1


## Filas que valen en una celda: las de la tabla con los ajustes del área de esa celda aplicados.
func rows_at(cell: Vector2i) -> Array[EncounterEntry]:
	var out: Array[EncounterEntry] = []
	for e in entries:
		out.append(e)
	var ai := area_at(cell)
	if ai < 0:
		return out
	for adj in areas[ai].adjustments:
		var replaced := false
		for i in out.size():
			if out[i].species_id == adj.species_id and out[i].where == adj.where:
				out[i] = adj
				replaced = true
		if not replaced:
			out.append(adj)
	return out


## Probabilidad (0-1) de cada especie en una celda con esos tags: {especie: probabilidad}.
func chances_at(cell: Vector2i, tags: PackedStringArray) -> Dictionary:
	var total := 0
	var by := {}
	for e in rows_at(cell):
		if tags.has(e.where) and e.weight > 0:
			total += e.weight
			by[e.species_id] = by.get(e.species_id, 0) + e.weight
	var out := {}
	for k in by:
		out[k] = float(by[k]) / total
	return out


## Elige una fila para una celda (con sus tags), con los ajustes de su área.
func pick_at(rng: RandomNumberGenerator, cell: Vector2i, tags: PackedStringArray) -> EncounterEntry:
	var rows := rows_at(cell)
	var total := 0
	for e in rows:
		if tags.has(e.where) and e.weight > 0:
			total += e.weight
	if total <= 0:
		return null
	var roll := rng.randi_range(1, total)
	for e in rows:
		if tags.has(e.where) and e.weight > 0:
			roll -= e.weight
			if roll <= 0:
				return e
	return null


## Lugares ("dónde") que usa la tabla (incluidos los ajustes de las áreas).
func wheres() -> PackedStringArray:
	var out := PackedStringArray()
	var all: Array[EncounterEntry] = entries.duplicate()
	for a in areas:
		all.append_array(a.adjustments)
	for e in all:
		if not out.has(e.where):
			out.append(e.where)
	return out


## Elige una fila al azar según los pesos, solo entre las de los lugares disponibles en la zona.
func pick(rng: RandomNumberGenerator, available: PackedStringArray) -> EncounterEntry:
	var total := 0
	for e in entries:
		if available.has(e.where) and e.weight > 0:
			total += e.weight
	if total <= 0:
		return null
	var roll := rng.randi_range(1, total)
	for e in entries:
		if available.has(e.where) and e.weight > 0:
			roll -= e.weight
			if roll <= 0:
				return e
	return null


## Plantillas de FireRed (tools/build_encounter_templates.py): [{"id", "name", "rows": [...]}].
static func templates() -> Array:
	if not FileAccess.file_exists(TEMPLATES):
		return []
	return JSON.parse_string(FileAccess.get_file_as_string(TEMPLATES)).get("templates", [])


static func from_template(t: Dictionary) -> EncounterTable:
	var table := EncounterTable.new()
	for r in t["rows"]:
		var e := EncounterEntry.new()
		e.species_id = r["species"]
		e.weight = int(r["weight"])
		e.min_level = int(r["min_level"])
		e.max_level = int(r["max_level"])
		e.where = r["where"]
		table.entries.append(e)
	return table
