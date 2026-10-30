class_name TournamentTests
extends Node
## Autotest del Torneo de Ciudad Plateada y del dinero (docs/PLAN_TORNEO.md, T-0 a T-3):
##   godot --headless --path . --quit-after 200000 -- --autotest-tournament
## Vitrina del estadio: godot --path . --quit-after 500 --write-movie out/f.png --fixed-fps 30 -- --showcase-tournament

var autotest: Node
var world: Node
## Respuestas automáticas a las preguntas (en orden); sin respuestas, 0.
var answers: Array = []


func run() -> void:
	var r := {}
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	_dialogs()
	r["Arrancás con $3000"] = GameState.money == GameState.STARTING_MONEY
	r["6 copas (Nv. 15, Nv. 30 y Libre; de 3 y de 6)"] = world.tournament.cups.size() == 6
	var lobby: ZoneEntry = null
	for z in world.streamer.world_data.zones:
		if z.id == "ciudad_plateada_torneo":
			lobby = z
	var pewter_door := false
	for z in world.streamer.world_data.zones:
		if z.id == "ciudad_plateada":
			pewter_door = z.warps.has(Vector2i(39, 4)) and z.warps[Vector2i(39, 4)]["to"] == "ciudad_plateada_torneo"
	r["Edificio del Torneo en Plateada (puerta del anexo del museo)"] = lobby != null and pewter_door
	var brock: NpcData = DB.npcs["ciudad_plateada_gimnasio_brock"]
	r["Ganarle a un entrenador da dinero"] = StoryDirector.prize_of(brock.trainer, [CreatureInstance.create(DB.species["onix"], 14)]) == 14 * 60

	# Equipo: 3 de nivel bajo (entran a la Copa Nv. 15) y uno alto (no entra).
	GameState.party.clear()
	for sp in ["charmander", "squirtle", "bulbasaur"]:
		GameState.party.append(CreatureInstance.create(DB.species[sp], 12))
	GameState.party.insert(1, CreatureInstance.create(DB.species["pidgey"], 40))
	GameState.set_active(0)
	Events.party_changed.emit()
	GameState.bag["superpocion"] = 2
	var cup: TournamentCup = world.tournament.cups[0]

	# Rivales generados (pedido del usuario 2026-10-30): de toda Kanto y visitantes de Johto/Hoenn, evolucionados.
	var t: Tournament = world.tournament
	var strong: Array[CreatureInstance] = [CreatureInstance.create(DB.species["charizard"], 45)]
	var seen_species := {}
	var evolved := 0
	var visitors := 0
	var banned := 0
	var over_cap := 0
	for i in 6:
		for e in t._field(t.cups[5], strong):  # Copa Libre (6): al nivel de tu más alto (45)
			if str(e) == "jugador":
				continue
			if e.has("origen"):
				visitors += 1
			for m in e["team"]:
				seen_species[m[0]] = true
				if DB.species[m[0]].evolves_from != "":
					evolved += 1
				if m[0] in Tournament.BANNED:
					banned += 1
	r["Rivales con muchas especies distintas (%d en 6 cuadros)" % seen_species.size()] = seen_species.size() >= 60
	r["A nivel 45 casi todos vienen evolucionados (%d)" % evolved] = evolved >= 150
	r["Hay visitantes de Johto y Hoenn (%d)" % visitors] = visitors >= 12
	r["Sin legendarios ni los que no pelean"] = banned == 0
	for e in t._field(t.cups[0], GameState.party):  # Copa Nv. 15
		if str(e) != "jugador":
			for m in e["team"]:
				if m[1] > 15:
					over_cap += 1
	r["En la Copa Nv. 15 nadie pasa el nivel 15"] = over_cap == 0
	r["Evolucionan como un entrenador: Charmander a Nv. 40 es Charizard, Abra es Alakazam"] = \
		Tournament.evolve_for(DB.species["charmander"], 40).id == "charizard" and Tournament.evolve_for(DB.species["abra"], 40).id == "alakazam" \
		and Tournament.evolve_for(DB.species["charmander"], 12).id == "charmander"
	var azul: Dictionary = t._rival(t.cups[5], 45)
	r["Azul a Nv. 45 trae su equipo evolucionado (%s)" % str(azul["team"])] = azul["team"].any(func(m): return m[0] == "pidgeot") \
		and azul["team"].any(func(m): return m[0] == "alakazam")
	r["Se inscriben los primeros 3 con nivel <= 15"] = world.tournament.eligible(cup).map(func(i): return i.species.id) == \
		["charmander", "squirtle", "bulbasaur"]

	# --- Recepción: elegir la Copa Nv. 15 (3), confirmar, y ganar las 3 rondas ---
	await _go("ciudad_plateada_torneo", Vector2i(7, 4))
	r["La recepcionista está en el vestíbulo"] = is_instance_valid(world.story.npcs.get("ciudad_plateada_torneo_recepcionista"))
	answers = [0, 0]
	world.story.talk_to(world.story.npcs["ciudad_plateada_torneo_recepcionista"])
	await _until(func(): return world.arena.active and world.arena._fighting, 15.0)
	r["Pagás la entrada ($500)"] = GameState.money == GameState.STARTING_MONEY - cup.entry_fee
	r["En el torneo solo están tus 3 inscriptos y 6 Pociones"] = GameState.party.size() == 3 and GameState.bag.size() == 1 \
		and GameState.item_count("pocion") == 6
	r["Peleás en el estadio, con el cartel de la ronda"] = world.arena.arena_data.id == "arena_torneo"
	var saved := GameState.to_dict()
	r["Guardar en medio del torneo guarda tu equipo y Mochila de antes"] = saved["party"].size() == 4 and saved["bag"].has("superpocion")
	var rounds := 0
	for k in 3:
		await _until(func(): return world.arena.active and world.arena._fighting, 15.0)
		if not world.arena.active:
			break
		rounds += 1
		while world.arena.active and world.arena.result == "":
			await _until(func(): return not world.arena.active or (is_instance_valid(world.arena.foe) and not world.arena.foe.is_down()), 6.0)
			if is_instance_valid(world.arena.foe):
				world.arena.foe.health.apply_damage(9999.0)
			await get_tree().create_timer(0.3).timeout
		await _until(func(): return not world.arena.active, 10.0)
	await _until(func(): return not world.tournament.active and not world.story.busy, 20.0)
	r["Se juegan 3 rondas (cuadro de 8 → 4 → 2 → campeón)"] = world.tournament.bracket.size() == 4 		and world.tournament.bracket.map(func(f): return f.size()) == [8, 4, 2, 1] and world.tournament.bracket[3] == ["jugador"]
	r["Campeón: te llevás el premio ($3000)"] = GameState.has_flag("campeon_nv15_3") \
		and GameState.money == GameState.STARTING_MONEY - cup.entry_fee + cup.prize
	r["Al salir vuelven tu equipo completo y tu Mochila"] = GameState.party.size() == 4 and GameState.item_count("superpocion") == 2 \
		and GameState.tournament.is_empty()

	# --- Perder: quedás afuera y la entrada no se devuelve ---
	var money0 := GameState.money
	answers = [0, 0]
	world.story.talk_to(world.story.npcs["ciudad_plateada_torneo_recepcionista"])
	await _until(func(): return world.arena.active and world.arena._fighting, 15.0)
	for k in 4:
		await _until(func(): return not world.arena.active or (is_instance_valid(world.companion) and not world.companion.is_down()), 5.0)
		if not world.arena.active:
			break
		world.companion.health.apply_damage(9999.0)
		await get_tree().create_timer(1.6).timeout
	await _until(func(): return not world.tournament.active and not world.story.busy, 20.0)
	r["Si perdés quedás afuera y perdés la entrada"] = GameState.money == money0 - cup.entry_fee and GameState.party.size() == 4 \
		and GameState.tournament.is_empty()
	r["Sin plata no te dejan anotarte"] = await _broke_cant_enter(cup)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[torneo] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-tournament] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _broke_cant_enter(cup: TournamentCup) -> bool:
	GameState.money = cup.entry_fee - 1
	answers = [0]
	world.story.talk_to(world.story.npcs["ciudad_plateada_torneo_recepcionista"])
	await get_tree().create_timer(0.3).timeout
	await _until(func(): return not world.story.busy, 8.0)
	return not world.tournament.active and GameState.money == cup.entry_fee - 1


