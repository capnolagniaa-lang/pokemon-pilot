extends SceneTree
## Exporta el "plano" de una zona 2D para construirla en 3D: por celda, qué hay (pasto, camino, agua, árbol, edificio,
## cerca, cartel, saliente, flores, pasto alto) y si choca; más las puertas. No lleva dibujos: solo el plano.
## Uso: Godot --headless --path . --quit-after 20000 --script res://tools/export_plan3d.gd -- <zona> [<zona>...]
## Sale en res://data/plan3d/<zona>.json

const CATALOG := "res://art/pret/tiles/catalog.json"
# categoría del catálogo -> letra del plano
const KIND := {
	"suelos": "g", "caminos": "p", "agua": "w", "arboles": "T", "flores": "f", "salientes": "L", "cercas": "F",
	"rocas": "R", "carteles": "S", "escaleras": "s", "cuevas": "C", "adornos": "A", "edificios": "B",
	"otros_terreno": "g", "otros_pasto": "g", "otros_arena": "p", "otros_agua": "w", "otros_arboles": "T",
	"otros_rocas": "R", "otros_edificios": "B", "otros_puertas": "B", "otros_escaleras": "s", "otros_salientes": "L",
	"otros_carteles": "S", "otros_obstaculos": "A", "otros_suelo": "g", "otros_suelo_especial": "g",
}


func _init() -> void:
	var cat: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CATALOG))
	var cats: Dictionary = cat["categories"]
	var tags: Dictionary = cat["tags"]
	var world: WorldData = load(ZoneBuilder.WORLD_PATH)
	DirAccess.make_dir_recursive_absolute("res://data/plan3d")
	for id in OS.get_cmdline_user_args():
		var entry: ZoneEntry = null
		for z in world.zones:
			if z.id == id:
				entry = z
		if entry == null:
			print("no existe la zona ", id)
			continue
		var zone: Node = (load(entry.scene_path) as PackedScene).instantiate()
		root.add_child(zone)
		var layers: Array[TileMapLayer] = []
		for n in ["Ground", "Water", "Foliage", "Overhead"]:
			layers.append(zone.get_node(n) as TileMapLayer)
		var objects := MapRules.objects_by_cell(zone)
		var rows: Array = []
		var solid: Array = []
		var seen := {}
		for y in entry.size.y:
			var row := ""
			var srow := ""
			for x in entry.size.x:
				var cell := Vector2i(x, y)
				var kind := "g"
				var tall := false
				# manda lo más alto que haya en la celda (edificio o árbol por encima del suelo)
				for li in [0, 1, 2, 3]:
					var mt := ZoneBuilder.metatile_at(layers[li], cell)
					if mt < 0:
						continue
					var c: String = cats.get(str(mt), "")
					seen[c] = int(seen.get(c, 0)) + 1
					var k: String = KIND.get(c, "")
					if k == "":
						continue
					if k in ["B", "T"] or (kind not in ["B", "T"]):
						kind = k
					if "pasto_alto" in tags.get(str(mt), []):
						tall = true
				if tall and kind == "g":
					kind = "h"
				var ph := MapRules.cell_physics(zone, cell, objects)
				row += kind
				srow += "1" if ph == MapRules.SOLID else ("2" if ph == MapRules.WATER else "0")
			rows.append(row)
			solid.append(srow)
		var warps: Array = []
		for c: Vector2i in entry.warps:
			warps.append({"x": c.x, "y": c.y, "to": str(entry.warps[c].get("to", ""))})
		var out := {"id": id, "name": entry.display_name, "w": entry.size.x, "h": entry.size.y, "cells": rows,
			"solid": solid, "warps": warps}
		var f := FileAccess.open("res://data/plan3d/%s.json" % id, FileAccess.WRITE)
		f.store_string(JSON.stringify(out, " "))
		f.close()
		print(id, " ", entry.size, " categorias: ", seen)
		zone.queue_free()
	quit()
