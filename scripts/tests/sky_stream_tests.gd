class_name SkyStreamTests
extends Node
## Rayo (marca una zona y cae del cielo) y Lanzallamas (chorro sostenido, como Psicorrayo), con sus hojas hechas con Qwen:
##   godot --headless --path . --quit-after 30000 -- --autotest-sky-stream
##   godot --path . --quit-after 300 --write-movie out/f.png --fixed-fps 30 -- --showcase-sky-stream

var autotest: Node
var world: Node
var r := {}


func run() -> void:
	world = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	me.instance.level = 50  # (a Nv. 10 la barra de PP no alcanza para uno de 90)
	me.moves.set_pp(me.moves.max_pp())
	var rayo: MoveData = DB.moves["rayo"]
	var flame: MoveData = DB.moves["lanzallamas"]
	r["Las hojas están (6 de caída, 4 de marca, 4 de chorro)"] = DB.vfx_sheet(SkyStrike.BOLT_SHEET).get_frame_count("default") == 6 \
		and DB.vfx_sheet(SkyStrike.MARK_SHEET).get_frame_count("default") == 4 \
		and DB.vfx_part(flame, "chorro").get_frame_count("default") == 4

	# Rayo: el que está en la marca recibe el golpe recién cuando cae, y el que no, nada.
	r["Rayo es una zona que cae del cielo"] = rayo.kind == MoveData.Kind.ZONE and rayo.zone_strike and rayo.strike_delay >= 0.4
	var foe: Creature = autotest._dummy(world, "snorlax", me.global_position + Vector2(80, 0))
	var far: Creature = autotest._dummy(world, "snorlax", me.global_position + Vector2(80, 70))
	var at := foe.global_position
	var hp0: float = foe.instance.hp
	var far0: float = far.instance.hp
	me.moves.slots[1] = rayo
	me.moves.reset_cooldown(1)
	r["Rayo sale donde apuntás"] = me.use_slot(1, Vector2.RIGHT, at)
	await _until(func(): return _strike() != null, 1.0)
	var sk: SkyStrike = _strike()
	r["Marca la zona en el piso, con la hoja"] = sk != null and sk.global_position.distance_to(at) < 1.0 and sk._mark != null
	r["Antes de caer no pega"] = is_equal_approx(foe.instance.hp, hp0)
	await _until(func(): return foe.instance.hp < hp0, 1.5)
	r["Cae y pega al que está en la marca"] = foe.instance.hp < hp0
	r["Al que está afuera no le hace nada"] = is_equal_approx(far.instance.hp, far0)
	foe.queue_free()
	far.queue_free()
	await _until(func(): return me.machine.current_name() == me.default_state(), 2.0)

	# Lanzallamas: se sostiene, pega varias veces y va lento mientras sale.
	r["Lanzallamas es un chorro sostenido, largo y angosto"] = flame.kind == MoveData.Kind.CHANNEL and flame.cone_length >= 120 and flame.cone_angle_deg <= 16
	foe = autotest._dummy(world, "snorlax", me.global_position + Vector2(70, 0))
	me.moves.slots[1] = flame
	me.moves.reset_cooldown(1)
	me.moves.set_pp(me.moves.max_pp())
	var hits := [0, foe.instance.hp]
	foe.health.changed.connect(func(hp: float, _max: float):
		if hp < hits[1]:
			hits[0] += 1
		hits[1] = hp)
	var aim: Vector2 = (foe.global_position - me.global_position).normalized()
	r["Lanzallamas sale"] = me.use_slot(1, aim)
	await _until(func(): return me.machine.current_name() == "channel", 1.0)
	r["Se queda canalizando"] = me.machine.current_name() == "channel"
	var cone: ChannelCone = _cone(me)
	r["El chorro se dibuja con la hoja"] = cone != null and cone._stream != null and cone._stream.is_playing()
	await _until(func(): return me.machine.current_name() != "channel", 2.0)
	r["Pega varias veces (%d)" % hits[0]] = hits[0] >= 3
	foe.queue_free()
	await _surf()
	await _solar()

	var ok: bool = r.values().all(func(v): return v)
	for key in r:
		print("[sky-stream] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-sky-stream] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina: dos Rayos y dos Lanzallamas contra un Snorlax.
func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	me.instance.level = 50
	var foe: Creature = autotest._dummy(world, "snorlax", me.global_position + Vector2(90, 0))
	for id in ["rayo", "lanzallamas", "rayo", "lanzallamas"]:
		me.moves.slots[1] = DB.moves[id]
		me.moves.reset_cooldown(1)
		me.moves.set_pp(me.moves.max_pp())
		foe.health.heal(9999.0)
		var aim: Vector2 = (foe.global_position - me.global_position).normalized()
		me.use_slot(1, aim, foe.global_position)
		print("[showcase] ", id, " cuadro ", Engine.get_frames_drawn())
		await get_tree().create_timer(1.8).timeout


## Surf: viaja arriba de la ola hasta donde apuntás y golpea recién ahí.
func _surf() -> void:
	var me: Creature = world.companion
	var surf: MoveData = DB.moves["surf"]
	me.moves.slots[1] = surf
	me.moves.reset_cooldown(1)
	me.moves.set_pp(me.moves.max_pp())
	me.machine.transition_to(me.default_state())
	var finder := BalanceTests.new()
	finder.world = world
	me.global_position = finder._open_spot()  # (sin paredes en el camino)
	finder.free()
	await get_tree().physics_frame
	var from := me.global_position
	var near: Creature = autotest._dummy(world, "snorlax", from + Vector2(20, 0))  # queda atrás al llegar
	var goal: Creature = autotest._dummy(world, "snorlax", from + Vector2(110, 0))
	var near0: float = near.instance.hp
	var goal0: float = goal.instance.hp
	await get_tree().physics_frame
	r["Surf llega más lejos que antes"] = surf.reach() > surf.radius
	r["Surf sale"] = me.use_slot(1, Vector2.RIGHT, from + Vector2(110, 0))
	await _until(func(): return me.machine.current_name() == "ride", 1.5)
	r["Surf: después de cargar viaja"] = me.machine.current_name() == "ride"
	r["Surf: va arriba de la ola"] = me.sprite.lift > 0.0 and me.get_children().any(func(c): return c is VfxSprite)
	r["Surf: mientras viaja no pega"] = is_equal_approx(near.instance.hp, near0) and is_equal_approx(goal.instance.hp, goal0)
	await _until(func(): return me.machine.current_name() != "ride", 1.5)
	r["Surf: termina donde apuntaste (%.0f px)" % me.global_position.distance_to(from + Vector2(110, 0))] = me.global_position.distance_to(from + Vector2(110, 0)) < 12.0
	await get_tree().create_timer(0.2).timeout
	r["Surf: al llegar golpea al que está ahí"] = goal.instance.hp < goal0
	r["Surf: al que quedó lejos, atrás, no"] = is_equal_approx(near.instance.hp, near0)
	r["Surf: se baja de la ola"] = is_zero_approx(me.sprite.lift) and not me.get_children().any(func(c): return c is VfxSprite and not c.is_queued_for_deletion())
	near.queue_free()
	goal.queue_free()
	await _until(func(): return me.machine.current_name() == me.default_state(), 2.0)
	# Apuntar lejos no lo pasa de su alcance; apuntar cerca, va cerca.
	var start := me.global_position
	r["Surf: no se pasa de su alcance"] = me.ride_point(surf, start + Vector2(900, 0), Vector2.RIGHT).distance_to(start) <= surf.ride_range + 0.5
	r["Surf: apuntando cerca va cerca"] = me.ride_point(surf, start + Vector2(30, 0), Vector2.RIGHT).distance_to(start) < 31.0
	r["Surf: la explicación lo cuenta"] = "ola" in MoveInfo.what_it_does(surf)


## Rayo Solar: carga y después un rayo instantáneo que pega a todos en la línea a la vez, hasta la primera pared.
func _solar() -> void:
	var me: Creature = world.companion
	var solar: MoveData = DB.moves["rayo_solar"]
	r["Rayo Solar es un rayo con carga"] = solar.beam_length > 0.0 and solar.cast_time > 0.5
	me.moves.slots[1] = solar
	me.moves.reset_cooldown(1)
	me.moves.set_pp(me.moves.max_pp())
	me.machine.transition_to(me.default_state())
	var finder := BalanceTests.new()
	finder.world = world
	me.global_position = finder._open_spot()
	finder.free()
	await get_tree().physics_frame
	var from := me.global_position
	var near: Creature = autotest._dummy(world, "snorlax", from + Vector2(50, 0))
	var far: Creature = autotest._dummy(world, "snorlax", from + Vector2(solar.beam_length - 20.0, 0))
	var side: Creature = autotest._dummy(world, "snorlax", from + Vector2(100, 50))
	var hp := [near.instance.hp, far.instance.hp, side.instance.hp]
	await get_tree().physics_frame
	r["Rayo Solar sale"] = me.use_slot(1, Vector2.RIGHT)
	await get_tree().physics_frame
	r["Rayo Solar: primero carga, marcando la línea"] = me.machine.current_name() == "cast" and me.telegraph.shape == Telegraph.Shape.LINE
	await get_tree().create_timer(solar.cast_time * 0.8).timeout
	r["Rayo Solar: mientras carga no pega"] = is_equal_approx(near.instance.hp, hp[0]) and is_equal_approx(far.instance.hp, hp[1])
	await _until(func(): return near.instance.hp < hp[0], 1.0)
	var t0 := Time.get_ticks_msec()
	await _until(func(): return far.instance.hp < hp[1], 0.5)
	r["Rayo Solar: pega a los dos de la línea casi a la vez (%d ms)" % (Time.get_ticks_msec() - t0)] = far.instance.hp < hp[1] and Time.get_ticks_msec() - t0 < 60
	r["Rayo Solar: no es un proyectil"] = not me.get_parent().get_children().any(func(c): return c is Projectile)
	r["Rayo Solar: al de costado no"] = is_equal_approx(side.instance.hp, hp[2])
	for c in [near, far, side]:
		c.queue_free()
	await _until(func(): return me.machine.current_name() == me.default_state(), 2.0)
	# Una pared lo corta: un rayo hacia abajo desde una celda libre al lado de algo sólido.
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var ws := CollisionShape2D.new()
	ws.shape = RectangleShape2D.new()
	ws.shape.size = Vector2(16, 60)
	wall.add_child(ws)
	wall.global_position = from + Vector2(80, 0)
	world.entities.add_child(wall)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var len := BeamStrike.reach_from(me, from, Vector2.RIGHT, solar.beam_length)
	r["Rayo Solar: una pared lo corta (%.0f px)" % len] = len < 80.0 and len > 60.0
	wall.queue_free()
	r["Rayo Solar: la explicación lo cuenta"] = "rayo instantáneo" in MoveInfo.what_it_does(solar)


func showcase_solar() -> void:
	world = await autotest._setup_kit_world("bulbasaur")
	var me: Creature = world.companion
	me.instance.level = 50
	var finder := BalanceTests.new()
	finder.world = world
	me.global_position = finder._open_spot() + Vector2(-80, 0)
	finder.free()
	world.trainer.global_position = me.global_position + Vector2(70, -50)
	var foe: Creature = autotest._dummy(world, "snorlax", me.global_position + Vector2(110, 0))
	var foe2: Creature = autotest._dummy(world, "snorlax", me.global_position + Vector2(170, 4))
	world.get_node("UI").visible = false
	for i in 3:
		me.moves.slots[1] = DB.moves["rayo_solar"]
		me.moves.reset_cooldown(1)
		me.moves.set_pp(me.moves.max_pp())
		foe.health.heal(9999.0)
		foe2.health.heal(9999.0)
		print("[showcase] rayo solar cuadro ", Engine.get_frames_drawn())
		me.use_slot(1, Vector2.RIGHT)
		await get_tree().create_timer(2.2).timeout
	get_tree().quit()


func showcase_surf() -> void:
	world = await autotest._setup_kit_world("squirtle")
	var me: Creature = world.companion
	me.instance.level = 50
	var foe: Creature = autotest._dummy(world, "snorlax", me.global_position + Vector2(100, 0))
	world.get_node("UI").visible = false
	for i in 3:
		me.moves.slots[1] = DB.moves["surf"]
		me.moves.reset_cooldown(1)
		me.moves.set_pp(me.moves.max_pp())
		foe.health.heal(9999.0)
		print("[showcase] surf cuadro ", Engine.get_frames_drawn())
		me.use_slot(1, (foe.global_position - me.global_position).normalized(), foe.global_position)
		await get_tree().create_timer(2.0).timeout
		me.global_position = foe.global_position + Vector2(-100, 0)
	get_tree().quit()


func _strike() -> SkyStrike:
	for n in world.companion.get_parent().get_children():
		if n is SkyStrike:
			return n
	return null


func _cone(me: Creature) -> ChannelCone:
	for n in me.get_children():
		if n is ChannelCone:
			return n
	return null


func _until(cond: Callable, seconds: float) -> void:
	var left := seconds
	while left > 0.0 and not cond.call():
		await get_tree().physics_frame
		left -= get_physics_process_delta_time()
