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
	r["Datos: 3 estados y 5 reglas cargadas"] = DB.env_states.size() == 3 and DB.reactions.size() == 5

	# --- El fuego no interactúa con el entorno ---
	var zone: Zone = await _go_to("ruta1")
	var grass := _find(zone, func(c): return zone.get_tags(c).has("pasto_alto"))
	var g := rs.grid_at(_center(zone, grass))
	r["El fuego no prende el pasto alto"] = _try(g, grass, fuego) == ""

	# --- Agua moja; eléctrico sobre mojado ---
	var dirt := _find(zone, func(c): return zone.get_tags(c).has("suelo") and g.state_at(c) == null 		and not zone.get_tags(c).has("solido"))
	r["Agua moja el suelo"] = _try(g, dirt, agua) == "mojado"
	r["El fuego no seca lo mojado"] = _try(g, dirt, fuego) == "mojado"
	var dummy: Creature = autotest._dummy(world, "rattata", _center(zone, dirt))
	await get_tree().create_timer(0.7).timeout
	r["Pararse en un charco ya no empapa (solo moja el golpe)"] = not dummy.statuses.has_status("empapado")
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
	dummy.queue_free()

	# --- Rework de Empapado (2026-10-23): moja al pegar, no por el camino ---
	var squirtle: Creature = autotest._dummy(world, "squirtle", world.trainer.global_position + Vector2(-140, 60))
	squirtle.team = Creature.Team.ALLY
	var target: Creature = autotest._dummy(world, "rattata", squirtle.global_position + Vector2(70, 0))
	await get_tree().physics_frame
	var wet_before := _cells_with(g, ["mojado"])
	var water_move: MoveData = DB.moves["pistola_agua"]
	var p := Projectile.new()
	world.entities.add_child(p)
	p.launch(HitInfo.from(squirtle, water_move), squirtle.global_position + Vector2(8, -8), Vector2.RIGHT)
	await get_tree().create_timer(0.6).timeout
	r["Un ataque de agua empapa al que golpea"] = target.statuses.has_status("empapado")
	var path_dry := true  # el camino (lejos del impacto, que sí moja alrededor) queda seco
	for dx in [12.0, 24.0, 36.0]:
		var st := g.state_at(g.zone.cell_at(squirtle.global_position + Vector2(dx, 0)))
		path_dry = path_dry and (st == null or st.id != "mojado")
	r["El disparo no moja el piso por el camino"] = path_dry and wet_before >= 0
	var fire_hit := HitInfo.from(squirtle, DB.moves["ascuas"])
	var hp0: float = target.instance.hp
	target.hurtbox.receive(fire_hit)
	r["Fuego contra Empapado: lo seca (¡Vapor!)"] = not target.statuses.has_status("empapado") and target.instance.hp < hp0
	r["Empapado dura 4 s y solo ralentiza un 10%"] = is_equal_approx(DB.statuses["empapado"].duration, 4.0) \
		and is_equal_approx(DB.statuses["empapado"].speed_mult, 0.9) and DB.statuses["empapado"].can_move
	squirtle.queue_free()
	target.queue_free()

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

	# --- Agua: hielo hace puente; eléctrico corre por el agua ---
	zone = await _go_to("lago")
	g = rs.grid_at(_center(zone, Vector2i(1, 1)))
	var water := _find(zone, func(c): return zone.get_tags(c).has("congelable") and _count_around(zone, c, "agua") >= 4)
	r["Hay agua en el Lago"] = water != Vector2i(-999, -999)
	r["Hielo congela el agua"] = _try(g, water, hielo) == "congelado"
	r["Puente de hielo: sin colisión de agua"] = zone.water.get_cell_source_id(water) == -1
	r["El fuego no derrite el hielo"] = _try(g, water, fuego) == "congelado"
	g.set_state(water, null)
	r["Al terminar el hielo vuelve el agua"] = zone.water.get_cell_source_id(water) >= 0
	rs.apply_element_cell(g, water, electrico)
	r["Eléctrico corre por el agua"] = _cells_with(g, ["electrificado"]) >= 5
	await get_tree().create_timer(1.6).timeout
	r["La descarga se termina"] = _cells_with(g, ["electrificado"]) == 0

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[env] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-env] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina (--write-movie ... -- --showcase-env): en el lago se congela el agua (puente) y se electrifica.
func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	rs = world.reactions
	var zone: Zone
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
	world.camera.snap()  # el streaming sigue a la cámara: si queda lejos, puede descargar la zona recién cargada
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
