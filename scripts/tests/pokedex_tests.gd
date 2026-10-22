class_name PokedexTests
extends Node
## Autotest de las 386 especies y la Pokédex: godot --headless --path . --quit-after 40000 -- --autotest-pokedex

var autotest: Node


func run() -> void:
	var r := {}
	var all := DB.species_by_dex()
	r["386 especies (Kanto, Johto y Hoenn) con números 1 a 386"] = all.size() == 386 and all[0].dex == 1 and all[-1].dex == 386
	r["18 tipos"] = DB.types.size() == 18
	var chart: TypeChart = DB.type_chart
	var t := DB.types
	var normal: Array[ElementType] = [t["fantasma"]]
	var ground: Array[ElementType] = [t["tierra"]]
	var dragon: Array[ElementType] = [t["dragon"], t["volador"]]
	r["Tabla de tipos oficial (Normal→Fantasma 0, Eléctrico→Tierra 0, Hielo→Dragón/Volador ×4)"] = \
		chart.get_multiplier(t["normal"], normal) == 0.0 and chart.get_multiplier(t["electrico"], ground) == 0.0 \
		and chart.get_multiplier(t["hielo"], dragon) == 4.0
	var bad_data := []
	for sp in all:
		if sp.learnset_entries().is_empty() or sp.types.is_empty() or sp.base_hp <= 0 or DB.anims_of(sp).get("Idle") == null \
				or sp.display_name == "" or sp.pokedex_entry == "":
			bad_data.append(sp.id)
	r["Todas con stats, tipos, learnset, descripción y sprites"] = bad_data.is_empty()
	if not bad_data.is_empty():
		print("[pokedex] con datos incompletos: ", bad_data)

	# Cada especie sale al mundo (Nv. 50) y usa sus 4 movimientos sin errores.
	var world: Node = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	var errors := []
	var used := 0
	for i in range(0, all.size(), 8):
		var batch: Array[Creature] = []
		for k in range(i, mini(i + 8, all.size())):
			var c: Creature = autotest._dummy(world, all[k].id, world.trainer.global_position + Vector2(-200 + (k - i) * 50, 120), false)
			c.instance.level = 50
			batch.append(c)
		await get_tree().physics_frame
		for c in batch:
			if c.moves.moves.is_empty():
				errors.append(c.instance.species.id)
			for slot in MoveUser.SLOT_COUNT:
				c.moves.reset_cooldown(slot)
				if c.machine.current_name() in ["cast", "dash", "lunge", "channel", "recovery"]:
					await get_tree().create_timer(0.5).timeout
				if c.use_slot(slot, Vector2.RIGHT, c.global_position + Vector2(40, 0)):
					used += 1
		await get_tree().create_timer(0.3).timeout
		for c in batch:
			if is_instance_valid(c):
				c.queue_free()
	r["Todas salen al mundo con movimientos y los usan (%d usos)" % used] = errors.is_empty() and used > 386 * 2
	if not errors.is_empty():
		print("[pokedex] sin movimientos: ", errors)

	# Pokédex: vistos y luchados
	GameState.new_game(DB.species["bulbasaur"])
	r["Partida nueva: solo el inicial en la Pokédex"] = GameState.pokedex_seen.size() == 1 and GameState.has_fought(DB.species["bulbasaur"])
	var sp: SpeciesData = DB.species["treecko"]
	var wild: Creature = autotest._dummy(world, "treecko", world.camera.get_screen_center_position() + Vector2(40, 0))
	await get_tree().create_timer(0.6).timeout
	r["Un salvaje en pantalla queda visto (no luchado)"] = GameState.has_seen(sp) and not GameState.has_fought(sp)
	Events.wild_aggro.emit(wild, world.companion)
	r["Si pelea, queda luchado"] = GameState.has_fought(sp)
	var far: SpeciesData = DB.species["rayquaza"]
	autotest._dummy(world, "rayquaza", world.trainer.global_position + Vector2(2000, 0))
	await get_tree().create_timer(0.6).timeout
	r["Uno fuera de pantalla no se registra"] = not GameState.has_seen(far)
	var d := GameState.to_dict()
	GameState.new_game(DB.species["squirtle"])
	GameState.from_dict(d)
	r["La Pokédex se guarda y se carga"] = GameState.has_fought(sp) and not GameState.has_seen(far)

	world.pause_menu.try_open()
	world.pause_menu._open_pokedex()
	await get_tree().process_frame
	var dex: Control = world.pause_menu._stack[-1]
	dex._show_region(2)  # Hoenn
	await get_tree().process_frame
	dex._show_detail(far)
	await get_tree().process_frame
	var texts := _texts(dex._detail)
	r["No visto: ????? y silueta"] = "?????" in texts and dex._view.silhouette
	dex._show_detail(sp)
	await get_tree().process_frame
	texts = _texts(dex._detail)
	r["Visto: nombre, descripción y estadísticas"] = "Treecko" in texts and sp.pokedex_entry in texts and "Luchado" in texts \
		and not dex._view.silhouette
	r["Hoenn: 135 casillas"] = dex._cells.size() == 135
	world.pause_menu.close()

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[pokedex] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-pokedex] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _texts(node: Node) -> String:
	var out := ""
	for c in node.find_children("*", "Label", true, false):
		if not c.is_queued_for_deletion():
			out += c.text + "\n"
	return out


## Vitrina (--write-movie ... -- --showcase-pokedex): Pokédex con algunos vistos, uno luchado y siluetas.
func showcase() -> void:
	var world: Node = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	for id in ["bulbasaur", "pidgey", "rattata", "vulpix", "pikachu", "gengar", "dragonite"]:
		GameState.mark_seen(DB.species[id])
	GameState.mark_fought(DB.species["pidgey"])
	await get_tree().create_timer(0.3).timeout
	world.pause_menu.try_open()
	world.pause_menu._open_pokedex()
	await get_tree().create_timer(1.0).timeout
	var dex: Control = world.pause_menu._stack[-1]
	dex._cells[15].grab_focus()  # Pidgey (luchado)
	await get_tree().create_timer(1.2).timeout
	dex._cells[1].grab_focus()  # Ivysaur (no visto)
	await get_tree().create_timer(1.2).timeout
	dex._cells[93].grab_focus()  # Gengar (visto, no luchado)
	await get_tree().create_timer(1.2).timeout
	dex._show_region(2)
	await get_tree().create_timer(1.2).timeout
	get_tree().quit()
