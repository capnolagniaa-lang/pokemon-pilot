class_name EvolutionTests
extends Node
## Autotest de las evoluciones (Evolution, EvolutionDirector, EvolutionScreen, tools/apply_evolutions.gd):
##   godot --headless --path . --quit-after 60000 -- --autotest-evolution
## Vitrina (Charmander → Charmeleon, la pantalla con el parpadeo):
##   godot --path . --quit-after 330 --write-movie out/f.png --fixed-fps 30 -- --showcase-evolution

var autotest: Node


func run() -> void:
	var r := {}
	var sp := DB.species
	r["Datos: 172 especies evolucionan"] = sp.values().filter(func(s): return not s.evolutions.is_empty()).size() == 172
	var ch: SpeciesData = sp["charmander"]
	r["Charmander → Charmeleon a Nv. 16"] = ch.evolutions.size() == 1 and ch.evolutions[0].to_id == "charmeleon" \
		and ch.evolutions[0].method == "nivel" and ch.evolutions[0].level == 16 and sp["charmeleon"].evolves_from == "charmander"
	r["Charmeleon hereda el kit de Charmander (pelea igual)"] = sp["charmeleon"].kit == ch.kit and sp["charmeleon"].kit_inherited
	r["Charmeleon aprende su kit y además su learnset de FireRed"] = sp["charmeleon"].learnset.size() > ch.kit.moves.size() + 2
	r["Butterfree y Gyarados no heredan (cambian mucho): kit propio o ninguno"] = \
		not sp["butterfree"].kit_inherited and not sp["gyarados"].kit_inherited
	r["Clefairy evoluciona con la Piedra Lunar; Eevee con 3 piedras"] = Evolution.by_item(CreatureInstance.create(sp["clefairy"], 10),
		"piedra_lunar") == sp["clefable"] and sp["eevee"].evolutions.filter(func(e): return e.method == "piedra").size() == 3

	var world: Node = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	world.evolutions.speed = 25.0
	GameState.wilds_enabled = false
	var mon: CreatureInstance = GameState.party[0]
	mon.level = 15
	mon.experience = CreatureInstance.exp_for_level(mon.species.growth_rate, 15)
	mon.hp = mon.max_hp() * 0.5
	var equipped_before := mon.equipped_moves.duplicate()
	GameState.grant_exp(mon, mon.exp_to_next())
	r["Al llegar a Nv. 16 queda en la cola para evolucionar"] = mon.level == 16 and world.evolutions.queue.size() == 1
	var results := []
	world.evolutions.done.connect(func(i, ok): results.append([i, ok]))
	await _until(func(): return results.size() >= 1, 10.0)
	r["Evolucionó en Charmeleon (con la pantalla)"] = not results.is_empty() and results[0][1] and mon.species.id == "charmeleon"
	r["Conserva nivel, daño recibido y movimientos equipados"] = mon.level == 16 and mon.hp < mon.max_hp() * 0.7 \
		and mon.equipped_moves == equipped_before
	await get_tree().process_frame
	r["Sale con su forma nueva"] = is_instance_valid(world.companion) and world.companion.instance.species.id == "charmeleon"
	r["Queda en la Pokédex"] = GameState.pokedex_caught.has("charmeleon")

	# Frenarla con Esc (las de nivel se pueden cancelar) y que vuelva a intentar al subir otra vez.
	var bulba := CreatureInstance.create(sp["bulbasaur"], 15)
	GameState.party.append(bulba)
	GameState.grant_exp(bulba, bulba.exp_to_next())
	await _until(func(): return world.evolutions.showing, 5.0)
	world.evolutions.screen.cancel()
	await _until(func(): return results.size() >= 2, 10.0)
	r["Esc la frena: sigue siendo Bulbasaur"] = results.size() >= 2 and not results[1][1] and bulba.species.id == "bulbasaur"
	GameState.grant_exp(bulba, bulba.exp_to_next())
	await _until(func(): return results.size() >= 3, 10.0)
	r["Al subir de nuevo vuelve a intentar: Ivysaur"] = bulba.species.id == "ivysaur"

	# Piedra Lunar: no se puede frenar.
	var clefairy := CreatureInstance.create(sp["clefairy"], 12)
	GameState.party.append(clefairy)
	GameState.add_item("piedra_lunar", 1)
	r["La Piedra Lunar sirve con Clefairy y no con Charmeleon"] = DB.items["piedra_lunar"].can_use_on(clefairy) \
		and not DB.items["piedra_lunar"].can_use_on(mon)
	r["Usar la piedra la gasta"] = GameState.use_item_on("piedra_lunar", clefairy) != "" and GameState.item_count("piedra_lunar") == 0
	await _until(func(): return world.evolutions.showing, 5.0)
	world.evolutions.screen.cancel()
	await _until(func(): return results.size() >= 4, 10.0)
	r["Con piedra no se frena: Clefable"] = clefairy.species.id == "clefable"

	# Evoluciona y aprende lo de su nivel (Metapod → Butterfree a Nv. 10: Confusión).
	var metapod := CreatureInstance.create(sp["metapod"], 9)
	GameState.party.append(metapod)
	GameState.grant_exp(metapod, metapod.exp_to_next())
	await _until(func(): return results.size() >= 5, 10.0)
	r["Metapod → Butterfree aprende lo de su nivel y no olvida Fortaleza"] = metapod.species.id == "butterfree" \
		and metapod.learned_moves().any(func(m): return m.display_name == "Confusión") \
		and metapod.learned_moves().any(func(m): return m.display_name == "Fortaleza")

	# Durante un combate espera a que termine.
	var weedle := CreatureInstance.create(sp["weedle"], 6)
	GameState.party.append(weedle)
	world.combat.start_battle()
	GameState.grant_exp(weedle, weedle.exp_to_next())
	await get_tree().create_timer(0.5).timeout
	r["En combate no aparece (espera)"] = not world.evolutions.showing and weedle.species.id == "weedle"
	world.combat.end_battle()
	await _until(func(): return results.size() >= 6, 10.0)
	r["Al terminar el combate evoluciona: Kakuna"] = weedle.species.id == "kakuna"

	var saved := GameState.to_dict()
	r["Se guarda la forma nueva"] = GameState.from_dict(saved) and GameState.party[0].species.id == "charmeleon"

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[evolucion] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-evolution] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func showcase() -> void:
	var world: Node = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.wilds_enabled = false
	var mon: CreatureInstance = GameState.party[0]
	mon.level = 15
	mon.experience = CreatureInstance.exp_for_level(mon.species.growth_rate, 15)
	await get_tree().create_timer(0.5).timeout
	GameState.grant_exp(mon, mon.exp_to_next())
	await world.evolutions.done
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()
