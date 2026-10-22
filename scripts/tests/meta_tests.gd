class_name MetaTests
extends Node
## Autotests de la Etapa 2c (título, guardado, equipo y movimientos). Los lanza Autotest:
##   godot --headless --path . --quit-after 9000 -- --autotest-save
##   godot --headless --path . --quit-after 9000 -- --autotest-party
## Usan un slot de prueba (user://saves/autotest.json) para no pisar la partida real.

const TEST_SLOT := "user://saves/autotest.json"

var autotest: Node


func _results(name: String, r: Dictionary) -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[%s] %s %s" % [name, "OK   " if r[key] else "FALLO", key])
	print("[autotest-%s] -> %s" % [name, "OK" if ok else "FALLO"])
	SaveManager.slot_path = SaveManager.SLOT
	get_tree().quit(0 if ok else 1)


# --- Guardado ------------------------------------------------------------------------------

func save_test() -> void:
	var r := {}
	SaveManager.slot_path = TEST_SLOT
	SaveManager.delete_save()
	r["Sin guardado: has_save() = false y summary vacío"] = not SaveManager.has_save() and SaveManager.summary().is_empty()

	var world: Node = await autotest._setup_kit_world("charmander")  # empieza en combate
	r["No se puede guardar en combate"] = not SaveManager.save_game() and not SaveManager.has_save()
	world.combat.end_battle()
	await get_tree().physics_frame

	var me := GameState.active()
	var lanzallamas: MoveData = DB.moves["lanzallamas"]
	r["Movimiento de nivel mayor (Lanzallamas, Nv. 31) no se equipa"] = not me.can_equip(lanzallamas) and not me.equip(3, lanzallamas)
	var learned := []
	Events.move_learned.connect(func(_c, m): learned.append(m))
	var text := GameState.grant_exp(me, CreatureInstance.exp_for_level(me.species.growth_rate, 31) - me.experience)
	r["Al subir a Nv. 31 aprende Lanzallamas (mensaje + evento)"] = me.level == 31 and learned.has(lanzallamas) and "Lanzallamas" in text
	r["Con las 4 ranuras llenas no lo equipa solo"] = not me.equipped_moves.has(lanzallamas)
	r["Ahora sí se puede equipar"] = me.equip(3, lanzallamas) and me.equipped_moves[3] == lanzallamas
	r["No se repite un movimiento en dos ranuras"] = me.equip(0, lanzallamas) and me.equipped_moves.count(lanzallamas) == 1
	me.hp = me.max_hp() * 0.5
	var second := CreatureInstance.create(DB.species["bulbasaur"], 12)
	GameState.add_to_party(second)
	GameState.set_active(1)
	GameState.practice_mode = false
	GameState.set_difficulty("dificil")
	GameState.balls = 7
	await get_tree().physics_frame
	world.trainer.global_position += Vector2(48, 16)
	var saved_pos: Vector2 = world.trainer.global_position
	r["Guardar fuera de combate"] = SaveManager.save_game() and SaveManager.has_save()
	var before := JSON.stringify(GameState.to_dict())

	GameState.new_game(DB.species["squirtle"])
	GameState.practice_mode = true
	GameState.set_difficulty("normal")
	r["Cargar"] = SaveManager.load_game()
	var after := JSON.stringify(GameState.to_dict())
	r["Equipo, niveles, EXP, PS, movimientos, opciones y posición idénticos"] = before == after
	r["Opciones restauradas"] = not GameState.practice_mode and GameState.difficulty_id() == "dificil" and GameState.balls == 7
	var sm := SaveManager.summary()
	r["Resumen del título (2 Pokémon, nivel del líder)"] = sm.get("species", []).size() == 2 and sm.get("leader_level", 0) == 31

	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	r["Aparece donde guardó"] = world.trainer.global_position.distance_to(saved_pos) < 1.0
	r["Sale el activo guardado (Bulbasaur)"] = is_instance_valid(world.companion) and world.companion.instance.species.id == "bulbasaur"

	# Archivos rotos
	var party_before := JSON.stringify(GameState.to_dict())
	_write(SaveManager.slot_path, "{esto no es json")
	r["JSON corrupto: no crashea ni toca la partida"] = not SaveManager.load_game() and JSON.stringify(GameState.to_dict()) == party_before
	_write(SaveManager.slot_path, JSON.stringify({"version": 1, "party": [
		{"species_id": "missingno", "level": 5},
		{"species_id": "charmander", "level": 8, "equipped_moves": ["no_existe", "charmander/ascuas_abanico", "", "lanzallamas"]}]}))
	var ok_load := SaveManager.load_game()
	var eq: Array[MoveData] = GameState.party[0].equipped_moves if ok_load else []
	r["Especie o movimiento inexistente: se saltea con aviso"] = ok_load and GameState.party.size() == 1 \
		and SaveManager.last_warnings.size() >= 3 and eq[0] == null and eq[1] != null and eq[3] == null
	_write(SaveManager.slot_path, JSON.stringify({"version": 1, "party": [{"species_id": "missingno"}]}))
	r["Sin ningún Pokémon válido: no carga"] = not SaveManager.load_game()
	SaveManager.delete_save()
	_results("save", r)


