class_name MapRules
extends RefCounted
## Reglas sobre las celdas de una zona con la colisión real del TileSet: qué es transitable, búsqueda de la
## celda libre más cercana y validaciones de una zona (las usan el editor de mapas y World al cargar).

## Capas de colisión del TileSet: 0 sólido ("mundo"), 1 agua.
const SOLID := 0
const WATER := 1


## Colisión de una celda: -1 nada, 0 sólido, 1 agua. Mira las capas de tiles y los objetos de la zona.
## `objects` (de objects_by_cell) es opcional: pasarlo ahorra recalcularlo en recorridos largos.
static func cell_physics(zone: Node, cell: Vector2i, objects = null) -> int:
	if objects == null:
		objects = objects_by_cell(zone)
	if objects.has(cell):
		return SOLID
	var out := -1
	for layer_name in ["Ground", "Water", "Foliage"]:
		var td: TileData = (zone.get_node(layer_name) as TileMapLayer).get_cell_tile_data(cell)
		if td == null:
			continue
		if td.get_collision_polygons_count(SOLID) > 0:
			return SOLID
		if td.get_collision_polygons_count(WATER) > 0:
			out = WATER
	return out


static func is_walkable(zone: Node, cell: Vector2i, objects = null) -> bool:
	return cell_physics(zone, cell, objects) < 0


## Objetos del entorno de la zona por celda.
static func objects_by_cell(zone: Node) -> Dictionary:
	var out := {}
	for n in zone.get_node("Objects").get_children():
		if n is Node2D and not n.is_queued_for_deletion():
			out[ZoneBuilder.object_cell(n.position)] = n
	return out


## Celda transitable más cercana (dentro de la zona) a una celda; la misma si ya lo es.
static func nearest_walkable(zone: Node, entry: ZoneEntry, cell: Vector2i, max_radius: int = 24) -> Vector2i:
	var objects := objects_by_cell(zone)
	if is_walkable(zone, cell, objects):
		return cell
	for r in range(1, max_radius + 1):
		var best := Vector2i(-1, -1)
		var best_d := INF
		for y in range(cell.y - r, cell.y + r + 1):
			for x in range(cell.x - r, cell.x + r + 1):
				if maxi(absi(x - cell.x), absi(y - cell.y)) != r:
					continue
				var c := Vector2i(x, y)
				if _inside(entry, c) and is_walkable(zone, c, objects):
					var d := Vector2(c - cell).length()
					if d < best_d:
						best_d = d
						best = c
		if best_d < INF:
			return best
	return cell


