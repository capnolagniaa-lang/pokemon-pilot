class_name AiUtilityTests
extends Node
## Autotest de la Fase 3 de la IA nueva (docs/IA_AUDITORIA.md): el cerebro de utilidad del Pokémon (`UtilityBrain`) y el
## del entrenador (`UtilityCoach`): cuándo se usa, softmax, penalidad por repetir, ritmo variable, qué elige en cada
## situación, que reaccione a lo que ve venir, que no lea nada prohibido, y peleas de verdad con un bot.
##   godot --headless --path . --quit-after 90000 -- --autotest-ai-utility

var autotest: Node
var world: Node
var r := {}
var me: Creature
var foe: Creature
var dir := Vector2.RIGHT


func run() -> void:
	seed(7)
	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	GameState.active().level = 30
	GameState.active().hp = GameState.active().max_hp()
	world.respawn_companion()
	await get_tree().physics_frame
	_units()
	_no_cheat_source()
	# --- Con el ajuste apagado: IA clásica, sin cerebro ---
	r["El ajuste arranca apagado"] = GameState.setting("ai_brain_new") == false
	await _fight(["rattata", "pidgey"], true)
	r["Apagado: el Pokémon del entrenador usa la IA clásica (sin cerebro nuevo)"] = not foe.uses_new_brain() and foe._brain == null
	await _finish()
	GameState.set_setting("ai_brain_new", true)
	await _fight(["rattata", "pidgey"], true)
	r["Prendido: usa el cerebro nuevo"] = foe.uses_new_brain()
	var wild := Creature.new()
	r["Un salvaje nunca lo usa"] = not wild.uses_new_brain()
	wild.free()
	var st := TrainerStyle.new()
	st.profile = DB.ai_profiles["normal"].duplicate()
	st.profile.brain = "clasica"
	var saved_style := foe.trainer_style
	foe.trainer_style = st
	r["Un perfil puede forzar la clásica aunque el ajuste esté prendido"] = not foe.uses_new_brain()
	foe.trainer_style = saved_style
	await _situations()
	await _react()
	await _finish()
	await _coach()
	await _live()
	GameState.set_setting("ai_brain_new", false)
	_results()


## Softmax, repetición y ritmo, con números armados.
func _units() -> void:
	var opts := [{"u": 1.0, "name": "a"}, {"u": 0.6, "name": "b"}, {"u": 0.2, "name": "c"}]
	var cold := {}
	var hot := {}
	for i in 400:
		var a: Dictionary = UtilityBrain.softmax_pick(opts.duplicate(true), 0.05)
		cold[a.name] = cold.get(a.name, 0) + 1
		var b: Dictionary = UtilityBrain.softmax_pick(opts.duplicate(true), 0.5)
		hot[b.name] = hot.get(b.name, 0) + 1
	r["Softmax frío: casi siempre la mejor (%s)" % str(cold)] = cold.get("a", 0) >= 380
	r["Softmax tibio: varía, pero la mejor sigue primera (%s)" % str(hot)] = hot.get("a", 0) < 330 and hot.get("a", 0) > hot.get("b", 0) \
		and hot.get("b", 0) > hot.get("c", 0) and hot.get("c", 0) > 0
	var dummy := Creature.new()
	var b := UtilityBrain.new(dummy)
	for i in 4:
		b._remember("atk:Placaje", 10.0 + i * 0.3)
	b._remember("acercarse", 11.0)
	var fresh := b.recent_share("atk:Placaje", 11.2)
	var later := b.recent_share("atk:Placaje", 11.2 + 20.0)
	r["Repetir pesa: lo que hizo recién cuenta mucho (%.2f) y se olvida con el tiempo (%.2f, solo)" % [fresh, later]] = fresh > 0.6 and later > 0.0
	b._remember("rodear izq.", 40.0)
	r["...y lo viejo deja de pesar al lado de lo nuevo (%.2f)" % b.recent_share("atk:Placaje", 40.0)] = b.recent_share("atk:Placaje", 40.0) < 0.05
	var gaps: Array[float] = []
	for i in 80:
		gaps.append(b._think_interval(100.0 + i * 0.7))
	var mean := 0.0
	for g in gaps:
		mean += g
	mean /= gaps.size()
	var var_ := 0.0
	for g in gaps:
		var_ += (g - mean) * (g - mean)
	var cv := sqrt(var_ / gaps.size()) / mean
	r["Piensa con ritmo variable (promedio %.2f s, variación %.0f%%)" % [mean, cv * 100.0]] = cv > 0.2 \
		and gaps.all(func(g): return g >= UtilityBrain.THINK_MIN and g <= UtilityBrain.THINK_MAX)
	dummy.free()


