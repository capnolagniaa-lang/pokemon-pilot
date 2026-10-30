class_name TrainerAiTests
extends Node
## Entrenadores con cabeza (docs/PLAN_IA.md, IA-4): estilo por clase, elegir a quién sacar, cambiar por tipos,
## Superpoción y los momentos del guion de los líderes.
##   godot --headless --path . --quit-after 60000 -- --autotest-ai-trainers

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	r["Estilos por clase (Cazabichos impaciente, Montañero aguante, Líder, sin clase = por defecto)"] = \
		DB.trainer_style_for("Cazabichos").id == "impaciente" and DB.trainer_style_for("Montañero").id == "aguante" \
		and DB.trainer_style_for("Líder").id == "lider" and DB.trainer_style_for("Nadie").id == "" \
		and is_equal_approx(DB.trainer_style_for("Nadie").retreat, 0.35)
	r["Guiones: los 8 líderes y el Campeón (el rival de antes no)"] = DB.leader_scripts.size() >= 9 \
		and DB.leader_script_for("brock") != null and DB.leader_script_for("lt. surge") != null \
		and DB.leader_script_for("liga_campeon_0x0") != null and DB.leader_script_for("azul") == null

	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	var me := GameState.active()
	me.level = 30
	me.equipped_moves = me.default_equipment()
	me.hp = me.max_hp()
	world.respawn_companion()
	await get_tree().physics_frame

	# --- El estratega saca al que mejor le va (Bulbasaur contra tu Squirtle, no el Charmander de la lista) ---
	var team: Array[CreatureInstance] = [CreatureInstance.create(DB.species["charmander"], 20), CreatureInstance.create(DB.species["bulbasaur"], 20)]
	world.arena.start({"name": "Gus", "title": "Entrenador Guay", "team": team})
	await _until(func(): return world.arena.active and is_instance_valid(world.arena.foe), 8.0)
	var arena: TrainerBattle = world.arena
	r["Estratega: sale primero el que mejor le va (%s)" % arena.foe.instance.species.id] = arena.foe.instance.species.id == "bulbasaur"
	r["Su Pokémon sabe cómo pelea su entrenador"] = arena.foe.trainer_style != null and arena.foe.trainer_style.id == "estratega"
	await _finish(arena)

	# --- Cambio por tipos: el impaciente saca la lista en orden; con cambio por tipos, retira al Charmander ---
	team = [CreatureInstance.create(DB.species["charmander"], 20), CreatureInstance.create(DB.species["bulbasaur"], 20)]
	world.arena.start({"name": "Gus", "title": "Cazabichos", "team": team})
	await _until(func(): return world.arena.active and is_instance_valid(world.arena.foe), 8.0)
	r["Impaciente: saca el primero de la lista"] = arena.foe.instance.species.id == "charmander"
	r["El Charmander se sabe en desventaja contra tu Squirtle"] = arena.foe.mind.matchup() == "cuidate"
	arena.style = arena.style.duplicate()
	arena.style.switch_types = 1.0
	arena._entered_at = arena._clock - 10.0
	arena.think()
	await get_tree().physics_frame
	r["Con los tipos en contra lo cambia por el Bulbasaur"] = is_instance_valid(arena.foe) and arena.foe.instance.species.id == "bulbasaur"

	# --- Superpoción ---
	var foe: Creature = arena.foe
	foe.instance.hp = foe.instance.max_hp() * 0.2
	var before := foe.instance.hp
	arena.potions_left = 1
	arena.think()
	await get_tree().physics_frame
	r["Con poca vida usa la Superpoción y queda expuesto"] = foe.instance.hp > before and arena.potions_left == 0 \
		and foe.machine.current_name() == "stunned"
	foe.instance.hp = foe.instance.max_hp() * 0.2
	before = foe.instance.hp
	arena.potions_left = 1
	arena.think()
	r["...una sola por Pokémon"] = foe.instance.hp == before

	# --- Momentos del guion (Brock: Fortaleza a la mitad de la vida) ---
	arena.script_data = DB.leader_script_for("brock")
	arena._moments_done.clear()
	arena._retreat_checked[foe.instance] = true  # (que no lo retire en vez de plantarse)
	foe.instance.hp = foe.instance.max_hp() * 0.4
	arena.think()
	r["Brock: con menos de la mitad, Fortaleza"] = foe.statuses.has_status("fortaleza")
	foe.statuses.clear()
	arena.think()
	r["...una sola vez por pelea"] = not foe.statuses.has_status("fortaleza")
	# Surge: además de enfurecerse, ataca más seguido un rato.
	var surge: LeaderScript = DB.leader_script_for("lt. surge")
	var calm: float = foe.mind.trainer_pace()
	arena.play_moment(surge.moments[0])
	r["Surge: enfurecido y ataca más seguido (%.2f → %.2f)" % [calm, foe.mind.trainer_pace()]] = \
		foe.statuses.has_status("enfurecido") and foe.mind.trainer_pace() < calm * 0.8
	await _finish(arena)

	# --- Pelea de verdad de la historia: Misty (su guion llega desde StoryDirector.fight) ---
	world.story.fight(DB.npcs["ciudad_celeste_gimnasio_misty"])
	await _until(func(): return arena.active and is_instance_valid(arena.foe), 8.0)
	r["Pelea de la historia: Misty tiene su guion"] = arena.script_data != null and arena.script_data.id == "misty" \
		and arena.style.id == "lider"
	arena.foe.health.apply_damage(arena.foe.instance.max_hp() * 10.0)
	await _until(func(): return is_instance_valid(arena.foe) and not arena.foe.is_down() and arena.foe.instance.species.id == "starmie", 8.0)
	await get_tree().physics_frame
	r["Sale Starmie (su último) y se potencia («inundá la cancha»)"] = is_instance_valid(arena.foe) \
		and arena.foe.instance.species.id == "starmie" and arena.foe.statuses.has_status("potenciado")
	await _finish(arena)

	# --- Estilos en la mente ---
	var dummy: Creature = autotest._dummy(world, "geodude", world.companion.global_position + Vector2(60, 0))
	var target: Creature = autotest._dummy(world, "rattata", world.companion.global_position + Vector2(90, 0))
	await get_tree().physics_frame
	dummy.target = target
	dummy.temperament = DB.temperaments["entrenador"]
	dummy.trainer_style = DB.trainer_style_for("Montañero")
	var steady: float = dummy.mind.trainer_pace()
	target.hitstun_left = 3.0
	var punish: float = dummy.mind.trainer_pace()
	r["Aguante: espera (×%.2f) y contragolpea cuando estás expuesto (×%.2f)" % [steady, punish]] = steady > 1.0 and punish < 1.0
	dummy.trainer_style = DB.trainer_style_for("Cazabichos")
	dummy.instance.hp = dummy.instance.max_hp() * 0.2
	r["Impaciente con poca vida se juega todo (aunque su temperamento sea de entrenador)"] = dummy.mind.low_hp_plan() == "todo"

	var ok := r.values().all(func(v): return v)
	for k in r:
		print("[ia-entrenadores] %s %s" % ["OK   " if r[k] else "FALLO", k])
	print("[autotest-ai-trainers] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Termina la pelea de arena como ganada y espera a volver al mundo.
func _finish(arena: TrainerBattle) -> void:
	arena._end("win")
	await _until(func(): return not arena.active, 10.0)
	GameState.heal_party()
	world.respawn_companion()
	await get_tree().physics_frame


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()
