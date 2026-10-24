class_name ArenaRulesTests
extends Node
## Autotest del combate de arena (docs/PLAN_IDENTIDAD_COMBATE.md "Combate de arena"): estilos de movimiento,
## combos, superficies y cráteres; por ahora solo rigen en las arenas.
##   godot --headless --path . --quit-after 100000 -- --autotest-arena-rules
## Vitrina (Onix contra Geodude en el estadio, cráteres): godot --path . --quit-after 600 --write-movie out/f.png --fixed-fps 30 -- --showcase-arena-rules

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	var kits := DB.species.values().filter(func(s): return s.kit != null)
	r["Cada Pokémon con kit tiene su estilo de arena (%d)" % DB.fight_styles.size()] = kits.all(func(s): return DB.fight_styles.has(s.id))
	var bad := []
	for st: FightStyle in DB.fight_styles.values():
		var ids: Array = DB.species[st.species_id].kit.moves.map(func(m): return m.id)
		for c in st.combos:
			if not (c.first in ids and c.second in ids):
				bad.append("%s: %s" % [st.species_id, c.display_name])
	r["Los combos usan ataques de su kit %s" % str(bad)] = bad.is_empty()

	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.active().level = 30
	GameState.active().hp = GameState.active().max_hp()
	_dialogs()
	var me: Creature = world.companion
	r["En el mundo abierto no rigen las reglas de arena"] = not me.arena_rules()

	var foe_team: Array[CreatureInstance] = [CreatureInstance.create(DB.species["onix"], 20)]
	world.arena.start({"name": "Prueba", "team": foe_team, "arena_id": "arena_torneo", "no_blackout": true})
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	me = world.companion
	var foe: Creature = world.arena.foe
	r["En la arena rigen las reglas de arena"] = me.arena_rules() and foe.arena_rules()
	foe.machine.set_physics_process(false)

	# --- Cráteres: un golpe fuerte contra el suelo deja un pozo que frena ---
	var normal_speed := me.speed()
	Events.ground_impact.emit(me.global_position, 24.0, "prueba", 3)
	await get_tree().physics_frame
	var st: EnvCellState = world.reactions.state_at(me.global_position)
	r["Un golpe contra el suelo deja un cráter"] = st != null and st.id == "crater"
	r["El cráter frena"] = me.speed() < normal_speed * 0.8
	r["Excavar y Tumba Rocas de Onix dejan cráteres"] = DB.all_moves.values().filter(
		func(m): return m.id in ["excavar_onix", "tumba_rocas_onix"] and m.crater_radius > 0.0).size() == 2

	# --- Cadena de golpes y combo con nombre (Charmander: Arañazo → Ascuas = Garra Ardiente) ---
	var scratch := HitInfo.from(me, me.moves.slots[1])
	var embers := HitInfo.from(me, me.moves.slots[0])
	var c1 := me.register_hit(foe, scratch)
	var c2 := me.register_hit(foe, embers)
	r["Arañazo y enseguida Ascuas = combo Garra Ardiente"] = c1["name"] == "" and c2["name"] == "Garra Ardiente" \
		and c2["mult"] >= 1.4 and c2["status"] != null and c2["status"].id == "quemado"
	var c3 := me.register_hit(foe, embers)
	r["La cadena de golpes suma daño (×3 = +10%)"] = c3["chain"] == 3 and absf(c3["mult"] - 1.10) < 0.001
	await get_tree().create_timer(Creature.CHAIN_WINDOW + 0.2).timeout
	r["Si pasa mucho tiempo la cadena se corta"] = me.register_hit(foe, embers)["chain"] == 1

	# --- Estilos de movimiento ---
	foe.velocity = Vector2.ZERO
	foe._move_vel = Vector2.ZERO
	foe.move(Vector2.RIGHT, 100.0)
	r["Onix es pesado: arranca de a poco (inercia)"] = foe.move_style() == "pesado" and foe._move_vel.length() < 20.0
	me._move_vel = Vector2.ZERO
	me.move(Vector2.RIGHT, 100.0)
	r["Charmander (normal) arranca al toque"] = me._move_vel.length() > 99.0
	var pika := Creature.new()
	pika.fight_style = DB.fight_styles["pikachu"]
	r["Pikachu es ágil y Pidgey volador"] = pika.move_style() == "agil" and DB.fight_styles["pidgey"].move_style == "volador"
	pika.free()

	# --- Salto de cráter con el esquive (Charmander sí, Onix no) ---
	await get_tree().create_timer(0.5).timeout
	me = world.companion
	me.moves.dodge_cooldown = 0.0
	var grid: EnvironmentGrid = world.reactions.grid_at(me.global_position)
	for cell in grid.cells.keys():  # sin los cráteres de antes
		grid.set_state(cell, null)
	r["Sin cráter adelante el esquive es el de siempre"] = me.crater_jump_target(Vector2.LEFT) == Vector2.INF
	var start := me.global_position
	Events.ground_impact.emit(start + Vector2(44, 0), 22.0, "prueba_salto", 3)
	await get_tree().physics_frame
	var land := me.crater_jump_target(Vector2.RIGHT)
	r["Hay un salto hasta la otra punta del cráter"] = land != Vector2.INF and land.x > start.x + 60.0 		and not world.tags_at(land).has("crater")
	r["Onix (pesado, sin patas) no salta cráteres"] = foe.crater_jump_target(Vector2.LEFT) == Vector2.INF
	var jumped := me.dodge(Vector2.ZERO, Vector2.RIGHT * 50.0)
	await get_tree().create_timer(0.1).timeout
	var mid_lift: float = me.sprite.lift
	await get_tree().create_timer(0.6).timeout
	r["Charmander salta el cráter por el aire (Espacio, hacia donde apunta)"] = jumped and mid_lift > 2.0 		and me.global_position.x > start.x + 55.0 and not world.tags_at(me.global_position).has("crater")

	# --- Tope de cráteres: por ataque y por cancha ---
	var g2: EnvironmentGrid = world.reactions.grid_at(me.global_position)
	for cell in g2.cells.keys():
		g2.set_state(cell, null)
	var base := me.global_position + Vector2(-60, 60)
	for k in 5:  # el mismo ataque 5 veces, tope 2
		Events.ground_impact.emit(base + Vector2(k * 40, 0), 8.0, "tope", 2)
	var alive := 0
	for k in 5:
		var st2: EnvCellState = world.reactions.state_at(base + Vector2(k * 40, 0))
		if st2 != null and st2.id == "crater":
			alive += 1
	r["Cada ataque deja como mucho su tope de cráteres (se borra el más viejo)"] = alive == 2 		and world.reactions.state_at(base + Vector2(160, 0)) != null
	for k in 30:  # muchos ataques distintos: la cancha nunca se llena
		Events.ground_impact.emit(base + Vector2((k % 6) * 32, -(k / 6) * 32), 24.0, "otro_%d" % k, 3)
	var cells := g2.cells.values().filter(func(e): return e["state"].id == "crater").size()
	r["La cancha tiene un tope total de cráteres (%d celdas)" % cells] = cells <= ReactionSystem.CRATER_CELLS_MAX

	foe.health.apply_damage(99999.0)
	await _until(func(): return not world.arena.active, 15.0)
	r["Al salir de la arena dejan de regir"] = not world.companion.arena_rules()

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[arena-reglas] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-arena-rules] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _dialogs() -> void:
	while is_inside_tree():
		await get_tree().create_timer(0.12).timeout
		var d: DialogBox = world.story.dialog
		if d.active:
			if d._choosing:
				d.choose(0)
			else:
				d.advance()


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func showcase() -> void:
	world = await autotest._setup_kit_world("geodude")
	world.combat.end_battle()
	GameState.active().level = 20
	GameState.active().hp = GameState.active().max_hp()
	_dialogs()
	var foe_team: Array[CreatureInstance] = [CreatureInstance.create(DB.species["onix"], 20)]
	world.arena.start({"name": "Brock", "title": "Líder", "team": foe_team, "arena_id": "arena_torneo", "leader": true,
		"banner": "EXHIBICIÓN", "texture": load("res://art/pret/characters/brock.png"), "no_blackout": true})
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	world.combat.input_source = BotCombatInput.new(world)
	world.companion.input_source = world.combat.input_source
	await get_tree().create_timer(14.0).timeout
	get_tree().quit()
