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
		and (DB.moves["lanzallamas"].cast_time <= 0.0 or not TacticalMind.needs_tell(DB.moves["lanzallamas"]))

	# --- IA-2: memoria corta ---
	# Finta: con feint_chance 1, el ataque avisado no sale (amaga) y vuelve a intentar enseguida.
	var feinty := AiDifficulty.new()
	feinty.feint_chance = 1.0
	feinty.telegraph = 0.1
	GameState.difficulty = feinty
	brute.mind.feints = 0
	used.clear()
	t = 0.0
	while t < 2.0 and brute.mind.feints < 2:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	r["Finta: amaga el ataque fuerte y no lo suelta (%d fintas)" % brute.mind.feints] = brute.mind.feints >= 2 and used.is_empty()
	brute.machine.transition_to("idle")
	GameState.difficulty = hard

	# Te lee el esquive: 4 esquives a la derecha de la línea entre los dos → apunta corrido hacia ese lado.
	var reader: Creature = autotest._dummy(world, "squirtle", base + Vector2(-120, -60))
	var foe: Creature = autotest._dummy(world, "rattata", base + Vector2(-40, -60))
	await get_tree().physics_frame
	await get_tree().physics_frame
	reader.target = foe
	reader.mind.observe()
	var side_dir := Vector2(0, 1)  # (la línea va hacia la derecha: esquivar hacia abajo es siempre el mismo lado)
	for i in 4:
		foe.moves.dodge_cooldown = 0.0
		foe.dodge(side_dir)
		foe.machine.transition_to("idle")
		await get_tree().physics_frame
	var read: Array = reader.mind.dodge_read()
	r["Recuerda hacia qué lado esquivás (%s)" % str(read)] = read[0] != 0 and read[1] >= 0.75
	var off: Vector2 = foe.global_position - reader.global_position
	var shifted := 0
	var toward := 0
	for i in 200:
		var o: Vector2 = reader.mind.aim_read(off)
		if o != Vector2.ZERO:
			shifted += 1
			if o.normalized().dot(side_dir) > 0.9:
				toward += 1
	r["Y te apunta a ese lado (a veces: %d de 200)" % shifted] = shifted > 40 and shifted < 200 and toward == shifted
	# Si peleás de lejos esquiva más; de cerca, te mantiene a raya.
	for i in 5:
		foe.move_released.emit(DB.moves["pistola_agua"])
	r["Se da cuenta de que peleás de lejos (esquiva más)"] = reader.mind.foe_style() == "lejos" and reader.mind.dodge_bonus() > 0.0
	# Al cambiar de rival se olvida de todo.
	reader.target = grass
	reader.mind.observe()
	r["Con otro rival empieza de cero"] = reader.mind.dodge_sides.is_empty() and reader.mind.foe_style() == ""
	# Ventana: tus ataques fuertes en recarga.
	reader.target = foe
	reader.mind.observe()
	_set_moves(foe, ["cuchillada", "placaje"])
	var closed: bool = not reader.mind.window_open()
	foe.moves.cooldowns[0] = 3.0
	r["Castiga cuando tu ataque fuerte está en recarga"] = closed and reader.mind.window_open()
	# Con poca vida, según el temperamento.
	var plans := {}
	for id in ["agresivo", "timido", "territorial", "entrenador"]:
		reader.temperament = DB.temperaments[id]
		reader.instance.hp = reader.instance.max_hp() * 0.2
		plans[id] = reader.mind.low_hp_plan()
	reader.instance.hp = reader.instance.max_hp()
	plans["sano"] = reader.mind.low_hp_plan()
	r["Con poca vida: agresivo se juega todo, tímido huye, territorial y entrenador se cubren (%s)" % str(plans)] = \
		plans == {"agresivo": "todo", "timido": "huye", "territorial": "cuidado", "entrenador": "cuidado", "sano": ""}

	# --- IA-3: habilidades ---
	var water_mv: MoveData = DB.moves["pistola_agua"]
	var tackle: MoveData = DB.moves["placaje"]
	foe.signature.data = load("res://data/abilities/absorbe_agua.tres")
	reader.target = foe
	r["No tira Agua contra Absorbe Agua"] = reader.mind.ability_mult(water_mv, foe) == 0.0
	_set_moves(reader, ["pistola_agua", "placaje"])
	r["...ni la elige (puntaje 0)"] = reader.mind.score(0, 20.0, true) == 0.0 and reader.mind.score(1, 20.0, true) > 0.0
	foe.signature.data = load("res://data/abilities/electricidad_estatica.tres")
	r["Cuerpo a cuerpo contra Electricidad Estática vale menos"] = is_equal_approx(reader.mind.ability_mult(tackle, foe), TacticalMind.CONTACT_RISK) \
		and reader.mind.ability_mult(water_mv, foe) == 1.0
	reader.signature.data = load("res://data/abilities/torrente.tres")
	reader.instance.hp = reader.instance.max_hp() * 0.2
	r["Con Torrente y poca vida, el Agua vale ×1,5"] = is_equal_approx(reader.mind.ability_mult(water_mv, foe), 1.5)
	reader.instance.hp = reader.instance.max_hp()

	# --- IA-3: entorno (lo mojado y la descarga) ---
	var rs: ReactionSystem = world.reactions
	var spot := _ground_spot(rs, base)
	r["Hay suelo para mojar cerca (%s)" % str(spot)] = spot != Vector2.INF
	if spot != Vector2.INF:
		var zap: MoveData = DB.moves["impactrueno"]
		foe.global_position = spot
		reader.global_position = spot + Vector2(-60, 0)
		_set_moves(reader, ["pistola_agua", "impactrueno"])
		await get_tree().physics_frame
		r["En seco: mojarte primero prepara la descarga (×%.2f)" % reader.mind.env_mult(water_mv, foe)] = \
			is_equal_approx(reader.mind.env_mult(water_mv, foe), TacticalMind.ENV_SETUP) and reader.mind.env_mult(zap, foe) == 1.0
		rs.apply_element(water_mv.element, spot, 4.0)
		r["Mojado: la descarga vale ×1,6"] = rs.state_at(spot) != null and rs.state_at(spot).id == "mojado" \
			and is_equal_approx(reader.mind.env_mult(zap, foe), TacticalMind.ENV_PUNISH)
		# Al revés: el que está parado en lo mojado frente a uno con ataques eléctricos se va.
		_set_moves(reader, ["impactrueno"])
		foe.target = reader
		var foe_body_spot := foe.global_position
		r["Parado en lo mojado frente a un eléctrico: peligro"] = foe.mind.danger_at(foe_body_spot) \
			and not foe.mind.danger_at(reader.global_position)
		r["...y sabe para dónde salir"] = foe.body.hazard_escape() != Vector2.ZERO

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


## Un lugar de suelo (que se moja) cerca, con suelo alrededor (para salir).
func _ground_spot(rs: ReactionSystem, around: Vector2) -> Vector2:
	for r in range(0, 160, 16):
		for k in 16:
			var p := around + Vector2.RIGHT.rotated(k * TAU / 16.0) * r
			if rs.tags_at(p).has("suelo") and rs.state_at(p) == null and rs.tags_at(p + Vector2(18, 0)).has("suelo") \
					and rs.tags_at(p + Vector2(-60, 0)).has("suelo"):
				return p
	return Vector2.INF
