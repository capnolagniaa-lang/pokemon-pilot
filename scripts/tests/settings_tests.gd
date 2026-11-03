class_name SettingsTests
extends Node
## Autotest de los Ajustes del juego por partida (Esc → Opciones → Ajustes del juego; GameState.settings):
##   godot --headless --path . --quit-after 30000 -- --autotest-settings

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	GameState.new_game(DB.species["charmander"])
	r["Una partida nueva arranca con los valores de siempre (EXP ×0,5, vida ×3)"] = GameState.settings.is_empty() \
		and is_equal_approx(GameState.setting("exp_mult"), DB.config.exp_multiplier) \
		and is_equal_approx(CreatureInstance.hp_scale(), CreatureInstance.HP_SCALE)
	var foe := CreatureInstance.create(DB.species["rattata"], 10)
	var exp0 := CreatureInstance.exp_yield(foe)
	GameState.set_setting("exp_mult", float(GameState.setting("exp_mult")) * 2.0)
	r["Experiencia ×2 → el doble de EXP"] = abs(CreatureInstance.exp_yield(foe) - exp0 * 2) <= 1
	var inst: CreatureInstance = GameState.party[0]
	var max0 := inst.max_hp()
	inst.hp = max0 * 0.5
	GameState.set_setting("hp_scale", CreatureInstance.HP_SCALE * 2.0)
	r["Vida ×2: el doble de vida y la actual se reescala (sigue a la mitad)"] = is_equal_approx(inst.max_hp(), max0 * 2.0) \
		and is_equal_approx(inst.hp / inst.max_hp(), 0.5)
	var money0 := GameState.money
	GameState.set_setting("money_mult", 2.0)
	GameState.add_prize(100)
	r["Dinero de los premios ×2"] = GameState.money == money0 + 200
	var c0 := Capture.catch_value(foe, 1.0)
	GameState.set_setting("catch_mult", 2.0)
	r["Captura ×2"] = is_equal_approx(Capture.catch_value(foe, 1.0), c0 * 2.0)
	GameState.set_setting("ai_dodge", 0.9)
	GameState.set_difficulty("personalizado")
	r["Dificultad personalizada con los ajustes de la IA"] = GameState.difficulty_id() == "personalizado" \
		and is_equal_approx(CombatBody.difficulty().dodge_chance, 0.9)
	GameState.set_setting("ai_dodge", 0.7)
	r["Cambiar un ajuste de la IA actualiza la personalizada"] = is_equal_approx(CombatBody.difficulty().dodge_chance, 0.7)
	# Se guardan con la partida.
	var d := GameState.to_dict()
	GameState.new_game(DB.species["squirtle"])
	r["Otra partida nueva vuelve a los de siempre"] = GameState.settings.is_empty() and GameState.difficulty_id() == "normal"
	GameState.from_dict(d)
	r["Cargar la partida trae sus ajustes y su dificultad personalizada"] = is_equal_approx(GameState.setting("money_mult"), 2.0) \
		and GameState.difficulty_id() == "personalizado" and is_equal_approx(CombatBody.difficulty().dodge_chance, 0.7)
	var old := GameState.to_dict()
	old.erase("settings")
	GameState.from_dict(old)
	r["Una partida vieja (sin ajustes) usa los de siempre"] = GameState.settings.is_empty()
	GameState.from_dict(d)

	# En el mundo: daño, salvajes, curación sola.
	world = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	GameState.set_setting("dealt_mult", 2.0)
	r["Daño que hacés ×2"] = HitInfo.from(me, me.moves.slots[1]).damage_mult >= 1.99  # (ranura 1: la 0 es el básico)
	GameState.set_setting("dealt_mult", 1.0)
	# Teclas por rol (estilo LoL): básico seguido y flojo, definitiva lenta y fuerte; los rivales se ordenan solos.
	var mu: MoveUser = me.moves
	var basic := mu.slots[0]
	r["Básico: recarga corta según la Velocidad"] = mu.slot_cooldown(0, 10.0) <= 0.9 and mu.slot_cooldown(0, 10.0) >= 0.45
	r["Básico: no pasa el daño por segundo del ataque"] = basic == null or mu.role_damage(basic) <= 1.0
	GameState.set_setting("pp_mode", false)
	r["Definitiva (sin PP): recarga larga y pega más"] = mu.slot_cooldown(3, 2.0) >= 8.0 		and (mu.slots[3] == null or mu.role_damage(mu.slots[3]) > 1.0)
	GameState.set_setting("pp_mode", true)
	var weak := MoveData.new(); weak.power = 40.0
	var strong := MoveData.new(); strong.power = 120.0
	var buff := MoveData.new(); buff.category = MoveData.Category.STATUS
	var sorted := MoveUser.by_role([strong, buff, weak] as Array[MoveData])
	r["Rivales: el más flojo de básico y el más fuerte de definitiva"] = sorted[0] == weak and sorted[-1] == strong
	# PP como maná (pedido del usuario 2026-10-31): barra que crece con el nivel, cada ataque gasta, el básico no.
	var lvl := me.instance.level
	r["PP: la barra crece con el nivel (Nv. %d = %d)" % [lvl, int(mu.max_pp())]] = is_equal_approx(mu.max_pp(), 		MoveUser.PP_BASE + MoveUser.PP_PER_LEVEL * lvl)
	var heavy := MoveData.new(); heavy.power = 150.0
	r["PP: los fuertes gastan más (Hiperrayo %d, Placaje %d)" % [MoveUser.pp_cost_of(heavy), MoveUser.pp_cost_of(weak)]] = 		MoveUser.pp_cost_of(heavy) > MoveUser.pp_cost_of(weak) * 2.0
	# Como en Pokemon Arena 2D (2026-11-01): potencia 65 ≈ 20 % de la barra de referencia, 85 ≈ 40 %.
	var mid := MoveData.new(); mid.power = 65.0
	var big := MoveData.new(); big.power = 85.0
	r["PP: 65 de potencia ≈ 20 %% y 85 ≈ 40 %% (%d y %d PP)" % [MoveUser.pp_cost_of(mid), MoveUser.pp_cost_of(big)]] = 		is_equal_approx(MoveUser.cost_fraction(65.0), 0.2) and is_equal_approx(MoveUser.cost_fraction(85.0), 0.4)
	var stream := MoveData.new(); stream.power = 90.0; stream.kind = MoveData.Kind.CHANNEL; stream.channel_time = 1.0
	var keep := mu.slots[1]
	mu.slots[1] = stream
	var upfront := mu.pp_cost(1) * MoveUser.PP_CHANNEL_UPFRONT
	r["PP: un canalizado paga una parte al empezar y el resto mientras sale"] = mu.channel_drain(stream) > 0.0 		and absf(upfront + mu.channel_drain(stream) * stream.channel_time - mu.pp_cost(1)) < 0.01
	mu.slots[1] = keep
	r["PP: el básico es gratis"] = mu.pp_cost(0) == 0.0
	var paid := -1
	for i in [1, 2, 3]:
		if mu.slots[i] != null:
			paid = i
			break
	if paid >= 0:
		mu.reset_cooldown(paid)
		mu.set_pp(mu.max_pp())
		var before_pp := mu.pp()
		var cost := mu.pp_cost(paid)
		me.use_slot(paid, Vector2.RIGHT)
		r["PP: usar un ataque gasta su costo (%d)" % int(cost)] = absf(before_pp - mu.pp() - cost) < 2.0
		mu.set_pp(cost - 1.0)
		mu.reset_cooldown(paid)
		r["PP: sin PP suficientes no sale"] = not mu.can_use(paid)
		mu.set_pp(mu.max_pp())
		r["PP: la recarga queda corta (%.2f s)" % mu.slot_cooldown(paid, 10.0)] = mu.slot_cooldown(paid, 10.0) <= MoveUser.PP_COOLDOWN_MAX
	# Nerf del 2026-11-03: todo ×1,5 y las curas gastan una parte de la barra y solo salen con un rival cerca.
	r["PP: los costos subieron ×1,5 (65 de potencia = %d)" % MoveUser.pp_cost_of(mid)] = MoveUser.pp_cost_of(mid) == 66.0 \
		and MoveUser.pp_cost_of(buff) == MoveUser.PP_STATUS_COST
	var rest: MoveData = load("res://data/moves/descanso.tres")
	var keep_heal := mu.slots[1]
	mu.slots[1] = rest
	mu.reset_cooldown(1)
	mu.set_pp(mu.max_pp())
	r["Curas: Descanso gasta el 60 %% de la barra (%d de %d)" % [mu.pp_cost(1), mu.max_pp()]] = MoveUser.is_heal(rest) \
		and is_equal_approx(mu.pp_cost(1), roundf(mu.max_pp() * 0.6))
	r["Curas: sin un rival cerca no salen"] = not me.foe_near() and not mu.can_use(1) and not me.use_slot(1, Vector2.RIGHT)
	var wild: Creature = load("res://scenes/creatures/creature.tscn").instantiate()
	wild.instance = CreatureInstance.create(DB.species["rattata"], 5)
	wild.team = Creature.Team.WILD
	wild.position = me.global_position + Vector2(60, 0)
	wild.process_mode = Node.PROCESS_MODE_DISABLED  # quieto: que no arranque una pelea
	me.get_parent().add_child(wild)
	await get_tree().physics_frame
	r["Curas: con un rival cerca sí"] = me.foe_near() and mu.can_use(1)
	wild.queue_free()
	mu.slots[1] = keep_heal
	me.instance.pp = 10.0
	GameState.heal_party()
	r["PP: curarse los llena"] = is_equal_approx(mu.pp(), mu.max_pp())
	GameState.set_setting("pp_mode", false)
	r["Sin PP: nada gasta"] = mu.pp_cost(1) == 0.0 and mu.pp_cost(3) == 0.0
	GameState.set_setting("pp_mode", true)
	GameState.set_setting("slot_roles", false)
	GameState.set_setting("pp_mode", false)
	r["Sin teclas por rol ni PP: recargas de siempre"] = is_equal_approx(mu.slot_cooldown(0, 3.0), 3.0) and is_equal_approx(mu.slot_cooldown(3, 3.0), 3.0)
	GameState.set_setting("slot_roles", true)
	GameState.set_setting("pp_mode", true)
	GameState.set_setting("dealt_mult", 2.0)
	GameState.set_setting("wild_mult", 0.0)
	r["Cantidad de salvajes ×0 → no aparece ninguno"] = world.spawner.max_alive(world.streamer.current.id) == 0
	world.combat.end_battle()
	GameState.set_setting("regen", true)
	var mine: CreatureInstance = GameState.party[0]
	mine.hp = mine.max_hp() * 0.5
	var h0 := mine.hp
	await get_tree().create_timer(1.0).timeout
	r["Curación sola fuera de combate (si la prendés)"] = mine.hp > h0
	# La pantalla: mover un deslizador cambia el ajuste.
	var layer := CanvasLayer.new()
	add_child(layer)
	var screen := GameSettingsScreen.new()
	layer.add_child(screen)
	await get_tree().process_frame
	(screen.controls["taken_mult"] as HSlider).value = 0.5
	(screen.controls["field_items"] as CheckBox).button_pressed = false
	r["La pantalla cambia los ajustes (daño recibido ×0,5, sin objetos)"] = is_equal_approx(GameState.setting("taken_mult"), 0.5) \
		and GameState.setting("field_items") == false
	GameState.reset_settings()
	screen.refresh()
	r["Valores por defecto"] = GameState.settings.is_empty() \
		and is_equal_approx((screen.controls["taken_mult"] as HSlider).value, 1.0)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[ajustes] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-settings] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina: la pantalla de ajustes abierta desde Esc → Opciones.
##   godot --path . --quit-after 40 --write-movie out/f.png --fixed-fps 30 -- --showcase-settings
func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	world.pause_menu.try_open()
	world.pause_menu.push(GameSettingsScreen.new())
