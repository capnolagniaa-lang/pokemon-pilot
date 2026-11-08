class_name WildIndex
extends RefCounted
## Dónde sale cada especie como salvaje (Pokédex → "Dónde aparece", tools/build_wild_docs.gd): recorre las tablas de
## encuentros de todas las zonas (la propia o la de su bioma, como WildSpawner), sus áreas pintadas y las tablas de
## pesca por caña (data/world/pesca.json). Se arma una sola vez y queda en caché (`for_species`).
##
## El % de una fila es contra el total de su lugar ("dónde"): el spawner elige primero la celda y después una fila
## de las que valen ahí, así que las filas de pasto alto compiten solo entre ellas. Una fila sin especie ("esa vez
## no sale nadie") cuenta para el total pero no se lista. En un área pintada valen las filas con sus ajustes (se
## listan aparte, con el nombre del área). Las filas de agua salen solo navegando (Surf). Pesca: el % de FireRed
## para esa caña.

## Cómo se llama cada forma de encontrarlo, para mostrar.
const KIND_TEXT := {"pasto_alto": "Pasto alto", "suelo": "Cualquier suelo", "agua": "Surf", "arena": "Arena",
	"flores": "Flores", "tierra": "Tierra", "pesca": "Pesca"}
const ROD_TEXT := {"vieja": "Caña Vieja", "buena": "Caña Buena", "super": "Supercaña"}
const ROD_ORDER := ["vieja", "buena", "super"]
const FISHING_PATH := "res://data/world/pesca.json"

## especie → [{zone, name, kind, rod, area, pct, min, max}]
static var _by_species: Dictionary = {}
## zona → [{species, kind, rod, area, pct, min, max}] (todas las filas con especie, ya agrupadas)
static var _by_zone: Dictionary = {}
static var _built := false


## Lugares donde sale una especie, ordenados como las zonas de la región (y dentro de cada zona: tierra, Surf, pesca).
static func for_species(species_id: String) -> Array:
	_ensure()
	return _by_species.get(species_id, [])


## Todo lo que sale en una zona (para tests y listados).
static func for_zone(zone_id: String) -> Array:
	_ensure()
	return _by_zone.get(zone_id, [])


## Vuelve a armar el índice la próxima vez (después de cambiar tablas, por ejemplo en el editor de mapas).
static func invalidate() -> void:
	_built = false
	_by_species.clear()
	_by_zone.clear()


## Filas de una tabla con su % dentro de su lugar: [{entry, pct}] (pct 0-100; las de especie vacía también, para
## que un listado las muestre si quiere).
static func rows_with_pct(rows: Array) -> Array:
	var totals := {}
	for e: EncounterEntry in rows:
		if e.weight > 0:
			totals[e.where] = totals.get(e.where, 0) + e.weight
	var out := []
	for e: EncounterEntry in rows:
		var pct := 100.0 * e.weight / float(totals[e.where]) if e.weight > 0 else 0.0
		out.append({"entry": e, "pct": pct})
	return out


## Texto corto de un lugar: "Pasto alto", "Surf", "Pesca (Caña Buena)", "+ área «Orilla»".
static func kind_label(place: Dictionary) -> String:
	var s: String = KIND_TEXT.get(place["kind"], String(place["kind"]).capitalize())
	if place.get("rod", "") != "":
		s += " (%s)" % ROD_TEXT.get(place["rod"], place["rod"])
	if place.get("area", "") != "":
		s += " · área «%s»" % place["area"]
	return s


static func _ensure() -> void:
	if _built:
		return
	_built = true
	# DB por nombre: en un --script (build_wild_docs) no hay autoloads y el identificador no compila.
	var db: Node = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("DB") if Engine.get_main_loop() is SceneTree else null
	var world: WorldData = db.config.world if db != null and db.config != null else load("res://data/world/kanto.tres")
	build(world)


## Arma el índice para una región (sin autoloads: lo usa también tools/build_wild_docs.gd).
static func build(world: WorldData) -> void:
	_built = true
	_by_species.clear()
	_by_zone.clear()
	var fishing := {}
	if FileAccess.file_exists(FISHING_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(FISHING_PATH))
		if parsed is Dictionary:
			fishing = parsed
	for z: ZoneEntry in world.zones:
		var places := []  # filas agrupadas de esta zona
		var table := EncounterTable.for_zone(z)
		if table != null:
			_add_rows(places, table.entries, "")
			for a in table.areas:  # en el área: la tabla con sus ajustes; se listan solo las filas ajustadas
				_add_rows(places, _area_rows(table, a), a.name if a.name != "" else "sin nombre", a.adjustments)
		for rod in ROD_ORDER:
			for row: Dictionary in fishing.get(z.id, {}).get(rod, []):
				var sid := String(row.get("species", ""))
				if sid == "":
					continue
				_merge(places, sid, "pesca", rod, "", float(row.get("pct", 0)), int(row.get("min", 1)), int(row.get("max", 1)))
		places.sort_custom(func(a, b): return _order(a) < _order(b))
		if places.is_empty():
			continue
		_by_zone[z.id] = places
		for p: Dictionary in places:
			var item := p.duplicate()
			item["zone"] = z.id
			item["name"] = z.display_name if z.display_name != "" else z.id
			item.erase("species")
			if not _by_species.has(p["species"]):
				_by_species[p["species"]] = []
			_by_species[p["species"]].append(item)


## Las filas que valen en un área: las de la tabla con los ajustes del área (lo mismo que EncounterTable.rows_at).
static func _area_rows(table: EncounterTable, area: EncounterArea) -> Array:
	var out := table.entries.duplicate()
	for adj in area.adjustments:
		var replaced := false
		for i in out.size():
			if out[i].species_id == adj.species_id and out[i].where == adj.where:
				out[i] = adj
				replaced = true
		if not replaced:
			out.append(adj)
	return out


static func _add_rows(places: Array, rows: Array, area: String, only: Array = []) -> void:
	for r: Dictionary in rows_with_pct(rows):
		var e: EncounterEntry = r["entry"]
		if e.species_id == "" or e.weight <= 0 or (not only.is_empty() and not only.has(e)):
			continue
		_merge(places, e.species_id, e.where, "", area, r["pct"], e.min_level, e.max_level)


## Suma a la fila de la misma especie, forma, caña y área (una especie puede tener varias filas con otros niveles).
static func _merge(places: Array, sid: String, kind: String, rod: String, area: String, pct: float, lo: int, hi: int) -> void:
	for p: Dictionary in places:
		if p["species"] == sid and p["kind"] == kind and p["rod"] == rod and p["area"] == area:
			p["pct"] += pct
			p["min"] = mini(p["min"], mini(lo, hi))
			p["max"] = maxi(p["max"], maxi(lo, hi))
			return
	places.append({"species": sid, "kind": kind, "rod": rod, "area": area, "pct": pct, "min": mini(lo, hi), "max": maxi(lo, hi)})


static func _order(p: Dictionary) -> int:
	var k := 0 if p["kind"] != "agua" and p["kind"] != "pesca" else (1 if p["kind"] == "agua" else 2 + ROD_ORDER.find(p["rod"]))
	return k * 10 + (1 if p["area"] != "" else 0)
