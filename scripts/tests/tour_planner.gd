class_name TourPlanner
extends RefCounted
## Planifica caminatas por el mundo para los autotests: qué celdas son transitables (con la colisión real de cada
## zona), el camino más corto entre dos celdas (BFS por celdas del mundo, cruzando zonas) y por qué puertas pasar.

var world: WorldData
var _walk := {}   # id de zona -> PackedByteArray (1 = transitable), en celdas locales
var _by_id := {}
var _ledges := {}  # celda del mundo -> dirección del salto (salientes de FireRed)


## `cut`: los árboles cortables (EnvObject "cortable") cuentan como transitables (como si tuvieras Corte); `surf`: el
## agua también (Surf); `strength`: las rocas pesadas también (Fuerza: en FireRed se empujan). `people` = false: las
## personas de la historia no tapan (para medir solo el mapa: el Snorlax o los guardias se sacan jugando).
func _init(p_world: WorldData, cut: bool = false, surf: bool = false, strength: bool = false, people: bool = true) -> void:
	world = p_world
	for z in world.zones:
		_by_id[z.id] = z
		var node: Node = load(z.scene_path).instantiate()
		var objects := MapRules.objects_by_cell(node)
		if cut:
			for c in objects.keys():
				if (objects[c] as EnvObject).has_tag("cortable"):
					objects.erase(c)
		if strength:
			for c in objects.keys():
				if (objects[c] as EnvObject).has_tag("pesado"):
					objects.erase(c)
		var bits := PackedByteArray()
		bits.resize(z.size.x * z.size.y)
		for y in z.size.y:
			for x in z.size.x:
				var phys := MapRules.cell_physics(node, Vector2i(x, y), objects)
				bits[y * z.size.x + x] = 1 if phys < 0 or (surf and phys == MapRules.WATER) else 0
		for npc: NpcData in DB.npcs.values():  # las personas de la historia también ocupan su celda
			if people and npc.zone_id == z.id and npc.visible_now() and Rect2i(Vector2i.ZERO, z.size).has_point(npc.cell):
				bits[npc.cell.y * z.size.x + npc.cell.x] = 0
		for b in ExtraContent.buildings:  # los edificios agregados (Centros Online, globos) también son sólidos
			if b.zone_id == z.id:
				for c in b.cells():
					if Rect2i(Vector2i.ZERO, z.size).has_point(c):
						bits[c.y * z.size.x + c.x] = 0
		_walk[z.id] = bits
		for c in (node.get_node("Ground") as TileMapLayer).get_used_cells():
			var d := LedgeJumper.direction_at(node, c)
			if d != Vector2i.ZERO:
				_ledges[z.origin + c] = d
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


## Si desde `c` caminando hacia `d` se salta un saliente: la celda donde se cae (si no, Vector2i(-99999, -99999)).
func jump(c: Vector2i, d: Vector2i) -> Vector2i:
	var n := c + d
	if _ledges.get(n, Vector2i.ZERO) != d:
		return Vector2i(-99999, -99999)
	var land := n + d
	for i in LedgeJumper.MAX_CHAIN:  # salientes seguidos se saltan juntos (como LedgeJumper)
		if _ledges.get(land, Vector2i.ZERO) != d:
			break
		land += d
	return land if walkable(land) else Vector2i(-99999, -99999)


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


## Recorrido completo de `from` hasta la plaza de la zona `zone_id`, usando puertas y salientes si hace falta:
## [[celda, zona a la que se llega ("" = caminar hasta la celda)], ...] (vacío si no hay). Tras una puerta sigue
## desde la celda de llegada.
func route(from: Vector2i, zone_id: String) -> Array:
	var goal: Vector2i = _by_id[zone_id].origin + _by_id[zone_id].hub
	var prev := {from: [from, ""]}  # celda -> [anterior, puerta usada ("" = caminando o saltando)]
	var queue: Array[Vector2i] = [from]
	var i := 0
	var dirs: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	while i < queue.size() and not prev.has(goal):
		var c := queue[i]
		i += 1
		for d in dirs:
			var n := c + d
			var to := n
			var via := ""
			if is_warp(n):
				to = arrival(n)
				via = str(n.x) + "," + str(n.y)
			elif not walkable(n):
				to = jump(c, d)
				if to.x == -99999:
					continue
			if prev.has(to):
				continue
			prev[to] = [c, via]
			queue.append(to)
	if not prev.has(goal):
		return []
	var cells: Array = []  # de atrás para adelante
	var c := goal
	while c != from:
		cells.push_front([c, prev[c][1]])
		c = prev[c][0]
	var out: Array = []
	var walk: Array[Vector2i] = [from]
	for step in cells:
		if step[1] == "":
			walk.append(step[0])
			continue
		for k in corners(walk):
			out.append([k, ""])
		var w: PackedStringArray = (step[1] as String).split(",")
		var door := Vector2i(int(w[0]), int(w[1]))
		var dest := world.zone_at(Vector2(step[0] * world.tile_size) + Vector2.ONE)
		out.append([door, dest.id])
		walk = [step[0]]
	for k in corners(walk):
		out.append([k, ""])
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
