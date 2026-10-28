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
