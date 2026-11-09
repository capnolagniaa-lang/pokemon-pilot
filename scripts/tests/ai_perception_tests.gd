class_name AiPerceptionTests
extends Node
## Autotest de la Fase 2 de la IA nueva (docs/IA_AUDITORIA.md): perfiles por dificultad (`AIProfile`), percepción con
## retraso y sin trampas (`Perception`) y el clasificador de situación (`Situation`). El Pokémon del entrenador queda quieto
## (sin su IA) y se mira qué percibe y cómo lee la situación mientras se mueve a tu Pokémon a mano.
##   godot --headless --path . --quit-after 60000 -- --autotest-ai-perception

var autotest: Node
var world: Node
var r := {}
var me: Creature
var foe: Creature
var dir := Vector2.RIGHT


func run() -> void:
	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	GameState.active().level = 30
	GameState.active().hp = GameState.active().max_hp()
	world.respawn_companion()
	await get_tree().physics_frame
	_profiles()
	_no_cheat_source()
	await _fight(["rattata", "pidgey"])
	await _delay()
	await _threat_delay()
	await _cooldowns()
	await _situations()
	await _finish()
	await _fight(["charmander", "oddish"])
	await _strategy()
	await _overlay()
	await _finish()
	_results()


func _profiles() -> void:
	var ids := ["facil", "normal", "dificil"]
	var ok := ids.all(func(i): return DB.ai_profiles.has(i))
	r["Hay un perfil por dificultad"] = ok
	if not ok:
		return
	var d: Array = ids.map(func(i): return DB.ai_profiles[i].delay())
	r["Retraso de percepción entre 0,15 y 0,4 s, más corto cuanto más difícil (%s)" % str(d)] = d.all(func(x): return x >= 0.15 and x <= 0.4) \
		and d[0] > d[1] and d[1] > d[2]
	GameState.set_difficulty("dificil")
	r["El perfil sale de la dificultad"] = AIProfile.current() == DB.ai_profiles["dificil"]
	GameState.set_difficulty("normal")
	var st := TrainerStyle.new()
	st.profile = AIProfile.new()
	var dummy := Creature.new()
	dummy.trainer_style = st
	r["Un estilo de entrenador puede traer su perfil"] = AIProfile.of(dummy) == st.profile
	dummy.free()


## Las piezas de la IA nueva no tocan tus teclas, tus recargas ni tus PP: solo lo que se ve.
func _no_cheat_source() -> void:
	var src := FileAccess.get_file_as_string("res://scripts/creatures/ai/perception.gd") \
		+ FileAccess.get_file_as_string("res://scripts/creatures/ai/situation.gd")
	var code := "\n".join(Array(src.split("\n")).filter(func(l): return not l.strip_edges().begins_with("#")))
	var bad := ["Input.", "input_source", "CombatInput", ".cooldowns", "has_pp", "t.moves", "_foe.moves", "target.moves", ".pp()"]
	var found := bad.filter(func(b): return b in code)
	r["Perception y Situation no leen tus teclas, recargas ni PP (%s)" % (", ".join(found) if not found.is_empty() else "nada")] = found.is_empty()


## Ve tu posición con el retraso de su dificultad.
func _delay() -> void:
	for diff in ["normal", "dificil", "facil"]:
		GameState.set_difficulty(diff)
		var expect: float = DB.ai_profiles[diff].delay()
		var jit: float = DB.ai_profiles[diff].perception_jitter
		_place(120.0)
		await _ticks(0.7)
		var target := me.global_position + dir.orthogonal() * 60.0
		me.global_position = target
		var t := 0.0
		while t < 1.0 and foe.perception.foe().get("pos", Vector2.INF).distance_to(target) > 2.0:
			await _ticks(1.0 / 60.0)
			t += 1.0 / 60.0
		r["%s: se entera del movimiento a los %.2f s (retraso %.2f ± %.2f)" % [diff, t, expect, jit]] = \
			t >= expect - jit - 0.02 and t <= expect + jit + 0.04
	GameState.set_difficulty("normal")


