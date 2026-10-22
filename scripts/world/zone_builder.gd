class_name ZoneBuilder
extends RefCounted
## Núcleo compartido entre tools/build_world.gd y el editor de mapas: arma el TileSet desde los roles
## (data/world/tile_roles.tres), crea la escena de una zona con la estructura exacta que espera el juego
## (capas, z_index, materiales, scripts, owners), el autotile 3x3 de FireRed y conversiones de metatiles.

const T := 16
const TILES_DIR := "res://art/pret/tiles"
const TILESET_PATH := "res://art/tiles/world_tileset.tres"
const ROLES_PATH := "res://data/world/tile_roles.tres"
const WORLD_PATH := "res://data/world/kanto.tres"
const ZONES_DIR := "res://scenes/world/zones"
const OBJECTS_DIR := "res://scenes/world/objects"

# Fuentes del TileSet
const SRC_BELOW := 0
const SRC_ANIM := 1
const SRC_ABOVE := 2

## Capas de tiles de una zona, en orden (índice = el que usa el editor).
const LAYERS := ["Ground", "Water", "Foliage", "Overhead"]
const GROUND := 0
const WATER := 1
const FOLIAGE := 2
const OVERHEAD := 3

static var _manifest: Dictionary
## anim row -> metatile (inversa de manifest.anim)
static var _anim_rows: Dictionary


## Datos del tileset "general" de FireRed (art/pret/tiles/manifest.json).
static func manifest() -> Dictionary:
	if _manifest.is_empty():
		_manifest = JSON.parse_string(FileAccess.get_file_as_string(TILES_DIR + "/manifest.json"))["general"]
		for key in _manifest["anim"]:
			_anim_rows[int(_manifest["anim"][key]["row"])] = int(key)
	return _manifest


static func load_roles() -> TileRoleSet:
	return load(ROLES_PATH)


# --- TileSet -----------------------------------------------------------------

## TileSet nuevo a partir de los atlas de FireRed; tags y colisión salen de los roles (+ ajustes).
static func build_tileset(roles: TileRoleSet) -> TileSet:
	var m := manifest()
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

	var count := int(m["count"])
	var below := _atlas(TILES_DIR + "/general_below.png")
	ts.add_source(below, SRC_BELOW)
	for i in count:
		below.create_tile(Vector2i(i % 16, i / 16))

	var anim := _atlas(TILES_DIR + "/general_anim.png")
	ts.add_source(anim, SRC_ANIM)
	for key in m["anim"]:
		var a: Dictionary = m["anim"][key]
		var c := Vector2i(0, int(a["row"]))
		anim.create_tile(c)
		anim.set_tile_animation_columns(c, int(a["frames"]))
		anim.set_tile_animation_frames_count(c, int(a["frames"]))
		for f in int(a["frames"]):
			anim.set_tile_animation_frame_duration(c, f, float(a["duration"]))

	var above := _atlas(TILES_DIR + "/general_above.png")
	ts.add_source(above, SRC_ABOVE)
	for i in count:
		if m["above_used"][i]:
			above.create_tile(Vector2i(i % 16, i / 16))

	for i in count:
		apply_tile_props(ts, roles, i)
	return ts


static func _atlas(path: String) -> TileSetAtlasSource:
	var src := TileSetAtlasSource.new()
	src.texture = load(path)
	src.texture_region_size = Vector2i(T, T)
	return src


## Aplica tags y colisión (cuadrado de 16x16) de un metatile a sus tiles del TileSet (normal y animado).
static func apply_tile_props(ts: TileSet, roles: TileRoleSet, metatile: int) -> void:
	var tags := roles.tags_for(metatile)
	var physics := roles.physics_for(metatile)
	var h := T / 2.0
	for td in _tile_datas(ts, metatile):
		td.set_custom_data("tags", tags)
		for layer in 2:
			td.set_collision_polygons_count(layer, 0)
		if physics >= 0:
			td.add_collision_polygon(physics)
			td.set_collision_polygon_points(physics, 0, PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)]))


static func _tile_datas(ts: TileSet, metatile: int) -> Array[TileData]:
	var out: Array[TileData] = []
	var below: TileSetAtlasSource = ts.get_source(SRC_BELOW)
	var c := Vector2i(metatile % 16, metatile / 16)
	if below.has_tile(c):
		out.append(below.get_tile_data(c, 0))
	var key := str(metatile)
	if manifest()["anim"].has(key):
		var ac := Vector2i(0, int(manifest()["anim"][key]["row"]))
		var anim: TileSetAtlasSource = ts.get_source(SRC_ANIM)
		if anim.has_tile(ac):
			out.append(anim.get_tile_data(ac, 0))
	return out


# --- Metatiles ---------------------------------------------------------------

