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
		_overview.call_deferred()
		set_process(false)
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
	var cam: Camera2D = world.trainer.get_node("Camera")
	cam.position_smoothing_enabled = false
	cam.top_level = true
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
