extends SceneTree
## Construye el TileSet (a partir de los atlas de FireRed generados por tools/pret_import.py)
## y la región: una grilla de zonas generadas según su bioma, conectadas por caminos.
## Uso: godot --headless --path . --script res://tools/build_world.gd [-- --force]
## Sin --force no pisa archivos existentes (para no perder lo que pintes en el editor).

const T := 16
const TILES_DIR := "res://art/pret/tiles"
const TILESET_PATH := "res://art/tiles/world_tileset.tres"
const WORLD_PATH := "res://data/world/kanto.tres"
const ZONE_SIZE := Vector2i(48, 32)
const START_ZONE := "ruta1"

# Región: [id, nombre, columna, fila, bioma]. Las zonas vecinas quedan conectadas.
const REGION := [
	["bosque_profundo", "Bosque Profundo", 0, 0, "bosque_denso"],
	["bosque", "Bosque Verde", 1, 0, "bosque"],
	["lago", "Lago Celeste", 2, 0, "lago"],
	["pradera_florida", "Pradera Florida", 0, 1, "pradera_florida"],
	["ruta1", "Ruta 1", 1, 1, "pradera"],
	["colinas", "Colinas Rocosas", 2, 1, "rocoso"],
	["humedal", "Humedal", 0, 2, "humedal"],
	["pradera_sur", "Pradera Sur", 1, 2, "pradera"],
	["arboleda", "Arboleda", 2, 2, "arboleda"],
]

# Parámetros de generación por bioma.
#  path: tipo de camino ("=" arena, "-" tierra)  trees: probabilidad de árbol por hueco de 2x2
#  tall_grass/ponds/flower_patches/meadows: [cantidad, tamaño mín, tamaño máx]
#  flowers: flores sueltas  rocks: rocas  rock_smash: fracción frágil  streams: arroyos  lake: [ancho, alto]
const BIOMES := {
	"pradera": {"path": "=", "trees": 0.05, "tall_grass": [7, 4, 9], "ponds": [1, 5, 8], "flower_patches": [2, 3, 5], "flowers": 60, "rocks": 3},
	"pradera_florida": {"path": "-", "trees": 0.04, "tall_grass": [5, 3, 7], "ponds": [1, 4, 6], "flower_patches": [7, 3, 6], "flowers": 170, "rocks": 1},
	"bosque": {"path": "-", "trees": 0.5, "tall_grass": [7, 3, 7], "flower_patches": [1, 2, 4], "flowers": 20, "rocks": 2, "streams": 1, "cut_trees": 2},
	"bosque_denso": {"path": "-", "trees": 0.72, "tall_grass": [9, 3, 6], "ponds": [1, 3, 5], "flowers": 10, "rocks": 2, "cut_trees": 3},
	"lago": {"path": "=", "trees": 0.12, "lake": [26, 12], "tall_grass": [4, 3, 6], "ponds": [2, 3, 5], "flowers": 35, "rocks": 2},
	"rocoso": {"path": "-", "trees": 0.07, "tall_grass": [3, 3, 5], "flowers": 10, "rocks": 45, "rock_smash": 0.35},
	"humedal": {"path": "-", "trees": 0.1, "tall_grass": [11, 3, 7], "ponds": [9, 3, 6], "flowers": 20, "rocks": 1},
	"arboleda": {"path": "=", "trees": 0.25, "tall_grass": [5, 3, 6], "ponds": [1, 4, 6], "flower_patches": [2, 2, 4], "flowers": 40, "rocks": 3},
}

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
const MEADOW := [[189, 190, 191], [197, 198, 199], [205, 206, 207]]
const TREE_TOP := [14, 15]
const TREE_TOP_STACKED := [26, 27]  # árbol con otro árbol justo arriba
const TREE_BOTTOM := [30, 31]

