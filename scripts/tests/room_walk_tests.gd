class_name RoomWalkTests
extends Node
## Recorre caminando todo lo recorrible de un lugar (pedido del usuario 2026-11-03, para el Centro Online pintado): desde
## la plaza (`hub`) busca todas las celdas caminables según MapRules (sin las puertas, que te sacan) y el entrenador las
## pisa una por una con las teclas de verdad. Si a una no llega (una pared invisible, un mueble con más choque que el
## dibujo), FALLO. Además arma una imagen del lugar con la colisión encima (verde = se camina y se llegó, rojo = choca,
## amarillo = caminable pero no se llegó, azul = puerta), para ver si te frena el aire o pasás por arriba de un mueble.
##   godot --headless --path . --quit-after 200000 -- --autotest-room-walk [--zone centro_online] [--out <png>]
##   ... -- --autotest-room-walk --arena arena_gimnasio_roca   (una arena de combate: entra como en una pelea, sin rival,
##   desde donde se para el jugador; las rocas que se rompen cuentan como sólidas)
## Sin --out la imagen va a user://room_walk_<zona>.png. El fondo es la pintura del lugar si tiene (ExtraBuilding
## `walkable` del tamaño de la zona, o ArenaData.painting); si no, un gris.

const STEP_TIMEOUT := 1.2  # segundos de juego para pasar de una celda a la de al lado
const NEAR := 3.0  # px: llegó al centro de la celda
const ACTIONS := {Vector2i.LEFT: "move_left", Vector2i.RIGHT: "move_right", Vector2i.UP: "move_up", Vector2i.DOWN: "move_down"}

var autotest: Node
var world: Node


func run() -> void:
	var args := OS.get_cmdline_user_args()
	var zone_id := _arg(args, "--zone", "centro_online")
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	var data: WorldData = world.streamer.world_data
	var entry: ZoneEntry = null
	var zone: Node = null
	var painting: Texture2D = null
	var arena_id := _arg(args, "--arena", "")
	if arena_id != "":
		var ad: ArenaData = load("res://data/arenas/%s.tres" % arena_id)
		world.arena.arena_data = ad
		world.arena._enter_arena(null)
		world.arena.active = true  # (la luz y las nubes como en una pelea de verdad)
		world.day_night.apply()
		await get_tree().create_timer(0.5).timeout
		zone = world.arena.arena
		entry = ZoneEntry.new()  # la arena no es una zona de la región: una de mentira con su lugar y tamaño
		entry.id = arena_id
		entry.origin = Vector2i(TrainerBattle.ARENA_ORIGIN / float(data.tile_size))
		entry.size = (zone.get_node("Ground") as TileMapLayer).get_used_rect().end
		entry.hub = ad.player_cell
		painting = ad.painting
		zone_id = arena_id
	else:
		for z in data.zones:
			if z.id == zone_id:
				entry = z
		if entry == null:
			print("[autotest-room-walk] no existe la zona ", zone_id, " -> FALLO")
			get_tree().quit(1)
			return
		await world.story.teleport(zone_id, entry.hub)
		await get_tree().create_timer(0.5).timeout
		zone = world.streamer.zone_node(zone_id)
		for b in ExtraContent.buildings:
			if b.zone_id == entry.id and b.walkable and b.size == entry.size and b.texture != null:
				painting = b.texture
	var objects := MapRules.objects_by_cell(zone)
	var walk := func(c: Vector2i) -> bool:
		return Rect2i(Vector2i.ZERO, entry.size).has_point(c) and not entry.warps.has(c) and MapRules.is_walkable(zone, c, objects)
	var reachable := _flood(entry.hub, walk)
	var t: Trainer = world.trainer
	var ts := float(data.tile_size)
	var center := func(c: Vector2i) -> Vector2:
		return Vector2(entry.origin + c) * ts + Vector2.ONE * ts / 2.0
	Engine.time_scale = 2.0
	var reached := {entry.hub: true}
	var blocked := []
	var here := entry.hub
	for target: Vector2i in _dfs_order(entry.hub, reachable):
		if reached.has(target):
			continue
		var path := _path(here, target, reachable)
		for step: Vector2i in path:
			if await _step(t, here, step, center):
				reached[step] = true
				here = step
			else:
				blocked.append(step)
				t.global_position = center.call(here)  # no pudo: vuelve y sigue con la próxima
				break
	Engine.time_scale = 1.0
	var missing := reachable.keys().filter(func(c): return not reached.has(c))
	var out := _arg(args, "--out", "user://room_walk_%s.png" % zone_id)
	_draw(entry, zone, objects, reached, out, painting)
	print("[room-walk] %s: %d celdas caminables desde la plaza, pisadas %d" % [zone_id, reachable.size(), reached.size()])
	if not blocked.is_empty():
		print("[room-walk] no se pudo pasar a: ", blocked)
	print("[room-walk] imagen: ", ProjectSettings.globalize_path(out) if out.begins_with("user://") else out)
	var ok := missing.is_empty()
	print("[autotest-room-walk] -> %s" % ("OK" if ok else "FALLO (sin pisar %s)" % str(missing)))
	get_tree().quit(0 if ok else 1)


