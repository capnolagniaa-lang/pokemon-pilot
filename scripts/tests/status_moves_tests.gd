class_name StatusMovesTests
extends Node
## Autotest de los ataques de estado que antes no hacían nada (2026-11-03): los que bajan stats dejan su estado,
## Drenadoras le saca vida al rival y te la pasa (no a los tipo Planta), los que todavía no hacen nada
## (MoveData.does_nothing) no los usa la IA, el equipamiento de fábrica los deja para el final y la descripción lo dice.
##   godot --headless --path . --quit-after 30000 -- --autotest-status-moves

const LOWERS := {"agitacola": ["expuesto"], "dulce_aroma": ["expuesto"], "chirrido": ["muy_expuesto"],
	"llanto_falso": ["muy_expuesto"], "eco_metalico": ["muy_expuesto"], "encanto": ["muy_intimidado"],
	"danza_pluma": ["muy_intimidado"], "cosquillas": ["intimidado", "expuesto"], "cara_susto": ["frenado"],
	"esporagodon": ["frenado"], "destello": ["desorientado"], "drenadoras": ["drenado"], "atraccion": ["enamorado"],
	"mofa": ["mofado"], "tormento": ["atormentado"], "rastreo": ["descubierto"], "profecia": ["descubierto"],
	"telepata": ["descubierto"], "mal_de_ojo": ["atrapado"], "bloqueo": ["atrapado"]}

var autotest: Node


func _small_mechanics(_world: Node, me: Creature, dummy: Creature) -> Dictionary:
	var r := {}
	dummy.statuses.clear()
	dummy.statuses.apply(DB.statuses["pesadilla"])
	r["Pesadilla no prende en uno despierto"] = not dummy.statuses.has_status("pesadilla")
	dummy.statuses.apply(DB.statuses["dormido"])
	dummy.statuses.apply(DB.statuses["pesadilla"])
	var hp0 := dummy.instance.hp
	var had := dummy.statuses.has_status("pesadilla")
	for i in 130:
		await get_tree().physics_frame
	r["Dormido, la pesadilla le saca vida"] = had and dummy.instance.hp < hp0
	dummy.statuses.cure(DB.statuses["dormido"])
	for i in 3:
		await get_tree().physics_frame
	r["Al despertarse se va"] = not dummy.statuses.has_status("pesadilla")

	GameState.set_setting("pp_mode", true)
	dummy.moves.set_pp(dummy.moves.max_pp())
	_use(me, "rencor", dummy)
	for i in 10:
		await get_tree().physics_frame
	r["Rencor le saca PP"] = dummy.moves.pp() <= dummy.moves.max_pp() * 0.75
	GameState.set_setting("pp_mode", false)

	dummy.instance.hp = dummy.health.max_hp()
	me.instance.hp = minf(me.health.max_hp(), 20.0)
	var total := dummy.instance.hp + me.instance.hp
	_use(me, "divide_dolor", dummy)
	for i in 40:
		await get_tree().physics_frame
	r["Divide Dolor: promedio de vida"] = dummy.instance.hp < total and dummy.instance.hp <= total * 0.5 + 1.0

	dummy.statuses.clear()
	dummy.moves.slots[0] = DB.moves["gruñido"] if DB.moves.has("gruñido") else DB.moves["grunido"]
	dummy.moves.slots[1] = DB.moves["placaje"]
	dummy.moves.gap_left = 0.0
	dummy.moves.reset_cooldown(0)
	dummy.moves.reset_cooldown(1)
	dummy.statuses.apply(DB.statuses["mofado"])
	r["Mofa: no usa ataques de estado, sí los de daño"] = not dummy.moves.can_use(0) and dummy.moves.can_use(1)
	dummy.statuses.clear()
	dummy.statuses.apply(DB.statuses["atormentado"])
	dummy.moves.last_used = 1
	r["Tormento: no repite el mismo"] = not dummy.moves.can_use(1) and dummy.moves.can_use(0)
	dummy.statuses.clear()
	dummy.statuses.apply(DB.statuses["descubierto"])
	r["Descubierto: no puede esquivar"] = not dummy.dodge(Vector2.RIGHT)
	dummy.statuses.clear()
	me.statuses.apply(DB.statuses["atrapado"])
	r["Atrapado: no te podés cambiar"] = me.statuses.flag("traps")
	me.statuses.clear()
	return r


