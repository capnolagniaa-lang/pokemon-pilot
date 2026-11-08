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
		and DB.trainer_style_for("Líder").id == "lider" and DB.trainer_style_for("Alto Mando").id == "elite" \
		and DB.trainer_style_for("Campeón").id == "elite" and DB.trainer_style_for("Nadie").id == "" \
		and is_equal_approx(DB.trainer_style_for("Nadie").retreat, 0.35)
	r["Guiones: los 8 líderes y el Campeón (el rival de antes no)"] = DB.leader_scripts.size() >= 9 \
		and DB.leader_script_for("brock") != null and DB.leader_script_for("lt. surge") != null \
		and DB.leader_script_for("liga_campeon_0x0") != null and DB.leader_script_for("azul") == null

	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	_dialogs()
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
	arena.style.max_switches = 1
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

	await _reads(r)

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


## IA-7: el daño de verdad de cada cruce, cambiar como una persona y leer costumbres.
func _reads(r: Dictionary) -> void:
	var me: Creature = world.companion
	var make := func(id: String, lv: int) -> CreatureInstance: return CreatureInstance.create(DB.species[id], lv)
	# El daño de verdad
	var strong: CreatureInstance = make.call("machop", 30)
	var physical := MoveData.new()
	physical.power = 60.0
	physical.category = MoveData.Category.PHYSICAL
	physical.element = DB.types["normal"]
	var special: MoveData = physical.duplicate()
	special.category = MoveData.Category.SPECIAL
	r["Cruces: un físico rinde según su Ataque (Machop, físico > especial)"] = TacticalMind.hit_share(physical, strong, make.call("abra", 30)) > TacticalMind.hit_share(special, strong, make.call("abra", 30))
	var water: MoveData = physical.duplicate()
	water.element = DB.types["agua"]
	var ratio: float = TacticalMind.hit_share(water, strong, make.call("charmander", 30)) / TacticalMind.hit_share(physical, strong, make.call("charmander", 30))
	r["Cruces: súper efectivo saca el doble (%.1f)" % ratio] = absf(ratio - 2.0) < 0.3
	r["Cruces: inmune no saca nada"] = TacticalMind.hit_share(physical, strong, make.call("gastly", 30)) == 0.0
	var weak_grass: CreatureInstance = make.call("bellsprout", 5)
	var big: CreatureInstance = make.call("pidgeot", 45)
	r["Un tipo a favor pero muy flojo pierde contra uno fuerte"] = TacticalMind.matchup_score(big, me) > TacticalMind.matchup_score(weak_grass, me)
	var hurt: CreatureInstance = make.call("pidgeot", 45)
	hurt.hp = hurt.max_hp() * 0.1
	r["Uno casi debilitado vale menos"] = TacticalMind.matchup_score(hurt, me) < TacticalMind.matchup_score(big, me)
	# Solo sabe lo que vio
	var memo := FoeMemory.new()
	var ice: MoveData = DB.moves["rayo_hielo"]
	var keep: Array[MoveData] = me.moves.slots.duplicate()
	me.moves.slots[3] = ice
	var grass: CreatureInstance = make.call("bulbasaur", 30)
	var knows: float = TacticalMind.matchup_score(grass, me)
	var blind: float = TacticalMind.matchup_score(grass, me, memo)
	r["Sin haberlo visto no sabe que tenés Rayo Hielo"] = blind > knows
	memo.note_move(me.instance, ice, true)
	r["Cuando lo usás, ya lo sabe"] = memo.seen_moves(me.instance).has(ice) and TacticalMind.matchup_score(grass, me, memo) < blind
	# La costumbre
	var fresh := FoeMemory.new()
	var gun: MoveData = me.moves.slots[0]
	r["Dos veces no es costumbre"] = (func():
		fresh.note_move(me.instance, gun, true)
		fresh.note_move(me.instance, gun, true)
		return fresh.habit() == null).call()
	for i in 3:
		fresh.note_move(me.instance, gun, true)
	r["Repetirlo sí"] = fresh.habit() == gun
	fresh.note_move(me.instance, ice, true)
	fresh.note_move(me.instance, DB.moves["placaje"], true)
	fresh.note_move(me.instance, ice, true)
	r["Si variás, se le pasa"] = fresh.habit() == null or fresh.habit() != gun
	me.moves.slots.assign(keep)

	# Cambiar como una persona: vos cambiás y responde enseguida
	var arena: TrainerBattle = world.arena
	GameState.party.resize(1)
	var fire: CreatureInstance = make.call("charmander", 30)
	GameState.party.append(fire)
	var team: Array[CreatureInstance] = [make.call("bulbasaur", 30), make.call("squirtle", 30)]
	world.arena.start({"name": "Gus", "title": "Alto Mando", "team": team})
	await _until(func(): return arena.active and is_instance_valid(arena.foe), 8.0)
	r["Contra tu Squirtle saca al Bulbasaur"] = arena.foe.instance.species.id == "bulbasaur"
	r["El Alto Mando conoce tus ataques"] = arena._known() == null
	await get_tree().create_timer(0.5).timeout
	world.combat._switch_cd = 0.0
	world.combat.switch_to(1)
	var swapped_at := Time.get_ticks_msec()
	await get_tree().create_timer(0.6).timeout
	r["No responde al instante"] = is_instance_valid(arena.foe) and arena.foe.instance.species.id == "bulbasaur"
	await _until(func(): return is_instance_valid(arena.foe) and arena.foe.instance.species.id == "squirtle", 3.0)
	var waited := (Time.get_ticks_msec() - swapped_at) / 1000.0
	r["Sacaste Fuego: en %.1f s responde con el de Agua" % waited] = is_instance_valid(arena.foe) and arena.foe.instance.species.id == "squirtle"
	var after: Creature = arena.foe
	# Cambiar de nuevo enseguida no lo hace saltar
	world.combat._switch_cd = 0.0
	world.combat.switch_to(0)
	await get_tree().create_timer(TrainerBattle.SWITCH_REACT + 0.6).timeout
	r["No se puede jugar a cambiar sin parar"] = is_instance_valid(arena.foe) and arena.foe == after
	# Lee lo que repetís
	r["La memoria es de todo el equipo"] = after.mind.memory == arena._memory
	var mine: Creature = world.companion
	if is_instance_valid(mine) and is_instance_valid(after):
		after.target = mine
		after.global_position = mine.global_position + Vector2(60, 0)
		var repeat: MoveData = mine.moves.moves[0]
		for i in 5:
			arena._memory.note_move(mine.instance, repeat, true)
		var was: float = after.moves.dodge_cooldown
		after.mind._watching = mine
		after.mind._on_move(repeat)
		# (la lectura se usa en cuanto puede actuar: si justo estaba rodando o dando un paso al costado, un poco después)
		await _until(func(): return not is_instance_valid(after) or after.mind._read_dodge_at < 0.0 or after.moves.dodge_cooldown > was, 1.0)
		r["Repetís el ataque: esquiva antes (Alto Mando)"] = is_instance_valid(after) and (after.moves.dodge_cooldown > was or after.mind._read_dodge_at < 0.0)
		after.mind._watching = null
	await _finish(arena)
	GameState.party.resize(1)
	GameState.set_active(0)
	world.respawn_companion()
	await get_tree().physics_frame

	# Elegir ataque con los stats
	var thinker: Creature = autotest._dummy(world, "abra", world.companion.global_position + Vector2(60, 0))
	await get_tree().physics_frame
	thinker.target = world.companion
	r["Elige por stats: Abra rinde más con ataques especiales"] = thinker.mind.stat_edge(special, world.companion) > thinker.mind.stat_edge(physical, world.companion)
	var wild_reads: float = thinker.mind.reads()
	r["Los salvajes no estudian qué repetís"] = wild_reads == 0.0
	thinker.queue_free()
	await get_tree().physics_frame


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


## Avanza solos los diálogos (los premios después de ganarle a un líder).
func _dialogs() -> void:
	while is_inside_tree():
		await get_tree().create_timer(0.12).timeout
		var d: DialogBox = world.story.dialog
		if d.active:
			if d._choosing:
				d.choose(0)
			else:
				d.advance()
