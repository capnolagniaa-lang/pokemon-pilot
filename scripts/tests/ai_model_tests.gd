class_name AiModelTests
extends Node
## Autotest de la Fase 4 de la IA nueva (docs/IA_AUDITORIA.md): el modelo del jugador (`PlayerModel`): memoria que se
## desvanece, secuencias de 2 y 3 acciones, confianza según la dificultad, cómo respondés a sus ataques, contracambios; y el
## cerebro nuevo usándolo (apunta adonde vas a esquivar, amaga más, se corre antes de tu golpe, cambia menos si
## contracambiás). Al final, una pelea contra un bot que siempre esquiva para el mismo lado.
##   godot --headless --path . --quit-after 120000 -- --autotest-ai-model

var autotest: Node
var world: Node
var r := {}
var me: Creature
var foe: Creature
var dir := Vector2.RIGHT


func run() -> void:
	seed(11)
	_units()
	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	GameState.active().level = 30
	GameState.active().hp = GameState.active().max_hp()
	world.respawn_companion()
	GameState.set_setting("ai_brain_new", true)
	GameState.set_difficulty("dificil")
	await get_tree().physics_frame
	_no_cheat_source()
	await _fight(["rattata", "pidgey"], true)
	await _brain_reads()
	await _finish()
	await _fight(["charmander", "oddish"], true)
	await _coach_counter()
	await _finish()
	await _live()
	GameState.set_setting("ai_brain_new", false)
	GameState.set_difficulty("normal")
	_results()


func _units() -> void:
	var m := PlayerModel.new()
	m.add("t", "x", "a", 0.0, 10.0)
	var n := float(m.predict("t", "x", 10.0, 10.0, 2.0).n)
	r["La memoria se desvanece: a la vida media pesa la mitad (%.2f)" % n] = absf(n - 0.5) < 0.01
	# Bigrama: A, B, A, B...
	m = PlayerModel.new()
	var t := 0.0
	for i in 8:
		m.note_action("A", t, 30.0)
		m.note_action("B", t + 0.5, 30.0)
		t += 1.0
	var pr := m.predict_next(t, 30.0, 2.0)
	r["Secuencia A, B, A, B: después de B viene A (%s %.2f, %s)" % [pr.outcome, pr.p, pr.get("from", "")]] = pr.outcome == "A" and float(pr.p) > 0.9
	# Trigrama: A, A, B, A, A, B... (con una sola acción no se sabe; con dos sí)
	m = PlayerModel.new()
	t = 0.0
	for i in 6:
		for tok in ["A", "A", "B"]:
			m.note_action(tok, t, 30.0)
			t += 0.4
	var bi := m.predict("bi", "A", t, 30.0, 2.0)
	pr = m.predict_next(t, 30.0, 2.0)  # (lo último: A, A, B → viene A)
	m.note_action("A", t, 30.0)
	var pr2 := m.predict_next(t, 30.0, 2.0)  # (B, A → viene A)
	m.note_action("A", t, 30.0)
	var pr3 := m.predict_next(t, 30.0, 2.0)  # (A, A → viene B)
	r["Trigrama: después de A, A viene B aunque después de A sola no se sepa (bigrama %.2f, trigrama %s %.2f)" % [bi.p, pr3.outcome, pr3.p]] = \
		float(bi.p) < 0.7 and pr3.outcome == "B" and float(pr3.p) > 0.9 and pr3.from == "trigrama" and pr2.outcome == "A"
	# Se adapta a un patrón nuevo (lo viejo se desvanece).
	m = PlayerModel.new()
	for i in 10:
		m.note_action("X", i * 2.0, 30.0)
		m.note_action("Y", i * 2.0 + 0.5, 30.0)
	for i in 4:
		m.note_action("X", 120.0 + i, 30.0)
		m.note_action("Z", 120.5 + i, 30.0)
	m.note_action("X", 125.0, 30.0)
	pr = m.predict_next(125.0, 30.0, 2.0)
	r["Cambiás de costumbre: a los pocos casos predice la nueva (%s %.2f)" % [pr.outcome, pr.p]] = pr.outcome == "Z"
	# Confianza: Difícil se anima con menos casos que Fácil.
	m = PlayerModel.new()
	for i in 4:
		m.note_response("aviso", "esq_der", i * 1.0, 30.0)
	var hard := float(m.predict_response("aviso", 4.0, 30.0, DB.ai_profiles["dificil"].adapt_k).conf)
	var easy := float(m.predict_response("aviso", 4.0, 30.0, DB.ai_profiles["facil"].adapt_k).conf)
	r["Con 4 casos: Difícil confía %.2f, Fácil %.2f" % [hard, easy]] = hard > 0.6 and easy < 0.4
	m.note_response("aviso", "nada", 4.0, 30.0)
	var ev := m.evade_share("aviso", 4.0, 30.0, 2.0)
	r["Respuestas: esquivás el aviso el %d%%" % roundi(float(ev[0]) * 100.0)] = absf(float(ev[0]) - 0.8) < 0.02
	# Contracambio.
	m = PlayerModel.new()
	m.note_ai_switch(10.0)
	m.note_switch(12.0, 30.0)
	m.note_ai_switch(13.0)
	m.note_no_counter(14.0, 30.0)  # (pegado: si no, el "sí" ya se desvaneció un poco)
	var cs := m.counter_switch(14.0, 30.0, 2.0)
	r["Contracambio: 1 de 2 (%.2f)" % cs[0]] = absf(float(cs[0]) - 0.5) < 0.1
	# Lados.
	var line := Vector2(1, 0)
	var ok := true
	for v in [Vector2(0, 1), Vector2(0, -1)]:
		var s := PlayerModel.side_of(v, line)
		ok = ok and PlayerModel.side_dir(s, line).dot(v) > 0.9
	r["Lado izq./der. ida y vuelta"] = ok and PlayerModel.side_of(Vector2(1, 0), line) == "atras"


