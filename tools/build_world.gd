extends SceneTree
## Construye el TileSet (tags + colisiones) y las escenas de zona iniciales.
## Uso: godot --headless --path . --script res://tools/build_world.gd [-- --force]
## Sin --force no pisa archivos existentes (para no perder lo que pintes en el editor).

const T := 16
const TILES_PNG := "res://art/tiles/tileset.png"
const TILESET_PATH := "res://art/tiles/world_tileset.tres"
const WORLD_PATH := "res://data/world/kanto.tres"

# Coordenadas en el atlas (mismo layout que tools/gen_art.gd)
const GRASS := Vector2i(0, 0)
const FLOWERS := Vector2i(1, 0)
const TALL_GRASS := Vector2i(2, 0)
const PATH := Vector2i(3, 0)
const WATER := Vector2i(4, 0)
const ROCK := Vector2i(5, 0)
const CRACKED := Vector2i(6, 0)
const SAND := Vector2i(7, 0)
const TREE_TL := Vector2i(0, 1)
const TREE_TR := Vector2i(1, 1)
const TREE_BL := Vector2i(0, 2)
const TREE_BR := Vector2i(1, 2)
const BURNT := Vector2i(2, 1)
const WET := Vector2i(3, 1)
const ICE := Vector2i(4, 1)
const RUBBLE := Vector2i(5, 1)
const VINES := Vector2i(6, 1)

# physics: 0 = mundo sólido (capa 1), 1 = agua (capa 2)
const TILE_DEFS := {
	GRASS: {"tags": ["suelo", "pasto"]},
	FLOWERS: {"tags": ["suelo", "pasto", "inflamable"]},
	TALL_GRASS: {"tags": ["suelo", "pasto_alto", "inflamable"]},
	PATH: {"tags": ["suelo", "tierra"]},
	WATER: {"tags": ["agua", "conductor", "congelable"], "physics": 1},
	ROCK: {"tags": ["solido", "roca"], "physics": 0},
	CRACKED: {"tags": ["solido", "roca", "fragil"], "physics": 0},
	SAND: {"tags": ["suelo", "arena"]},
	TREE_TL: {"tags": ["arbol", "inflamable"], "y_sort": 16},
	TREE_TR: {"tags": ["arbol", "inflamable"], "y_sort": 16},
	TREE_BL: {"tags": ["arbol", "solido", "inflamable"], "physics": 0},
	TREE_BR: {"tags": ["arbol", "solido", "inflamable"], "physics": 0},
	BURNT: {"tags": ["suelo", "quemado"]},
	WET: {"tags": ["suelo", "mojado", "conductor"]},
	ICE: {"tags": ["hielo", "suelo"]},
	RUBBLE: {"tags": ["escombros"]},
	VINES: {"tags": ["planta", "solido", "inflamable"], "physics": 0},
}

const GROUND_CHARS := {".": GRASS, ",": TALL_GRASS, "=": PATH, "~": WATER, "*": FLOWERS, "s": SAND}

var force := false
var tileset: TileSet


func _init() -> void:
	force = "--force" in OS.get_cmdline_user_args()
	for d in ["res://data/world", "res://scenes/world/zones"]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(d))
	tileset = _build_tileset()

	var zones: Array[ZoneEntry] = []
	zones.append(_zone("pradera", "Ruta 1 - Pradera", Vector2i(0, 0), "pradera", _paint_pradera))
	zones.append(_zone("bosque", "Bosque Verde", Vector2i(0, -26), "bosque", _paint_bosque))

	if force or not ResourceLoader.exists(WORLD_PATH):
		var world := WorldData.new()
		world.tile_size = T
		world.zones = zones
		world.spawn_cell = Vector2i(20, 21)
		ResourceSaver.save(world, WORLD_PATH)
	var cfg_path := "res://data/config/game_config.tres"
	if ResourceLoader.exists(cfg_path):
		var cfg: GameConfig = load(cfg_path)
		cfg.world = load(WORLD_PATH)
		ResourceSaver.save(cfg, cfg_path)
	print("Mundo construido.")
	quit()


func _build_tileset() -> TileSet:
	if not force and ResourceLoader.exists(TILESET_PATH):
		return load(TILESET_PATH)
	var ts := TileSet.new()
	ts.tile_size = Vector2i(T, T)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(1, 2)
	ts.set_physics_layer_collision_mask(1, 0)
	ts.add_custom_data_layer()
	ts.set_custom_data_layer_name(0, "tags")
	ts.set_custom_data_layer_type(0, TYPE_PACKED_STRING_ARRAY)

	var src := TileSetAtlasSource.new()
	src.texture = load(TILES_PNG)
	src.texture_region_size = Vector2i(T, T)
	ts.add_source(src, 0)
	var h := T / 2.0
	var square := PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)])
	for coords in TILE_DEFS:
		var def: Dictionary = TILE_DEFS[coords]
		src.create_tile(coords)
		var td := src.get_tile_data(coords, 0)
		td.set_custom_data("tags", PackedStringArray(def["tags"]))
		if def.has("physics"):
			var layer: int = def["physics"]
			td.add_collision_polygon(layer)
			td.set_collision_polygon_points(layer, 0, square)
		if def.has("y_sort"):
			td.y_sort_origin = def["y_sort"]
	ResourceSaver.save(ts, TILESET_PATH)
	return load(TILESET_PATH)


