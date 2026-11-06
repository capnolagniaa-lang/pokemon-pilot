class_name AiPpTests
extends Node
## La IA administra sus PP (docs/PLAN_IA.md, H-1): no tira un ataque malo si con unos segundos junta para uno mucho mejor.
##   godot --headless --path . --quit-after 60000 -- --autotest-ai-pp

var autotest: Node
var world: Node
var r := {}


func run() -> void:
	world = await autotest._setup_kit_world("squirtle")
	GameState.difficulty = DB.difficulties["dificil"]
	await _decisions()
	await _real_fight()
	var ok := true
	for k in r:
		print("[ai-pp] %s: %s" % [k, "OK" if r[k] else "FALLO"])
		ok = ok and r[k]
	print("[autotest-ai-pp] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Charmander (nivel 40: barra 260, recarga 42 PP/s) contra Bulbasaur: Llamarada es súper efectiva, Arañazo no.
func _decisions() -> void:
	var base: Vector2 = world.companion.global_position
	var ai: Creature = autotest._dummy(world, "charmander", base + Vector2(-200, 0))
	var foe: Creature = autotest._dummy(world, "bulbasaur", base + Vector2(-180, 0))
	await get_tree().physics_frame
	await get_tree().physics_frame
	ai.target = foe
	_set_moves(ai, ["llamarada", "aranazo"])
	var elite: TrainerStyle = DB.trainer_style_for("Alto Mando")
	var hurried := TrainerStyle.new()
	hurried.patience = 0.0
	ai.trainer_style = elite
	var cost: float = ai.moves.pp_cost(0)

	ai.moves.set_pp(ai.moves.max_pp())
	r["Con la barra llena abre con el fuerte"] = ai.mind.pick(20.0) == 0 and not ai.mind.saving

	ai.moves.set_pp(cost - 60.0)
	var wait: float = ai.moves.seconds_until_ready(0)
	r["Le faltan PP para el fuerte y le alcanzan para el flojo (faltan %.1f s)" % wait] = ai.moves.can_use(1) and not ai.moves.can_use(0) and wait < TacticalMind.SAVE_MAX_WAIT
	r["No tira el flojo: junta"] = ai.mind.pick(20.0) == -1 and ai.mind.saving

	ai.mind.saving = false
	ai.trainer_style = hurried
	r["Sin paciencia tira el flojo igual"] = ai.mind.pick(20.0) == 1 and not ai.mind.saving
	ai.trainer_style = elite

	ai.mind.saving = false
	ai.moves.set_pp(ai.moves.pp_cost(1) + 1.0)
	r["Falta demasiado para el fuerte (%.1f s): no lo espera" % ai.moves.seconds_until_ready(0)] = ai.moves.seconds_until_ready(0) > TacticalMind.SAVE_MAX_WAIT \
		and ai.mind.pick(20.0) == 1 and not ai.mind.saving

	ai.moves.set_pp(cost - 60.0)
	ai.mind.saving = false
	foe.hitstun_left = 5.0
	r["Si estás expuesto no espera"] = ai.mind.pick(20.0) == 1 and not ai.mind.saving
	foe.hitstun_left = 0.0

	ai.mind.all_in = true
	r["Si se juega todo no espera"] = ai.mind.pick(20.0) == 1 and not ai.mind.saving
	ai.mind.all_in = false

	# La recarga cuenta igual que los PP: acaba de tirar el bueno y vuelve en un segundo.
	ai.moves.set_pp(ai.moves.max_pp())
	ai.moves.cooldowns[0] = 1.0
	r["Espera también a que termine la recarga"] = ai.mind.pick(20.0) == -1 and ai.mind.saving
	ai.moves.cooldowns[0] = 0.0

	# Le falta poco: espera sin irse; le falta bastante: se aleja.
	ai.moves.cooldowns[0] = 0.4
	ai.mind.saving = false
	ai.mind.pick(20.0)
	r["Le falta poco: espera cerca"] = ai.mind.saving and ai.mind.save_left() < TacticalMind.SAVE_BACK_OFF
	ai.moves.cooldowns[0] = 2.0
	r["Le falta bastante: se aleja"] = ai.mind.saving and ai.mind.save_left() >= TacticalMind.SAVE_BACK_OFF
	ai.moves.cooldowns[0] = 0.0

	# Una vez que decidió sigue, aunque el azar del puntaje cambie, hasta poder usarlo; ahí lo usa.
	ai.mind.saving = false
	ai.moves.set_pp(cost - 60.0)
	var held := true
	for i in 30:
		held = held and ai.mind.pick(20.0) == -1
	r["Mantiene la decisión mientras junta"] = held
	ai.moves.set_pp(cost)
	r["Con los PP justos tira el fuerte"] = ai.mind.pick(20.0) == 0 and not ai.mind.saving

	# Remate: el barato alcanza, no gasta el caro.
	ai.moves.set_pp(ai.moves.max_pp())
	foe.instance.hp = 1.0
	var picks := {}
	for i in 30:
		var s: int = ai.mind.pick(20.0)
		picks[s] = picks.get(s, 0) + 1
	r["Para rematar usa el más barato (%s)" % str(picks)] = picks.get(1, 0) == 30
	foe.instance.hp = foe.instance.max_hp()

	# Daño por PP: con la barra por la mitad el caro pierde valor; con la barra llena, no.
	ai.moves.set_pp(ai.moves.max_pp())
	var full := _avg_score(ai, 0) / ai.mind.move_value(0, 20.0, true)
	ai.moves.set_pp(ai.moves.max_pp() * 0.75)
	var mid := _avg_score(ai, 0) / ai.mind.move_value(0, 20.0, true)
	r["A menos barra, el caro vale menos (%.2f → %.2f)" % [full, mid]] = mid < full

	# Lanzallamas y Psicorrayo: su potencia es por golpe; antes parecían flojísimos.
	_set_moves(ai, ["lanzallamas", "aranazo"])
	ai.moves.set_pp(ai.moves.max_pp())
	r["Un chorro cuenta todos sus golpes"] = ai.mind.move_value(0, 20.0, true) > ai.mind.move_value(1, 20.0, true)
	r["Un combo también (Doble Bofetón, 4 golpes)"] = TacticalMind.hits_of(DB.moves["doble_bofeton"]) == 4

	# La paciencia sale del entrenador, del temperamento y de la dificultad.
	r["Paciencia por clase"] = DB.trainer_style_for("Alto Mando").patience > DB.trainer_style_for("Cazabichos").patience
	ai.trainer_style = null
	var temper := Temperament.new()
	temper.patience = 0.8
	ai.temperament = temper
	r["Los salvajes usan la de su temperamento"] = is_equal_approx(ai.mind.patience(), 0.8)
	GameState.difficulty = DB.difficulties["facil"]
	r["En Fácil administra menos"] = ai.mind.patience() < 0.5
	GameState.difficulty = DB.difficulties["dificil"]

	# Sin rival expuesto y con un solo ataque: si le falta poco, junta en vez de ir a pegarte sin nada.
	_set_moves(ai, ["aranazo"])
	ai.trainer_style = elite
	ai.moves.set_pp(0.0)
	r["Sin nada para tirar también junta"] = ai.mind.pick(20.0) == -1 and ai.mind.saving
	for c in [ai, foe]:
		c.queue_free()
	await get_tree().physics_frame


## Una pelea de verdad: con paciencia tira menos veces el flojo que sin paciencia, y mientras junta se aleja sin atacar.
func _real_fight() -> void:
	var hurried := await _fight(0.0)
	var patient := await _fight(1.0)
	print("[ai-pp] sin paciencia: %s" % str(hurried))
	print("[ai-pp] con paciencia: %s" % str(patient))
	r["En pelea: con paciencia junta PP alguna vez"] = patient["saving_time"] > 0.5
	r["En pelea: sin paciencia nunca"] = hurried["saving_time"] == 0.0
	r["En pelea: con paciencia tira más la parte buena (%.0f%% vs %.0f%%)" % [100.0 * patient["good"], 100.0 * hurried["good"]]] = patient["good"] > hurried["good"]
	r["En pelea: no se queda sin atacar (usó %d ataques)" % patient["uses"]] = patient["uses"] >= 3
	r["En pelea: mientras junta no ataca"] = patient["attacks_while_saving"] == 0
	r["En pelea: mientras junta se aleja"] = patient["far_share"] > 0.5


func _fight(patience: float) -> Dictionary:
	var finder := BalanceTests.new()
	finder.world = world
	var base: Vector2 = finder._open_spot()  # (un lugar abierto: en medio de árboles no hay tiro)
	finder.free()
	var style := TrainerStyle.new()
	style.patience = patience
	var temp := Temperament.new()
	temp.flee_below = 0.0
	temp.leash = 99999.0
	var ai: Creature = _spawn("charmander", Creature.Team.ALLY, base + Vector2(-60, 0), temp)
	var foe: Creature = _spawn("bulbasaur", Creature.Team.WILD, base + Vector2(60, 0), temp)
	await get_tree().physics_frame
	await get_tree().physics_frame
	# El rival solo está para recibir: lo que se mide es cómo gasta, no quién gana.
	_set_moves(foe, [])
	foe.machine.set_physics_process(false)  # (quieto: si no, sin ataques se le viene encima y no se ve si se aleja)
	ai.trainer_style = style
	_set_moves(ai, ["llamarada", "aranazo"])
	ai.target = foe
	foe.target = ai
	ai.machine.transition_to("chase")
	var out := {"uses": 0, "good_uses": 0, "good": 0.0, "saving_time": 0.0, "attacks_while_saving": 0, "far_share": 0.0}
	var on_move := func(user: Node, m: MoveData) -> void:
		if user != ai:
			return
		out["uses"] += 1
		if m.id == "llamarada":
			out["good_uses"] += 1
		if ai.mind.saving:
			out["attacks_while_saving"] += 1
	Events.move_used.connect(on_move)
	var far := 0.0
	var t := 0.0
	while t < 12.0 and not ai.is_down() and not foe.is_down():
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		t += dt
		foe.instance.hp = foe.instance.max_hp()  # (no se termina antes de medir)
		if ai.mind.saving:
			out["saving_time"] += dt
			if ai.global_position.distance_to(foe.global_position) >= 60.0:
				far += dt
	Events.move_used.disconnect(on_move)
	out["good"] = float(out["good_uses"]) / maxf(1.0, out["uses"])
	out["far_share"] = far / maxf(0.01, out["saving_time"])
	for c in [ai, foe]:
		c.queue_free()
	await get_tree().physics_frame
	return out


func _spawn(id: String, team: int, pos: Vector2, temp: Temperament) -> Creature:
	var c: Creature = preload("res://scenes/creatures/creature.tscn").instantiate()
	c.instance = CreatureInstance.create_rival(DB.species[id], 40)
	c.team = team
	c.ai_fighter = true
	c.temperament = temp
	c.position = pos
	world.entities.add_child(c)
	c.home = pos
	c.get_node("StateMachine/Attack").flee_below = 0.0
	return c


func _set_moves(c: Creature, ids: Array) -> void:
	for i in MoveUser.SLOT_COUNT:
		c.moves.slots[i] = DB.moves[ids[i]] if i < ids.size() else null
		c.moves.cooldowns[i] = 0.0


func _avg_score(c: Creature, slot: int) -> float:
	var total := 0.0
	for i in 300:
		total += c.mind.score(slot, 20.0, true)
	return total / 300.0
