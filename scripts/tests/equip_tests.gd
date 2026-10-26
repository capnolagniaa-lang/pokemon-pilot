class_name EquipTests
extends Node
## Autotest de equipar movimientos (bug del usuario 2026-10-26: "hay un error con equipar los ataques cuando sube de
## nivel o cuando quiero equiparlo"): todo lo aprendido de cada Pokémon con kit se puede equipar, y equiparlo en el
## que está afuera (y subir de nivel) no rompe nada.
##   godot --headless --path . --quit-after 60000 -- --autotest-equip

var autotest: Node


func run() -> void:
	var r := {}
	var fails := []
	for sp: SpeciesData in DB.species.values():
		if sp.kit == null:
			continue
		var inst := CreatureInstance.create(sp, 100)
		for m in inst.learned_moves():
			if not inst.equip(3, m) or inst.equipped_moves[3] != m:
				fails.append("%s:%s" % [sp.id, DB.move_key(m)])
	r["Todo lo aprendido se puede equipar %s" % str(fails.slice(0, 8))] = fails.is_empty()
	# En el mundo: equipar en el que está afuera (la ficha emite equipment_changed) y usarlo.
	var world: Node = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	var inst: CreatureInstance = me.instance
	inst.level = 50
	var errors := []
	for m in inst.learned_moves():
		if not inst.equip(2, m):
			errors.append("no equipa " + m.id)
			continue
		Events.equipment_changed.emit(inst)
		await get_tree().physics_frame
		if not is_instance_valid(world.companion) or world.companion.moves.slots[2] != m:
			errors.append("no queda en la ranura " + m.id)
			continue
		r["En combate, el recién equipado arranca con su recarga (%s)" % m.id] = world.companion.moves.cooldowns[2] > 0.0 or m.cooldown <= 0.0
		world.companion.moves.reset_cooldown(2)
		world.companion.use_slot(2, Vector2.RIGHT, world.companion.global_position + Vector2(50, 0))
		await get_tree().create_timer(0.4).timeout
		if world.companion.machine.current_name() == "stunned":
			world.companion.machine.transition_to("controlled")
	r["Equipar en el que está afuera y usarlo %s" % str(errors)] = errors.is_empty()
	# Subir de nivel: aprende y (con una ranura libre) lo equipa solo.
	var fresh := CreatureInstance.create(DB.species["squirtle"], 5)
	fresh.equipped_moves[3] = null
	var text := GameState.grant_exp(fresh, CreatureInstance.exp_for_level(fresh.species.growth_rate, 20) - fresh.experience + 1)
	r["Subir de nivel aprende y equipa en la ranura libre (%s)" % text.strip_edges()] = fresh.level >= 20 \
		and fresh.equipped_moves[3] != null

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[equipar] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-equip] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)