func _weather(me: Creature, dummy: Creature) -> Dictionary:
	var r := {}
	var water: ElementType = DB.types["agua"]
	var fire: ElementType = DB.types["fuego"]
	me.moves.slots[1] = DB.moves["danza_lluvia"]
	me.moves.reset_cooldown(1)
	me.moves.gap_left = 0.0
	me.use_slot(1, Vector2.RIGHT, dummy.global_position)
	await get_tree().physics_frame
	r["Danza Lluvia larga el clima: Agua ×1,5, Fuego ×0,5"] = CombatWeather.current == "lluvia" \
		and CombatWeather.damage_mult(water) == 1.5 and CombatWeather.damage_mult(fire) == 0.5
	me.target = dummy
	for i in 140:
		await get_tree().physics_frame
	r["La lluvia moja a los que pelean"] = dummy.statuses.has_status("empapado")
	CombatWeather.stop(get_tree())
	r["Al cortarse, todo vuelve a lo normal"] = CombatWeather.damage_mult(water) == 1.0

	CombatWeather.start("granizo", me)
	var hp0 := dummy.instance.hp
	var me0 := me.instance.hp
	for i in 130:
		await get_tree().physics_frame
	r["Granizo lastima a los que pelean"] = dummy.instance.hp < hp0 and me.instance.hp < me0
	CombatWeather.stop(get_tree())

	var ice := CreatureInstance.create(DB.species["articuno"], 30)
	var fake := autotest._dummy(me.get_parent().get_parent() if false else get_tree().get_first_node_in_group("world"), "articuno", me.global_position + Vector2(0, 60)) as Creature
	CombatWeather.start("granizo", me)
	r["Al tipo Hielo el granizo no le hace nada"] = not CombatWeather.hurts(fake) and CombatWeather.hurts(me) and ice != null
	CombatWeather.stop(get_tree())

	me.moves.slots[1] = DB.moves["danza_lluvia"]
	me.moves.slots[0] = DB.moves["ascuas"] if DB.moves.has("ascuas") else null
	me.moves.slots[2] = null
	me.moves.slots[3] = null
	r["La IA no larga lluvia si no tiene ataques de agua"] = CombatWeather.value_for("lluvia", me, dummy) == 0.0
	r["Sí larga sol si tiene ataques de fuego"] = CombatWeather.value_for("sol", me, dummy) > 0.0
	r["Hay descripción de clima"] = MoveInfo.what_it_does(DB.moves["granizo"]).contains("Graniza")
	return r


## Vitrina: los 4 climas, 2 s cada uno (--showcase-weather).
func showcase() -> void:
	var world: Node = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	autotest._dummy(world, "snorlax", me.global_position + Vector2(40, 0))
	for kind in ["lluvia", "sol", "granizo", "arena"]:
		CombatWeather.start(kind, me)
		for i in 60:
			await get_tree().process_frame
	get_tree().quit()


func _use(me: Creature, id: String, dummy: Creature) -> void:
	dummy.global_position = me.global_position + Vector2(30, 0)
	me.moves.slots[1] = DB.moves[id]
	me.moves.reset_cooldown(1)
	me.moves.gap_left = 0.0
	me.use_slot(1, Vector2.RIGHT, dummy.global_position)


