class_name CaptureTests
extends Node
## Autotests de captura, Caja y mochila (docs/PLAN_CAPTURA_MOCHILA.md):
##   godot --headless --path . --quit-after 30000 -- --autotest-capture
##   godot --headless --path . --quit-after 30000 -- --autotest-bag

var autotest: Node
var world: Node


func _finish(name: String, r: Dictionary) -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[%s] %s %s" % [name, "OK   " if r[key] else "FALLO", key])
	print("[autotest-%s] -> %s" % [name, "OK" if ok else "FALLO"])
	get_tree().quit(0 if ok else 1)


func _setup() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await get_tree().physics_frame


func _wild(species_id: String, level: int, offset: Vector2) -> Creature:
	var c: Creature = autotest._dummy(world, species_id, world.trainer.global_position + offset)
	c.instance.level = level
	c.instance.hp = c.instance.max_hp()
	return c


# --- Captura ---------------------------------------------------------------------------------

func run_capture() -> void:
	var r := {}
	await _setup()
	var rat := CreatureInstance.create(DB.species["rattata"], 10)
	var full := Capture.chance(rat, 1.0)
	rat.hp = 1.0
	var low := Capture.chance(rat, 1.0)
	r["Fórmula: con poca vida es más fácil"] = low > full and full > 0.0
	r["Fórmula: dormido > sin estado; Ultra Ball > Poké Ball"] = Capture.chance(rat, 1.0, ["dormido"]) >= low \
		and Capture.chance(CreatureInstance.create(DB.species["snorlax"], 30), 2.0) > Capture.chance(CreatureInstance.create(DB.species["snorlax"], 30), 1.0)
	r["Fórmula: Master Ball siempre"] = Capture.roll(CreatureInstance.create(DB.species["mewtwo"], 70), 255.0) == Capture.SHAKES_TO_CATCH
	var spawned := []
	for i in 6:
		spawned.append(world.spawner.spawn(DB.species["pidgey"], 5, world.trainer.global_position + Vector2(-300 - i * 20, -200)))
	var all_perfect := spawned.all(func(c): return c.instance.ivs.values().all(func(v): return v == 31))
	r["Los salvajes aparecen con IVs al azar"] = not all_perfect
	for c in spawned:
		c.queue_free()

	# Errar: la bola se gasta y no pasa nada.
	var balls_before := GameState.item_count("poke_ball")
	var threw := world.items.throw_ball(world.trainer.global_position + Vector2(0, 80)) != null
	await get_tree().create_timer(0.9).timeout
	r["Errar: la bola se gasta"] = threw and GameState.item_count("poke_ball") == balls_before - 1

	# Atrapar con Master Ball → al equipo y a la Pokédex.
	GameState.add_item("master_ball", 2)
	GameState.selected_ball = "master_ball"
	var target := _wild("pidgey", 6, Vector2(70, 0))
	world.items._cooldown = 0.0
	var party_before := GameState.party.size()
	var caught_signal := []
	Events.pokemon_caught.connect(func(inst, where): caught_signal.append(where))
	var b: BallThrow = world.items.throw_ball(target.global_position)
	await get_tree().create_timer(0.35).timeout
	r["La bola mete al salvaje adentro (invisible, sin golpes)"] = is_instance_valid(target) and not target.visible
	await get_tree().create_timer(2.6).timeout
	r["Master Ball: atrapado, al equipo y a la Pokédex"] = b.result == "caught" and GameState.party.size() == party_before + 1 \
		and GameState.has_caught(DB.species["pidgey"]) and caught_signal == ["equipo"] and not is_instance_valid(target)

	# Escaparse: Poké Ball contra un legendario con toda la vida.
	GameState.selected_ball = "poke_ball"
	var mew := _wild("mewtwo", 70, Vector2(-70, 0))
	world.items._cooldown = 0.0
	var outcome := []
	var b2: BallThrow = world.items.throw_ball(mew.global_position)
	if b2 != null:
		b2.finished.connect(func(res): outcome.append(res))
	await get_tree().create_timer(2.8).timeout
	r["Se escapa: vuelve a estar afuera y activo"] = outcome == ["escaped"] \
		and is_instance_valid(mew) and mew.visible and mew.process_mode == Node.PROCESS_MODE_INHERIT
	mew.queue_free()

	# Equipo lleno → Caja.
	while GameState.party.size() < GameState.MAX_PARTY:
		GameState.add_to_party(CreatureInstance.create(DB.species["rattata"], 5))
	GameState.selected_ball = "master_ball"
	var extra := _wild("vulpix", 6, Vector2(0, 70))
	world.items._cooldown = 0.0
	world.items.throw_ball(extra.global_position)
	await get_tree().create_timer(3.0).timeout
	r["Con el equipo lleno, va a la Caja"] = GameState.box.size() == 1 and GameState.box[0].species.id == "vulpix" \
		and caught_signal.back() == "caja"
	r["Caja: no entra al equipo si está lleno"] = not GameState.box_to_party(0)
	r["Caja: dejar uno del equipo y traer el de la Caja"] = GameState.party_to_box(5) and GameState.box_to_party(0) \
		and GameState.party.any(func(i): return i.species.id == "vulpix")
	while GameState.party.size() > 1:
		GameState.party_to_box(GameState.party.size() - 1)
	r["Caja: el último del equipo no se puede dejar"] = not GameState.party_to_box(0) and GameState.party.size() == 1
	var d := GameState.to_dict()
	var box_n := GameState.box.size()
	GameState.new_game(DB.species["squirtle"])
	GameState.from_dict(d)
	r["La Caja y los atrapados se guardan"] = GameState.box.size() == box_n and GameState.has_caught(DB.species["pidgey"])
	world.pause_menu.try_open()
	world.pause_menu._open_box()
	await get_tree().process_frame
	r["Pantalla de la Caja"] = world.pause_menu._stack[-1]._grid.get_child_count() >= box_n
	world.pause_menu.close()
	_finish("capture", r)