func _no_cheat_source() -> void:
	var src := ""
	for f in ["utility_brain.gd", "utility_coach.gd"]:
		src += FileAccess.get_file_as_string("res://scripts/creatures/ai/" + f)
	var code := "\n".join(Array(src.split("\n")).filter(func(l): return not l.strip_edges().begins_with("#")))
	var bad := ["Input.", "input_source", "CombatInput", ".cooldowns", "has_pp", "knows_moves", "danger_at(", "strong_on_cooldown",
		"window_open", "t.moves", "target.moves", "me.moves", "mind.matchup()", "TacticalMind.exposed", "foe.moves"]
	var found := bad.filter(func(x): return x in code)
	r["El cerebro y el entrenador nuevos no leen tus teclas, recargas, PP ni ataques (%s)" % (", ".join(found) if not found.is_empty() else "nada")] = found.is_empty()


## Qué elige en cada situación (el rival quieto: se mira la evaluación, no la ejecución).
func _situations() -> void:
	foe.moves.set_pp(foe.moves.max_pp())
	_place(260.0)
	await _ticks(0.5)
	var o := foe.brain.evaluate_now()
	r["Lejos: acercarse le gana a alejarse (%s)" % _top(o)] = _u(o, UtilityBrain.Act.APPROACH) > _u(o, UtilityBrain.Act.RETREAT) \
		and _u(o, UtilityBrain.Act.APPROACH) >= float(o[0].u) * 0.8
	_place(40.0)
	await _ticks(0.5)
	var calm := _best_attack(foe.brain.evaluate_now())
	me.machine.transition_to("recovery", {"time": 2.0})
	await _ticks(foe.perception.delay() + 0.1)
	o = foe.brain.evaluate_now()
	r["Te ve recuperándote al lado: lo mejor es pegarte, y más que en calma (%.2f > %.2f; %s)" % [_best_attack(o), calm, _top(o)]] = \
		int(o[0].act) == UtilityBrain.Act.ATTACK and _best_attack(o) > calm
	me.machine.transition_to("controlled")
	await _ticks(0.3)
	# Sin PP para su mejor ataque, pero a punto: juntar PP es una opción.
	var strong := -1
	var best_cost := 0.0
	for s in MoveUser.SLOT_COUNT:
		var m: MoveData = foe.moves.slots[s]
		if m != null and m.power > 0.0 and foe.moves.pp_cost(s) > best_cost:
			best_cost = foe.moves.pp_cost(s)
			strong = s
	foe.moves.set_pp(best_cost - 10.0)
	_place(40.0)
	await _ticks(0.6)  # (que ya no te vea expuesto de recién)
	foe.moves.set_pp(best_cost - 10.0)
	o = foe.brain.evaluate_now()
	r["A pocos PP de su mejor ataque: juntar PP aparece como opción (%s)" % _top(o)] = strong >= 0 and _u(o, UtilityBrain.Act.WAIT) > 0.0
	foe.moves.set_pp(foe.moves.max_pp())
	# Acorralado: salir del rincón.
	var center := foe.global_position
	for k in 40:
		foe.global_position = center + Vector2(-1, -1).normalized() * 12.0 * k
		await get_tree().physics_frame
		if Situation.is_cornered(foe):
			break
	me.global_position = foe.global_position + Vector2(1, 1).normalized() * 70.0
	await _ticks(0.4)
	o = foe.brain.evaluate_now()
	r["Acorralado: salir del rincón está entre lo mejor (%s)" % _top(o)] = _u(o, UtilityBrain.Act.REPOSITION) > 0.0 \
		and o.slice(0, 3).any(func(x): return int(x.act) == UtilityBrain.Act.REPOSITION)
	foe.global_position = center
	await _ticks(0.3)