# physics: 0 = mundo sólido (capa 1), 1 = agua (capa 2)
const ROLES := {
	"grass": {"ids": [1, 8, 9, 16, 17], "tags": ["suelo", "pasto"]},
	"meadow": {"ids": [189, 190, 191, 197, 198, 199, 205, 206, 207], "tags": ["suelo", "pasto"]},
	"tall_grass": {"ids": [13], "tags": ["suelo", "pasto_alto", "inflamable"]},
	"flowers": {"ids": [4], "tags": ["suelo", "pasto", "flores", "inflamable"]},
	"sand": {"ids": [211, 212, 213, 219, 220, 221, 227, 228, 229], "tags": ["suelo", "arena"]},
	"dirt": {"ids": [208, 209, 210, 216, 217, 218, 224, 225, 226], "tags": ["suelo", "tierra"]},
	"water": {"ids": [416, 417, 418, 424, 425, 426, 432, 433, 434], "tags": ["agua", "conductor", "congelable"], "physics": 1},
	"tree": {"ids": [14, 15, 26, 27, 30, 31], "tags": ["arbol", "solido", "inflamable"], "physics": 0},
}

# Caracteres del mapa de suelo: . pasto  , pasto alto  * flores  = arena  - tierra  ~ agua  m pradera clara
const AUTOTILE := {"=": SAND, "-": DIRT, "~": POND, "m": MEADOW}
const OBJECT_SCENES := {
	"rock": "res://scenes/world/objects/rock_smash_rock.tscn",
	"boulder": "res://scenes/world/objects/strength_boulder.tscn",
	"cut_tree": "res://scenes/world/objects/cut_tree.tscn",
}
const OPPOSITE := {"up": "down", "down": "up", "left": "right", "right": "left"}

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

	var entries := _plan_region()
	var zones: Array[ZoneEntry] = []
	var spawn := Vector2i.ZERO
	for e in entries:
		_build_zone(e)
		zones.append(e)
		if e.id == START_ZONE:
			spawn = e.origin + e.hub + Vector2i(1, 1)

	if force or not ResourceLoader.exists(WORLD_PATH):
		var world := WorldData.new()
		world.tile_size = T
		world.zones = zones
		world.spawn_cell = spawn
		ResourceSaver.save(world, WORLD_PATH)
	var cfg_path := "res://data/config/game_config.tres"
	if ResourceLoader.exists(cfg_path):
		var cfg: GameConfig = load(cfg_path)
		cfg.world = load(WORLD_PATH)
		ResourceSaver.save(cfg, cfg_path)
	print("Mundo construido: %d zonas." % zones.size())
	quit()


# --- Región ------------------------------------------------------------------

## Crea las ZoneEntry con su plaza central y las salidas alineadas con cada vecina.
func _plan_region() -> Array[ZoneEntry]:
	var by_pos := {}
	var out: Array[ZoneEntry] = []
	for z in REGION:
		var e := ZoneEntry.new()
		e.id = z[0]
		e.display_name = z[1]
		e.origin = Vector2i(z[2], z[3]) * ZONE_SIZE
		e.size = ZONE_SIZE
		e.biome = z[4]
		e.scene_path = "res://scenes/world/zones/%s.tscn" % e.id
		rng.seed = hash(e.id + "hub")
		e.hub = Vector2i(rng.randi_range(9, 14) * 2, rng.randi_range(5, 9) * 2)
		by_pos[Vector2i(z[2], z[3])] = e
		out.append(e)
	for pos in by_pos:
		var e: ZoneEntry = by_pos[pos]
		for side in [["right", Vector2i(1, 0)], ["down", Vector2i(0, 1)]]:
			var other: ZoneEntry = by_pos.get(pos + side[1])
			if other == null:
				continue
			rng.seed = hash(e.id + other.id)
			if side[0] == "right":
				var y := rng.randi_range(4, ZONE_SIZE.y / 2 - 5) * 2
				e.exits["right"] = Vector2i(ZONE_SIZE.x - 2, y)
				other.exits["left"] = Vector2i(0, y)
			else:
				var x := rng.randi_range(4, ZONE_SIZE.x / 2 - 5) * 2
				e.exits["down"] = Vector2i(x, ZONE_SIZE.y - 2)
				other.exits["up"] = Vector2i(x, 0)
	return out


