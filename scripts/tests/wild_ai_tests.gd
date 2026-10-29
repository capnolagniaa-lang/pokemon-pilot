class_name WildAiTests
extends Node
## Autotest de la IA de los salvajes (temperamentos + cuerpo compartido):
##   godot --headless --path . --quit-after 30000 -- --autotest-wild-ai

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await get_tree().physics_frame
	# 4 de salvajes + "entrenador" (el de los Pokémon de un entrenador en la arena, E-1; no se asigna a especies).
	r["4 temperamentos de salvajes asignados a las 386"] = DB.temperaments.keys().filter(func(k): return k != "entrenador").size() == 4 \
		and DB.species.values().all(func(sp): return sp.temperament != null and sp.temperament.id != "entrenador")
	var me: Creature = world.companion

	# --- Agresivo: te ataca apenas te ve, y abre con su ataque de acercamiento ---
	var used: Array = []
	var log_moves := func(u, m): if u is Creature and u.team == Creature.Team.WILD: used.append(m)
	Events.move_used.connect(log_moves)
	var rat := _spawn("rattata", "agresivo", me.global_position + Vector2(90, 0))
	await get_tree().create_timer(1.6).timeout
	r["Agresivo: te ve y pelea (entra en combate)"] = rat.target == me and world.combat.in_battle
	r["Agresivo: abre con su ataque de acercamiento (Ataque Rápido)"] = not used.is_empty() and used[0].kind == MoveData.Kind.DASH
	Events.move_used.disconnect(log_moves)
	_clear(rat)
	await get_tree().create_timer(2.0).timeout

	# --- Territorial: no le importa si estás afuera; si entrás a su zona, pelea ---
	var guard := _spawn("bellsprout", "territorial", me.global_position + Vector2(85, 0))
	await get_tree().create_timer(1.2).timeout
	r["Territorial: te ve afuera de su zona y no ataca"] = guard.target == null
	_move_party(guard.global_position + Vector2(-30, 0))
	await get_tree().create_timer(1.2).timeout
	r["Territorial: si entrás a su zona, pelea"] = guard.target == me
	guard.last_exchange = -100.0  # salís sin haber peleado (si ya hubo golpes, no te suelta: ver más abajo)
	_move_party(guard.home + Vector2(-260, 0))
	await get_tree().create_timer(2.5).timeout
	r["Territorial: si salís de su zona, te deja ir"] = guard.target == null
	_move_party(guard.home + Vector2(-30, 0))
	await get_tree().create_timer(1.0).timeout
	r["Territorial: después de soltarte no te vuelve a agarrar enseguida"] = guard.target == null
	_clear(guard)
	await get_tree().create_timer(2.0).timeout

	# Huir con F adentro de su territorio: no te vuelve a desafiar al instante (Creature.CALM_AFTER_FLEE).
	var held_guard := _spawn("bellsprout", "territorial", me.global_position + Vector2(40, 0))
	await get_tree().create_timer(1.2).timeout
	var fought: bool = held_guard.target == me and world.combat.in_battle
	world.combat.end_battle()
	await get_tree().create_timer(3.0).timeout
	r["Territorial: huís con F en su zona y no te desafía enseguida"] = fought and held_guard.target == null 		and not world.combat.in_battle
	await get_tree().create_timer(Creature.CALM_AFTER_FLEE).timeout
	r["Territorial: pasado el respiro, si seguís en su zona vuelve a pelear"] = held_guard.target == me
	_clear(held_guard)
	await get_tree().create_timer(2.0).timeout

	# Peleando (hubo golpes) no suelta aunque tu Pokémon salga de su zona: antes cortaba el combate a cada rato.
	var fighter := _spawn("bellsprout", "territorial", me.global_position + Vector2(50, 0))
	await get_tree().physics_frame
	fighter.hurtbox.receive(HitInfo.from(me, me.moves.slots[0]))
	await get_tree().create_timer(0.3).timeout
	_move_party(fighter.home + Vector2(-150, 0))
	var held := true
	for k in 12:
		await get_tree().create_timer(0.15).timeout
		held = held and fighter.target == me and world.combat.in_battle
		if k % 4 == 0:
			fighter.hurtbox.receive(HitInfo.from(me, me.moves.slots[0]))  # siguen peleando
	r["Territorial peleando: no suelta aunque salgas de su zona (no corta el combate)"] = held
	_clear(fighter)
	await get_tree().create_timer(2.0).timeout

	# --- Tímido: huye sin pelear; si le pegás, pelea ---
	var shy := _spawn("pidgey", "timido", me.global_position + Vector2(70, 0))
	var d0 := shy.global_position.distance_to(me.global_position)
	await get_tree().create_timer(1.0).timeout
	r["Tímido: huye sin entrar en combate"] = shy.machine.current_name() == "flee" and shy.target == null \
		and shy.global_position.distance_to(me.global_position) > d0 + 10.0
	var hit := HitInfo.from(me, me.moves.slots[0])
	shy.hurtbox.receive(hit)
	await get_tree().physics_frame
	r["Tímido: si le pegás, pelea"] = shy.target == me
	_clear(shy)
	await get_tree().create_timer(2.0).timeout

	# --- Curioso: se acerca a mirar; si te le venís encima, se pone nervioso ---
	var nosy := _spawn("vulpix", "curioso", me.global_position + Vector2(115, 0))
	await get_tree().create_timer(2.0).timeout
	var dn := nosy.global_position.distance_to(me.global_position)
	r["Curioso: se acerca a mirarte (sin atacar)"] = nosy.machine.current_name() == "watch" and nosy.target == null and dn < 90.0
	_move_party(nosy.global_position + Vector2(-12, 0))
	await get_tree().create_timer(0.6).timeout
	r["Curioso: si te le venís encima, ataca o huye"] = nosy.machine.current_name() in ["chase", "attack", "flee", "cast", "dash", "lunge", "recovery"]
	_clear(nosy)
	await get_tree().create_timer(2.0).timeout

	# --- Reacciones: golpe fuerte lo espanta; sale de lo electrificado ---
	var scared := _spawn("rattata", "agresivo", me.global_position + Vector2(200, 60))
	scared.temperament = scared.temperament.duplicate()
	scared.temperament.spook_chance = 1.0
	scared.target = me
	var strong := HitInfo.from(me, me.moves.slots[0])
	strong.knockback = 260.0
	scared.hurtbox.receive(strong)
	r["Golpe fuerte: se espanta"] = scared.spook_left > 0.0
	_clear(scared)
	# Donde estaba tu Pokémon (seguro es caminable); el equipo se corre a un costado.
	var spot: Vector2 = me.global_position
	_move_party(spot + Vector2(0, -70))
	var wet := _spawn("rattata", "territorial", spot)
	wet.get_node("StateMachine/Wander").aggro_radius = 0.0
	await get_tree().physics_frame
	var g: EnvironmentGrid = world.reactions.grid_at(wet.global_position)
	var cell: Vector2i = g.zone.cell_at(wet.global_position)
	g.set_state(cell, DB.env_states["electrificado"])
	var left_cell := false
	for k in 10:
		await get_tree().create_timer(0.15).timeout
		left_cell = left_cell or g.zone.cell_at(wet.global_position) != cell
	r["Sale de una celda peligrosa (electrificada)"] = left_cell
	_clear(wet)

	# --- Una pelea de verdad (bot) con cada temperamento: el combate no se corta mientras pelean ---
	for temper in ["territorial", "curioso", "timido", "agresivo"]:
		for dist in [40.0, 110.0]:
			var cuts := await _real_fight("bellsprout", temper, dist)
			r["Pelea real con un %s a %d px: no se corta" % [temper, dist]] = cuts == 0
			print("[wild-ai] pelea con ", temper, " a ", dist, ": cortes=", cuts)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[wild-ai] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-wild-ai] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina (--write-movie ... -- --showcase-wild-ai): un salvaje de cada temperamento alrededor tuyo.
