class_name AiMindTests
extends Node
## Mente táctica de la IA (docs/PLAN_IA.md): elegir ataque por situación, tipos, reacción humana y aviso.
##   godot --headless --path . --quit-after 30000 -- --autotest-ai-mind

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	world = await autotest._setup_kit_world("squirtle")
	var me: Creature = world.companion
	var base := me.global_position
	var hard: AiDifficulty = DB.difficulties["dificil"]
	var easy: AiDifficulty = DB.difficulties["facil"]
	r["Las dificultades traen smarts/reacción/aviso (Fácil más lento y tonto)"] = easy.smarts < hard.smarts \
		and easy.reaction > hard.reaction and easy.telegraph > hard.telegraph

	# --- Elegir ataque: Charmander contra Bulbasaur (Ascuas súper efectiva y con STAB vs. Placaje) ---
	GameState.difficulty = hard
	var ai: Creature = autotest._dummy(world, "charmander", base + Vector2(-200, 0))
	var grass: Creature = autotest._dummy(world, "bulbasaur", base + Vector2(-180, 0))
	await get_tree().physics_frame
	await get_tree().physics_frame
	ai.target = grass
	_set_moves(ai, ["placaje", "ascuas"])
	var picks := _count_picks(ai, 20.0, 100)
	r["Difícil elige casi siempre el súper efectivo con STAB (%s)" % str(picks)] = picks.get(1, 0) >= 95
	GameState.difficulty = easy
	picks = _count_picks(ai, 20.0, 300)
	r["Fácil piensa menos: a veces elige el otro (%s)" % str(picks)] = picks.get(0, 0) >= 20 and picks.get(1, 0) > picks.get(0, 0)
	GameState.difficulty = hard

	# Inmune: Placaje contra un Fantasma no vale nada.
	var ghost: Creature = autotest._dummy(world, "gastly", base + Vector2(-180, 30))
	await get_tree().physics_frame
	ai.target = ghost
	r["Contra un inmune ni lo intenta"] = ai.mind.score(0, 20.0, true) == 0.0 and ai.mind.score(1, 20.0, true) > 0.0
	ai.target = grass

	# Vulnerable: en stagger vale más pegarle (promedio, el puntaje tiene ±15 %).
	var calm := _avg_score(ai, 1)
	grass.hitstun_left = 5.0
	var exposed := _avg_score(ai, 1)
	grass.hitstun_left = 0.0
	r["Si estás en stagger, más ganas de pegarte (%.0f → %.0f)" % [calm, exposed]] = exposed > calm * 1.25
	# No repite siempre lo mismo.
	ai.mind.last_slot = 1
	var repeated := _avg_score(ai, 1)
	ai.mind.last_slot = -1
	r["Repetir el último vale menos"] = repeated < calm * 0.8

	# --- Cruce de tipos ---
	var water: Creature = autotest._dummy(world, "squirtle", base + Vector2(-200, 60))
	var fire: Creature = autotest._dummy(world, "charmander", base + Vector2(-170, 60))
	await get_tree().physics_frame
	_set_moves(water, ["pistola_agua", "placaje"])
	_set_moves(fire, ["ascuas", "placaje"])
	water.target = fire
	fire.target = water
	r["El de Agua presiona al de Fuego"] = water.mind.matchup() == "presiona"
	r["El de Fuego se cuida del de Agua"] = fire.mind.matchup() == "cuidate"
	r["Charmander presiona a Bulbasaur; sin rival, nada"] = ai.mind.matchup() == "presiona" and grass.mind.matchup() == ""
	for c in [water, fire, ghost]:
		c.queue_free()

	# --- Reacción: esquiva recién pasado su tiempo de reacción ---
	var custom := AiDifficulty.new()
	custom.dodge_chance = 1.0
	custom.reaction = 0.25
	GameState.difficulty = custom
	var dodger: Creature = autotest._dummy(world, "rattata", base + Vector2(0, -150))
	var shooter: Creature = me  # (tiene que ser del otro equipo: tu Pokémon)
	me.global_position = base + Vector2(190, -150)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_set_moves(shooter, ["pistola_agua"])
	shooter.use_slot(0, Vector2.LEFT)
	await get_tree().physics_frame
	var seen_at := -1.0
	var dodged_at := -1.0
	var t := 0.0
	while t < 1.5 and dodged_at < 0.0:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if dodger.body.try_dodge():
			dodged_at = t
		if seen_at < 0.0 and not dodger.body._checked.is_empty():
			seen_at = t
	var waited := dodged_at - seen_at
	r["Ve el disparo y esquiva después de reaccionar (%.2f s)" % waited] = seen_at >= 0.0 and dodged_at > 0.0 \
		and waited >= 0.25 * 0.7 - 0.02
	dodger.queue_free()

	# --- Aviso: un ataque fuerte sin carga brilla y se frena antes de salir ---
	GameState.difficulty = hard
	var brute: Creature = autotest._dummy(world, "charmander", base + Vector2(0, 150), false)
	var dummy: Creature = autotest._dummy(world, "bulbasaur", base + Vector2(18, 150))
	await get_tree().physics_frame
	await get_tree().physics_frame
	_set_moves(brute, ["cuchillada"])
	brute.target = dummy
	var used := []
	Events.move_used.connect(func(c, m): if c == brute: used.append(m.id))
	brute.machine.transition_to("attack")
	var told_before_use := false
	t = 0.0
	while t < 4.0 and used.is_empty():
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if brute.sprite.tell_left > 0.0 and used.is_empty():
			told_before_use = true
	r["Cuchillada (70, sin carga) brilla antes de salir"] = TacticalMind.needs_tell(DB.moves["cuchillada"]) and told_before_use and not used.is_empty()
	r["Placaje (40) no se avisa; los que cargan tampoco (ya se marcan en el suelo)"] = not TacticalMind.needs_tell(DB.moves["placaje"]) \
		and not TacticalMind.needs_tell(DB.moves["lanzallamas"]) or DB.moves["lanzallamas"].cast_time <= 0.0

	var ok := r.values().all(func(v): return v)
	for k in r:
		print("[ia] %s %s" % ["OK   " if r[k] else "FALLO", k])
	print("[autotest-ai-mind] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _set_moves(c: Creature, ids: Array) -> void:
	for i in MoveUser.SLOT_COUNT:
		c.moves.slots[i] = DB.moves[ids[i]] if i < ids.size() else null
		c.moves.cooldowns[i] = 0.0


func _count_picks(c: Creature, dist: float, n: int) -> Dictionary:
	var out := {}
	for i in n:
		var s: int = c.mind.pick(dist)
		out[s] = out.get(s, 0) + 1
	return out


func _avg_score(c: Creature, slot: int) -> float:
	var total := 0.0
	for i in 200:
		total += c.mind.score(slot, 20.0, true)
	return total / 200.0
