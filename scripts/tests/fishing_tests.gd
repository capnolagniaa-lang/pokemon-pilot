class_name FishingTests
extends Node
## Pesca: tablas, cañas, puntos a los que se llega sin Surf, y el minijuego con botones simulados en el mundo de verdad.
##   godot --headless --path . --quit-after 60000 -- --autotest-fishing
## Rearmar los puntos: godot --headless --path . --quit-after 60000 -- --autotest-fishing --generate-spots
## Vitrina: godot --path . --quit-after 150 --write-movie out/f.png --fixed-fps 30 -- --showcase-fishing

const SPOTS_PATH := "res://data/world/pesca_puntos.json"

var autotest: Node
var world: Node
var r := {}


func generate_spots() -> void:
	var data: WorldData = DB.config.world
	var plan := TourPlanner.new(data, true, false, true, false)
	var bounds := BoundsTests.new()
	var reach: Dictionary = bounds._reach(plan, data, true)
	bounds.free()
	var tables = JSON.parse_string(FileAccess.get_file_as_string(Fishing.TABLES_PATH))
	var out := []
	for z: ZoneEntry in data.zones:
		if not tables.has(z.id):
			continue
		var best := {}
		var best_score := -INF
		var node: Node = load(z.scene_path).instantiate()
		var objects := MapRules.objects_by_cell(node)
		var water := func(c: Vector2i) -> bool:
			return Rect2i(Vector2i.ZERO, z.size).has_point(c) and MapRules.cell_physics(node, c, objects) == MapRules.WATER
		for y in z.size.y:
			for x in z.size.x:
				var stand := Vector2i(x, y)
				if not reach.has(z.origin + stand) or plan.is_warp(z.origin + stand):
					continue
				for d: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
					if not water.call(stand + d):
						continue
					var deep := 0
					for k in range(1, 6):
						deep += 1 if water.call(stand + d * k) else 0
					var score := float(deep) * 4.0 - Vector2(stand - z.hub).length() * 0.1
					if deep >= 3 and score > best_score:
						var side := Vector2i(d.y, d.x)
						var sign_cell = stand + side if plan.walkable(z.origin + stand + side) else (stand - side if plan.walkable(z.origin + stand - side) else null)
						best_score = score
						best = {"zone": z.id, "water": [stand.x + d.x, stand.y + d.y], "stand": [stand.x, stand.y]}
						if sign_cell != null:
							best["sign"] = [sign_cell.x, sign_cell.y]
		node.free()
		if not best.is_empty():
			out.append(best)
	var f := FileAccess.open(SPOTS_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(out, " ") + "\n")
	f.close()
	print("[pesca] %d puntos: %s" % [out.size(), ", ".join(out.map(func(s): return s["zone"]))])
	get_tree().quit()


