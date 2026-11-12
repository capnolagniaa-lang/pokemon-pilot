class_name RoguePieceTests
extends Node
## Autotest de las "Salas por piezas" del Modo Desafío (sección 10 de docs/PROPUESTA_ROGUELIKE.md): cada bioma ya
## convertido (todas sus salas tienen lista de piezas) se revisa entero.
##   godot --headless --path . --fixed-fps 60 --quit-after 200000 -- --autotest-rogue-pieces [--biome <bioma>]

var world: Node
var r := {}


func run_tests() -> void:
	var f := RogueRun.load_floor()
	var args := OS.get_cmdline_user_args()
	var only: String = args[args.find("--biome") + 1] if args.has("--biome") and args.find("--biome") + 1 < args.size() else ""
	var done: Array[String] = []
	for biome: String in f["biomes"]:
		var rooms: Array = f["biomes"][biome]["rooms"]
		if rooms.all(func(id): return RoomPieces.has_room(id)) and (only == "" or only == biome):
			await _check_biome(f, biome)
			done.append(biome)
	r["Biomas por piezas revisados: %s" % ", ".join(done)] = done.has("costa") or only != ""
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[piezas] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-pieces] -> ", "OK" if ok else "FALLO")
	GameState.rogue = {}
	get_tree().quit(0 if ok else 1)


func _check_biome(f: Dictionary, biome: String) -> void:
	var tag := "[%s] " % biome
	var rooms: Array = f["biomes"][biome]["rooms"]
	var catalog := RoomPieces.load_catalog(biome)
	var missing: Array[String] = []
	for id: String in catalog:
		if not ResourceLoader.exists("res://sprites/rogue/piezas/%s/%s.png" % [biome, id]):
			missing.append(id)
	var kinds := {}
	for d: Dictionary in catalog.values():
		kinds[d["kind"]] = int(kinds.get(d["kind"], 0)) + 1
	r[tag + "El catálogo tiene %d piezas con su sprite (%s)%s" % [catalog.size(), kinds, "" if missing.is_empty() else " — falta: " + ", ".join(missing)]] = \
		catalog.size() >= 12 and missing.is_empty() and kinds.get("solida", 0) >= 8 and kinds.get("decorado", 0) >= 2
	r[tag + "Usa %d salas por piezas (%s)" % [rooms.size(), ", ".join(rooms)]] = rooms.size() >= 6

	var other := ""
	for b: String in f["biomes"]:
		if b != biome:
			other = b
			break
	RogueRun.begin(DB.species["squirtle"])
	GameState.rogue["biomes"] = [biome, other, biome, other, biome]
	var before := world
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world != before and world.get("rogue") != null and world.rogue.phase == "oleada", 25.0)
	var run: RogueRun = world.rogue
	for e in run.foes:
		e.process_mode = Node.PROCESS_MODE_DISABLED
	var total := 0
	var seen_rooms := 0
	var bad: Array[String] = []
	var native := true
	var scenes_ok := true
	for i in run.chain.size():
		var id: String = run.chain_data[i].id
		if not RoomPieces.has_room(id) or not rooms.has(id):
			continue
		seen_rooms += 1
		var zone: Zone = run.chain[i]
		var room := RoomPieces.load_room(id)
		total += room["pieces"].size()
		if room.get("scenes", []).size() < 2:
			scenes_ok = false
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
		if run.spawn_cells().size() < 40 and i == 0:
			bad.append("%s: poco lugar para las oleadas" % id)
	r[tag + "El fondo es pixel art 1 a 1 (sin suavizar)"] = native and seen_rooms == 3
	r[tag + "Las %d piezas de sus 3 salas están puestas, en el y-sort de las entidades" % total] = total >= 80 \
		and run.pieces.filter(func(n): return n.get_parent() == world.entities).size() >= total
	r[tag + "Cada sala está armada con escenas (2 o más; menos en las que tienen poco piso)"] = scenes_ok
	r[tag + "La grilla sigue debajo (sólido, agua, decorado libre), hay camino, entrada y puertas libres%s" % (
		"" if bad.is_empty() else " — " + "; ".join(bad.slice(0, 6)))] = bad.is_empty()
	var solids := run.pieces.filter(func(n): return n is StaticBody2D)
	var shapes_ok: bool = solids.all(func(n): return n.collision_layer == RoomPieces.WORLD_LAYER \
		and n.get_children().any(func(c): return c is CollisionPolygon2D and c.polygon.size() >= 8) \
		and n.get_node("Sprite").texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	r[tag + "Las sólidas chocan con la forma de su base (%d)" % solids.size()] = solids.size() >= 20 and shapes_ok
	# Se pasa por detrás de la más alta: su dibujo sube desde los pies; parado detrás no se choca.
	var tall: StaticBody2D = null
	var wide: StaticBody2D = null
	for n: StaticBody2D in solids:
		if not catalog.has(n.get_meta("piece")):
			continue  # (pieza de una sala de otro bioma de la cadena)
		var spr: Sprite2D = n.get_node("Sprite")
		var base: Array = catalog[n.get_meta("piece")]["base"]
		if float(base[0]) <= 24.0 and (tall == null or spr.position.y < tall.get_node("Sprite").position.y):
			tall = n
		if float(base[0]) >= 30.0 and wide == null:
			wide = n
	var me: Creature = world.companion
	var rise: float = -tall.get_node("Sprite").position.y
	me.global_position = tall.global_position + Vector2(0, -20)
	await get_tree().physics_frame
	await get_tree().physics_frame
	r[tag + "Se pasa por detrás de %s (sube %d px desde los pies)" % [tall.get_meta("piece"), int(rise)]] = rise > 36.0 \
		and me.global_position.distance_to(tall.global_position + Vector2(0, -20)) < 4.0
	me.global_position = wide.global_position + Vector2(0, 44)
	var t := 0.0
	while t < 1.5:
		me.velocity = Vector2(0, -90)
		me.move_and_slide()
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	r[tag + "%s frena: empujando contra su base no se la atraviesa" % wide.get_meta("piece")] = me.global_position.y > wide.global_position.y + 3.0
	var count := run.pieces.size()
	run._unload_chain()
	await get_tree().process_frame
	await get_tree().process_frame
	r[tag + "Al descargar la cadena las piezas se van con ella"] = count > 0 and run.pieces.is_empty() \
		and world.entities.get_children().filter(func(n): return n.has_meta("piece")).is_empty()
	GameState.rogue = {}


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()