static func _inside(entry: ZoneEntry, c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < entry.size.x and c.y < entry.size.y


## ¿Se puede caminar entre dos celdas de la zona? (búsqueda en grilla, 4 direcciones)
static func has_path(zone: Node, entry: ZoneEntry, from: Vector2i, to: Vector2i, objects = null) -> bool:
	if objects == null:
		objects = objects_by_cell(zone)
	if not is_walkable(zone, from, objects) or not is_walkable(zone, to, objects):
		return false
	var seen := {from: true}
	var queue: Array[Vector2i] = [from]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		if c == to:
			return true
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if not seen.has(n) and _inside(entry, n) and is_walkable(zone, n, objects):
				seen[n] = true
				queue.append(n)
	return false


const OPPOSITE := {"up": "down", "down": "up", "left": "right", "right": "left"}
const SIDE_DIR := {"up": Vector2i(0, -1), "down": Vector2i(0, 1), "left": Vector2i(-1, 0), "right": Vector2i(1, 0)}


## Zona vecina de `entry` hacia un lado (la que toca ese borde), o null.
static func neighbor(world: WorldData, entry: ZoneEntry, side: String) -> ZoneEntry:
	var probe := Vector2(entry.origin * world.tile_size)
	var r := entry.world_rect(world.tile_size)
	match side:
		"up": probe = Vector2(r.get_center().x, r.position.y - 1)
		"down": probe = Vector2(r.get_center().x, r.end.y + 1)
		"left": probe = Vector2(r.position.x - 1, r.get_center().y)
		"right": probe = Vector2(r.end.x + 1, r.get_center().y)
	return world.zone_at(probe)


## Validaciones de una zona. Devuelve [{"level": "error"|"warn", "msg": String, "cell": Vector2i}].
## Los "error" rompen el juego (se bloquea el guardado); los "warn" son avisos.
static func validate(zone: Node, entry: ZoneEntry, world: WorldData) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var objects := objects_by_cell(zone)
	if entry.id.strip_edges() == "":
		out.append({"level": "error", "msg": "La zona no tiene id.", "cell": Vector2i(-1, -1)})
	for z in world.zones:
		if z == entry:
			continue
		if z.id == entry.id:
			out.append({"level": "error", "msg": "Hay otra zona con el id \"%s\"." % entry.id, "cell": Vector2i(-1, -1)})
		if z.world_rect(1).intersects(entry.world_rect(1)):
			out.append({"level": "error", "msg": "La zona se encima con %s." % z.display_name, "cell": Vector2i(-1, -1)})
	# Salidas: transitables, empalman con la vecina y conectadas con la plaza.
	for side in entry.exits:
		var ex: Vector2i = entry.exits[side]
		var blocked := false
		for d in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
			if not is_walkable(zone, ex + d, objects):
				blocked = true
		if blocked:
			out.append({"level": "warn", "msg": "La salida %s está bloqueada (sólido o agua)." % _side_name(side), "cell": ex})
		var other := neighbor(world, entry, side)
		if other == null:
			out.append({"level": "warn", "msg": "La salida %s no da a ninguna zona." % _side_name(side), "cell": ex})
		elif not other.exits.has(OPPOSITE[side]):
			out.append({"level": "warn", "msg": "%s no tiene salida hacia esta zona (lado %s)." % [other.display_name, _side_name(OPPOSITE[side])], "cell": ex})
		else:
			var mine := entry.origin + ex
			var theirs: Vector2i = other.origin + other.exits[OPPOSITE[side]]
			var aligned := mine.x == theirs.x if side in ["up", "down"] else mine.y == theirs.y
			if not aligned:
				out.append({"level": "warn", "msg": "La salida %s no empalma con la de %s." % [_side_name(side), other.display_name], "cell": ex})
		if not blocked and not has_path(zone, entry, entry.hub, ex, objects):
			out.append({"level": "warn", "msg": "No hay camino transitable entre la plaza y la salida %s." % _side_name(side), "cell": ex})
	if not is_walkable(zone, entry.hub, objects):
		out.append({"level": "warn", "msg": "La plaza (hub) está bloqueada.", "cell": entry.hub})
	# Inicio del juego
	var spawn_local := world.spawn_cell - entry.origin
	if _inside(entry, spawn_local) and not is_walkable(zone, spawn_local, objects):
		out.append({"level": "warn", "msg": "El inicio del juego (spawn_cell) cae en algo sólido o en el agua.", "cell": spawn_local})
	# Salvajes y tiles fuera de la zona
	var tall := false
	var outside := 0
	for layer_name in ZoneBuilder.LAYERS:
		var layer: TileMapLayer = zone.get_node(layer_name)
		for c in layer.get_used_cells():
			if not _inside(entry, c):
				outside += 1
			elif not tall and layer_name != "Overhead":
				var td := layer.get_cell_tile_data(c)
				tall = td != null and (td.get_custom_data("tags") as PackedStringArray).has("pasto_alto")
	if not tall:
		out.append({"level": "warn", "msg": "La zona no tiene pasto alto: no van a aparecer salvajes.", "cell": Vector2i(-1, -1)})
	if outside > 0:
		out.append({"level": "warn", "msg": "Hay %d tiles fuera del tamaño de la zona." % outside, "cell": Vector2i(-1, -1)})
	for c in objects:
		if not _inside(entry, c):
			out.append({"level": "warn", "msg": "Hay un objeto fuera de la zona.", "cell": c})
	return out


static func _side_name(side: String) -> String:
	return {"up": "de arriba", "down": "de abajo", "left": "de la izquierda", "right": "de la derecha"}.get(side, side)
