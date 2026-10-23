extends SceneTree
## Crea las tablas de encuentros iniciales (si no existen): una por bioma con las especies que tenía el
## spawner provisorio y la de Ruta 1 con los 4 de la fase de prueba del combate. Uso único:
## godot --headless --path . --quit-after 2000 --script res://tools/dev/make_default_encounters.gd

# bioma -> [niveles mín, máx, [especie, dónde]...]
const BIOMES := {
	"pradera": [2, 5, ["rattata", "pasto_alto"], ["pidgey", "pasto_alto"], ["oddish", "pasto_alto"], ["eevee", "pasto_alto"]],
	"pradera_florida": [3, 6, ["oddish", "pasto_alto"], ["bellsprout", "pasto_alto"], ["pidgey", "pasto_alto"], ["vulpix", "pasto_alto"]],
	"bosque": [4, 7, ["oddish", "pasto_alto"], ["bellsprout", "pasto_alto"], ["pikachu", "pasto_alto"], ["pidgey", "pasto_alto"]],
	"bosque_denso": [5, 8, ["bellsprout", "pasto_alto"], ["oddish", "pasto_alto"], ["pikachu", "pasto_alto"]],
	"lago": [5, 8, ["psyduck", "agua"], ["poliwag", "agua"], ["seel", "agua"], ["pidgey", "pasto_alto"]],
	"rocoso": [6, 9, ["growlithe", "pasto_alto"], ["vulpix", "pasto_alto"], ["rattata", "pasto_alto"]],
	"humedal": [4, 7, ["poliwag", "agua"], ["psyduck", "agua"], ["oddish", "pasto_alto"]],
	"arboleda": [4, 7, ["pikachu", "pasto_alto"], ["eevee", "pasto_alto"], ["pidgey", "pasto_alto"], ["growlithe", "pasto_alto"]],
}


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EncounterTable.DIR + "/biomas"))
	for b in BIOMES:
		var spec: Array = BIOMES[b]
		var t := EncounterTable.new()
		var rows := spec.slice(2)
		for r in rows:
			t.entries.append(_row(r[0], 100 / rows.size(), spec[0], spec[1], r[1]))
		_save(t, EncounterTable.biome_path(b))
	var r1 := EncounterTable.new()
	for r in [["pidgey", 35], ["rattata", 35], ["bellsprout", 15], ["vulpix", 15]]:
		r1.entries.append(_row(r[0], r[1], 2, 5, "pasto_alto"))
	_save(r1, EncounterTable.zone_path("ruta1"))
	quit()


func _row(sp: String, w: int, lo: int, hi: int, where: String) -> EncounterEntry:
	var e := EncounterEntry.new()
	e.species_id = sp
	e.weight = w
	e.min_level = lo
	e.max_level = hi
	e.where = where
	return e


func _save(t: EncounterTable, path: String) -> void:
	if ResourceLoader.exists(path):
		print("ya existe: ", path)
		return
	print(path, " -> ", ResourceSaver.save(t, path))