func run() -> void:
	var r := {}
	var world: Node = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	GameState.set_setting("pp_mode", false)
	var dummy: Creature = autotest._dummy(world, "snorlax", me.global_position + Vector2(30, 0))
	var missing: Array[String] = []
	for id in LOWERS:
		var m: MoveData = DB.moves[id]
		dummy.statuses.clear()
		dummy.global_position = me.global_position + Vector2(30, 0)
		me.moves.slots[1] = m
		me.moves.reset_cooldown(1)
		me.moves.gap_left = 0.0
		me.use_slot(1, Vector2.RIGHT, dummy.global_position)
		for i in 60:
			await get_tree().physics_frame
		for sid in LOWERS[id]:
			if not dummy.statuses.has_status(sid):
				missing.append("%s → %s" % [id, sid])
	r["Los que bajan stats dejan su estado (%s)" % ", ".join(missing)] = missing.is_empty()

	dummy.statuses.clear()
	dummy.instance.hp = dummy.instance.max_hp()
	var room := me.health.max_hp() - 1.0
	me.instance.hp = 1.0
	dummy.statuses.apply(DB.statuses["drenado"], 1.0, me)
	for i in 70:  # (el primer número puede traer daño por tiempo de antes)
		await get_tree().physics_frame
	var hp0 := dummy.instance.hp
	var me0 := me.instance.hp
	for i in 180:  # 3 s más
		await get_tree().physics_frame
	var lost := hp0 - dummy.instance.hp
	var healed := me.instance.hp - me0
	r["Drenadoras: le saca vida (%.0f) y te la pasa (%.0f)" % [lost, healed]] = lost > 0.0 and absf(minf(lost, room) - healed) < 1.0
	var plant: Creature = autotest._dummy(world, "bulbasaur", me.global_position + Vector2(0, 40))
	plant.statuses.apply(DB.statuses["drenado"], 1.0, me)
	r["A los tipo Planta no les prende"] = not plant.statuses.has_status("drenado")

	r.merge(await _small_mechanics(world, me, dummy))
	r.merge(await _weather(me, dummy))
	var noop: Array = DB.moves.values().filter(func(m: MoveData): return m.does_nothing())
	r["Quedan %d ataques sin efecto (ninguno de los arreglados ni Aguante/Teletransporte)" % noop.size()] = \
		noop.size() > 20 and noop.all(func(m): return m.id not in LOWERS and m.id not in ["aguante", "teletransporte", "salpicadura"])
	r["La descripción lo dice"] = MoveInfo.what_it_does(DB.moves["sustituto"]).begins_with("Todavía no") \
		and MoveInfo.what_it_does(DB.moves["drenadoras"]).contains("te la pasa") \
		and MoveInfo.what_it_does(DB.moves["chirrido"]).contains("45 %")

	me.moves.slots[1] = DB.moves["sustituto"]
	me.target = dummy
	r["La IA no usa los que no hacen nada"] = me.mind.score(1, 20.0, true) == 0.0
	dummy.statuses.apply(DB.statuses["expuesto"])
	me.moves.slots[1] = DB.moves["agitacola"]
	r["Ni repite uno que ya dejó su estado"] = me.mind.score(1, 20.0, true) == 0.0

	var bad: Array[String] = []
	for sp_id in ["clefairy", "cloyster", "lapras", "chansey", "kakuna"]:
		var inst := CreatureInstance.create(DB.species[sp_id], 40)
		var useful := inst.equipped_moves.filter(func(m): return m != null and not m.does_nothing()).size()
		var known := inst.species.learnset_entries().filter(func(e): return e.level <= 40 and e.move != null \
			and not e.move.does_nothing()).map(func(e): return e.move)
		var distinct := {}
		for m in known:
			distinct[m] = true
		if useful < mini(4, distinct.size()):
			bad.append("%s (%d)" % [sp_id, useful])
	r["El equipamiento de fábrica trae los que sí hacen algo (%s)" % ", ".join(bad)] = bad.is_empty()
	var ditto := CreatureInstance.create(DB.species["ditto"], 40)
	r["Si no tiene otra cosa, igual lleva el que tiene (Ditto)"] = ditto.equipped_moves.has(DB.moves["transformacion"])

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[estado] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-status-moves] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)