## Un disparo: la mente de hoy lo ve al instante; la percepción, recién pasado el retraso, con el tiempo descontado.
func _threat_delay() -> void:
	_place(150.0)
	await _ticks(0.5)
	me.moves.slots[0] = DB.moves["pistola_agua"]
	me.moves.reset_cooldown(0)
	me.moves.set_pp(me.moves.max_pp())
	me.use_slot(0, (foe.global_position - me.global_position).normalized())
	var t := 0.0
	var instant := -1.0
	var seen := -1.0
	var eta_gap := 9.0
	while t < 0.8 and seen < 0.0:
		await _ticks(1.0 / 60.0)
		t += 1.0 / 60.0
		if instant < 0.0 and not foe.mind.threat().is_empty():
			instant = t
		var th := foe.perception.threat()
		if not th.is_empty():
			seen = t
			var real := foe.mind.threat()
			eta_gap = absf(float(th.eta) - float(real.get("eta", th.eta)))
	var d := foe.perception.delay()
	r["El disparo lo ve con retraso (al instante %.2f s, percibido %.2f s, retraso %.2f)" % [instant, seen, d]] = \
		instant >= 0.0 and seen > instant and seen - instant >= d - 0.06
	r["...y descuenta el tiempo que pasó (diferencia de llegada %.3f s)" % eta_gap] = eta_gap < 0.06
	await _ticks(0.8)


## No espía tus recargas ni tus PP: los estima con lo que te vio hacer.
func _cooldowns() -> void:
	_place(160.0)
	var hydro: MoveData = DB.moves["hidrobomba"]
	me.moves.slots[1] = hydro
	me.moves.cooldowns[1] = 10.0
	await _ticks(0.5)
	r["Sin verte usarlo, no sabe que Hidrobomba está en recarga (la mente de hoy sí: %s)" % str(foe.mind.strong_on_cooldown())] = \
		not foe.perception.strong_down_est() and foe.perception.est_ready_in(hydro) == 0.0
	me.moves.reset_cooldown(1)
	me.moves.set_pp(me.moves.max_pp())
	var full := foe.perception.est_pp()
	me.use_slot(1, dir.orthogonal())  # (para un costado: que no le pegue)
	await _ticks(hydro.cast_time + foe.perception.delay() + 0.15)
	var left := foe.perception.est_ready_in(hydro)
	r["Te vio tirar Hidrobomba: la cree en recarga o sin PP (%.2f s) y te bajó la barra (%d → %d)" % [left, full, foe.perception.est_pp()]] = \
		left > 0.0 and foe.perception.strong_down_est() and foe.perception.est_pp() < full - 100.0 and foe.perception.window_est()
	me.moves.reset_cooldown(1)
	me.moves.set_pp(me.moves.max_pp())
	await _ticks(1.0 / 60.0)
	r["Si de verdad ya la tenés lista, no se entera (sigue estimando %.2f s)" % foe.perception.est_ready_in(hydro)] = \
		foe.perception.est_ready_in(hydro) > 0.0
	await _ticks(foe.perception.est_ready_in(hydro) + 0.1)
	r["Pasado el tiempo que estima, la cree lista"] = foe.perception.est_ready_in(hydro) == 0.0 and not foe.perception.strong_down_est()


func _situations() -> void:
	foe.moves.set_pp(foe.moves.max_pp())
	for s in MoveUser.SLOT_COUNT:
		foe.moves.reset_cooldown(s)
	_place(260.0)
	await _ticks(0.5)
	var sit := _read()
	r["Lejos: neutral lejos (%s)" % sit.to_text()] = sit.primary == Situation.Tactic.NEUTRAL_FAR
	_place(110.0)
	await _ticks(0.5)
	sit = _read()
	r["A media distancia: neutral media (%s)" % sit.to_text()] = sit.primary == Situation.Tactic.NEUTRAL_MID
	_place(40.0)
	await _ticks(0.5)
	sit = _read()
	r["Cerca: neutral cerca (%s)" % sit.to_text()] = sit.primary == Situation.Tactic.NEUTRAL_CLOSE
	me.machine.transition_to("recovery", {"time": 2.0})
	await _ticks(0.05)
	sit = _read()
	var early := sit.has(Situation.Tactic.PUNISH)
	await _ticks(foe.perception.delay() + 0.05)
	sit = _read()
	r["Te recuperás de un ataque: castigar, recién después del retraso (antes: %s; %s)" % [str(early), sit.to_text()]] = \
		not early and sit.primary == Situation.Tactic.PUNISH and sit.window
	me.machine.transition_to("controlled")
	await _ticks(0.5)
	foe.instance.hp = foe.instance.max_hp() * 0.2
	await _ticks(0.05)
	sit = _read()
	r["Poca vida propia (%s)" % sit.to_text()] = sit.has(Situation.Tactic.LOW_HP)
	foe.instance.hp = foe.instance.max_hp()
	me.instance.hp = 1.0
	await _ticks(foe.perception.delay() + 0.1)
	sit = _read()
	r["Te queda un golpe: rematar (%s)" % sit.to_text()] = sit.primary == Situation.Tactic.FINISH
	me.instance.hp = me.instance.max_hp()
	await _ticks(0.5)
	# Un disparo que viene: ataque entrante (manda sobre todo).
	_place(130.0)
	await _ticks(0.5)
	me.moves.reset_cooldown(0)
	me.moves.set_pp(me.moves.max_pp())
	me.use_slot(0, (foe.global_position - me.global_position).normalized())
	var got := false
	var t := 0.0
	while t < 0.7 and not got:
		await _ticks(1.0 / 60.0)
		t += 1.0 / 60.0
		got = _read().primary == Situation.Tactic.INCOMING
	r["Un disparo que llega: le viene un ataque"] = got
	await _ticks(0.6)
	# Acorralado: contra el borde de la arena sí, en el medio no.
	var center := foe.global_position
	var mid_ok := not Situation.is_cornered(foe)
	var corner := false
	for k in 40:
		foe.global_position = center + Vector2(-1, -1).normalized() * 12.0 * k
		await get_tree().physics_frame
		if Situation.is_cornered(foe):
			corner = true
			break
	r["Acorralado contra el borde, no en el medio (%s)" % str(foe.global_position - center)] = mid_ok and corner
	foe.global_position = center
	await _ticks(0.1)


