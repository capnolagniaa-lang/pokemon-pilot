extends SceneTree
## Auditoría de una zona para el terreno propio (docs/PLAN_TERRENO_PROPIO.md): qué metatiles, roles, categorías y
## sellos de FireRed usa, así se sabe qué piezas hacen falta para dibujarla con un paquete (StyleOverlay).
##   godot --headless --path . --quit-after 60000 --script res://tools/style_audit.gd -- <zona> [<zona>...]

func _init() -> void:
	var catalog: TileCatalog = load("res://data/world/tile_catalog.tres")
	var roles: TileRoleSet = ZoneBuilder.load_roles()
	var world: WorldData = load("res://data/world/kanto.tres")
	var args := OS.get_cmdline_user_args()
	for zone_id in args:
		var entry: ZoneEntry = null
		for z in world.zones:
			if z.id == zone_id:
				entry = z
		if entry == null:
			print("no existe ", zone_id)
			continue
		var zone: Node2D = load(entry.scene_path).instantiate()
		root.add_child(zone)
		_audit(zone, entry, catalog, roles)
		zone.free()
	quit()


func _audit(zone: Node, entry: ZoneEntry, catalog: TileCatalog, roles: TileRoleSet) -> void:
	print("\n=== %s (%s) %dx%d bioma %s, puertas %d, árboles %d" % [entry.id, entry.display_name, entry.size.x, entry.size.y,
		entry.biome, entry.warps.size(), zone.tree_cells.size()])
	var by_role := {}
	var by_cat := {}
	var unknown := {}
	for layer_name in ["Ground", "Water", "Foliage"]:
		var l: TileMapLayer = zone.get_node(layer_name)
		for c in l.get_used_cells():
			var m := ZoneBuilder.metatile_of(l.get_cell_source_id(c), l.get_cell_atlas_coords(c))
			var role := roles.role_of(m)
			var cat: String = catalog.categories.get(str(m), "?")
			if role != null:
				by_role[layer_name + ":" + role.id] = by_role.get(layer_name + ":" + role.id, 0) + 1
			else:
				by_cat[cat] = by_cat.get(cat, 0) + 1
				unknown[m] = unknown.get(m, 0) + 1
	print("Roles:")
	for k in by_role:
		print("  %-28s %d" % [k, by_role[k]])
	print("Sin rol, por categoría del catálogo:")
	for k in by_cat:
		print("  %-28s %d" % [k, by_cat[k]])
	var top := unknown.keys()
	top.sort_custom(func(a, b): return unknown[a] > unknown[b])
	print("Metatiles sin rol más usados (id: veces, categoría, tags de una celda de muestra):")
	for m in top.slice(0, 25):
		var cat = catalog.categories.get(m, catalog.categories.get(str(m), "?"))
		print("  %d: %d, %s, %s" % [m, unknown[m], cat, _sample_tags(zone, m)])
	# Sellos: cuáles aparecen y dónde.
	var ground: TileMapLayer = zone.get_node("Ground")
	for st: Dictionary in catalog.stamps:
		var size: Vector2i = st["size"]
		var want: PackedInt32Array = (st["variants"][0] if st.has("variants") else st)["cells"]
		var found := []
		for y in range(entry.size.y - size.y + 1):
			for x in range(entry.size.x - size.x + 1):
				if _matches(ground, Vector2i(x, y), size, want):
					found.append(Vector2i(x, y))
		if not found.is_empty():
			print("Sello %s (%s, %dx%d, puertas %s): %s" % [st["id"], st.get("name", ""), size.x, size.y, st.get("doors", []), found])


func _sample_tags(zone: Node, m: int) -> PackedStringArray:
	for layer_name in ["Ground", "Water", "Foliage"]:
		var l: TileMapLayer = zone.get_node(layer_name)
		for c in l.get_used_cells():
			if ZoneBuilder.metatile_of(l.get_cell_source_id(c), l.get_cell_atlas_coords(c)) == m:
				return zone.get_tags(c)
	return PackedStringArray()


func _matches(ground: TileMapLayer, at: Vector2i, size: Vector2i, want: PackedInt32Array) -> bool:
	for i in want.size():
		if want[i] < 0:
			continue
		var c := at + Vector2i(i % size.x, i / size.x)
		var src := ground.get_cell_source_id(c)
		if src < 0 or ZoneBuilder.metatile_of(src, ground.get_cell_atlas_coords(c)) != want[i]:
			return false
	return true
