class_name RepaintTests
extends Node
## Skins del mundo: zonas repintadas con IA y su luz horneada por momento del día (PaintedZone, tools/repaint_zone.py):
##   godot --headless --path . --quit-after 60000 -- --autotest-repaint
## Vitrina (Pueblo Paleta con la skin HD en varios lugares y horas; imprime qué cuadros son cada uno):
##   godot --path . --quit-after 400 --write-movie out/f.png --fixed-fps 30 -- --showcase-repaint
## (`--skin pixel` = con otra skin; `--zone ruta1 --cells 20,30;20,60 --hours 12,23` = otros lugares y horas.)

const ZONE := "pueblo_paleta"
const SPOTS := [[Vector2i(56, 12), 12.0], [Vector2i(52, 28), 12.0], [Vector2i(56, 12), 7.0], [Vector2i(56, 12), 18.5],
	[Vector2i(56, 12), 23.0]]
const FRAMES := 24

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	r["Hay skins: clásica primero y HD (%s)" % str(PaintedZone.skins())] = PaintedZone.skins().size() >= 2 \
		and PaintedZone.skins()[0][0] == PaintedZone.CLASSIC
	r["Pueblo Paleta tiene su imagen en la skin HD"] = PaintedZone.available(ZONE, "hd")
	var noon := PaintedZone.moment_weights(12.0)
	var dusk := PaintedZone.moment_weights(18.7)
	var night := PaintedZone.moment_weights(23.0)
	var dawn := PaintedZone.moment_weights(6.3)
	r["Las pinturas se funden por hora: día, atardecer, noche y amanecer (%s %s %s %s)" % [noon, dusk, night, dawn]] = 		noon == Vector2.ZERO and dusk.x > 0.9 and dusk.y < 0.1 and night.y == 1.0 and dawn.x == 1.0 and dawn.y < 0.1 		and PaintedZone.moment_weights(18.7, false).x == 0.0
	GameState.new_game(DB.species["charmander"])
	r["Skin pixel: Pueblo Paleta, Ruta 1 y Ciudad Verde, de día y de noche"] = ["pueblo_paleta", "ruta1", "ciudad_verde"].all(
		func(z): return PaintedZone.available(z, "pixel") and ResourceLoader.exists(PaintedZone.ROOT + "pixel/" + z + "@noche.png"))
	r["Las ventanas se prenden antes de la noche y se apagan al amanecer"] = PaintedZone.lights_weight(12.0) == 0.0 		and PaintedZone.lights_weight(18.7) > 0.5 and PaintedZone.lights_weight(23.0) == 1.0 and PaintedZone.lights_weight(7.0) == 0.0
	r["Una partida nueva arranca con la skin pixel (la elegida)"] = PaintedZone.current() == "pixel"
	await _start(Vector2i(56, 12))
	var town: Node2D = world.streamer.loaded.get(ZONE)
	var pz: PaintedZone = town.get_node_or_null("PaintedZone") if town != null else null
	r["Se dibuja la imagen en lugar de los tiles"] = pz != null and PaintedZone.covers(town) \
		and pz.find_child("PaintedGround", true, false) != null \
		and not town.get_node("Ground").visible and not town.get_node("Overhead").visible
	var top: Sprite2D = pz.find_child("PaintedOverhead", true, false) if pz != null else null
	var water: Sprite2D = pz.find_child("PaintedWater", true, false) if pz != null else null
	r["Techos y copas con el z de su capa (tapan al pasar por detrás)"] = top != null 		and top.z_index == town.get_node("Overhead").z_index
	r["El agua va aparte, con ondas (el estanque)"] = water != null 		and (water.material as ShaderMaterial).get_shader_parameter("water") == true
	await get_tree().process_frame
	r["Con skin, sin sombras del mapa ni faroles calculados"] = not town.get_node("SunShadows").visible \
		and (town.get_node_or_null("StreetLamps") == null or not town.get_node("StreetLamps").visible)
	# La colisión es la de siempre: la pared de una casa sigue siendo sólida aunque no se vea su tile.
	var q := PhysicsPointQueryParameters2D.new()
	q.position = town.to_global((Vector2(45, 6) + Vector2(0.5, 0.5)) * Zone.TILE)  # casa de arriba a la izquierda (sello en 43,3)
	q.collision_mask = 1
	r["Las paredes siguen chocando"] = not town.get_world_2d().direct_space_state.intersect_point(q).is_empty()
	GameState.set_setting("skin", PaintedZone.CLASSIC)
	await get_tree().process_frame
	await get_tree().process_frame
	r["Con la skin clásica vuelven los tiles de FireRed (y sus sombras)"] = town.get_node("Ground").visible \
		and not PaintedZone.covers(town) and town.get_node("SunShadows").visible
	GameState.set_setting("skin", "hd")
	await get_tree().process_frame
	await get_tree().process_frame
	r["Y con la HD vuelve la imagen"] = not town.get_node("Ground").visible and PaintedZone.covers(town)
	r["Una zona sin imagen queda con sus tiles"] = world.streamer.loaded.values().all(
		func(z): return PaintedZone.available(z.zone_id) or not PaintedZone.covers(z))
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[repaint] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-repaint] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	GameState.new_game(DB.species["charmander"])
	var spots := SPOTS.duplicate()
	var zone := _arg("--zone", ZONE)
	if _arg("--cells", "") != "":
		spots.clear()
		for h in _arg("--hours", "12").split(","):
			for c in _arg("--cells", "").split(";"):
				var xy := c.split(",")
				spots.append([Vector2i(int(xy[0]), int(xy[1])), float(h)])
	if _arg("--skin", "") != "":
		GameState.set_setting("skin", _arg("--skin", ""))
	for spot in spots:
		GameState.set_setting("time_lock", spot[1])
		await _start(spot[0], zone)
		world.get_node("UI").visible = false
		var first := Engine.get_frames_drawn()
		for i in FRAMES:
			await get_tree().process_frame
		print("[showcase-repaint] %s %.1f h: cuadros %d-%d" % [spot[0], spot[1], first, Engine.get_frames_drawn()])
	get_tree().quit()


func _arg(name: String, fallback: String) -> String:
	var args := OS.get_cmdline_user_args()
	var i := args.find(name)
	return args[i + 1] if i >= 0 and i + 1 < args.size() else fallback


func _start(cell: Vector2i, zone := ZONE) -> void:
	var wd: WorldData = DB.config.world
	for z in wd.zones:
		if z.id == zone:
			GameState.trainer_position = Vector2((z.origin + cell) * wd.tile_size) + Vector2.ONE * wd.tile_size / 2.0
	GameState.wilds_enabled = false
	GameState.set_flag("tutorial_visto")
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	await get_tree().create_timer(0.5).timeout