func _build_zone(e: ZoneEntry) -> void:
	if not force and ResourceLoader.exists(e.scene_path):
		return
	rng.seed = hash(e.id)
	var biome: Dictionary = BIOMES[e.biome]
	var m := ZoneMap.new(e.size)
	# 1) Agua grande (los caminos la cruzan después, formando vados)
	for i in biome.get("streams", 0):
		var y := rng.randi_range(4, e.size.y - 7)
		if absi(y - e.hub.y) < 4:
			y = (y + 9) % (e.size.y - 7) + 3
		m.rect("~", 2, y, e.size.x - 4, 2)
	if biome.has("lake"):
		var s: Array = biome["lake"]
		m.rect("~", (e.size.x - s[0]) / 2, (e.size.y - s[1]) / 2, s[0], s[1])
	# 2) Borde de árboles solo en los lados que dan al exterior de la región; caminos a cada vecina
	m.border(["up", "down", "left", "right"].filter(func(s): return not e.exits.has(s)))
	var path: String = biome["path"]
	m.rect(path, e.hub.x - 1, e.hub.y - 1, 4, 4)
	for side in e.exits:
		m.carve(e.exits[side], e.hub, side, path)
	# 3) Detalles especiales de la zona
	match e.id:
		"ruta1":
			_rock_nook(m)
		"bosque":
			if m.is_free(30, 3, 2, 1):
				m.put("boulder", 30, 3)
				m.put("rock", 31, 3)
	# 4) Relleno según el bioma
	_scatter(m, biome)
	_save_zone_scene(e, m)


func _scatter(m: ZoneMap, b: Dictionary) -> void:
	if b.has("ponds"):
		_patches(m, "~", b["ponds"], 1)
	if b.has("meadows"):
		_patches(m, "m", b["meadows"], 1)
	if b.has("tall_grass"):
		_patches(m, ",", b["tall_grass"], 0)
	if b.has("flower_patches"):
		_patches(m, "*", b["flower_patches"], 0)
	for i in b.get("rocks", 0):
		var c := Vector2i(rng.randi_range(2, m.size.x - 3), rng.randi_range(2, m.size.y - 3))
		if m.is_free(c.x - 1, c.y - 1, 3, 3):
			m.put("rock" if rng.randf() < b.get("rock_smash", 0.3) else "boulder", c.x, c.y)
	for i in b.get("cut_trees", 0):
		for attempt in 20:
			var c := Vector2i(rng.randi_range(2, m.size.x - 3), rng.randi_range(2, m.size.y - 3))
			if m.ground[c.y][c.x] == "." and m.near(c, ["=", "-"]) and m.is_free(c.x, c.y, 1, 1):
				m.put("cut_tree", c.x, c.y)
				break
	# Árboles: posiciones al azar (x libre, y par para que se apilen bien), así no quedan en grilla.
	var density: float = b.get("trees", 0.0)
	var attempts := int(density * m.size.x * m.size.y / 4.0 * 3.5)
	for i in attempts:
		var x := rng.randi_range(0, m.size.x - 2)
		var y := rng.randi_range(0, m.size.y / 2 - 1) * 2
		if m.is_free(x, y, 2, 2) and not m.near_rect(x, y, 2, 2, ["=", "-"]):
			m.tree(x, y)
	for i in b.get("flowers", 0):
		var c := Vector2i(rng.randi_range(2, m.size.x - 3), rng.randi_range(2, m.size.y - 3))
		if m.is_free(c.x, c.y, 1, 1):
			m.ground[c.y][c.x] = "*"


## Coloca manchas rectangulares de un tipo de suelo donde haya lugar (con margen).
func _patches(m: ZoneMap, ch: String, spec: Array, margin: int) -> void:
	for i in spec[0]:
		for attempt in 30:
			var w := rng.randi_range(spec[1], spec[2])
			var h := rng.randi_range(maxi(2, spec[1] - 1), maxi(2, spec[2] - 2))
			var x := rng.randi_range(2, m.size.x - w - 3)
			var y := rng.randi_range(2, m.size.y - h - 3)
			if m.is_free(x - margin, y - margin, w + margin * 2, h + margin * 2):
				m.rect(ch, x, y, w, h)
				break


## Rincón de flores encerrado por rocas, con dos frágiles (puzzle de la Etapa 3).
func _rock_nook(m: ZoneMap) -> void:
	for corner: Vector2i in [Vector2i(2, 2), Vector2i(m.size.x - 12, 2), Vector2i(2, m.size.y - 12), Vector2i(m.size.x - 12, m.size.y - 12)]:
		if not m.is_free(corner.x, corner.y, 10, 10):
			continue
		var top := corner.y == 2
		var left := corner.x == 2
		var wall_y := corner.y + 8 if top else corner.y + 1
		var wall_x := corner.x + 8 if left else corner.x + 1
		var inner_x := corner.x if left else corner.x + 2
		var inner_y := corner.y if top else corner.y + 2
		m.rect("*", inner_x, inner_y, 8, 8)
		for x in range(corner.x, corner.x + 10):
			m.put("rock" if x in [corner.x + 4, corner.x + 5] else "boulder", x, wall_y)
		for y in range(corner.y, corner.y + 10):
			if y != wall_y:
				m.put("boulder", wall_x, y)
		return


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


