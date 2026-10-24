class_name LedgeTests
extends Node
## Autotest de los salientes (godot --headless --path . --quit-after 6000 -- --autotest-ledges): en la Ruta 1, desde
## arriba se saltan hacia abajo (y el Pokémon salta detrás); desde abajo no se suben.

var autotest: Node


func run() -> void:
	var r := {}
	GameState.new_game(DB.config.starters[0])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	for i in 3:
		await get_tree().process_frame
	var world: Node = get_tree().current_scene
	var entry: ZoneEntry
	for z in world.streamer.world_data.zones:
		if z.id == "ruta1":
			entry = z
	var center := entry.world_rect(world.streamer.world_data.tile_size).get_center()
	world.trainer.global_position = center
	world.camera.snap()
	world.streamer.load_around_now(center)
	await get_tree().physics_frame
	var zone: Zone = world.streamer.zone_node("ruta1")
	var ledge := _find_ledge(zone)
	r["La Ruta 1 tiene un saliente con lugar arriba y abajo"] = ledge.x >= 0
	if ledge.x >= 0:
		var t: Trainer = world.trainer
		# Desde arriba: se salta.
		_place(world, zone, ledge + Vector2i.UP)
		t.autopilot = Vector2.DOWN
		await get_tree().create_timer(0.9).timeout
		t.autopilot = Vector2.ZERO
		var below := zone.cell_at(t.global_position)
		r["Desde arriba se salta hacia abajo"] = below.y > ledge.y
		await get_tree().create_timer(0.8).timeout
		r["El Pokémon salta detrás"] = is_instance_valid(world.companion) \
			and world.companion.global_position.distance_to(t.global_position) < 60.0 \
			and zone.cell_at(world.companion.global_position).y > ledge.y
		# Desde abajo: es una pared.
		_place(world, zone, ledge + Vector2i.DOWN)
		t.autopilot = Vector2.UP
		await get_tree().create_timer(0.9).timeout
		t.autopilot = Vector2.ZERO
		r["Desde abajo no se sube"] = zone.cell_at(t.global_position).y > ledge.y
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[salientes] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-ledges] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Un saliente hacia abajo con dos celdas libres arriba y una abajo.
func _find_ledge(zone: Zone) -> Vector2i:
	for c in zone.ground.get_used_cells():
		if LedgeJumper.direction_at(zone, c) != Vector2i.DOWN:
			continue
		if MapRules.is_walkable(zone, c + Vector2i.UP) and MapRules.is_walkable(zone, c + Vector2i.UP * 2) \
				and MapRules.is_walkable(zone, c + Vector2i.DOWN) and MapRules.is_walkable(zone, c + Vector2i(0, 2)):
			return c
	return Vector2i(-1, -1)


func _place(world: Node, zone: Zone, cell: Vector2i) -> void:
	var pos := zone.to_global(zone.ground.map_to_local(cell))
	world.trainer.global_position = pos
	world.trainer.trail.assign([pos])
	if is_instance_valid(world.companion):
		world.companion.global_position = pos - Vector2(0, 14)
