extends SceneTree
## Arma las arenas de combate contra entrenadores (docs/PLAN_ENTRENADORES.md, E-1) con tiles reales de FireRed:
##  · arena_campo: claro rodeado de pinos (pasto de la Ruta 22) para los entrenadores de ruta y del bosque;
##  · arena_gimnasio_roca: el gimnasio de Brock, agrandado y épico (paredes, tierra, rocas, la plataforma de piedra
##    del líder y rocas que se rompen), con ambientación de tipo roca;
##  · arena_torneo: el estadio del Torneo de Plateada (docs/PLAN_TORNEO.md): cancha de tierra, dos lagunas, pasto alto
##    en las esquinas (se prende fuego), rocas de cobertura y rocas que se rompen, con tribunas y luces;
##  · arena_gimnasio_agua: el gimnasio de Misty (Ciudad Celeste, docs/PLAN_CAPITULO_2.md), con los tiles del gimnasio de
##    Celeste: piletas a los costados y dos chicas en el medio (agua de verdad: moja, frena y conduce la electricidad);
##  · arena_gimnasio_electrico: el gimnasio de Lt. Surge (Ciudad Carmín, docs/PLAN_CAPITULO_3.md) con los tiles del
##    gimnasio de Carmín: paredes con máquinas, basureros de cobertura y generadores.
## Escribe scenes/world/arenas/<id>.tscn (zonas como las del mundo: se pueden retocar con el editor de mapas) y
## data/arenas/<id>.tres (ArenaData). Correrlo de nuevo PISA las escenas.
## Uso: godot --headless --path . --quit-after 20000 --script res://tools/build_arenas.gd [-- --only <id>]
## `--only arena_gimnasio_agua` arma solo esa (no pisa las otras).

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
	var args := OS.get_cmdline_user_args()
	var only := args[args.find("--only") + 1] if args.has("--only") and args.find("--only") + 1 < args.size() else ""
	for step in [["arena_campo", _campo], ["arena_gimnasio_roca", _gimnasio_roca], ["arena_torneo", _torneo],
			["arena_gimnasio_agua", _gimnasio_agua], ["arena_gimnasio_electrico", _gimnasio_electrico]] + _themed_steps():
		if only == "" or only == step[0]:
			step[1].call()
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


# --- Gimnasio de agua (Misty) ------------------------------------------------------------------------------

## Metatiles del gimnasio de Celeste (cerulean_gym, base 11000): 1 baldosa, 12 sombra de la pared izquierda, 46/47
## paredes de los costados, filas 0-3 = pared de arriba (5-7, 13-15, 21-23, 29-31; 38/39 esquinas, 20 escudo,
## 75 salvavidas), pileta: 8/9/10 borde de arriba, 16/17/18 costados y agua, 24/25/26 borde de abajo.
const CG := 11000


