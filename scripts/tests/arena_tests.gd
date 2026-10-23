class_name ArenaTests
extends Node
## Autotest de los combates contra entrenadores en arena (docs/PLAN_ENTRENADORES.md, E-1):
##   godot --headless --path . --quit-after 60000 -- --autotest-arena
## Vitrina (Brock en su gimnasio, Onix jefe): godot --path . --quit-after 600 --write-movie out/f.png --fixed-fps 30 -- --showcase-arena

var autotest: Node
var world: Node
var _auto_dialog := true


func run() -> void:
	var r := {}
	r["Hay arenas (campo y gimnasio de roca)"] = ResourceLoader.exists("res://data/arenas/arena_campo.tres") \
		and ResourceLoader.exists("res://data/arenas/arena_gimnasio_roca.tres")
	var trainers := DB.npcs.values().filter(func(n): return n.trainer != null)
	r["Entrenadores de la historia cargados (%d)" % trainers.size()] = trainers.size() >= 8
	r["Brock: Geodude 12 + Onix 14 en el gimnasio de roca"] = _team_of("ciudad_plateada_gimnasio_brock") == "geodude12 onix14" \
		and DB.npcs["ciudad_plateada_gimnasio_brock"].trainer.arena_id == "arena_gimnasio_roca"

	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	GameState.active().level = 30
	GameState.active().hp = GameState.active().max_hp()
	GameState.add_to_party(CreatureInstance.create(DB.species["bulbasaur"], 25))
	_dialogs()

	# --- Ganarle a Brock (le hablás) ---
	await _npc_near("ciudad_plateada_gimnasio_brock", Vector2i(0, 2))
	var brock: NpcData = DB.npcs["ciudad_plateada_gimnasio_brock"]
	var start_pos: Vector2 = world.trainer.global_position
	world.story.try_interact()
	await _until(func(): return world.arena.active and is_instance_valid(world.arena.foe), 8.0)
	var foe: Creature = world.arena.foe
	r["Hablarle a Brock te lleva a su arena"] = world.arena.active and world.arena.arena != null \
		and world.trainer.global_position.distance_to(TrainerBattle.ARENA_ORIGIN) < 1500.0
	r["Sale su primer Pokémon (Geodude de Brock)"] = is_instance_valid(foe) and foe.instance.species.id == "geodude" and foe.owner_name == "Brock"
	r["Tu Pokémon pelea (control y combate trabado)"] = world.combat.in_battle and world.combat.arena_lock and world.companion.player_controlled
	var balls := GameState.item_count("poke_ball")
	await autotest._tap("capture")
	await get_tree().process_frame
	r["No se puede atrapar al Pokémon de un entrenador"] = GameState.item_count("poke_ball") == balls
	var exp0: int = GameState.active().experience
	_ko(foe)
	await _until(func(): return is_instance_valid(world.arena.foe) and world.arena.foe.instance.species.id == "onix", 5.0)
	r["Al caer, saca al siguiente (Onix)"] = is_instance_valid(world.arena.foe) and world.arena.foe.instance.species.id == "onix"
	r["Debilitar a uno da EXP"] = GameState.active().experience > exp0
	r["Onix sale como jefe (grande)"] = world.arena.foe.sprite.scale.x > 1.2
	# Tu Pokémon cae: sale el siguiente sano solo.
	_ko(world.companion)
	await _until(func(): return is_instance_valid(world.companion) and not world.companion.is_down() \
		and world.companion.instance.species.id == "bulbasaur", 5.0)
	r["Si cae tu Pokémon, sale el siguiente sano"] = is_instance_valid(world.companion) and world.companion.instance.species.id == "bulbasaur" \
		and world.companion.player_controlled and world.arena.active
	_ko(world.arena.foe)
	await _until(func(): return not world.arena.active, 12.0)
	r["Ganarle termina la pelea y te devuelve adonde estabas"] = not world.arena.active and world.arena.arena == null \
		and world.trainer.global_position.distance_to(start_pos) < 4.0 and not world.combat.in_battle
	r["Ganarle a Brock da la Medalla Roca"] = GameState.has_flag("medalla_roca") and GameState.has_flag(brock.defeated_flag())
	world.story.try_interact()
	await get_tree().process_frame
	r["Ya vencido, Brock solo charla"] = not world.arena.active
	await _until(func(): return not world.story.busy, 3.0)

	# --- Un Cazabichos te ve y te desafía; perdés y volvés al último lugar donde te curaron ---
	for inst in GameState.party:
		inst.hp = inst.max_hp()
	GameState.last_heal_position = world.trainer.global_position
	var heal_pos: Vector2 = GameState.last_heal_position
	var bug: NpcData = DB.npcs["bosque_verde_rick"]
	await _npc_near(bug.id, bug.facing * 3)
	await _until(func(): return world.arena.active and world.arena._fighting, 12.0)
	r["Un entrenador que te ve te desafía solo"] = world.arena.active and world.arena.foe_name == "Ricardo"
	r["Los de ruta pelean en el claro de pinos"] = world.arena.arena_data != null and world.arena.arena_data.id == "arena_campo"
	for k in 3:
		await _until(func(): return is_instance_valid(world.companion) and not world.companion.is_down(), 4.0)
		if not world.arena.active:
			break
		_ko(world.companion)
		await get_tree().create_timer(1.5).timeout
	await _until(func(): return not world.arena.active, 10.0)
	r["Sin Pokémon perdés y volvés donde te curaron"] = not world.arena.active and world.arena.result == "lose" \
		and world.trainer.global_position.distance_to(heal_pos) < 4.0
	r["Al perder, el equipo vuelve curado"] = GameState.party.all(func(i): return i.hp == i.max_hp())
	r["Perder no cuenta como vencido"] = not GameState.has_flag(bug.defeated_flag())

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[arena] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-arena] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _team_of(id: String) -> String:
	return " ".join(DB.npcs[id].trainer.starting_team.map(func(m): return "%s%d" % [m.species.id, m.level]))


