class_name WaterWildTests
extends Node
## Salvajes de agua (salen solo navegando): zona por zona, llegás como un jugador (salen los de tierra), te subís a navegar
## y pasa el tiempo. Cuenta cuántos del agua aparecen y a qué distancia tuya.
##   godot --headless --path . --quit-after 400000 -- --autotest-water-wilds [--only zona_safari]

## Segundos navegando que se simulan en cada zona, y lo que se ve en pantalla alrededor tuyo (vista de 640×360).
const SURF_SECONDS := 30
const ON_SCREEN := 320.0

var autotest: Node
var r := {}


func run() -> void:
	GameState.new_game(DB.species["squirtle"])
	GameState.party[0].level = 30
	GameState.wilds_enabled = true
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world: Node = get_tree().current_scene
	await get_tree().create_timer(0.3).timeout
	var args := OS.get_cmdline_user_args()
	var only: String = args[args.find("--only") + 1] if "--only" in args else ""
	var fm: FieldMoves = world.field_moves
	var sp: WildSpawner = world.spawner
	var data: WorldData = world.streamer.world_data
	var total := 0
	var with_swimmers := 0
	var with_visible := 0
	var walked_clean := true
	var land_grew := ""
	for z: ZoneEntry in data.zones:
		if only != "" and z.id != only:
			continue
		var path := EncounterTable.zone_path(z.id)
		if not ResourceLoader.exists(path):
			continue
		var table: EncounterTable = load(path)
		if not table.entries.any(func(e): return e.where == "agua"):
			continue
		var center := Vector2((z.origin + z.size / 2) * data.tile_size)
		world.trainer.global_position = center
		world.camera.global_position = center  # (el streamer sigue a la cámara)
		world.streamer.load_around_now(center)
		await get_tree().process_frame
		var zone: Zone = world.streamer.zone_node(z.id)
		if zone == null:
			print("[agua] %-22s no cargó" % z.id)
			continue
		var cells: Array = sp.cells_for(z.id, zone, PackedStringArray(["agua"]))["agua"]
		if cells.is_empty():
			print("[agua] %-22s tabla con agua pero 0 celdas de agua" % z.id)
			continue
		total += 1
		var cell: Vector2i = cells[cells.size() / 2]
		var at: Vector2 = zone.to_global(zone.ground.map_to_local(cell))
		var land: int = sp._alive.get(z.id, []).filter(func(c): return is_instance_valid(c)).size()
		world.trainer.global_position = at
		world.camera.global_position = at
		world.streamer.current = z
		await get_tree().process_frame
		for list in sp._alive.values():  # (los que quedaron de la zona de al lado)
			for c in list:
				if is_instance_valid(c) and c.swims:
					c.free()
		if fm.surfing:  # (parado en el agua sin navegar, FieldMoves te sube solo: acá no pasan cuadros)
			fm.stop_surf()
		sp._process(0.0)
		for i in SURF_SECONDS:
			sp._process(1.0)
		for c in sp._alive.get(z.id, []):
			if is_instance_valid(c) and c.swims:
				walked_clean = false
				print("[agua] sin navegar: %s en %s, navegando=%s" % [c.instance.species.id, z.id, fm.surfing])
		fm.start_surf(at)
		# Navegando, en tiempo de juego de verdad (acelerado).
		Engine.time_scale = 12.0
		await get_tree().create_timer(SURF_SECONDS).timeout
		Engine.time_scale = 1.0
		world.trainer.global_position = at
		var land_after: int = sp._alive.get(z.id, []).filter(func(c): return is_instance_valid(c) and not c.swims).size()
		if land_after > sp.max_alive(z.id):
			land_grew = "%s: %d de %d" % [z.id, land_after, sp.max_alive(z.id)]
		var swimmers := 0
		var near := INF
		var seen := 0
		var all_wilds: Array = []
		for list in sp._alive.values():  # (lo que ves: puede estar anotado en la zona de al lado)
			all_wilds.append_array(list)
		for c in all_wilds:
			if is_instance_valid(c) and c.swims:
				swimmers += 1
				var d: float = c.global_position.distance_to(at)
				near = minf(near, d)
				if d <= ON_SCREEN:
					seen += 1
		var alive: int = sp._alive.get(z.id, []).filter(func(c): return is_instance_valid(c)).size()
		print("[agua] %-22s agua %5d celdas | de tierra al llegar %2d | máximo %2d | a los %d s: vivos %2d, del agua %2d, en pantalla %2d, el más cerca %s" % [
			z.id, cells.size(), land, sp.max_alive(z.id), SURF_SECONDS, alive, swimmers, seen, "-" if near == INF else "%d px" % near])
		if swimmers > 0:
			with_swimmers += 1
		if seen > 0:
			with_visible += 1
		for c in sp._alive.get(z.id, []):
			if is_instance_valid(c):
				c.queue_free()
		sp._alive[z.id] = []
		fm.stop_surf()
		if world.combat.in_battle:
			world.combat.end_battle()
	print("[agua] zonas con agua: %d | con salvajes del agua a los %d s: %d | con alguno en pantalla: %d" % [total, SURF_SECONDS, with_swimmers, with_visible])
	r["Navegando aparecen salvajes del agua en todas las zonas con agua (%d de %d)" % [with_swimmers, total]] = total > 0 and with_swimmers == total
	r["Y se llegan a ver: alguno en pantalla en todas (%d de %d)" % [with_visible, total]] = with_visible == total
	r["Sin navegar no sale ninguno"] = walked_clean
	r["Los de tierra no cuentan los del agua para su cupo (%s)" % land_grew] = land_grew == ""
	# Bajarse: los que no pelean se van cuando quedan lejos.
	var far_one: Creature = sp.spawn(DB.species["psyduck"], 20, world.trainer.global_position + Vector2(WildSpawner.WATER_FAR_ON_LAND + 40.0, 0))
	far_one.swims = true
	var here: ZoneEntry = world.streamer.current
	sp._alive[here.id].append(far_one)
	sp._process(0.1)
	await get_tree().process_frame
	r["Al bajarte, los del agua lejanos se van"] = not is_instance_valid(far_one)
	var ok: bool = r.values().all(func(v): return v)
	for key in r:
		print("[agua] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-water-wilds] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)
