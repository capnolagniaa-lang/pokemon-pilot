extends SceneTree
## Arma las arenas de combate contra entrenadores (docs/PLAN_ENTRENADORES.md, E-1) con tiles reales de FireRed:
##  · arena_campo: claro rodeado de pinos (pasto de la Ruta 22) para los entrenadores de ruta y del bosque;
##  · arena_gimnasio_roca: el gimnasio de Brock, agrandado y épico (paredes, tierra, rocas, la plataforma de piedra
##    del líder y rocas que se rompen), con ambientación de tipo roca.
## Escribe scenes/world/arenas/<id>.tscn (zonas como las del mundo: se pueden retocar con el editor de mapas) y
## data/arenas/<id>.tres (ArenaData). Correrlo de nuevo PISA las escenas.
## Uso: godot --headless --path . --quit-after 20000 --script res://tools/build_arenas.gd

const ARENAS_DIR := "res://scenes/world/arenas"
const DATA_DIR := "res://data/arenas"
const ROCK := "res://scenes/world/objects/rock_smash_rock.tscn"

## Metatiles del gimnasio de Plateada (pewter_gym): filas 0-3 = pared de arriba, 35008/35015 paredes de los
## costados, 35019 sombra de la pared, 35020 tierra, 35035 roca, 35040-35043 tablones, 35044-35055 plataforma.
const TOP := [
	[35000, 35001, 35002, 35002, 35021, 35006, 35007],
	[35008, 35009, 35010, 35010, 35011, 35014, 35015],
	[35008, 35017, 35018, 35018, 35018, 35022, 35015],
	[35008, 35025, 35026, 35028, 35028, 35029, 35030],
]
const PLATFORM := [
	[35035, 35044, 35045, 35046, 35035],
	[35051, 35052, 35053, 35054, 35055],
	[35048, 35036, 35037, 35036, 35048],
]

var tileset: TileSet
var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.seed = 7
	tileset = load(ZoneBuilder.TILESET_PATH)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ARENAS_DIR))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DATA_DIR))
	_campo()
	_gimnasio_roca()
	quit()


# --- Claro de pinos (Ruta 22) ----------------------------------------------------------------------

func _campo() -> void:
	var w := 36
	var h := 26
	var b := 4  # dos pinos de profundidad
	var root := ZoneBuilder.new_zone_root("arena_campo", tileset)
	var g: TileMapLayer = root.get_node("Ground")
	var grass := [1, 1, 1, 8, 9, 16, 17]
	for y in h:
		for x in w:
			var m: int
			if x < b or x >= w - b or y < b or y >= h - b:
				m = (22 if x % 2 == 0 else 23) if y % 2 == 0 else (30 if x % 2 == 0 else 31)  # pinos 2×2
			else:
				m = grass[rng.randi() % grass.size()]
			ZoneBuilder.set_metatile(g, Vector2i(x, y), m)
	root.set("hand_edited", true)
	_save(root, "arena_campo")
	var a := ArenaData.new()
	a.id = "arena_campo"
	a.display_name = "Claro de combate"
	a.scene_path = "%s/arena_campo.tscn" % ARENAS_DIR
	a.field = Rect2i(b + 1, b + 1, w - 2 * b - 2, h - 2 * b - 2)
	a.foe_trainer_cell = Vector2i(w / 2, b + 1)
	a.foe_mon_cell = Vector2i(w / 2, b + 5)
	a.player_cell = Vector2i(w / 2, h - b - 2)
	a.player_mon_cell = Vector2i(w / 2, h - b - 6)
	a.line_color = Color(1, 1, 1, 0.28)
	a.particles = "hojas"
	a.particle_color = Color(0.55, 0.85, 0.4, 0.7)
	ResourceSaver.save(a, "%s/arena_campo.tres" % DATA_DIR)


# --- Gimnasio de roca (Brock) ----------------------------------------------------------------------

func _gimnasio_roca() -> void:
	var w := 40
	var h := 30
	var cx := w / 2
	var root := ZoneBuilder.new_zone_root("arena_gimnasio_roca", tileset)
	var g: TileMapLayer = root.get_node("Ground")
	for y in h:
		for x in w:
			var m := 35020
			if y < 4:
				var row: Array = TOP[y]
				if x == 0:
					m = row[0]
				elif x == 1:
					m = row[1]
				elif x == w - 2:
					m = row[5]
				elif x == w - 1:
					m = row[6] if y < 3 else 35015
				elif x == cx and y == 0:
					m = row[4]  # adorno del centro de la pared
				elif y == 3:
					m = row[2] if x == 2 else (row[5] if x == w - 3 else row[3])
				else:
					m = row[2] if x % 2 == 0 else row[3]
			elif y >= h - 3:
				var k := y - (h - 3)
				if x == 0:
					m = [35016, 35024, 35032][k]
				elif x == w - 1:
					m = [35023, 35031, 35039][k]
				else:
					m = 35040 if x == 1 else 35042
			elif x == 0:
				m = 35008
			elif x == w - 1:
				m = 35015
			elif x == 1:
				m = 35019
			ZoneBuilder.set_metatile(g, Vector2i(x, y), m)
	# Pasarela de tablones donde se para el jugador, como en el gimnasio.
	for x in range(2, w - 1):
		ZoneBuilder.set_metatile(g, Vector2i(x, h - 4), 35041 if x == 2 else (35043 if x == w - 2 else 35042))
	# Plataforma de piedra del líder, arriba al centro.
	for py in PLATFORM.size():
		for px in PLATFORM[py].size():
			ZoneBuilder.set_metatile(g, Vector2i(cx - 2 + px, 5 + py), PLATFORM[py][px])
	# Rocas (cubiertas) en simetría y rocas que se rompen.
	for p in [Vector2i(7, 10), Vector2i(12, 15), Vector2i(6, 19), Vector2i(14, 21), Vector2i(10, 12), Vector2i(16, 9)]:
		ZoneBuilder.set_metatile(g, p, 35035)
		ZoneBuilder.set_metatile(g, Vector2i(w - 1 - p.x, p.y), 35035)
	for p in [Vector2i(11, 18), Vector2i(17, 13)]:
		ZoneBuilder.add_object(root, ROCK, p)
		ZoneBuilder.add_object(root, ROCK, Vector2i(w - 1 - p.x, p.y))
	root.set("hand_edited", true)
	_save(root, "arena_gimnasio_roca")
	var a := ArenaData.new()
	a.id = "arena_gimnasio_roca"
	a.display_name = "Gimnasio de Ciudad Plateada"
	a.scene_path = "%s/arena_gimnasio_roca.tscn" % ARENAS_DIR
	a.field = Rect2i(4, 9, w - 8, h - 15)
	a.foe_trainer_cell = Vector2i(cx, 6)
	a.foe_mon_cell = Vector2i(cx, 11)
	a.player_cell = Vector2i(cx, h - 4)
	a.player_mon_cell = Vector2i(cx, h - 8)
	a.element_id = "roca"
	a.line_color = Color(1.0, 0.92, 0.75, 0.32)
	a.particles = "polvo"
	a.particle_color = Color(0.85, 0.72, 0.5, 0.55)
	a.braziers = true
	a.ambient = Color(1.0, 0.94, 0.86)
	a.epic = true
	ResourceSaver.save(a, "%s/arena_gimnasio_roca.tres" % DATA_DIR)


func _save(root: Node, id: String) -> void:
	var err := ZoneBuilder.save_zone(root, "%s/%s.tscn" % [ARENAS_DIR, id])
	print(id, ": ", "OK" if err == OK else "ERROR %d" % err)
	root.free()