## Un disparo que viene: con `evade_skill` 1 siempre reacciona (paso al costado o esquive). Acá el rival pelea de verdad
## (su máquina de estados corre): se cuentan sus reacciones en el registro.
func _react() -> void:
	var st := TrainerStyle.new()
	st.profile = DB.ai_profiles["dificil"].duplicate()
	st.profile.evade_skill = 1.0
	foe.trainer_style = st
	var saved_slots := foe.moves.slots.duplicate()
	for k in MoveUser.SLOT_COUNT:
		foe.moves.slots[k] = null  # (sin ataques: que no esté en pleno golpe cuando llega el disparo)
	foe.machine.set_physics_process(true)
	foe.machine.transition_to("attack")
	var reacted := [0]
	var cb := func(actor, what, _d): if actor == foe and what in ["paso", "esquive"]: reacted[0] += 1
	Events.ai_decided.connect(cb)
	var rounds := 0
	var center := foe.global_position
	for i in 3:
		await _ticks(1.0)  # (que se le pase la recarga del esquive)
		foe.global_position = center
		_place(150.0)
		await _ticks(0.05)
		var before: int = reacted[0]
		me.moves.slots[0] = DB.moves["pistola_agua"]
		me.moves.reset_cooldown(0)
		me.moves.set_pp(me.moves.max_pp())
		me.use_slot(0, (foe.global_position - me.global_position).normalized())
		await _ticks(0.7)
		if reacted[0] > before:
			rounds += 1
	Events.ai_decided.disconnect(cb)
	r["Ve venir el disparo y reacciona: paso al costado o esquive (%d de 3)" % rounds] = rounds == 3
	foe.machine.set_physics_process(false)
	for k in MoveUser.SLOT_COUNT:
		foe.moves.slots[k] = saved_slots[k]


func _coach() -> void:
	await _fight(["charmander", "oddish"], true)
	var arena: TrainerBattle = world.arena
	arena.style.switch_types = 1.0
	arena.style.max_switches = 2
	arena._entered_at = arena._clock - 10.0
	arena._last_switch = -100.0
	_place(120.0)
	await _ticks(0.5)
	var o := arena.coach.evaluate()
	r["Entrenador: Charmander contra tu Squirtle, lo mejor es cambiar a Oddish (%s)" % _coach_top(o)] = not o.is_empty() and o[0].kind == "cambiar"
	var switched := false
	for i in 6:
		arena.coach.think()
		await get_tree().physics_frame
		if is_instance_valid(arena.foe) and arena.foe.instance.species.id == "oddish":
			switched = true
			break
	r["...y cambia"] = switched
	if switched:
		foe = arena.foe
		foe.machine.set_physics_process(false)
		foe.health.invulnerable_time = 9999.0
		await _ticks(0.5)
		o = arena.coach.evaluate()
		r["Con el cruce a favor, se queda (%s)" % _coach_top(o)] = o[0].kind == "mantener"
		foe.instance.hp = foe.instance.max_hp() * 0.2
		arena.potions_left = 1
		_place(220.0)
		o = arena.coach.evaluate()
		r["Con poca vida y vos lejos, lo mejor es la Superpoción (%s)" % _coach_top(o)] = o[0].kind == "pocion"
		await _ticks(3.0)
		r["...y la usa"] = arena.potions_left == 0 and foe.health.ratio() > 0.2
		foe.instance.hp = foe.instance.max_hp()
	await _finish()


