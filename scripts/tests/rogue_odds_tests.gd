class_name RogueOddsTests
extends Node
## Autotest de los pasos O-a y O-c del Modo Desafío (docs/PROPUESTA_ROGUELIKE.md, sección 11): pesos por necesidad en
## las puertas, la recompensa Poké Ball, el reroll pagado y la suerte por Pokédex del modo.
##   godot --headless --path . --fixed-fps 60 --quit-after 60000 -- --autotest-rogue-odds

var world: Node
var run: RogueRun
var rewards: RogueRewards
var boons: RogueBoons
var inst: CreatureInstance
var _busy := false


func run_tests() -> void:
	var r := {}
	DirAccess.remove_absolute(RogueProgress.TEST_PATH)
	var f := RogueRun.load_floor()
	var w: Dictionary = f["rewards"]["weights"]
	RogueRun.begin(DB.species["squirtle"])
	GameState.rogue["biomes"] = ["bosque", "cueva", "volcan", "hielo", "costa"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	rewards = run.rewards
	boons = run.boons
	inst = GameState.active()
	for e: Creature in run.foes:
		e.process_mode = Node.PROCESS_MODE_DISABLED

	# --- Pesos por necesidad ---
	inst.hp = inst.max_hp()
	var full := rewards.weight_of("centro")
	var full_share := _share("centro")
	inst.hp = inst.max_hp() * 0.3
	var low := rewards.weight_of("centro")
	var low_share := _share("centro")
	r["Centro: con la vida entera casi no sale (peso %.1f, en %d %% de las puertas) y con 30 %% sale seguro (peso %.1f, %d %%)" % [full, roundi(full_share * 100),
		low, roundi(low_share * 100)]] = is_equal_approx(full, float(w["centro"]) * 0.3) and is_equal_approx(low, float(w["centro"]) * 3.0) \
		and full_share < 0.15 and is_equal_approx(low_share, 1.0)
	inst.hp = inst.max_hp()
	GameState.money = 0
	var broke := rewards.weight_of("tienda")
	GameState.money = 500
	r["Tienda: sin plata no se ofrece; alcanzando para dos cosas pesa más"] = is_zero_approx(broke) and is_equal_approx(rewards.weight_of("tienda"), float(w["tienda"]) * 1.5)
	GameState.money = 0
	GameState.bag["poke_ball"] = 0
	var none := rewards.weight_of("bola")
	GameState.bag["poke_ball"] = 2
	var two := rewards.weight_of("bola")
	GameState.bag["poke_ball"] = 3
	r["Poké Ball: sin bolas pesa el doble (%.0f), con 2 lo normal (%.0f) y con 3 casi nada (%.1f)" % [none, two, rewards.weight_of("bola")]] = \
		is_equal_approx(none, float(w["bola"]) * 2.0) and is_equal_approx(two, float(w["bola"])) and is_equal_approx(rewards.weight_of("bola"), float(w["bola"]) * 0.3)
	GameState.bag["poke_ball"] = 2
	await rewards.grant("bola")
	r["La recompensa Poké Ball da una bola más"] = GameState.item_count("poke_ball") == 3 and ResourceLoader.exists(RogueRewards.icon_of("bola"))
	var empty := rewards.weight_of("objeto")
	GameState.rogue["items"] = [{"id": "restos", "rarity": "comun", "level": 3}, {"id": "periscopio", "rarity": "comun", "level": 3},
		{"id": "casco_dentado", "rarity": "comun", "level": 3}]
	var maxed := rewards.weight_of("objeto")
	GameState.rogue["items"][0]["level"] = 1
	r["Objeto: con ranuras libres pesa más (%.0f); con las 3 al máximo, casi nada (%.1f); si no, lo normal (%.0f)" % [empty, maxed, rewards.weight_of("objeto")]] = \
		is_equal_approx(empty, float(w["objeto"]) * 1.5) and is_equal_approx(maxed, float(w["objeto"]) * 0.3) and is_equal_approx(rewards.weight_of("objeto"), float(w["objeto"]))
	GameState.rogue["items"] = []
	var no_boons := rewards.weight_of("caramelo")
	boons.take("sobrecarga")
	var one := rewards.weight_of("caramelo")
	boons.take("brasas")
	boons.take("pila")
	boons.entry("pila")["level"] = RogueBoons.MAX_LEVEL
	r["Caramelo Raro: sin bendiciones no sale; crece con las que podés subir (%.0f con una, %.0f con dos y otra al máximo)" % [one, rewards.weight_of("caramelo")]] = \
		is_zero_approx(no_boons) and is_equal_approx(one, float(w["caramelo"]) * 0.75) and is_equal_approx(rewards.weight_of("caramelo"), float(w["caramelo"]))
	GameState.rogue["boons"] = []
	boons.changed.emit()
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	var useless := false
	for n in 400:
		for id in rewards.options(rng):
			if not rewards.available(id):
				useless = true
	r["Nunca se ofrece algo inútil (400 pares de puertas sin plata ni bendiciones)"] = not useless

	# --- Reroll ---
	run.rooms_cleared = 0
	var base := int(f["rewards"]["reroll"]["base"])
	var costs: Array = [rewards.reroll_cost(0), rewards.reroll_cost(1), rewards.reroll_cost(2)]
	run.rooms_cleared = 4
	var later := rewards.reroll_cost(0)
	run.rooms_cleared = 0
	r["El reroll cuesta $%d, se duplica con cada uno seguido (%s) y sube con las salas ($%d en la quinta)" % [base, ", ".join(costs.map(func(c): return "$%d" % c)), later]] = \
		costs == [base, base * 2, base * 4] and later == roundi(float(base) * (1.0 + 4.0 * float(f["rewards"]["reroll"]["room_step"])))
	GameState.money = 0
	_grant("bendicion")
	await _until(func(): return is_instance_valid(run.boon_screen), 3.0)
	await get_tree().process_frame
	var s1: BoonScreen = run.boon_screen
	s1.choose(-1)
	await get_tree().process_frame
	r["Sin plata el botón de cambiar las opciones está apagado y no hace nada"] = is_instance_valid(s1) and s1.reroll != null and s1.reroll.disabled \
		and run.boon_screen == s1 and s1.reroll.text.contains("$%d" % base)
	GameState.money = base * 3 + 10
	s1.choose(0)
	await _until(func(): return not _busy, 3.0)
	GameState.rogue["boons"] = []
	_grant("bendicion")
	await _until(func(): return is_instance_valid(run.boon_screen), 3.0)
	await get_tree().process_frame
	var a: BoonScreen = run.boon_screen
	a.choose(-1)
	await _until(func(): return is_instance_valid(run.boon_screen) and run.boon_screen != a, 3.0)
	await get_tree().process_frame
	var b: BoonScreen = run.boon_screen
	var after_one := GameState.money
	var second_cost: int = b.reroll_cost
	b.choose(-1)
	await _until(func(): return is_instance_valid(run.boon_screen) and run.boon_screen != b, 3.0)
	await get_tree().process_frame
	var c: BoonScreen = run.boon_screen
	var third_off: bool = c.reroll.disabled and c.reroll_cost == base * 4
	c.choose(0)
	await _until(func(): return not _busy, 3.0)
	r["Con plata: cada reroll trae otra oferta y cobra ($%d → $%d → $%d); el tercero ya no alcanza; al final elegís una" % [base * 3 + 10, after_one, GameState.money]] = \
		after_one == base * 2 + 10 and second_cost == base * 2 and GameState.money == 10 and third_off and boons.owned().size() == 1 and not get_tree().paused
	GameState.money = 200
	_grant("objeto")
	await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
	await get_tree().process_frame
	var i1: RewardScreen = run.reward_screen
	var first_titles: Array = i1.cards_data.map(func(x): return x["title"])
	i1.choose(-1)
	await _until(func(): return is_instance_valid(run.reward_screen) and run.reward_screen != i1, 3.0)
	await get_tree().process_frame
	var i2: RewardScreen = run.reward_screen
	var paid := GameState.money == 200 - base
	i2.choose(0)
	await _until(func(): return not _busy, 3.0)
	r["Los objetos también se pueden cambiar pagando (%s → otra oferta)" % ", ".join(first_titles)] = paid and i2.reroll != null and boons.items().size() == 1
	_grant("caramelo")
	await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
	await get_tree().process_frame
	var candy: RewardScreen = run.reward_screen
	var candy_plain: bool = candy.reroll == null
	candy.choose(0)
	await _until(func(): return not _busy, 3.0)
	r["Caramelo Raro, MT y Tienda no tienen reroll"] = candy_plain

	# --- Suerte ---
	r["Sin capturas la suerte es 0 (los 3 de base no cuentan)"] = RogueProgress.luck() == 0 and boons.luck() == 0 and RogueProgress.caught_count() == 0
	for id in ["pidgey", "rattata", "caterpie", "weedle", "oddish", "zubat", "geodude"]:
		RogueProgress.unlock(id)
	r["Cada %d Pokémon rescatados = 1 de suerte (7 rescatados: %d); un inicial shiny suma %d (%d)" % [RogueProgress.LUCK_EVERY, RogueProgress.luck(),
		RogueProgress.LUCK_SHINY, RogueProgress.luck(true)]] = RogueProgress.luck() == 2 and RogueProgress.luck(true) == 2 + RogueProgress.LUCK_SHINY \
		and boons.luck() == 2
	inst.shiny = true
	var shiny_luck := boons.luck()
	inst.shiny = false
	for n in 40:
		RogueProgress.unlock(DB.species.keys()[n])
	r["La suerte de la partida cuenta el shiny (%d) y la de la Pokédex tiene tope (%d)" % [shiny_luck, RogueProgress.luck()]] = shiny_luck == 2 + RogueProgress.LUCK_SHINY \
		and RogueProgress.luck() == RogueProgress.LUCK_CAP
	var plain := _rarities(0)
	var lucky := _rarities(RogueProgress.LUCK_CAP + RogueProgress.LUCK_SHINY)
	r["En 5000 tiradas, con suerte 0: %d comunes y %d legendarias; con suerte %d: %d y %d" % [plain["comun"], plain["legendaria"],
		RogueProgress.LUCK_CAP + RogueProgress.LUCK_SHINY, lucky["comun"], lucky["legendaria"]]] = lucky["comun"] < plain["comun"] - 300 \
		and lucky["legendaria"] > plain["legendaria"] and lucky["rara"] > plain["rara"] and absi(plain["comun"] - 3000) < 150
	var r1 := RandomNumberGenerator.new()
	var r2 := RandomNumberGenerator.new()
	r1.seed = 77
	r2.seed = 77
	var same := true
	for n in 300:
		if boons.roll_rarity(r1, 0) != boons.roll_rarity(r2, 0) or r1.randi() != r2.randi():
			same = false
	r["Con suerte 0 el sorteo es el de siempre (no gasta azar de más)"] = same
	GameState.rogue["luck"] = 5
	_grant("bendicion")
	await _until(func(): return is_instance_valid(run.boon_screen), 3.0)
	await get_tree().process_frame
	var shown: bool = run.boon_screen.find_children("*", "Label", true, false).any(func(l): return l.text.contains("Suerte 5"))
	run.boon_screen.choose(0)
	await _until(func(): return not _busy, 3.0)
	r["La suerte se ve en la pantalla de elección"] = shown
	DirAccess.remove_absolute(RogueProgress.TEST_PATH)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[azar] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-odds] -> ", "OK" if ok else "FALLO")
	GameState.rogue = {}
	get_tree().quit(0 if ok else 1)


## En qué parte de 500 pares de puertas aparece ese tipo.
func _share(id: String) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12
	var n := 0
	for k in 500:
		if rewards.options(rng).has(id):
			n += 1
	return float(n) / 500.0


func _rarities(luck: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	var out := {"comun": 0, "rara": 0, "epica": 0, "legendaria": 0}
	for n in 5000:
		out[boons.roll_rarity(rng, luck)] += 1
	return out


func _grant(id: String) -> void:
	_busy = true
	await rewards.grant(id)
	_busy = false


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()
