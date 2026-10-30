class_name StyleTests
extends Node
## Terreno propio en la zona de pruebas (StyleOverlay, docs/PLAN_TERRENO_PROPIO.md):
##   godot --headless --path . --quit-after 60000 -- --autotest-style
## Vitrina (cada paquete en el pueblo, el bosque y la cueva; imprime qué cuadros son cada uno):
##   godot --path . --quit-after 900 --write-movie out/f.png --fixed-fps 30 -- --showcase-style

const SPOTS := [["pruebas_pueblo", Vector2i(20, 17)], ["pruebas_pueblo", Vector2i(10, 15)], ["pruebas_bosque", Vector2i(13, 14)],
	["pruebas_cueva", Vector2i(9, 9)]]
const FRAMES := 20

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	for pack in StyleOverlay.PACKS:
		var missing := []
		for piece in StyleOverlay.MATERIALS + ["casa", "fuente", "arbol", "cerca"]:
			if piece == "mat_pasto_alto":
				continue  # opcional: sin él, el pasto alto va con matas sueltas
			if not ResourceLoader.exists(StyleOverlay.DIR % [pack, piece]):
				missing.append(piece)
		r["Paquete %s completo%s" % [pack, (" (faltan: %s)" % ", ".join(missing)) if missing else ""]] = missing.is_empty()

	GameState.new_game(DB.species["charmander"])
	StyleOverlay.active = "campo"
	await _start("pruebas_pueblo", Vector2i(20, 17))
	var town: Node2D = world.streamer.loaded.get("pruebas_pueblo")
	var ov: StyleOverlay = town.get_node_or_null("StyleOverlay") if town != null else null
	r["La zona de pruebas se dibuja con el paquete"] = ov != null and town.get_node_or_null("StyleGround") != null
	var houses := 0
	var trees := 0
	var fences := 0
	for s in (ov._sprites if ov != null else []):
		if s is Sprite2D:
			var p: String = s.texture.resource_path.get_file()
			houses += 1 if p in ["casa.png", "tienda.png"] else 0
			trees += 1 if p.begins_with("arbol") else 0
			fences += 1 if p == "cerca.png" else 0
	r["4 casas, árboles (%d) y cercas (%d) como sprites" % [trees, fences]] = houses == 4 and trees >= 4 and fences >= 2
	r["Los tiles de FireRed quedan escondidos"] = not town.get_node("Ground").visible and not town.get_node("Overhead").visible
	# La colisión es la de siempre: una pared de casa sigue siendo sólida aunque no se vea su tile.
	var wall := Vector2i(9, 9)  # casa de arriba a la izquierda (sello 5×5 en (7,7))
	var q := PhysicsPointQueryParameters2D.new()
	q.position = town.to_global((Vector2(wall) + Vector2(0.5, 0.5)) * Zone.TILE)
	q.collision_mask = 1
	r["Las paredes de las casas siguen chocando"] = not town.get_world_2d().direct_space_state.intersect_point(q).is_empty()

	var gm := GmCommands.new(world)
	gm.run("estilo fire")
	await get_tree().process_frame
	r["«estilo fire» vuelve a los tiles de siempre"] = town.get_node_or_null("StyleOverlay") == null \
		and town.get_node("Ground").visible and town.get_node_or_null("StyleGround") == null
	gm.run("estilo siniestro")
	await get_tree().process_frame
	r["«estilo siniestro» lo cambia en el momento"] = town.get_node_or_null("StyleOverlay") != null \
		and StyleOverlay.active == "siniestro"
	r["Un estilo que no existe no rompe nada"] = "No conozco" in gm.run("estilo marciano") and StyleOverlay.active == "siniestro"

	# Pasto alto: el frente de la mata que tapa las piernas es la del paquete, no el tile de FireRed.
	await _start("pruebas_bosque", Vector2i(16, 13))
	var grass: Sprite2D = world.trainer.get_node_or_null("GrassOverlay")
	for i in 4:
		await get_tree().physics_frame
	r["En el pasto alto, la mata de encima es la del paquete (%s)" % (grass.texture.resource_path.get_file() if grass and grass.texture else "-")] = 		grass != null and grass.visible and grass.texture == StyleOverlay.texture("pasto_alto")
	StyleOverlay.active = ""
	StyleOverlay.refresh(world)
	for i in 4:
		await get_tree().physics_frame
	r["Sin paquete vuelve la de FireRed"] = grass != null and grass.texture.resource_path.ends_with("general_below.png")
	StyleOverlay.active = "siniestro"
	await _start("ruta1", Vector2i(48, 35))
	r["Fuera de la zona de pruebas, nada cambia"] = world.streamer.loaded.values().all(
		func(z): return z.get_node_or_null("StyleOverlay") == null)
	StyleOverlay.active = ""

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[style] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-style] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	GameState.new_game(DB.species["charmander"])
	GameState.set_setting("time_lock", 11.0)
	for pack in StyleOverlay.PACKS:
		StyleOverlay.active = pack
		for spot in SPOTS:
			await _start(spot[0], spot[1])
			world.get_node("UI").visible = false
			var first := Engine.get_frames_drawn()
			for i in FRAMES:
				await get_tree().process_frame
			print("[showcase-style] %s %s: cuadros %d-%d" % [pack, spot[0], first, Engine.get_frames_drawn()])
	StyleOverlay.active = ""
	get_tree().quit()


func _start(zone_id: String, cell: Vector2i) -> void:
	var wd: WorldData = DB.config.world
	for z in wd.zones:
		if z.id == zone_id:
			GameState.trainer_position = Vector2((z.origin + cell) * wd.tile_size) + Vector2.ONE * wd.tile_size / 2.0
	GameState.wilds_enabled = false
	GameState.set_flag("tutorial_visto")
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	await get_tree().create_timer(0.5).timeout
