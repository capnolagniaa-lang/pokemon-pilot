class_name TrainerTests
extends Node
## Autotest de los entrenadores vivos (docs/PLAN_ENTRENADORES.md):
##   godot --headless --path . --quit-after 20000 -- --autotest-trainers
## E-0: interruptor, datos, NPC en el mundo según el interruptor y la zona, y guardado.

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	r["3 entrenadores con equipo, personalidad y rutina"] = DB.trainers.size() == 3 and DB.trainers.values().all(
		func(t): return not t.starting_team.is_empty() and t.personality != null and not t.routine.is_empty() and t.sprite != null)
	GameState.living_trainers = false
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await get_tree().create_timer(0.3).timeout
	r["Apagado (por defecto): no hay entrenadores en el mundo"] = _npcs().is_empty()

	GameState.set_living_trainers(true)
	await get_tree().process_frame
	await get_tree().process_frame
	var npcs := _npcs()
	r["Prendido: aparecen los 3 en Ruta 1"] = npcs.size() == 3
	var ok_place := true
	for npc in npcs:
		var block: RoutineBlock = npc.data.routine[0]
		var zone: Zone = world.streamer.zone_node(block.zone_id)
		var cell := zone.cell_at(npc.global_position)
		ok_place = ok_place and MapRules.is_walkable(zone, cell) and Vector2(cell - block.cell).length() <= 4.0
	r["Cada uno en una celda caminable cerca de su lugar"] = ok_place
	r["Cada uno tiene su estado con el equipo inicial"] = npcs.all(func(n): return n.state().team.size() == n.data.starting_team.size())

	# Mira al jugador y muestra su nombre cuando te acercás.
	var azul: TrainerNPC = world.trainers.npcs["azul"]
	world.trainer.global_position = azul.global_position + Vector2(-40, 0)
	await get_tree().create_timer(0.2).timeout
	r["Te mira y muestra su nombre cuando te acercás"] = azul.name_label.visible and azul.facing == Vector2.LEFT

	# Guardado: el interruptor y lo que cambió del entrenador.
	azul.state().losses = 2
	var d := GameState.to_dict()
	GameState.new_game(DB.species["squirtle"])
	GameState.living_trainers = false
	GameState.from_dict(d)
	# Al cargar queda apagado (sacado del juego por ahora, 2026-10-29): se vuelve a prender para seguir probando.
	r["Se guarda el estado de cada entrenador (y al cargar queda apagado)"] = not GameState.living_trainers \
		and GameState.trainer_state(DB.trainers["azul"]).losses == 2
	GameState.set_living_trainers(true)

	# Al alejarse (se descarga Ruta 1) desaparecen; al volver, reaparecen con su estado.
	var far := _zone_center("ciudad_plateada")
	world.trainer.global_position = far
	world.camera.global_position = far
	await get_tree().create_timer(2.5).timeout
	r["Si se descarga su zona, desaparecen"] = world.streamer.zone_node("ruta1") == null and _npcs().is_empty()
	var home := _zone_center("ruta1")
	world.trainer.global_position = home
	world.camera.global_position = home
	await get_tree().create_timer(2.5).timeout
	r["Al volver reaparecen y recuerdan (estado intacto)"] = _npcs().size() == 3 \
		and GameState.trainer_state(DB.trainers["azul"]).losses == 2

	GameState.set_living_trainers(false)
	await get_tree().process_frame
	await get_tree().process_frame
	r["Apagar en Opciones los saca al momento"] = _npcs().is_empty()

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[trainers] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-trainers] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _npcs() -> Array:
	return get_tree().get_nodes_in_group("trainer_npcs").filter(func(n): return not n.is_queued_for_deletion())


func _zone_center(id: String) -> Vector2:
	for z in world.streamer.world_data.zones:
		if z.id == id:
			return z.world_rect(world.streamer.world_data.tile_size).get_center()
	return Vector2.ZERO


## Vitrina (--write-movie ... -- --showcase-trainers): los 3 entrenadores en Ruta 1.
func showcase() -> void:
	GameState.living_trainers = true
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await get_tree().create_timer(0.5).timeout
	var azul: TrainerNPC = world.trainers.npcs.get("azul")
	if azul != null:
		world.trainer.global_position = azul.global_position + Vector2(-36, 10)
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