## Camina de `from` a la celda de al lado `to` con la tecla de esa dirección (y corrige el desvío de costado).
func _step(t: Trainer, from: Vector2i, to: Vector2i, center: Callable) -> bool:
	var dir := to - from
	var goal: Vector2 = center.call(to)
	var time := 0.0
	var ok := false
	while time < STEP_TIMEOUT:
		var off := goal - t.global_position
		var along := off.dot(Vector2(dir))
		var side := off - Vector2(dir) * along
		if along <= NEAR and side.length() <= NEAR:
			ok = true
			break
		_press(ACTIONS[dir], along > NEAR)
		for d: Vector2i in [Vector2i(dir.y, dir.x), -Vector2i(dir.y, dir.x)]:
			_press(ACTIONS[d], side.dot(Vector2(d)) > NEAR)
		await get_tree().physics_frame
		time += get_physics_process_delta_time() * Engine.time_scale
	for a: String in ACTIONS.values():
		Input.action_release(a)
	if ok:
		t.global_position = goal
	return ok


func _press(action: String, on: bool) -> void:
	if on:
		Input.action_press(action)
	else:
		Input.action_release(action)


func _flood(from: Vector2i, walk: Callable) -> Dictionary:
	var seen := {from: true}
	var queue: Array[Vector2i] = [from]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		for d: Vector2i in ACTIONS:
			var n: Vector2i = c + d
			if not seen.has(n) and walk.call(n):
				seen[n] = true
				queue.append(n)
	return seen


## Orden de visita en profundidad (así el recorrido no salta de punta a punta).
func _dfs_order(from: Vector2i, cells: Dictionary) -> Array[Vector2i]:
	var order: Array[Vector2i] = []
	var seen := {}
	var stack: Array[Vector2i] = [from]
	while not stack.is_empty():
		var c: Vector2i = stack.pop_back()
		if seen.has(c):
			continue
		seen[c] = true
		order.append(c)
		for d: Vector2i in ACTIONS:
			if cells.has(c + d) and not seen.has(c + d):
				stack.append(c + d)
	return order


## Camino más corto por celdas (sin la de partida).
func _path(from: Vector2i, to: Vector2i, cells: Dictionary) -> Array[Vector2i]:
	var prev := {from: from}
	var queue: Array[Vector2i] = [from]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		if c == to:
			break
		for d: Vector2i in ACTIONS:
			var n: Vector2i = c + d
			if cells.has(n) and not prev.has(n):
				prev[n] = c
				queue.append(n)
	var out: Array[Vector2i] = []
	var c := to
	while c != from and prev.has(c):
		out.push_front(c)
		c = prev[c]
	return out


func _draw(entry: ZoneEntry, zone: Node, objects, reached: Dictionary, out: String, painting: Texture2D) -> void:
	var img: Image = null
	if painting != null:
		img = Image.load_from_file(ProjectSettings.globalize_path(painting.resource_path))
	if img == null:
		img = Image.create_empty(entry.size.x * 48, entry.size.y * 48, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.3, 0.3, 0.3))
	img.convert(Image.FORMAT_RGBA8)
	var kx := float(img.get_width()) / entry.size.x  # (con decimales: una arena agrandada no da justo)
	var ky := float(img.get_height()) / entry.size.y
	for y in entry.size.y:
		for x in entry.size.x:
			var c := Vector2i(x, y)
			var col: Color
			if entry.warps.has(c):
				col = Color(0.2, 0.4, 1.0, 0.45)
			elif not MapRules.is_walkable(zone, c, objects):
				col = Color(1.0, 0.1, 0.1, 0.35)
			elif reached.has(c):
				col = Color(0.1, 1.0, 0.2, 0.3)
			else:
				col = Color(1.0, 0.9, 0.0, 0.6)
			for py in range(int(y * ky), int((y + 1) * ky)):
				for px in range(int(x * kx), int((x + 1) * kx)):
					var edge := px == int(x * kx) or py == int(y * ky)
					img.set_pixel(px, py, img.get_pixel(px, py).blend(Color(0, 0, 0, 0.5) if edge else col))
	if out.begins_with("user://"):
		img.save_png(out)
	else:
		img.save_png(ProjectSettings.globalize_path(out) if out.begins_with("res://") else out)


func _arg(args: PackedStringArray, name: String, default: String) -> String:
	var i := args.find(name)
	return args[i + 1] if i >= 0 and i + 1 < args.size() else default
