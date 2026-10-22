class_name EnvTests
extends Node
## Autotest del entorno reactivo (Etapa 3): godot --headless --path . --quit-after 12000 -- --autotest-env
## Busca en el mapa real pasto alto, agua y rocas frágiles y prueba cada reacción.

var autotest: Node
var world: Node
var rs: ReactionSystem


func run() -> void:
	var r := {}
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	rs = world.reactions
	var fuego: ElementType = DB.types["fuego"]
	var agua: ElementType = DB.types["agua"]
	var hielo: ElementType = DB.types["hielo"]
	var electrico: ElementType = DB.types["electrico"]
	r["Datos: 5 estados y reglas cargadas"] = DB.env_states.size() == 5 and DB.reactions.size() >= 8

	# --- Fuego en el pasto alto: prende, se contagia y queda quemado ---
	var zone: Zone = await _go_to("ruta1")
	var grass := _find(zone, func(c): return zone.get_tags(c).has("pasto_alto") and _count_around(zone, c, "pasto_alto") >= 3)
	var g := rs.grid_at(_center(zone, grass))
	rs.apply_element(fuego, _center(zone, grass), 2.0)
	r["Fuego prende el pasto alto"] = g.state_at(grass) != null and g.state_at(grass).id == "ardiendo"
	await get_tree().create_timer(3.5).timeout
	r["El fuego se contagia a las vecinas"] = _cells_with(g, ["ardiendo", "quemado"]) >= 3
	await get_tree().create_timer(6.0).timeout
	r["Se apaga solo y queda quemado (ya no es pasto alto)"] = g.state_at(grass) != null and g.state_at(grass).id == "quemado" \
		and not world.tags_at(_center(zone, grass)).has("pasto_alto")
	r["Lo quemado no vuelve a prender"] = _try(g, grass, fuego) == "quemado"

	# --- Agua apaga, moja; vapor; eléctrico sobre mojado ---
	var grass2 := _find(zone, func(c): return zone.get_tags(c).has("pasto_alto") and g.state_at(c) == null)
	rs.apply_element_cell(g, grass2, fuego)
	r["Agua apaga el fuego"] = _try(g, grass2, agua) == "quemado"
	var dirt := _find(zone, func(c): return zone.get_tags(c).has("suelo") and not zone.get_tags(c).has("inflamable") and g.state_at(c) == null \
		and not zone.get_tags(c).has("solido"))
	r["Agua moja el suelo"] = _try(g, dirt, agua) == "mojado"
	var dummy: Creature = autotest._dummy(world, "rattata", _center(zone, dirt))
	await get_tree().create_timer(0.7).timeout
	r["Criatura sobre lo mojado: Empapada"] = dummy.statuses.has_status("empapado")
	r["Eléctrico sobre lo mojado: electrifica"] = _try(g, dirt, electrico) == "electrificado"
	var stunned := false
	for k in 12:
		await get_tree().physics_frame
		stunned = stunned or dummy.statuses.meter("paralizado") > 0.0 or dummy.machine.current_name() == "stunned"
	await get_tree().create_timer(0.6).timeout
	stunned = stunned or dummy.statuses.meter("paralizado") > 0.0 or dummy.machine.current_name() == "stunned"
	r["Criatura sobre lo electrificado: se paraliza"] = stunned
	await get_tree().create_timer(1.0).timeout
	r["Después vuelve a estar mojado"] = g.state_at(dirt) != null and g.state_at(dirt).id == "mojado"
	r["Fuego sobre lo mojado: vapor (se seca)"] = _try(g, dirt, fuego) == ""
	dummy.global_position = _center(zone, grass2 + Vector2i(40, 40))
	var grass3 := _find(zone, func(c): return zone.get_tags(c).has("pasto_alto") and g.state_at(c) == null)
	dummy.global_position = _center(zone, grass3)
	dummy.statuses.clear()
	rs.apply_element_cell(g, grass3, fuego)
	await get_tree().create_timer(0.7).timeout
	r["Criatura sobre el fuego: se quema"] = dummy.statuses.has_status("quemado")
	dummy.queue_free()

	# --- Objetos: roca frágil y árbol cortable ---
	var rocks: Array = get_tree().get_nodes_in_group("env_objects").filter(func(o): return o.has_tag("fragil"))
	r["Ruta 1 tiene rocas frágiles"] = rocks.size() >= 1
	if not rocks.is_empty():
		var rock: EnvObject = rocks[0]
		Events.env_object_struck.emit(rock, 10.0)
		await get_tree().physics_frame
		var survives := is_instance_valid(rock) and rock.collision_layer != 0
		# Embestida real de Charmander (Embestida Ígnea) contra la roca.
		var me: Creature = world.companion
		world.combat.start_battle()
		# La roca está rodeada de rocas pesadas: se acerca por el lado libre.
		var others: Array = get_tree().get_nodes_in_group("env_objects").filter(func(o): return o != rock)
		var dir := Vector2.RIGHT
		for d in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
			var spot: Vector2 = rock.global_position - d * 16.0
			if not others.any(func(o): return o.global_position.distance_to(spot) < 12.0) \
					and not world.tags_at(spot).has("solido"):
				dir = d
				break
		me.global_position = rock.global_position - dir * 26.0 + Vector2(0, -2)
		await get_tree().physics_frame
		me.use_slot(3, dir)
		await get_tree().create_timer(0.5).timeout
		r["Roca frágil: aguanta un golpe débil y se rompe con una embestida"] = survives and not is_instance_valid(rock)
		world.combat.end_battle()
	var tree := EnvObject.new()
	tree.tags = PackedStringArray(["solido", "inflamable", "cortable"])
	var spr := Sprite2D.new()
	spr.name = "Sprite"
	tree.add_child(spr)
	world.entities.add_child(tree)
	tree.global_position = world.trainer.global_position + Vector2(60, 0)
	rs.apply_element(fuego, tree.global_position, 6.0)
	await get_tree().create_timer(3.0).timeout
	r["Árbol cortable: el fuego lo quema"] = not is_instance_valid(tree)

	# --- Agua: hielo hace puente; eléctrico corre por el agua; fuego derrite ---
	zone = await _go_to("lago")
	g = rs.grid_at(_center(zone, Vector2i(1, 1)))
	var water := _find(zone, func(c): return zone.get_tags(c).has("congelable") and _count_around(zone, c, "agua") >= 4)
	r["Hay agua en el Lago"] = water != Vector2i(-999, -999)
	r["Hielo congela el agua"] = _try(g, water, hielo) == "congelado"
	r["Puente de hielo: sin colisión de agua"] = zone.water.get_cell_source_id(water) == -1
	r["Fuego derrite el hielo y vuelve el agua"] = _try(g, water, fuego) == "" and zone.water.get_cell_source_id(water) >= 0
	rs.apply_element_cell(g, water, electrico)
	r["Eléctrico corre por el agua"] = _cells_with(g, ["electrificado"]) >= 5
	await get_tree().create_timer(1.6).timeout
	r["La descarga se termina"] = _cells_with(g, ["electrificado"]) == 0

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[env] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-env] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina (--write-movie ... -- --showcase-env): Charmander prende el pasto alto con Ascuas, después en el
## lago se congela el agua y se electrifica.
func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	rs = world.reactions
	var zone: Zone = await _go_to("ruta1")
	# El borde izquierdo de la mancha de pasto alto más cercana al centro de la zona.
	var mid := zone.cell_at(world.trainer.global_position)
	var best := Vector2i(-999, -999)
	for c in zone.ground.get_used_cells():
		if zone.get_tags(c).has("pasto_alto") and not zone.get_tags(c + Vector2i.LEFT).has("pasto_alto") \
				and _count_around(zone, c, "pasto_alto") >= 3 and (best.x == -999 or Vector2(c - mid).length() < Vector2(best - mid).length()):
			best = c
	var me: Creature = world.companion
	me.global_position = _center(zone, best) + Vector2(-40, 0)
	world.trainer.global_position = me.global_position + Vector2(-24, 6)
	world.camera.target = me
	world.camera.snap()
	await get_tree().create_timer(0.4).timeout
	me.use_slot(0, Vector2.RIGHT)
	await get_tree().create_timer(5.0).timeout
	world.combat.end_battle()
	zone = await _go_to("lago")
	var water := _find(zone, func(c): return zone.get_tags(c).has("congelable") and _count_around(zone, c, "agua") >= 4)
	world.trainer.global_position = _center(zone, water) + Vector2(0, 40)
	world.camera.snap()
	await get_tree().create_timer(0.5).timeout
	for k in 5:
		rs.apply_element(DB.types["hielo"], _center(zone, water + Vector2i(k - 2, 0)), 8.0)
		await get_tree().create_timer(0.15).timeout
	await get_tree().create_timer(1.2).timeout
	rs.apply_element(DB.types["electrico"], _center(zone, water + Vector2i(6, 1)), 4.0)
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()


