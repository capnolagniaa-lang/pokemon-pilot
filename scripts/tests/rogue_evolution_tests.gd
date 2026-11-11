class_name RogueEvolutionTests
extends Node
## Autotest de la evolución en el Modo Desafío (pedido del usuario 2026-11-11: "no evoluciona en el medio de la run"):
## al llegar al nivel, evoluciona con la sala limpia, antes de elegir puerta, conservando todo.
##   godot --headless --path . --fixed-fps 60 --quit-after 60000 -- --autotest-rogue-evolution

var world: Node
var run: RogueRun
var me: Creature


func run_tests() -> void:
	var r := {}
	RogueRun.begin(DB.species["charmander"])
	GameState.rogue["biomes"] = ["bosque", "cueva", "volcan", "hielo", "costa"]
	GameState.rogue["rewards"] = ["dinero", "dinero"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	me = world.companion
	var inst: CreatureInstance = GameState.active()
	var evo: EvolutionDirector = world.evolutions
	evo.speed = 12.0
	run.boons.take("sobrecarga", "rara")
	await run.rewards.grant("proteina")
	var mult := inst.hp_mult
	var moves: Array = inst.equipped_moves.duplicate()
	var ability := inst.species.abilities.map(func(a): return a.id).find(inst.ability)

	# Sube al nivel 16 en plena oleada: queda esperando, no interrumpe la pelea.
	var need: int = CreatureInstance.exp_for_level(inst.species.growth_rate, 16) - inst.experience
	GameState.grant_exp(inst, need)
	for i in 30:
		await get_tree().process_frame
	r["Llegó a Nv. 16 en plena oleada: la evolución espera (no corta la pelea)"] = inst.level == 16 and inst.species.id == "charmander" \
		and evo.pending() and not evo.showing and run.phase == "oleada"
	inst.hp = inst.max_hp() * 0.5
	var spot := me.global_position
	await _clear_room()
	await _until(func(): return is_instance_valid(run.boon_screen), 6.0)
	var early := evo.showing
	if is_instance_valid(run.boon_screen):
		run.boon_screen.choose(0)  # (la recompensa de la sala va primero)
	await _until(func(): return evo.showing or run.phase == "eleccion", 8.0)
	r["Con la sala limpia y la recompensa cobrada, evoluciona (antes de las puertas)"] = evo.showing and not early and run.phase == "evolucion" \
		and run.reward_doors.is_empty()
	var asked := 0
	var t := 0.0
	while t < 30.0 and run.phase != "eleccion":
		if evo.moves.showing and is_instance_valid(evo.moves.screen):  # "¿reemplazar un ataque?": no
			evo.moves.screen.finished.emit(-1)
			asked += 1
		await get_tree().process_frame
		t += get_process_delta_time()
	print("[evolucion]       (ataques nuevos preguntados: %d)" % asked)
	var c: Creature = world.companion
	r["Charmander → %s, al mismo nivel" % inst.species.display_name] = inst.species.id == "charmeleon" and inst.level == 16 \
		and GameState.party.size() == 1 and GameState.active() == inst
	r["Sale con la forma nueva en el mismo lugar y lo seguís manejando"] = is_instance_valid(c) and c != me and c.instance == inst \
		and c.player_controlled and world.camera.target == c and world.trainer.follow_target == c and world.trainer.locked \
		and c.global_position.distance_to(spot) < 60.0 and world.combat.in_battle
	r["Conserva la vida en proporción (%d %%), el Más PS (×%.2f) y la bendición" % [roundi(100.0 * inst.hp / inst.max_hp()), inst.hp_mult]] = \
		absf(inst.hp / inst.max_hp() - 0.5) < 0.03 and is_equal_approx(inst.hp_mult, mult) and mult > 1.0 \
		and run.boons.has("sobrecarga") and run.boons.entry("sobrecarga")["rarity"] == "rara" \
		and is_equal_approx(c.health.max_hp(), inst.max_hp())
	r["Conserva sus ataques (%s) y la habilidad del mismo lugar" % ", ".join(inst.equipped_moves.filter(func(m): return m != null).map(
		func(m): return m.display_name))] = moves.all(func(m): return m == null or inst.equipped_moves.has(m)) \
		and inst.species.abilities.map(func(a): return a.id).find(inst.ability) == ability
	r["Las bendiciones quedan enganchadas al Pokémon nuevo"] = run.boons._creature == c
	r["La evolución no queda desbloqueada como inicial (solo lo que atrapás)"] = not RogueProgress.is_unlocked("charmeleon")
	r["Después siguen las puertas, como siempre"] = run.phase == "eleccion" and run.reward_doors.size() == 2 and not evo.pending()

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[evolucion] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-evolution] -> ", "OK" if ok else "FALLO")
	GameState.rogue = {}
	get_tree().quit(0 if ok else 1)


## Limpia la sala: debilita a todos los de cada oleada apenas salen.
func _clear_room() -> void:
	var room := run.room_index
	var t := 0.0
	while t < 40.0 and run.room_index == room and run.phase in ["oleada", ""] and run.rooms_cleared <= room:
		for e: Creature in run.foes.duplicate():
			if is_instance_valid(e) and not e.is_down():
				e.health.apply_damage(99999.0)
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()
