class_name RogueRewardTests
extends Node
## Autotest de R-3 del Modo Desafío (docs/PROPUESTA_ROGUELIKE.md): recompensas de sala y puertas con ícono.
##   godot --headless --path . --fixed-fps 60 --quit-after 60000 -- --autotest-rogue-rewards
## Vitrina (las puertas en la sala, la Tienda, la MT y el Caramelo Raro):
##   godot --path . --quit-after 520 --write-movie out/f.png --fixed-fps 30 -- --showcase-rogue-rewards

var world: Node
var run: RogueRun
var rewards: RogueRewards
var me: Creature
var inst: CreatureInstance


func run_tests() -> void:
	var r := {}
	var f := RogueRun.load_floor()
	var cfg: Dictionary = f["rewards"]
	var missing: Array[String] = []
	for id: String in RogueRewards.TYPES:
		if not ResourceLoader.exists(RogueRewards.icon_of(id)):
			missing.append("ícono de " + id)
		if not cfg["weights"].has(id):
			missing.append("peso de " + id)
	if not ResourceLoader.exists(RogueRewardDoor.ARCH):
		missing.append("arco de la puerta")
	r["Hay %d tipos de recompensa, cada uno con su ícono y su peso, y el arco de la puerta%s" % [RogueRewards.TYPES.size(),
		"" if missing.is_empty() else " — falta: " + "; ".join(missing)]] = missing.is_empty() and RogueRewards.TYPES.size() == 9

	RogueRun.begin(DB.species["pikachu"])  # (uno sin kit de 5 teclas: con kit no hay MT)
	GameState.rogue["biomes"] = ["bosque", "cueva", "volcan", "hielo", "costa"]
	GameState.rogue["rewards"] = ["bendicion", "dinero"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	rewards = run.rewards
	me = world.companion
	inst = GameState.active()

	# --- Qué se ofrece ---
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var seen := {}
	var pairs_ok := true
	for n in 500:
		var o: Array[String] = rewards.options(rng)
		if o.size() != 2 or o[0] == o[1]:
			pairs_ok = false
		for id in o:
			seen[id] = true
	r["Sin bendiciones ni plata, las puertas nunca ofrecen Caramelo Raro ni Tienda (salen: %s)" % ", ".join(seen.keys())] = pairs_ok \
		and not seen.has("caramelo") and not seen.has("tienda") and seen.has("bendicion") and seen.has("mt") and seen.has("centro")
	run.boons.take("sobrecarga")
	GameState.money = 500
	seen.clear()
	for n in 800:
		for id in rewards.options(rng):
			seen[id] = int(seen.get(id, 0)) + 1
	r["Con bendiciones y plata salen los 9 tipos, de a 2 distintos; la Bendición es la más común (%d de 1600)" % seen.get("bendicion", 0)] = \
		seen.size() == 9 and seen.values().all(func(v): return v > 0) and seen.keys().all(func(id): return seen["bendicion"] >= seen[id])

	# --- Cada recompensa ---
	GameState.money = 0
	var hp_before := inst.max_hp()
	inst.hp = hp_before * 0.5
	await rewards.grant("proteina")
	r["Más PS: la vida máxima sube %d %% (%d → %d) y te da esa vida" % [roundi(float(cfg["proteina"]) * 100), roundi(hp_before), roundi(inst.max_hp())]] = \
		is_equal_approx(inst.max_hp(), hp_before * (1.0 + float(cfg["proteina"]))) and is_equal_approx(inst.hp, hp_before * 0.5 + inst.max_hp() - hp_before) \
		and is_equal_approx(me.health.max_hp(), inst.max_hp())
	await rewards.grant("dinero")
	r["Dinero: entre $%d y $%d (te dio $%d)" % [cfg["dinero"][0], cfg["dinero"][1], GameState.money]] = GameState.money >= int(cfg["dinero"][0]) \
		and GameState.money <= int(cfg["dinero"][1])
	inst.hp = inst.max_hp() * 0.2
	me.moves.set_pp(10.0)
	await rewards.grant("centro")
	r["Centro Pokémon: cura %d %% de la vida (de 20 a %d %%) y llena los PP" % [roundi(float(cfg["centro"]) * 100), roundi(100.0 * inst.hp / inst.max_hp())]] = \
		is_equal_approx(inst.hp, inst.max_hp() * (0.2 + float(cfg["centro"]))) and is_equal_approx(me.moves.pp(), me.moves.max_pp())
	# Caramelo Raro
	_grant("caramelo")
	await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
	await get_tree().process_frame
	var candy_cards: int = run.reward_screen.cards.size() if is_instance_valid(run.reward_screen) else 0
	var paused := get_tree().paused
	if is_instance_valid(run.reward_screen):
		run.reward_screen.choose(0)
	await _until(func(): return not _busy, 3.0)
	r["Caramelo Raro: te muestra tus bendiciones (%d) con el juego en pausa y la que elegís sube a Nv. 2" % candy_cards] = candy_cards == 1 and paused \
		and int(run.boons.entry("sobrecarga")["level"]) == 2 and not get_tree().paused
	# MT
	var old_moves: Array = inst.equipped_moves.duplicate()
	var cands := rewards.tm_candidates()
	var names: Array = old_moves.filter(func(m): return m != null).map(func(m): return m.display_name)
	r["MT: %s puede aprender %d ataques de daño que no tiene puestos" % [inst.species.display_name, cands.size()]] = cands.size() >= 3 \
		and cands.all(func(m): return m.power > 0.0 and not names.has(m.display_name))
	_grant("mt")
	await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
	await get_tree().process_frame
	var first: RewardScreen = run.reward_screen
	var offered: Array = first.cards_data.map(func(c): return c["title"])
	var want: String = offered[0]
	first.choose(0)
	await _until(func(): return is_instance_valid(run.reward_screen) and run.reward_screen != first, 3.0)
	await get_tree().process_frame
	var slot_cards: int = run.reward_screen.cards.size() if is_instance_valid(run.reward_screen) else 0
	if is_instance_valid(run.reward_screen):
		run.reward_screen.choose(2)
	await _until(func(): return not _busy, 3.0)
	r["MT: 3 ataques a elegir (%s), después a cuál de los 4 reemplaza; queda en esa ranura, también en el que pelea" % ", ".join(offered)] = \
		offered.size() == 3 and slot_cards == 4 and inst.equipped_moves[2] != null and inst.equipped_moves[2].display_name == want \
		and me.moves.slots[2] == inst.equipped_moves[2] and inst.equipped_moves[0] == old_moves[0] and inst.equipped_moves[1] == old_moves[1]
	# Tienda
	GameState.money = 100
	var potions := GameState.item_count("pocion")
	var balls := GameState.item_count("poke_ball")
	_grant("tienda")
	await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
	await get_tree().process_frame
	var shop: RewardScreen = run.reward_screen
	var shop_ok: bool = shop.cards.size() == cfg["shop"].size() + 1 and shop.cards[4].disabled and not shop.cards[0].disabled
	shop.choose(4)  # (la bendición, $110: no alcanza)
	await get_tree().process_frame
	var still: bool = is_instance_valid(run.reward_screen) and run.reward_screen == shop and GameState.money == 100
	shop.choose(0)  # Poción, $40
	await _until(func(): return is_instance_valid(run.reward_screen) and run.reward_screen != shop, 3.0)
	await get_tree().process_frame
	var second: RewardScreen = run.reward_screen
	second.choose(1)  # Poké Ball, $60
	await _until(func(): return is_instance_valid(run.reward_screen) and run.reward_screen != second, 3.0)
	await get_tree().process_frame
	var third: RewardScreen = run.reward_screen
	var broke: bool = range(cfg["shop"].size()).all(func(i): return third.cards[i].disabled)
	third.choose(third.last_enabled())  # Salir
	await _until(func(): return not _busy, 3.0)
	r["Tienda: lo que no te alcanza está apagado; comprás Poción y Poké Ball con $100, te quedás en $0 y salís"] = shop_ok and still and broke \
		and GameState.item_count("pocion") == potions + 1 and GameState.item_count("poke_ball") == balls + 1 and GameState.money == 0
	# Lo que no se puede dar, da una bendición
	GameState.rogue["boons"] = []
	_grant("caramelo")
	await _until(func(): return is_instance_valid(run.boon_screen), 3.0)
	var fallback := is_instance_valid(run.boon_screen)
	if fallback:
		run.boon_screen.choose(0)
	await _until(func(): return not _busy, 3.0)
	r["Si ya no se puede dar (Caramelo Raro sin bendiciones), te ofrece una bendición"] = fallback and run.boons.owned().size() == 1

	# --- En la partida: recompensa de la sala, puertas, y la sala siguiente da lo elegido ---
	GameState.money = 0
	GameState.rogue["boons"] = []
	await _clear_room()
	await _until(func(): return is_instance_valid(run.boon_screen), 6.0)
	r["La primera sala da una bendición"] = is_instance_valid(run.boon_screen) and run.phase == "premio" and run.reward_of(0) == "bendicion"
	if is_instance_valid(run.boon_screen):
		run.boon_screen.choose(0)
	await _until(func(): return run.phase == "eleccion", 6.0)
	await get_tree().process_frame
	var doors: Array = run.reward_doors.duplicate()
	var types: Array = doors.map(func(d): return d.reward)
	var free_cells: bool = doors.all(func(d): return MapRules.cell_physics(run.room, run.room.ground.local_to_map(run.room.to_local(d.global_position))) == -1)
	r["Con la sala limpia aparecen 2 puertas con ícono (%s), en piso libre y separadas, y el portón sigue cerrado" % ", ".join(types)] = doors.size() == 2 \
		and types[0] != types[1] and types[0] == "dinero" and free_cells and doors[0].global_position.distance_to(doors[1].global_position) >= 70.0 \
		and is_instance_valid(run.gates[0]) and doors.all(func(d): return d._icon != null and d.text != "") \
		and run.exit_point() == doors[0].global_position
	r["El cartel dice que elijas y muestra tu plata ($%d por la sala)" % GameState.money] = run._label.text.contains("Elegí una puerta") \
		and run._label.text.contains("$%d" % GameState.money) and GameState.money == int(cfg["room_money"])
	await get_tree().create_timer(0.5).timeout
	r["Hasta que no pisás una, no pasa nada"] = run.phase == "eleccion" and run.reward_doors.size() == 2
	me.global_position = doors[0].global_position
	await _until(func(): return run.phase == "puerta", 6.0)
	await get_tree().physics_frame
	r["Pisar una puerta elige la recompensa de la sala siguiente (%s), las puertas se van y se abre el portón" % run.reward_of(1)] = run.phase == "puerta" \
		and run.reward_of(1) == "dinero" and run.reward_doors.is_empty() and not is_instance_valid(doors[0]) and not is_instance_valid(run.gates[0])
	# La sala 2
	var next: Zone = run.chain[1]
	var used: Rect2i = next.ground.get_used_rect()
	me.global_position = next.to_global(next.ground.map_to_local(Vector2i(used.end.x / 2, used.end.y - 9)))
	await _until(func(): return run.room_index == 1 and run.phase == "oleada", 10.0)
	var money0 := GameState.money
	await _clear_room()
	await _until(func(): return run.phase == "eleccion" or run.phase == "puerta", 8.0)
	var gained := GameState.money - money0 - int(cfg["room_money"])
	r["La sala 2 da lo que elegiste: dinero ($%d), sin pantalla de bendición" % gained] = gained >= int(cfg["dinero"][0]) and gained <= int(cfg["dinero"][1]) \
		and not is_instance_valid(run.boon_screen) and run.boons.owned().size() == 1 and run.phase == "eleccion"

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[premios] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-rewards] -> ", "OK" if ok else "FALLO")
	GameState.rogue = {}
	get_tree().quit(0 if ok else 1)


