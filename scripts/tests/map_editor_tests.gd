class_name MapEditorTests
extends Node
## Autotest del editor de mapas (sin ventana): godot --headless --path . --quit-after 20000 -- --autotest-map-editor
## Ida y vuelta sin cambios, pinceles con reglas (arena, agua, árbol, roca), tags y colisión, deshacer/rehacer,
## validaciones, zona nueva y ajuste de tags de un tile. Todo se guarda en user://; no toca res://.

const TMP := "user://map_editor_test"
const ROCK := "res://scenes/world/objects/rock_smash_rock.tscn"
const BOULDER := "res://scenes/world/objects/strength_boulder.tscn"

var autotest: Node
var roles: TileRoleSet
var world: WorldData


func run() -> void:
	var r := {}
	DirAccess.make_dir_recursive_absolute(TMP)
	roles = ZoneBuilder.load_roles()
	world = MapDocument.load_world_copy()
	var entry := _entry("ruta1")
	var zones_on_disk := (load(ZoneBuilder.WORLD_PATH) as WorldData).zones.size()

	# --- 1) Abrir y guardar sin cambios: mismo contenido ---
	var doc := MapDocument.open(world, entry, roles)
	add_child(doc.zone)
	r["Abre Ruta 1 sin cambios pendientes"] = not doc.is_dirty()
	r["Guarda sin cambios en una ruta temporal"] = doc.save(TMP + "/ruta1_rt.tscn") == OK
	var orig := _instance(entry.scene_path)
	var rt := _instance(TMP + "/ruta1_rt.tscn")
	r["Ida y vuelta: tiles por capa, objetos y tree_cells idénticos"] = _same(orig, rt)
	r["Ida y vuelta: hasta los bytes de cada capa son iguales"] = ZoneBuilder.LAYERS.all(func(ln: String) -> bool:
		return (orig.get_node(ln) as TileMapLayer).tile_map_data == (rt.get_node(ln) as TileMapLayer).tile_map_data)
	r["Ida y vuelta: la guardada queda marcada hand_edited"] = rt.hand_edited and ZoneBuilder.is_hand_edited(TMP + "/ruta1_rt.tscn") \
		and not ZoneBuilder.is_hand_edited(entry.scene_path)

	# --- 2) Pinceles con reglas ---
	var sand_rect := _free_rect(doc, Vector2i(5, 4))
	var sand := roles.get_role("sand")
	doc.paint_role(_cells(sand_rect), sand)
	doc.commit("Arena")
	var water_rect := _free_rect(doc, Vector2i(4, 3))
	var water := roles.get_role("water")
	doc.paint_role(_cells(water_rect), water)
	doc.commit("Agua")
	var tree_o := _free_rect(doc, Vector2i(2, 4)).position
	var tree := doc.tree_role()
	doc.paint_role([tree_o], tree)
	doc.commit("Árbol")
	doc.paint_role([tree_o + Vector2i(0, 2)], tree)  # otro justo abajo: el de abajo lleva copa apilada
	doc.commit("Árbol apilado")
	var rock_cell := _free_rect(doc, Vector2i(1, 1)).position
	doc.place_object(rock_cell, ROCK)
	doc.commit("Roca")
	r["Hay cambios sin guardar después de pintar"] = doc.is_dirty()
	r["Guarda la zona editada"] = doc.save(TMP + "/ruta1_edit.tscn") == OK
	var ed := _instance(TMP + "/ruta1_edit.tscn")
	r["Arena: bordes y esquinas del autotile correctos"] = _autotile_ok(ed.ground, sand_rect, sand)
	var water_ok := _autotile_ok(ed.water, water_rect, water)
	for c in _cells(water_rect):
		water_ok = water_ok and roles.role_of(ZoneBuilder.metatile_at(ed.ground, c)) == doc.base_role()
	r["Agua: en la capa Water, con autotile y pasto abajo"] = water_ok
	var m := tree.metatiles
	r["Árbol: tronco y copa en Ground, parte de arriba en Overhead"] = ZoneBuilder.metatile_at(ed.ground, tree_o) == m[0] \
		and ZoneBuilder.metatile_at(ed.ground, tree_o + Vector2i(1, 1)) == m[5] \
		and ed.get_node("Overhead").get_cell_source_id(tree_o) == ZoneBuilder.SRC_ABOVE
	r["Árbol: en tree_cells (sombras)"] = ed.tree_cells.has(tree_o) and ed.tree_cells.has(tree_o + Vector2i(0, 2))
	r["Árbol de abajo: copa apilada"] = ZoneBuilder.metatile_at(ed.ground, tree_o + Vector2i(0, 2)) == m[2]
	var rock: Node = MapRules.objects_by_cell(ed).get(rock_cell)
	r["Roca frágil: EnvObject con sus tags"] = rock is EnvObject and (rock as EnvObject).has_tag("fragil")
	var sc := sand_rect.position + Vector2i(1, 1)
	var wc := water_rect.position + Vector2i(1, 1)
	r["Tags (Zone.get_tags): arena, agua y árbol"] = ed.get_tags(sc) == PackedStringArray(["suelo", "arena"]) \
		and ed.get_tags(wc).has("agua") and ed.get_tags(tree_o).has("arbol") and ed.get_tags(tree_o).has("solido")
	r["Colisión: arena libre, agua, árbol y roca sólidos"] = MapRules.cell_physics(ed, sc) == -1 \
		and MapRules.cell_physics(ed, wc) == MapRules.WATER and MapRules.cell_physics(ed, tree_o) == MapRules.SOLID \
		and MapRules.cell_physics(ed, rock_cell) == MapRules.SOLID

	# --- 3) Deshacer y rehacer ---
	for i in 5:
		doc.do_undo()
	r["Deshacer todo: vuelve a la zona original"] = _same(orig, doc.zone)
	for i in 5:
		doc.do_redo()
	r["Rehacer todo: vuelve a la zona editada"] = _same(ed, doc.zone)
	doc.do_undo()
	r["Deshacer la roca: sin objeto en la celda"] = doc.object_at(rock_cell) == null
	doc.do_redo()

	# --- Balde y copiar/pegar ---
	var filled := doc.flood(sc, MapDocument.GROUND)
	r["Balde: rellena justo la mancha de arena"] = filled.size() == sand_rect.get_area()
	var clip := doc.copy_region(Rect2i(tree_o, Vector2i(2, 2)))
	var paste_at := _free_rect(doc, Vector2i(2, 2)).position
	doc.paste(clip, paste_at)
	doc.commit("Pegar")
	r["Copiar y pegar un árbol: tiles y tree_cells"] = doc.has_tree(paste_at) and doc.metatile(MapDocument.GROUND, paste_at + Vector2i(1, 1)) == m[5]
	doc.do_undo()
	r["Deshacer el pegado"] = not doc.has_tree(paste_at)

	# --- Gráficos de FireRed: catálogo, tiles de otros tilesets y sellos de edificios ---
	var cat := roles.catalog
	var counts := {}
	for id in cat.categories:
		counts[cat.categories[id]] = counts.get(cat.categories[id], 0) + 1
	r["Catálogo: más de 60 tilesets de FireRed y sellos de edificios"] = ZoneBuilder.set_names().size() >= 60 and cat.stamps.size() >= 40
	r["Catálogo: hay edificios, suelos, agua, escaleras, rocas y árboles (tipos de la referencia)"] = ["edificios", "suelos", "agua", "escaleras", "rocas", "arboles"].all(
		func(k: String) -> bool: return counts.get(k, 0) > 0)
	r["TileSet: tiene las fuentes de todos los tilesets"] = Array(ZoneBuilder.set_names()).all(func(n: String) -> bool:
		return doc.tileset.has_source(ZoneBuilder.sources_of(n)[0]))
	var house := -1
	for id in cat.categories:
		if cat.categories[id] == "edificios" and ZoneBuilder.set_of(id) == "pallet_town" and roles.physics_for(id) == 0:
			house = id
			break
	var hc := _free_rect(doc, Vector2i(1, 1)).position
	var href := ZoneBuilder.below_ref(house)
	doc.paint_raw([hc], MapDocument.GROUND, href[0], href[1])
	doc.commit("Tile de Pueblo Paleta")
	var buildings := cat.stamps.filter(func(st: Dictionary) -> bool: return st["group"] != "Piezas del mundo")
	var smallest: Dictionary = buildings[0]
	for st in buildings:
		if st["size"].x * st["size"].y < smallest["size"].x * smallest["size"].y:
			smallest = st
	var sat := _free_rect(doc, smallest["size"]).position
	doc.place_stamp(smallest, sat)
	doc.commit("Sello")
	r["Guarda la zona con un tile de otro tileset y un sello"] = doc.save(TMP + "/ruta1_fr.tscn") == OK
	var fr := _instance(TMP + "/ruta1_fr.tscn")
	r["Tile de Pueblo Paleta: vuelve igual, sólido y con tag edificio"] = ZoneBuilder.metatile_at(fr.ground, hc) == house 		and MapRules.cell_physics(fr, hc) == MapRules.SOLID and fr.get_tags(hc).has("edificio")
	var stamp_ok := true
	var cells: PackedInt32Array = smallest["variants"][0]["cells"]
	for i in cells.size():
		var c: Vector2i = sat + Vector2i(i % smallest["size"].x, i / smallest["size"].x)
		if cells[i] < 0:
			continue
		stamp_ok = stamp_ok and ZoneBuilder.metatile_at(fr.ground, c) == cells[i] 			and (not ZoneBuilder.has_above(cells[i]) or fr.get_node("Overhead").get_cell_source_id(c) >= 0)
	r["Sello: todas las piezas en Ground con su parte de arriba"] = stamp_ok
	r["Sello: el edificio tiene colisión"] = range(cells.size()).any(func(i: int) -> bool:
		return cells[i] >= 0 and MapRules.cell_physics(fr, sat + Vector2i(i % smallest["size"].x, i / smallest["size"].x)) == MapRules.SOLID)
	doc.do_undo()
	doc.do_undo()
	r["Deshacer el sello y el tile"] = ZoneBuilder.metatile_at(doc.layer(MapDocument.GROUND), hc) != house 		and roles.role_of(doc.metatile(MapDocument.GROUND, sat + Vector2i(smallest["size"].x / 2, smallest["size"].y - 1))) == doc.base_role()
	fr.queue_free()

	# --- 4) Validaciones ---
	var side: String = doc.entry.exits.keys()[0]
	r["Validación: la zona editada no tiene salidas bloqueadas"] = not _has_issue(doc.validate(), "bloqueada")
	doc.place_object(doc.entry.exits[side], BOULDER)
	doc.commit("Tapar salida")
	var issues := doc.validate()
	r["Validación: detecta la salida bloqueada"] = _has_issue(issues, "bloqueada")
	doc.do_undo()
	var bare := ZoneEntry.new()
	bare.id = "test_vacia"
	bare.display_name = "Prueba vacía"
	bare.origin = Vector2i(-10000, -10000)
	var plain := MapDocument.create(world, bare, roles, doc.tileset, false)
	add_child(plain.zone)
	r["Validación: avisa que una zona sin pasto alto no tiene salvajes"] = _has_issue(plain.validate(), "pasto alto")
	plain.dispose()

	# --- 5) Zona nueva en un lugar libre (sin dejarla en kanto.tres) ---
	var slots := MapNewZoneDialog.free_slots(world)
	r["Hay lugares libres pegados a la región"] = not slots.is_empty()
	if not slots.is_empty():
		var ne := MapNewZoneDialog.make_entry(world, "test_nueva", "Zona de prueba", "pradera", slots[0] * MapNewZoneDialog.GRID, Vector2i(48, 32), false)
		world.zones.append(ne)
		var nd := MapDocument.create(world, ne, roles, doc.tileset, true)
		add_child(nd.zone)
		var errors := nd.validate().filter(func(it: Dictionary) -> bool: return it["level"] == "error")
		r["Zona nueva generada: válida (sin errores)"] = errors.is_empty() and nd.zone.get_node("Ground").get_used_cells().size() == 48 * 32
		r["Zona nueva: se guarda y vuelve a cargar"] = nd.save(TMP + "/test_nueva.tscn", false) == OK and _instance(TMP + "/test_nueva.tscn") != null
		var dup := MapNewZoneDialog.make_entry(world, "test_dup", "Encimada", "pradera", ne.origin, Vector2i(48, 32), false)
		world.zones.append(dup)
		r["Validación: detecta zonas encimadas"] = nd.validate().any(func(it: Dictionary) -> bool: return it["level"] == "error")
		world.zones.erase(dup)
		world.zones.erase(ne)
		nd.dispose()
	r["kanto.tres en disco sin cambios"] = (load(ZoneBuilder.WORLD_PATH) as WorldData).zones.size() == zones_on_disk

	# --- 6) Panel de tile: tags y colisión de un metatile sin tags (sobre copias, sin guardar) ---
	# Sobre el TileSet cargado (sin guardarlo) y después se restaura: duplicar uno de 15.000 tiles es lento.
	var roles2 := TileRoleSet.new()
	roles2.roles = roles.roles
	var free_m := 2
	roles2.set_override(free_m, PackedStringArray(["cerca", "solido"]), 0)
	ZoneBuilder.apply_tile_props(doc.tileset, roles2, free_m)
	var td := (doc.tileset.get_source(ZoneBuilder.SRC_BELOW) as TileSetAtlasSource).get_tile_data(Vector2i(free_m, 0), 0)
	r["Panel de tile: tags y colisión sólida aplicados al TileSet"] = td.get_custom_data("tags") == PackedStringArray(["cerca", "solido"]) 		and td.get_collision_polygons_count(0) == 1
	ZoneBuilder.apply_tile_props(doc.tileset, roles, free_m)
	r["Sugerencia por behavior: pasto alto (0x02)"] = roles.behavior_hints.get(2, {}).get("tags", PackedStringArray()).has("pasto_alto")

	doc.dispose()
	for n in [orig, rt, ed]:
		n.queue_free()
	for f in DirAccess.get_files_at(TMP):
		DirAccess.remove_absolute(TMP + "/" + f)

	await _ui_smoke(r)
	await _relocation(r)
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[map-editor] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-map-editor] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## La escena real del editor manejada como con el mouse y el teclado (no guarda nada).
func _ui_smoke(r: Dictionary) -> void:
	get_tree().change_scene_to_file("res://scenes/tools/map_editor.tscn")
	await _frames(4)
	var ed: Node = get_tree().current_scene
	var d: MapDocument = ed.doc
	r["UI: abre el editor con una zona"] = d != null and d.zone.is_inside_tree()
	var sand := roles.get_role("sand")
	var rect := _free_rect(d, Vector2i(4, 3))
	ed.set_brush(ed._brushes.brush("role:sand"))
	ed.set_tool(ed.Tool.RECT)
	ed._press(rect.position, false)
	ed._drag(rect.end - Vector2i.ONE)
	ed._release(rect.end - Vector2i.ONE)
	r["UI: rectángulo de arena con autotile"] = _autotile_ok(d.layer(MapDocument.GROUND), rect, sand) and d.is_dirty()
	var p := _free_rect(d, Vector2i(4, 1)).position
	ed.set_brush(ed._brushes.brush("role:tall_grass"))
	ed.set_tool(ed.Tool.PENCIL)
	ed._press(p, false)
	ed._drag(p + Vector2i(3, 0))
	ed._release(p + Vector2i(3, 0))
	r["UI: pincel arrastrando (pasto alto en Foliage)"] = range(4).all(func(i: int) -> bool:
		return d.role_in(MapDocument.FOLIAGE, p + Vector2i(i, 0)) == roles.get_role("tall_grass"))
	var key := InputEventKey.new()
	key.keycode = KEY_Z
	key.ctrl_pressed = true
	key.pressed = true
	ed._shortcut(key)
	r["UI: Ctrl+Z deshace el trazo entero"] = d.layer(MapDocument.FOLIAGE).get_cell_source_id(p) < 0 \
		and d.layer(MapDocument.FOLIAGE).get_cell_source_id(p + Vector2i(3, 0)) < 0
	var q := _free_rect(d, Vector2i(8, 2)).position
	ed.set_brush(ed._brushes.brush("role:tree"))
	ed.set_tool(ed.Tool.LINE)
	ed._press(q, false)
	ed._drag(q + Vector2i(6, 0))
	ed._release(q + Vector2i(6, 0))
	r["UI: línea de árboles cada 2 celdas"] = d.has_tree(q) and d.has_tree(q + Vector2i(2, 0)) and d.has_tree(q + Vector2i(6, 0))
	ed.set_brush(ed._brushes.brush("role:dirt"))
	ed.set_tool(ed.Tool.FILL)
	ed._press(rect.position + Vector2i.ONE, false)
	r["UI: balde cambia toda la mancha de arena por tierra"] = _autotile_ok(d.layer(MapDocument.GROUND), rect, roles.get_role("dirt"))
	ed.set_brush(ed._brushes.brush("role:grass"))
	ed.pick(rect.position)
	r["UI: gotero toma el pincel de la celda"] = ed.brush.get("key") == "role:dirt"
	ed.set_tool(ed.Tool.SELECT)
	ed._press(q, false)
	ed._drag(q + Vector2i(1, 1))
	ed._release(q + Vector2i(1, 1))
	ed._copy()
	var dest := _free_rect(d, Vector2i(2, 2)).position
	ed._start_paste()
	ed._press(dest, false)
	r["UI: seleccionar, copiar y pegar un árbol"] = d.has_tree(dest)
	ed.pasting = false
	var hub := d.entry.hub
	ed.set_tool(ed.Tool.MARKERS)
	ed._press(hub, false)
	ed._drag(hub + Vector2i(2, 2))
	ed._release(hub + Vector2i(2, 2))
	var moved := d.entry.hub == hub + Vector2i(2, 2)
	ed._undo()
	r["UI: arrastrar la plaza (y deshacer)"] = moved and d.entry.hub == hub
	ed.set_tool(ed.Tool.SPAWN)
	ed._press(hub, false)
	r["UI: elegir inicio del juego"] = d.world.spawn_cell == d.entry.origin + hub
	r["UI: la paleta muestra los edificios de FireRed"] = _palette_count(ed, "", "edificios") > 100
	r["UI: la paleta filtra por tileset (rocas de Cuevas)"] = _palette_count(ed, "cave", "rocas") > 0
	r["UI: la pestaña Sellos lista los edificios"] = ed._stamps._list.item_count == roles.catalog.stamps.size()
	var st0: Dictionary = roles.catalog.stamps[0]
	var at := _free_rect(d, st0["size"]).position
	ed._stamps.stamp_selected.emit(st0, 0)
	ed.set_tool(ed.Tool.PENCIL)
	ed._press(at, false)
	ed._release(at)
	var first := 0
	var st0_cells: PackedInt32Array = st0["variants"][0]["cells"]
	while st0_cells[first] < 0:
		first += 1
	r["UI: un clic pega el sello"] = d.metatile(MapDocument.GROUND, at + Vector2i(first % st0["size"].x, first / st0["size"].x)) == st0_cells[first]
	r["UI: la zona en disco no cambió"] = not ZoneBuilder.is_hand_edited(d.entry.scene_path)


