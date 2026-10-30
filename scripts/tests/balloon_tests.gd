class_name BalloonTests
extends StoryH1Tests
## Globos aerostáticos entre ciudades (BalloonTravel, tools/build_balloons.py).
##   godot --headless --path . --quit-after 60000 -- --autotest-balloon
##   godot --path . --quit-after 600 --write-movie out/f.png --fixed-fps 30 -- --showcase-balloon  (Verde -> Plateada volando)


func run() -> void:
	var r := {}
	await _setup()
	var data: WorldData = world.streamer.world_data
	var all := BalloonTravel.balloons()
	r["Hay un globo en cada ciudad (9)"] = all.size() >= 9 and all.all(func(b): return b.texture != null and b.to_zone == "")
	r["Cada uno tiene su piloto (acción globo)"] = all.all(func(b): return DB.npcs.has(b.id + "_piloto") \
		and DB.npcs[b.id + "_piloto"].talk_now().action == "globo")
	GameState.set_flag("historia")
	GameState.visited_zones = {"ciudad_verde": true, "ciudad_plateada": true}
	var dests := BalloonTravel.destinations("ciudad_verde")
	r["En la historia: solo a las ciudades que visitaste"] = dests.size() == 1 and dests[0].zone_id == "ciudad_plateada"
	GameState.set_flag("historia", false)
	r["En el modo libre: a todas"] = BalloonTravel.destinations("ciudad_verde").size() == all.size() - 1
	var by_city := {}
	for b in all:
		by_city[b.zone_id] = b
	var pts := BalloonTravel.route_points(data, "ciudad_verde", "isla_canela", Vector2.ZERO, Vector2.ONE)
	r["El vuelo sigue las rutas (Verde -> Canela pasa por varias zonas)"] = pts.size() >= 4
	# Bajás en un lugar caminable en cada ciudad.
	var bad := []
	for b in all:
		await _go(b.zone_id, b.cell + Vector2i(b.size.x / 2, b.size.y))
		var z: Zone = world.streamer.zone_node(b.zone_id)
		if z == null or not MapRules.is_walkable(z, b.cell + Vector2i(b.size.x / 2, b.size.y)) \
				or MapRules.is_walkable(z, b.cell) or not z.has_node("Extra_" + b.id):
			bad.append(b.zone_id)
	if not bad.is_empty():
		print("[globo] ciudades con problemas: ", bad)
	r["En cada ciudad el globo es sólido y se baja en un lugar caminable"] = bad.is_empty()
	# Viaje de verdad: Verde -> Plateada (se saltea a la mitad con E).
	await _go("ciudad_verde", by_city["ciudad_verde"].cell + Vector2i(1, 4))
	GameState.visited_zones = {"ciudad_verde": true}
	var visited_start: Dictionary = GameState.visited_zones.duplicate()
	await _ride(by_city["ciudad_verde"], true)
	var t: Trainer = world.trainer
	var flew: bool = world.balloon.flying and not t.visible and world.camera.target != t
	await get_tree().create_timer(2.5).timeout
	world.balloon._skip = true
	await _until(func(): return not world.balloon.flying, 10.0)
	await _idle()
	var land: Vector2 = BalloonTravel.landing_point(data, by_city["ciudad_plateada"])
	r["Hablando con el piloto se sube y vuela (sin el entrenador en el piso)"] = flew
	r["Volando por arriba no se desbloquea nada (solo la ciudad a la que llegaste)"] = 		GameState.visited_zones.keys().all(func(z): return z in visited_start or z == "ciudad_plateada")
	r["Llega a Plateada, frente al globo, y puede caminar"] = _zone_id() == "ciudad_plateada" \
		and t.global_position.distance_to(land) < 2.0 and t.visible and not t.locked and world.camera.target == t
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[globo] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-balloon] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	await _setup()
	var all := BalloonTravel.balloons()
	for b in all:
		if b.zone_id == "ciudad_verde":
			await _go(b.zone_id, b.cell + Vector2i(b.size.x / 2, b.size.y + 2))
			await get_tree().create_timer(1.0).timeout
			await _ride(b, true)
	await _until(func(): return not world.balloon.flying, 60.0)
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()


func _setup() -> void:
	GameState.new_game(DB.species["charmander"])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	_dialogs()
	await get_tree().create_timer(0.3).timeout


## Habla con el piloto de `b` y elige Plateada (el primero de la lista en el modo libre que no sea Verde).
func _ride(b: ExtraBuilding, wait_start: bool) -> void:
	var pilot: NpcData = DB.npcs[b.id + "_piloto"]
	await _go(b.zone_id, pilot.cell + Vector2i(0, 1))
	var dests := BalloonTravel.destinations(b.zone_id)
	answer = maxi(0, dests.map(func(d): return d.zone_id).find("ciudad_plateada"))
	_talk_to(pilot.id)
	if wait_start:
		await _until(func(): return world.balloon.flying, 10.0)
		await get_tree().create_timer(0.5).timeout
