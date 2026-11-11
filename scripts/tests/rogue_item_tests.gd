class_name RogueItemTests
extends Node
## Autotest de los objetos equipables del Modo Desafío (paso O-b de docs/PROPUESTA_ROGUELIKE.md, sección 11): datos,
## ranuras, cada efecto, la recompensa "Objeto", la Mochila y la ficha del menú de pausa, y el HUD.
##   godot --headless --path . --fixed-fps 60 --quit-after 60000 -- --autotest-rogue-items
## Vitrina (el HUD con objetos, la elección, la Mochila "De la partida" y la ficha):
##   godot --path . --quit-after 520 --write-movie out/f.png --fixed-fps 30 -- --showcase-rogue-items

var world: Node
var run: RogueRun
var boons: RogueBoons
var me: Creature
var inst: CreatureInstance
var foe: Creature
var _busy := false


func run_tests() -> void:
	var r := {}
	var f := RogueRun.load_floor()
	var bad: Array[String] = []
	for d: BoonData in DB.rogue_items.values():
		if not d.is_item() or d.icon_path == "" or not ResourceLoader.exists(d.icon_path) or d.text.length() < 15 or DB.boons.has(d.id):
			bad.append(d.id)
	r["Hay %d objetos, cada uno con su ícono y su texto%s" % [DB.rogue_items.size(), "" if bad.is_empty() else " — mal: " + ", ".join(bad)]] = \
		bad.is_empty() and DB.rogue_items.size() >= 20
	r["La recompensa \"Objeto\" tiene ícono, peso en las puertas y está en la Tienda"] = ResourceLoader.exists(RogueRewards.icon_of("objeto")) \
		and float(f["rewards"]["weights"].get("objeto", 0)) > 0.0 and f["rewards"]["shop"].any(func(x): return x["id"] == "objeto")

	await _start("squirtle")
	var texts_ok := true
	for d: BoonData in DB.rogue_items.values():
		var text := boons.describe(d, "rara", 2)
		if text.contains("{") or text.contains("}"):
			texts_ok = false
			print("[objetos]       texto raro en %s: %s" % [d.id, text])
	r["Los textos salen completos (números y teclas)"] = texts_ok
	var pool: Array = boons.item_pool().map(func(d): return d.id)
	var types := {}
	for m in inst.equipped_moves:
		if m != null and m.power > 0.0:
			types[m.element.id] = true
	var boosters: Array = pool.filter(func(id): return DB.rogue_items[id].effect == "bonus_type")
	r["De los potenciadores de tipo solo se ofrecen los de tus ataques (%s: %s)" % [", ".join(types.keys()), ", ".join(boosters)]] = \
		not boosters.is_empty() and boosters.all(func(id): return types.has(DB.rogue_items[id].params["type"])) and not pool.has("carbon") \
		and pool.has("restos")
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var offers_ok := true
	for n in 200:
		var o: Array = boons.offer_items(rng)
		var ids := {}
		for x in o:
			ids[x["id"]] = true
		if o.size() != 3 or ids.size() != 3 or not o.all(func(x): return pool.has(x["id"]) and str(x["rarity"]) != ""):
			offers_ok = false
	r["Una oferta: 3 objetos distintos, cada uno con su rareza"] = offers_ok

	# --- Ranuras ---
	var got: Array = [boons.take_item("restos"), boons.take_item("periscopio", "rara"), boons.take_item("panuelo_elegido"), boons.take_item("casco_dentado")]
	r["3 ranuras: los 3 primeros se equipan y el cuarto queda guardado (%s)" % ", ".join(got)] = got == ["equipado", "equipado", "equipado", "guardado"] \
		and boons.items().size() == 3 and boons.stash().size() == 1 and boons.slots_full()
	var again: Array = [boons.take_item("restos", "epica"), boons.take_item("restos"), boons.take_item("restos")]
	var restos: Dictionary = boons.entry("restos")
	r["Repetido: sube de nivel sin gastar ranura, se queda con la mejor rareza y el tope es Nv. %d (quedó Nv. %d, %s)" % [RogueBoons.MAX_LEVEL,
		int(restos["level"]), restos["rarity"]]] = again == ["nivel", "nivel", "nivel"] and int(restos["level"]) == RogueBoons.MAX_LEVEL \
		and restos["rarity"] == "epica" and boons.items().size() == 3 and not boons.item_pool().any(func(d): return d.id == "restos")
	var fast := me.speed()
	boons.unequip_item(2)
	var slow := me.speed()
	r["Desequipar lo manda a Guardados y deja de hacer efecto (Pañuelo Elegido: %d → %d px/s)" % [roundi(fast), roundi(slow)]] = \
		boons.items().size() == 2 and boons.stash().size() == 2 and is_equal_approx(fast, slow * (1.0 + float(DB.rogue_items["panuelo_elegido"].params["pct"])))
	boons.equip_item(boons.stash().find(boons.entry("panuelo_elegido")))
	r["Equiparlo de nuevo lo pone en la ranura libre"] = boons.items().size() == 3 and boons.items()[2]["id"] == "panuelo_elegido" \
		and is_equal_approx(me.speed(), fast)
	boons.move_item(2, -1)
	var moved: bool = boons.items()[1]["id"] == "panuelo_elegido" and boons.items()[2]["id"] == "periscopio"
	boons.swap_item(0, 0)
	r["Se cambia de ranura y se cambia un equipado por un guardado"] = moved and boons.items()[0]["id"] == "casco_dentado" \
		and boons.stash()[0]["id"] == "restos"
	var money0 := GameState.money
	var value: int = boons.sell_value(boons.entry("restos"))
	boons.sell_item(boons.entry("restos"))
	r["Vender uno guardado lo saca y da plata según rareza y nivel ($%d)" % value] = GameState.money == money0 + value and not boons.has("restos") \
		and value == int(f["rewards"]["item_sell"]) * 3 * 3

	# --- Cada efecto (uno solo equipado por vez) ---
	foe = run.foes[0]
	for e: Creature in run.foes:
		e.process_mode = Node.PROCESS_MODE_DISABLED  # (que no peleen: la sala sigue en "oleada")
	var water: MoveData = DB.moves["pistola_agua"]
	var normal: MoveData = DB.moves["placaje"]
	var power: float = 4.0 + float(inst.level)
	_only("restos")
	inst.hp = inst.max_hp() * 0.5
	await get_tree().create_timer(3.2).timeout
	var regen: float = inst.hp / inst.max_hp() - 0.5
	var per: float = float(DB.rogue_items["restos"].params["pct"])
	r["Restos: peleando recuperás vida sola (%.1f %% en 3 s)" % (regen * 100.0)] = regen >= per * 2.0 - 0.0005 and regen <= per * 4.0 + 0.0005
	_only("campana_concha")
	inst.hp = inst.max_hp() * 0.5
	_hit(water, 40.0)
	r["Campana Concha: te cura parte del daño que hacés (%.1f de 40)" % (inst.hp - inst.max_hp() * 0.5)] = \
		is_equal_approx(inst.hp - inst.max_hp() * 0.5, 40.0 * float(DB.rogue_items["campana_concha"].params["pct"]))
	_only("agua_mistica")
	var extra := _hit(water, 20.0)
	var none := _hit(normal, 20.0)
	r["Agua Mística: +%d %% a los ataques de Agua (%.1f de más) y nada a los demás (%.1f)" % [roundi(100 * float(DB.rogue_items["agua_mistica"].params["pct"])),
		extra, none]] = is_equal_approx(extra, 20.0 * float(DB.rogue_items["agua_mistica"].params["pct"])) and is_zero_approx(none)
	_only("periscopio")
	var crits := 0
	for n in 400:
		if _hit(water, 10.0) > 0.0:
			crits += 1
	r["Periscopio: algunos golpes son críticos (+50 %%): %d de 400" % crits] = crits >= 20 and crits <= 90
	_only("roca_del_rey")
	boons.triggers.clear()
	var stunned := 0
	for n in 300:
		foe.statuses.clear()
		_hit(normal, 5.0)
		if foe.statuses.has_status("azotado"):
			stunned += 1
	foe.statuses.clear()
	r["Roca del Rey: a veces deja al enemigo sin actuar (%d de 300)" % stunned] = stunned >= 8 and stunned <= 70
	_only("casco_dentado")
	var hit := HitInfo.new()
	hit.attacker = foe
	hit.move = normal
	var foe_hp := foe.instance.hp
	me.damage_received.emit(5.0, hit)
	var first := foe_hp - foe.instance.hp
	me.damage_received.emit(5.0, hit)
	r["Casco Dentado: el que te pega recibe %.1f (y enseguida de nuevo, no)" % first] = is_equal_approx(first, float(DB.rogue_items["casco_dentado"].params["power"]) * power) \
		and is_equal_approx(foe_hp - foe.instance.hp, first)
	foe.health.heal(9999.0)
	_only("cinta_focus")
	boons.room_started()
	me.health.invulnerable_time = 0.0
	inst.hp = inst.max_hp() * 0.2
	me.damage_received.emit(1.0, null)
	var guard := me.health.invulnerable_time
	me.health.invulnerable_time = 0.0
	me.damage_received.emit(1.0, null)
	r["Cinta Focus: bajo 25 %% de vida nada te hace daño por %.1f s, una vez por sala" % guard] = guard >= float(DB.rogue_items["cinta_focus"].params["time"]) - 0.01 \
		and is_zero_approx(me.health.invulnerable_time)
	_only("baya_zidra")
	boons.room_started()
	inst.hp = inst.max_hp() * 0.4
	me.damage_received.emit(1.0, null)
	var up: float = inst.hp / inst.max_hp()
	inst.hp = inst.max_hp() * 0.4
	me.damage_received.emit(1.0, null)
	r["Baya Zidra: bajo 50 %% recuperás vida (de 40 a %d %%), una vez por sala" % roundi(up * 100)] = \
		is_equal_approx(up, 0.4 + float(DB.rogue_items["baya_zidra"].params["heal"])) and is_equal_approx(inst.hp / inst.max_hp(), 0.4)
	inst.hp = inst.max_hp()
	_only("garra_rapida")
	me.moves.dodge_cooldown = 1.0
	me.dodged.emit()
	r["Garra Rápida: el esquive recarga antes (1,00 → %.2f s)" % me.moves.dodge_cooldown] = \
		is_equal_approx(me.moves.dodge_cooldown, 1.0 - float(DB.rogue_items["garra_rapida"].params["pct"]))
	me.moves.dodge_cooldown = 0.0
	var exp0 := float(DB.config.exp_multiplier) * float(f["exp_mult"])
	_only("huevo_suerte")
	r["Huevo Suerte: más EXP (×%.2f → ×%.2f) y al sacarlo vuelve" % [exp0, float(GameState.setting("exp_mult"))]] = \
		is_equal_approx(float(GameState.setting("exp_mult")), exp0 * (1.0 + float(DB.rogue_items["huevo_suerte"].params["pct"])))
	_only("moneda_amuleto")
	var back_exp := is_equal_approx(float(GameState.setting("exp_mult")), exp0)
	GameState.money = 0
	run.rewards._money()
	r["Moneda Amuleto: las bolsas de dinero dan más ($%d; sin ella, hasta $%d)" % [GameState.money, int(f["rewards"]["dinero"][1])]] = back_exp \
		and GameState.money >= roundi(float(f["rewards"]["dinero"][0]) * 1.5) and is_equal_approx(boons.stat("money"), float(DB.rogue_items["moneda_amuleto"].params["pct"]))

	# --- La recompensa "Objeto" ---
	GameState.rogue["items"] = []
	GameState.rogue["stash"] = []
	boons._items_changed()
	_grant("objeto")
	await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
	await get_tree().process_frame
	var screen: RewardScreen = run.reward_screen
	var titles: Array = screen.cards_data.map(func(c): return c["title"])
	var paused := get_tree().paused
	screen.choose(1)
	await _until(func(): return not _busy, 3.0)
	r["Recompensa Objeto: 3 tarjetas con rareza (%s), en pausa; el elegido se equipa" % ", ".join(titles)] = titles.size() == 3 and paused \
		and boons.items().size() == 1 and RogueBoons.data_of(boons.items()[0]["id"]).display_name == titles[1] and not get_tree().paused \
		and screen.cards_data.all(func(c): return str(c["tag"]) != "" and str(c["text"]).length() > 10)
	GameState.rogue["items"] = [{"id": "restos", "rarity": "comun", "level": 1}, {"id": "periscopio", "rarity": "rara", "level": 2},
		{"id": "casco_dentado", "rarity": "comun", "level": 1}]
	boons._items_changed()
	GameState.money = 0
	_grant("objeto")
	await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
	await get_tree().process_frame
	var pick: RewardScreen = run.reward_screen
	var fresh := 0
	for i in pick.cards_data.size():
		if not ["Restos", "Periscopio", "Casco Dentado"].has(pick.cards_data[i]["title"]):
			fresh = i
	var fresh_name: String = pick.cards_data[fresh]["title"]
	pick.choose(fresh)
	await _until(func(): return is_instance_valid(run.reward_screen) and run.reward_screen != pick, 3.0)
	await get_tree().process_frame
	var swap: RewardScreen = run.reward_screen
	var swap_cards: int = swap.cards.size() if is_instance_valid(swap) else 0
	var sell: int = boons.sell_value(boons.items()[1])
	if is_instance_valid(swap):
		swap.choose(1)  # (sale el Periscopio)
	await _until(func(): return not _busy, 3.0)
	r["Con las 3 llenas: elegís cuál sale (%d tarjetas: tus 3 y \"Guardarlo\"); %s reemplazó al Periscopio y te dieron $%d" % [swap_cards, fresh_name, sell]] = \
		swap_cards == 4 and boons.items().size() == 3 and RogueBoons.data_of(boons.items()[1]["id"]).display_name == fresh_name \
		and not boons.has("periscopio") and GameState.money == sell and boons.stash().is_empty()
	_grant("objeto")
	await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
	await get_tree().process_frame
	pick = run.reward_screen
	var owned_names: Array = boons.items().map(func(e): return RogueBoons.data_of(e["id"]).display_name)
	fresh = -1
	for i in pick.cards_data.size():
		if not owned_names.has(pick.cards_data[i]["title"]):
			fresh = i
	pick.choose(maxi(fresh, 0))
	await _until(func(): return (is_instance_valid(run.reward_screen) and run.reward_screen != pick) or not _busy, 3.0)
	await get_tree().process_frame
	if is_instance_valid(run.reward_screen):
		run.reward_screen.choose(run.reward_screen.last_enabled())  # "Guardarlo en la Mochila"
	await _until(func(): return not _busy, 3.0)
	r["O lo guardás sin equipar: queda en la Mochila de la partida"] = boons.items().size() == 3 and boons.stash().size() == 1

	# --- Se ve: HUD, Mochila y ficha ---
	run.boons.take("sobrecarga")
	await run.rewards.grant("proteina")
	await get_tree().process_frame
	await get_tree().process_frame
	var hud_icons: int = run._boon_row.get_children().filter(func(c): return not c.is_queued_for_deletion()).size()
	r["HUD: arriba a la izquierda están las 3 ranuras de objeto, la bendición y el Más PS (%d íconos)" % (hud_icons - 1)] = \
		hud_icons == RogueBoons.ITEM_SLOTS + 1 + 1 + 1
	var ups: Array = run.rewards.upgrades()
	r["Más PS queda anotado como mejora de la partida (%s)" % (str(ups[0]["text"]) if not ups.is_empty() else "")] = ups.size() == 1 \
		and ups[0]["id"] == "proteina" and str(ups[0]["text"]).contains("%")
	var menu: PauseMenu = world.pause_menu
	menu.try_open()
	menu._open_bag()
	await get_tree().process_frame
	await get_tree().process_frame
	var bag: Control = menu._stack[-1]
	var kinds: Array = bag._rows.map(func(b): return b.get_meta("row")["kind"])
	r["Mochila del menú de pausa: primer bolsillo \"De la partida\" con equipados, guardados, bendiciones y mejoras (%s)" % ", ".join(kinds)] = \
		bag.pockets[0][0] == "De la partida" and bag._pocket == 0 and kinds == ["item", "item", "item", "stash", "boon", "upgrade"]
	bag._show_run_detail(bag._rows[0].get_meta("row"), true)
	await get_tree().process_frame
	var actions: Array = bag._detail.get_children().filter(func(c): return c is Button and not c.is_queued_for_deletion())
	var first_id: String = boons.items()[0]["id"]
	r["Un objeto equipado se puede desequipar, cambiar de ranura y vender (%s)" % ", ".join(actions.map(func(b): return b.text))] = \
		actions.size() == 3 and actions[0].text.begins_with("Desequipar") and actions[-1].text.begins_with("Vender")
	actions[0].pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	r["Desequipar desde la Mochila lo pasa a Guardados y la lista se actualiza"] = boons.items().size() == 2 and boons.stash().any(func(e): return e["id"] == first_id) \
		and bag._rows.map(func(b): return b.get_meta("row")["kind"]) == ["item", "item", "empty", "stash", "stash", "boon", "upgrade"]
	var stash_row: Button = bag._rows[3]
	bag._show_run_detail(stash_row.get_meta("row"), true)
	await get_tree().process_frame
	actions = bag._detail.get_children().filter(func(c): return c is Button and not c.is_queued_for_deletion())
	actions[0].pressed.emit()  # Equipar
	await get_tree().process_frame
	r["Y un guardado se equipa en la ranura libre"] = boons.items().size() == 3 and boons.stash().size() == 1
	bag.menu_tab(1)
	await get_tree().process_frame
	r["Los bolsillos de siempre siguen ahí (Pociones y Pokébolas)"] = bag.pockets.size() == 4 and bag._selected != null
	bag.closed.emit()
	await get_tree().process_frame
	var summary: Control = load("res://scenes/ui/summary_screen.tscn").instantiate()
	summary.party_index = 0
	menu.push(summary)
	await get_tree().process_frame
	var tabs: TabContainer = summary._tabs
	var names: Array = range(tabs.get_tab_count()).map(func(i): return tabs.get_tab_title(i))
	var kit: Control = tabs.get_child(tabs.get_tab_count() - 1)
	var labels: Array = kit.find_children("*", "Label", true, false).map(func(l): return l.text)
	r["Ficha del Pokémon: pestaña \"Partida\" con sus objetos y bendiciones, con descripción"] = names.has("Partida") \
		and labels.any(func(t): return t.begins_with("Sobrecarga")) and labels.any(func(t): return t.contains("OBJETOS EQUIPADOS")) \
		and labels.any(func(t): return t.begins_with("Más PS"))
	summary.closed.emit()
	await get_tree().process_frame
	menu.close()
	GameState.rogue = {}
	r["Fuera del modo la Mochila y la ficha no cambian"] = RogueKitView.run_of(get_tree()) == null

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[objetos] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-items] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _start(species: String) -> void:
	RogueRun.begin(DB.species[species])
	GameState.rogue["biomes"] = ["bosque", "cueva", "volcan", "hielo", "costa"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	boons = run.boons
	me = world.companion
	inst = GameState.active()
	await get_tree().physics_frame


## Solo ese objeto equipado, común.
func _only(id: String) -> void:
	GameState.rogue["items"] = [{"id": id, "rarity": "comun", "level": 1}]
	GameState.rogue["stash"] = []
	boons._thorns.clear()
	boons._items_changed()


## Un golpe tuyo de `damage` al enemigo con ese ataque; devuelve el daño de más que le hicieron tus objetos.
func _hit(move: MoveData, damage: float) -> float:
	var hit := HitInfo.new()
	hit.attacker = me
	hit.move = move
	foe.instance.hp = foe.instance.max_hp()
	var before := foe.instance.hp
	me.hit_dealt.emit(foe, hit, damage)
	return before - foe.instance.hp


func _grant(id: String) -> void:
	_busy = true
	await run.rewards.grant(id)
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


## Vitrina: el HUD con objetos, la elección de un objeto, el reemplazo, la Mochila "De la partida" y la ficha.
func showcase() -> void:
	await _start("charmander")
	for e: Creature in run.foes:
		e.process_mode = Node.PROCESS_MODE_DISABLED
	boons.take_item("carbon", "rara")
	boons.take_item("restos")
	boons.take_item("periscopio", "epica")
	boons.take_item("periscopio")
	boons.take_item("garra_rapida")
	boons.take("garra_ardiente", "rara")
	boons.take("brasas")
	boons.take("ave_fenix", "epica")
	await run.rewards.grant("proteina")
	GameState.money = 135
	run._refresh_label()
	await get_tree().create_timer(3.0).timeout  # 1) el HUD
	_grant("objeto")
	await _until(func(): return is_instance_valid(run.reward_screen), 3.0)
	await get_tree().create_timer(3.0).timeout  # 2) elegí 1 de 3
	var pick: RewardScreen = run.reward_screen
	var names: Array = boons.items().map(func(e): return RogueBoons.data_of(e["id"]).display_name) + ["Garra Rápida"]
	var fresh := 0
	for i in pick.cards_data.size():
		if not names.has(pick.cards_data[i]["title"]):
			fresh = i
	pick.choose(fresh)
	await get_tree().create_timer(3.0).timeout  # 3) ¿a cuál reemplaza?
	if is_instance_valid(run.reward_screen):
		run.reward_screen.choose(run.reward_screen.last_enabled())
	await _until(func(): return not _busy, 3.0)
	var menu: PauseMenu = world.pause_menu
	menu.try_open()
	menu._open_bag()
	await get_tree().create_timer(3.0).timeout  # 4) la Mochila
	var bag: Control = menu._stack[-1]
	bag._show_run_detail(bag._rows[3].get_meta("row"), true)
	await get_tree().create_timer(2.0).timeout  # 5) un guardado
	bag.closed.emit()
	var summary: Control = load("res://scenes/ui/summary_screen.tscn").instantiate()
	summary.party_index = 0
	menu.push(summary)
	await get_tree().process_frame
	summary._tabs.current_tab = summary._tabs.get_tab_count() - 1
	await get_tree().create_timer(60.0).timeout  # 6) la ficha