## Partida guardada parada sobre un árbol (como si el mapa hubiera cambiado): World la lleva a lo libre.
func _relocation(r: Dictionary) -> void:
	GameState.new_game(DB.config.starters[0])
	GameState.wilds_enabled = false
	var w := DB.config.world
	var e: ZoneEntry
	for z in w.zones:
		if z.id == "ruta1":
			e = z
	var zone_scene: Zone = _instance(e.scene_path)
	var tree_cell: Vector2i = zone_scene.tree_cells[0] + Vector2i(0, 1)  # tronco
	zone_scene.queue_free()
	GameState.trainer_position = Vector2((e.origin + tree_cell) * w.tile_size) + Vector2(8, 8)
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _frames(3)
	var world_node: Node = get_tree().current_scene
	var zone: Zone = world_node.streamer.zone_node("ruta1")
	var cell := zone.cell_at(world_node.trainer.global_position)
	r["Juego: si la posición guardada quedó en algo sólido, aparece en lo libre más cercano"] = \
		MapRules.is_walkable(zone, cell) and Vector2(cell - tree_cell).length() <= 3.0


## Vitrina (--write-movie ... -- --showcase-map-editor): el editor con colisión, la paleta y el panel de tile.
func showcase() -> void:
	get_tree().change_scene_to_file("res://scenes/tools/map_editor.tscn")
	for i in 4:
		await get_tree().process_frame
	var ed: Node = get_tree().current_scene
	ed._toggle_view(1)  # colisión
	ed.hover = Vector2i(20, 12)
	ed._update_hover()
	await _frames(20)
	ed._toggle_view(1)
	ed._tabs.current_tab = ed.TAB_STAMPS
	await _frames(20)
	ed._tabs.current_tab = ed.TAB_TILES
	ed._palette.set_filters("", "edificios")
	await _frames(20)
	ed._palette.set_filters("cave", "rocas")
	await _frames(20)
	ed._palette.set_filters("", "arboles")
	ed._palette._as_sheet.button_pressed = true
	await _frames(20)
	ed._palette._as_sheet.button_pressed = false
	ed._tabs.current_tab = ed.TAB_STAMPS
	ed._stamps._group.select(1)
	ed._stamps._fill_places()
	ed._stamps.refresh()
	for i in ed._stamps._list.item_count:
		if (ed._stamps._list.get_item_metadata(i)["variants"] as Array).size() > 1:
			ed._stamps._list.select(i)
			ed._stamps._on_selected(i)
	await _frames(20)
	ed._tabs.current_tab = ed.TAB_TILE
	ed._props.show_metatile(213)
	await _frames(20)
	ed._tabs.current_tab = ed.TAB_ZONE
	ed.validate()
	await _frames(20)
	get_tree().quit()


