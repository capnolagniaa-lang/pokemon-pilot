extends Node
## Prueba automática (solo con: godot --path . -- --autotest).
## Elige inicial y recorre la región por los caminos (plaza -> salida -> zona vecina -> plaza ...),
## verificando que las zonas estén conectadas, que se carguen y que el Pokémon siga al entrenador.

## Recorrido: zonas a visitar en orden (cada una vecina de la anterior).
const TOUR := ["ruta1", "bosque", "lago", "colinas", "arboleda", "pradera_sur", "humedal", "pradera_florida", "ruta1"]
const STUCK_TIME := 3.0
const ARRIVE := 4.0

var enabled := false
var _zones_seen: Array[String] = []
var _waypoints: Array[Vector2] = []
var _max_follow_gap := 0.0
var _stuck := 0.0
var _last_pos := Vector2.ZERO
var _done := false


func _ready() -> void:
	if "--overview" in OS.get_cmdline_user_args():
		GameState.wilds_enabled = false
		_overview.call_deferred()
		set_process(false)
		return
	if "--autotest-input" in OS.get_cmdline_user_args():
		set_process(false)
		_input_test.call_deferred()
		return
	if "--autotest-combat" in OS.get_cmdline_user_args():
		set_process(false)
		_combat_test.call_deferred()
		return
	enabled = "--autotest" in OS.get_cmdline_user_args()
	if not enabled:
		set_process(false)
		return
	Events.zone_entered.connect(func(z: ZoneEntry): _zones_seen.append(z.id); print("[zona] ", z.display_name))
	Engine.time_scale = 3.0
	_start.call_deferred()


func _start() -> void:
	GameState.new_game(DB.config.starters[1])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	_build_waypoints()


## Vista de toda la región de una vez (godot --path . --write-movie mapa.png -- --overview).
func _overview() -> void:
	GameState.new_game(DB.config.starters[1])
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world := get_tree().current_scene
	var data := DB.config.world
	var bounds := Rect2()
	for z in data.zones:
		var r := z.world_rect(data.tile_size)
		bounds = r if bounds.size == Vector2.ZERO else bounds.merge(r)
		world.streamer.load_around_now(r.get_center())
	world.streamer.target = null
	world.get_node("PostProcess").visible = false
	world.get_node("CloudShadows").visible = false
	var cam: CameraRig = world.camera
	cam.target = null
	cam.global_position = bounds.get_center()
	var view := get_viewport().get_visible_rect().size
	var z := minf(view.x / bounds.size.x, view.y / bounds.size.y)
	cam.zoom = Vector2(z, z)
	for i in 10:
		await get_tree().process_frame
	get_tree().quit()


func _build_waypoints() -> void:
	var world := DB.config.world
	var ts := world.tile_size
	var zones := {}
	for z in world.zones:
		zones[z.id] = z
	for i in TOUR.size() - 1:
		var a: ZoneEntry = zones[TOUR[i]]
		var b: ZoneEntry = zones[TOUR[i + 1]]
		var side := _side(a, b)
		var exit_a: Vector2i = a.exits[side]
		var exit_b: Vector2i = b.exits[_opposite(side)]
		_waypoints.append(a.path_point(a.hub, ts))
		_waypoints.append(a.path_point(_corner(a, exit_a, side), ts))
		_waypoints.append(a.path_point(exit_a, ts))
		_waypoints.append(b.path_point(exit_b, ts))
		_waypoints.append(b.path_point(_corner(b, exit_b, _opposite(side)), ts))
	var last: ZoneEntry = zones[TOUR[-1]]
	_waypoints.append(last.path_point(last.hub, ts))


func _side(a: ZoneEntry, b: ZoneEntry) -> String:
	var d := b.origin - a.origin
	if d.x > 0:
		return "right"
	if d.x < 0:
		return "left"
	return "down" if d.y > 0 else "up"


func _opposite(side: String) -> String:
	return {"up": "down", "down": "up", "left": "right", "right": "left"}[side]


## Esquina del camino en L entre la salida y la plaza (ver ZoneMap.carve en tools/build_world.gd).
func _corner(z: ZoneEntry, exit: Vector2i, side: String) -> Vector2i:
	return Vector2i(exit.x, z.hub.y) if side in ["up", "down"] else Vector2i(z.hub.x, exit.y)


func _process(delta: float) -> void:
	var world := get_tree().current_scene
	if _done or world == null or not world.has_method("tags_at"):
		return
	var trainer: Trainer = world.trainer
	var comp: Creature = world.companion
	if comp != null:
		_max_follow_gap = maxf(_max_follow_gap, comp.global_position.distance_to(trainer.global_position))
	if _waypoints.is_empty():
		_finish(world, trainer, "")
		return
	var target := _waypoints[0]
	var diff := target - trainer.global_position
	if diff.length() < ARRIVE:
		_waypoints.pop_front()
		_stuck = 0.0
		return
	trainer.autopilot = diff.normalized()
	trainer.autopilot_run = true
	_stuck = _stuck + delta if trainer.global_position.distance_to(_last_pos) < 0.5 else 0.0
	_last_pos = trainer.global_position
	if _stuck > STUCK_TIME:
		_finish(world, trainer, "trabado yendo a %s" % target)


