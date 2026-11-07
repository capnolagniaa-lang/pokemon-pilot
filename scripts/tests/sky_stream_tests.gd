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