func _palette_count(ed: Node, set_name: String, category: String) -> int:
	ed._palette.set_filters(set_name, category)
	return ed._palette._list.item_count


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _entry(id: String) -> ZoneEntry:
	for z in world.zones:
		if z.id == id:
			return z
	return null


func _instance(path: String) -> Zone:
	var packed: PackedScene = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if packed == null:
		return null
	var z: Zone = packed.instantiate()
	add_child(z)
	return z


## Mismo contenido: tiles de cada capa (celda por celda; el orden interno de tile_map_data puede variar),
## objetos (escena + posición) y tree_cells.
func _same(a: Node, b: Node) -> bool:
	for ln in ZoneBuilder.LAYERS:
		var la := a.get_node(ln) as TileMapLayer
		var lb := b.get_node(ln) as TileMapLayer
		var cells := {}
		var used := la.get_used_cells()
		used.append_array(lb.get_used_cells())
		for c in used:
			if [la.get_cell_source_id(c), la.get_cell_atlas_coords(c), la.get_cell_alternative_tile(c)] 					!= [lb.get_cell_source_id(c), lb.get_cell_atlas_coords(c), lb.get_cell_alternative_tile(c)]:
				cells[c] = [ZoneBuilder.metatile_at(la, c), ZoneBuilder.metatile_at(lb, c)]
		if not cells.is_empty():
			print("  distinta la capa ", ln, ": ", cells if cells.size() < 12 else "%d celdas" % cells.size())
			return false
	var oa := a.get_node("Objects").get_children().map(func(n): return [n.scene_file_path, n.position])
	var ob := b.get_node("Objects").get_children().map(func(n): return [n.scene_file_path, n.position])
	oa.sort()
	ob.sort()
	if oa != ob:
		print("  distintos los objetos")
		return false
	var ta: Array = a.tree_cells.duplicate()
	var tb: Array = b.tree_cells.duplicate()
	ta.sort()
	tb.sort()
	return ta == tb


