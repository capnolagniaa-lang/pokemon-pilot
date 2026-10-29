class_name AbilitiesTests
extends Node
## Autotest de las habilidades (decisión del usuario 2026-10-28: la identidad sale de la habilidad de los juegos, el
## tipo y los ataques que elegís; los ataques se comportan igual para todos; kit de jefe solo con los líderes).
##   godot --headless --path . --quit-after 30000 -- --autotest-abilities

var autotest: Node
var world: Node
var me: Creature


func run() -> void:
	var r := {}
	# --- Datos ---
	var kanto := DB.species.values().filter(func(s): return s.dex <= 151)
	var without := kanto.filter(func(s): return s.abilities.is_empty()).map(func(s): return s.id)
	r["Los 151 de Kanto tienen habilidad %s" % str(without.slice(0, 5))] = without.is_empty()
	r["Están las 76 habilidades de 3ª gen, todas con mecánica"] = DB.abilities.size() >= 76 \
		and DB.abilities.values().all(func(a): return a.mechanic_script != null)
	r["Habilidades de los juegos: Gengar Levitación, Onix Cabeza Roca o Robustez"] = \
		DB.species["gengar"].abilities.map(func(a): return a.id) == ["levitacion"] \
		and DB.species["onix"].abilities.map(func(a): return a.id) == ["cabeza_roca", "robustez"]
	var with_kit := DB.species.values().filter(func(s): return s.kit != null).size()
	r["Nadie tiene kit; solo Onix, Starmie y Raichu tienen kit de jefe"] = with_kit == 0 \
		and DB.species.values().filter(func(s): return s.boss_kit != null).map(func(s): return s.id).size() == 3 \
		and DB.species["onix"].boss_kit != null and DB.species["starmie"].boss_kit != null and DB.species["raichu"].boss_kit != null
	# --- Cada Pokémon nace con una de las suyas, se guarda, se conserva al evolucionar ---
	var seen := {}
	for i in 40:
		seen[CreatureInstance.create(DB.species["onix"], 20).ability] = true
	r["La habilidad sale al azar entre las de la especie (Onix: %s)" % str(seen.keys())] = seen.size() == 2
	var inst := CreatureInstance.create(DB.species["abra"], 20)
	inst.ability = "fuerza_mental"
	var back := CreatureInstance.from_dict(inst.to_dict())
	r["La habilidad se guarda con la partida"] = back.ability == "fuerza_mental"
	inst.evolve_into(DB.species["kadabra"])
	r["Al evolucionar conserva la del mismo lugar (Abra Fuerza Mental → Kadabra Fuerza Mental)"] = inst.ability == "fuerza_mental"
	# --- Ataques ---
	var ch := CreatureInstance.create(DB.species["charmander"], 31)
	var names := ch.equipped_moves.map(func(m): return m.display_name if m != null else "")
	r["Viene con los últimos 4 por nivel (Charmander 31: %s)" % ", ".join(names)] = \
		names == ["Garra Metal", "Pantalla de Humo", "Cara Susto", "Lanzallamas"]
	r["Puede elegir sus MT (Charmander: Garra Dragón)"] = ch.can_equip(DB.moves["garra_dragon"]) and not ch.can_equip(DB.moves["surf"])
	var old := ch.to_dict()
	old["equipped_moves"] = ["charmander/ascuas_abanico", "", "", ""]
	var migrated := CreatureInstance.from_dict(old)
	r["Partida vieja: el ataque de kit pasa a ser el oficial (Ascuas)"] = migrated.equipped_moves[0] == DB.moves["ascuas"]

	# --- Mecánicas ---
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	var gengar := _spawn("gengar", "levitacion", Vector2(0, -40))
	var hp0: float = gengar.instance.hp
	gengar._on_hit(_hit_from(world.companion, "terremoto"))
	r["Levitación: Terremoto no le hace nada"] = gengar.instance.hp == hp0
	var lapras := _spawn("vaporeon", "absorbe_agua", Vector2(40, -40))
	lapras.instance.hp = lapras.instance.max_hp() * 0.5
	var hp1: float = lapras.instance.hp
	lapras._on_hit(_hit_from(world.companion, "surf"))
	r["Absorbe Agua: Surf lo cura"] = lapras.instance.hp > hp1
	var geo := _spawn("geodude", "robustez", Vector2(-40, -40))
	var huge := _hit_from(world.companion, "lanzallamas")
	huge.damage_mult = 1000.0
	geo._on_hit(huge)
	r["Robustez: con la vida llena aguanta un golpe letal con 1"] = not geo.is_down() and geo.instance.hp <= 1.01
	var abra := _spawn("abra", "fuerza_mental", Vector2(80, -40))
	abra._on_hit(_hit_from(world.companion, "ascuas"))
	r["Fuerza Mental: no sufre stagger"] = abra.hitstun_left == 0.0
	var growl := _spawn("growlithe", "intimidacion", Vector2(-80, -40))
	var foe := _spawn("rattata", "fuga", Vector2(-80, -10))
	growl.target = foe
	await get_tree().create_timer(0.2).timeout
	r["Intimidación: al encarar deja Intimidado al rival"] = foe.statuses.has_status("intimidado")
	var char := _spawn("charmander", "mar_llamas", Vector2(0, 40))
	var full := HitInfo.from(char, DB.moves["ascuas"]).damage_mult
	char.instance.hp = char.instance.max_hp() * 0.2
	var low := HitInfo.from(char, DB.moves["ascuas"]).damage_mult
	r["Mar Llamas: con poca vida el fuego pega ×1,5 (%.2f → %.2f)" % [full, low]] = absf(low / full - 1.5) < 0.01

	# --- Inmunidades de tipo (pedido del usuario 2026-10-28): ni daño, ni estado, ni empuje ---
	for case in [["umbreon", "psiquico", "Siniestro a Psíquico"], ["magnemite", "bomba_lodo", "Acero a Veneno"],
			["clefairy", "dragoaliento", "Hada a Dragón"], ["pidgey", "terremoto", "Volador a Tierra"]]:
		var c := _spawn(case[0], "fuga", Vector2(-120 + 60 * r.size() % 240, 130))
		var hp: float = c.instance.hp
		var h := _hit_from(world.companion, case[1])
		h.extra_status = DB.statuses["envenenado"]
		h.extra_status_chance = 1.0
		c._on_hit(h)
		r["%s: %s no le hace nada" % [case[2], DB.moves[case[1]].display_name]] = c.instance.hp == hp \
			and c.statuses.active.is_empty() and c.knockback == Vector2.ZERO
	var grimer := _spawn("grimer", "fuga", Vector2(-60, 170))
	var bulba := _spawn("bulbasaur", "fuga", Vector2(60, 170))
	grimer.statuses.apply(DB.statuses["envenenado"])
	bulba.statuses.apply(DB.statuses["envenenado"])
	r["Un tipo Veneno no se envenena (Grimer, ni Bulbasaur Planta/Veneno)"] = \
		not grimer.statuses.has_status("envenenado") and not bulba.statuses.has_status("envenenado")
	var rat := _spawn("rattata", "fuga", Vector2(0, 170))
	rat.statuses.apply(DB.statuses["envenenado"])
	r["Un Rattata sí se envenena"] = rat.statuses.has_status("envenenado")

	# --- Iniciales salvajes (pedido del usuario 2026-10-28) ---
	var moon: EncounterTable = load("res://data/world/encounters/mt_moon.tres")
	var forest: EncounterTable = load("res://data/world/encounters/bosque_verde.tres")
	var cerulean: EncounterTable = load("res://data/world/encounters/ciudad_celeste.tres")
	r["Charmander 15% en Mt. Moon"] = is_equal_approx(moon.chances_at(Vector2i.ZERO, PackedStringArray(["suelo"])).get("charmander", 0.0), 0.15)
	r["Bulbasaur 5% en el Bosque Verde"] = is_equal_approx(forest.chances_at(Vector2i.ZERO, PackedStringArray(["pasto_alto"])).get("bulbasaur", 0.0), 0.05)
	r["Squirtle 12% en las flores de Ciudad Celeste"] = is_equal_approx(cerulean.chances_at(Vector2i.ZERO, PackedStringArray(["flores"])).get("squirtle", 0.0), 0.12)

	# --- Abra con Poder Oculto (pedido del usuario 2026-10-28: con Teletransporte solo no ganaba EXP) ---
	var abra5 := CreatureInstance.create(DB.species["abra"], 5)
	r["Abra sale con Poder Oculto equipado"] = abra5.equipped_moves.has(DB.moves["poder_oculto"])

	# --- EXP repartida entre los que pelearon y siguen en pie (pedido del usuario 2026-10-28) ---
	var p1: CreatureInstance = GameState.active()
	var p2 := CreatureInstance.create(DB.species["pidgey"], 10)
	var p3 := CreatureInstance.create(DB.species["rattata"], 10)
	GameState.add_to_party(p2)
	GameState.add_to_party(p3)
	var enemy := _spawn("caterpie", "fuga", Vector2(200, 0))
	world.combat._note_participant(enemy, p2)
	world.combat._note_participant(enemy, p3)
	var shares: Dictionary = world.combat.exp_shares(enemy, 90)
	r["Tres que pelearon: 30 EXP cada uno"] = shares.size() == 3 and shares.values().all(func(v): return v == 30)
	world.combat._note_participant(enemy, p2)
	world.combat._note_participant(enemy, p3)
	p3.hp = 0.0
	shares = world.combat.exp_shares(enemy, 90)
	r["Uno debilitado: no recibe y los otros dos se llevan 45"] = shares.size() == 2 and not shares.has(p3) \
		and shares.get(p1) == 45 and shares.get(p2) == 45
	shares = world.combat.exp_shares(enemy, 90)
	r["Sin nadie más: todo para el que está afuera"] = shares.size() == 1 and shares.get(p1) == 90
	GameState.party.erase(p2)
	GameState.party.erase(p3)
	enemy.queue_free()

	# --- Los que huyen se desparraman (pedido del usuario 2026-10-28) ---
	var threat: Creature = world.companion
	var flock := []
	for i in 5:
		var w := _spawn("pidgey", "fuga", Vector2(90, -15 + 8 * i))
		w.machine.set_physics_process.call_deferred(true)
		flock.append(w)
	await get_tree().physics_frame
	var starts := flock.map(func(w): return w.global_position)
	var threat_at: Vector2 = threat.global_position
	for w in flock:
		w.machine.transition_to("flee", {"from": threat, "calm": true})
	await get_tree().create_timer(1.0).timeout
	var angles := []
	for i in flock.size():
		var d: Vector2 = flock[i].global_position - starts[i]
		if d.length() > 4.0:  # ángulo respecto de "justo en contra de la amenaza"
			angles.append(rad_to_deg((starts[i] - threat_at).angle_to(d)))
	angles.sort()
	var spread: float = angles[-1] - angles[0] if angles.size() > 1 else 0.0
	r["5 que huyen juntos se abren en abanico, sin volver hacia vos (%s)" % str(angles.map(func(a): return roundi(a)))] = 		angles.size() == 5 and spread > 60.0 and angles.all(func(a): return absf(a) < 100.0)

	# --- Jefe de gimnasio ---
	var boss_inst := CreatureInstance.create(DB.species["onix"], 14)
	boss_inst.boss = true
	var boss := _spawn_inst(boss_inst, Vector2(0, 90))
	var wild := _spawn("onix", "robustez", Vector2(60, 90))
	await get_tree().physics_frame
	r["El Onix de un líder pelea con el kit de jefe (Coloso, sus 4 ataques, grande)"] = boss.signature != null \
		and boss.signature.data.id == "coloso" and boss.moves.slots[0] == DB.species["onix"].boss_kit.moves[0] \
		and boss.sprite.scale.x > 1.2
	r["Un Onix salvaje pelea con su habilidad y sus ataques"] = wild.signature != null \
		and wild.signature.data.id == "robustez" and not wild.moves.slots.has(DB.species["onix"].boss_kit.moves[0])

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[abilities] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-abilities] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _spawn(id: String, ability: String, offset: Vector2) -> Creature:
	var inst := CreatureInstance.create(DB.species[id], 30)
	inst.ability = ability
	return _spawn_inst(inst, offset)


func _spawn_inst(inst: CreatureInstance, offset: Vector2) -> Creature:
	var c: Creature = WildSpawner.CreatureScene.instantiate()
	c.instance = inst
	c.team = Creature.Team.WILD
	c.position = world.trainer.global_position + offset
	world.entities.add_child(c)
	c.machine.set_physics_process.call_deferred(false)
	return c


func _hit_from(c: Creature, move_id: String) -> HitInfo:
	return HitInfo.from(c, DB.moves[move_id])
