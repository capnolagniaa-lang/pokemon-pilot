extends SceneTree
## Devuelve las filas de agua de FireRed (las de Surf) a las tablas de salvajes de las zonas importadas, sin tocar las
## demás filas ni las áreas pintadas. Al importar se habían sacado porque no había Surf; ahora salen solo mientras
## navegás (WildSpawner). Crea la tabla si la zona no tenía (rutas de puro mar, como la 19).
##   godot --headless --path . --quit-after 20000 --script res://tools/add_water_encounters.gd

func _init() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world/frlg_maps.json"))
	var templates := {}
	for t in EncounterTable.templates():
		templates[t["id"]] = t
	var changed := 0
	for z: Dictionary in data["zones"]:
		var tpl: String = z.get("template", "")
		if not templates.has(tpl):
			continue
		var water: Array[EncounterEntry] = []
		water.assign(EncounterTable.from_template(templates[tpl]).entries.filter(
			func(r: EncounterEntry) -> bool: return r.where == "agua"))
		if water.is_empty():
			continue
		var path := EncounterTable.zone_path(z["id"])
		var table: EncounterTable = load(path) if ResourceLoader.exists(path) else EncounterTable.new()
		if table.entries.any(func(r: EncounterEntry) -> bool: return r.where == "agua"):
			continue  # ya tiene (o se editaron a mano): no se pisa
		table.entries.append_array(water)
		ResourceSaver.save(table, path)
		changed += 1
		print("%-22s +%d filas de agua (%s)" % [z["id"], water.size(), ", ".join(water.map(func(r): return r.species_id))])
	print("tablas con agua: ", changed)
	quit()
