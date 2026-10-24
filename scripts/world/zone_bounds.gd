class_name ZoneBounds
extends RefCounted
## Paredes invisibles en los bordes de una zona que dan al vacío (afuera de toda zona): así no se puede salir a una
## parte no dibujada del mundo. Donde la zona empalma con otra, el borde queda abierto. En FireRed el "afuera" de un
## mapa es una pared; acá hace falta porque muchos interiores tienen piso hasta el borde y algunos caminos llevaban
## a mapas que no están (Ruta 3, Calle Victoria...). World las agrega a cada zona al cargarla.

const THICKNESS := 8.0


## Tramos del borde que dan al vacío: [lado (Vector2i hacia afuera), primera celda, cantidad de celdas].
static func open_runs(world: WorldData, entry: ZoneEntry) -> Array:
	var out := []
	var ts := world.tile_size
	for side in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var horizontal: bool = side.y != 0
		var n := entry.size.x if horizontal else entry.size.y
		var start := -1
		for i in n + 1:
			var open := false
			if i < n:
				var cell: Vector2i = Vector2i(i, 0 if side == Vector2i.UP else entry.size.y - 1) if horizontal \
					else Vector2i(0 if side == Vector2i.LEFT else entry.size.x - 1, i)
				var outside: Vector2i = entry.origin + cell + side
				open = world.zone_at(Vector2(outside * ts) + Vector2.ONE * ts / 2.0) == null
			if open and start < 0:
				start = i
			elif not open and start >= 0:
				out.append([side, start, i - start])
				start = -1
	return out


## ¿La celda del borde (local) que da al vacío por el lado `side` tiene pared?
static func covers(runs: Array, cell: Vector2i, side: Vector2i) -> bool:
	var i := cell.x if side.y != 0 else cell.y
	for run in runs:
		if run[0] == side and i >= run[1] and i < run[1] + run[2]:
			return true
	return false


## Agrega a la zona (nodo) un StaticBody2D "Bounds" con una pared por cada tramo abierto al vacío.
static func attach(zone: Node2D, entry: ZoneEntry, world: WorldData) -> StaticBody2D:
	var old := zone.get_node_or_null("Bounds")
	if old != null:
		old.free()
	var body := StaticBody2D.new()
	body.name = "Bounds"
	body.collision_layer = 1  # capa "mundo": la chocan el entrenador y las criaturas
	body.collision_mask = 0
	var ts := float(world.tile_size)
	var size := Vector2(entry.size) * ts
	for run in open_runs(world, entry):
		var side: Vector2i = run[0]
		var a := float(run[1]) * ts
		var len := float(run[2]) * ts
		var rect: Rect2
		match side:
			Vector2i.UP:
				rect = Rect2(a, -THICKNESS, len, THICKNESS)
			Vector2i.DOWN:
				rect = Rect2(a, size.y, len, THICKNESS)
			Vector2i.LEFT:
				rect = Rect2(-THICKNESS, a, THICKNESS, len)
			_:
				rect = Rect2(size.x, a, THICKNESS, len)
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		var cs := CollisionShape2D.new()
		cs.shape = shape
		cs.position = rect.get_center()
		body.add_child(cs)
	zone.add_child(body)
	return body