# --- Mochila --------------------------------------------------------------------------------

func run_bag() -> void:
	var r := {}
	await _setup()
	r["Mochila inicial (10 Poké Ball, 3 Pociones...)"] = GameState.item_count("poke_ball") == 10 and GameState.item_count("pocion") == 3
	r["15 objetos oficiales con nombre, descripción e ícono"] = DB.items.size() >= 15 and DB.items.values().all(
		func(it): return it.display_name != "" and it.description != "" and it.icon != null)
	var me: Creature = world.companion
	var inst := me.instance
	inst.hp = inst.max_hp() * 0.3
	var hp0 := inst.hp
	var text := GameState.use_item_on("pocion", inst, me.statuses)
	r["Poción: cura 20 PS ×3 y se gasta"] = text != "" and is_equal_approx(inst.hp, minf(inst.max_hp(), hp0 + 60.0)) and GameState.item_count("pocion") == 2
	inst.hp = inst.max_hp()
	r["Con la vida llena no se gasta"] = GameState.use_item_on("pocion", inst, me.statuses) == "" and GameState.item_count("pocion") == 2
	me.statuses.apply(DB.statuses["envenenado"])
	me.statuses.apply(DB.statuses["arraigado"])
	GameState.add_item("cura_total")
	r["Antídoto cura el veneno"] = GameState.use_item_on("antidoto", inst, me.statuses) != "" and not me.statuses.has_status("envenenado")
	me.statuses.apply(DB.statuses["quemado"])
	GameState.use_item_on("cura_total", inst, me.statuses)
	r["Cura Total sana problemas, no mejoras propias"] = not me.statuses.has_status("quemado") and me.statuses.has_status("arraigado")
	var fainted := CreatureInstance.create(DB.species["pidgey"], 5)
	fainted.hp = 0.0
	GameState.add_to_party(fainted)
	GameState.add_item("revivir")
	r["Revivir: vuelve con la mitad de la vida"] = GameState.use_item_on("revivir", fainted) != "" and is_equal_approx(fainted.hp, fainted.max_hp() * 0.5)

	# Ranura rápida en combate: te deja expuesto.
	world.combat.start_battle()
	await get_tree().physics_frame
	inst.hp = inst.max_hp() * 0.5
	GameState.quick_item = "pocion"
	var used: bool = world.items.use_quick_item()
	r["C en combate: usa el objeto y te deja expuesto"] = used and me.machine.current_name() == "recovery" and GameState.item_count("pocion") == 1
	world.combat.end_battle()

	# Bola elegida y la que se lanza si no quedan.
	GameState.bag.erase("poke_ball")
	GameState.add_item("super_ball", 2)
	GameState.selected_ball = "poke_ball"
	r["Sin la bola elegida, lanza la que haya"] = world.items.ball_to_throw() != null and world.items.ball_to_throw().id == "super_ball"
	var old := {"party": [inst.to_dict()], "balls": 7}
	GameState.from_dict(old)
	r["Partidas viejas: sus Poké Balls pasan a la mochila"] = GameState.item_count("poke_ball") == 7

	# Objetos del mapa.
	await get_tree().create_timer(0.3).timeout
	var on_map: Array = get_tree().get_nodes_in_group("field_items")
	r["Hay objetos tirados en el mapa (3 por zona)"] = on_map.size() >= 3
	var f: FieldItem = on_map[0]
	var key := f.key
	var it_id := f.item.id
	var n0 := GameState.item_count(it_id)
	world.trainer.global_position = f.global_position
	await get_tree().create_timer(0.3).timeout
	r["Pasar por encima lo recoge"] = GameState.item_count(it_id) == n0 + 1 and GameState.field_picked.has(key)
	var spawner: FieldItemSpawner = world.get_node("FieldItemSpawner")
	var zone_id := key.split(":")[0]
	spawner._populate(spawner._entry(zone_id), world.streamer.zone_node(zone_id))
	await get_tree().process_frame
	r["No vuelve enseguida"] = not spawner._exists(key)
	world.trainer.global_position += Vector2(0, -60)  # que no lo recoja apenas reaparece
	await get_tree().physics_frame
	GameState.play_time += FieldItemSpawner.RESPAWN_TIME + 1.0
	spawner._populate(spawner._entry(zone_id), world.streamer.zone_node(zone_id))
	await get_tree().process_frame
	r["Vuelve a aparecer después de un rato"] = spawner._exists(key)

	# Botín de un salvaje.
	spawner.drop_table = spawner.drop_table.duplicate()
	spawner.drop_table.drop_chance = 1.0
	var wild := _wild("rattata", 3, Vector2(120, 0))
	var at: Vector2 = wild.global_position
	wild.health.apply_damage(99999.0)
	await get_tree().create_timer(0.2).timeout
	r["Los salvajes a veces sueltan un objeto"] = get_tree().get_nodes_in_group("field_items").any(
		func(f): return f.key == "" and f.lifetime > 0.0 and f.global_position.distance_to(at) < 2.0)

	world.pause_menu.try_open()
	world.pause_menu._open_bag()
	await get_tree().process_frame
	var bag: Control = world.pause_menu._stack[-1]
	r["Pantalla de la Mochila (bolsillos)"] = bag._rows.size() >= 1
	bag._show_pocket(1)
	await get_tree().process_frame
	r["Bolsillo Pokéballs"] = bag._rows.size() >= 1 and bag._selected != null and bag._selected.is_ball()
	world.pause_menu.close()
	_finish("bag", r)


## Vitrina (--write-movie ... -- --showcase-capture): lanzar una bola, la mochila y la Caja.
func showcase() -> void:
	await _setup()
	GameState.add_item("ultra_ball", 3)
	GameState.add_item("superpocion", 2)
	var wild := _wild("pidgey", 4, Vector2(80, 0))
	wild.instance.hp = 1.0
	await get_tree().create_timer(0.5).timeout
	GameState.selected_ball = "ultra_ball"
	world.items.throw_ball(wild.global_position)
	await get_tree().create_timer(3.2).timeout
	world.pause_menu.try_open()
	world.pause_menu._open_bag()
	await get_tree().create_timer(1.2).timeout
	world.pause_menu._stack[-1]._show_pocket(1)
	await get_tree().create_timer(1.0).timeout
	world.pause_menu.close()
	world.pause_menu.try_open()
	world.pause_menu._open_box()
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
