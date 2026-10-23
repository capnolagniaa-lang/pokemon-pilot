extends SceneTree
## Arma los 3 entrenadores vivos del prototipo (docs/PLAN_ENTRENADORES.md, sección 4) y los guarda en
## data/trainers/<id>.tres. Después se pueden ajustar a mano en el inspector; correr esto de nuevo los pisa.
## Uso: godot --headless --path . --quit-after 3000 --script res://tools/build_trainers.gd

## Celdas relativas a la plaza (hub) de cada zona.
const TRAINERS := [
	{"id": "azul", "name": "Azul", "title": "Rival", "sprite": "res://art/pret/characters/blue.png",
		"personality": {"encounters_to_learn": 2, "max_intelligence": 2, "pride": 0.85, "aggression": 0.85,
			"curiosity": 0.15, "misread_chance": 0.25},
		"team": [["charmander", 8], ["rattata", 7]],
		"routine": [[8, 12, "ruta1", Vector2i(5, -3), "entrenar"], [12, 14, "ruta1", Vector2i(-7, -4), "descansar"],
			[14, 19, "ruta1", Vector2i(0, 6), "buscar_rival"], [19, 8, "ruta1", Vector2i(-7, -4), "descansar"]],
		"lines": {"saludo": "¡Eh! ¿Vos de nuevo?", "desafio": "¡Vamos, a ver quién es mejor!",
			"gana": "¡Ja! Te falta entrenar.", "pierde": "¡Tuviste suerte! La próxima no te escapás."}},
	{"id": "valeria", "name": "Valeria", "title": "Estratega", "sprite": "res://art/pret/characters/cooltrainer_f.png",
		"personality": {"encounters_to_learn": 3, "max_intelligence": 3, "pride": 0.4, "aggression": 0.3,
			"curiosity": 0.3, "misread_chance": 0.1},
		"team": [["bellsprout", 8], ["pidgey", 8]],
		"routine": [[9, 13, "ruta1", Vector2i(-6, 3), "entrenar"], [15, 18, "bosque_verde", Vector2i(0, 0), "entrenar"],
			[18, 9, "ruta1", Vector2i(-6, 3), "descansar"]],
		"lines": {"saludo": "Hola. Te estuve observando.", "desafio": "Probemos una idea que tengo.",
			"gana": "Tal como lo planeé.", "pierde": "Interesante... lo voy a anotar."}},
	{"id": "tomas", "name": "Tomás", "title": "Explorador", "sprite": "res://art/pret/characters/camper.png",
		"personality": {"encounters_to_learn": 2, "max_intelligence": 2, "pride": 0.15, "aggression": 0.5,
			"curiosity": 0.85, "misread_chance": 0.2},
		"team": [["vulpix", 8]],
		"routine": [[7, 12, "ruta1", Vector2i(9, 4), "explorar"], [12, 17, "ruta22", Vector2i(0, 0), "explorar"],
			[17, 21, "ruta2", Vector2i(0, 2), "explorar"], [21, 7, "ruta1", Vector2i(9, 4), "descansar"]],
		"lines": {"saludo": "¡Hola! ¿Viste algún Pokémon raro por acá?", "desafio": "¡Mirá lo que encontré! ¿Peleamos?",
			"gana": "¡Mi equipo nuevo funciona!", "pierde": "Uh... mañana pruebo con otro."}},
]


func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://data/trainers")
	var world: WorldData = load("res://data/world/kanto.tres")
	for t in TRAINERS:
		var data := TrainerData.new()
		data.id = t["id"]
		data.display_name = t["name"]
		data.title = t["title"]
		data.sprite = load(t["sprite"])
		var p := PersonalityData.new()
		for key in t["personality"]:
			p.set(key, t["personality"][key])
		data.personality = p
		var team: Array[TrainerMon] = []
		for row in t["team"]:
			var mon := TrainerMon.new()
			mon.species = load("res://data/species/%s.tres" % row[0])
			mon.level = row[1]
			team.append(mon)
		data.starting_team = team
		var routine: Array[RoutineBlock] = []
		for row in t["routine"]:
			var b := RoutineBlock.new()
			b.start_hour = row[0]
			b.end_hour = row[1]
			b.zone_id = row[2]
			b.cell = row[3]
			for z in world.zones:
				if z.id == row[2]:
					# la celda transitable más cercana (las zonas son mapas reales: al lado de la plaza puede haber
					# un edificio o un árbol)
					var node: Node = load(z.scene_path).instantiate()
					b.cell = MapRules.nearest_walkable(node, z, z.hub + row[3])
					node.free()
			b.activity = row[4]
			routine.append(b)
		data.routine = routine
		data.lines = t["lines"]
		var path := "res://data/trainers/%s.tres" % data.id
		print(path, " -> ", ResourceSaver.save(data, path))
	quit()
