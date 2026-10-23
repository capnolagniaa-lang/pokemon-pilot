class_name EncounterTests
extends Node
## Pokémon salvajes por zona (tablas de encuentros y áreas pintadas):
##   godot --headless --path . --quit-after 20000 -- --autotest-encounters
## No toca los archivos del juego: lo que guarda va a user://.

const TMP := "user://encounter_test"

var autotest: Node


func run() -> void:
	var r := {}
	DirAccess.make_dir_recursive_absolute(TMP)
	var world_data := DB.config.world
	var ruta1: ZoneEntry
	var other: ZoneEntry
	for z in world_data.zones:
		if z.id == "ruta1":
			ruta1 = z
		elif not ResourceLoader.exists(EncounterTable.zone_path(z.id)) and z.biome == "pradera":
			other = z
	var t1 := EncounterTable.for_zone(ruta1)
	r["Ruta 1 tiene tabla propia"] = t1 != null and t1.entries.size() >= 2
	r["Una zona sin tabla propia usa la de su bioma"] = other == null or EncounterTable.for_zone(other) != null
	var tpl := EncounterTable.templates()
	var route1_tpl: Array = tpl.filter(func(x): return x["id"] == "route1")
	r["Plantillas de FireRed (más de 100, Ruta 1 con Pidgey y Rattata)"] = tpl.size() > 100 and not route1_tpl.is_empty() \
		and EncounterTable.from_template(route1_tpl[0]).entries.map(func(e): return e.species_id) == ["pidgey", "rattata"]

	# Pesos
	var t := EncounterTable.new()
	t.entries.append(_row("pidgey", 70, "pasto_alto"))
	t.entries.append(_row("rattata", 30, "pasto_alto"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var count := 0
	for i in 4000:
		count += int(t.pick_at(rng, Vector2i.ZERO, PackedStringArray(["pasto_alto"])).species_id == "pidgey")
	r["Los porcentajes se respetan (70/30 → %.1f%%)" % (count / 40.0)] = absf(count / 4000.0 - 0.7) < 0.03

	# Áreas: adentro el ajuste pisa la tabla
	var area := EncounterArea.new()
	area.cells = [Vector2i(3, 3)]
	area.adjustments.append(_row("pikachu", 50, "pasto_alto"))
	area.adjustments.append(_row("rattata", 0, "pasto_alto"))
	t.areas.append(area)
	var inside := t.chances_at(Vector2i(3, 3), PackedStringArray(["pasto_alto"]))
	var outside := t.chances_at(Vector2i(9, 9), PackedStringArray(["pasto_alto"]))
	r["Área: suma un Pokémon y saca otro (peso 0) solo adentro"] = inside.has("pikachu") and not inside.has("rattata") \
		and absf(inside["pikachu"] - 50.0 / 120.0) < 0.001 and outside.has("rattata") and not outside.has("pikachu")

	# En el mundo: el spawner usa la tabla, los niveles y el lugar; las áreas y el agua
	GameState.new_game(DB.config.starters[0])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _frames(3)
	var world: Node = get_tree().current_scene
	world.streamer.load_around_now(ruta1.world_rect(world_data.tile_size).get_center())
	await _frames(2)
	var sp: WildSpawner = world.spawner
	var zone: Zone = world.streamer.zone_node("ruta1")
	sp._tables["ruta1"] = t1
	var ok := true
	var ids := t1.entries.map(func(e): return e.species_id)
	for i in 300:
		var roll := sp.roll("ruta1")
		if roll.is_empty():
			ok = false
			break
		var row: EncounterEntry = t1.entries.filter(func(e): return e.species_id == roll[0].id)[0] if ids.has(roll[0].id) else null
		ok = ok and row != null and roll[1] >= row.min_level and roll[1] <= row.max_level and zone.get_tags(roll[2]).has(row.where)
	r["Spawner: solo especies de la tabla, en su rango de nivel y su lugar"] = ok
	# Área en un parche de pasto alto: ahí solo Pikachu; afuera solo Pidgey
	var grass: Array = sp.cells_for("ruta1", zone, PackedStringArray(["pasto_alto"]))["pasto_alto"]
	var t2 := EncounterTable.new()
	t2.entries.append(_row("pidgey", 100, "pasto_alto"))
	var a2 := EncounterArea.new()
	for i in grass.size() / 2:
		a2.cells.append(grass[i])
	a2.adjustments.append(_row("pikachu", 100, "pasto_alto"))
	a2.adjustments.append(_row("pidgey", 0, "pasto_alto"))
	t2.areas.append(a2)
	sp._tables["ruta1"] = t2
	var area_ok := true
	var saw := {}
	for i in 300:
		var roll := sp.roll("ruta1")
		var in_area := a2.cells.has(roll[2])
		saw[roll[0].id] = true
		area_ok = area_ok and (roll[0].id == "pikachu") == in_area
	r["Spawner: el área pintada cambia lo que aparece ahí (y solo ahí)"] = area_ok and saw.has("pikachu") and saw.has("pidgey")
	# Agua
	# (en la Ruta 22, que tiene laguna)
	var t3 := EncounterTable.new()
	t3.entries.append(_row("psyduck", 100, "agua"))
	var lake: ZoneEntry = null
	for z in world_data.zones:
		if z.id == "ruta22":
			lake = z
	world.streamer.load_around_now(lake.world_rect(world_data.tile_size).get_center())
	var wzone: Zone = world.streamer.zone_node("ruta22")
	sp._tables["ruta22"] = t3
	var wroll := sp.roll("ruta22")
	var water_ok := not wroll.is_empty() and wzone.get_tags(wroll[2]).has("agua")
	if water_ok:
		var c: Creature = sp.spawn(wroll[0], wroll[1], wzone.to_global(wzone.ground.map_to_local(wroll[2])))
		c.swims = true
		water_ok = c.collision_mask & 2 == 0
		c.queue_free()
	r["Agua: aparece en el agua y nada (no choca con el agua)"] = water_ok
	# Modo de prueba
	GameState.wild_test_pool = true
	var pool_ok := true
	for i in 60:
		var roll := sp.roll("ruta1")
		pool_ok = pool_ok and not roll.is_empty() and roll[0].id in WildSpawner.TEST_POOL
	GameState.wild_test_pool = false
	r["Salvajes de prueba: solo los 4 de prueba"] = pool_ok

	# Editor: tabla propia, área pintada, guardar, deshacer, validar
	var wd := MapDocument.load_world_copy()
	var e1: ZoneEntry
	for z in wd.zones:
		if z.id == "ruta1":
			e1 = z
	var doc := MapDocument.open(wd, e1, ZoneBuilder.load_roles())
	add_child(doc.zone)
	doc.encounters_path = TMP + "/ruta1.tres"
	doc.load_encounters()
	r["Editor: sin tabla propia guardada, usa la del bioma"] = doc.encounters == null and doc.effective_encounters() != null
	doc.edit_encounters(func(tt: EncounterTable): tt.entries.append(_row("pikachu", 5, "pasto_alto")), "Agregar")
	var cells: Array[Vector2i] = []
	for i in 6:
		cells.append(grass[i])
	doc.edit_encounters(func(tt: EncounterTable):
		var a := EncounterArea.new()
		a.name = "Rincón"
		a.adjustments.append(_row("pikachu", 40, "pasto_alto"))
		tt.areas.append(a), "Área")
	doc.paint_area(cells, 0, true)
	doc.commit("Pintar área")
	r["Editor: el % en el área se ve en la celda"] = doc.chances_at(grass[0]).has("pikachu") \
		and doc.chances_at(grass[0])["pikachu"] > doc.chances_at(grass[grass.size() - 1]).get("pikachu", 0.0)
	r["Editor: guarda la zona y su tabla"] = doc.save(TMP + "/ruta1.tscn", false) == OK and FileAccess.file_exists(TMP + "/ruta1.tres")
	var back: EncounterTable = ResourceLoader.load(TMP + "/ruta1.tres", "", ResourceLoader.CACHE_MODE_REPLACE)
	r["Editor: la tabla vuelve igual (filas y celdas del área)"] = back != null and back.entries.size() == doc.encounters.entries.size() \
		and back.areas.size() == 1 and back.areas[0].cells.size() == 6 and back.areas[0].name == "Rincón"
	doc.do_undo()
	r["Deshacer: saca las celdas pintadas"] = doc.encounters.areas[0].cells.is_empty()
	doc.do_undo()
	doc.do_undo()
	r["Deshacer todo: vuelve a la tabla del bioma"] = doc.encounters == null
	doc.edit_encounters(func(tt: EncounterTable): tt.entries.append(_row("diglett", 10, "tierra")), "Agregar")
	r["Validación: avisa si un Pokémon tiene un lugar que la zona no tiene"] = doc.validate().any(func(it: Dictionary) -> bool:
		return (it["msg"] as String).contains("Diglett"))
	doc.dispose()

	# La pestaña Salvajes del editor
	get_tree().change_scene_to_file("res://scenes/tools/map_editor.tscn")
	await _frames(4)
	var ed: Node = get_tree().current_scene
	ed.doc.encounters_path = TMP + "/ui.tres"
	ed.doc.load_encounters()
	ed._wild.refresh()
	ed._tabs.current_tab = ed.TAB_WILD
	ed._wild.add_species("pikachu", -1)
	r["UI: agregar un Pokémon a la tabla de la zona"] = ed.doc.encounters != null \
		and ed.doc.encounters.entries.any(func(e): return e.species_id == "pikachu")
	ed.doc.edit_encounters(func(tt: EncounterTable): tt.areas.append(EncounterArea.new()), "Área")
	ed._wild.paint_area_requested.emit(0)
	ed.set_tool(ed.Tool.RECT)
	ed._press(grass[0], false)
	ed._drag(grass[0] + Vector2i(1, 1))
	ed._release(grass[0] + Vector2i(1, 1))
	r["UI: pintar un área con el rectángulo"] = ed.doc.encounters.areas[0].cells.size() == 4
	ed.hover = grass[0]
	ed._update_status()
	r["UI: la barra de abajo muestra el % del área bajo el mouse"] = ed._status.text.contains("Área")
	r["UI: nada se guardó en el juego"] = not FileAccess.file_exists(TMP + "/ui.tres") and t1.entries.size() == EncounterTable.for_zone(ruta1).entries.size()

	for f in DirAccess.get_files_at(TMP):
		DirAccess.remove_absolute(TMP + "/" + f)
	var all_ok := r.values().all(func(x): return x)
	for k in r:
		print("[salvajes] %s %s" % ["OK   " if r[k] else "FALLO", k])
	print("[autotest-encounters] -> ", "OK" if all_ok else "FALLO")
	get_tree().quit(0 if all_ok else 1)


func _row(sp: String, w: int, where: String) -> EncounterEntry:
	var e := EncounterEntry.new()
	e.species_id = sp
	e.weight = w
	e.min_level = 3
	e.max_level = 6
	e.where = where
	return e


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
