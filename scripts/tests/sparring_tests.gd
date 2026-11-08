class_name SparringTests
extends Node
## Autotest de la grabación de peleas para entrenar la IA (S-1, docs/PLAN_SPARRING_IA.md): sin el ajuste no graba; con
## la consola GM (`sparring`) o el ajuste prendido graba muestras, hechos y marcas en user://sparring/ y el JSON tiene lo
## que espera el informe (S-2).
##   godot --headless --path . --quit-after 30000 -- --autotest-sparring

var autotest: Node
var world: Node
var r := {}


func run() -> void:
	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	var me := GameState.active()
	me.level = 30
	me.hp = me.max_hp()
	world.respawn_companion()
	await get_tree().physics_frame
	var rec: SparringRecorder = world.sparring
	r["El mundo tiene el grabador y arranca apagado"] = rec != null and not rec.recording and not rec.armed \
		and GameState.setting("record_fights") == false

	# --- Sin el ajuste ni la consola: no graba ---
	await _fight(0.6)
	r["Sin el ajuste no graba"] = not rec.recording and rec.last_file == ""
	await _finish()

	# --- Desde la consola GM: graba una pelea entera ---
	var gm := GmCommands.new(world)
	var answer := gm.run("sparring")
	r["La consola arma la pelea para grabar (\"%s\")" % answer.substr(0, 40)] = rec.armed and "Grabando" in answer
	await _until(func(): return world.arena.active and world.arena._fighting, 10.0)
	r["Graba mientras se pelea"] = rec.recording
	var mon: Creature = world.companion
	mon.moves.slots[0] = DB.moves["pistola_agua"]
	var t := 0.0
	var shoot := 0.0
	var marked := false
	while t < 2.5 and world.arena.active and is_instance_valid(world.arena.foe):
		shoot -= get_physics_process_delta_time()
		if shoot <= 0.0 and is_instance_valid(mon) and is_instance_valid(world.arena.foe):
			shoot = 0.45
			mon.moves.reset_cooldown(0)
			mon.moves.set_pp(mon.moves.max_pp())
			mon.use_slot(0, (world.arena.foe.global_position - mon.global_position).normalized())
		if t > 1.0 and not marked:
			marked = true
			rec.mark()
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	var samples_live: int = rec.data.get("samples", []).size()
	await _finish()
	r["Al terminar guarda el archivo y se apaga"] = rec.last_file != "" and FileAccess.file_exists(rec.last_file) \
		and not rec.recording and not rec.armed
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(rec.last_file)) if rec.last_file != "" else null
	var ok_json: bool = parsed is Dictionary
	r["El JSON se lee"] = ok_json
	if ok_json:
		var d: Dictionary = parsed
		var samples: Array = d.get("samples", [])
		var events: Array = d.get("events", [])
		var kinds := events.map(func(e): return e.k)
		r["Cabecera: versión, fecha, dificultad, arena, entrenador, tu Pokémon y el equipo rival"] = int(d.get("version", 0)) == SparringRecorder.VERSION \
			and str(d.get("date", "")) != "" and str(d.get("difficulty", "")) != "" and str(d.get("arena", "")) != "" \
			and str(d.get("trainer", "")) != "" and d.get("me", {}).get("species", "") == "squirtle" \
			and d.get("foe_team", []).size() == 3 and d.get("result", "") == "win" and float(d.get("duration", 0.0)) > 2.0
		r["Muestras: 10 por segundo, con todas las columnas (%d muestras, %d en vivo)" % [samples.size(), samples_live]] = samples.size() >= 15 \
			and samples.size() <= 40 and samples.all(func(s): return s.size() == SparringRecorder.COLUMNS.size()) \
			and d.get("columns", []).size() == SparringRecorder.COLUMNS.size()
		var ci := SparringRecorder.COLUMNS.find("dist")
		var cs := SparringRecorder.COLUMNS.find("foe_state")
		r["Las muestras traen distancia y estado del rival con sentido"] = not samples.is_empty() \
			and samples.all(func(s): return float(s[ci]) > 0.0 and str(s[cs]) != "")
		r["Hechos: tus ataques, golpes al rival, la salida de su Pokémon y la marca (%s)" % str(kinds.slice(0, 8))] = \
			"use" in kinds and "hit" in kinds and "send" in kinds and d.get("marks", []).size() == 1 \
			and events.filter(func(e): return e.k == "use" and e.who == "me" and e.move == "pistola_agua").size() >= 3 \
			and events.filter(func(e): return e.k == "hit" and e.who == "foe").all(func(e): return e.has("closing") and e.has("hp"))

	# --- Con el ajuste prendido también graba (y se apaga con el ajuste) ---
	GameState.set_setting("record_fights", true)
	r["El ajuste se guarda con la partida"] = GameState.to_dict().get("settings", {}).get("record_fights", false) == true
	var before := rec.last_file
	await _fight(0.8)
	r["Con el ajuste prendido graba"] = rec.recording
	await _finish()
	r["...y guarda otro archivo"] = rec.last_file != before and rec.last_file != ""
	GameState.set_setting("record_fights", false)
	await _fight(0.5)
	r["Apagado el ajuste, no graba"] = not rec.recording
	await _finish()
	_results()


## Una pelea de prueba contra un entrenador con 3 Pokémon, hasta `seconds` después de que empieza de verdad.
func _fight(seconds: float) -> void:
	var team: Array[CreatureInstance] = []
	for sp in ["rattata", "pidgey", "caterpie"]:
		team.append(CreatureInstance.create_rival(DB.species[sp], 12))
	world.arena.start({"name": "Tincho", "title": "Entrenador", "team": team, "no_blackout": true})
	await _until(func(): return world.arena.active and world.arena._fighting, 10.0)
	await get_tree().create_timer(seconds).timeout


func _finish() -> void:
	if world.arena.active:
		world.arena._end("win")
	await _until(func(): return not world.arena.active, 10.0)
	GameState.heal_party()
	world.respawn_companion()
	await get_tree().physics_frame


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func _results() -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[sparring] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-sparring] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