func _no_cheat_source() -> void:
	var src := FileAccess.get_file_as_string("res://scripts/creatures/ai/player_model.gd")
	var code := "\n".join(Array(src.split("\n")).filter(func(l): return not l.strip_edges().begins_with("#")))
	var found := ["Input.", "input_source", "CombatInput", ".cooldowns", "has_pp", "moves.slots"].filter(func(x): return x in code)
	r["El modelo no lee teclas, recargas ni ataques equipados (%s)" % (", ".join(found) if not found.is_empty() else "nada")] = found.is_empty()


func _brain_reads() -> void:
	var b: UtilityBrain = foe.brain
	var st := TrainerStyle.new()
	st.reads = 1.0
	foe.trainer_style = st
	_place(120.0)
	await _ticks(0.4)
	b.evaluate_now()
	b._watch_foe(me)
	# Anota tus ataques en la secuencia.
	me.moves.slots[0] = DB.moves["pistola_agua"]
	for i in 3:
		me.moves.reset_cooldown(0)
		me.moves.set_pp(me.moves.max_pp())
		me.use_slot(0, dir.orthogonal())
		await _ticks(0.3)
	r["Anota tus ataques (%s)" % str(b.model().stream)] = b.model().stream.count("atk:pistola_agua") == 3
	# Cómo respondés: le tira algo, esquivás a un lado.
	var line := me.global_position - foe.global_position
	b.evaluate_now()
	b._pending = {}
	b._open_pending("disparo")
	await _ticks(0.05)
	me.dodge(PlayerModel.side_dir("der", line))
	await _ticks(0.8)
	me.machine.transition_to("controlled")
	b._resolve_pending()
	var resp := b.model().predict_response("disparo", PlayerModel.clock(), b._hl(), b._k())
	r["Aprende cómo respondiste (%s)" % str(resp.get("dist", {}))] = resp.get("outcome", "") == "esq_der"
	# Apunta adonde vas a esquivar.
	for i in 10:
		b.model().note_response("disparo", "esq_der", PlayerModel.clock(), b._hl())
	_place(120.0)
	await _ticks(0.3)
	line = me.global_position - foe.global_position
	var hits := 0
	var right := 0
	for i in 40:
		var bias := b._read_bias(DB.moves["pistola_agua"], me.global_position)
		if bias != Vector2.ZERO:
			hits += 1
			if bias.dot(PlayerModel.side_dir("der", line)) > 50.0:
				right += 1
	r["Te tiene leído: corre la puntería hacia donde esquivás (%d de 40, %d hacia ese lado)" % [hits, right]] = hits >= 28 and right == hits
	st.reads = 0.0
	var none := 0
	for i in 20:
		if b._read_bias(DB.moves["pistola_agua"], me.global_position) != Vector2.ZERO:
			none += 1
	r["Una clase que no lee no lo usa"] = none == 0
	st.reads = 1.0
	# Esquivás para cualquier lado: no hay a dónde correrla.
	var saved: Dictionary = b.model()._tables.get("resp", {}).duplicate(true)
	b.model()._tables["resp"] = {}
	for i in 6:
		b.model().note_response("disparo", "esq_der", PlayerModel.clock(), b._hl())
		b.model().note_response("disparo", "esq_izq", PlayerModel.clock(), b._hl())
	var random_hits := 0
	for i in 40:
		if b._read_bias(DB.moves["pistola_agua"], me.global_position) != Vector2.ZERO:
			random_hits += 1
	r["Si esquivás para cualquier lado, no corre la puntería (%d de 40)" % random_hits] = random_hits == 0
	b.model()._tables["resp"] = saved
	for i in 8:
		b.model().note_response("aviso", "esq_izq", PlayerModel.clock(), b._hl())
	r["Esquivás al aviso: amaga más (+%.2f)" % b._feint_bonus()] = b._feint_bonus() > 0.2
	# Viene tu golpe: se corre antes.
	_place(40.0)
	await _ticks(0.4)
	b.model().clear()
	var plain := _u(b.evaluate_now(), UtilityBrain.Act.RETREAT)
	for i in 8:
		b.model().note_action("atk:placaje", PlayerModel.clock(), b._hl())
	var read := _u(b.evaluate_now(), UtilityBrain.Act.RETREAT)
	r["Predice tu Placaje: alejarse vale más (%.2f → %.2f; %s)" % [plain, read, b.prediction_text()]] = read > plain + 0.1


