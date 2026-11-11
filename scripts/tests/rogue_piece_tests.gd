class_name RoguePieceTests
extends Node
## Autotest de las "Salas por piezas" del Modo Desafío (sección 10 de docs/PROPUESTA_ROGUELIKE.md, P-0: la Costa).
##   godot --headless --path . --fixed-fps 60 --quit-after 60000 -- --autotest-rogue-pieces

var world: Node


func run_tests() -> void:
	var r := {}
	var f := RogueRun.load_floor()
	var rooms: Array = f["biomes"]["costa"]["rooms"]
	var catalog := RoomPieces.load_catalog("costa")
	var missing: Array[String] = []
	for id: String in catalog:
		if not ResourceLoader.exists("res://sprites/rogue/piezas/costa/%s.png" % id):
			missing.append(id)
	var kinds := {}
	for d: Dictionary in catalog.values():
		kinds[d["kind"]] = int(kinds.get(d["kind"], 0)) + 1
	r["El catálogo de la Costa tiene %d piezas con su sprite (%s)%s" % [catalog.size(), kinds, "" if missing.is_empty() else " — falta: " + ", ".join(missing)]] = \
		catalog.size() >= 12 and missing.is_empty() and kinds.get("solida", 0) >= 8 and kinds.get("zona", 0) >= 2 and kinds.get("decorado", 0) >= 2
	r["La Costa usa 3 salas por piezas (%s)" % ", ".join(rooms)] = rooms.size() == 3 and rooms.all(func(id): return RoomPieces.has_room(id))

	RogueRun.begin(DB.species["squirtle"])
	GameState.rogue["biomes"] = ["costa", "bosque", "costa", "volcan", "costa"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	var run: RogueRun = world.rogue
	var total := 0
	var bad: Array[String] = []
	var native := true
	for i in run.chain.size():
		var id: String = run.chain_data[i].id
		if not RoomPieces.has_room(id):
			continue
		var zone: Zone = run.chain[i]
		var room := RoomPieces.load_room(id)
		total += room["pieces"].size()
		var tex: Texture2D = run.chain_data[i].painting
		var used: Rect2i = zone.ground.get_used_rect()
		var paint: Sprite2D = zone.get_node_or_null("Pintura")
		if tex.get_size() != Vector2(used.end * Zone.TILE) or paint == null or paint.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
			native = false
		# La grilla debajo: sólido bajo cada pieza sólida, agua bajo cada zona, y camino de la entrada a la salida.
		var grid := AStarGrid2D.new()
		grid.region = used
		grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		grid.update()
		for cell in zone.ground.get_used_cells():
			grid.set_point_solid(cell, MapRules.cell_physics(zone, cell) != -1)
		for p: Array in room["pieces"]:
			var def: Dictionary = catalog[p[0]]
			var cell := Vector2i(floori(float(p[1]) / Zone.TILE), floori(float(p[2]) / Zone.TILE))
			var phys := MapRules.cell_physics(zone, cell)
			if def["kind"] == "solida" and phys != MapRules.SOLID:
				bad.append("%s: %s en %s no marca la celda" % [id, p[0], cell])
			if def["kind"] == "zona" and phys != MapRules.WATER:
				bad.append("%s: %s en %s no es agua" % [id, p[0], cell])
			if def["kind"] == "decorado" and phys == MapRules.SOLID:
				bad.append("%s: %s (decorado) en %s tapa el paso" % [id, p[0], cell])
		var mid := used.end.x / 2
		if grid.get_id_path(Vector2i(mid, used.end.y - 1), Vector2i(mid, 0)).is_empty():
			bad.append("%s: sin camino de la entrada a la salida" % id)
		for cell in RogueRun.door_cells(zone, 2) + [run.chain_data[i].player_mon_cell, run.chain_data[i].player_cell, run.chain_data[i].foe_trainer_cell]:
			if MapRules.cell_physics(zone, cell) != -1:
				bad.append("%s: la celda %s (entrada o puerta) está tapada" % [id, cell])
	r["El fondo es pixel art 1 a 1 (1024×768 para 64×48 celdas, sin suavizar)"] = native
	r["Las %d piezas de las 3 salas están puestas, en el y-sort de las entidades" % total] = run.pieces.size() == total and total >= 60 \
		and run.pieces.all(func(n): return n.get_parent() == world.entities)
	r["La grilla sigue debajo: sólido bajo las sólidas, agua bajo los charcos, decorado libre, y hay camino%s" % (
		"" if bad.is_empty() else " — " + "; ".join(bad.slice(0, 6)))] = bad.is_empty()
	var solids := run.pieces.filter(func(n): return n is StaticBody2D)
	var shapes_ok: bool = solids.all(func(n): return n.collision_layer == RoomPieces.WORLD_LAYER \
		and n.get_children().any(func(c): return c is CollisionPolygon2D and c.polygon.size() >= 8) \
		and n.get_node("Sprite").texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	r["Las sólidas chocan con la forma de su base (una elipse), no con celdas enteras (%d)" % solids.size()] = solids.size() >= 30 and shapes_ok
	# Se pasa por detrás: el sprite sube desde los pies; parado justo arriba de la base no se choca y la pieza lo tapa.
	var palm: StaticBody2D = null
	for n in solids:
		if n.get_meta("piece") == "palmera":
			palm = n
			break
	var spr: Sprite2D = palm.get_node("Sprite")
	var me: Creature = world.companion
	me.global_position = palm.global_position + Vector2(0, -20)
	await get_tree().physics_frame
	await get_tree().physics_frame
	r["Se pasa por detrás de una palmera: el dibujo sube %d px desde los pies y, parado detrás, queda adelante tuyo en el y-sort" % int(-spr.position.y)] = \
		spr.position.y < -60.0 and me.global_position.y < palm.global_position.y and me.global_position.distance_to(palm.global_position + Vector2(0, -20)) < 3.0
	# Y de frente frena: caminando hacia la base no se la atraviesa.
	var rock: StaticBody2D = null
	for n in solids:
		if n.get_meta("piece") == "roca_percebes":
			rock = n
			break
	for e in run.foes:
		e.process_mode = Node.PROCESS_MODE_DISABLED
	me.global_position = rock.global_position + Vector2(0, 40)
	var t := 0.0
	while t < 1.5:
		me.velocity = Vector2(0, -90)
		me.move_and_slide()
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	r["Una roca frena: empujando contra ella te quedás del lado de acá (a %d px de su centro)" % int(me.global_position.y - rock.global_position.y)] = \
		me.global_position.y > rock.global_position.y + 4.0
	var count := run.pieces.size()
	run._unload_chain()
	await get_tree().process_frame
	await get_tree().process_frame
	r["Al descargar la cadena las piezas se van con ella"] = count > 0 and run.pieces.is_empty() \
		and world.entities.get_children().filter(func(n): return n.has_meta("piece")).is_empty()

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[piezas] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-pieces] -> ", "OK" if ok else "FALLO")
	GameState.rogue = {}
	get_tree().quit(0 if ok else 1)


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()
