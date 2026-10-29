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
	var rock_row := texts.find("MT   Tumba Rocas")
	r["Ficha de Nidoking: sección Por MT / MO con sus MT de FireRed (%d filas)" % texts.size()] = rock_row >= 0 \
		and texts.has("MO   Surf") and texts.has("MT   Terremoto") and texts.size() > nido.species.learnset_entries().size()
	if rock_row >= 0:
		sheet._on_row(rock, false, sheet._rows[rock_row])
		sheet._on_slot(3)
	r["Desde la ficha se equipa un ataque de MT"] = nido.equipped_moves[3] == rock
	sheet.queue_free()
	GameState.party.erase(nido)

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
