extends SceneTree
## Pasa data/source/evolutions.json (tools/fetch_evolutions.py) a las especies: SpeciesData.evolutions y
## evolves_from. Kits (decisión del usuario 2026-10-25): la especie evolucionada sin kit propio hereda el de su
## preevolución (kit_inherited = true) y pelea igual, salvo las de NEW_KIT, que cambian mucho su forma de pelear y
## esperan un kit propio (hasta entonces pelean con sus movimientos de FRLG). Un kit propio nunca se pisa.
## Después correr tools/build_learnsets.gd (el learnset de las que heredan: kit + el oficial de FRLG).
## Uso: godot --headless --path . --quit-after 20000 --script res://tools/apply_evolutions.gd

## Cambian mucho al evolucionar (alas, otro tipo, otra forma de atacar): no heredan el kit.
const NEW_KIT := ["butterfree", "beedrill", "gyarados", "kadabra", "charizard", "vaporeon", "jolteon",
	"flareon", "espeon", "umbreon", "dustox", "beautifly", "ninjask", "shedinja"]

## Intercambio y amistad no existen en el juego: como en los fangames (decisión del usuario 2026-11-03), los de
## intercambio simple evolucionan por nivel, los de intercambio con objeto usando ese objeto como una piedra
## (data/items, se venden en el 4º piso del Gran Almacén de Azulona) y los de amistad por nivel (Espeon de día,
## Umbreon de noche). Clave: especie destino.
const FANGAME := {
	"alakazam": {"method": "nivel", "level": 37}, "machamp": {"method": "nivel", "level": 37},
	"golem": {"method": "nivel", "level": 37}, "gengar": {"method": "nivel", "level": 37},
	"steelix": {"method": "piedra", "item": "revestimiento_metalico"},
	"scizor": {"method": "piedra", "item": "revestimiento_metalico"},
	"kingdra": {"method": "piedra", "item": "escama_dragon"}, "slowking": {"method": "piedra", "item": "roca_del_rey"},
	"politoed": {"method": "piedra", "item": "roca_del_rey"}, "porygon2": {"method": "piedra", "item": "mejora"},
	"huntail": {"method": "piedra", "item": "diente_marino"}, "gorebyss": {"method": "piedra", "item": "escama_marina"},
	"milotic": {"method": "nivel", "level": 30},
	"pikachu": {"method": "nivel", "level": 15, "from": "pichu"}, "clefairy": {"method": "nivel", "level": 15, "from": "cleffa"},
	"jigglypuff": {"method": "nivel", "level": 15, "from": "igglybuff"}, "togetic": {"method": "nivel", "level": 15},
	"marill": {"method": "nivel", "level": 15, "from": "azurill"}, "crobat": {"method": "nivel", "level": 40},
	"blissey": {"method": "nivel", "level": 40},
	"espeon": {"method": "nivel", "level": 25, "time": "dia"}, "umbreon": {"method": "nivel", "level": 25, "time": "noche"},
}


func _initialize() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/source/evolutions.json"))
	var species := {}
	for f in DirAccess.get_files_at("res://data/species"):
		if f.ends_with(".tres"):
			var sp: SpeciesData = load("res://data/species/" + f)
			species[sp.id] = sp
	var parent := {}
	for from_id in data:
		for e in data[from_id]:
			parent[e["to"]] = from_id
	for sp: SpeciesData in species.values():
		sp.evolutions.clear()
		for e in data.get(sp.id, []):
			var ev := EvolutionData.new()
			ev.to_id = e["to"]
			ev.method = e["method"]
			ev.level = int(e.get("level", 0))
			ev.item = str(e.get("item", ""))
			ev.stats_cond = int(e.get("stats", 99))
			var fan: Dictionary = FANGAME.get(ev.to_id, {})
			if (ev.method == "intercambio" or ev.method == "amistad") and not fan.is_empty() 					and str(fan.get("from", sp.id)) == sp.id:
				ev.method = fan["method"]
				ev.level = int(fan.get("level", 0))
				ev.item = str(fan.get("item", ""))
				ev.time = str(fan.get("time", ""))
			sp.evolutions.append(ev)
		sp.evolves_from = parent.get(sp.id, "")
		if sp.kit_inherited:
			sp.kit = null  # se vuelve a heredar abajo (por si cambió el de la preevolución)
			sp.kit_inherited = false
	# Herencia en orden de Pokédex (la preevolución ya resolvió la suya).
	var by_dex: Array = species.values()
	by_dex.sort_custom(func(a, b): return a.dex < b.dex)
	var inherited := []
	for sp: SpeciesData in by_dex:
		var from: SpeciesData = species.get(sp.evolves_from)
		if sp.kit == null and from != null and from.kit != null and not NEW_KIT.has(sp.id):
			sp.kit = from.kit
			sp.kit_inherited = true
			inherited.append(sp.id)
	var errors := 0
	for sp: SpeciesData in by_dex:
		if ResourceSaver.save(sp, sp.resource_path) != OK:
			errors += 1
	print("evoluciones: %d especies evolucionan | heredan el kit: %s | errores: %d" % [data.size(), inherited, errors])
	quit()
