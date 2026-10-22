class_name TileCatalog
extends Resource
## Catálogo de todos los metatiles de FireRed importados (data/world/tile_catalog.tres): tipo para la paleta,
## tags y colisión sugeridos, sellos y la grilla de la paleta "como en la hoja". Lo genera tools/pret_import.py
## (con los mapas reales de FireRed y los datos curados de tools/match_reference.py) y lo pasa a .tres
## tools/build_world.gd -- --tileset. Los ids son globales: base del tileset (general 0, el resto 1000, 2000...
## según art/pret/tiles/manifest.json → order) + índice local.
## Lo que se corrige a mano en el editor va a TileRoleSet.overrides (así reimportar no lo pisa).

## id global -> clave de tipo ("edificios", "agua", "otros_rocas"...).
@export var categories: Dictionary = {}
## Orden y nombres para mostrar de los tipos.
@export var category_order: PackedStringArray = []
@export var category_names: Dictionary = {}
## id global -> tags sugeridos (PackedStringArray).
@export var tags: Dictionary = {}
## id global -> colisión sugerida (-1 nada, 0 sólido, 1 agua): la que el metatile tiene casi siempre en los mapas.
@export var physics: Dictionary = {}
## Sellos (edificios y piezas del mundo), sacados de los mapas reales con las hojas de referencia:
## {"id", "name", "group", "place", "size": Vector2i, "maps", "variants": [{"name", "id", "map",
##  "cells": PackedInt32Array (por filas, -1 = vacío), "solid": PackedInt32Array (1 = sólido en el mapa real),
##  "doors": PackedInt32Array (índices de celdas de puerta), "ref_diff": píxeles distintos de la referencia}]}.
@export var stamps: Array[Dictionary] = []
## Grupos de sellos, en orden (Casas, Centros y tiendas, Gimnasios...).
@export var stamp_groups: PackedStringArray = []
## Paleta "como en la hoja" del mundo: tamaño en celdas, id por celda (por filas, -1 = vacío) y secciones
## {"name", "category", "rect": Rect2i}.
@export var sheet_size: Vector2i = Vector2i.ZERO
@export var sheet_cells: PackedInt32Array = []
@export var sheet_sections: Array[Dictionary] = []

const JSON_PATH := "res://art/pret/tiles/catalog.json"


func category_of(m: int) -> String:
	return categories.get(m, "")


func category_name(key: String) -> String:
	return category_names.get(key, key.capitalize())


## Arma el catálogo desde el JSON del importador.
static func from_json(path: String = JSON_PATH) -> TileCatalog:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var c := TileCatalog.new()
	for k in data["categories"]:
		c.categories[int(k)] = data["categories"][k]
	for k in data["tags"]:
		c.tags[int(k)] = PackedStringArray(data["tags"][k])
	for k in data["physics"]:
		c.physics[int(k)] = int(data["physics"][k])
	c.category_order = PackedStringArray(data["category_order"])
	c.category_names = data["category_names"]
	c.stamp_groups = PackedStringArray(data.get("stamp_groups", []))
	var stamps: Array[Dictionary] = []
	for s in data["stamps"]:
		var size := Vector2i(int(s["size"][0]), int(s["size"][1]))
		var variants := []
		# Formato viejo (sin variantes): un sello = una variante.
		for v in s.get("variants", [s]):
			variants.append({"name": v.get("name", ""), "id": v.get("id", ""), "map": v.get("map", ""),
				"cells": PackedInt32Array(v["cells"]), "solid": PackedInt32Array(v.get("solid", [])),
				"doors": PackedInt32Array(v.get("doors", [])), "ref_diff": int(v.get("ref_diff", 0))})
		stamps.append({"id": s.get("id", ""), "name": s["name"], "group": s.get("group", "Edificios"),
			"place": s.get("place", ""), "size": size, "maps": int(s.get("maps", 1)), "variants": variants})
	c.stamps = stamps
	var sheet: Dictionary = data.get("palette_sheet", {})
	if not sheet.is_empty():
		c.sheet_size = Vector2i(int(sheet["size"][0]), int(sheet["size"][1]))
		var cells := PackedInt32Array()
		cells.resize(c.sheet_size.x * c.sheet_size.y)
		cells.fill(-1)
		for e in sheet["cells"]:
			cells[int(e[1]) * c.sheet_size.x + int(e[0])] = int(e[2])
		c.sheet_cells = cells
		var secs: Array[Dictionary] = []
		for s in sheet["sections"]:
			secs.append({"name": s["name"], "category": s["category"],
				"rect": Rect2i(int(s["rect"][0]), int(s["rect"][1]), int(s["rect"][2]), int(s["rect"][3]))})
		c.sheet_sections = secs
	return c


## Metatiles que en algún sello tienen otra colisión que la del tile (id -> {true: necesita "sólido",
## false: necesita "caminable"}): el TileSet les agrega tiles alternativos con esa colisión.
func collision_alternatives(roles: TileRoleSet) -> Dictionary:
	var out := {}
	for s in stamps:
		for v in s["variants"]:
			var cells: PackedInt32Array = v["cells"]
			var solid: PackedInt32Array = v["solid"]
			for i in mini(cells.size(), solid.size()):
				var m := cells[i]
				if m < 0:
					continue
				var tile_solid := roles.physics_for(m) == 0
				if (solid[i] == 1) != tile_solid:
					out.get_or_add(m, {})[solid[i] == 1] = true
	return out
