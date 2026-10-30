class_name RepaintTests
extends Node
## Skins del mundo: zonas repintadas con IA (PaintedZone, tools/repaint_zone.py):
##   godot --headless --path . --quit-after 60000 -- --autotest-repaint
## Vitrina (Pueblo Paleta con la skin HD en varios lugares y horas; imprime qué cuadros son cada uno):
##   godot --path . --quit-after 400 --write-movie out/f.png --fixed-fps 30 -- --showcase-repaint

const ZONE := "pueblo_paleta"
const SPOTS := [[Vector2i(56, 12), 12.0], [Vector2i(66, 16), 12.0], [Vector2i(56, 12), 8.0], [Vector2i(56, 12), 18.5],
	[Vector2i(56, 12), 23.0]]
const FRAMES := 24

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	r["Hay skins: clásica primero y HD (%s)" % str(PaintedZone.skins())] = PaintedZone.skins().size() >= 2 \
		and PaintedZone.skins()[0][0] == PaintedZone.CLASSIC
	r["Pueblo Paleta tiene su imagen en la skin HD"] = PaintedZone.available(ZONE, "hd")
	GameState.new_game(DB.species["charmander"])
	r["Una partida nueva arranca con la skin HD"] = PaintedZone.current() == "hd"
	await _start(Vector2i(56, 12))
	var town: Node2D = world.streamer.loaded.get(ZONE)
	var pz: PaintedZone = town.get_node_or_null("PaintedZone") if town != null else null
	r["Se dibuja la imagen en lugar de los tiles"] = pz != null and pz.get_node_or_null("PaintedGround") != null \
		and not town.get_node("Ground").visible and not town.get_node("Overhead").visible
	r["Techos y copas recortados en su capa (tapan al pasar por detrás)"] = pz != null \
		and pz.get_node_or_null("PaintedOverhead") != null \
		and pz.get_node("PaintedOverhead").z_index == town.get_node("Overhead").z_index
	# La colisión es la de siempre: la pared de una casa sigue siendo sólida aunque no se vea su tile.
	var q := PhysicsPointQueryParameters2D.new()
	q.position = town.to_global((Vector2(45, 6) + Vector2(0.5, 0.5)) * Zone.TILE)  # casa de arriba a la izquierda (sello en 43,3)
	q.collision_mask = 1
	r["Las paredes siguen chocando"] = not town.get_world_2d().direct_space_state.intersect_point(q).is_empty()
	GameState.set_setting("skin", PaintedZone.CLASSIC)
	await get_tree().process_frame
	await get_tree().process_frame
	r["Con la skin clásica vuelven los tiles de FireRed"] = town.get_node("Ground").visible \
		and pz.get_node_or_null("PaintedGround") == null
	GameState.set_setting("skin", "hd")
	await get_tree().process_frame
	await get_tree().process_frame
	r["Y con la HD vuelve la imagen"] = not town.get_node("Ground").visible and pz.get_node_or_null("PaintedGround") != null
	r["Una zona sin imagen queda con sus tiles"] = world.streamer.loaded.values().all(
		func(z): return PaintedZone.available(z.zone_id) or z.get_node("PaintedZone").get_node_or_null("PaintedGround") == null)
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[repaint] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-repaint] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	GameState.new_game(DB.species["charmander"])
	for spot in SPOTS:
		GameState.set_setting("time_lock", spot[1])
		await _start(spot[0])
		world.get_node("UI").visible = false
		var first := Engine.get_frames_drawn()
		for i in FRAMES:
			await get_tree().process_frame
		print("[showcase-repaint] %s %.1f h: cuadros %d-%d" % [spot[0], spot[1], first, Engine.get_frames_drawn()])
	get_tree().quit()


func _start(cell: Vector2i) -> void:
	var wd: WorldData = DB.config.world
	for z in wd.zones:
		if z.id == ZONE:
			GameState.trainer_position = Vector2((z.origin + cell) * wd.tile_size) + Vector2.ONE * wd.tile_size / 2.0
	GameState.wilds_enabled = false
	GameState.set_flag("tutorial_visto")
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	await get_tree().create_timer(0.5).timeout