## Avanza los diálogos y contesta las preguntas con `answers` (en orden).
func _dialogs() -> void:
	while is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		var d: DialogBox = world.story.dialog
		if d.active:
			if d._choosing:
				d.choose(answers.pop_front() if not answers.is_empty() else 0)
			else:
				d.advance()


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func _go(zone_id: String, cell: Vector2i) -> void:
	var data: WorldData = world.streamer.world_data
	for z in data.zones:
		if z.id == zone_id:
			var pos := Vector2((z.origin + cell) * data.tile_size) + Vector2.ONE * data.tile_size / 2.0
			world.streamer.load_around_now(pos)
			world.trainer.global_position = pos
			world.camera.snap()
	for i in 3:
		await get_tree().process_frame
	world.story.refresh()
	await get_tree().physics_frame


func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.active().level = 15
	GameState.active().hp = GameState.active().max_hp()
	_dialogs()
	var team: Array[CreatureInstance] = [GameState.active()]
	var cup: TournamentCup = world.tournament.cups[0]
	world.tournament.play(cup, team)
	await _until(func(): return world.arena.active and world.arena._fighting, 15.0)
	world.combat.input_source = BotCombatInput.new(world)
	world.companion.input_source = world.combat.input_source
	await get_tree().create_timer(10.0).timeout
	get_tree().quit()