## Peleas de verdad: el cerebro nuevo contra un bot que te dispara, sin errores, con decisiones y variedad.
func _live() -> void:
	var seen := {}
	var cb := func(actor, what, _d): if actor == world.arena.foe: seen[what] = seen.get(what, 0) + 1
	Events.ai_decided.connect(cb)
	await _fight(["rattata", "pidgey", "spearow"], false)
	var t := 0.0
	var shoot := 0.0
	while t < 14.0 and world.arena.active:
		shoot -= get_physics_process_delta_time()
		me = world.companion
		if shoot <= 0.0 and is_instance_valid(me) and is_instance_valid(world.arena.foe):
			shoot = 0.8
			me.moves.slots[0] = DB.moves["pistola_agua"]
			me.moves.reset_cooldown(0)
			me.moves.set_pp(me.moves.max_pp())
			me.use_slot(0, (world.arena.foe.global_position - me.global_position).normalized())
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	var stats: AiFightStats = world.ai_debug.stats
	var rep := stats.repetition()
	r["Pelea viva: decide seguido (%d), ataca (%d), sin errores" % [seen.get("decide", 0), stats.uses["ia"]]] = int(seen.get("decide", 0)) >= 10 \
		and stats.uses["ia"] >= 3
	r["...y no repite siempre lo mismo (más usado %d%%, %s)" % [roundi(float(rep.mas_usado) * 100.0), str(stats.ia_moves.slice(0, 8))]] = \
		float(rep.mas_usado) < 0.95 or stats.ia_moves.size() < 3
	r["...con tiempo en varios movimientos (%s)" % str(stats.to_dict().modos_ia)] = (stats.mode_time as Dictionary).size() >= 3
	Events.ai_decided.disconnect(cb)
	await _finish()


func _u(o: Array, act: int) -> float:
	var best := 0.0
	for x in o:
		if int(x.act) == act:
			best = maxf(best, float(x.u))
	return best


func _best_attack(o: Array) -> float:
	return _u(o, UtilityBrain.Act.ATTACK)


func _top(o: Array) -> String:
	return ", ".join(o.slice(0, 4).map(func(x): return "%s %.2f" % [x.name, x.u]))


func _coach_top(o: Array) -> String:
	return ", ".join(o.slice(0, 3).map(func(x): return "%s %.2f" % [x.name, x.u]))


func _place(dist: float) -> void:
	me.global_position = foe.global_position - dir * dist
	me.velocity = Vector2.ZERO


func _ticks(seconds: float) -> void:
	var t := 0.0
	while true:
		foe.perception.tick()
		if t >= seconds:
			break
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


## Pelea de prueba. `frozen` = el rival queda quieto (sin su máquina de estados) para mirar qué evalúa.
func _fight(species: Array, frozen: bool) -> void:
	var team: Array[CreatureInstance] = []
	for sp in species:
		team.append(CreatureInstance.create_rival(DB.species[sp], 26))
	world.arena.start({"name": "Tincho", "title": "Entrenador", "team": team, "no_blackout": true})
	await _until(func(): return world.arena.active and world.arena._fighting and is_instance_valid(world.arena.foe), 10.0)
	foe = world.arena.foe
	me = world.companion
	world.arena.potions_left = 0
	world.arena.style = TrainerStyle.new()
	world.arena.style.retreat = 0.0
	world.arena.style.switch_types = 0.0
	foe.trainer_style = world.arena.style
	me.input_source = NetCombatInput.new()  # (mudo)
	me.health.invulnerable_time = 9999.0
	if frozen:
		foe.machine.set_physics_process(false)
		foe.health.invulnerable_time = 9999.0
		var center: Vector2 = world.arena.cell_pos(world.arena.arena_data.player_cell).lerp(world.arena.cell_pos(world.arena.arena_data.foe_mon_cell), 0.5)
		foe.global_position = center
	await get_tree().physics_frame


func _finish() -> void:
	if world.arena.active:
		world.arena._end("win")
	await _until(func(): return not world.arena.active, 10.0)
	GameState.heal_party()
	world.respawn_companion()
	await get_tree().physics_frame


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func _results() -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[ai-utility] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-ai-utility] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
