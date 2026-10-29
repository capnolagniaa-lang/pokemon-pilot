class_name EquipTests
extends Node
## Autotest de equipar movimientos (bug del usuario 2026-10-26: "hay un error con equipar los ataques cuando sube de
## nivel o cuando quiero equiparlo"): todo lo aprendido de cada Pokémon con kit se puede equipar, y equiparlo en el
## que está afuera (y subir de nivel) no rompe nada.
##   godot --headless --path . --quit-after 60000 -- --autotest-equip

var autotest: Node


func run() -> void:
	var r := {}
	var fails := []
	for sp: SpeciesData in DB.species.values():
		if sp.kit == null:
			continue
		var inst := CreatureInstance.create(sp, 100)
		for m in inst.learned_moves():
			if not inst.equip(3, m) or inst.equipped_moves[3] != m:
				fails.append("%s:%s" % [sp.id, DB.move_key(m)])
	r["Todo lo aprendido se puede equipar %s" % str(fails.slice(0, 8))] = fails.is_empty()
	# En el mundo: equipar en el que está afuera (la ficha emite equipment_changed) y usarlo.
	var world: Node = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	var inst: CreatureInstance = me.instance
	inst.level = 50
	var errors := []
	for m in inst.learned_moves():
		if not inst.equip(2, m):
			errors.append("no equipa " + m.id)
			continue
		Events.equipment_changed.emit(inst)
		await get_tree().physics_frame
		if not is_instance_valid(world.companion) or world.companion.moves.slots[2] != m:
			errors.append("no queda en la ranura " + m.id)
			continue
		r["En combate, el recién equipado arranca con su recarga (%s)" % m.id] = world.companion.moves.cooldowns[2] > 0.0 or m.cooldown <= 0.0
		world.companion.moves.reset_cooldown(2)
		world.companion.use_slot(2, Vector2.RIGHT, world.companion.global_position + Vector2(50, 0))
		await get_tree().create_timer(0.4).timeout
		if world.companion.machine.current_name() == "stunned":
			world.companion.machine.transition_to("controlled")
	r["Equipar en el que está afuera y usarlo %s" % str(errors)] = errors.is_empty()
	# Subir de nivel: aprende y (con una ranura libre) lo equipa solo.
	var fresh := CreatureInstance.create(DB.species["squirtle"], 5)
	fresh.equipped_moves[3] = null
	var text := GameState.grant_exp(fresh, CreatureInstance.exp_for_level(fresh.species.growth_rate, 20) - fresh.experience + 1)
	r["Subir de nivel aprende y equipa en la ranura libre (%s)" % text.strip_edges()] = fresh.level >= 20 \
		and fresh.equipped_moves[3] != null

	# Con las 4 llenas: al terminar la pelea aparece el cartel; "Sí" + elegir la ranura 0 lo reemplaza.
	world.combat.end_battle()
	var mine: CreatureInstance = GameState.active()
	mine.level = 30
	mine.experience = CreatureInstance.exp_for_level(mine.species.growth_rate, 30)
	# 4 ranuras llenas, ninguna con Lanzallamas (el que aprende a Nv. 31; también es su MT, por eso se saca a mano).
	var others := mine.learned_moves().filter(func(m): return m.id != "lanzallamas")
	for i in 4:
		mine.equipped_moves[i] = others[i]
	var learn: MoveLearnDirector = world.evolutions.moves
	GameState.grant_exp(mine, CreatureInstance.exp_for_level(mine.species.growth_rate, 31) - mine.experience)
	world.evolutions.queue.clear()  # (un Charmander Nv. 31 también quiere evolucionar: acá solo el cartel del ataque)
	var flame: MoveData = DB.moves["lanzallamas"]
	await _until(func(): return learn.showing, 3.0)
	r["Con las 4 ranuras llenas aparece el cartel (%s)" % flame.display_name] = learn.showing and is_instance_valid(learn.screen) \
		and learn.screen.move == flame
	if is_instance_valid(learn.screen):
		learn.screen.finished.emit(0)
	await get_tree().process_frame
	r["Elegir la ranura 1 lo reemplaza ahí"] = mine.equipped_moves[0] == flame and not learn.showing

	# La ficha muestra las MT/MO de su especie y se pueden equipar desde ahí (bug del usuario 2026-10-29: Nidoking
	# solo mostraba los de nivel).
	var nido := CreatureInstance.create(DB.species["nidoking"], 30)
	GameState.party.append(nido)
	var sheet: Control = load("res://scenes/ui/summary_screen.tscn").instantiate()
	sheet.party_index = GameState.party.size() - 1
	add_child(sheet)
	await get_tree().process_frame
	sheet._tabs.current_tab = 1
	await get_tree().process_frame
	var texts: Array = sheet._rows.map(func(b): return b.text)
	var rock: MoveData = DB.moves["tumba_rocas"]
	GameState.bag.erase("mt39")
	r["Ficha de Nidoking: sus MT/MO de FireRed, bloqueadas sin la MT (%d filas)" % texts.size()] = texts.has("MT39   Tumba Rocas   — te falta la MT") 		and texts.has("MO03   Surf   — te falta la MT") and texts.has("MT26   Terremoto   — te falta la MT") 		and texts.size() > nido.species.learnset_entries().size()
	r["Sin enseñarle la MT no se puede equipar (las MT ya no están libres)"] = not nido.equip(3, rock) and not nido.learned_moves().has(rock)
	sheet.queue_free()
	# Con la MT en la mochila dice que se la enseñes; al enseñársela se equipa desde la ficha.
	GameState.add_item("mt39", 1)
	sheet = load("res://scenes/ui/summary_screen.tscn").instantiate()
	sheet.party_index = GameState.party.size() - 1
	add_child(sheet)
	await get_tree().process_frame
	sheet._tabs.current_tab = 1
	await get_tree().process_frame
	r["Con la MT en la Mochila: \"enseñale la MT\""] = sheet._rows.map(func(b): return b.text).has("MT39   Tumba Rocas   — enseñale la MT (Mochila)")
	GameState.use_item_on("mt39", nido)
	sheet.queue_free()
	sheet = load("res://scenes/ui/summary_screen.tscn").instantiate()
	sheet.party_index = GameState.party.size() - 1
	add_child(sheet)
	await get_tree().process_frame
	sheet._tabs.current_tab = 1
	await get_tree().process_frame
	texts = sheet._rows.map(func(b): return b.text)
	var rock_row: int = texts.find("MT39   Tumba Rocas")
	if rock_row < 0:
		rock_row = texts.find("MT39   Tumba Rocas   (equipado)")
	if rock_row >= 0:
		nido.equip(3, DB.moves["malicioso"] if DB.moves.has("malicioso") else null)
		sheet._on_row(rock, false, sheet._rows[rock_row])
		sheet._on_slot(3)
	r["Enseñada la MT (y la MT sigue en la Mochila), se equipa desde la ficha"] = nido.equipped_moves.has(rock) 		and GameState.item_count("mt39") == 1
	# Partidas de antes: un ataque de MT que ya tenía equipado lo conserva (queda como enseñado).
	var old := nido.to_dict()
	old["taught_moves"] = []
	old["equipped_moves"] = ["terremoto", "", "", ""]
	var loaded := CreatureInstance.from_dict(old)
	r["Partida vieja: el ataque de MT que tenía equipado lo conserva"] = loaded.equipped_moves[0] == DB.moves["terremoto"] 		and loaded.taught_moves.has(DB.moves["terremoto"])
	sheet.queue_free()
	GameState.party.erase(nido)

	# Las 50 MT y las 8 MO existen y cada una se consigue en algún lado (pedido del usuario 2026-10-29): en el suelo,
	# de un líder o de regalo (charlas y premios de data/story/npcs) o en una tienda (data/shops).
	var sources := {}
	for npc: NpcData in DB.npcs.values():
		for t: NpcTalk in npc.talks:
			for id in t.give_items:
				sources[id] = sources.get(id, []) + [npc.id]
		if npc.trainer != null:
			for id in npc.trainer.reward_items:
				sources[id] = sources.get(id, []) + [npc.id]
	for f in DirAccess.get_files_at("res://data/shops"):
		var shop = load("res://data/shops/" + f.trim_suffix(".remap"))
		if shop is ShopData:
			for it in shop.items:
				sources[it.id] = sources.get(it.id, []) + ["tienda " + shop.id]
	var machines := []
	for n in range(1, 51):
		machines.append("mt%02d" % n)
	for n in range(1, 9):
		machines.append("mo%02d" % n)
	var broken := machines.filter(func(id): return not DB.items.has(id) or DB.items[id].teaches_move == null)
	var nowhere := machines.filter(func(id): return not sources.has(id))
	r["Las 50 MT y 8 MO existen y enseñan su ataque %s" % str(broken)] = broken.is_empty()
	r["Cada MT/MO se consigue en algún lado %s" % str(nowhere)] = nowhere.is_empty()
	r["Los líderes dan su MT de FireRed (Brock 39, Misty 03, Surge 34, Erika 19, Koga 06, Sabrina 04, Blaine 38, Giovanni 26)"] = \
		["mt39", "mt03", "mt34", "mt19", "mt06", "mt04", "mt38", "mt26"].all(func(id): return sources.get(id, []).any(func(s): return "gimnasio" in s))
	r["27 MT tiradas en el mapa, como en FireRed"] = DB.npcs.keys().filter(func(k): return "_itemtm" in k).size() == 27

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[equipar] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-equip] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()
