class_name AiSteerTests
extends Node
## Autotest de la IA que no se traba (pedido del usuario 2026-10-25: "se quedan trabados cuando tienen un obstáculo
## enfrente mío"): CombatBody.steer/find_path/clear_shot, anticipación del disparo y la dificultad Normal.
##   godot --headless --path . --quit-after 30000 -- --autotest-ai-steer

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	world = await autotest._setup_kit_world("squirtle")
	var me: Creature = world.companion
	var zone: Zone = world.streamer.zone_node(world.streamer.current.id)
	var wall := _find_wall(zone)
	r["Hay una pared de prueba en %s (%s)" % [world.streamer.current.id, str(wall)]] = wall.x > -1000
	if wall.x > -1000:
		var above := zone.to_global(zone.ground.map_to_local(wall + Vector2i(0, -2)))
		var below := zone.to_global(zone.ground.map_to_local(wall + Vector2i(0, 2)))
		# Tu Pokémon quieto abajo de la pared; un salvaje arriba que te persigue.
		me.machine.set_physics_process(false)
		me.global_position = below
		var wild: Creature = world.spawner.spawn(DB.species["rattata"], 8, above)
		await get_tree().physics_frame
		r["La pared tapa el tiro (clear_shot)"] = not wild.body.clear_shot(me)
		var open: Creature = autotest._dummy(world, "bulbasaur", below + Vector2(30, 0))
		await get_tree().physics_frame
		r["En campo abierto hay tiro"] = me.body.clear_shot(open)
		open.queue_free()
		wild.home = above
		wild.target = me
		wild.machine.transition_to("chase")
		# Llegó = pasó al otro lado de la pared (más abajo que ella) y está cerca tuyo.
		var wall_y: float = zone.to_global(zone.ground.map_to_local(wall)).y
		var arrived := func() -> bool: return is_instance_valid(wild) and wild.global_position.y > wall_y + 10.0 			and wild.global_position.distance_to(me.global_position) < 36.0
		var t := 0.0
		while t < 10.0 and not arrived.call():
			await get_tree().physics_frame
			t += get_physics_process_delta_time()
		r["El salvaje rodea la pared y te alcanza (en %.1f s)" % t] = arrived.call()
		if is_instance_valid(wild):
			wild.queue_free()
		me.machine.set_physics_process(true)

	# Anticipación: con Difícil (lead 1) apunta adonde vas a estar.
	GameState.difficulty = DB.difficulties["dificil"]
	var shooter: Creature = autotest._dummy(world, "squirtle", me.global_position + Vector2(-90, 0))
	var runner: Creature = autotest._dummy(world, "bulbasaur", me.global_position + Vector2(40, 0))
	await get_tree().physics_frame
	shooter.target = runner
	runner.velocity = Vector2(0, 120)  # se mueve hacia abajo
	var slot := -1
	for s in MoveUser.SLOT_COUNT:
		var m: MoveData = shooter.moves.slots[s]
		if m != null and m.kind == MoveData.Kind.PROJECTILE and m.power > 0:
			slot = s
			break
	var before: Array = world.entities.get_children().filter(func(n): return n is Projectile)
	var lead := CombatBody.difficulty().lead
	var saved_err := CombatBody.difficulty().aim_error_deg
	CombatBody.difficulty().aim_error_deg = 0.0
	shooter.body.use(slot)
	CombatBody.difficulty().aim_error_deg = saved_err  # (sin error, para ver solo la anticipación)
	await get_tree().physics_frame
	var shots: Array = world.entities.get_children().filter(func(n): return n is Projectile and not n in before)
	r["Dispara anticipando el movimiento (lead %.1f)" % lead] = lead > 0.0 and not shots.is_empty() \
		and shots[0].velocity.normalized().y > 0.05

	# Normal más pareja que antes (pedido del usuario: "no parece ser tan buena en dificultad normal").
	var normal: AiDifficulty = load("res://data/config/difficulty/normal.tres")
	r["Normal: ataca más seguido, apunta mejor, esquiva y anticipa"] = normal.attack_interval_mult <= 1.25 \
		and normal.aim_error_deg <= 10.0 and normal.dodge_chance >= 0.2 and normal.lead > 0.0

	# Con la F (controlando al Pokémon) el entrenador lo sigue (pedido del usuario 2026-10-28: "se queda lejos").
	world = await autotest._setup_kit_world("squirtle")
	var mon: Creature = world.companion
	var t: Trainer = world.trainer
	r["Al tomar el control, el entrenador sigue a su Pokémon"] = world.combat.in_battle and t.follow_target == mon
	mon.machine.set_physics_process(false)
	var target_pos := t.global_position + Vector2(0, 160)
	var path_free := not mon.test_move(mon.global_transform, target_pos - mon.global_position)
	mon.global_position = target_pos if path_free else t.global_position + Vector2(160, 0)
	var waited := 0.0
	while waited < 4.0 and t.global_position.distance_to(mon.global_position) > Trainer.FOLLOW_FAR:
		await get_tree().physics_frame
		waited += get_physics_process_delta_time()
	r["El entrenador se acerca solo (%.0f px en %.1f s)" % [t.global_position.distance_to(mon.global_position), waited]] = \
		t.global_position.distance_to(mon.global_position) <= Trainer.FOLLOW_FAR
	await get_tree().create_timer(0.5).timeout
	r["...y frena antes de meterse encima"] = t.global_position.distance_to(mon.global_position) >= Trainer.FOLLOW_NEAR * 0.7
	mon.machine.set_physics_process(true)
	world.combat.end_battle()
	r["Al soltar el control deja de seguir"] = t.follow_target == null

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[ai-steer] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-ai-steer] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Mitad del ancho de la pared de prueba: 7 celdas, como una casa (de frente, sin esquivar, se queda empujando).
const WALL_HALF := 3


## Una pared de al menos 7 celdas de ancho con lugar libre arriba y abajo (y camino para rodearla). Celda del medio de
## la pared, o Vector2i(-9999, -9999) si no hay.
func _find_wall(zone: Zone) -> Vector2i:
	var objects := MapRules.objects_by_cell(zone)
	var free := func(c: Vector2i) -> bool: return MapRules.is_walkable(zone, c, objects)
	var used := zone.ground.get_used_rect()
	for y in range(used.position.y + 3, used.end.y - 3):
		for x in range(used.position.x + 3, used.end.x - 3):
			var c := Vector2i(x, y)
			if range(-WALL_HALF, WALL_HALF + 1).any(func(dx): return free.call(c + Vector2i(dx, 0))):
				continue
			if not (free.call(c + Vector2i(0, -1)) and free.call(c + Vector2i(0, -2)) and free.call(c + Vector2i(0, 1)) \
					and free.call(c + Vector2i(0, 2))):
				continue
			var astar := AStarGrid2D.new()
			astar.region = Rect2i(c - Vector2i(14, 8), Vector2i(29, 17))
			astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
			astar.update()
			for ax in range(astar.region.position.x, astar.region.end.x):
				for ay in range(astar.region.position.y, astar.region.end.y):
					if not free.call(Vector2i(ax, ay)):
						astar.set_point_solid(Vector2i(ax, ay))
			var p := astar.get_id_path(c + Vector2i(0, -2), c + Vector2i(0, 2))
			if p.size() > 10 and p.size() < 34:
				return c
	return Vector2i(-9999, -9999)