func _coach_counter() -> void:
	var arena: TrainerBattle = world.arena
	arena.style.switch_types = 1.0
	arena.style.max_switches = 3
	arena.style.reads = 1.0
	foe.trainer_style = arena.style
	arena._entered_at = arena._clock - 10.0
	_place(120.0)
	await _ticks(0.4)
	var base := _switch_u(arena.coach.evaluate())
	var mdl: PlayerModel = foe.mind.memory.model
	for i in 6:
		mdl.note_ai_switch(PlayerModel.clock())
		mdl.note_switch(PlayerModel.clock(), 60.0)
	var after := _switch_u(arena.coach.evaluate())
	r["Si contracambiás, cambiar rinde menos (%.2f → %.2f)" % [base, after]] = base > 0.0 and after < base * 0.75


## Pelea de verdad contra un bot que siempre esquiva hacia el mismo lado: lo aprende y le corre la puntería.
func _live() -> void:
	var lee := [0]
	var cb := func(actor, what, _d): if what == "lee": lee[0] += 1
	Events.ai_decided.connect(cb)
	await _fight(["magnemite", "voltorb"], false)
	var st := TrainerStyle.new()
	st.reads = 1.0
	world.arena.style = st
	world.arena.foe.trainer_style = st
	var t := 0.0
	var shoot := 0.0
	while t < 25.0 and world.arena.active:
		me = world.companion
		var f: Creature = world.arena.foe if is_instance_valid(world.arena.foe) else null  # (entre un Pokémon y el siguiente no hay)
		if is_instance_valid(me) and f != null:
			for n in world.entities.get_children():
				if n is Projectile and n.hit != null and n.hit.team != me.team and n.global_position.distance_to(me.global_position) < 90.0 \
						and n.velocity.dot(me.global_position - n.global_position) > 0.0 and me.moves.can_dodge():
					me.dodge(PlayerModel.side_dir("der", me.global_position - f.global_position))  # siempre a "su derecha"
					break
			shoot -= get_physics_process_delta_time()
			if shoot <= 0.0:
				shoot = 1.2
				me.moves.slots[0] = DB.moves["pistola_agua"]
				me.moves.reset_cooldown(0)
				me.moves.set_pp(me.moves.max_pp())
				me.use_slot(0, (f.global_position - me.global_position).normalized())
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	var f: Creature = world.arena.foe if is_instance_valid(world.arena.foe) else null
	var learned := {}
	if is_instance_valid(f):
		for ctx in ["disparo", "aviso", "carga"]:
			var pr := f.mind.memory.model.predict_response(ctx, PlayerModel.clock(), f.brain._hl(), f.brain._k())
			if not pr.is_empty():
				learned[ctx] = "%s %d%% conf %.2f" % [pr.outcome, roundi(float(pr.p) * 100.0), float(pr.conf)]
	r["Pelea viva: aprende que esquivás a la derecha (%s)" % str(learned)] = learned.values().any(func(v): return str(v).begins_with("esq_der"))
	r["...y te corre la puntería (%d veces)" % lee[0]] = lee[0] >= 1
	Events.ai_decided.disconnect(cb)
	await _finish()


func _switch_u(o: Array) -> float:
	for x in o:
		if x.kind == "cambiar":
			return float(x.u)
	return 0.0


## La utilidad con lo que predice de vos (el `read_bonus` cuenta al elegir con qué moverse).
func _u(o: Array, act: int) -> float:
	var best := 0.0
	for x in o:
		if int(x.act) == act:
			best = maxf(best, float(x.u) + float(x.get("read_bonus", 0.0)))
	return best


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
		print("[ai-model] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-ai-model] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
