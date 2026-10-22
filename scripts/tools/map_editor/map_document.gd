class_name MapDocument
extends RefCounted
## Una zona abierta en el editor de mapas. El lienzo ES la escena real de la zona (sus TileMapLayer y
## objetos); acá están las operaciones con las reglas del juego (pinceles semánticos, autotile, árboles con
## copa y sombra, objetos), deshacer/rehacer y guardar con el mismo formato que genera build_world.gd.
## No conoce la UI: el autotest del editor la usa sin ventana.

signal changed
signal region_changed

const GROUND := ZoneBuilder.GROUND
const WATER := ZoneBuilder.WATER
const FOLIAGE := ZoneBuilder.FOLIAGE
const OVERHEAD := ZoneBuilder.OVERHEAD
## "Capa" de objetos (para borrar y el balde); no es un TileMapLayer.
const OBJECTS := 4
const NO_TREE := Vector2i(-9999, -9999)
const BACKUPS_KEPT := 5

var world: WorldData
var entry: ZoneEntry
var zone: Zone
var roles: TileRoleSet
var tileset: TileSet
var undo := UndoRedo.new()
var rng := RandomNumberGenerator.new()
## Hubo cambios de la región (hub, salidas, nombre, inicio...) desde el último guardado.
var region_dirty := false

var _saved_version := 0
var _rec_tiles: Dictionary = {}    # Vector3i(capa, x, y) -> [fuente, coords, alt] de antes
var _rec_objects: Dictionary = {}  # celda -> escena de antes ("" = ninguna)
var _rec_trees = null              # tree_cells de antes (o null si no cambió)