func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


# --- Vitrina de menús (--write-movie ... -- --showcase-menus) ------------------------------

func showcase_menus() -> void:
	SaveManager.slot_path = TEST_SLOT
	GameState.new_game(DB.species["charmander"])
	GameState.grant_exp(GameState.active(), CreatureInstance.exp_for_level("medium-slow", 31))
	for id in ["bulbasaur", "pidgey", "rattata", "vulpix", "pikachu"]:
		GameState.add_to_party(CreatureInstance.create(DB.species[id], 12))
	GameState.party[3].hp *= 0.4
	GameState.play_time = 3725.0
	GameState.zone_name = "Ruta 1"
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
	await get_tree().create_timer(2.0).timeout
	print("[showcase] menu")
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world := get_tree().current_scene
	await get_tree().create_timer(0.5).timeout
	world.pause_menu.try_open()
	await get_tree().create_timer(1.0).timeout
	world.pause_menu._open_party()
	await get_tree().create_timer(1.5).timeout
	var party: Control = world.pause_menu._stack[-1]
	party._open_actions(0)
	await get_tree().create_timer(1.0).timeout
	party._open_summary(0)
	await get_tree().create_timer(1.5).timeout
	var summary: Control = world.pause_menu._stack[-1]
	summary._tabs.current_tab = 1
	await get_tree().create_timer(1.0).timeout
	summary._rows[4].grab_focus()
	summary._on_row(summary._inst.species.learnset_entries()[4].move, false, summary._rows[4])
	await get_tree().create_timer(1.5).timeout
	SaveManager.delete_save()
	SaveManager.slot_path = SaveManager.SLOT
	get_tree().quit()


# --- Equipo -------------------------------------------------------------------------------

func party_test() -> void:
	var r := {}
	var world: Node = await autotest._setup_kit_world("charmander")
	r["Menú: no se abre en combate"] = not world.pause_menu.try_open() and not get_tree().paused
	world.combat.end_battle()
	await get_tree().physics_frame

	var ids := ["bulbasaur", "pidgey", "rattata", "vulpix", "pikachu"]
	for id in ids:
		GameState.add_to_party(CreatureInstance.create(DB.species[id], 8))
	r["Equipo de 6"] = GameState.party.size() == GameState.MAX_PARTY
	r["add_to_party rechaza al 7°"] = not GameState.add_to_party(CreatureInstance.create(DB.species["seel"], 5)) and GameState.party.size() == 6

	GameState.set_active(2)
	await get_tree().process_frame
	await get_tree().physics_frame
	r["Cambiar el activo respawnea al compañero correcto"] = is_instance_valid(world.companion) and world.companion.instance.species.id == "pidgey"
	GameState.party[4].hp = 0.0
	r["No se puede poner activo a uno debilitado"] = not GameState.set_active(4) and GameState.active_index == 2
	var active := GameState.active()
	GameState.move_in_party(2, 0)
	r["Reordenar mantiene el activo"] = GameState.active() == active and GameState.active_index == 0 and GameState.party[0] == active

	var me := GameState.active()
	var old: MoveData = me.equipped_moves[0]
	var extra: MoveData = DB.moves["ataque_ala"]  # Pidgey la aprende al Nv. 25
	r["Ficha: bloqueado no se equipa"] = not me.equip(0, extra)
	GameState.grant_exp(me, CreatureInstance.exp_for_level(me.species.growth_rate, 25) - me.experience)
	r["Ficha: aprendido sí, y el activo vuelve a salir con él"] = me.equip(0, extra)
	Events.equipment_changed.emit(me)
	await get_tree().process_frame
	await get_tree().physics_frame
	r["Ficha: aprendido sí, y el activo vuelve a salir con él"] = r["Ficha: aprendido sí, y el activo vuelve a salir con él"] \
		and is_instance_valid(world.companion) and world.companion.moves.slots[0] == extra and old != extra
	for k in 3:
		me.equip(k + 1, null)
	r["No se puede quedar sin movimientos"] = not me.equip(0, null) and me.equipped_moves[0] != null

	r["Menú: se abre fuera de combate y pausa"] = world.pause_menu.try_open() and get_tree().paused
	world.pause_menu.close()
	r["Menú: al cerrar despausa"] = not get_tree().paused

	var n := GameState.party.size()
	GameState.party.resize(3)
	r["Debug: F9 suma un Pokémon (solo con --debug)"] = world.debug_add_pokemon() and GameState.party.size() == 4 and n == 6
	_results("party", r)
