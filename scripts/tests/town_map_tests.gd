class_name TownMapTests
extends Node
## Autotest del Mapa del menú (Esc → Mapa; TownMap + TownMapScreen):
##   godot --headless --path . --quit-after 30000 -- --autotest-town-map
## Vitrina (el mapa abierto en Ciudad Plateada, con niebla, íconos y la estrella):
##   godot --path . --quit-after 120 --write-movie out/f.png --fixed-fps 30 -- --showcase-town-map

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	var wd: WorldData = DB.config.world
	# --- Geometría ---
	var ids := TownMap.map_zones(wd).map(func(z): return z.id)
	r["En el mapa: ciudades y rutas (%d zonas)" % ids.size()] = ["pueblo_paleta", "ruta1", "ciudad_verde", "ciudad_plateada",
		"ciudad_celeste"].all(func(id): return id in ids)
	r["Fuera del mapa: interiores y el Bosque Verde (lejos, abajo)"] = not "bosque_verde" in ids and not "laboratorio_oak" in ids
	var ents := TownMap.entrances(wd)
	r["El Bosque Verde se ubica en la Ruta 2 (por sus garitas)"] = TownMap.map_zone_at(wd, ents.get("bosque_verde", Vector2i(-1, -1))) == "ruta2"
	r["El Mt. Moon se ubica en la Ruta 3 o 4"] = TownMap.map_zone_at(wd, ents.get("mt_moon", Vector2i(-1, -1))) in ["ruta3", "ruta4"]
	r["El laboratorio de Oak está en Pueblo Paleta"] = TownMap.map_zone_at(wd, ents.get("laboratorio_oak", Vector2i(-1, -1))) == "pueblo_paleta"
	var icons := TownMap.icons(wd, ents)
	var icon_of := func(zone: String) -> Dictionary:
		for ic in icons:
			if ic["zone"] == zone:
				return ic
		return {}
	r["Ícono de Centro en Ciudad Verde"] = icon_of.call("ciudad_verde_centro").get("letter", "") == "C" \
		and TownMap.map_zone_at(wd, icon_of.call("ciudad_verde_centro")["cell"]) == "ciudad_verde"
	r["Ícono de Gimnasio en Ciudad Plateada"] = icon_of.call("ciudad_plateada_gimnasio").get("letter", "") == "G"
	r["Ícono de Tienda en Ciudad Celeste"] = icon_of.call("ciudad_celeste_tienda").get("letter", "") == "T"
	var names := TownMap.places(wd, ents).map(func(p): return p["name"])
	r["Lugares con nombre fuera del mapa (Bosque Verde, Mt. Moon)"] = "Bosque Verde" in names and "Mt. Moon" in names
	var t0 := Time.get_ticks_msec()
	var img := TownMap.image(wd)
	var b := TownMap.bounds(wd)
	r["La imagen se dibuja desde los mapas (%d ms)" % (Time.get_ticks_msec() - t0)] = img != null \
		and img.get_size() == b.size * TownMap.CELL_PX and img.get_pixelv(_px(TownMap.zone_cell(wd, "pueblo_paleta"))).a > 0.5

	# --- Partidas viejas (sin zonas visitadas) ---
	GameState.new_story()
	for f in ["oak_te_freno", "tiene_inicial", "rival_lab_peleado", "tiene_paquete", "paquete_entregado", "medalla_roca"]:
		GameState.set_flag(f)
	GameState.party.append(CreatureInstance.create(DB.species["squirtle"], 15))
	var d := GameState.to_dict()
	d.erase("visited_zones")
	GameState.from_dict(d)
	r["Partida vieja: lo recorrido según la historia queda visitado"] = ["pueblo_paleta", "ruta1", "ciudad_verde", "ruta2",
		"bosque_verde", "ciudad_plateada"].all(func(id): return GameState.visited_zones.has(id)) \
		and not GameState.visited_zones.has("ciudad_celeste")
	var free := {"party": d["party"], "story_flags": []}
	GameState.from_dict(free)
	r["Partida vieja del modo libre: todo a la vista"] = GameState.visited_zones.has("ciudad_carmin")
	GameState.from_dict(d)
	GameState.visited_zones["ruta3"] = true
	var d2 := GameState.to_dict()
	GameState.visited_zones.clear()
	GameState.from_dict(d2)
	r["Las zonas visitadas se guardan"] = GameState.visited_zones.has("ruta3") and GameState.visited_zones.has("ciudad_plateada")
	GameState.visited_zones.erase("ruta3")

	# --- En el juego: Ciudad Plateada, dentro del gimnasio ---
	await _start("ciudad_plateada_gimnasio", Vector2i(6, 10))
	r["Al entrar a una zona queda visitada"] = GameState.visited_zones.has("ciudad_plateada_gimnasio")
	r["Sin el objeto Mapa no aparece en el menú"] = world.pause_menu.try_open() and not world.pause_menu._map_button.visible
	world.pause_menu.close()
	GameState.add_item("mapa", 1)
	r["Con el objeto Mapa (Dalia) aparece en el menú"] = world.pause_menu.try_open() and world.pause_menu._map_button.visible
	world.pause_menu._open_map()
	await get_tree().process_frame
	var screen: TownMapScreen = world.pause_menu._stack[-1]
	r["Se abre la pantalla del Mapa"] = screen is TownMapScreen and screen.visible
	r["Dentro del gimnasio, vos estás en su puerta en Ciudad Plateada"] = TownMap.map_zone_at(wd, screen._player) == "ciudad_plateada" \
		and screen._player == ents["ciudad_plateada_gimnasio"]
	r["La estrella marca el objetivo de la Guía (Mt. Moon)"] = StoryGuide.current().get("goal", "") == "mt_moon" \
		and screen._goal == ents["mt_moon"]
	r["Lo no visitado está tapado (Ciudad Celeste)"] = not screen.visited("ciudad_celeste") \
		and screen._place_name(TownMap.zone_cell(wd, "ciudad_celeste")) == "???"
	r["Lo visitado muestra su nombre"] = screen._place_name(TownMap.zone_cell(wd, "ciudad_verde")) == "Ciudad Verde"
	var z0 := screen.zoom
	screen.set_zoom(z0 * 100.0)
	var zmax := screen.zoom
	screen.set_zoom(0.0001)
	r["Zoom con tope (de %.2f a %.2f)" % [screen.zoom, zmax]] = zmax == TownMapScreen.ZOOM_MAX and screen.zoom == TownMapScreen.ZOOM_MIN
	screen.center_on_player()
	r["Espacio centra en vos"] = screen.cam.distance_to(screen.cell_to_image(screen._player)) < 1.0
	world.pause_menu._pop()
	r["Esc vuelve al menú"] = world.pause_menu._stack.is_empty()
	world.pause_menu.close()

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[town-map] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-town-map] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina: el mapa abierto con niebla (hasta Ciudad Plateada) y la estrella en el Mt. Moon.
func showcase() -> void:
	GameState.new_story()
	for f in ["oak_te_freno", "tiene_inicial", "rival_lab_peleado", "tiene_paquete", "paquete_entregado", "medalla_roca", "rival_ruta22_peleado"]:
		GameState.set_flag(f)
	GameState.party.append(CreatureInstance.create(DB.species["squirtle"], 15))
	GameState.visited_zones = TownMap.visited_from_progress(GameState.story_flags, DB.config.world)
	GameState.add_item("mapa", 1)
	await _start("ciudad_plateada", Vector2i(40, 40))
	world.pause_menu.try_open()
	world.pause_menu._open_map()
	await get_tree().process_frame
	var screen: TownMapScreen = world.pause_menu._stack[-1]
	screen.set_zoom(0.32)


func _start(zone_id: String, cell: Vector2i) -> void:
	var wd: WorldData = DB.config.world
	for z in wd.zones:
		if z.id == zone_id:
			GameState.trainer_position = Vector2((z.origin + cell) * wd.tile_size) + Vector2.ONE * wd.tile_size / 2.0
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	await get_tree().create_timer(0.5).timeout


func _px(cell: Vector2i) -> Vector2i:
	return (cell - TownMap.origin()) * TownMap.CELL_PX
