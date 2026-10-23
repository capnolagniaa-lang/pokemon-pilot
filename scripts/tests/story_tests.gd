class_name StoryTests
extends Node
## Autotest de la base de la historia (docs/PLAN_HISTORIA.md, H-0) y del cambio de Pokémon con 1-6:
##   godot --headless --path . --quit-after 30000 -- --autotest-story
## Vitrina (la enfermera de Ciudad Verde hablando): godot --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-story

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	r["Hay personas de la historia cargadas (%d)" % DB.npcs.size()] = DB.npcs.size() >= 50
	var bad := DB.npcs.values().filter(func(n): return not ResourceLoader.exists("res://art/pret/characters/%s.png" % n.gfx) \
		or n.talks.is_empty() or n.talks[0].lines.is_empty())
	r["Todas tienen sprite y algo para decir"] = bad.is_empty()

	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await get_tree().physics_frame
	var story: StoryDirector = world.story

	# --- Enfermera: cura al equipo ---
	var nurse: NpcData = DB.npcs["ciudad_verde_centro_nurse"]
	await _go_near(nurse, Vector2i(0, 2))
	r["La enfermera aparece en el Centro de Ciudad Verde"] = is_instance_valid(story.npcs.get(nurse.id))
	var inst: CreatureInstance = GameState.active()
	inst.hp = inst.max_hp() * 0.3
	world.companion.statuses.apply(DB.statuses["envenenado"])
	var balls := GameState.item_count("poke_ball")
	await autotest._tap("capture")
	await get_tree().process_frame
	r["E al lado de alguien habla (no tira la bola)"] = story.dialog.active and GameState.item_count("poke_ball") == balls
	r["Mientras habla, el entrenador no se mueve"] = world.trainer.locked
	await _finish_dialog(story)
	r["La enfermera cura todo (vida y estados)"] = inst.hp == inst.max_hp() and not world.companion.statuses.has_status("envenenado")
	r["Al terminar se puede mover de nuevo"] = not world.trainer.locked and not story.busy

	# --- Empleado de Ruta 1: regala una Poción una sola vez ---
	var clerk: NpcData = DB.npcs["ruta1_martclerk"]
	await _go_near(clerk, Vector2i(0, 1))
	var pots := GameState.item_count("pocion")
	story.try_interact()
	await _finish_dialog(story)
	r["El empleado regala una Poción y anota la bandera"] = GameState.item_count("pocion") == pots + 1 and GameState.has_flag("muestra_pocion")
	story.try_interact()
	await _finish_dialog(story)
	r["La segunda vez no regala otra"] = GameState.item_count("pocion") == pots + 1

	# --- Bloqueo: un NPC con hide_if desaparece al poner la bandera ---
	var gate := NpcData.new()
	gate.id = "test_bloqueo"
	gate.zone_id = clerk.zone_id
	gate.cell = clerk.cell + Vector2i(3, 0)
	gate.gfx = "old_man_1"
	gate.hide_if = PackedStringArray(["test_abierto"])
	var t := NpcTalk.new()
	t.lines = PackedStringArray(["No podés pasar."])
	gate.talks = [t]
	DB.npcs[gate.id] = gate
	story.refresh()
	r["Un bloqueo aparece mientras falta su bandera"] = is_instance_valid(story.npcs.get(gate.id))
	GameState.set_flag("test_abierto")
	await get_tree().process_frame
	r["Al poner la bandera, el bloqueo se va"] = not is_instance_valid(story.npcs.get(gate.id))
	DB.npcs.erase(gate.id)

	# --- Disparador: pisar la celda abre la conversación y te hace volver ---
	var zone: Zone = world.streamer.zone_node(clerk.zone_id)
	var here := zone.cell_at(world.trainer.global_position)
	var trig := StoryTrigger.new()
	trig.id = "test_disparador"
	trig.zone_id = clerk.zone_id
	trig.rect = Rect2i(here + Vector2i(0, -1), Vector2i(1, 1))
	trig.push_back = true
	trig.talk = NpcTalk.new()
	trig.talk.lines = PackedStringArray(["¡Esperá!"])
	DB.story_triggers[trig.id] = trig
	await get_tree().physics_frame
	world.trainer.global_position = zone.to_global(zone.ground.map_to_local(here + Vector2i(0, -1)))
	for i in 3:
		await get_tree().physics_frame
	r["Pisar un disparador abre su conversación"] = story.dialog.active
	await _finish_dialog(story)
	r["El disparador te hace volver un paso"] = zone.cell_at(world.trainer.global_position) == here
	r["Un disparador de una vez no se repite"] = GameState.has_flag(trig.flag()) and not trig.ready_to_fire()
	DB.story_triggers.erase(trig.id)

	# --- Banderas en la partida ---
	var saved := GameState.to_dict()
	GameState.story_flags.clear()
	GameState.from_dict(saved)
	r["Las banderas se guardan con la partida"] = GameState.has_flag("muestra_pocion") and GameState.has_flag("test_abierto")

	# --- Cambio de Pokémon con 1-6 ---
	GameState.add_to_party(CreatureInstance.create(DB.species["pidgey"], 8))
	GameState.add_to_party(CreatureInstance.create(DB.species["rattata"], 8))
	await get_tree().process_frame
	world.combat._switch_cd = 0.0
	await autotest._tap("switch_3")
	await get_tree().process_frame
	r["La tecla 3 saca al 3º del equipo"] = GameState.active_index == 2 and world.companion.instance.species.id == "rattata"
	world.combat._switch_cd = 0.0
	world.combat.start_battle()
	await get_tree().physics_frame
	var at: Vector2 = world.companion.global_position
	await autotest._tap("switch_2")
	await get_tree().physics_frame
	await get_tree().physics_frame
	var c: Creature = world.companion
	r["En combate, cambiar sigue la pelea con el nuevo"] = world.combat.in_battle and c.instance.species.id == "pidgey" \
		and c.player_controlled and c.machine.current_name() == "controlled" and c.global_position.distance_to(at) < 12.0
	await autotest._tap("switch_1")
	r["Hay una recarga entre cambios"] = GameState.active_index == 1
	GameState.party[0].hp = 0.0
	world.combat._switch_cd = 0.0
	r["No se puede sacar a uno debilitado"] = not world.combat.switch_to(0) and GameState.active_index == 1

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[story] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-story] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Lleva al entrenador al lado de una persona (carga su zona) y espera a que aparezca.
func _go_near(npc: NpcData, offset: Vector2i) -> void:
	var data: WorldData = world.streamer.world_data
	var entry: ZoneEntry = null
	for z in data.zones:
		if z.id == npc.zone_id:
			entry = z
	var pos := Vector2((entry.origin + npc.cell + offset) * data.tile_size) + Vector2.ONE * data.tile_size / 2.0
	world.streamer.load_around_now(pos)
	world.trainer.global_position = pos
	world.camera.snap()
	for i in 4:
		await get_tree().process_frame
	world.story.refresh()
	await get_tree().physics_frame


func _finish_dialog(story: StoryDirector) -> void:
	for i in 40:
		if not story.busy and not story.dialog.active:
			return
		story.dialog.advance()
		await get_tree().process_frame


func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await _go_near(DB.npcs["ciudad_verde_centro_nurse"], Vector2i(0, 2))
	await get_tree().create_timer(0.5).timeout
	world.story.try_interact()
	await get_tree().create_timer(2.5).timeout
	world.story.dialog.advance()
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()