## Copia editable de la región (se descarta recargándola del disco).
static func load_world_copy() -> WorldData:
	var src: WorldData = ResourceLoader.load(ZoneBuilder.WORLD_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	var w := WorldData.new()
	w.tile_size = src.tile_size
	w.spawn_cell = src.spawn_cell
	var zones: Array[ZoneEntry] = []
	for z in src.zones:
		var c: ZoneEntry = z.duplicate()
		c.exits = z.exits.duplicate()
		zones.append(c)
	w.zones = zones
	return w


## Abre una zona existente de la región.
static func open(p_world: WorldData, p_entry: ZoneEntry, p_roles: TileRoleSet) -> MapDocument:
	var packed: PackedScene = ResourceLoader.load(p_entry.scene_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	return _make(p_world, p_entry, p_roles, packed.instantiate())


## Zona nueva: todo pasto o generada con el generador del bioma. No la agrega a la región (lo hace quien llama).
static func create(p_world: WorldData, p_entry: ZoneEntry, p_roles: TileRoleSet, p_tileset: TileSet, generated: bool) -> MapDocument:
	var gen := ZoneGenerator.new(p_roles, p_tileset)
	var d := _make(p_world, p_entry, p_roles, gen.generate(p_entry, not generated))
	d._saved_version = -1  # sin guardar
	return d


static func _make(p_world: WorldData, p_entry: ZoneEntry, p_roles: TileRoleSet, node: Node) -> MapDocument:
	var d := MapDocument.new()
	d.world = p_world
	d.entry = p_entry
	d.roles = p_roles
	d.zone = node
	d.tileset = (node.get_node("Ground") as TileMapLayer).tile_set
	d.rng.randomize()
	d._saved_version = d.undo.get_version()
	return d


func dispose() -> void:
	if is_instance_valid(zone):
		zone.queue_free()
	undo.free()


func layer(li: int) -> TileMapLayer:
	return zone.get_node(ZoneBuilder.LAYERS[li])


func inside(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < entry.size.x and c.y < entry.size.y


func is_dirty() -> bool:
	return region_dirty or undo.get_version() != _saved_version


## Escenas de objetos disponibles (todo lo que haya en scenes/world/objects: uno nuevo aparece solo).
static func object_scenes() -> PackedStringArray:
	var out := PackedStringArray()
	for f in DirAccess.get_files_at(ZoneBuilder.OBJECTS_DIR):
		if f.ends_with(".tscn"):
			out.append(ZoneBuilder.OBJECTS_DIR + "/" + f)
	return out


# --- Lectura -------------------------------------------------------------------

func metatile(li: int, cell: Vector2i) -> int:
	return ZoneBuilder.metatile_at(layer(li), cell)


func role_in(li: int, cell: Vector2i) -> TileRole:
	return roles.role_of(metatile(li, cell))


## Rol "visible" de la celda (árbol, follaje, agua o suelo, en ese orden).
func role_at(cell: Vector2i) -> TileRole:
	if tree_origin_at(cell) != NO_TREE:
		return tree_role()
	for li in [FOLIAGE, WATER, GROUND]:
		var r := role_in(li, cell)
		if r != null:
			return r
	return null


func tree_role() -> TileRole:
	for r in roles.roles:
		if r.kind == TileRole.Kind.TREE:
			return r
	return null


func base_role() -> TileRole:
	return roles.get_role(roles.base_role)


func object_at(cell: Vector2i) -> Node2D:
	return MapRules.objects_by_cell(zone).get(cell)


func has_tree(origin: Vector2i) -> bool:
	return zone.tree_cells.has(origin)


## Celda de origen (sup. izq.) del árbol que ocupa la celda, o NO_TREE.
func tree_origin_at(cell: Vector2i) -> Vector2i:
	for d in [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1)]:
		if zone.tree_cells.has(cell + d):
			return cell + d
	return NO_TREE


# --- Primitivas (graban para deshacer) ----------------------------------------

func get_raw(li: int, cell: Vector2i) -> Array:
	var l := layer(li)
	return [l.get_cell_source_id(cell), l.get_cell_atlas_coords(cell), l.get_cell_alternative_tile(cell)]


func set_raw(li: int, cell: Vector2i, source: int, coords: Vector2i, alt: int = 0) -> void:
	var key := Vector3i(li, cell.x, cell.y)
	if not _rec_tiles.has(key):
		_rec_tiles[key] = get_raw(li, cell)
	if source < 0:
		layer(li).erase_cell(cell)
	else:
		layer(li).set_cell(cell, source, coords, alt)


func set_metatile(li: int, cell: Vector2i, m: int) -> void:
	if m < 0:
		set_raw(li, cell, -1, Vector2i(-1, -1))
		return
	var ref := ZoneBuilder.below_ref(m)
	set_raw(li, cell, ref[0], ref[1])


func clear(li: int, cell: Vector2i) -> void:
	if layer(li).get_cell_source_id(cell) >= 0:
		set_raw(li, cell, -1, Vector2i(-1, -1))


## Pone (o saca, con "") el objeto de una celda. Nunca hay dos objetos en la misma celda.
func set_object(cell: Vector2i, scene_path: String) -> void:
	var current := object_at(cell)
	var before := current.scene_file_path if current != null else ""
	if before == scene_path:
		return
	if not _rec_objects.has(cell):
		_rec_objects[cell] = before
	_put_object(cell, scene_path)


func _put_object(cell: Vector2i, scene_path: String) -> void:
	var current := object_at(cell)
	if current != null:
		current.get_parent().remove_child(current)
		current.free()
	if scene_path != "":
		ZoneBuilder.add_object(zone, scene_path, cell)


func _touch_trees() -> void:
	if _rec_trees == null:
		_rec_trees = zone.tree_cells.duplicate()


## Cierra la operación en curso como un paso de deshacer. Devuelve false si no cambió nada.
func commit(action_name: String) -> bool:
	if _rec_tiles.is_empty() and _rec_objects.is_empty() and _rec_trees == null:
		return false
	var after_t := {}
	for k: Vector3i in _rec_tiles:
		after_t[k] = get_raw(k.x, Vector2i(k.y, k.z))
	var after_o := {}
	for c in _rec_objects:
		var n := object_at(c)
		after_o[c] = n.scene_file_path if n != null else ""
	var after_tr = zone.tree_cells.duplicate() if _rec_trees != null else null
	undo.create_action(action_name)
	undo.add_do_method(_apply.bind(after_t, after_o, after_tr))
	undo.add_undo_method(_apply.bind(_rec_tiles, _rec_objects, _rec_trees))
	_rec_tiles = {}
	_rec_objects = {}
	_rec_trees = null
	undo.commit_action(false)
	_redraw_shadows()
	changed.emit()
	return true


func _apply(tiles: Dictionary, objs: Dictionary, trees) -> void:
	for k: Vector3i in tiles:
		var t: Array = tiles[k]
		var cell := Vector2i(k.y, k.z)
		if t[0] < 0:
			layer(k.x).erase_cell(cell)
		else:
			layer(k.x).set_cell(cell, t[0], t[1], t[2])
	for c in objs:
		_put_object(c, objs[c])
	if trees != null:
		zone.tree_cells = trees.duplicate()
	_redraw_shadows()
	changed.emit()


func _redraw_shadows() -> void:
	var s := zone.get_node_or_null("TreeShadows")
	if s != null:
		s.queue_redraw()


func do_undo() -> bool:
	commit("")  # por si quedó algo a medias
	return undo.undo()


func do_redo() -> bool:
	return undo.redo()


# --- Pinceles semánticos ------------------------------------------------------------

## Pinta un rol en las celdas con sus reglas: capa, lo que va abajo, autotile de bordes y árboles.
func paint_role(cells: Array, role: TileRole) -> void:
	if role.kind == TileRole.Kind.TREE:
		for c in cells:
			place_tree(c)
		return
	var li := ZoneBuilder.LAYERS.find(role.layer)
	var touched: Array[Vector2i] = []
	for c: Vector2i in cells:
		if not inside(c):
			continue
		var t := tree_origin_at(c)
		if t != NO_TREE:
			remove_tree(t)
		if li != WATER:
			clear(WATER, c)
		if li != FOLIAGE:
			clear(FOLIAGE, c)
		if role.under != "":
			var u := roles.get_role(role.under)
			if role_in(GROUND, c) != u:
				set_metatile(GROUND, c, u.pick(rng))
		if role_in(li, c) != role:
			set_metatile(li, c, role.piece(1, 1) if role.kind == TileRole.Kind.AUTOTILE else role.pick(rng))
		_sync_overhead(c)
		touched.append(c)
	refresh_autotile(touched)


## Borra. li = -1: todo lo de la celda (tiles, objeto y árbol) y deja pasto. GROUND deja pasto.
func erase(cells: Array, li: int = -1) -> void:
	var base := base_role()
	var touched: Array[Vector2i] = []
	for c: Vector2i in cells:
		if not inside(c) and li != OVERHEAD:
			continue
		if li == -1 or li == GROUND:
			var t := tree_origin_at(c)
			if t != NO_TREE:
				remove_tree(t)
		if li == -1 or li == OBJECTS:
			set_object(c, "")
		if li == -1:
			for l in [WATER, FOLIAGE, OVERHEAD]:
				clear(l, c)
		if li == -1 or li == GROUND:
			if role_in(GROUND, c) != base:
				set_metatile(GROUND, c, base.pick(rng))
			_sync_overhead(c)
		elif li in [WATER, FOLIAGE, OVERHEAD]:
			clear(li, c)
			if li != OVERHEAD:
				_sync_overhead(c)
		touched.append(c)
	refresh_autotile(touched)


## Overhead de la celda según la parte de arriba (above) de su tile más alto.
func _sync_overhead(c: Vector2i) -> void:
	for li in [FOLIAGE, WATER, GROUND]:
		var m := metatile(li, c)
		if m >= 0 and ZoneBuilder.has_above(m):
			var ref := ZoneBuilder.above_ref(m)
			if get_raw(OVERHEAD, c) != [ref[0], ref[1], 0]:
				set_raw(OVERHEAD, c, ref[0], ref[1])
			return
	clear(OVERHEAD, c)


## Recalcula bordes y esquinas (autotile 3x3) de las celdas y sus vecinas.
func refresh_autotile(cells: Array) -> void:
	var todo := {}
	for c: Vector2i in cells:
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				todo[c + Vector2i(dx, dy)] = true
	for c: Vector2i in todo:
		if not inside(c):
			continue
		for li in [GROUND, WATER, FOLIAGE]:
			var r := role_in(li, c)
			if r == null or r.kind != TileRole.Kind.AUTOTILE:
				continue
			var piece := ZoneBuilder.autotile_piece(r, func(d: Vector2i) -> bool:
				var n := c + d
				return not inside(n) or role_in(li, n) == r)
			if metatile(li, c) != piece:
				set_metatile(li, c, piece)


# --- Árboles -------------------------------------------------------------------------

## Árbol 2x2 con su copa (Overhead) y su sombra; si hay otro árbol justo arriba usa la copa apilada.
func place_tree(o: Vector2i) -> void:
	if not inside(o) or not inside(o + Vector2i.ONE) or has_tree(o):
		return
	var cells: Array[Vector2i] = [o, o + Vector2i(1, 0), o + Vector2i(0, 1), o + Vector2i(1, 1)]
	for c in cells:
		var t := tree_origin_at(c)
		if t != NO_TREE:
			remove_tree(t)
	for c in cells:
		clear(WATER, c)
		clear(FOLIAGE, c)
		set_object(c, "")
	_touch_trees()
	zone.tree_cells.append(o)
	_draw_tree(o)
	if has_tree(o + Vector2i(0, 2)):
		_draw_tree(o + Vector2i(0, 2))
	refresh_autotile(cells)


func remove_tree(o: Vector2i) -> void:
	if not has_tree(o):
		return
	_touch_trees()
	zone.tree_cells.erase(o)
	var base := base_role()
	for d in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
		set_metatile(GROUND, o + d, base.pick(rng))
		_sync_overhead(o + d)
	if has_tree(o + Vector2i(0, 2)):
		_draw_tree(o + Vector2i(0, 2))
	refresh_autotile([o, o + Vector2i.ONE])


func _draw_tree(o: Vector2i) -> void:
	var m := tree_role().metatiles
	var stacked := has_tree(o + Vector2i(0, -2))
	var ids := [m[2] if stacked else m[0], m[3] if stacked else m[1], m[4], m[5]]
	var offs := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
	for i in 4:
		set_metatile(GROUND, o + offs[i], ids[i])
		_sync_overhead(o + offs[i])


## Borde de árboles: hilera doble (2 árboles de alto/ancho) sobre un lado de la zona.
func tree_border(side: String) -> void:
	var cells: Array[Vector2i] = []
	match side:
		"up", "down":
			var ys := [0, 2] if side == "up" else [entry.size.y - 4, entry.size.y - 2]
			for y in ys:
				for x in range(0, entry.size.x - 1, 2):
					cells.append(Vector2i(x, y))
		"left", "right":
			var xs := [0, 2] if side == "left" else [entry.size.x - 4, entry.size.x - 2]
			for x in xs:
				for y in range(0, entry.size.y - 1, 2):
					cells.append(Vector2i(x, y))
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	for c in cells:
		place_tree(c)


# --- Objetos y tiles crudos ---------------------------------------------------------

func place_object(cell: Vector2i, scene_path: String) -> void:
	if not inside(cell):
		return
	var t := tree_origin_at(cell)
	if t != NO_TREE:
		remove_tree(t)
	set_object(cell, scene_path)


## Tile crudo en una capa. Si el metatile tiene parte de arriba, pone también la de Overhead.
func paint_raw(cells: Array, li: int, source: int, coords: Vector2i) -> void:
	for c: Vector2i in cells:
		set_raw(li, c, source, coords)
		if li == OVERHEAD or ZoneBuilder.is_above_source(source):
			continue
		var m := ZoneBuilder.metatile_of(source, coords)
		if ZoneBuilder.has_above(m):
			var ref := ZoneBuilder.above_ref(m)
			set_raw(OVERHEAD, c, ref[0], ref[1])
		elif li == GROUND:
			clear(OVERHEAD, c)


## Sello de varias celdas (edificio de FireRed): pone cada pieza en Ground con su parte de arriba en
## Overhead; saca árboles, agua, follaje y objetos debajo. Las celdas -1 del sello no se tocan.
func place_stamp(stamp: Dictionary, at: Vector2i) -> void:
	var size: Vector2i = stamp["size"]
	var cells: PackedInt32Array = stamp["cells"]
	var touched: Array[Vector2i] = []
	for i in cells.size():
		var m := cells[i]
		var c := at + Vector2i(i % size.x, i / size.x)
		if m < 0 or not inside(c) or not ZoneBuilder.exists(m):
			continue
		var t := tree_origin_at(c)
		if t != NO_TREE:
			remove_tree(t)
		clear(WATER, c)
		clear(FOLIAGE, c)
		set_object(c, "")
		set_metatile(GROUND, c, m)
		_sync_overhead(c)
		touched.append(c)
	refresh_autotile(touched)


# --- Balde y copiar/pegar ----------------------------------------------------------

## Qué hay en la celda para el balde (en la capa activa): rol, metatile, objeto o vacío.
func fill_key(li: int, cell: Vector2i) -> String:
	if li == OBJECTS:
		var n := object_at(cell)
		return n.scene_file_path if n != null else ""
	if li == GROUND and tree_origin_at(cell) != NO_TREE:
		return "role:tree"
	var r := role_in(li, cell)
	if r != null:
		return "role:" + r.id
	var raw := get_raw(li, cell)
	return "%d:%s" % [raw[0], raw[1]]


## Relleno por inundación (4 direcciones) dentro de la zona: celdas con lo mismo que la inicial.
func flood(start: Vector2i, li: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if not inside(start):
		return out
	var key := fill_key(li, start)
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		out.append(c)
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if not seen.has(n) and inside(n) and fill_key(li, n) == key:
				seen[n] = true
				queue.append(n)
	return out


## Copia un rectángulo (TileMapPattern por capa + objetos + árboles enteros).
func copy_region(rect: Rect2i) -> Dictionary:
	var cells: Array[Vector2i] = []
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			cells.append(Vector2i(x, y))
	var patterns: Array[TileMapPattern] = []
	for li in ZoneBuilder.LAYERS.size():
		patterns.append(layer(li).get_pattern(cells))
	var objs := []
	var by_cell := MapRules.objects_by_cell(zone)
	for c in cells:
		if by_cell.has(c):
			objs.append([c - rect.position, by_cell[c].scene_file_path])
	var trees := []
	for t in zone.tree_cells:
		if rect.has_point(t) and rect.has_point(t + Vector2i.ONE):
			trees.append(t - rect.position)
	return {"size": rect.size, "patterns": patterns, "objects": objs, "trees": trees}


func paste(clip: Dictionary, at: Vector2i) -> void:
	var size: Vector2i = clip["size"]
	var rect := Rect2i(at, size)
	for t in zone.tree_cells.duplicate():  # árboles pisados por el pegado: afuera enteros
		if rect.intersects(Rect2i(t, Vector2i(2, 2))):
			remove_tree(t)
	for y in size.y:
		for x in size.x:
			var rel := Vector2i(x, y)
			var c := at + rel
			if not inside(c):
				continue
			set_object(c, "")
			for li in ZoneBuilder.LAYERS.size():
				var p: TileMapPattern = clip["patterns"][li]
				if p.get_cell_source_id(rel) >= 0:
					set_raw(li, c, p.get_cell_source_id(rel), p.get_cell_atlas_coords(rel), p.get_cell_alternative_tile(rel))
				else:
					clear(li, c)
	for o in clip["objects"]:
		if inside(at + o[0]):
			set_object(at + o[0], o[1])
	var pasted: Array[Vector2i] = []
	for t: Vector2i in clip["trees"]:
		if inside(at + t) and inside(at + t + Vector2i.ONE):
			_touch_trees()
			zone.tree_cells.append(at + t)
			pasted.append(at + t)
	for t in pasted:  # copas apiladas según los vecinos del lugar nuevo
		_draw_tree(t)
		if has_tree(t + Vector2i(0, 2)):
			_draw_tree(t + Vector2i(0, 2))


# --- Región (hub, salidas, nombre, bioma, inicio) -------------------------------------------

func set_entry_prop(prop: String, value: Variant, action_name: String) -> void:
	_set_prop(entry, prop, value, action_name)


func set_spawn(world_cell: Vector2i) -> void:
	_set_prop(world, "spawn_cell", world_cell, "Inicio del juego")


func set_exit(side: String, cell: Vector2i) -> void:
	var ex: Dictionary = entry.exits.duplicate()
	ex[side] = clamp_exit(side, cell)
	set_entry_prop("exits", ex, "Salida")


func remove_exit(side: String) -> void:
	var ex: Dictionary = entry.exits.duplicate()
	ex.erase(side)
	set_entry_prop("exits", ex, "Sacar salida")


## Las salidas van pegadas a su borde (camino de 2 celdas).
func clamp_exit(side: String, cell: Vector2i) -> Vector2i:
	var c := cell.clamp(Vector2i.ZERO, entry.size - Vector2i(2, 2))
	match side:
		"up": c.y = 0
		"down": c.y = entry.size.y - 2
		"left": c.x = 0
		"right": c.x = entry.size.x - 2
	return c


func _set_prop(obj: Object, prop: String, value: Variant, action_name: String) -> void:
	if obj.get(prop) == value:
		return
	undo.create_action(action_name)
	undo.add_do_property(obj, prop, value)
	undo.add_undo_property(obj, prop, obj.get(prop))
	undo.add_do_method(_region_touched)
	undo.add_undo_method(_region_touched)
	undo.commit_action()


func _region_touched() -> void:
	region_dirty = true
	region_changed.emit()
	changed.emit()


func validate() -> Array[Dictionary]:
	return MapRules.validate(zone, entry, world)


# --- Guardar ---------------------------------------------------------------------------

## ¿Se puede escribir en res://? (el juego corre desde la carpeta del proyecto, no exportado)
static func res_writable() -> bool:
	var probe := "res://.map_editor_write_test"
	var f := FileAccess.open(probe, FileAccess.WRITE)
	if f == null:
		return false
	f.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(probe))
	return true


## Guarda la escena de la zona (misma estructura que build_world.gd, marcada hand_edited) y, si la región
## cambió, data/world/kanto.tres. Hace backup de la zona anterior (se quedan los últimos 5).
func save(path: String = "", save_region: bool = true) -> Error:
	commit("")
	if path == "":
		path = entry.scene_path
	if FileAccess.file_exists(path):
		backup_file(path)
	var root := ZoneBuilder.new_zone_root(entry.id, tileset)
	root.set("tree_cells", zone.tree_cells.duplicate())
	root.set("hand_edited", true)
	for ln in ZoneBuilder.LAYERS:
		(root.get_node(ln) as TileMapLayer).tile_map_data = (zone.get_node(ln) as TileMapLayer).tile_map_data
	for n in zone.get_node("Objects").get_children():
		ZoneBuilder.add_object(root, n.scene_file_path, ZoneBuilder.object_cell(n.position))
	var err := ZoneBuilder.save_zone(root, path)
	root.free()
	if err != OK:
		return err
	if path == entry.scene_path:
		ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)  # que el juego (mismo proceso) cargue la nueva
	if save_region and region_dirty:
		err = ResourceSaver.save(world, ZoneBuilder.WORLD_PATH)
		if err != OK:
			return err
		region_dirty = false
	_saved_version = undo.get_version()
	changed.emit()
	return OK


## Copia un archivo a <carpeta>/.backup/<nombre>_<fecha>.<ext> y se queda con los últimos BACKUPS_KEPT.
static func backup_file(path: String) -> void:
	var dir := path.get_base_dir() + "/.backup"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var id := path.get_file().get_basename()
	var stamp := Time.get_datetime_string_from_system(false, false).replace(":", "").replace("-", "").replace("T", "_")
	DirAccess.copy_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path("%s/%s_%s.%s" % [dir, id, stamp, path.get_extension()]))
	var mine: Array = Array(DirAccess.get_files_at(dir)).filter(func(f: String) -> bool:
		return f.begins_with(id + "_") and f.trim_prefix(id + "_").left(8).is_valid_int())
	mine.sort()
	while mine.size() > BACKUPS_KEPT:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(dir + "/" + mine.pop_front()))
