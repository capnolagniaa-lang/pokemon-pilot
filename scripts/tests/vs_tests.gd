class_name VsTests
extends Node
## Pantalla VS antes de las peleas importantes (VsScreen):
##   godot --headless --path . --quit-after 20000 -- --autotest-vs
## Vitrina (Brock, Misty y el rival):
##   godot --path . --quit-after 330 --write-movie out/f.png --fixed-fps 30 -- --showcase-vs

const IMPORTANT := ["brock", "misty", "lt_surge", "erika", "koga", "sabrina", "blaine", "giovanni", "lorelei", "bruno",
	"agatha", "lance", "blue"]

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	var missing := IMPORTANT.filter(func(g): return not VsScreen.has_portrait(g))
	r["Hay retrato VS de los líderes, el Alto Mando y el rival (faltan: %s)" % ", ".join(missing)] = missing.is_empty()
	r["Y el tuyo"] = VsScreen.has_portrait(VsScreen.PLAYER)
	var leaders := DB.npcs.values().filter(func(n): return n.trainer != null and n.trainer.leader)
	var without := leaders.filter(func(n): return not VsScreen.has_portrait(n.gfx)).map(func(n): return n.id)
	r["Todo líder o miembro del Alto Mando tiene VS (sin: %s)" % ", ".join(without)] = without.is_empty() and leaders.size() >= 12
	r["Un entrenador común no tiene VS"] = not VsScreen.has_portrait("youngster") and not VsScreen.has_portrait("")
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	var t0 := Time.get_ticks_msec()
	await VsScreen.play(world, "brock", "Brock", "Líder", Color(0.7, 0.6, 0.4))
	var took := (Time.get_ticks_msec() - t0) / 1000.0
	await get_tree().process_frame
	r["La pantalla VS dura unos segundos y se cierra (%.1f s)" % took] = took > 1.5 and took < 5.0 \
		and world.get_children().filter(func(n): return n is VsScreen).is_empty()
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[vs] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-vs] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	for f in [["brock", "Brock", "Líder", Color(0.72, 0.62, 0.38)], ["misty", "Misty", "Líder", Color(0.35, 0.55, 0.95)],
			["blue", "Azul", "Rival", Color(0.62, 0.42, 0.9)]]:
		var first := Engine.get_frames_drawn()
		await VsScreen.play(world, f[0], f[1], f[2], f[3])
		print("[showcase-vs] %s: cuadros %d-%d" % [f[0], first, Engine.get_frames_drawn()])
	get_tree().quit()