func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	var me: Creature = world.companion
	await get_tree().create_timer(0.3).timeout
	_spawn("rattata", "agresivo", me.global_position + Vector2(100, -10))
	_spawn("pidgey", "timido", me.global_position + Vector2(-80, 20))
	_spawn("vulpix", "curioso", me.global_position + Vector2(0, 110))
	_spawn("bellsprout", "territorial", me.global_position + Vector2(-60, -80))
	await get_tree().create_timer(5.0).timeout
	get_tree().quit()


## Pelea manejada por el bot (como --autotest-combat) contra un salvaje con su temperamento. Cuenta cuántas veces
## el combate terminó mientras el salvaje seguía en pie y sin haber huido con poca vida (un "corte").
func _real_fight(species_id: String, temper: String, keep: float) -> int:
	world.combat.end_battle()
	var me: Creature = world.companion
	me.instance.hp = me.instance.max_hp()
	var bot := BotCombatInput.new(world)
	bot.keep_distance = keep
	world.combat.input_source = bot
	var wild := _spawn(species_id, temper, me.global_position + Vector2(40, 0))
	wild.instance.level = me.instance.level
	wild.instance.hp = wild.instance.max_hp()
	var cuts := 0
	var on_end := func():
		if is_instance_valid(wild) and not wild.health.is_dead() and wild.health.ratio() > wild.temperament.flee_below:
			cuts += 1
	Events.battle_ended.connect(on_end)
	# Si no lo nota solo (tímido/curioso), le pegamos para empezar.
	await get_tree().create_timer(0.3).timeout
	if not world.combat.in_battle:
		wild.hurtbox.receive(HitInfo.from(me, me.moves.slots[0]))
	var t := 0.0
	while t < 14.0 and is_instance_valid(wild) and not wild.health.is_dead():
		await get_tree().process_frame
		t += get_process_delta_time()
		if not world.combat.in_battle and is_instance_valid(wild) and wild.target == null:
			if cuts > 0:
				break  # se cortó (ya contado)
			wild.hurtbox.receive(HitInfo.from(me, me.moves.slots[0]))  # huyó: lo volvemos a buscar
	Events.battle_ended.disconnect(on_end)
	world.combat.input_source = CombatInput.new()
	_clear(wild)
	await get_tree().create_timer(0.5).timeout
	return cuts


func _spawn(species_id: String, temper: String, pos: Vector2) -> Creature:
	var c: Creature = world.spawner.spawn(DB.species[species_id], 8, pos)
	c.temperament = DB.temperaments[temper]
	return c


## Mueve al entrenador y a tu Pokémon juntos (el Pokémon queda quieto al lado).
func _move_party(pos: Vector2) -> void:
	world.trainer.global_position = pos + Vector2(-14, 0)
	world.companion.global_position = pos


func _clear(c: Creature) -> void:
	if is_instance_valid(c):
		c.queue_free()
	world.combat.end_battle()
	_move_party(world.trainer.global_position + Vector2(14, 0))
