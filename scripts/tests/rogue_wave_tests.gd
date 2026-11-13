class_name RogueWaveTests
extends Node
## Autotest de R-1 del Modo Desafío (docs/PROPUESTA_ROGUELIKE.md): esbirros con vida propia y fichas de ataque.
##   godot --headless --path . --fixed-fps 60 --quit-after 60000 -- --autotest-rogue-waves

var world: Node
## Segundos que se mira a la oleada atacar.
const WATCH := 24.0


func run() -> void:
	var r := {}
	var f := RogueRun.load_floor()
	var limit := int(f["attackers"])
	var normal := CreatureInstance.create_rival(DB.species["rattata"], 5)
	var full_hp := normal.max_hp()
	r["Fuera del modo nadie cambia: vida propia ×1 y sin permiso que pedir"] = is_equal_approx(normal.hp_mult, 1.0)
	var minion := CreatureInstance.create_rival(DB.species["rattata"], 5)
	minion.ivs = normal.ivs.duplicate()
	RogueRun.make_minion(minion, f)
	r["Un esbirro tiene %d %% de la vida (%d contra %d) y arranca lleno" % [int(100.0 * float(f["minion_hp"])), int(minion.max_hp()), int(full_hp)]] = \
		is_equal_approx(minion.max_hp(), full_hp * float(f["minion_hp"])) and is_equal_approx(minion.hp, minion.max_hp()) \
		and float(f["minion_hp"]) < 1.0
	var moves: Array = minion.equipped_moves.filter(func(m): return m != null)
	r["Y pelea con a lo sumo %d ataques, todos de daño (%s)" % [int(f["minion_moves"]), ", ".join(moves.map(func(m): return m.display_name))]] = \
		moves.size() >= 1 and moves.size() <= int(f["minion_moves"]) and moves.all(func(m): return m.power > 0.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var story: Array = RogueRun.plan_rooms(f, rng)  # el recorrido del anime, tal cual está escrito
	var eps: Array = story.map(func(room): return str(room.get("episode", "")))
	var samurai: Array = story.filter(func(room): return str(room.get("rival", "")) != "")
	r["El primer tramo sigue el anime: %s" % " / ".join(eps)] = eps.all(func(e): return e.begins_with("EP ")) 		and story[0]["waves"][0].all(func(m): return m[0] == "spearow") and story.all(func(room): return room["biome"] == "bosque") 		and story.all(func(room): return room["waves"].all(func(w): return w.size() <= 3))
	r["Un rival del anime manda a los suyos de a uno y el último es el del objeto (%s)" % (str(samurai[0]["rival"]) if samurai.size() == 1 else "-")] = 		samurai.size() == 1 and samurai[0]["waves"].size() == 2 and samurai[0]["waves"].all(func(w): return w.size() == 1) 		and str(samurai[0]["waves"][0][0][3]) == "rival" and str(samurai[0]["waves"][1][0][3]) == "duelo" and samurai[0]["waves"][1][0][0] == "pinsir"
	f = RogueRun.unscripted(f)
	var plan: Array = RogueRun.plan_rooms(f, rng)
	var elite_ok := true
	var bigger := false
	for i in plan.size():
		var slot: Dictionary = f["slots"][i]
		for w in plan[i]["waves"].size():
			var strong: bool = slot.get("duel", false) or (slot.get("strong_last", false) and w == plan[i]["waves"].size() - 1)
			if plan[i]["waves"][w].size() > limit:
				bigger = true
			for m in plan[i]["waves"][w]:
				if bool(m[2]) != strong:
					elite_ok = false
	r["En el plan, solo la oleada fuerte es de élites (vida entera)"] = elite_ok
	r["Ninguna oleada del plan pasa de 3 enemigos a la vez"] = not bigger and limit <= 3
	var duels: Array = plan.filter(func(room): return room.get("duel", false))
	r["El plan tiene una sala de élite: una sola oleada de un solo Pokémon, de los fuertes de su bioma"] = duels.size() == 1 		and duels[0]["waves"].size() == 1 and duels[0]["waves"][0].size() == 1 		and f["biomes"][duels[0]["biome"]]["strong"].has(duels[0]["waves"][0][0][0])

	# --- En una sala: 7 esbirros contra vos, que no hacés nada ---
	RogueRun.begin(DB.species["squirtle"])
	GameState.rogue["biomes"] = ["bosque", "volcan", "cueva", "hielo", "costa"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	var run: RogueRun = world.rogue
	run._spawn_wave([["rattata", 3], ["pidgey", 3], ["caterpie", 3], ["weedle", 3], ["spearow", 3], ["oddish", 3], ["beedrill", 4, true]])
	await get_tree().physics_frame
	var foes: Array[Creature] = run.foes.duplicate()
	var minions := foes.filter(func(e): return e.instance.hp_mult < 1.0)
	var elites := foes.filter(func(e): return is_equal_approx(e.instance.hp_mult, 1.0))
	r["En la sala salen esbirros (%d) y el élite con la vida entera (%d), todos pidiendo ficha" % [minions.size(), elites.size()]] = \
		minions.size() >= 6 and elites.size() == 1 and elites[0].instance.species.id == "beedrill" \
		and foes.all(func(e): return e.attack_gate.is_valid())
	var me: Creature = world.companion
	var held := {}  # enemigo -> último momento con ficha
	var holders := {}
	var most := 0
	var attacks := [0]
	var without := [0]
	var clock := [0.0]
	for e: Creature in foes:
		e.slot_used.connect(func(_s, _a, _p):
			attacks[0] += 1
			if not run.tokens.has(e):
				without[0] += 1)
	var idle_dist := [0.0]
	var idle_n := [0]
	var t := 0.0
	while t < WATCH:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		clock[0] = t
		if is_instance_valid(me):
			me.health.heal(99999.0)  # (no se mide la pelea: que no caiga)
			me.statuses.clear()
		for e: Creature in foes:
			if is_instance_valid(e) and not e.is_down():
				e.health.heal(99999.0)
		var now := 0
		for k in run.tokens.keys():
			if is_instance_valid(k) and float(run.tokens[k]) > run._clock:
				now += 1
				held[k] = t
				holders[k] = true
		most = maxi(most, now)
		for e: Creature in foes:
			if is_instance_valid(e) and is_instance_valid(me) and not run.tokens.has(e):
				idle_dist[0] += e.global_position.distance_to(me.global_position)
				idle_n[0] += 1
	r["Nunca hay más de %d con ficha a la vez (máximo visto: %d)" % [limit, most]] = most <= limit and most >= 2
	r["Atacan (%d ataques en %d s) y solo los que tienen ficha (%d sin ficha)" % [attacks[0], int(WATCH), without[0]]] = \
		attacks[0] >= 8 and without[0] == 0
	r["Las fichas rotan: %d de %d enemigos llegaron a atacar" % [holders.size(), foes.size()]] = holders.size() >= 5
	var avg: float = float(idle_dist[0]) / maxf(1.0, float(idle_n[0]))
	r["Los que no tienen ficha esperan alrededor, no encima (a %d px en promedio)" % int(avg)] = avg > 40.0
	run.floor_data["attackers"] = 0
	r["Con el límite en 0 atacan todos"] = foes.all(func(e): return not is_instance_valid(e) or run.can_attack(e))

	# --- Sala de élite: uno solo, de tu nivel, con kit entero y un objeto puesto ---
	for e: Creature in run.foes.duplicate():
		if is_instance_valid(e):
			e.queue_free()
	run.foes.clear()
	GameState.active().level = 14
	run._spawn_wave([["scyther", 9, true, "duelo"]])
	await get_tree().physics_frame
	var boss: Creature = run.foes[0] if run.foes.size() == 1 else null
	var bmods: Array = RogueFoeMods.of(boss) if boss != null else []
	r["El élite del duelo sale solo, a tu nivel (%d), con la vida entera y las 4 teclas de su kit" % (boss.instance.level if boss != null else 0)] = 		boss != null and boss.instance.level == 14 and boss.instance.hp_mult >= 1.0 and boss.instance.rogue_kit != null 		and boss.instance.equipped_moves.size() == 4 and boss.instance.kit_limit == 4
	r["Lleva un objeto que se ve (%s) y hace efecto (%s)" % [str(bmods[0].get("name", "")) if not bmods.is_empty() else "-",
		run.foe_mods.describe(bmods[0]["id"], bmods[0]["level"]) if not bmods.is_empty() else "-"]] = bmods.size() == 1 		and DB.rogue_items.has(str(boss.instance.get_meta("rogue_item", ""))) and ResourceLoader.exists(str(bmods[0].get("icon", ""))) 		and run.foe_mods.list().has(bmods[0]["id"])

	# --- Tramos: hasta el tercer líder, con la misma cantidad de salas antes de cada uno ---
	var all: Array = RogueRun.acts_of(RogueRun.load_floor())
	var bosses: Array = all.map(func(a): return str(a["boss"]["name"]))
	r["La partida tiene 3 tramos (%s) con %d salas cada uno y una sala de élite en cada tramo" % [", ".join(bosses), all[0]["slots"].size()]] = 		bosses == ["Brock", "Misty", "Lt. Surge"] and all.all(func(a): return a["slots"].size() == all[0]["slots"].size() 		and a["slots"].filter(func(s): return s.get("duel", false)).size() == 1)
	r["Cada líder tiene su gimnasio, su retrato, su equipo y su medalla"] = all.all(func(a): return 		ResourceLoader.exists("res://data/arenas/%s.tres" % a["boss"]["arena"]) and ResourceLoader.exists("res://sprites/vs/%s.png" % a["boss"]["gfx"]) 		and ResourceLoader.exists("res://art/pret/characters/%s.png" % a["boss"]["gfx"]) and DB.npcs.has(a["boss"]["trainer_id"]) 		and a["boss"]["team"].all(func(m): return DB.species.has(m[0])) and str(a["boss"].get("badge", "")) != "")
	r["Los niveles suben de tramo en tramo"] = int(all[1]["slots"][0]["levels"][0]) > int(all[0]["slots"][-1]["levels"][1]) 		and int(all[2]["slots"][0]["levels"][0]) > int(all[1]["slots"][-1]["levels"][1])
	await run.start_act(1)
	r["El segundo tramo arma salas nuevas hacia Misty y te deja en la entrada de la primera"] = run.act == 1 		and run.floor_data["boss"]["name"] == "Misty" and run.chain.size() == all[1]["slots"].size() and run.room_index == 0 		and is_instance_valid(world.companion) and int(run.floor_data["rooms"][0]["waves"][0][0][1]) >= int(all[1]["slots"][0]["levels"][0]) 		and world.companion.global_position.distance_to(run._cell_pos(run.room_data.player_mon_cell)) < 40.0

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[oleadas] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-waves] -> ", "OK" if ok else "FALLO")
	GameState.rogue = {}
	get_tree().quit(0 if ok else 1)


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()
