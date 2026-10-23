extends SceneTree
## Renderiza zonas enteras a PNG (para revisar mapas sin abrir el juego). Necesita GPU (sin --headless).
## Uso: godot --path . --script res://tools/dev/render_zone.gd -- <carpeta> [id_zona ...]  (sin ids: todas)
func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var out_dir: String = args[0]
	var ids := args.slice(1)
	var w: WorldData = load("res://data/world/kanto.tres")
	for z in w.zones:
		if (not ids.is_empty() and z.id not in ids) or not ResourceLoader.exists(z.scene_path):
			continue
		var vp := SubViewport.new()
		vp.size = z.size * w.tile_size
		vp.transparent_bg = false
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		vp.add_child(load(z.scene_path).instantiate())
		for i in 4:
			await process_frame
		vp.get_texture().get_image().save_png(out_dir.path_join(z.id + ".png"))
		print("renderizada ", z.id, " ", vp.size)
		vp.queue_free()
	quit()