func _pool(layer: TileMapLayer, rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var col := 0 if x == rect.position.x else (2 if x == rect.end.x - 1 else 1)
			var row := 0 if y == rect.position.y else (2 if y == rect.end.y - 1 else 1)
			ZoneBuilder.set_metatile(layer, Vector2i(x, y), CG + [[8, 9, 10], [16, 17, 18], [24, 25, 26]][row][col])


func _gimnasio_agua() -> void:
	var w := 40
	var h := 30
	var cx := w / 2
	var root := ZoneBuilder.new_zone_root("arena_gimnasio_agua", tileset)
	var g: TileMapLayer = root.get_node("Ground")
	var water: TileMapLayer = root.get_node("Water")
	for y in h:
		for x in w:
			var m := 1
			if x == 0:
				m = 38 if y == 0 else 46
			elif x == w - 1:
				m = 39 if y == 0 else 47
			elif y < 4:
				var row: Array = [[5, 6, 7], [13, 14, 15], [21, 22, 23], [29, 30, 31]][y]
				m = row[0] if x == 1 else (row[2] if x == w - 2 else row[1])
				if y == 0 and x == cx:
					m = 20  # escudo de la Medalla Cascada
				elif y == 1 and x % 6 == 2 and x > 1 and x < w - 2:
					m = 75  # salvavidas colgados
			elif x == 1:
				m = 12
			ZoneBuilder.set_metatile(g, Vector2i(x, y), CG + m)
	# Piletas largas a los costados de la cancha y dos chicas en el medio (cobertura que no tapa los tiros).
	_pool(water, Rect2i(3, 8, 6, 15))
	_pool(water, Rect2i(w - 9, 8, 6, 15))
	_pool(water, Rect2i(cx - 7, 13, 4, 4))
	_pool(water, Rect2i(cx + 3, 13, 4, 4))
	root.set("hand_edited", true)
	_save(root, "arena_gimnasio_agua")
	var a := ArenaData.new()
	a.id = "arena_gimnasio_agua"
	a.display_name = "Gimnasio de Ciudad Celeste"
	a.scene_path = "%s/arena_gimnasio_agua.tscn" % ARENAS_DIR
	a.field = Rect2i(10, 7, w - 20, h - 12)
	a.foe_trainer_cell = Vector2i(cx, 5)
	a.foe_mon_cell = Vector2i(cx, 9)
	a.player_cell = Vector2i(cx, h - 3)
	a.player_mon_cell = Vector2i(cx, h - 7)
	a.element_id = "agua"
	a.line_color = Color(0.85, 0.95, 1.0, 0.35)
	a.particles = "burbujas"
	a.particle_color = Color(0.7, 0.9, 1.0, 0.55)
	a.ambient = Color(0.9, 0.97, 1.05)
	a.epic = true
	ResourceSaver.save(a, "%s/arena_gimnasio_agua.tres" % DATA_DIR)


# --- Arenas temáticas: el resto de los gimnasios y el Alto Mando (docs/PLAN_RESTO_KANTO.md) ------------------------

## id → [nombre, tipo, piso (rol), detalles, partículas, color de partículas, ambiente]. Detalles: "piletas", "pasto"
## (pasto alto: se prende), "flores", "rocas" (cobertura), "rompibles", "braseros", "publico".
const THEMED := {
	"arena_gimnasio_planta": ["Gimnasio de Ciudad Azulona", "planta", "grass", ["flores", "pasto"], "hojas",
		Color(0.55, 0.9, 0.45, 0.7), Color(0.97, 1.04, 0.95)],
	"arena_gimnasio_veneno": ["Gimnasio de Ciudad Fucsia", "veneno", "stone_floor", ["rocas", "piletas"], "polvo",
		Color(0.75, 0.45, 0.9, 0.55), Color(0.97, 0.9, 1.04)],
	"arena_gimnasio_psiquico": ["Gimnasio de Ciudad Azafrán", "psiquico", "city_floor", ["rocas"], "polvo",
		Color(1.0, 0.55, 0.85, 0.55), Color(1.03, 0.95, 1.03)],
	"arena_gimnasio_fuego": ["Gimnasio de Isla Canela", "fuego", "dirt", ["rocas", "braseros", "pasto"], "polvo",
		Color(1.0, 0.55, 0.25, 0.6), Color(1.05, 0.97, 0.92)],
	"arena_gimnasio_tierra": ["Gimnasio de Ciudad Verde", "tierra", "sand", ["rocas", "rompibles", "braseros"], "polvo",
		Color(0.85, 0.7, 0.45, 0.6), Color(1.02, 0.98, 0.92)],
	"arena_liga_hielo": ["Alto Mando: Lorelei", "hielo", "stone_floor", ["piletas", "braseros"], "polvo",
		Color(0.92, 0.97, 1.0, 0.7), Color(0.93, 0.98, 1.06)],
	"arena_liga_lucha": ["Alto Mando: Bruno", "lucha", "dirt", ["rocas", "rompibles", "braseros"], "polvo",
		Color(0.85, 0.72, 0.5, 0.55), Color(1.03, 0.98, 0.94)],
	"arena_liga_fantasma": ["Alto Mando: Agatha", "fantasma", "cave_floor", ["rocas"], "polvo",
		Color(0.7, 0.55, 1.0, 0.55), Color(0.86, 0.82, 0.98)],
	"arena_liga_dragon": ["Alto Mando: Lance", "dragon", "stone_floor", ["piletas", "rocas", "braseros"], "polvo",
		Color(0.6, 0.55, 1.0, 0.55), Color(0.97, 0.97, 1.04)],
}


## Piso de un rol: con autotile si tiene las 9 piezas de borde; si no, sus tiles sueltos al azar.
func _fill_role(layer: TileMapLayer, role: TileRole, rect: Rect2i) -> void:
	if role.metatiles.size() >= 9:
		_autotile(layer, role, rect)
		return
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			ZoneBuilder.set_metatile(layer, Vector2i(x, y), role.metatiles[rng.randi() % role.metatiles.size()])


func _themed_steps() -> Array:
	var out := []
	for id in THEMED:
		out.append([id, _themed.bind(id)])
	return out


## Una arena temática: paredes de gimnasio (las de Plateada), el piso del rol del tipo y sus detalles en simetría.
func _themed(id: String) -> void:
	var spec: Array = THEMED[id]
	var extras: Array = spec[3]
	var w := 44
	var h := 32
	var cx := w / 2
	var roles := ZoneBuilder.load_roles()
	var root := ZoneBuilder.new_zone_root(id, tileset)
	var g: TileMapLayer = root.get_node("Ground")
	var water: TileMapLayer = root.get_node("Water")
	var foliage: TileMapLayer = root.get_node("Foliage")
	for y in h:
		for x in w:
			var m := 35020
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
	var field := Rect2i(3, 5, w - 6, h - 9)
	_fill_role(g, roles.get_role(spec[2]), field)
	var sym := func(p: Vector2i) -> Array: return [p, Vector2i(w - 1 - p.x, p.y)]
	if extras.has("piletas"):
		_autotile(water, roles.get_role("water"), Rect2i(5, h / 2 - 3, 5, 6))
		_autotile(water, roles.get_role("water"), Rect2i(w - 10, h / 2 - 3, 5, 6))
	if extras.has("pasto"):
		for corner in [Vector2i(5, 7), Vector2i(w - 10, 7), Vector2i(5, h - 9), Vector2i(w - 10, h - 9)]:
			for dy in 2:
				for dx in 5:
					ZoneBuilder.set_metatile(foliage, corner + Vector2i(dx, dy), 13)
	if extras.has("flores"):
		for p in [Vector2i(12, 9), Vector2i(12, h - 10), Vector2i(cx - 2, 14)]:
			for q in sym.call(p):
				var fr: TileRole = roles.get_role("flowers")
				if fr != null and not fr.metatiles.is_empty():
					ZoneBuilder.set_metatile(g, q, fr.metatiles[0])
	if extras.has("rocas"):
		for p in [Vector2i(13, 12), Vector2i(17, 18), Vector2i(cx - 4, 10), Vector2i(cx - 4, h - 11)]:
			for q in sym.call(p):
				ZoneBuilder.set_metatile(g, q, 35035)
	if extras.has("rompibles"):
		for p in [Vector2i(15, 14), Vector2i(15, h - 13)]:
			for q in sym.call(p):
				ZoneBuilder.add_object(root, ROCK, q)
	for x in range(2, w - 1):  # pasarela de tablones donde se para el jugador
		ZoneBuilder.set_metatile(g, Vector2i(x, h - 4), 35041 if x == 2 else (35043 if x == w - 2 else 35042))
	root.set("hand_edited", true)
	_save(root, id)
	var a := ArenaData.new()
	a.id = id
	a.display_name = spec[0]
	a.scene_path = "%s/%s.tscn" % [ARENAS_DIR, id]
	a.field = field
	a.foe_trainer_cell = Vector2i(cx, 5)
	a.foe_mon_cell = Vector2i(cx, field.position.y + 3)
	a.player_cell = Vector2i(cx, h - 4)
	a.player_mon_cell = Vector2i(cx, field.end.y - 3)
	a.element_id = spec[1]
	a.line_color = Color(1, 1, 1, 0.3)
	a.particles = spec[4]
	a.particle_color = spec[5]
	a.ambient = spec[6]
	a.braziers = extras.has("braseros")
	a.crowd = extras.has("publico")
	a.epic = true
	ResourceSaver.save(a, "%s/%s.tres" % [DATA_DIR, id])


# --- Gimnasio eléctrico (Lt. Surge) ----------------------------------------------------------------------

## Metatiles del gimnasio de Carmín (vermilion_gym, base 58000): 1 piso, 2 sombra de la pared izquierda, 3 sombra de
## arriba, 8/15 esquinas, 64/65 y 72/73 máquinas de la pared, 16/23 paredes de los costados, 24/31 esquinas de abajo,
## 10 borde de abajo, 56 basurero, 57/58 generador (arriba/abajo).
const VG := 58000


func _gimnasio_electrico() -> void:
	var w := 40
	var h := 30
	var cx := w / 2
	var root := ZoneBuilder.new_zone_root("arena_gimnasio_electrico", tileset)
	var g: TileMapLayer = root.get_node("Ground")
	for y in h:
		for x in w:
			var m := 1
			if x == 0:
				m = 8 if y == 0 else (24 if y == h - 1 else 16)
			elif x == w - 1:
				m = 15 if y == 0 else (31 if y == h - 1 else 23)
			elif y == 0:
				m = 64 if x % 2 == 1 else 65
			elif y == 1:
				m = 72 if x % 2 == 1 else 73
			elif y == h - 1:
				m = 10
			elif y == 2:
				m = 3
			elif x == 1:
				m = 2
			ZoneBuilder.set_metatile(g, Vector2i(x, y), VG + m)
	# Basureros de cobertura (en simetría, como el puzzle del gimnasio) y generadores en las esquinas de la cancha.
	for p in [Vector2i(11, 11), Vector2i(16, 15), Vector2i(11, 19), Vector2i(cx, 12), Vector2i(cx, 18)]:
		ZoneBuilder.set_metatile(g, p, VG + 56)
		ZoneBuilder.set_metatile(g, Vector2i(w - 1 - p.x, p.y), VG + 56)
	for p in [Vector2i(6, 9), Vector2i(6, 20)]:
		for q in [p, Vector2i(w - 1 - p.x, p.y)]:
			ZoneBuilder.set_metatile(g, q, VG + 57)
			ZoneBuilder.set_metatile(g, q + Vector2i(0, 1), VG + 58)
	root.set("hand_edited", true)
	_save(root, "arena_gimnasio_electrico")
	var a := ArenaData.new()
	a.id = "arena_gimnasio_electrico"
	a.display_name = "Gimnasio de Ciudad Carmín"
	a.scene_path = "%s/arena_gimnasio_electrico.tscn" % ARENAS_DIR
	a.field = Rect2i(4, 6, w - 8, h - 12)
	a.foe_trainer_cell = Vector2i(cx, 4)
	a.foe_mon_cell = Vector2i(cx, 8)
	a.player_cell = Vector2i(cx, h - 3)
	a.player_mon_cell = Vector2i(cx, h - 7)
	a.element_id = "electrico"
	a.line_color = Color(1.0, 0.95, 0.5, 0.35)
	a.particles = "polvo"
	a.particle_color = Color(0.8, 0.92, 1.0, 0.6)  # chispas (el piso del gimnasio ya es amarillo: sin tinte)
	a.epic = true
	ResourceSaver.save(a, "%s/arena_gimnasio_electrico.tres" % DATA_DIR)


func _save(root: Node, id: String) -> void:
	var err := ZoneBuilder.save_zone(root, "%s/%s.tscn" % [ARENAS_DIR, id])
	print(id, ": ", "OK" if err == OK else "ERROR %d" % err)
	root.free()
