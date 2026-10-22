extends SceneTree
## Vuelca tags, colisión y tile de cada celda de todas las zonas de kanto.tres a un JSON (para comparar
## antes/después de tocar el TileSet o el catálogo). Uso: godot --headless --path . --script res://tools/dev/dump_zone_cells.gd -- <salida.json>
func _init() -> void:
	var out := {}
	var w: WorldData = load("res://data/world/kanto.tres")
	for z in w.zones:
		if not ResourceLoader.exists(z.scene_path):
			continue
		var n: Node = load(z.scene_path).instantiate()
		var cells := {}
		for ln in ["Ground", "Water", "Foliage", "Overhead"]:
			var l: TileMapLayer = n.get_node(ln)
			for c in l.get_used_cells():
				var td := l.get_cell_tile_data(c)
				var key := "%s:%d,%d" % [ln, c.x, c.y]
				cells[key] = [l.get_cell_source_id(c), str(l.get_cell_atlas_coords(c)), l.get_cell_alternative_tile(c),
					",".join(td.get_custom_data("tags")) if td else "", td.get_collision_polygons_count(0) if td else -1,
					td.get_collision_polygons_count(1) if td else -1]
		out[z.id] = cells
		n.free()
	var f := FileAccess.open(OS.get_cmdline_user_args()[0], FileAccess.WRITE)
	f.store_string(JSON.stringify(out))
	print("zonas: ", out.size())
	quit()