func _zone(id: String, display_name: String, origin: Vector2i, biome: String, painter: Callable) -> ZoneEntry:
	var entry := ZoneEntry.new()
	entry.id = id
	entry.display_name = display_name
	entry.scene_path = "res://scenes/world/zones/%s.tscn" % id
	entry.origin = origin
	entry.size = Vector2i(40, 26)
	entry.biome = biome
	if force or not ResourceLoader.exists(entry.scene_path):
		var map := ZoneMap.new(entry.size)
		painter.call(map)
		_save_zone_scene(entry, map)
	return entry


func _save_zone_scene(entry: ZoneEntry, map: ZoneMap) -> void:
	var root := Node2D.new()
	root.name = entry.id.capitalize().replace(" ", "")
	root.y_sort_enabled = true
	root.set_script(load("res://scripts/world/zone.gd"))
	root.set("zone_id", entry.id)

	var ground := TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = tileset
	ground.z_index = -10
	var objects := TileMapLayer.new()
	objects.name = "Objects"
	objects.tile_set = tileset
	objects.y_sort_enabled = true
	root.add_child(ground)
	root.add_child(objects)
	ground.owner = root
	objects.owner = root

	for y in map.size.y:
		for x in map.size.x:
			var c := Vector2i(x, y)
			ground.set_cell(c, 0, GROUND_CHARS.get(map.ground[y][x], GRASS))
			var o: Vector2i = map.objects.get(c, Vector2i(-1, -1))
			if o.x >= 0:
				objects.set_cell(c, 0, o)
	var packed := PackedScene.new()
	packed.pack(root)
	ResourceSaver.save(packed, entry.scene_path)
	root.free()


# --- Pintado de zonas --------------------------------------------------------

class ZoneMap:
	var size: Vector2i
	var ground: Array = []  # filas de caracteres
	var objects: Dictionary = {}  # Vector2i -> coords atlas

	func _init(p_size: Vector2i) -> void:
		size = p_size
		for y in size.y:
			var row := []
			row.resize(size.x)
			row.fill(".")
			ground.append(row)

	func inside(c: Vector2i) -> bool:
		return c.x >= 0 and c.y >= 0 and c.x < size.x and c.y < size.y

	func rect(ch: String, x: int, y: int, w: int, h: int) -> void:
		for yy in range(y, y + h):
			for xx in range(x, x + w):
				if inside(Vector2i(xx, yy)):
					ground[yy][xx] = ch

	func is_free(x: int, y: int, w: int, h: int) -> bool:
		for yy in range(y, y + h):
			for xx in range(x, x + w):
				var c := Vector2i(xx, yy)
				if not inside(c) or objects.has(c) or ground[yy][xx] != ".":
					return false
		return true

	func tree(x: int, y: int) -> void:
		objects[Vector2i(x, y)] = TREE_TL
		objects[Vector2i(x + 1, y)] = TREE_TR
		objects[Vector2i(x, y + 1)] = TREE_BL
		objects[Vector2i(x + 1, y + 1)] = TREE_BR

	func put(x: int, y: int, atlas: Vector2i) -> void:
		objects[Vector2i(x, y)] = atlas

	## Bordea la zona con árboles, dejando huecos (rangos de x arriba/abajo).
	func border(top_gaps: Array, bottom_gaps: Array) -> void:
		for x in range(0, size.x, 2):
			if not _in_gaps(x, top_gaps):
				tree(x, 0)
			if not _in_gaps(x, bottom_gaps):
				tree(x, size.y - 2)
		for y in range(2, size.y - 2, 2):
			tree(0, y)
			tree(size.x - 2, y)

	func _in_gaps(x: int, gaps: Array) -> bool:
		for g in gaps:
			if x + 1 >= g.x and x <= g.y:
				return true
		return false


func _paint_pradera(m: ZoneMap) -> void:
	m.border([Vector2i(18, 21)], [])
	m.rect("=", 19, 0, 2, 24)
	m.rect("=", 6, 12, 13, 2)
	m.rect(",", 26, 4, 8, 6)
	m.rect(",", 4, 16, 10, 6)
	m.rect("s", 24, 14, 11, 8)
	m.rect("~", 25, 15, 9, 6)
	# Rincón cerrado por rocas con una parte frágil (para un puzzle futuro)
	for x in range(2, 10):
		m.put(x, 10, CRACKED if x in [5, 6] else ROCK)
	for y in range(2, 10):
		m.put(10, y, ROCK)
	m.rect("*", 3, 3, 6, 6)
	m.put(14, 4, ROCK)
	m.put(11, 7, ROCK)
	m.put(15, 8, ROCK)
	m.tree(14, 16)
	m.tree(30, 2)
	m.tree(35, 11)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in 25:
		var x := rng.randi_range(2, 37)
		var y := rng.randi_range(2, 23)
		if m.is_free(x, y, 1, 1):
			m.ground[y][x] = "*"


func _paint_bosque(m: ZoneMap) -> void:
	m.border([], [Vector2i(18, 21)])
	m.rect("=", 19, 14, 2, 12)
	m.rect("=", 12, 10, 16, 4)
	m.rect("~", 2, 7, 36, 2)
	m.rect("=", 30, 7, 2, 2)  # vado para cruzar el arroyo
	m.rect("=", 28, 9, 4, 3)
	m.rect(",", 4, 14, 8, 5)
	m.rect(",", 28, 16, 8, 5)
	m.rect(",", 6, 2, 10, 4)
	m.put(24, 3, ROCK)
	m.put(25, 3, CRACKED)
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for i in 140:
		var x := rng.randi_range(1, 18) * 2
		var y := rng.randi_range(1, 11) * 2
		if x >= 16 and x <= 22 and y >= 13:
			continue  # pasillo del camino
		if y >= 5 and y <= 9:
			continue  # orillas del arroyo
		if m.is_free(x, y, 2, 2):
			m.tree(x, y)
