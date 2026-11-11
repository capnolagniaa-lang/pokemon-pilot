class_name RogueFoeTests
extends Node
## Autotest de las mejoras enemigas del Modo Desafío (RogueFoeMods; paso O-d de docs/PROPUESTA_ROGUELIKE.md) y de los
## números de dificultad (EXP, esbirros, fichas).
##   godot --headless --path . --fixed-fps 60 --quit-after 60000 -- --autotest-rogue-foes
## Vitrina (una oleada de élites con mejoras, de cerca):
##   godot --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-rogue-foes

var world: Node
var run: RogueRun
var mods: RogueFoeMods
var me: Creature


func run_tests() -> void:
	var r := {}
	var f := RogueRun.load_floor()
	r["Menos EXP que en la historia (×%.1f; antes ×3): no se dispara de nivel" % float(f["exp_mult"])] = float(f["exp_mult"]) <= 1.0
	r["Esbirros más duros: %d %% de vida (antes 45) y hasta %d atacando a la vez (antes 3)" % [roundi(100.0 * float(f["minion_hp"])), int(f["attackers"])]] = \
		float(f["minion_hp"]) > 0.45 and float(f["minion_hp"]) < 1.0 and int(f["attackers"]) == 4
	var list: Dictionary = f["foe_mods"]["list"]
	var missing: Array[String] = []
	for id: String in list:
		if not ResourceLoader.exists(RogueFoeMods.icon_of(id)):
			missing.append("ícono de " + id)
		if str(list[id].get("text", "")) == "" or str(list[id].get("name", "")) == "":
			missing.append("texto de " + id)
	r["Hay %d mejoras enemigas, cada una con nombre, texto e ícono%s" % [list.size(), "" if missing.is_empty() else " — " + "; ".join(missing)]] = \
		missing.is_empty() and list.size() >= 5

	RogueRun.begin(DB.species["squirtle"])
	GameState.rogue["biomes"] = ["bosque", "cueva", "volcan", "hielo", "costa"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	mods = run.foe_mods
	me = world.companion
	r["La EXP de la partida es la del piso (×%.2f sobre la oficial)" % float(GameState.setting("exp_mult"))] = \
		is_equal_approx(float(GameState.setting("exp_mult")), float(DB.config.exp_multiplier) * float(f["exp_mult"]))
	r["En la sala 1 nadie lleva mejoras"] = run.foes.all(func(e): return RogueFoeMods.of(e).is_empty()) and mods.count_for(0, false, 0) == 0 \
		and mods.count_for(0, true, 0) == 0
	var grow := true
	var last_power := 0
	for i in f["slots"].size():
		var power: int = mods.count_for(i, true, 0) * mods.level_for(i) * 10 + mods.count_for(i, false, 0)
		if power < last_power:
			grow = false
		last_power = power
	r["Crecen con las salas: en la última, cada élite lleva %d de nivel %d y hay %d campeón por oleada" % [mods.count_for(4, true, 0), mods.level_for(4),
		int(f["slots"][4].get("champions", 0))]] = grow and mods.count_for(4, true, 0) >= 1 and mods.level_for(4) >= 2 and mods.count_for(4, false, 0) == 1 \
		and mods.count_for(4, false, 5) == 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var seen := {}
	var distinct := true
	for n in 200:
		var got: Array = mods.roll(2, 1, rng)
		if got.size() != 2 or got[0]["id"] == got[1]["id"]:
			distinct = false
		for m in got:
			seen[m["id"]] = true
	r["El sorteo da mejoras distintas y en 200 tiradas salen todas (%s)" % ", ".join(seen.keys())] = distinct and seen.size() == list.size()
	r["A más nivel, más número (Furioso: %s → %s)" % [mods.describe("furioso", 1), mods.describe("furioso", 2)]] = \
		mods.value("furioso", 2) > mods.value("furioso", 1) and mods.describe("furioso", 1).contains("%")

	# --- En la sala: una oleada de la última sala (un élite y dos esbirros) ---
	_clear()
	run.room_index = 4
	run._spawn_wave([["beedrill", 8, true], ["rattata", 5], ["pidgey", 5]])
	await get_tree().physics_frame
	await get_tree().physics_frame
	var elite: Creature = run.foes[0]
	var champ: Creature = run.foes[1]
	var plain: Creature = run.foes[2]
	r["El élite sale con su mejora (%s), el primer esbirro es campeón (%s) y el otro no lleva nada" % [
		", ".join(RogueFoeMods.of(elite).map(func(m): return mods.mod_name(m["id"]))), ", ".join(RogueFoeMods.of(champ).map(func(m): return mods.mod_name(m["id"])))]] = \
		RogueFoeMods.of(elite).size() == mods.count_for(4, true, 0) and int(RogueFoeMods.of(elite)[0]["level"]) == 2 \
		and RogueFoeMods.of(champ).size() == 1 and RogueFoeMods.of(plain).is_empty()
	var badge: RogueFoeBadge = _badge(elite)
	r["Se ve: ícono sobre la cabeza del que la lleva (y no sobre el que no)"] = badge != null and badge.textures.size() == RogueFoeMods.of(elite).size() \
		and badge.textures.all(func(t): return t != null) and _badge(champ) != null and _badge(plain) == null

	# --- Cada mejora hace lo que dice ---
	var base := CreatureInstance.create_rival(DB.species["beedrill"], 8)
	_clear()
	GameState.rogue["force_mods"] = [{"id": "blindado", "level": 1}]
	run._spawn_wave([["beedrill", 8, true]])
	await get_tree().physics_frame
	var foe: Creature = run.foes[0]
	base.ivs = foe.instance.ivs.duplicate()
	r["Blindado: %d %% más de vida (%d contra %d), y arranca lleno" % [roundi(100.0 * mods.value("blindado", 1)), roundi(foe.instance.max_hp()), roundi(base.max_hp())]] = \
		is_equal_approx(foe.instance.max_hp(), base.max_hp() * (1.0 + mods.value("blindado", 1))) and is_equal_approx(foe.instance.hp, foe.instance.max_hp())
	foe = await _one("furioso", 2)
	me.health.heal(99999.0)
	var before := me.instance.hp
	foe.hit_dealt.emit(me, HitInfo.new(), 20.0)
	r["Furioso (Nv. 2): su golpe de 20 te saca %.1f más" % (before - me.instance.hp)] = is_equal_approx(before - me.instance.hp, 20.0 * mods.value("furioso", 2)) \
		and mods.value("furioso", 2) > 0.3
	foe = await _one("ardiente", 9)
	me.statuses.clear()
	foe.hit_dealt.emit(me, HitInfo.new(), 5.0)
	r["Ardiente: su golpe te deja Quemado"] = me.statuses.has_status("quemado")
	foe = await _one("electrico", 9)
	me.statuses.clear()
	foe.hit_dealt.emit(me, HitInfo.new(), 5.0)
	r["Eléctrico: su golpe te deja Paralizado"] = me.statuses.has_status("paralizado") or me.statuses.meter("paralizado") > 0.0
	me.statuses.clear()
	foe = await _one("regenerador", 1)
	foe.process_mode = Node.PROCESS_MODE_DISABLED  # (que no pelee: solo se mira la vida)
	foe.instance.hp = foe.instance.max_hp() * 0.5
	var hp0 := foe.instance.hp
	await get_tree().create_timer(3.2).timeout
	var gained: float = (foe.instance.hp - hp0) / foe.instance.max_hp()
	r["Regenerador: en 3 s recuperó %.1f %% de su vida" % (gained * 100.0)] = gained >= mods.value("regenerador", 1) * 2.0 - 0.001 \
		and gained <= mods.value("regenerador", 1) * 4.0 + 0.001
	GameState.rogue.erase("force_mods")

	# --- El jefe ---
	var team: Array[CreatureInstance] = []
	for m in f["boss"]["team"]:
		team.append(CreatureInstance.create_rival(DB.species[m[0]], int(m[1])))
	mods.assign_boss(team)
	r["Los Pokémon de Brock también: %s" % ", ".join(team.map(func(t): return "%s (%s)" % [t.species.display_name,
		", ".join(RogueFoeMods.of(t).map(func(m): return mods.mod_name(m["id"])))]))] = \
		range(team.size()).all(func(i): return RogueFoeMods.of(team[i]).size() == int(f["boss"]["mods"][i])) and RogueFoeMods.of(team[-1]).size() >= 1
	var out := CreatureInstance.create_rival(DB.species["rattata"], 5)
	r["Fuera del modo nadie lleva mejoras"] = RogueFoeMods.of(out).is_empty()

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[enemigos] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-foes] -> ", "OK" if ok else "FALLO")
	GameState.rogue = {}
	get_tree().quit(0 if ok else 1)


