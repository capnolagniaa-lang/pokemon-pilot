class_name StatusMovesTests
extends Node
## Autotest de los ataques de estado que antes no hacían nada (2026-11-03): los que bajan stats dejan su estado,
## Drenadoras le saca vida al rival y te la pasa (no a los tipo Planta), los que todavía no hacen nada
## (MoveData.does_nothing) no los usa la IA, el equipamiento de fábrica los deja para el final y la descripción lo dice.
##   godot --headless --path . --quit-after 30000 -- --autotest-status-moves

const LOWERS := {"agitacola": ["expuesto"], "dulce_aroma": ["expuesto"], "chirrido": ["muy_expuesto"],
	"llanto_falso": ["muy_expuesto"], "eco_metalico": ["muy_expuesto"], "encanto": ["muy_intimidado"],
	"danza_pluma": ["muy_intimidado"], "cosquillas": ["intimidado", "expuesto"], "cara_susto": ["frenado"],
	"esporagodon": ["frenado"], "destello": ["desorientado"], "drenadoras": ["drenado"]}

var autotest: Node


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

	var noop: Array = DB.moves.values().filter(func(m: MoveData): return m.does_nothing())
	r["Quedan %d ataques sin efecto (ninguno de los arreglados ni Aguante/Teletransporte)" % noop.size()] = \
		noop.size() > 30 and noop.all(func(m): return m.id not in LOWERS and m.id not in ["aguante", "teletransporte", "salpicadura"])
	r["La descripción lo dice"] = MoveInfo.what_it_does(DB.moves["danza_lluvia"]).begins_with("Todavía no") \
		and MoveInfo.what_it_does(DB.moves["drenadoras"]).contains("te la pasa") \
		and MoveInfo.what_it_does(DB.moves["chirrido"]).contains("45 %")

	me.moves.slots[1] = DB.moves["danza_lluvia"]
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
