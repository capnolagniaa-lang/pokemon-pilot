class_name FucsiaPlazaTests
extends Node
## La plaza con fuente, el estadio y el partido de Ciudad Fucsia (tools/build_plaza_fucsia.py):
##   godot --headless --path . --quit-after 30000 -- --autotest-fucsia-plaza
##   godot --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-fucsia-plaza

const ZONE := "ciudad_fucsia"
const PLAZA := Rect2i(31, 35, 18, 16)
const FIELD := Rect2i(32, 52, 12, 9)

var autotest: Node
var world: Node
var r := {}


func run() -> void:
	await _setup()
	var zone: Zone = world.streamer.zone_node(ZONE)
	var entry: ZoneEntry = _entry()
	var origin := Vector2(entry.origin * 16)
	r["La fuente y los bancos son sólidos"] = _solid(zone, entry, Vector2i(39, 45)) and _solid(zone, entry, Vector2i(33, 42))
	r["Al estadio no se entra"] = _solid(zone, entry, Vector2i(65, 50))
	r["El piso de la plaza se camina"] = not _solid(zone, entry, Vector2i(36, 44)) and not _solid(zone, entry, Vector2i(44, 30))
	var reach := _reachable(zone, entry, Vector2i(51, 22))
	r["De la calle se llega a la plaza y a la cuidadora"] = reach.has(Vector2i(36, 44)) and reach.has(Vector2i(61, 63))
	# Sin lo agregado, para comparar (la casa con patio se entra por adentro: esa puerta no se alcanzaba desde antes).
	var solid = zone.get_meta(ExtraContent.SOLID_META)
	zone.remove_meta(ExtraContent.SOLID_META)
	var before := _reachable(zone, entry, Vector2i(51, 22))
	zone.set_meta(ExtraContent.SOLID_META, solid)
	var doors := true
	for c: Vector2i in entry.warps:
		var near := false
		var near_before := false
		for d: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.ZERO]:
			near = near or reach.has(c + d)
			near_before = near_before or before.has(c + d)
		if near_before and not near:
			doors = false
			print("[fucsia] sin llegar a la puerta ", c, " → ", entry.warps[c].get("to", ""))
	r["Se sigue llegando a todas las puertas de la ciudad"] = doors

	# Los Pokémon del estadio
	var pets: Array = zone.get_node("Pen_fucsia_estadio").get_children()
	r["Hay 10 Pokémon chicos paseando"] = pets.size() == 10
	var starts := pets.map(func(p): return p.position)
	var area := Rect2(Vector2(FIELD.position * 16), Vector2(FIELD.size * 16)).grow(1.0)
	var walkers := _walkers()
	r["Hay 5 personas caminando"] = walkers.size() == 5
	var walker_starts := walkers.map(func(n): return n.global_position)
	world.trainer.global_position = origin + Vector2(30, 60) * 16  # (lejos: con vos cerca se quedan quietos)
	var inside := true
	var in_plaza := true
	var plaza := Rect2(origin + Vector2(PLAZA.position * 16), Vector2(PLAZA.size * 16)).grow(10.0)
	Engine.time_scale = 10.0
	for i in 120:
		await get_tree().create_timer(0.25).timeout
		inside = inside and pets.all(func(p): return area.has_point(p.position))
		in_plaza = in_plaza and walkers.all(func(n): return plaza.has_point(n.global_position))
	Engine.time_scale = 1.0
	var moved := 0
	for i in pets.size():
		if pets[i].position.distance_to(starts[i]) > 4.0:
			moved += 1
	r["Los Pokémon pasean (%d de 10)" % moved] = moved >= 8
	r["Y no se salen del campo"] = inside
	var went := 0
	for i in walkers.size():
		if walkers[i].global_position.distance_to(walker_starts[i]) > 4.0:
			went += 1
	r["La gente camina (%d de 5)" % went] = went >= 3
	r["Y no se va de la plaza"] = in_plaza
	# El partido
	var game: SoccerMatch = zone.get_node("Pitch_fucsia_estadio")
	r["Juegan 8 Hitmonlee, 4 por equipo"] = game.players.size() == 8 and game.players.filter(func(p): return p.team == 0).size() == 4
	var mat0: ShaderMaterial = game.players[0].sprite.material
	var mat1: ShaderMaterial = game.players[4].sprite.material
	r["Cada equipo tiene su camiseta"] = mat0 != null and mat1 != null and mat0.get_shader_parameter("main_color") != mat1.get_shader_parameter("main_color")
	var field: Rect2 = game.field
	var in_bounds := true
	var box := field.grow(60.0)
	Engine.time_scale = 12.0
	for i in 400:
		await get_tree().create_timer(0.25).timeout
		in_bounds = in_bounds and box.has_point(game.ball) and game.players.all(func(p): return box.has_point(p.position))
	Engine.time_scale = 1.0
	r["Patean la pelota (%d patadas)" % game.kicks] = game.kicks >= 20
	r["Se la pasan (%d pases) y se la roban (%d)" % [game.passes, game.steals]] = game.passes >= 15 and game.steals >= 1
	r["Esquivan al rival con la pelota (%d veces)" % game.dodges] = game.dodges >= 10
	r["Hay goles (%d a %d)" % [game.score[0], game.score[1]]] = game.score[0] + game.score[1] >= 1
	r["La pelota y los jugadores no se van de la cancha"] = in_bounds
	r["Ningún equipo tiene siempre la pelota"] = game.kicks_of[0] >= game.kicks / 4 and game.kicks_of[1] >= game.kicks / 4
	# Con vos cerca se frena.
	var one: StoryNPC = walkers[0]
	world.trainer.global_position = one.global_position + Vector2(20, 0)
	await get_tree().create_timer(0.3).timeout
	var at: Vector2 = one.global_position
	await get_tree().create_timer(1.5).timeout
	r["Con vos cerca se queda quieta"] = one.global_position.distance_to(at) < 1.0

	var ok: bool = r.values().all(func(v): return v)
	for key in r:
		print("[fucsia] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-fucsia-plaza] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina: la plaza y el estadio, sin entrenador en el medio.
func showcase() -> void:
	await _setup()
	var entry := _entry()
	world.trainer.global_position = Vector2((entry.origin + Vector2i(30, 62)) * 16)
	var cam: CameraRig = world.camera
	cam.target = null
	cam.global_position = Vector2((entry.origin + Vector2i(62, 50)) * 16)
	cam.zoom = Vector2(1.9, 1.9)
	world.get_node("PostProcess").visible = false


func _setup() -> void:
	GameState.new_game(DB.species["charmander"])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	var center := Vector2((_entry().origin + Vector2i(40, 34)) * 16)
	world.trainer.global_position = center
	world.camera.global_position = center
	world.streamer.load_around_now(center)
	await get_tree().create_timer(0.5).timeout
	world.story.refresh()
	await get_tree().process_frame


func _entry() -> ZoneEntry:
	for z in DB.config.world.zones:
		if z.id == ZONE:
			return z
	return null


func _walkers() -> Array:
	var out := []
	for id in world.story.npcs:
		if id.begins_with("fucsia_plaza_") and is_instance_valid(world.story.npcs[id]) and world.story.npcs[id].wander_area.size != Vector2.ZERO:
			out.append(world.story.npcs[id])
	return out


func _solid(zone: Zone, entry: ZoneEntry, cell: Vector2i) -> bool:
	return MapRules.cell_physics(zone, cell) == MapRules.SOLID or zone.get_meta(ExtraContent.SOLID_META, {}).has(cell)


func _reachable(zone: Zone, entry: ZoneEntry, from: Vector2i) -> Dictionary:
	var objects := MapRules.objects_by_cell(zone)
	var seen := {from: true}
	var queue: Array[Vector2i] = [from]
	var bounds := Rect2i(Vector2i.ZERO, entry.size)
	while not queue.is_empty():
		var c: Vector2i = queue.pop_back()
		for d: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
			var n := c + d
			if bounds.has_point(n) and not seen.has(n) and MapRules.cell_physics(zone, n, objects) not in [MapRules.SOLID, MapRules.WATER]:
				seen[n] = true
				queue.append(n)
	return seen
