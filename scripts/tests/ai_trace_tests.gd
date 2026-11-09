class_name AiTraceTests
extends Node
## Autotest de la Fase 1 de la IA nueva (docs/IA_AUDITORIA.md): registro de decisiones (`AiTrace`), overlay y métricas
## por pelea (`AiFightStats`, `AiDebug`), y que el JSON de sparring las guarde.
##   godot --headless --path . --quit-after 60000 -- --autotest-ai-trace
##   godot --path . --quit-after 240 --write-movie out/f.png --fixed-fps 30 -- --showcase-ai-overlay  (el overlay en una pelea; `--new-brain` = con la IA nueva)

var autotest: Node
var world: Node
var r := {}
var seen: Array[String] = []  # decisiones del rival que pasaron por Events.ai_decided


func run() -> void:
	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	var me := GameState.active()
	me.level = 30
	me.hp = me.max_hp()
	world.respawn_companion()
	await get_tree().physics_frame
	var dbg: AiDebug = world.ai_debug
	r["El mundo tiene AiDebug, con todo apagado"] = dbg != null and not AiTrace.log_on and not AiTrace.overlay_on \
		and not AiTrace.measuring and not AiTrace.enabled() and not dbg._layer.visible
	_stats_unit()

	# --- Apagado no anota nada ---
	Events.ai_decided.connect(_on_decided)
	AiTrace.note(world.companion, "prueba", {})
	r["Apagado, AiTrace.note no avisa"] = seen.is_empty()

	# --- La consola prende el overlay y el registro ---
	var gm := GmCommands.new(world)
	var a1 := gm.run("ia ver")
	var a2 := gm.run("ia log")
	r["`ia ver` prende el overlay (\"%s\")" % a1] = AiTrace.overlay_on and dbg._layer.visible
	r["`ia log` prende el registro (\"%s\")" % a2.substr(0, 60)] = AiTrace.log_on and dbg.log_path != ""
	r["`ia` sola dice cómo está"] = "Overlay prendido" in gm.run("ia")
	r["Sin rival, el overlay lo dice"] = "no hay rival" in dbg.overlay_text()

	# --- Una pelea de arena grabada, disparándole ---
	world.sparring.armed = true
	await _fight(["rattata", "pidgey", "caterpie"])
	r["En la pelea se mide"] = AiTrace.measuring and dbg.fighting
	var mon: Creature = world.companion
	mon.moves.slots[0] = DB.moves["pistola_agua"]
	var t := 0.0
	var shoot := 0.0
	var text := ""
	while t < 4.0 and world.arena.active and is_instance_valid(world.arena.foe):
		shoot -= get_physics_process_delta_time()
		if shoot <= 0.0 and is_instance_valid(mon) and is_instance_valid(world.arena.foe):
			shoot = 0.5
			mon.moves.reset_cooldown(0)
			mon.moves.set_pp(mon.moves.max_pp())
			mon.use_slot(0, (world.arena.foe.global_position - mon.global_position).normalized())
		if t > 2.0 and text == "" and is_instance_valid(world.arena.foe):
			text = dbg.overlay_text()  # (en plena pelea)
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	r["Overlay: situación, amenaza, top 3, lo que te lee y la pelea"] = "Situación:" in text and "Amenaza:" in text \
		and "Top:" in text and "Te lee:" in text and "Pelea:" in text
	r["Decisiones del rival anotadas (%s)" % ", ".join(_unique(seen))] = "saca" in seen and ("modo" in seen or "ataque" in seen or "aviso" in seen)
	var with_top := _decisions.filter(func(d): return d.what in ["ataque", "aviso", "juntar"] and d.has("top"))
	if with_top.is_empty():
		r["Algún ataque elegido con top"] = false
	else:
		var tops: Array = with_top[0].top
		r["Un ataque elegido trae su top (%s)" % ", ".join(tops)] = tops.size() >= 1 and tops.size() <= 3
	var live := dbg.stats.to_dict()
	r["Métricas en vivo: tu daño y tus ataques (%.2f, %d)" % [live.dano_hecho_vos, live.ataques_vos]] = float(live.dano_hecho_vos) > 0.0 \
		and int(live.ataques_vos) >= 4 and float(live.duracion) > 2.0
	r["Métricas: modos del rival con tiempo"] = not (live.modos_ia as Dictionary).is_empty()

	# --- Cambio forzado: un mal cruce y uno bueno en el banco ---
	await _finish()
	await _fight(["charmander", "oddish"])
	var arena: TrainerBattle = world.arena
	arena.style = arena.style.duplicate()
	arena.style.switch_types = 1.0
	arena.style.max_switches = 2
	arena._entered_at = arena._clock - 10.0
	arena._last_switch = -100.0
	var switched: bool = arena._maybe_switch()
	r["El entrenador cambia por tipos y se anota (Charmander → Oddish)"] = switched and "cambio" in seen
	r["...y cuenta como cambio bueno"] = dbg.stats.switches == 1 and dbg.stats.switches_good == 1
	await _finish()
	r["Al terminar quedan las métricas de la pelea"] = dbg.last_stats.has("castigos_ia") and dbg.last_stats.get("cambios_ia", 0) == 1 \
		and dbg.last_stats.get("resultado", "") == "win" and not AiTrace.measuring

	# --- El registro y el JSON de sparring ---
	var log_text := FileAccess.get_file_as_string(dbg.log_path) if dbg.log_path != "" else ""
	r["El registro tiene las decisiones y el resumen"] = "saca" in log_text and "cambio" in log_text and "=== Terminó" in log_text
	var rec: SparringRecorder = world.sparring
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(rec.last_file)) if rec.last_file != "" else null
	# (el archivo es el de la primera pelea, la que estaba armada)
	var files := DirAccess.get_files_at(SparringRecorder.DIR)
	r["La pelea armada se grabó"] = parsed is Dictionary or not files.is_empty()
	if parsed is Dictionary:
		var d: Dictionary = parsed
		r["El JSON de sparring trae las métricas (versión %d)" % int(d.get("version", 0))] = int(d.get("version", 0)) == SparringRecorder.VERSION \
			and (d.get("metrics", {}) as Dictionary).has("dano_hecho_vos")
		r["...y las decisiones del rival como hechos \"ia\""] = (d.get("events", []) as Array).any(func(e): return e.get("k", "") == "ia")

	# --- Apagar ---
	gm.run("ia ver")
	gm.run("ia log")
	r["Se apagan los dos"] = not AiTrace.overlay_on and not AiTrace.log_on and not dbg._layer.visible and not AiTrace.enabled()
	_results()