func _cells(rect: Rect2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			out.append(Vector2i(x, y))
	return out


## Rectángulo de pasto común sin objetos ni árboles, rodeado de tiles sueltos (pasto, flores...: nada con
## autotile ni árboles, así se pueden verificar sus bordes).
func _free_rect(doc: MapDocument, size: Vector2i) -> Rect2i:
	var base := doc.base_role()
	for y in range(3, doc.entry.size.y - size.y - 3):
		for x in range(3, doc.entry.size.x - size.x - 3):
			var ok := true
			for c in _cells(Rect2i(Vector2i(x - 1, y - 1), size + Vector2i(2, 2))):
				var inner := Rect2i(Vector2i(x, y), size).has_point(c)
				var role := doc.role_at(c)
				if (inner and (role != base or doc.object_at(c) != null)) or role == null or role.kind != TileRole.Kind.TILE 						or doc.layer(MapDocument.OVERHEAD).get_cell_source_id(c) >= 0:
					ok = false
					break
			if ok:
				return Rect2i(Vector2i(x, y), size)
	push_error("No hay lugar libre de %s" % size)
	return Rect2i(Vector2i(4, 4), size)


## Cada celda del rectángulo tiene la pieza del 3x3 que le toca (rodeado de otra cosa).
func _autotile_ok(layer: TileMapLayer, rect: Rect2i, role: TileRole) -> bool:
	for c in _cells(rect):
		var row := 0 if c.y == rect.position.y else (2 if c.y == rect.end.y - 1 else 1)
		var col := 0 if c.x == rect.position.x else (2 if c.x == rect.end.x - 1 else 1)
		if ZoneBuilder.metatile_at(layer, c) != role.piece(row, col):
			print("  autotile mal en ", c, ": ", ZoneBuilder.metatile_at(layer, c), " en vez de ", role.piece(row, col))
			return false
	return true


func _has_issue(issues: Array[Dictionary], text: String) -> bool:
	return issues.any(func(it: Dictionary) -> bool: return (it["msg"] as String).contains(text))