func run() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.wilds_enabled = false
	var fish: Fishing = world.fishing
	await get_tree().process_frame

	var bad_rows := []
	for zone: String in fish.tables:
		for rod in ["vieja", "buena", "super"]:
			var rows: Array = fish.tables[zone].get(rod, [])
			var total := 0
			for row: Dictionary in rows:
				total += int(row["pct"])
				if not DB.species.has(row["species"]):
					bad_rows.append(row["species"])
			if total != 100:
				bad_rows.append("%s %s: %d %%" % [zone, rod, total])
	r["Las tablas suman 100 %% y las especies existen %s" % str(bad_rows)] = bad_rows.is_empty() and fish.tables.size() > 10
	var vieja := []
	for i in 200:
		vieja.append(fish.roll("ruta19", "vieja")["species"])
	r["Con la Caña Vieja solo sale Magikarp, como en FireRed"] = vieja.all(func(s): return s == "magikarp")
	var super_rolls := {}
	for i in 400:
		super_rolls[fish.roll("ruta19", "super")["species"]] = true
	r["Con la Súper salen los mejores %s" % str(super_rolls.keys())] = super_rolls.has("horsea") and super_rolls.has("gyarados")

	# Cada punto: al lado del agua, y se llega caminando sin Surf.
	var data: WorldData = world.streamer.world_data
	var plan := TourPlanner.new(data, true, false, true, false)
	var bounds := BoundsTests.new()
	var reach: Dictionary = bounds._reach(plan, data, true)
	bounds.free()
	var lost := []
	var count := 0
	for zone: String in fish.spots:
		for s: Dictionary in fish.spots[zone]:
			count += 1
			var entry := plan.entry(zone)
			if not fish.tables.has(zone) or not reach.has(entry.origin + s["stand"]) or (s["stand"] - s["water"]).length() != 1.0:
				lost.append(zone)
	r["Los %d puntos están en zonas con tabla y se llega sin Surf %s" % [count, str(lost)]] = lost.is_empty() and count >= 8
	var gifts := {"ciudad_carmin_casa1_fishingguru": "cana_vieja", "ciudad_fucsia_casa2_fishinggurusbrother": "cana_buena", "casa_pescador_fishinggurubrother": "cana_super"}
	var no_gift := []
	for npc_id: String in gifts:
		var talk: NpcTalk = DB.npcs[npc_id].talk_now()
		if talk == null or not talk.give_items.has(gifts[npc_id]):
			no_gift.append(npc_id)
	r["Los tres Pescadores dan su caña %s" % str(no_gift)] = no_gift.is_empty()

	# Sin caña, avisa; con caña, se pesca de verdad.
	var zone_id: String = "ciudad_carmin" if fish.spots.has("ciudad_carmin") else fish.spots.keys()[0]
	var spot: Dictionary = fish.spots[zone_id][0]
	await world.story.teleport(zone_id, spot["stand"])
	await _frames(3)
	world.trainer.facing = Vector2(spot["water"] - spot["stand"])
	GameState.bag.erase("cana_vieja")
	r["Sin caña no se pesca"] = fish.best_rod() == ""
	var front: Vector2 = world.trainer.global_position + world.trainer.facing * 16.0
	var entry_now: ZoneEntry = data.zone_at(front)
	var had_surf := {"mo03": GameState.item_count("mo03"), "alma": GameState.has_flag("medalla_alma")}
	GameState.add_item("mo03", 1)
	GameState.set_flag("medalla_alma")
	r["Sin caña y con Surf, la E no se la queda la pesca"] = not fish._on_interact(zone_id, world.streamer.zone_node(entry_now.id).cell_at(front), front)
	GameState.remove_item("mo03", GameState.item_count("mo03") - had_surf["mo03"])
	if not had_surf["alma"]:
		GameState.set_flag("medalla_alma", false)
	GameState.add_item("cana_vieja", 1)
	r["La mejor caña que tengas manda"] = fish.best_rod() == "vieja"
	fish.fixed_wait = 0.1
	await _press_only()
	r["La E frente al agua tira la línea y traba al entrenador"] = fish.phase == Fishing.Phase.WAITING and world.trainer.locked
	Input.action_release("capture")
	await _until(func(): return fish.phase == Fishing.Phase.BITE, 2.0)
	r["Pica"] = fish.phase == Fishing.Phase.BITE
	await _until(func(): return fish.phase == Fishing.Phase.IDLE, 3.0)
	r["Si no apretás a tiempo se escapa y te destraba"] = fish.phase == Fishing.Phase.IDLE and not world.trainer.locked

	# En el punto, la E pesca y no tira la bola: con el Pokémon afuera, mirando a otro lado o una celda más atrás.
	GameState.add_item("poke_ball", 5)
	var balls := GameState.item_count("poke_ball")
	fish.fixed_wait = 30.0
	var away := Vector2(spot["stand"] - spot["water"])
	world.trainer.facing = away
	await _press()
	r["Mirando para otro lado, pesca"] = fish.phase == Fishing.Phase.WAITING and world.trainer.facing == -away
	await _press()
	await _frames(3)
	r["Apretando de nuevo recoge la línea"] = fish.phase == Fishing.Phase.IDLE and not world.trainer.locked
	world.trainer.global_position += away * 16.0
	await _frames(25)
	await _press()
	r["Una celda más atrás, pesca"] = fish.phase == Fishing.Phase.WAITING
	await _press()
	await _frames(3)
	world.trainer.global_position -= away * 16.0
	world.combat.start_battle()
	await _frames(25)
	r["(sacó al Pokémon)"] = world.combat.in_battle
	await _press()
	r["Con el Pokémon afuera y sin pelea, lo guarda y pesca"] = fish.phase == Fishing.Phase.WAITING and not world.combat.in_battle
	await _press()
	await _frames(3)
	r["Nunca tiró una bola"] = GameState.item_count("poke_ball") == balls
	var far_at: Vector2 = world.trainer.global_position
	var close: Creature = world.spawner.spawn(DB.species["pidgey"], 3, far_at + Vector2(-away.y, away.x) * 48.0 + away * 16.0)
	await _frames(25)
	world.trainer.facing = away  # (mirando al agua, la E es Surf, como en cualquier orilla)
	await _press()
	r["Con un salvaje cerca, la E sigue lanzando la bola"] = fish.phase == Fishing.Phase.IDLE and GameState.item_count("poke_ball") == balls - 1
	if is_instance_valid(close):
		close.queue_free()
	world.combat.end_battle()
	fish.fixed_wait = 0.1
	await get_tree().create_timer(1.6).timeout

	# Aguja afuera de lo verde: se suelta.
	await _hook(fish)
	r["Con la aguja: zona verde y aguja moviéndose"] = fish.phase == Fishing.Phase.GAME and fish.zone_width > 0.0
	await _until(func(): return fish.needle < fish.zone_start - 0.03 or fish.needle > fish.zone_start + fish.zone_width + 0.03, 3.0)
	await _press()
	r["Fuera de lo verde se suelta"] = fish.phase == Fishing.Phase.IDLE and not world.combat.in_battle

	# En lo verde: sale a pelear.
	await _hook(fish)
	await _until(func(): return fish.needle > fish.zone_start + fish.zone_width * 0.3 and fish.needle < fish.zone_start + fish.zone_width * 0.7, 4.0)
	await _press()
	await _frames(3)
	var wild: Creature = null
	for c in world.entities.get_children():
		if c is Creature and c.team == Creature.Team.WILD:
			wild = c
	r["En lo verde sale el Pokémon a pelear, en tierra"] = wild != null and world.combat.in_battle and wild.instance.species.id == "magikarp" and not world.tags_at(wild.global_position).has("agua")
	r["Se puede atrapar (es un salvaje)"] = wild != null and wild.owner_name == ""
	r["Te destraba para pelear"] = not world.story.busy

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[pesca] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-fishing] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.wilds_enabled = false
	var fish: Fishing = world.fishing
	GameState.add_item("cana_super", 1)
	var zone_id: String = "ciudad_carmin" if fish.spots.has("ciudad_carmin") else fish.spots.keys()[0]
	var spot: Dictionary = fish.spots[zone_id][0]
	await world.story.teleport(zone_id, spot["stand"])
	await get_tree().create_timer(0.6).timeout
	world.trainer.facing = Vector2(spot["water"] - spot["stand"])
	fish.fixed_wait = 1.2
	world.story.try_interact()
	await _until(func(): return fish.phase == Fishing.Phase.BITE, 3.0)
	await _press()
	await get_tree().create_timer(1.0).timeout
	fish.needle = fish.zone_start + fish.zone_width / 2.0
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()


func _hook(fish: Fishing) -> void:
	await _frames(3)
	await _press()
	await _until(func(): return fish.phase == Fishing.Phase.BITE, 2.0)
	await _press()
	await _frames(2)


## Apretar y quedarse con el botón abajo, como una persona.
func _press_only() -> void:
	await get_tree().process_frame
	Input.action_press("capture")
	await get_tree().process_frame
	await get_tree().process_frame


func _press() -> void:
	await get_tree().process_frame
	Input.action_press("capture")
	await get_tree().process_frame
	await get_tree().process_frame
	Input.action_release("capture")
	await get_tree().process_frame


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
