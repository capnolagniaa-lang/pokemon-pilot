class_name TourPlanner
extends RefCounted
## Planifica caminatas por el mundo para los autotests: qué celdas son transitables (con la colisión real de cada
## zona), el camino más corto entre dos celdas (BFS por celdas del mundo, cruzando zonas) y por qué puertas pasar.

var world: WorldData
var _walk := {}   # id de zona -> PackedByteArray (1 = transitable), en celdas locales
var _by_id := {}


func _init(p_world: WorldData) -> void:
	world = p_world
	for z in world.zones:
		_by_id[z.id] = z
		var node: Node = load(z.scene_path).instantiate()
		var objects := MapRules.objects_by_cell(node)
		var bits := PackedByteArray()
		bits.resize(z.size.x * z.size.y)
		for y in z.size.y:
			for x in z.size.x:
				bits[y * z.size.x + x] = 1 if MapRules.is_walkable(node, Vector2i(x, y), objects) else 0
		_walk[z.id] = bits
		node.free()


func entry(id: String) -> ZoneEntry:
	return _by_id.get(id)


## ¿La celda del mundo es transitable? (fuera de toda zona: no)
func walkable(cell: Vector2i) -> bool:
	var z := world.zone_at(Vector2(cell * world.tile_size) + Vector2.ONE)
	if z == null:
		return false
	var l := cell - z.origin
	return _walk[z.id][l.y * z.size.x + l.x] == 1


func is_warp(cell: Vector2i) -> bool:
	var z := world.zone_at(Vector2(cell * world.tile_size) + Vector2.ONE)
	return z != null and z.warps.has(cell - z.origin)


## Camino de celdas del mundo de `from` a `to` (sin pisar puertas salvo `to`); vacío si no hay.
func path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var prev := {from: from}
	var queue: Array[Vector2i] = [from]
	var i := 0
	var dirs: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	while i < queue.size():
		var c := queue[i]
		i += 1
		if c == to:
			break
		for d in dirs:
			var n := c + d
			if prev.has(n):
				continue
			if n != to and (not walkable(n) or is_warp(n)):
				continue
			prev[n] = c
			queue.append(n)
	if not prev.has(to):
		return []
	var out: Array[Vector2i] = [to]
	while out[0] != from:
		out.push_front(prev[out[0]])
	return out


## Puertas (celdas del mundo) de la zona `from_id` que llevan a `to_id`.
func warps_to(from_id: String, to_id: String) -> Array[Vector2i]:
	var z: ZoneEntry = _by_id[from_id]
	var out: Array[Vector2i] = []
	for c in z.warps:
		if z.warps[c]["to"] == to_id:
			out.append(z.origin + c)
	return out


## Celda del mundo donde se aparece al usar la puerta `warp_cell` (celda del mundo).
func arrival(warp_cell: Vector2i) -> Vector2i:
	var z := world.zone_at(Vector2(warp_cell * world.tile_size) + Vector2.ONE)
	var w: Dictionary = z.warps[warp_cell - z.origin]
	var dest: ZoneEntry = _by_id[w["to"]]
	var bits: PackedByteArray = _walk[dest.id]
	var found := WarpSystem.arrival(func(c: Vector2i) -> bool: return bits[c.y * dest.size.x + c.x] == 1, dest, w["cell"])
	return dest.origin + found[0]


## Celda transitable desde la que se usa una puerta: la puerta misma si se pisa, o la de al lado si es sólida.
func approach(warp_cell: Vector2i) -> Vector2i:
	if walkable(warp_cell):
		return warp_cell
	for d in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		if walkable(warp_cell + d) and not is_warp(warp_cell + d):
			return warp_cell + d
	return warp_cell


## Solo las celdas donde el camino dobla (para que el piloto automático vaya en línea recta entre ellas).
static func corners(p: Array[Vector2i]) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for i in p.size():
		if i == 0 or i == p.size() - 1 or (p[i] - p[i - 1]) != (p[i + 1] - p[i]):
			out.append(p[i])
	return out
