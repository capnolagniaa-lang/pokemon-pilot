extends SceneTree
## Construye el TileSet (a partir de los atlas de FireRed generados por tools/pret_import.py)
## y las escenas de zona iniciales.
## Uso: godot --headless --path . --script res://tools/build_world.gd [-- --force]
## Sin --force no pisa archivos existentes (para no perder lo que pintes en el editor).

const T := 16
const TILES_DIR := "res://art/pret/tiles"
const TILESET_PATH := "res://art/tiles/world_tileset.tres"
const WORLD_PATH := "res://data/world/kanto.tres"

# Fuentes del TileSet
const SRC_BELOW := 0
const SRC_ANIM := 1
const SRC_ABOVE := 2

# Metatiles del tileset "general" de FireRed (ver art/pret/tiles/general_below.png)
const GRASS_IDS := [1, 1, 1, 1, 1, 8, 9, 16, 17]
const TALL_GRASS_ID := 13
const FLOWER_ID := 4
const SAND := [[211, 212, 213], [219, 220, 221], [227, 228, 229]]
const DIRT := [[208, 209, 210], [216, 217, 218], [224, 225, 226]]
const POND := [[416, 417, 418], [424, 425, 426], [432, 433, 434]]
const TREE_TOP := [14, 15]
const TREE_TOP_STACKED := [26, 27]  # árbol con otro árbol justo arriba
const TREE_BOTTOM := [30, 31]

# physics: 0 = mundo sólido (capa 1), 1 = agua (capa 2)
const ROLES := {
	"grass": {"ids": [1, 8, 9, 16, 17], "tags": ["suelo", "pasto"]},
	"tall_grass": {"ids": [13], "tags": ["suelo", "pasto_alto", "inflamable"]},
	"flowers": {"ids": [4], "tags": ["suelo", "pasto", "flores", "inflamable"]},
	"sand": {"ids": [211, 212, 213, 219, 220, 221, 227, 228, 229], "tags": ["suelo", "arena"]},
	"dirt": {"ids": [208, 209, 210, 216, 217, 218, 224, 225, 226], "tags": ["suelo", "tierra"]},
	"water": {"ids": [416, 417, 418, 424, 425, 426, 432, 433, 434], "tags": ["agua", "conductor", "congelable"], "physics": 1},
	"tree": {"ids": [14, 15, 26, 27, 30, 31], "tags": ["arbol", "solido", "inflamable"], "physics": 0},
}

# Caracteres del mapa de suelo
const AUTOTILE := {"=": SAND, "-": DIRT, "~": POND}
const OBJECT_SCENES := {
	"rock": "res://scenes/world/objects/rock_smash_rock.tscn",
	"boulder": "res://scenes/world/objects/strength_boulder.tscn",
	"cut_tree": "res://scenes/world/objects/cut_tree.tscn",
}

var force := false
var tileset: TileSet
var manifest: Dictionary
var rng := RandomNumberGenerator.new()


func _init() -> void:
	force = "--force" in OS.get_cmdline_user_args()
	for d in ["res://data/world", "res://scenes/world/zones", "res://art/tiles"]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(d))
	manifest = JSON.parse_string(FileAccess.get_file_as_string(TILES_DIR + "/manifest.json"))["general"]
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


# --- TileSet -----------------------------------------------------------------

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

	var count := int(manifest["count"])
	var below := _atlas(TILES_DIR + "/general_below.png")
	ts.add_source(below, SRC_BELOW)
	for i in count:
		below.create_tile(Vector2i(i % 16, i / 16))
		_apply_role(below.get_tile_data(Vector2i(i % 16, i / 16), 0), i)

	var anim := _atlas(TILES_DIR + "/general_anim.png")
	ts.add_source(anim, SRC_ANIM)
	for key in manifest["anim"]:
		var a: Dictionary = manifest["anim"][key]
		var c := Vector2i(0, int(a["row"]))
		anim.create_tile(c)
		anim.set_tile_animation_columns(c, int(a["frames"]))
		anim.set_tile_animation_frames_count(c, int(a["frames"]))
		for f in int(a["frames"]):
			anim.set_tile_animation_frame_duration(c, f, float(a["duration"]))
		_apply_role(anim.get_tile_data(c, 0), int(key))

	var above := _atlas(TILES_DIR + "/general_above.png")
	ts.add_source(above, SRC_ABOVE)
	for i in count:
		if manifest["above_used"][i]:
			above.create_tile(Vector2i(i % 16, i / 16))

	ResourceSaver.save(ts, TILESET_PATH)
	return load(TILESET_PATH)


func _atlas(path: String) -> TileSetAtlasSource:
	var src := TileSetAtlasSource.new()
	src.texture = load(path)
	src.texture_region_size = Vector2i(T, T)
	return src


