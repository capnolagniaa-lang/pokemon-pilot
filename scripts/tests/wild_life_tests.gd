class_name WildLifeTests
extends Node
## Salvajes vivos (docs/PLAN_IA.md, IA-5): día y noche, despertarlos, respeto, manadas, rodear, cazador y presa, curiosidad.
##   godot --headless --path . --quit-after 60000 -- --autotest-wild-life

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	r["Nocturnos, diurnos y los que les da igual"] = WildSociety.activity(DB.species["gastly"]) == "noche" \
		and WildSociety.activity(DB.species["zubat"]) == "noche" and WildSociety.activity(DB.species["pidgey"]) == "dia" \
		and WildSociety.activity(DB.species["rattata"]) == ""
	r["Gastly duerme al mediodía (no en una cueva) y Pidgey de noche"] = WildSociety.sleepy(DB.species["gastly"], 12.0, false) \
		and not WildSociety.sleepy(DB.species["gastly"], 12.0, true) and not WildSociety.sleepy(DB.species["gastly"], 23.0, false) \
		and WildSociety.sleepy(DB.species["pidgey"], 23.0, false) and not WildSociety.sleepy(DB.species["pidgey"], 12.0, false)

	world = await autotest._setup_kit_world("squirtle")
	var me: Creature = world.companion
	me.machine.set_physics_process(false)
	var base := me.global_position
	var far := base + Vector2(0, -260)

	# --- Dormido: se despierta si pasás al lado ---
	var ghost: Creature = world.spawner.spawn(DB.species["gastly"], 12, far)
	await get_tree().physics_frame
	WildSociety.nap(ghost)
	await get_tree().physics_frame
	r["Se echa a dormir (Dormido)"] = ghost.napping and ghost.statuses.has_status("dormido")
	await get_tree().create_timer(0.5).timeout
	r["Dormido no reacciona aunque estés cerca de su radio"] = ghost.napping and not is_instance_valid(ghost.target)
	me.global_position = ghost.global_position + Vector2(14, 0)
	await _until(func(): return not ghost.napping, 8.0)
	r["Pasando al lado lo despertás (%s)" % ghost.machine.current_name()] = not ghost.napping \
		and not ghost.statuses.has_status("dormido") and ghost.machine.current_name() in ["flee", "chase", "attack"]
	ghost.queue_free()
	me.global_position = base
	world.combat.end_battle(true)
	await get_tree().physics_frame

	# A los golpes: los no tímidos salen enfurecidos.
	var grump: Creature = world.spawner.spawn(DB.species["rattata"], 8, far)
	await get_tree().physics_frame
	grump.temperament = DB.temperaments["agresivo"]
	WildSociety.nap(grump)
	WildSociety.wake(grump, me)
	r["Despertado a los golpes: enfurecido y te ataca"] = not grump.napping and grump.statuses.has_status("enfurecido") \
		and grump.target == me
	grump.queue_free()
	world.combat.end_battle(true)

	# Llega su hora: se despierta solo, tranquilo.
	var owl: Creature = world.spawner.spawn(DB.species["gastly"], 12, far)
	await get_tree().physics_frame
	WildSociety.nap(owl)
	world.spawner._alive["_test"] = [owl]
	world.spawner._on_time_changed(22.0, "noche")
	r["A la noche el nocturno se despierta solo (sin pelear)"] = not owl.napping and not is_instance_valid(owl.target)
	world.spawner._alive.erase("_test")
	owl.queue_free()

	# --- Respeto: tu Pokémon le lleva 10 niveles o más ---
	var lvl := me.instance.level
	me.instance.level = 60
	var weak: Creature = world.spawner.spawn(DB.species["rattata"], 5, base + Vector2(60, 0))
	await get_tree().physics_frame
	weak.temperament = DB.temperaments["agresivo"]
	var seen_flee := [false]
	weak.machine.state_changed.connect(func(_a, b): if b == "flee": seen_flee[0] = true)
	await _until(func(): return seen_flee[0] or is_instance_valid(weak.target), 3.0)
	r["Un agresivo chiquito no te ataca: se va"] = seen_flee[0] and not is_instance_valid(weak.target)
	weak.queue_free()
	me.instance.level = lvl
	world.combat.end_battle(true)
	await get_tree().physics_frame

	# --- Manada: atacás a una cría y viene el grande enfurecido ---
	var cub: Creature = world.spawner.spawn(DB.species["rattata"], 4, far)
	var mom: Creature = world.spawner.spawn(DB.species["raticate"], 22, far + Vector2(40, 0))
	await get_tree().physics_frame
	for c in [cub, mom]:
		c.temperament = DB.temperaments["agresivo"]
	cub.target = me
	Events.wild_aggro.emit(cub, me)
	await get_tree().physics_frame
	r["Los de la misma familia se suman a la pelea"] = mom.target == me and mom.machine.current_name() in ["chase", "attack"]
	r["...y el grande defiende a su cría enfurecido"] = mom.statuses.has_status("enfurecido")
	# Rodear: el segundo va del otro lado.
	cub.global_position = base + Vector2(-40, 0)
	mom.global_position = base + Vector2(-30, 10)
	var later: Creature = cub if cub.get_instance_id() > mom.get_instance_id() else mom
	var first: Creature = mom if later == cub else cub
	var flank: Vector2 = later.mind.flank_point(30.0)
	r["En manada te rodean (el segundo va del otro lado)"] = flank != Vector2.INF \
		and (flank - me.global_position).dot(me.global_position - first.global_position) > 0.0 \
		and first.mind.flank_point(30.0) == Vector2.INF
	cub.queue_free()
	mom.queue_free()
	world.combat.end_battle(true)
	await get_tree().physics_frame

	# --- Cazador y presa (no se pegan) ---
	var snake: Creature = world.spawner.spawn(DB.species["ekans"], 12, far + Vector2(-30, 0))
	var mouse: Creature = world.spawner.spawn(DB.species["rattata"], 5, far + Vector2(20, 0))
	await get_tree().physics_frame
	r["Ekans caza Rattata (y no al revés)"] = WildSociety.preys_on(snake, mouse) and not WildSociety.preys_on(mouse, snake)
	var states := {}
	snake.machine.state_changed.connect(func(_a, b): states["snake_" + b] = true)
	mouse.machine.state_changed.connect(func(_a, b): states["mouse_" + b] = true)
	await _until(func(): return states.has("mouse_flee") or states.has("snake_hunt"), 6.0)
	r["La presa huye del cazador o el cazador sale a cazar (%s)" % str(states.keys())] = states.has("mouse_flee") or states.has("snake_hunt")
	r["...sin pelearse (ni pelea con vos)"] = not is_instance_valid(snake.target) and not is_instance_valid(mouse.target) \
		and snake.instance.hp == snake.instance.max_hp() and mouse.instance.hp == mouse.instance.max_hp()
	snake.queue_free()
	mouse.queue_free()

	# --- Curiosidad: un curioso va a mirar una Pokébola tirada ---
	var nosy: Creature = world.spawner.spawn(DB.species["pikachu"], 8, far)
	await get_tree().physics_frame
	nosy.temperament = DB.temperaments["curioso"]
	var ball := FieldItem.new()
	ball.item = DB.items["poke_ball"] if DB.items.has("poke_ball") else DB.items.values()[0]
	ball.thrown = true
	world.entities.add_child(ball)
	ball.global_position = far + Vector2(40, 0)
	var watched := [false]
	nosy.machine.state_changed.connect(func(_a, b): if b == "watch": watched[0] = true)
	await _until(func(): return watched[0], 4.0)
	await get_tree().create_timer(1.5).timeout
	r["Un curioso se acerca a mirar la Pokébola tirada"] = watched[0] and nosy.global_position.distance_to(ball.global_position) < 30.0
	nosy.queue_free()
	ball.queue_free()

	var ok := r.values().all(func(v): return v)
	for k in r:
		print("[salvajes-vivos] %s %s" % ["OK   " if r[k] else "FALLO", k])
	print("[autotest-wild-life] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