var _busy := false

## Pide una recompensa sin esperar (las que abren pantalla quedan esperando la elección).
func _grant(id: String) -> void:
	_busy = true
	await rewards.grant(id)
	_busy = false


## Limpia la sala en la que estás: debilita a todos los de cada oleada apenas salen.
func _clear_room() -> void:
	var room := run.room_index
	var t := 0.0
	while t < 40.0 and run.room_index == room and run.phase in ["oleada", ""] and run.rooms_cleared <= room:
		for e: Creature in run.foes.duplicate():
			if is_instance_valid(e) and not e.is_down():
				e.health.apply_damage(99999.0)
		if is_instance_valid(me):
			me.health.heal(99999.0)
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


## Vitrina: las dos puertas en la sala y después la Tienda, la MT y el Caramelo Raro.
func showcase() -> void:
	RogueRun.begin(DB.species["charmander"])
	GameState.rogue["biomes"] = ["cementerio", "bosque", "volcan", "hielo", "costa"]
	GameState.rogue["rewards"] = ["bendicion", "tienda"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	rewards = run.rewards
	me = world.companion
	GameState.money = 150
	await _clear_room()
	await _until(func(): return is_instance_valid(run.boon_screen), 6.0)
	await get_tree().create_timer(1.5).timeout
	run.boon_screen.choose(0)
	await _until(func(): return run.phase == "eleccion", 6.0)
	var mid: Vector2 = (run.reward_doors[0].global_position + run.reward_doors[1].global_position) / 2.0 + Vector2(0, 30)
	me.global_position = mid
	world.trainer.global_position = mid + Vector2(-14, 12)
	world.camera.snap()
	await get_tree().create_timer(4.0).timeout
	for id in ["tienda", "mt", "caramelo"]:
		_grant(id)
		await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
		await get_tree().create_timer(2.5).timeout
		while _busy:
			if is_instance_valid(run.reward_screen):
				run.reward_screen.choose(run.reward_screen.last_enabled())
			await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(30.0).timeout