func _apply_role(td: TileData, metatile: int) -> void:
	var h := T / 2.0
	for role in ROLES.values():
		if metatile in role["ids"]:
			td.set_custom_data("tags", PackedStringArray(role["tags"]))
			if role.has("physics"):
				var layer: int = role["physics"]
				td.add_collision_polygon(layer)
				td.set_collision_polygon_points(layer, 0, PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)]))
			return


## Dónde está un metatile en el TileSet: (fuente, coordenadas). Prefiere la versión animada.
func _below_ref(metatile: int) -> Array:
	var key := str(metatile)
	if manifest["anim"].has(key):
		return [SRC_ANIM, Vector2i(0, int(manifest["anim"][key]["row"]))]
	return [SRC_BELOW, Vector2i(metatile % 16, metatile / 16)]


# --- Zonas -------------------------------------------------------------------

func _zone(id: String, display_name: String, origin: Vector2i, biome: String, painter: Callable) -> ZoneEntry:
	var entry := ZoneEntry.new()
	entry.id = id
	entry.display_name = display_name
	entry.scene_path = "res://scenes/world/zones/%s.tscn" % id
	entry.origin = origin
	entry.size = Vector2i(40, 26)
	entry.biome = biome
	if force or not ResourceLoader.exists(entry.scene_path):
		rng.seed = hash(id)
		var map := ZoneMap.new(entry.size)
		painter.call(map)
		_save_zone_scene(entry, map)
	return entry


func _layer(root: Node, layer_name: String, z: int, material_path: String = "") -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = tileset
	layer.z_index = z
	if material_path != "":
		layer.material = load(material_path)
	root.add_child(layer)
	layer.owner = root
	return layer


func _save_zone_scene(entry: ZoneEntry, map: ZoneMap) -> void:
	var root := Node2D.new()
	root.name = entry.id.capitalize().replace(" ", "")
	root.y_sort_enabled = true
	root.set_script(load("res://scripts/world/zone.gd"))
	root.set("zone_id", entry.id)
	var tree_cells: Array[Vector2i] = []
	tree_cells.assign(map.trees)
	root.set("tree_cells", tree_cells)

	var ground := _layer(root, "Ground", -10)
	var water := _layer(root, "Water", -9, "res://shaders/materials/water.tres")
	var foliage := _layer(root, "Foliage", -8, "res://shaders/materials/foliage_wind.tres")
	var shadows := Node2D.new()
	shadows.name = "TreeShadows"
	shadows.z_index = -7
	shadows.set_script(load("res://scripts/world/tree_shadows.gd"))
	root.add_child(shadows)
	shadows.owner = root
	var overhead := _layer(root, "Overhead", 20, "res://shaders/materials/canopy_wind.tres")
	var objects := Node2D.new()
	objects.name = "Objects"
	objects.y_sort_enabled = true
	root.add_child(objects)
	objects.owner = root

	for y in map.size.y:
		for x in map.size.x:
			var c := Vector2i(x, y)
			var ch: String = map.ground[y][x]
			var below_id: int = GRASS_IDS[rng.randi() % GRASS_IDS.size()]
			var target := ground
			if AUTOTILE.has(ch):
				below_id = _autotile(map, c, ch)
				if ch == "~":
					target = water
					ground.set_cell(c, SRC_BELOW, Vector2i(1, 0))
			elif ch == ",":
				ground.set_cell(c, SRC_BELOW, Vector2i(1, 0))
				below_id = TALL_GRASS_ID
				target = foliage
			elif ch == "*":
				ground.set_cell(c, SRC_BELOW, Vector2i(1, 0))
				below_id = FLOWER_ID
				target = foliage
			if map.tree_tiles.has(c):
				below_id = map.tree_tiles[c]
				target = ground
			var ref := _below_ref(below_id)
			target.set_cell(c, ref[0], ref[1])
			if manifest["above_used"][below_id]:
				overhead.set_cell(c, SRC_ABOVE, Vector2i(below_id % 16, below_id / 16))

	for obj in map.objects:
		var node: Node2D = load(OBJECT_SCENES[obj[0]]).instantiate()
		node.position = Vector2(obj[1] * T) + Vector2(T / 2.0, T)
		objects.add_child(node)
		node.owner = root

	var packed := PackedScene.new()
	packed.pack(root)
	ResourceSaver.save(packed, entry.scene_path)
	root.free()