## Saca un élite con esa mejora sola (y limpia lo anterior).
func _one(id: String, level: int) -> Creature:
	_clear()
	GameState.rogue["force_mods"] = [{"id": id, "level": level}]
	run._spawn_wave([["beedrill", 8, true]])
	await get_tree().physics_frame
	await get_tree().physics_frame
	return run.foes[0]


func _clear() -> void:
	for e in run.foes:
		if is_instance_valid(e):
			e.queue_free()
	run.foes.clear()
	world.combat.enemies.clear()


func _badge(c: Creature) -> RogueFoeBadge:
	for n in c.get_children():
		if n is RogueFoeBadge:
			return n
	return null


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


## Vitrina: tres élites con mejoras al lado tuyo.
func showcase() -> void:
	RogueRun.begin(DB.species["charmander"])
	GameState.rogue["biomes"] = ["bosque", "cueva", "volcan", "hielo", "costa"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	me = world.companion
	_clear()
	run.room_index = 4
	GameState.rogue["force_mods"] = [{"id": "furioso", "level": 2}, {"id": "regenerador", "level": 2}]
	run._spawn_wave([["beedrill", 9, true]])
	GameState.rogue["force_mods"] = [{"id": "ardiente", "level": 1}]
	run._spawn_wave([["pidgeotto", 9, true]])
	GameState.rogue["force_mods"] = [{"id": "blindado", "level": 1}, {"id": "electrico", "level": 1}]
	run._spawn_wave([["butterfree", 9, true]])
	var k := 0
	for e: Creature in run.foes:
		e.global_position = me.global_position + Vector2(-46 + 46 * k, -40)
		e.process_mode = Node.PROCESS_MODE_DISABLED
		e.health.apply_damage(e.instance.max_hp() * 0.2)
		k += 1
	await get_tree().physics_frame
	for e: Creature in run.foes:
		for n in e.get_children():
			if n is RogueFoeBadge:
				n.process_mode = Node.PROCESS_MODE_ALWAYS
	world.camera.snap()
	await get_tree().create_timer(60.0).timeout