## Dónde está un metatile en el TileSet: [fuente, coordenadas]. Prefiere la versión animada.
static func below_ref(metatile: int) -> Array:
	var key := str(metatile)
	if manifest()["anim"].has(key):
		return [SRC_ANIM, Vector2i(0, int(manifest()["anim"][key]["row"]))]
	return [SRC_BELOW, Vector2i(metatile % 16, metatile / 16)]


## ¿El metatile tiene parte superior (va también en Overhead)?
static func has_above(metatile: int) -> bool:
	return metatile >= 0 and metatile < int(manifest()["count"]) and bool(manifest()["above_used"][metatile])


static func is_animated(metatile: int) -> bool:
	return manifest()["anim"].has(str(metatile))


## Metatile de FireRed de un tile del TileSet (-1 si no hay).
static func metatile_of(source: int, coords: Vector2i) -> int:
	if source < 0:
		return -1
	if source == SRC_ANIM:
		manifest()
		return _anim_rows.get(coords.y, -1)
	return coords.y * 16 + coords.x


static func metatile_at(layer: TileMapLayer, cell: Vector2i) -> int:
	return metatile_of(layer.get_cell_source_id(cell), layer.get_cell_atlas_coords(cell))


## Pone un metatile (parte de abajo) en una capa.
static func set_metatile(layer: TileMapLayer, cell: Vector2i, metatile: int) -> void:
	var ref := below_ref(metatile)
	layer.set_cell(cell, ref[0], ref[1])


## Autotile 3x3: elige la pieza (bordes/esquinas) según qué vecinos son del mismo rol.
## `same` recibe una dirección (Vector2i) y dice si el vecino es igual; fuera de la zona cuenta como igual,
## así los caminos siguen en la zona vecina. No usa los terrains de Godot: tratan lo de afuera de la zona
## como vacío (cortan los caminos en las salidas) y, sin esquinas interiores en el 3x3 de FireRed, eligen
## otra pieza donde se cruzan caminos (~7% de las celdas distintas; ver README, "Editor de mapas").
static func autotile_piece(role: TileRole, same: Callable) -> int:
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
	return role.piece(row, col)


# --- Escena de zona ----------------------------------------------------------

## Raíz de una zona nueva y vacía con todas sus capas (misma estructura que espera el juego).
static func new_zone_root(zone_id: String, tileset: TileSet) -> Node2D:
	var root := Node2D.new()
	root.name = zone_id.to_pascal_case()
	root.y_sort_enabled = true
	root.set_script(load("res://scripts/world/zone.gd"))
	root.set("zone_id", zone_id)
	_layer(root, "Ground", -10, tileset)
	_layer(root, "Water", -9, tileset, "res://shaders/materials/water.tres")
	_layer(root, "Foliage", -8, tileset, "res://shaders/materials/foliage_wind.tres")
	var shadows := Node2D.new()
	shadows.name = "TreeShadows"
	shadows.z_index = -7
	shadows.set_script(load("res://scripts/world/tree_shadows.gd"))
	root.add_child(shadows)
	shadows.owner = root
	_layer(root, "Overhead", 20, tileset, "res://shaders/materials/canopy_wind.tres")
	var objects := Node2D.new()
	objects.name = "Objects"
	objects.y_sort_enabled = true
	root.add_child(objects)
	objects.owner = root
	return root


static func _layer(root: Node, layer_name: String, z: int, tileset: TileSet, material_path: String = "") -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = tileset
	layer.z_index = z
	if material_path != "":
		layer.material = load(material_path)
	root.add_child(layer)
	layer.owner = root
	return layer


## Posición de un objeto del entorno en su celda (origen en los pies).
static func object_position(cell: Vector2i) -> Vector2:
	return Vector2(cell * T) + Vector2(T / 2.0, T)


static func object_cell(pos: Vector2) -> Vector2i:
	return Vector2i(floori((pos.x - T / 2.0) / T), floori((pos.y - T) / T))


## Agrega un objeto (escena de scenes/world/objects) a la zona, en una celda.
static func add_object(root: Node, scene_path: String, cell: Vector2i) -> Node2D:
	var node: Node2D = load(scene_path).instantiate()
	node.position = object_position(cell)
	root.get_node("Objects").add_child(node)
	node.owner = root
	return node


static func save_zone(root: Node, path: String) -> Error:
	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err != OK:
		return err
	return ResourceSaver.save(packed, path)


## ¿La escena de zona fue editada con el editor de mapas? (build_world --force no la pisa).
static func is_hand_edited(scene_path: String) -> bool:
	if not ResourceLoader.exists(scene_path):
		return false
	var packed: PackedScene = load(scene_path)
	var state := packed.get_state()
	for i in state.get_node_property_count(0):
		if state.get_node_property_name(0, i) == "hand_edited":
			return bool(state.get_node_property_value(0, i))
	return false