## Cruce perdido y uno mejor en el banco: conviene cambiar (con lo que te vio, sin conocer tus ataques de antes).
func _strategy() -> void:
	_place(120.0)
	await _ticks(0.5)
	var sit := Situation.read(foe, foe.perception, world.arena.foe_team)
	r["Charmander contra tu Squirtle: cruce perdido, Oddish mejor, conviene cambiar (%s)" % sit.to_text()] = \
		sit.matchup < 1.0 and sit.bench_name != "" and sit.bench_best > sit.matchup and sit.should_switch
	var alone := Situation.read(foe, foe.perception, [])
	r["Sin banco no sugiere cambiar"] = not alone.should_switch


func _overlay() -> void:
	var seen := []
	var cb := func(actor, what, _d): if actor == foe and what == "situacion": seen.append(what)
	Events.ai_decided.connect(cb)
	world.ai_debug.set_overlay(true)
	await _ticks(0.6)
	var text: String = world.ai_debug.overlay_text()
	r["El overlay muestra la situación de la IA nueva"] = "IA nueva" in text and "cruce" in text
	r["...y la anota en el registro"] = not seen.is_empty()
	world.ai_debug.set_overlay(false)
	Events.ai_decided.disconnect(cb)


func _read() -> Situation:
	return Situation.read(foe, foe.perception)


## Pone tu Pokémon a `dist` del rival (que queda quieto en su lugar), en una dirección fija.
func _place(dist: float) -> void:
	me.global_position = foe.global_position - dir * dist
	me.velocity = Vector2.ZERO


## Deja pasar `seconds` haciendo que el rival mire (tick de la percepción cada cuadro).
func _ticks(seconds: float) -> void:
	var t := 0.0
	while true:
		foe.perception.tick()
		if t >= seconds:
			break
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


func _fight(species: Array) -> void:
	var team: Array[CreatureInstance] = []
	for sp in species:
		team.append(CreatureInstance.create_rival(DB.species[sp], 26))
	world.arena.start({"name": "Tincho", "title": "Entrenador", "team": team, "no_blackout": true})
	await _until(func(): return world.arena.active and world.arena._fighting and is_instance_valid(world.arena.foe), 10.0)
	foe = world.arena.foe
	me = world.companion
	world.arena.potions_left = 0  # (que el entrenador no lo cure, retire ni cambie mientras se prueba)
	world.arena.style = TrainerStyle.new()
	world.arena.style.retreat = 0.0
	world.arena.style.switch_types = 0.0
	foe.machine.set_physics_process(false)  # (quieto: acá se mira qué percibe, no qué hace)
	foe.health.invulnerable_time = 9999.0
	me.health.invulnerable_time = 9999.0
	me.input_source = NetCombatInput.new()  # (mudo)
	# Un costado despejado: del rival hacia el centro de la arena.
	var center: Vector2 = world.arena.cell_pos(world.arena.arena_data.player_cell).lerp(world.arena.cell_pos(world.arena.arena_data.foe_mon_cell), 0.5)
	foe.global_position = center
	dir = Vector2.RIGHT
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
		print("[ai-perception] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-ai-perception] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
