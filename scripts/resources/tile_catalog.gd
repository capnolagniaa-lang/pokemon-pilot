class_name TileCatalog
extends Resource
## Catálogo de todos los metatiles de FireRed importados (data/world/tile_catalog.tres): categoría por tipo,
## tags y colisión sugeridos y sellos de edificios. Lo genera tools/pret_import.py (con los mapas reales de
## FireRed) y lo pasa a .tres tools/build_world.gd -- --tileset. Los ids son globales: base del tileset
## (general 0, el resto 1000, 2000... según art/pret/tiles/manifest.json → order) + índice local.
## Lo que se corrige a mano en el editor va a TileRoleSet.overrides (así reimportar no lo pisa).

## id global -> clave de categoría ("edificios", "agua"...).
@export var categories: Dictionary = {}
## Orden y nombres para mostrar de las categorías.
@export var category_order: PackedStringArray = []
@export var category_names: Dictionary = {}
## id global -> tags sugeridos (PackedStringArray).
@export var tags: Dictionary = {}
## id global -> colisión sugerida (-1 nada, 0 sólido, 1 agua): la que el metatile tiene casi siempre en los mapas.
@export var physics: Dictionary = {}
## Sellos de edificios: {"name", "place", "size": Vector2i, "cells": PackedInt32Array (por filas, -1 = vacío), "maps"}.
@export var stamps: Array[Dictionary] = []

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
	var stamps: Array[Dictionary] = []
	for s in data["stamps"]:
		stamps.append({"name": s["name"], "place": s["place"], "size": Vector2i(int(s["size"][0]), int(s["size"][1])),
			"cells": PackedInt32Array(s["cells"]), "maps": int(s["maps"])})
	c.stamps = stamps
	return c