## Lleva al entrenador al centro de una zona y la carga.
func _go_to(id: String) -> Zone:
	var entry: ZoneEntry = null
	for z in world.streamer.world_data.zones:
		if z.id == id:
			entry = z
	var rect: Rect2 = entry.world_rect(world.streamer.world_data.tile_size)
	world.trainer.global_position = rect.get_center()
	world.streamer.load_around_now(rect.get_center())
	await get_tree().physics_frame
	return world.streamer.zone_node(id)


func _center(zone: Zone, cell: Vector2i) -> Vector2:
	return zone.to_global(zone.ground.map_to_local(cell))


func _find(zone: Zone, pred: Callable) -> Vector2i:
	var cells: Array[Vector2i] = zone.ground.get_used_cells()
	cells.append_array(zone.water.get_used_cells())
	for c in cells:
		if pred.call(c):
			return c
	return Vector2i(-999, -999)


func _count_around(zone: Zone, cell: Vector2i, tag: String) -> int:
	var n := 0
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if zone.get_tags(cell + d).has(tag):
			n += 1
	return n


func _cells_with(g: EnvironmentGrid, ids: Array) -> int:
	var n := 0
	for c in g.cells:
		if ids.has(g.cells[c]["state"].id):
			n += 1
	return n


## Aplica un elemento a una celda y devuelve el id del estado que quedó ("" = ninguno).
func _try(g: EnvironmentGrid, cell: Vector2i, el: ElementType) -> String:
	rs.apply_element_cell(g, cell, el)
	var st := g.state_at(cell)
	return st.id if st != null else ""