## Elige la pieza del 3x3 (bordes/esquinas) según qué vecinos son del mismo tipo.
## Fuera de la zona cuenta como igual, así los caminos siguen en la zona vecina.
func _autotile(map: ZoneMap, c: Vector2i, ch: String) -> int:
	var same := func(d: Vector2i) -> bool:
		var n := c + d
		return not map.inside(n) or map.ground[n.y][n.x] == ch
	var row := 1
	if not same.call(Vector2i.UP):
		row = 0
	elif not same.call(Vector2i.DOWN):
		row = 2
	var col := 1
	if not same.call(Vector2i.LEFT):
		col = 0
	elif not same.call(Vector2i.RIGHT):
		col = 2
	return AUTOTILE[ch][row][col]


# --- Pintado de zonas --------------------------------------------------------

class ZoneMap:
	var size: Vector2i
	var ground: Array = []        # filas de caracteres: . pasto , pasto alto * flores = arena - tierra ~ agua
	var trees: Array = []         # celda sup. izq. de cada árbol (2x2)
	var tree_tiles: Dictionary = {}  # Vector2i -> metatile
	var objects: Array = []       # [tipo, celda]

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
				if not inside(c) or tree_tiles.has(c) or ground[yy][xx] != "." or _has_object(c):
					return false
		return true

	func _has_object(c: Vector2i) -> bool:
		for o in objects:
			if o[1] == c:
				return true
		return false

	## Árbol cónico de Kanto (2x2). Si hay otro árbol justo arriba, usa la copa "apilada".
	func tree(x: int, y: int) -> void:
		trees.append(Vector2i(x, y))
		var stacked := tree_tiles.has(Vector2i(x, y - 1))
		var top: Array = TREE_TOP_STACKED if stacked else TREE_TOP
		tree_tiles[Vector2i(x, y)] = top[0]
		tree_tiles[Vector2i(x + 1, y)] = top[1]
		tree_tiles[Vector2i(x, y + 1)] = TREE_BOTTOM[0]
		tree_tiles[Vector2i(x + 1, y + 1)] = TREE_BOTTOM[1]

	func put(kind: String, x: int, y: int) -> void:
		objects.append([kind, Vector2i(x, y)])

	## Bordea la zona con árboles, dejando huecos (rangos de x arriba/abajo).
	func border(top_gaps: Array, bottom_gaps: Array) -> void:
		for y in range(0, size.y, 2):
			for x in range(0, size.x, 2):
				var edge_x := x == 0 or x == size.x - 2
				var top := y == 0 and not _in_gaps(x, top_gaps)
				var bottom := y == size.y - 2 and not _in_gaps(x, bottom_gaps)
				if edge_x or top or bottom:
					tree(x, y)

	func _in_gaps(x: int, gaps: Array) -> bool:
		for g in gaps:
			if x + 1 >= g.x and x <= g.y:
				return true
		return false


func _paint_pradera(m: ZoneMap) -> void:
	m.border([Vector2i(18, 21)], [])
	m.rect("=", 19, 0, 2, 24)
	m.rect("-", 6, 12, 13, 2)
	m.rect(",", 26, 3, 9, 7)
	m.rect(",", 4, 16, 10, 6)
	m.rect("~", 25, 15, 9, 6)
	# Rincón cerrado por rocas: las dos del medio son frágiles (puzzle de la Etapa 3)
	for x in range(2, 10):
		m.put("rock" if x in [5, 6] else "boulder", x, 10)
	for y in range(2, 10):
		m.put("boulder", 10, y)
	m.rect("*", 3, 3, 6, 6)
	m.put("boulder", 14, 4)
	m.put("boulder", 12, 7)
	m.tree(14, 16)
	m.tree(16, 16)
	m.tree(30, 11)
	m.tree(35, 11)
	for i in 30:
		var x := rng.randi_range(2, 37)
		var y := rng.randi_range(2, 23)
		if m.is_free(x, y, 1, 1):
			m.ground[y][x] = "*"


func _paint_bosque(m: ZoneMap) -> void:
	m.border([], [Vector2i(18, 21)])
	m.rect("=", 19, 14, 2, 12)
	m.rect("-", 12, 10, 16, 4)
	m.rect("~", 2, 7, 36, 2)
	m.rect("=", 30, 7, 2, 2)  # vado para cruzar el arroyo
	m.rect("=", 28, 9, 4, 3)
	m.rect(",", 4, 14, 8, 5)
	m.rect(",", 28, 16, 8, 5)
	m.rect(",", 6, 2, 10, 4)
	m.put("boulder", 24, 3)
	m.put("rock", 25, 3)
	m.put("cut_tree", 22, 11)
	for y in range(2, 24, 2):
		for x in range(2, 38, 2):
			if x >= 16 and x <= 22 and y >= 13:
				continue  # pasillo del camino
			if y >= 5 and y <= 9:
				continue  # orillas del arroyo
			if rng.randf() < 0.55 and m.is_free(x, y, 2, 2):
				m.tree(x, y)