## Avanza solo los diálogos (el autotest no aprieta teclas para leer).
func _dialogs() -> void:
	while is_inside_tree():
		await get_tree().create_timer(0.15).timeout
		if _auto_dialog and world.story.dialog.active:
			world.story.dialog.advance()


func _ko(c: Creature) -> void:
	if is_instance_valid(c):
		c.health.apply_damage(c.instance.max_hp() * 10.0)


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


## Lleva al entrenador al lado de una persona y devuelve su StoryNPC.
func _npc_near(id: String, offset: Vector2i) -> StoryNPC:
	var npc: NpcData = DB.npcs[id]
	var data: WorldData = world.streamer.world_data
	var entry: ZoneEntry = null
	for z in data.zones:
		if z.id == npc.zone_id:
			entry = z
	var pos := Vector2((entry.origin + npc.cell + offset) * data.tile_size) + Vector2.ONE * data.tile_size / 2.0
	world.streamer.load_around_now(pos)
	world.trainer.global_position = pos
	world.camera.snap()
	for i in 3:
		await get_tree().process_frame
	world.story.refresh()
	await get_tree().physics_frame
	return world.story.npcs.get(id)


func showcase() -> void:
	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	GameState.active().level = 18
	GameState.active().hp = GameState.active().max_hp()
	_dialogs()
	await _npc_near("ciudad_plateada_gimnasio_brock", Vector2i(0, 2))
	world.story.try_interact()
	await _until(func(): return is_instance_valid(world.arena.foe), 10.0)
	_ko(world.arena.foe)
	await _until(func(): return is_instance_valid(world.arena.foe) and world.arena.foe.instance.species.id == "onix", 5.0)
	world.combat.input_source = BotCombatInput.new(world)
	world.companion.input_source = world.combat.input_source
	await get_tree().create_timer(9.0).timeout
	get_tree().quit()