## Vitrina: una pelea de arena con el overlay prendido, disparándole al rival.
func showcase() -> void:
	world = await autotest._setup_kit_world("squirtle")
	world.combat.end_battle()
	GameState.active().level = 30
	GameState.active().hp = GameState.active().max_hp()
	world.respawn_companion()
	await get_tree().physics_frame
	world.ai_debug.set_overlay(true)
	if "--new-brain" in OS.get_cmdline_user_args():
		GameState.set_setting("ai_brain_new", true)  # (con la IA nueva de entrenadores)
	await _fight(["rattata", "pidgey", "caterpie"])
	var shoot := 0.0
	while true:
		var mon: Creature = world.companion
		shoot -= get_physics_process_delta_time()
		if shoot <= 0.0 and is_instance_valid(mon) and world.arena.active and is_instance_valid(world.arena.foe):
			shoot = 0.7
			mon.moves.slots[0] = DB.moves["pistola_agua"]
			mon.moves.reset_cooldown(0)
			mon.moves.set_pp(mon.moves.max_pp())
			mon.use_slot(0, (world.arena.foe.global_position - mon.global_position).normalized())
		await get_tree().physics_frame


## AiFightStats con números armados: castigos hechos y perdidos, ventanas cortas, cambios y repetición.
func _stats_unit() -> void:
	var s := AiFightStats.new()
	for i in 5:
		s.tick(0.1, false, true, true, false)  # tu ventana, la IA puede pegarte
	s.on_hit("vos", 0.2)
	for i in 3:
		s.tick(0.1, false, false, true, false)
	r["Le pega en tu ventana: castigo hecho"] = s.punished["ia"] == 1 and s.missed["ia"] == 0
	for i in 6:
		s.tick(0.1, false, true, true, false)
	for i in 3:
		s.tick(0.1, false, false, true, false)
	r["Ventana larga sin pegarte pudiendo: castigo perdido"] = s.missed["ia"] == 1
	for i in 2:
		s.tick(0.1, false, true, true, false)
	for i in 3:
		s.tick(0.1, false, false, true, false)
	r["Ventana corta: no cuenta"] = s.missed["ia"] == 1 and s.punished["ia"] == 1
	for i in 6:
		s.tick(0.1, false, true, false, false)
	for i in 3:
		s.tick(0.1, false, false, false, false)
	r["Sin nada que llegue: no cuenta como perdido"] = s.missed["ia"] == 1
	s.on_hit("vos", 0.05)
	for i in 4:
		s.tick(0.1, true, false, false, true)
	s.on_hit("ia", 0.1)
	s.tick(0.2, false, false, false, true)
	r["Vos castigás la ventana de la IA"] = s.punished["vos"] == 1
	s.on_decision("cambio", {"cruce": 0.6, "nuevo": 1.8})
	s.on_decision("cambio", {"cruce": 0.9, "nuevo": 0.7})
	r["Cambios buenos y malos"] = s.switches == 2 and s.switches_good == 1
	for m in ["Placaje", "Placaje", "Placaje", "Látigo"]:
		s.on_use("ia", m)
	var rep := s.repetition()
	r["Repetición: más usado 75 %%, racha 3 (%s)" % str(rep)] = is_equal_approx(float(rep.mas_usado), 0.75) and int(rep.racha) == 3 \
		and float(rep.variedad) > 0.0 and float(rep.variedad) < 1.0
	var same := AiFightStats.new()
	for i in 4:
		same.on_use("ia", "Placaje")
	r["Siempre el mismo: variedad 0"] = float(same.repetition().variedad) == 0.0 and float(same.repetition().par_repetido) == 1.0
	r["Daño en vidas"] = is_equal_approx(s.damage["ia"], 0.25) and is_equal_approx(s.damage["vos"], 0.1)


var _decisions: Array[Dictionary] = []


func _on_decided(actor: Node, what: String, data: Dictionary) -> void:
	if world.arena != null and actor == world.arena.foe or what == "saca" or what == "prueba":
		seen.append(what)
		_decisions.append(data)


func _unique(a: Array) -> Array:
	var out := []
	for x in a:
		if not x in out:
			out.append(x)
	return out


func _fight(species: Array) -> void:
	var team: Array[CreatureInstance] = []
	for sp in species:
		team.append(CreatureInstance.create_rival(DB.species[sp], 26))
	world.arena.start({"name": "Tincho", "title": "Entrenador", "team": team, "no_blackout": true})
	await _until(func(): return world.arena.active and world.arena._fighting, 10.0)
	await get_tree().create_timer(0.3).timeout


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
		print("[ai-trace] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-ai-trace] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