func _finish(world: Node, trainer: Trainer, error: String) -> void:
	_done = true
	trainer.autopilot = Vector2.ZERO
	var expected := TOUR.duplicate()
	var missing := expected.filter(func(id): return not _zones_seen.has(id))
	var ok := error == "" and missing.is_empty() and _max_follow_gap < 170.0
	print("[autotest] zonas=", _zones_seen.size(), " faltan=", missing, " pos=", trainer.global_position.round(),
		" distancia_max_pokemon=", snappedf(_max_follow_gap, 0.1), " cargadas=", world.streamer.loaded.keys(),
		" ", error, " -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


# --- Autotest de combate (godot --path . -- --autotest-combat) ---------------------------

## [tu Pokémon, salvaje, nivel del salvaje]
const FIGHTS := [["charmander", "bulbasaur", 4], ["pikachu", "squirtle", 4], ["seel", "oddish", 4]]


func _combat_test() -> void:
	var stats := {}
	Events.battle_started.connect(func(): stats["battle_started"] += 1)
	Events.battle_ended.connect(func(): stats["battle_ended"] += 1)
	Events.creature_damaged.connect(func(c, amount, _h):
		if c.team == Creature.Team.WILD:
			stats["dealt"] += amount
		else:
			stats["taken"] += amount)
	Events.status_applied.connect(func(c, s): stats["status"].append("%s:%s" % [c.instance.species.id, s.id]))
	Events.move_used.connect(func(_u, m): if m.cast_time > 0.0: stats["casts"] += 1)
	Events.creature_fainted.connect(func(c): stats["fainted"] = c.instance.species.id)
	Events.message_requested.connect(func(t): print("[msg] ", t))
	Engine.time_scale = 2.0
	var all_ok := true
	var statuses_seen := {}
	for fight in FIGHTS:
		stats.merge({"battle_started": 0, "battle_ended": 0, "dealt": 0.0, "taken": 0.0, "status": [], "casts": 0, "fainted": ""}, true)
		GameState.new_game(DB.species[fight[0]])
		GameState.wilds_enabled = false
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")
		await get_tree().process_frame
		await get_tree().process_frame
		var world := get_tree().current_scene
		world.combat.input_source = BotCombatInput.new(world)
		await get_tree().create_timer(0.5).timeout
		var wild: Creature = world.spawner.spawn(DB.species[fight[1]], fight[2], world.trainer.global_position + Vector2(56, 0))
		var t := 0.0
		while t < 60.0 and stats["battle_ended"] == 0:
			await get_tree().process_frame
			t += get_process_delta_time()
		# Resultado válido: el salvaje se debilitó o huyó con poca vida (la IA de huida).
		var fled := is_instance_valid(wild) and not wild.health.is_dead() and wild.health.ratio() < 0.3
		stats["resultado"] = "debilitado" if stats["fainted"] != "" else ("huyó" if fled else "?")
		var ok: bool = stats["battle_started"] >= 1 and stats["battle_ended"] >= 1 and stats["dealt"] > 0.0 and stats["resultado"] != "?"
		for s in stats["status"]:
			statuses_seen[s.split(":")[1]] = true
		all_ok = all_ok and ok
		print("[combate] %s vs %s: " % [fight[0], fight[1]], stats, " tiempo=", snappedf(t, 0.1), " -> ", "OK" if ok else "FALLO")
	print("[autotest-combate] estados vistos=", statuses_seen.keys(), " -> ", "OK" if all_ok else "FALLO")
	get_tree().quit(0 if all_ok else 1)

# --- Autotest del input real (godot --path . -- --autotest-input) ---------------------------

func _input_test() -> void:
	var used := []
	Events.move_used.connect(func(_u, m): used.append(m.id))
	GameState.new_game(DB.species["charmander"])
	GameState.wilds_enabled = true
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world := get_tree().current_scene
	await get_tree().create_timer(0.3).timeout
	var results := {}
	var wilds: Array = world.entities.get_children().filter(func(n): return n is Creature and n.team == Creature.Team.WILD)
	results["hay salvajes en el pasto"] = wilds.size() > 0
	print("[salvajes] ", wilds.map(func(w): return "%s Nv.%d" % [w.instance.species.display_name, w.instance.level]))
	for w in wilds:
		w.queue_free()  # que no interfieran con la prueba de teclas
	await _tap("battle_toggle")
	results["F saca al Pokémon"] = world.combat.in_battle and world.companion.machine.current_name() == "controlled"
	Input.action_press("move_right")
	await get_tree().create_timer(0.3).timeout
	Input.action_release("move_right")
	results["WASD lo mueve"] = world.companion.global_position.x > world.trainer.global_position.x + 10.0
	await _tap("attack_1", true)
	results["1 usa Ascuas"] = used.has("ascuas")
	await get_tree().create_timer(1.0).timeout
	await _tap("dodge", true)
	results["Espacio esquiva"] = world.companion.machine.current_name() == "dash" or world.companion.health.invulnerable_time > 0.0
	await get_tree().create_timer(1.5).timeout
	results["sigue en combate sin enemigos"] = world.combat.in_battle
	await _tap("battle_toggle")
	await get_tree().create_timer(0.2).timeout
	results["F lo guarda"] = not world.combat.in_battle and world.companion.machine.current_name() in ["follow", "idle"]
	var ok := results.values().all(func(v): return v)
	print("[autotest-input] ", results, " -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Simula apretar una tecla justo antes de que la lean (como hace Godot con el input real):
## en el frame de proceso (acciones que se leen en _process) o en el de física.
func _tap(action: String, physics: bool = false) -> void:
	if physics:
		await get_tree().physics_frame
	else:
		await get_tree().process_frame
	Input.action_press(action)
	for i in 3:
		await get_tree().physics_frame
	Input.action_release(action)