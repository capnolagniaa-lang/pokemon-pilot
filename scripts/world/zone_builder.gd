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

# Fuentes del TileSet (las del tileset general; cada tileset suma 3: abajo, animado, arriba)
const SRC_BELOW := 0
const SRC_ANIM := 1
const SRC_ABOVE := 2

## Capas de tiles de una zona, en orden (índice = el que usa el editor).
const LAYERS := ["Ground", "Water", "Foliage", "Overhead"]
const GROUND := 0
const WATER := 1
const FOLIAGE := 2
const OVERHEAD := 3

## Id global de un metatile: base de su tileset + índice local. El "general" (exteriores) va de 0 a 639; el
## resto de los tilesets de FireRed, de a 1000 según manifest.json → order (que es estable: solo se agregan).
const SET_STRIDE := 1000
## Fuentes del TileSet por tileset: general 0/1/2; el k-ésimo de `order`, 3+3k (abajo), 4+3k (animado), 5+3k (arriba).

static var _all: Dictionary
## nombre del tileset -> {fila animada -> metatile local}
static var _anim_rows: Dictionary


## Manifest completo de art/pret/tiles/manifest.json (lo genera tools/pret_import.py).
static func manifest_all() -> Dictionary:
	if _all.is_empty():
		_all = JSON.parse_string(FileAccess.get_file_as_string(TILES_DIR + "/manifest.json"))
		for name in set_names():
			var rows := {}
			for key in _all[name]["anim"]:
				rows[int(_all[name]["anim"][key]["row"])] = int(key)
			_anim_rows[name] = rows
	return _all


## Datos del tileset "general" de FireRed.
static func manifest() -> Dictionary:
	return manifest_all()["general"]


## Tilesets importados: "general" y después los de `order`.
static func set_names() -> PackedStringArray:
	var out := PackedStringArray(["general"])
	out.append_array(PackedStringArray(manifest_all().get("order", [])))
	return out


static func set_info(set_name: String) -> Dictionary:
	return manifest_all()[set_name]


## Tileset al que pertenece un id global.
static func set_of(metatile: int) -> String:
	var k := metatile / SET_STRIDE
	if k == 0:
		return "general"
	var order: Array = manifest_all()["order"]
	return order[k - 1] if k - 1 < order.size() else ""


static func local_of(metatile: int) -> int:
	return metatile % SET_STRIDE


static func base_of(set_name: String) -> int:
	return int(set_info(set_name).get("base", 0))


## [abajo, animado, arriba] del tileset en el TileSet.
static func sources_of(set_name: String) -> Array:
	return set_info(set_name).get("sources", [SRC_BELOW, SRC_ANIM, SRC_ABOVE])


## ¿Existe el metatile y tiene algo dibujado?
static func exists(metatile: int) -> bool:
	if metatile < 0:
		return false
	var s := set_of(metatile)
	if s == "":
		return false
	var info := set_info(s)
	var l := local_of(metatile)
	return l < int(info["count"]) and not bool(info.get("empty", [])[l] if info.has("empty") else false)


static func behavior_of(metatile: int) -> int:
	return int(set_info(set_of(metatile))["behavior"][local_of(metatile)])


static func load_roles() -> TileRoleSet:
	return load(ROLES_PATH)


# --- TileSet -----------------------------------------------------------------

## TileSet nuevo a partir de los atlas de FireRed (todos los tilesets importados); tags y colisión salen de
## los roles (+ ajustes y catálogo).
static func build_tileset(roles: TileRoleSet) -> TileSet:
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
	for set_name in set_names():
		_add_set(ts, set_name)
	for set_name in set_names():
		var base := base_of(set_name)
		for i in int(set_info(set_name)["count"]):
			if exists(base + i) or set_name == "general":
				apply_tile_props(ts, roles, base + i)
	return ts


