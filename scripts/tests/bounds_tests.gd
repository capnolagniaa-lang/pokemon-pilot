class_name BoundsTests
extends Node
## Autotest de los límites del mundo (godot --headless --path . --quit-after 20000 -- --autotest-bounds): desde el
## inicio, recorriendo todo lo transitable y usando las puertas, en cada celda alcanzable que da al vacío (fuera de
## toda zona) hay una pared (ZoneBounds) y caminando contra ella no se sale; y no se llega a Ciudad Plateada sin
## cruzar el Bosque Verde (como en FireRed: el camino del este necesita Corte).

var autotest: Node


func run() -> void:
	var r := {}
	var world: WorldData = DB.config.world
	var plan := TourPlanner.new(world)
	var with_warps := _reach(plan, world, true)
	var void_edges := {}
	for c: Vector2i in with_warps:
		for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			if world.zone_at(Vector2((c + d) * world.tile_size) + Vector2.ONE) == null:
				var z := world.zone_at(Vector2(c * world.tile_size) + Vector2.ONE)
				void_edges.get_or_add(z.id, []).append([c - z.origin, d])
	# Cada una tiene su pared.
	var uncovered := []
	for id in void_edges:
		var e: ZoneEntry = plan.entry(id)
		var runs := ZoneBounds.open_runs(world, e)
		for it in void_edges[id]:
			var cell: Vector2i = it[0]
			var d: Vector2i = it[1]
			if not ZoneBounds.covers(runs, cell, d):
				uncovered.append("%s %s" % [id, cell])
	r["Toda celda alcanzable que da al vacío tiene pared"] = uncovered.is_empty()
	if not uncovered.is_empty():
		print("[limites] sin pared: ", uncovered.slice(0, 10))
	# Caminando contra la pared no se sale (en el juego de verdad, una celda por zona).
	var escaped := await _walk_out(void_edges)
	print("[limites] zonas con bordes al vacío probadas: %d; se salió en: %s" % [void_edges.size(), escaped])
	r["Caminando hacia el vacío no se sale de la zona"] = escaped.is_empty() and not void_edges.is_empty()
	var by_zone := {}
	for c: Vector2i in with_warps:
		by_zone[world.zone_at(Vector2(c * world.tile_size) + Vector2.ONE).id] = true
	var missing := world.zones.filter(func(z: ZoneEntry) -> bool: return not by_zone.has(z.id)).map(func(z: ZoneEntry) -> String: return z.id)
	print("[limites] zonas a las que no se llega: ", missing)
	if OS.has_environment("BOUNDS_DEBUG"):
		var e4 := plan.entry(OS.get_environment("BOUNDS_DEBUG"))
		var rows := []
		for y in e4.size.y:
			var line := ""
			for x in e4.size.x:
				var c := e4.origin + Vector2i(x, y)
				line += "o" if with_warps.has(c) else ("." if plan.walkable(c) else ("W" if plan.is_warp(c) else ("v" if plan._ledges.has(c) else "#")))
			rows.append(line)
		print("
".join(rows))
	r["Se llega a Ciudad Plateada"] = by_zone.has("ciudad_plateada")
	var key_places := ["laboratorio_oak", "ciudad_verde_centro", "ciudad_verde_tienda", "ciudad_verde_gimnasio",
		"ciudad_plateada_centro", "ciudad_plateada_tienda", "ciudad_plateada_gimnasio", "ciudad_plateada_torneo", "museo",
		"ruta4_centro", "mt_moon_s2", "ciudad_celeste_centro", "ciudad_celeste_tienda", "ciudad_celeste_gimnasio", "casa_bill",
		"ruta5_guarderia", "via_subterranea", "ruta6", "ciudad_carmin_centro", "ciudad_carmin_tienda", "club_fans",
		"ss_anne_capitan", "ss_anne_cubierta"]
	r["Se llega a los Centros, Tiendas, gimnasios, Museo, Torneo, Mt. Moon, Casa de Bill, Vía Subterránea y S.S. Anne"] = key_places.all(func(id: String) -> bool: return by_zone.has(id))
	var no_forest := _reach(plan, world, true, ["bosque_verde"])
	var skip := false
	for c: Vector2i in no_forest:
		var z := world.zone_at(Vector2(c * world.tile_size) + Vector2.ONE)
		skip = skip or (z != null and z.id == "ciudad_plateada")
	r["Sin cruzar el Bosque Verde no se llega a Ciudad Plateada"] = not skip
	var no_moon := _reach(plan, world, true, ["mt_moon", "mt_moon_s1", "mt_moon_s2"])
	var skip_moon := false
	for c: Vector2i in no_moon:
		var z := world.zone_at(Vector2(c * world.tile_size) + Vector2.ONE)
		skip_moon = skip_moon or (z != null and z.id == "ciudad_celeste")
	r["Sin cruzar el Mt. Moon no se llega a Ciudad Celeste"] = not skip_moon
	# Gimnasio de Carmín: detrás de un árbol cortable, como en FireRed (Corte te lo dan en el S.S. Anne).
	r["Sin Corte no se llega al Gimnasio de Carmín"] = not by_zone.has("ciudad_carmin_gimnasio")
	var with_cut := _reach(TourPlanner.new(world, true), world, true)
	var cut_zones := {}
	for c: Vector2i in with_cut:
		cut_zones[world.zone_at(Vector2(c * world.tile_size) + Vector2.ONE).id] = true
	r["Con Corte se llega al Gimnasio de Carmín"] = cut_zones.has("ciudad_carmin_gimnasio")
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[limites] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-bounds] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Para cada zona, pone al entrenador en una celda que da al vacío y lo hace caminar hacia afuera. Devuelve las zonas
## de las que se salió.
func _walk_out(void_edges: Dictionary) -> Array:
	GameState.new_game(DB.config.starters[0])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	for i in 3:
		await get_tree().process_frame
	var world: Node = get_tree().current_scene
	var data: WorldData = world.streamer.world_data
	var t: Trainer = world.trainer
	var out := []
	for id in void_edges:
		var e: ZoneEntry = null
		for z in data.zones:
			if z.id == id:
				e = z
		var it: Array = void_edges[id][0]
		var pos := Vector2((e.origin + it[0]) * data.tile_size) + Vector2.ONE * data.tile_size / 2.0
		world.streamer.load_around_now(pos)
		t.global_position = pos
		t.trail.assign([pos])
		world.camera.snap()
		await get_tree().physics_frame
		t.autopilot = Vector2(it[1])
		await get_tree().create_timer(0.6).timeout
		t.autopilot = Vector2.ZERO
		if not e.world_rect(data.tile_size).has_point(t.global_position):
			out.append(id)
	return out


## Celdas del mundo alcanzables desde el inicio (caminando y, si `warps`, usando puertas). `avoid`: zonas prohibidas.
func _reach(plan: TourPlanner, world: WorldData, warps: bool, avoid: Array = []) -> Dictionary:
	var seen := {world.spawn_cell: true}
	var queue: Array[Vector2i] = [world.spawn_cell]
	var i := 0
	while i < queue.size():
		var c := queue[i]
		i += 1
		var next: Array[Vector2i] = []
		if warps and plan.is_warp(c):
			next.append(plan.arrival(c))
		for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var n: Vector2i = c + d
			if plan.walkable(n):
				next.append(n)
			elif warps and plan.is_warp(n):  # puerta sólida: se usa caminando contra ella
				next.append(plan.arrival(n))
			else:
				var j := plan.jump(c, d)  # saliente: se baja saltando
				if j.x != -99999:
					next.append(j)
		for n in next:
			if seen.has(n):
				continue
			var z := world.zone_at(Vector2(n * world.tile_size) + Vector2.ONE)
			if z == null or z.id in avoid:
				continue
			seen[n] = true
			queue.append(n)
	return seen
