extends SceneTree
## Arma el learnset (movimientos por nivel) de cada especie y lo guarda en su .tres (SpeciesData.learnset).
## Regla (decisión del usuario, Etapa 2c): los 4 movimientos del kit (o los sueltos, si no tiene kit) se
## aprenden en los niveles 1, 1, 3 y 5, así el estilo de pelea está desde el principio; después, **todo su learnset
## de FireRed/LeafGreen** (data/source/official.json → "learnset"; pedido del usuario 2026-10-26) más los EXTRAS a
## mano (los marcados (*) no están en el learnset de FRLG y usan un nivel parecido). Lo que el kit ya tiene (mismo
## nombre) no se repite.
## Las especies sin kit ni EXTRAS (las 3 regiones) usan el learnset oficial completo de FRLG ("learnset").
## Uso: godot --headless --path . --script res://tools/build_learnsets.gd

## especie -> [[nivel, id en data/moves], ...]
const EXTRAS := {
	"bulbasaur": [[20, "hoja_afilada"], [46, "rayo_solar"]],
	"charmander": [[31, "lanzallamas"], [37, "cuchillada"]],
	"squirtle": [[18, "mordisco"], [47, "hidrobomba"]],
	"pidgey": [[25, "ataque_ala"], [31, "rapidez"]],  # (*) Rapidez es MT en FRLG
	"rattata": [[27, "persecucion"], [41, "derribo"]],  # (*) Derribo: Rattata no lo aprende por nivel
	"pikachu": [[26, "rayo"], [33, "rapidez"]],  # (*) Rapidez es MT
	"vulpix": [[13, "ataque_rapido"], [41, "giro_fuego"]],
	"oddish": [[23, "acido"], [36, "rayo_solar"]],  # (*) Rayo Solar es MT
	"psyduck": [[40, "aranazo"], [50, "hidrobomba"]],
	"growlithe": [[25, "derribo"], [31, "rueda_fuego"]],
	"poliwag": [[31, "golpe_cuerpo"], [43, "hidrobomba"]],
	"bellsprout": [[23, "acido"], [37, "hoja_afilada"]],
	"seel": [[17, "viento_hielo"], [41, "rayo_hielo"]],
	"eevee": [[30, "mordisco"], [42, "derribo"]],
	# v3 (2026-10-23): kits nuevos de Paras y Geodude, extras de su learnset de FRLG.
	"paras": [[31, "cuchillada"], [43, "gigadrenado"]],
	"geodude": [[16, "magnitud"], [36, "terremoto"]],
	# v4 (2026-10-23): kits de Kanto hasta Ciudad Plateada. Caterpie/Weedle/Metapod/Kakuna no aprenden más.
	"spearow": [[25, "ataque_aereo"], [31, "ataque_furia"]],
	"mankey": [[16, "golpes_furia"], [26, "golpe_karate"]],
	"sandshrew": [[17, "cuchillada"], [30, "rapidez"]],
	"onix": [[23, "furia"], [40, "excavar"]],
}
const BASE_LEVELS := [1, 1, 3, 5]


func _init() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/source/official.json"))
	for f in DirAccess.get_files_at("res://data/species"):
		if not f.ends_with(".tres"):
			continue
		var path := "res://data/species/" + f
		var sp: SpeciesData = load(path)
		sp.tm_moves = _tms(sp, data["species"].get(sp.id, {}).get("mt", []))
		if sp.kit == null:  # (desde las habilidades, 2026-10-28: todas sin kit → el learnset oficial de FRLG)
			_official(sp, path, data["species"].get(sp.id, {}).get("learnset", []))
			continue
		var entries: Array[LearnsetEntry] = []
		var base: Array[MoveData] = sp.kit.moves if sp.kit != null else sp.moves
		var names := []
		for i in base.size():
			entries.append(_entry(BASE_LEVELS[mini(i, 3)], base[i]))
			names.append(base[i].display_name)
		# Kit heredado de su preevolución (tools/apply_evolutions.gd): además, el learnset oficial de la evolucionada.
		# Todo lo que aprende en FRLG (pedido del usuario 2026-10-26: "todos los movimientos de la wiki tienen que
		# poder elegirse") + los extras a mano (algunos son MT en FRLG), por nivel.
		var extras: Array = data["species"].get(sp.id, {}).get("learnset", []).duplicate()
		extras.append_array(EXTRAS.get(sp.id, []))
		extras.sort_custom(func(x, y): return int(x[0]) < int(y[0]))
		for row in extras:
			var m: MoveData = load("res://data/moves/%s.tres" % row[1])
			# No repetir un movimiento que el kit ya tiene con otra forma (Ascuas del kit vs. Ascuas suelta).
			if m == null or names.has(m.display_name):
				continue
			entries.append(_entry(int(row[0]), m))
			names.append(m.display_name)
		sp.learnset = entries
		var err := ResourceSaver.save(sp, path)
		print("%s: %s %s" % [sp.id, names, "OK" if err == OK else "ERROR %d" % err])
	quit()


## Especies sin kit ni extras a mano (las de las 3 regiones): el learnset oficial completo de FRLG.
func _official(sp: SpeciesData, path: String, rows: Array) -> void:
	var entries: Array[LearnsetEntry] = []
	var seen := {}
	for row in rows:
		var m: MoveData = load("res://data/moves/%s.tres" % row[1])
		if m == null or seen.has(m):
			continue
		seen[m] = true
		entries.append(_entry(int(row[0]), m))
	sp.learnset = entries
	if ResourceSaver.save(sp, path) != OK:
		print("%s: ERROR al guardar" % sp.id)


## Sus MT/MO de FRLG (official.json "mt"). Si el kit tiene un ataque con el mismo nombre, va el del kit.
func _tms(sp: SpeciesData, ids: Array) -> Array[MoveData]:
	var by_name := {}
	if sp.kit != null:
		for km in sp.kit.moves:
			by_name[km.display_name] = km
	var out: Array[MoveData] = []
	for id in ids:
		if not ResourceLoader.exists("res://data/moves/%s.tres" % id):
			continue
		var m: MoveData = load("res://data/moves/%s.tres" % id)
		m = by_name.get(m.display_name, m)
		if not out.has(m):
			out.append(m)
	return out


func _entry(level: int, m: MoveData) -> LearnsetEntry:
	var e := LearnsetEntry.new()
	e.level = level
	e.move = m
	return e