static func _add_set(ts: TileSet, set_name: String) -> void:
	var m := set_info(set_name)
	var src: Array = sources_of(set_name)
	var count := int(m["count"])
	var general := set_name == "general"  # el general tiene todos sus tiles (compatibilidad con las zonas viejas)
	var below := _atlas("%s/%s_below.png" % [TILES_DIR, set_name])
	ts.add_source(below, src[0])
	for i in count:
		if general or not m["empty"][i]:
			below.create_tile(Vector2i(i % 16, i / 16))
	if not m["anim"].is_empty():
		var anim := _atlas("%s/%s_anim.png" % [TILES_DIR, set_name])
		ts.add_source(anim, src[1])
		for key in m["anim"]:
			var a: Dictionary = m["anim"][key]
			var c := Vector2i(0, int(a["row"]))
			anim.create_tile(c)
			anim.set_tile_animation_columns(c, int(a["frames"]))
			anim.set_tile_animation_frames_count(c, int(a["frames"]))
			for f in int(a["frames"]):
				anim.set_tile_animation_frame_duration(c, f, float(a["duration"]))
	if m["above_used"].has(true):
		var above := _atlas("%s/%s_above.png" % [TILES_DIR, set_name])
		ts.add_source(above, src[2])
		for i in count:
			if m["above_used"][i]:
				above.create_tile(Vector2i(i % 16, i / 16))


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
	var s := set_of(metatile)
	if s == "":
		return out
	var src: Array = sources_of(s)
	var l := local_of(metatile)
	if ts.has_source(src[0]):
		var below: TileSetAtlasSource = ts.get_source(src[0])
		if below.has_tile(Vector2i(l % 16, l / 16)):
			out.append(below.get_tile_data(Vector2i(l % 16, l / 16), 0))
	var key := str(l)
	if set_info(s)["anim"].has(key) and ts.has_source(src[1]):
		var ac := Vector2i(0, int(set_info(s)["anim"][key]["row"]))
		var anim: TileSetAtlasSource = ts.get_source(src[1])
		if anim.has_tile(ac):
			out.append(anim.get_tile_data(ac, 0))
	return out


# --- Metatiles ---------------------------------------------------------------

## Dónde está un metatile en el TileSet: [fuente, coordenadas]. Prefiere la versión animada.
static func below_ref(metatile: int) -> Array:
	var s := set_of(metatile)
	var src: Array = sources_of(s)
	var l := local_of(metatile)
	var key := str(l)
	if set_info(s)["anim"].has(key):
		return [src[1], Vector2i(0, int(set_info(s)["anim"][key]["row"]))]
	return [src[0], Vector2i(l % 16, l / 16)]


## Dónde está la parte de arriba (Overhead) de un metatile: [fuente, coordenadas].
static func above_ref(metatile: int) -> Array:
	var l := local_of(metatile)
	return [sources_of(set_of(metatile))[2], Vector2i(l % 16, l / 16)]


## ¿El metatile tiene parte superior (va también en Overhead)?
static func has_above(metatile: int) -> bool:
	if metatile < 0 or set_of(metatile) == "":
		return false
	var info := set_info(set_of(metatile))
	var l := local_of(metatile)
	return l < int(info["count"]) and bool(info["above_used"][l])


static func is_animated(metatile: int) -> bool:
	return metatile >= 0 and set_info(set_of(metatile))["anim"].has(str(local_of(metatile)))


## ¿La fuente es la de las partes de arriba (Overhead) de algún tileset?
static func is_above_source(source: int) -> bool:
	return source >= 0 and source % 3 == SRC_ABOVE


## Metatile de FireRed (id global) de un tile del TileSet (-1 si no hay).
static func metatile_of(source: int, coords: Vector2i) -> int:
	if source < 0:
		return -1
	var k := source / 3  # 0 = general, k = k-ésimo de order
	var names := set_names()
	if k >= names.size():
		return -1
	var s := names[k]
	if source % 3 == SRC_ANIM:
		manifest_all()
		var l: int = _anim_rows[s].get(coords.y, -1)
		return base_of(s) + l if l >= 0 else -1
	return base_of(s) + coords.y * 16 + coords.x


static func metatile_at(layer: TileMapLayer, cell: Vector2i) -> int:
	return metatile_of(layer.get_cell_source_id(cell), layer.get_cell_atlas_coords(cell))


## Pone un metatile (parte de abajo) en una capa.
static func set_metatile(layer: TileMapLayer, cell: Vector2i, metatile: int) -> void:
	var ref := below_ref(metatile)
	layer.set_cell(cell, ref[0], ref[1])


## Pone la parte de arriba de un metatile en Overhead.
static func set_above(layer: TileMapLayer, cell: Vector2i, metatile: int) -> void:
	var ref := above_ref(metatile)
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
