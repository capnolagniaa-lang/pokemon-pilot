class_name FieldMovesTests
extends StoryH1Tests
## Autotest de las MO y objetos de campo (FieldMoves; docs/PLAN_RESTO_KANTO.md): Surf, Fuerza, Poké Flauta y Corte.
##   godot --headless --path . --quit-after 60000 -- --autotest-field
## En el modo libre (sin historia: alcanza con tener la MO).


func run() -> void:
	var r := {}
	GameState.new_game(DB.species["squirtle"])
	GameState.party[0].level = 30
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	_dialogs()
	await get_tree().create_timer(0.3).timeout
	var fm: FieldMoves = world.field_moves
	var t: Trainer = world.trainer

	# --- Surf: una orilla de Pueblo Paleta (tierra con agua justo abajo) ---
	var shore: Vector2i = await _find_shore("pueblo_paleta")
	r["Hay una orilla en Pueblo Paleta"] = shore != Vector2i(-1, -1)
	await _go("pueblo_paleta", shore)
	t.facing = Vector2.DOWN
	answer = 0
	r["Sin la MO03 no se puede surfear"] = world.story.try_interact() and not fm.surfing
	await _idle()
	GameState.add_item("mo03", 1)
	world.story.try_interact()
	await _idle()
	await get_tree().create_timer(0.5).timeout
	r["Con la MO03: navega sobre el agua"] = fm.surfing and world.tags_at(t.global_position).has("agua") \
		and not t.get_collision_mask_value(2)
	t.autopilot = Vector2.DOWN
	await get_tree().create_timer(0.4).timeout
	t.autopilot = Vector2.ZERO
	r["Puede moverse por el agua"] = fm.surfing and world.tags_at(t.global_position).has("agua")

	# --- Pelea en el agua ---
	r["Modos: Agua nada, Volador/Fantasma/levita flota, el resto montado"] = \
		FieldMoves.water_mode_of(DB.species["squirtle"]) == "nada" and FieldMoves.water_mode_of(DB.species["pidgey"]) == "flota" \
		and FieldMoves.water_mode_of(DB.species["gastly"]) == "flota" and FieldMoves.water_mode_of(DB.species["koffing"]) == "flota" \
		and FieldMoves.water_mode_of(DB.species["charmander"]) == "montado"
	var no_water := true
	for i in 40:
		var roll: Array = world.spawner.roll("pueblo_paleta", false)
		if not roll.is_empty() and roll[3] == "agua":
			no_water = false
	var tpl: EncounterTable = load(EncounterTable.zone_path("ruta19"))
	r["Salvajes de agua: en la tabla, pero salen solo navegando"] = no_water and tpl != null \
		and tpl.entries.any(func(e): return e.where == "agua")
	world.combat.start_battle()
	await get_tree().create_timer(0.2).timeout
	var c: Creature = world.companion
	r["Navegando, tu Pokémon de agua sale a pelear nadando"] = world.combat.in_battle and c.visible and c.swims \
		and fm.water_mode == "nada"
	GameState.party.append(CreatureInstance.create(DB.species["charmander"], 30))
	await get_tree().create_timer(1.6).timeout  # (recarga de los cambios)
	world.combat.switch_to(GameState.party.size() - 1)
	await get_tree().create_timer(0.3).timeout
	c = world.companion
	r["Uno que no nada pelea montado (más lento, el entrenador con él)"] = fm.water_mode == "montado" and c.swims \
		and is_equal_approx(c.swim_mult, FieldMoves.MOUNTED_SPEED) and t.global_position.distance_to(c.global_position) < 6.0 \
		and FieldMoves.mount_species().id == "squirtle"
	world.combat.end_battle()
	await get_tree().create_timer(0.2).timeout
	r["Al terminar la pelea vuelve adentro (sigue navegando)"] = fm.surfing and fm.water_mode == "" \
		and not world.companion.visible
	world.combat.switch_to(0)
	await get_tree().create_timer(0.2).timeout
	t.autopilot = Vector2.UP
	await _until(func(): return not fm.surfing, 4.0)
	t.autopilot = Vector2.ZERO
	r["Al pisar tierra se baja solo"] = not fm.surfing and t.get_collision_mask_value(2) \
		and not world.tags_at(t.global_position).has("agua")
	t.autopilot = Vector2.DOWN
	await _until(func(): return fm.surfing, 3.0)
	t.autopilot = Vector2.ZERO
	r["Caminando hacia el agua se mete solo (sin preguntar)"] = fm.surfing and not world.story.dialog.active
	t.autopilot = Vector2.UP
	await _until(func(): return not fm.surfing, 4.0)
	t.autopilot = Vector2.ZERO

	# --- Fuerza: una roca de Calle Victoria ---
	var boulder: EnvObject = await _find_boulder()
	r["Hay rocas de Fuerza en Calle Victoria / Islas Espuma"] = boulder != null
	if boulder != null:
		var pushed := false
		var before := boulder.global_position
		r["Sin Fuerza activa no se mueve"] = not await fm.push(boulder, Vector2.RIGHT)
		fm.activate_strength("prueba")
		for d in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
			if await fm.push(boulder, d):
				pushed = true
				break
		r["Con Fuerza la roca se corre una celda"] = pushed and absf(boulder.global_position.distance_to(before) - 16.0) < 0.5

	# --- Poké Flauta: el Snorlax de la Ruta 12 ---
	var snor: NpcData = DB.npcs.get("ruta12_snorlax")
	r["El Snorlax duerme en la Ruta 12"] = snor != null and snor.visible_now()
	if snor != null:
		await _go("ruta12", snor.cell + Vector2i(0, 1))
		_talk_to("ruta12_snorlax")
		await _idle()
		r["Sin la Poké Flauta no se despierta"] = not GameState.has_flag("snorlax_ruta12_despierto")
		GameState.add_item("poke_flauta", 1)
		_talk_to("ruta12_snorlax")
		await _idle()
		await get_tree().process_frame
		var wilds: Array = world.entities.get_children().filter(func(c): return c is Creature and c.instance.species.id == "snorlax")
		r["Con la Poké Flauta se despierta y pelea (salvaje Nv. 30)"] = GameState.has_flag("snorlax_ruta12_despierto") \
			and not snor.visible_now() and wilds.size() == 1 and wilds[0].instance.level == 30

	# --- Mansión Pokémon: la estatua-interruptor da vuelta las barreras de todos los pisos ---
	var ms: MansionSwitches = world.mansion_switches
	await _go("mansion_pokemon_1p", Vector2i(5, 6))
	var m1: Zone = world.streamer.zone_node("mansion_pokemon_1p")
	var closed := not MapRules.is_walkable(m1, Vector2i(23, 10)) and MapRules.is_walkable(m1, Vector2i(32, 18))
	t.facing = Vector2.UP
	world.story.try_interact()
	await get_tree().process_frame
	world.story.dialog.choose(0)
	await _idle()
	r["Mansión: la estatua aprieta el interruptor (abre unas barreras y cierra otras)"] = closed 		and GameState.has_flag(MansionSwitches.FLAG) and MapRules.is_walkable(m1, Vector2i(23, 10)) 		and not MapRules.is_walkable(m1, Vector2i(32, 18))
	await _go("mansion_pokemon_s1", Vector2i(27, 6))
	var ms1: Zone = world.streamer.zone_node("mansion_pokemon_s1")
	r["Mansión: el sótano se carga con el interruptor apretado"] = ms1 != null 		and MapRules.is_walkable(ms1, Vector2i(12, 11)) and not MapRules.is_walkable(ms1, Vector2i(34, 21))
	ms.toggle()
	r["Mansión: soltarlo deja todo como al principio"] = not GameState.has_flag(MansionSwitches.FLAG) 		and not MapRules.is_walkable(ms1, Vector2i(12, 11)) and MapRules.is_walkable(ms1, Vector2i(34, 21))

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[campo] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-field] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Una celda de tierra con agua justo abajo (para entrar al agua mirando hacia abajo).
func _find_shore(zone_id: String) -> Vector2i:
	await _go(zone_id, world.streamer.world_data.zones.filter(func(z): return z.id == zone_id)[0].hub)
	var zone: Zone = world.streamer.zone_node(zone_id)
	for c: Vector2i in zone.ground.get_used_cells():
		var below := c + Vector2i(0, 1)
		if MapRules.is_walkable(zone, c) and not zone.get_tags(c).has("agua") and zone.get_tags(below).has("agua") \
				and zone.get_tags(below + Vector2i(0, 1)).has("agua"):
			return c
	return Vector2i(-1, -1)


func _find_boulder() -> EnvObject:
	for zid in ["calle_victoria_1p", "islas_espuma", "casa_guarda"]:
		var found: Array = world.streamer.world_data.zones.filter(func(z): return z.id == zid)
		if found.is_empty():
			continue
		await _go(zid, found[0].hub)
		var zone: Zone = world.streamer.zone_node(zid)
		if zone == null:
			continue
		for o in zone.get_node("Objects").get_children():
			if o is EnvObject and o.has_tag("pesado"):
				return o
	return null
