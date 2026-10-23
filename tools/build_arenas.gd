extends SceneTree
## Arma las arenas de combate contra entrenadores (docs/PLAN_ENTRENADORES.md, E-1) con tiles reales de FireRed:
##  · arena_campo: claro rodeado de pinos (pasto de la Ruta 22) para los entrenadores de ruta y del bosque;
##  · arena_gimnasio_roca: el gimnasio de Brock, agrandado y épico (paredes, tierra, rocas, la plataforma de piedra
##    del líder y rocas que se rompen), con ambientación de tipo roca;
##  · arena_torneo: el estadio del Torneo de Plateada (docs/PLAN_TORNEO.md): cancha de tierra, dos lagunas, pasto alto
##    en las esquinas (se prende fuego), rocas de cobertura y rocas que se rompen, con tribunas y luces.
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
	_torneo()
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


# --- Estadio del torneo -----------------------------------------------------------------------------------

## Pinta un rectángulo con un rol de autotile 3×3 (agua, tierra) en su capa.
func _autotile(layer: TileMapLayer, role: TileRole, rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var c := Vector2i(x, y)
			ZoneBuilder.set_metatile(layer, c, ZoneBuilder.autotile_piece(role, func(d): return rect.has_point(c + d)))


func _torneo() -> void:
	var w := 46
	var h := 34
	var cx := w / 2
	var roles := ZoneBuilder.load_roles()
	var root := ZoneBuilder.new_zone_root("arena_torneo", tileset)
	var g: TileMapLayer = root.get_node("Ground")
	var water: TileMapLayer = root.get_node("Water")
	var foliage: TileMapLayer = root.get_node("Foliage")
	var grass := [1, 1, 1, 8, 9, 16, 17]
	# Paredes del estadio (las del gimnasio) y pasto adentro.
	for y in h:
		for x in w:
			var m: int = grass[rng.randi() % grass.size()]
			if y < 4:
				var row: Array = TOP[y]
				m = row[0] if x == 0 else (row[1] if x == 1 else (row[5] if x == w - 2 else (row[6] if x == w - 1 and y < 3
					else (35015 if x == w - 1 else (row[2] if x % 2 == 0 else row[3])))))
				if y == 3 and x > 1 and x < w - 2:
					m = row[2] if x == 2 else (row[5] if x == w - 3 else row[3])
			elif y >= h - 3:
				var k := y - (h - 3)
				m = [35016, 35024, 35032][k] if x == 0 else ([35023, 35031, 35039][k] if x == w - 1 else (35040 if x == 1 else 35042))
			elif x == 0:
				m = 35008
			elif x == w - 1:
				m = 35015
			ZoneBuilder.set_metatile(g, Vector2i(x, y), m)
	# Cancha de tierra en el centro.
	var field := Rect2i(8, 8, w - 16, h - 16)
	_autotile(g, roles.get_role("dirt"), field)
	# Dos lagunas a los costados de la cancha (mojan, frenan, los de agua nadan; el eléctrico las electrifica).
	_autotile(water, roles.get_role("water"), Rect2i(3, h / 2 - 3, 4, 6))
	_autotile(water, roles.get_role("water"), Rect2i(w - 7, h / 2 - 3, 4, 6))
	# Pasto alto en las esquinas (se prende fuego).
	for corner in [Vector2i(3, 5), Vector2i(w - 8, 5), Vector2i(3, h - 9), Vector2i(w - 8, h - 9)]:
		for dy in 3:
			for dx in 5:
				ZoneBuilder.set_metatile(foliage, corner + Vector2i(dx, dy), 13)
	# Rocas de cobertura (simétricas) y rocas que se rompen.
	for p in [Vector2i(12, 12), Vector2i(16, 17), Vector2i(12, 21), Vector2i(cx - 3, 14), Vector2i(cx - 3, 19)]:
		ZoneBuilder.set_metatile(g, p, 35035)
		ZoneBuilder.set_metatile(g, Vector2i(w - 1 - p.x, p.y), 35035)
	for p in [Vector2i(15, 13), Vector2i(15, 20)]:
		ZoneBuilder.add_object(root, ROCK, p)
		ZoneBuilder.add_object(root, ROCK, Vector2i(w - 1 - p.x, p.y))
	# Pasarela de tablones donde se para el jugador.
	for x in range(2, w - 1):
		ZoneBuilder.set_metatile(g, Vector2i(x, h - 4), 35041 if x == 2 else (35043 if x == w - 2 else 35042))
	root.set("hand_edited", true)
	_save(root, "arena_torneo")
	var a := ArenaData.new()
	a.id = "arena_torneo"
	a.display_name = "Estadio del Torneo de Plateada"
	a.scene_path = "%s/arena_torneo.tscn" % ARENAS_DIR
	a.field = field
	a.foe_trainer_cell = Vector2i(cx, 5)
	a.foe_mon_cell = Vector2i(cx, field.position.y + 3)
	a.player_cell = Vector2i(cx, h - 4)
	a.player_mon_cell = Vector2i(cx, field.end.y - 3)
	a.line_color = Color(1, 1, 1, 0.4)
	a.particles = "confeti"
	a.particle_color = Color(1, 1, 1, 0.8)
	a.braziers = true
	a.crowd = true
	a.epic = true
	ResourceSaver.save(a, "%s/arena_torneo.tres" % DATA_DIR)


func _save(root: Node, id: String) -> void:
	var err := ZoneBuilder.save_zone(root, "%s/%s.tscn" % [ARENAS_DIR, id])
	print(id, ": ", "OK" if err == OK else "ERROR %d" % err)
	root.free()
