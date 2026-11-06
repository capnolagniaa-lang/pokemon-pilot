class_name CinnabarGymTests
extends Node
## Gimnasio de Isla Canela a pie: las 6 puertas con preguntas, en orden, hasta Blaine.
##   godot --headless --path . --quit-after 60000 -- --autotest-cinnabar-gym

const ZONE := CinnabarGymQuiz.ZONE
const BLAINE := Vector2i(5, 4)
const START := Vector2i(25, 22)
const DIRS: Array[Vector2i] = [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]

var autotest: Node
var world: Node
var r := {}


func run() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.wilds_enabled = false
	await world.story.teleport(ZONE, START)
	await get_tree().create_timer(0.3).timeout
	r["Sin responder nada no se llega a Blaine"] = not _reaches_blaine()
	for door in CinnabarGymQuiz.DOORS.size():
		await _door(door)
	r["Con las 6 puertas abiertas se llega a Blaine"] = _reaches_blaine()
	await _wrong_answer()
	await _saved()
	await _all_gyms()
	var ok := true
	for k: String in r:
		print("[canela] %s: %s" % [k, "OK" if r[k] else "FALLO"])
		ok = ok and r[k]
	print("[autotest-cinnabar-gym] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)


## Se llega a la máquina caminando, se responde con la E y la puerta deja pasar a la sala siguiente.
func _door(door: int) -> void:
	var d: Dictionary = CinnabarGymQuiz.DOORS[door]
	var seen := _reach()
	var stand := Vector2i(-1, -1)
	var machine := Vector2i.ZERO
	for m: Vector2i in d["machine"]:
		if seen.has(m + Vector2i.DOWN):
			stand = m + Vector2i.DOWN
			machine = m
	r["Puerta %d: se llega a su máquina" % (door + 1)] = stand.x >= 0
	if stand.x < 0:
		return
	var before := seen.size()
	await _answer(stand, d["yes"])
	r["Puerta %d: acertar la abre" % (door + 1)] = CinnabarGymQuiz.is_open(door)
	r["Puerta %d: abre paso a más lugar" % (door + 1)] = _reach().size() > before
	await _answer(stand, null)
	r["Puerta %d: abierta no pregunta de nuevo" % (door + 1)] = not world.story.busy


## Parado abajo de la máquina, mirándola: E y responder (null = solo pasar los textos).
func _answer(stand: Vector2i, yes: Variant) -> void:
	await world.story.teleport(ZONE, stand)
	await get_tree().create_timer(0.2).timeout
	world.trainer.facing = Vector2.UP
	world.story.try_interact()
	var time := 0.0
	while (world.story.busy or world.story.dialog.active) and time < 8.0:
		if yes != null and world.story.dialog.get("choosing") == true:
			world.story.dialog.choose(0 if yes else 1)
		else:
			world.story.dialog.advance()
			if yes != null:
				world.story.dialog.choose(0 if yes else 1)
		await get_tree().create_timer(0.05).timeout
		time += 0.05


## Errar: te reta su entrenador, y al ganarle se abre igual.
func _wrong_answer() -> void:
	var door := 0
	var flag := CinnabarGymQuiz.flag_of(door)
	GameState.set_flag(flag, false)
	var npc: NpcData = DB.npcs[CinnabarGymQuiz.DOORS[door]["trainer"]]
	GameState.set_flag(npc.defeated_flag(), false)
	r["Errar: la puerta sigue cerrada hasta pelear"] = not CinnabarGymQuiz.is_open(door)
	await world.story.teleport(ZONE, Vector2i(22, 11))
	await get_tree().create_timer(0.2).timeout
	world.trainer.facing = Vector2.UP
	world.story.try_interact()
	var time := 0.0
	while not world.arena.active and time < 10.0:
		world.story.dialog.advance()
		world.story.dialog.choose(1)  # "No": la de Caterpie es Sí
		await get_tree().create_timer(0.05).timeout
		time += 0.05
	r["Errar: te reta su entrenador"] = world.arena.active and not GameState.has_flag(flag)
	time = 0.0
	while world.arena.active and time < 30.0:
		for c in world.entities.get_children():
			if c is Creature and c.team == Creature.Team.WILD and not c.is_down():
				c.health.apply_damage(99999.0)
		world.story.dialog.advance()
		await get_tree().create_timer(0.2).timeout
		time += 0.2
	time = 0.0
	while (world.story.busy or world.warps.busy) and time < 10.0:
		world.story.dialog.advance()
		await get_tree().create_timer(0.1).timeout
		time += 0.1
	r["Errar: al ganarle se abre"] = GameState.has_flag(npc.defeated_flag()) and CinnabarGymQuiz.is_open(door)
	r["Errar: después no queda trabado"] = not world.story.busy and not world.trainer.locked


## Cargar adentro: quedan abiertas las de las banderas, y partidas viejas con el entrenador vencido también (la tuya).
func _saved() -> void:
	for door in CinnabarGymQuiz.DOORS.size():
		GameState.set_flag(CinnabarGymQuiz.flag_of(door), false)
		var other: NpcData = DB.npcs[CinnabarGymQuiz.DOORS[door]["trainer"]]
		GameState.set_flag(other.defeated_flag(), door == 0)
	GameState.set_flag(CinnabarGymQuiz.flag_of(1))
	var ts: int = world.streamer.world_data.tile_size
	var entry: ZoneEntry = world.streamer.world_data.zones.filter(func(z): return z.id == ZONE)[0]
	GameState.trainer_position = Vector2((entry.origin + START) * ts) + Vector2.ONE * ts / 2.0
	GameState.from_dict(JSON.parse_string(JSON.stringify(GameState.to_dict())))
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().create_timer(0.3).timeout
	world = get_tree().current_scene
	await get_tree().create_timer(1.0).timeout
	var zone: Zone = world.streamer.zone_node(ZONE)
	r["Al cargar: entrenador vencido = puerta abierta"] = MapRules.is_walkable(zone, Vector2i(26, 9))
	r["Al cargar: pregunta acertada = puerta abierta"] = MapRules.is_walkable(zone, Vector2i(17, 9))
	r["Al cargar: las demás siguen cerradas"] = not MapRules.is_walkable(zone, Vector2i(17, 16)) and not MapRules.is_walkable(zone, Vector2i(5, 9))
	GameState.set_flag(CinnabarGymQuiz.BLAINE_FLAG)
	await get_tree().process_frame
	r["Con la medalla quedan todas abiertas"] = MapRules.is_walkable(zone, Vector2i(11, 22)) and MapRules.is_walkable(zone, Vector2i(5, 9))


## Los 8 gimnasios: de la puerta de entrada se llega caminando al líder (con sus puzzles resueltos; Corte no cuenta como
## obstáculo). Las peleas de gimnasio de los otros tests saltan directo al líder: esto mira que se pueda llegar.
func _all_gyms() -> void:
	GameState.set_flag(VermilionGymPuzzle.FLAG)
	for n: NpcData in DB.npcs.values():
		if n.trainer == null or not n.trainer.leader or not n.zone_id.ends_with("_gimnasio"):
			continue
		var entry: ZoneEntry = world.streamer.world_data.zones.filter(func(z): return z.id == n.zone_id)[0]
		var door := Vector2i(-1, -1)
		for c: Vector2i in entry.warps:
			if entry.warps[c]["to"] != n.zone_id:
				door = c
		await world.story.teleport(n.zone_id, entry.hub)
		await get_tree().create_timer(0.3).timeout
		var zone: Zone = world.streamer.zone_node(n.zone_id)
		var seen := {}
		var queue: Array[Vector2i] = []
		for d: Vector2i in DIRS:
			if MapRules.is_walkable(zone, door + d, {}):
				seen[door + d] = true
				queue.append(door + d)
		while not queue.is_empty():
			var c: Vector2i = queue.pop_back()
			for d: Vector2i in DIRS:
				var m: Vector2i = c + d
				if entry.warps.has(m) and entry.warps[m]["to"] == n.zone_id:  # placas de teletransporte (Azafrán)
					var to: Vector2i = WarpSystem.arrival(func(k: Vector2i) -> bool: return MapRules.is_walkable(zone, k, {}), entry, entry.warps[m]["cell"])[0]
					if not seen.has(to):
						seen[to] = true
						queue.append(to)
				elif not seen.has(m) and m.x >= 0 and m.y >= 0 and m.x < entry.size.x and m.y < entry.size.y and MapRules.is_walkable(zone, m, {}):
					seen[m] = true
					queue.append(m)
		var there := DIRS.any(func(d: Vector2i) -> bool: return seen.has(n.cell + d))
		r["Se llega caminando a %s (%s)" % [n.trainer.display_name, n.zone_id]] = there


func _reach() -> Dictionary:
	var zone: Zone = world.streamer.zone_node(ZONE)
	var objects := MapRules.objects_by_cell(zone)
	var seen := {START: true}
	var queue: Array[Vector2i] = [START]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_back()
		for d: Vector2i in DIRS:
			var n: Vector2i = c + d
			if not seen.has(n) and n.x >= 0 and n.y >= 0 and n.x < 30 and n.y < 25 and MapRules.is_walkable(zone, n, objects):
				seen[n] = true
				queue.append(n)
	return seen


func _reaches_blaine() -> bool:
	var seen := _reach()
	return DIRS.any(func(d: Vector2i) -> bool: return seen.has(BLAINE + d))