# --- Escena de zona ----------------------------------------------------------

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
	map.finish_trees()
	var root := Node2D.new()
	root.name = entry.id.to_pascal_case()
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
			elif ch == "," or ch == "*":
				ground.set_cell(c, SRC_BELOW, Vector2i(1, 0))
				below_id = TALL_GRASS_ID if ch == "," else FLOWER_ID
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


# --- Mapa en memoria -----------------------------------------------------------

class ZoneMap:
	var size: Vector2i
	var ground: Array = []           # filas de caracteres (ver AUTOTILE)
	var trees: Array = []            # celda sup. izq. de cada árbol (2x2)
	var tree_tiles: Dictionary = {}  # Vector2i -> metatile
	var objects: Array = []          # [tipo, celda]
	var object_cells: Dictionary = {}

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
				if not inside(c) or tree_tiles.has(c) or ground[yy][xx] != "." or object_cells.has(c):
					return false
		return true

	## ¿Hay algún suelo de esos tipos a distancia 1 de la celda?
	func near(c: Vector2i, chars: Array) -> bool:
		return near_rect(c.x, c.y, 1, 1, chars)

	func near_rect(x: int, y: int, w: int, h: int, chars: Array) -> bool:
		for yy in range(y - 1, y + h + 1):
			for xx in range(x - 1, x + w + 1):
				if inside(Vector2i(xx, yy)) and ground[yy][xx] in chars:
					return true
		return false

	## Árbol cónico de Kanto (2x2). La copa definitiva se elige en finish_trees().
	func tree(x: int, y: int) -> void:
		trees.append(Vector2i(x, y))
		tree_tiles[Vector2i(x, y)] = TREE_TOP[0]
		tree_tiles[Vector2i(x + 1, y)] = TREE_TOP[1]
		tree_tiles[Vector2i(x, y + 1)] = TREE_BOTTOM[0]
		tree_tiles[Vector2i(x + 1, y + 1)] = TREE_BOTTOM[1]

	## Los árboles con otro árbol alineado justo arriba usan la copa "apilada" (como en FireRed).
	func finish_trees() -> void:
		var origins := {}
		for t in trees:
			origins[t] = true
		for t in trees:
			if origins.has(t + Vector2i(0, -2)):
				tree_tiles[t] = TREE_TOP_STACKED[0]
				tree_tiles[t + Vector2i(1, 0)] = TREE_TOP_STACKED[1]

	func put(kind: String, x: int, y: int) -> void:
		objects.append([kind, Vector2i(x, y)])
		object_cells[Vector2i(x, y)] = true

	## Hilera doble de árboles sobre los lados indicados (límite de la región).
	func border(sides: Array) -> void:
		for y in range(0, size.y, 2):
			for x in range(0, size.x, 2):
				var edge := (y <= 2 and "up" in sides) or (y >= size.y - 4 and "down" in sides) \
					or (x <= 2 and "left" in sides) or (x >= size.x - 4 and "right" in sides)
				if edge and not tree_tiles.has(Vector2i(x, y)):
					tree(x, y)

	## Camino de 2 celdas desde una salida hasta la plaza: primero perpendicular al borde, después de costado.
	func carve(from: Vector2i, hub: Vector2i, side: String, ch: String) -> void:
		var corner := Vector2i(from.x, hub.y) if side in ["up", "down"] else Vector2i(hub.x, from.y)
		_segment(from, corner, ch)
		_segment(corner, hub, ch)

	func _segment(a: Vector2i, b: Vector2i, ch: String) -> void:
		var lo := Vector2i(mini(a.x, b.x), mini(a.y, b.y))
		var hi := Vector2i(maxi(a.x, b.x), maxi(a.y, b.y))
		rect(ch, lo.x, lo.y, hi.x - lo.x + 2, hi.y - lo.y + 2)
