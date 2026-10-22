class_name ZoneGenerator
extends RefCounted
## Generador procedural de zonas según su bioma (caminos, agua, pasto alto, árboles, rocas...).
## Lo usan tools/build_world.gd (toda la región) y el editor de mapas ("Nueva zona" generada).

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

const OBJECT_SCENES := {
	"rock": "res://scenes/world/objects/rock_smash_rock.tscn",
	"boulder": "res://scenes/world/objects/strength_boulder.tscn",
	"cut_tree": "res://scenes/world/objects/cut_tree.tscn",
}

var roles: TileRoleSet
var tileset: TileSet
var rng := RandomNumberGenerator.new()


func _init(p_roles: TileRoleSet, p_tileset: TileSet) -> void:
	roles = p_roles
	tileset = p_tileset


## Genera la escena de la zona (sin guardar). `plain` = todo pasto, sin bioma ni caminos.
func generate(e: ZoneEntry, plain: bool = false) -> Node2D:
	rng.seed = hash(e.id)
	var m := ZoneMap.new(e.size, roles)
	if not plain:
		_fill(e, m)
	return _to_scene(e, m)


func _fill(e: ZoneEntry, m: ZoneMap) -> void:
	var biome: Dictionary = BIOMES.get(e.biome, BIOMES["pradera"])
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


## Pasa el mapa en memoria a una escena de zona (capas reales del juego).
func _to_scene(e: ZoneEntry, map: ZoneMap) -> Node2D:
	map.finish_trees()
	var root := ZoneBuilder.new_zone_root(e.id, tileset)
	var tree_cells: Array[Vector2i] = []
	tree_cells.assign(map.trees)
	root.set("tree_cells", tree_cells)
	var ground: TileMapLayer = root.get_node("Ground")
	var water: TileMapLayer = root.get_node("Water")
	var foliage: TileMapLayer = root.get_node("Foliage")
	var overhead: TileMapLayer = root.get_node("Overhead")
	var layers := {"Ground": ground, "Water": water, "Foliage": foliage}
	var base := roles.get_role(roles.base_role)

	for y in map.size.y:
		for x in map.size.x:
			var c := Vector2i(x, y)
			var ch: String = map.ground[y][x]
			var below_id: int = base.pick(rng)
			var target := ground
			var role := roles.by_symbol(ch)
			if role != null and role != base:
				target = layers[role.layer]
				if role.under != "":
					ZoneBuilder.set_metatile(ground, c, roles.get_role(role.under).metatiles[0])
				if role.kind == TileRole.Kind.AUTOTILE:
					below_id = ZoneBuilder.autotile_piece(role, func(d: Vector2i) -> bool:
						var n := c + d
						return not map.inside(n) or map.ground[n.y][n.x] == ch)
				else:
					below_id = role.metatiles[0]
			if map.tree_tiles.has(c):
				below_id = map.tree_tiles[c]
				target = ground
			ZoneBuilder.set_metatile(target, c, below_id)
			if ZoneBuilder.has_above(below_id):
				ZoneBuilder.set_above(overhead, c, below_id)

	for obj in map.objects:
		ZoneBuilder.add_object(root, OBJECT_SCENES[obj[0]], obj[1])
	return root


# --- Mapa en memoria -----------------------------------------------------------

class ZoneMap:
	var size: Vector2i
	var ground: Array = []           # filas de caracteres (TileRole.symbol)
	var trees: Array = []            # celda sup. izq. de cada árbol (2x2)
	var tree_tiles: Dictionary = {}  # Vector2i -> metatile
	var objects: Array = []          # [tipo, celda]
	var object_cells: Dictionary = {}
	var tree_role: TileRole

	func _init(p_size: Vector2i, p_roles: TileRoleSet) -> void:
		size = p_size
		for r in p_roles.roles:
			if r.kind == TileRole.Kind.TREE:
				tree_role = r
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
		var m := tree_role.metatiles
		trees.append(Vector2i(x, y))
		tree_tiles[Vector2i(x, y)] = m[0]
		tree_tiles[Vector2i(x + 1, y)] = m[1]
		tree_tiles[Vector2i(x, y + 1)] = m[4]
		tree_tiles[Vector2i(x + 1, y + 1)] = m[5]

	## Los árboles con otro árbol alineado justo arriba usan la copa "apilada" (como en FireRed).
	func finish_trees() -> void:
		var origins := {}
		for t in trees:
			origins[t] = true
		for t in trees:
			if origins.has(t + Vector2i(0, -2)):
				tree_tiles[t] = tree_role.metatiles[2]
				tree_tiles[t + Vector2i(1, 0)] = tree_role.metatiles[3]

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
