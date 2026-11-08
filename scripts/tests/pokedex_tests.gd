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
	_where_checks(r, world)
	await get_tree().process_frame

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[pokedex] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-pokedex] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## "Dónde aparece" (WildIndex): % de las tablas, sumas por zona, pesca, y la Pokédex con zonas visitadas y "???".
func _where_checks(r: Dictionary, world: Node) -> void:
	WildIndex.invalidate()
	var t: EncounterTable = load("res://data/world/encounters/ruta1.tres")
	var total := 0
	var pidgey_w := 0
	for e in t.entries:
		if e.where == "pasto_alto":
			total += e.weight
			if e.species_id == "pidgey":
				pidgey_w += e.weight
	var expected := 100.0 * pidgey_w / maxf(1, total)
	var got := -1.0
	for p: Dictionary in WildIndex.for_species("pidgey"):
		if p["zone"] == "ruta1" and p["kind"] == "pasto_alto" and p["area"] == "":
			got = p["pct"]
	r["Pidgey en Ruta 1, pasto alto: %.0f %% como su tabla (%.0f %%)" % [got, expected]] = pidgey_w > 0 and absf(got - expected) < 0.01
	var over := []
	var zones := 0
	for z: ZoneEntry in DB.config.world.zones:
		var sums := {}
		for p: Dictionary in WildIndex.for_zone(z.id):
			var k := "%s|%s|%s" % [p["kind"], p["rod"], p["area"]]
			sums[k] = sums.get(k, 0.0) + p["pct"]
		if not sums.is_empty():
			zones += 1
		for k in sums:
			if sums[k] > 100.001 or sums[k] <= 0.0:
				over.append("%s %s %.1f" % [z.id, k, sums[k]])
	r["Los %% de cada lugar de una zona suman ≤ 100 (%d zonas con salvajes)" % zones] = over.is_empty() and zones > 50
	if not over.is_empty():
		print("[pokedex] sumas raras: ", over)
	# Una fila "esa vez no sale nadie" cuenta para el total: en Ciudad Celeste lo de un lugar con una suma < 100.
	var nobody := false
	for z in ["ciudad_celeste"]:
		var tc := EncounterTable.for_zone(DB.config.world.zones.filter(func(e): return e.id == z)[0])
		for e in tc.entries:
			if e.species_id == "":
				var s := 0.0
				for p: Dictionary in WildIndex.for_zone(z):
					if p["kind"] == e.where and p["area"] == "" and p["rod"] == "":
						s += p["pct"]
				nobody = s < 99.99
	r["Una fila sin especie baja el % de las demás (Ciudad Celeste)"] = nobody
	var fished := WildIndex.for_species("magikarp").filter(func(p): return p["kind"] == "pesca")
	r["Pesca por caña: Magikarp con Caña Vieja en %d lugares" % fished.size()] = \
		fished.any(func(p): return p["rod"] == "vieja" and is_equal_approx(p["pct"], 100.0))
	r["Una especie que no sale salvaje (Mew) no tiene lugares"] = WildIndex.for_species("mew").is_empty()

	# En la Pokédex: Ruta 1 visitada con nombre; una zona sin visitar como "???".
	var sp: SpeciesData = DB.species["pidgey"]
	GameState.mark_seen(sp)
	GameState.visited_zones.clear()
	GameState.visited_zones["ruta1"] = true
	world.pause_menu.try_open()
	world.pause_menu._open_pokedex()
	var dex: Control = world.pause_menu._stack[-1]
	dex._show_detail(sp)
	var texts := _texts(dex._detail)
	var lines: Array = dex.where_lines("pidgey")
	r["Pokédex: \"Dónde aparece\" con Ruta 1 y su %"] = "Dónde aparece" in texts and "Ruta 1" in texts \
		and ("Pasto alto %d %%" % roundi(expected)) in texts and lines[0][0] == "Ruta 1"
	r["Pokédex: las zonas sin visitar salen como ??? (con su %%, %d)" % (lines.size() - 1)] = lines.size() > 1 \
		and lines.slice(1).all(func(l): return l[0].begins_with("???") and not l[2]) and not ("Ruta 2\n" in texts)
	dex._show_detail(DB.species["mew"])
	world.pause_menu.close()


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
	GameState.mark_seen(DB.species["magikarp"])
	for z in ["pueblo_paleta", "ruta1", "ciudad_verde", "ruta2", "bosque_verde", "ruta22", "ciudad_carmin"]:
		GameState.visited_zones[z] = true
	await get_tree().create_timer(0.3).timeout
	world.pause_menu.try_open()
	world.pause_menu._open_pokedex()
	await get_tree().create_timer(1.0).timeout
	var dex: Control = world.pause_menu._stack[-1]
	dex._cells[15].grab_focus()  # Pidgey (luchado)
	await get_tree().create_timer(1.2).timeout
	var scroll: ScrollContainer = dex._detail.get_parent()
	scroll.scroll_vertical = 420  # "Dónde aparece"
	await get_tree().create_timer(1.2).timeout
	dex._cells[128].grab_focus()  # Magikarp: Surf y pesca con cada caña
	await get_tree().process_frame
	scroll.scroll_vertical = 330
	await get_tree().create_timer(1.2).timeout
	dex._cells[1].grab_focus()  # Ivysaur (no visto)
	await get_tree().create_timer(1.2).timeout
	dex._cells[93].grab_focus()  # Gengar (visto, no luchado)
	await get_tree().create_timer(1.2).timeout
	dex._show_region(2)
	await get_tree().create_timer(1.2).timeout
	get_tree().quit()
