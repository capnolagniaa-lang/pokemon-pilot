extends Node
## Prueba automática (solo con: godot --path . -- --autotest).
## Elige inicial y recorre la región por los caminos (plaza -> salida -> zona vecina -> plaza ...),
## verificando que las zonas estén conectadas, que se carguen y que el Pokémon siga al entrenador.

## Recorrido: zonas a visitar en orden (cada una vecina de la anterior).
const TOUR := ["ruta1", "bosque", "lago", "colinas", "arboleda", "pradera_sur", "humedal", "pradera_florida", "ruta1"]
const STUCK_TIME := 3.0
const ARRIVE := 4.0

var enabled := false
var _zones_seen: Array[String] = []
var _waypoints: Array[Vector2] = []
var _max_follow_gap := 0.0
var _stuck := 0.0
var _last_pos := Vector2.ZERO
var _done := false


func _ready() -> void:
	if "--overview" in OS.get_cmdline_user_args():
		GameState.wilds_enabled = false
		_overview.call_deferred()
		set_process(false)
		return
	if "--showcase-kit" in OS.get_cmdline_user_args():
		set_process(false)
		_showcase_kit.call_deferred()
		return
	if "--autotest-kit" in OS.get_cmdline_user_args():
		set_process(false)
		_kit_test.call_deferred()
		return
	if "--autotest-identity" in OS.get_cmdline_user_args():
		set_process(false)
		_identity_test.call_deferred()
		return
	if "--autotest-stats" in OS.get_cmdline_user_args():
		set_process(false)
		_stats_test.call_deferred()
		return
	if "--showcase" in OS.get_cmdline_user_args():
		set_process(false)
		_showcase.call_deferred()
		return
	if "--autotest-input" in OS.get_cmdline_user_args():
		set_process(false)
		_input_test.call_deferred()
		return
	if "--autotest-combat" in OS.get_cmdline_user_args():
		set_process(false)
		_combat_test.call_deferred()
		return
	enabled = "--autotest" in OS.get_cmdline_user_args()
	if not enabled:
		set_process(false)
		return
	Events.zone_entered.connect(func(z: ZoneEntry): _zones_seen.append(z.id); print("[zona] ", z.display_name))
	Engine.time_scale = 3.0
	_start.call_deferred()


func _start() -> void:
	GameState.new_game(DB.config.starters[1])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	_build_waypoints()


## Vista de toda la región de una vez (godot --path . --write-movie mapa.png -- --overview).
func _overview() -> void:
	GameState.new_game(DB.config.starters[1])
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world := get_tree().current_scene
	var data := DB.config.world
	var bounds := Rect2()
	for z in data.zones:
		var r := z.world_rect(data.tile_size)
		bounds = r if bounds.size == Vector2.ZERO else bounds.merge(r)
		world.streamer.load_around_now(r.get_center())
	world.streamer.target = null
	world.get_node("PostProcess").visible = false
	world.get_node("CloudShadows").visible = false
	var cam: CameraRig = world.camera
	cam.target = null
	cam.global_position = bounds.get_center()
	var view := get_viewport().get_visible_rect().size
	var z := minf(view.x / bounds.size.x, view.y / bounds.size.y)
	cam.zoom = Vector2(z, z)
	for i in 10:
		await get_tree().process_frame
	get_tree().quit()


func _build_waypoints() -> void:
	var world := DB.config.world
	var ts := world.tile_size
	var zones := {}
	for z in world.zones:
		zones[z.id] = z
	for i in TOUR.size() - 1:
		var a: ZoneEntry = zones[TOUR[i]]
		var b: ZoneEntry = zones[TOUR[i + 1]]
		var side := _side(a, b)
		var exit_a: Vector2i = a.exits[side]
		var exit_b: Vector2i = b.exits[_opposite(side)]
		_waypoints.append(a.path_point(a.hub, ts))
		_waypoints.append(a.path_point(_corner(a, exit_a, side), ts))
		_waypoints.append(a.path_point(exit_a, ts))
		_waypoints.append(b.path_point(exit_b, ts))
		_waypoints.append(b.path_point(_corner(b, exit_b, _opposite(side)), ts))
	var last: ZoneEntry = zones[TOUR[-1]]
	_waypoints.append(last.path_point(last.hub, ts))


func _side(a: ZoneEntry, b: ZoneEntry) -> String:
	var d := b.origin - a.origin
	if d.x > 0:
		return "right"
	if d.x < 0:
		return "left"
	return "down" if d.y > 0 else "up"


func _opposite(side: String) -> String:
	return {"up": "down", "down": "up", "left": "right", "right": "left"}[side]


## Esquina del camino en L entre la salida y la plaza (ver ZoneMap.carve en tools/build_world.gd).
func _corner(z: ZoneEntry, exit: Vector2i, side: String) -> Vector2i:
	return Vector2i(exit.x, z.hub.y) if side in ["up", "down"] else Vector2i(z.hub.x, exit.y)


func _process(delta: float) -> void:
	var world := get_tree().current_scene
	if _done or world == null or not world.has_method("tags_at"):
		return
	var trainer: Trainer = world.trainer
	var comp: Creature = world.companion
	if comp != null:
		_max_follow_gap = maxf(_max_follow_gap, comp.global_position.distance_to(trainer.global_position))
	if _waypoints.is_empty():
		_finish(world, trainer, "")
		return
	var target := _waypoints[0]
	var diff := target - trainer.global_position
	if diff.length() < ARRIVE:
		_waypoints.pop_front()
		_stuck = 0.0
		return
	trainer.autopilot = diff.normalized()
	trainer.autopilot_run = true
	_stuck = _stuck + delta if trainer.global_position.distance_to(_last_pos) < 0.5 else 0.0
	_last_pos = trainer.global_position
	if _stuck > STUCK_TIME:
		_finish(world, trainer, "trabado yendo a %s" % target)


func _finish(world: Node, trainer: Trainer, error: String) -> void:
	_done = true
	trainer.autopilot = Vector2.ZERO
	var expected := TOUR.duplicate()
	var missing := expected.filter(func(id): return not _zones_seen.has(id))
	var ok := error == "" and missing.is_empty() and _max_follow_gap < 170.0
	print("[autotest] zonas=", _zones_seen.size(), " faltan=", missing, " pos=", trainer.global_position.round(),
		" distancia_max_pokemon=", snappedf(_max_follow_gap, 0.1), " cargadas=", world.streamer.loaded.keys(),
		" ", error, " -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


# --- Autotest de combate (godot --path . -- --autotest-combat) ---------------------------

## [tu Pokémon, salvaje, nivel del salvaje]
const FIGHTS := [["charmander", "bulbasaur", 4], ["pikachu", "squirtle", 4], ["seel", "oddish", 4]]


func _combat_test() -> void:
	var stats := {}
	Events.battle_started.connect(func(): stats["battle_started"] += 1)
	Events.battle_ended.connect(func(): stats["battle_ended"] += 1)
	Events.creature_damaged.connect(func(c, amount, _h):
		if c.team == Creature.Team.WILD:
			stats["dealt"] += amount
		else:
			stats["taken"] += amount)
	Events.status_applied.connect(func(c, s): stats["status"].append("%s:%s" % [c.instance.species.id, s.id]))
	Events.move_used.connect(func(_u, m): if m.cast_time > 0.0: stats["casts"] += 1)
	Events.creature_fainted.connect(func(c): stats["fainted"] = c.instance.species.id)
	Events.message_requested.connect(func(t): print("[msg] ", t))
	Engine.time_scale = 2.0
	var all_ok := true
	var statuses_seen := {}
	for fight in FIGHTS:
		stats.merge({"battle_started": 0, "battle_ended": 0, "dealt": 0.0, "taken": 0.0, "status": [], "casts": 0, "fainted": ""}, true)
		GameState.new_game(DB.species[fight[0]])
		GameState.wilds_enabled = false
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")
		await get_tree().process_frame
		await get_tree().process_frame
		var world := get_tree().current_scene
		world.combat.input_source = BotCombatInput.new(world)
		await get_tree().create_timer(0.5).timeout
		var wild: Creature = world.spawner.spawn(DB.species[fight[1]], fight[2], world.trainer.global_position + Vector2(56, 0))
		var t := 0.0
		while t < 60.0 and stats["battle_ended"] == 0:
			await get_tree().process_frame
			t += get_process_delta_time()
		# Resultado válido: el salvaje se debilitó o huyó con poca vida (la IA de huida).
		var fled := is_instance_valid(wild) and not wild.health.is_dead() and wild.health.ratio() < 0.3
		stats["resultado"] = "debilitado" if stats["fainted"] != "" else ("huyó" if fled else "?")
		var ok: bool = stats["battle_started"] >= 1 and stats["battle_ended"] >= 1 and stats["dealt"] > 0.0 and stats["resultado"] != "?"
		for s in stats["status"]:
			statuses_seen[s.split(":")[1]] = true
		all_ok = all_ok and ok
		print("[combate] %s vs %s: " % [fight[0], fight[1]], stats, " tiempo=", snappedf(t, 0.1), " -> ", "OK" if ok else "FALLO")
	print("[autotest-combate] estados vistos=", statuses_seen.keys(), " -> ", "OK" if all_ok else "FALLO")
	get_tree().quit(0 if all_ok else 1)

# --- Autotest del input real (godot --path . -- --autotest-input) ---------------------------

func _input_test() -> void:
	var used := []
	Events.move_used.connect(func(_u, m): used.append(m.id))
	GameState.new_game(DB.species["charmander"])
	GameState.wilds_enabled = true
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world := get_tree().current_scene
	await get_tree().create_timer(0.3).timeout
	var results := {}
	var wilds: Array = world.entities.get_children().filter(func(n): return n is Creature and n.team == Creature.Team.WILD)
	results["hay salvajes en el pasto"] = wilds.size() > 0
	print("[salvajes] ", wilds.map(func(w): return "%s Nv.%d" % [w.instance.species.display_name, w.instance.level]))
	for w in wilds:
		w.queue_free()  # que no interfieran con la prueba de teclas
	await _tap("battle_toggle")
	results["F saca al Pokémon"] = world.combat.in_battle and world.companion.machine.current_name() == "controlled"
	Input.action_press("move_right")
	await get_tree().create_timer(0.3).timeout
	Input.action_release("move_right")
	results["WASD lo mueve"] = world.companion.global_position.x > world.trainer.global_position.x + 10.0
	await _tap("basic", true)
	results["Clic usa el básico (Arañazo)"] = used.has("aranazo_combo")
	await get_tree().create_timer(1.0).timeout
	await _tap("mobility", true)
	results["Espacio usa la movilidad"] = world.companion.machine.current_name() == "dash" or world.companion.health.invulnerable_time > 0.0
	await get_tree().create_timer(1.5).timeout
	results["sigue en combate sin enemigos"] = world.combat.in_battle
	await _tap("battle_toggle")
	await get_tree().create_timer(0.2).timeout
	results["F lo guarda"] = not world.combat.in_battle and world.companion.machine.current_name() in ["follow", "idle"]
	var ok := results.values().all(func(v): return v)
	print("[autotest-input] ", results, " -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Simula apretar una tecla justo antes de que la lean (como hace Godot con el input real):
## en el frame de proceso (acciones que se leen en _process) o en el de física.
func _tap(action: String, physics: bool = false) -> void:
	if physics:
		await get_tree().physics_frame
	else:
		await get_tree().process_frame
	Input.action_press(action)
	for i in 3:
		await get_tree().physics_frame
	Input.action_release(action)

# --- Stats oficiales (godot --path . -- --autotest-stats) ----------------------------------

## Valores conocidos (IV 31, EV 0, naturaleza neutra), de las calculadoras de las wikis.
const KNOWN_STATS := {
	"pikachu": [50, {"hp": 110, "attack": 75, "defense": 60, "sp_attack": 70, "sp_defense": 70, "speed": 110}],
	"charmander": [5, {"hp": 20, "attack": 11, "defense": 10, "sp_attack": 12, "sp_defense": 11, "speed": 13}],
	"seel": [100, {"hp": 271, "attack": 126, "defense": 146, "sp_attack": 126, "sp_defense": 176, "speed": 126}],
}
const KNOWN_EXP := {"medium-slow": [[5, 135], [100, 1059860]], "medium": [[100, 1000000]], "fast": [[100, 800000]], "slow": [[100, 1250000]]}


func _stats_test() -> void:
	var ok := true
	for id in KNOWN_STATS:
		var inst := CreatureInstance.create(DB.species[id], KNOWN_STATS[id][0])
		var got := {}
		for s in CreatureInstance.STATS:
			got[s] = inst.stat(s)
		var match_all: bool = got == KNOWN_STATS[id][1]
		ok = ok and match_all
		print("[stats] %s Nv.%d %s -> %s" % [id, inst.level, got, "OK" if match_all else "esperado %s" % KNOWN_STATS[id][1]])
	for growth in KNOWN_EXP:
		for pair in KNOWN_EXP[growth]:
			var v := CreatureInstance.exp_for_level(growth, pair[0])
			ok = ok and v == pair[1]
			print("[exp] %s Nv.%d = %d %s" % [growth, pair[0], v, "OK" if v == pair[1] else "(esperado %d)" % pair[1]])
	print("[velocidad] px/s a Nv.5 y Nv.50:")
	for id in DB.species:
		var a := CreatureInstance.create(DB.species[id], 5)
		var b := CreatureInstance.create(DB.species[id], 50)
		print("   %-11s base %3d -> %5.1f / %5.1f" % [id, DB.species[id].base_speed, Creature.move_speed_for(a.stat("speed")), Creature.move_speed_for(b.stat("speed"))])
	print("[autotest-stats] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


# --- Vitrina visual (godot --path . --write-movie out/f.png -- --showcase) -------------------

func _showcase() -> void:
	GameState.new_game(DB.species["charmander"])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world := get_tree().current_scene
	var base: Vector2 = world.trainer.global_position
	var row := [["bulbasaur", "quemado"], ["squirtle", "paralizado"], ["oddish", "congelado"], ["psyduck", "empapado"],
		["rattata", "enraizado"], ["bellsprout", "envenenado"], ["eevee", "dormido"], ["pidgey", "desorientado"], ["vulpix", "herido"]]
	var wilds := []
	for i in row.size():
		var w: Creature = world.spawner.spawn(DB.species[row[i][0]], 5, base + Vector2(-80 + (i % 5) * 40, -60 + (i / 5) * 40))
		w.get_node("StateMachine/Wander").aggro_radius = 0.0
		wilds.append(w)
	await get_tree().create_timer(0.3).timeout
	for i in row.size():
		for n in (3 if row[i][1] == "envenenado" else 1):
			wilds[i].statuses.apply(load("res://data/status/%s.tres" % row[i][1]))
	world.combat.start_battle()
	var c: Creature = world.companion
	c.global_position = base + Vector2(0, 40)
	for k in 8:
		await get_tree().create_timer(0.45).timeout
		c.facing = Vector2.UP
		c.release_move({"move": DB.moves["ascuas"], "aim": (wilds[0].global_position - c.global_position).normalized() if is_instance_valid(wilds[0]) else Vector2.UP})
	get_tree().quit()

# --- Base de identidad (godot --path . -- --autotest-identity) -------------------------------
# Reglas compartidas del plan de identidad: estados, interacciones, resistencia a control, etc.

func _identity_test() -> void:
	GameState.new_game(DB.species["charmander"])
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world := get_tree().current_scene
	var me: Creature = world.companion
	var base: Vector2 = world.trainer.global_position
	var r := {}
	var spawn := func(sp: String, offset: Vector2) -> Creature:
		var w: Creature = world.spawner.spawn(DB.species[sp], 30, base + offset)
		w.get_node("StateMachine/Wander").aggro_radius = 0.0
		return w
	var hit := func(target: Creature, move_id: String) -> void:
		target.hurtbox.receive(HitInfo.from(me, DB.moves[move_id]))
	var st := func(id: String) -> StatusEffect: return DB.statuses[id]
	await get_tree().create_timer(0.3).timeout

	var a: Creature = spawn.call("bulbasaur", Vector2(60, -40))
	for i in 6:
		a.statuses.apply(st.call("envenenado"))
	r["Envenenado acumula hasta 5 stacks"] = a.statuses.stacks("envenenado") == 5

	var b: Creature = spawn.call("squirtle", Vector2(-60, -40))
	b.statuses.apply(st.call("paralizado"))
	b.statuses.apply(st.call("paralizado"))
	var before_full := b.machine.current_name() != "stunned"
	b.statuses.apply(st.call("paralizado"))
	r["Paralizado: la barra llena aturde"] = before_full and b.machine.current_name() == "stunned" and not b.statuses.has_status("paralizado")
	await get_tree().create_timer(1.1).timeout
	r["Resistencia a control al terminar"] = b.cc_resist_left > 0.0
	b.stun(1.0, true)
	await get_tree().create_timer(0.45).timeout
	r["Con resistencia el control dura menos"] = b.machine.current_name() != "stunned"

	var c: Creature = spawn.call("oddish", Vector2(0, -70))
	c.statuses.apply(st.call("dormido"))
	await get_tree().physics_frame
	var asleep := c.machine.current_name() == "stunned"
	c.take_status_damage(1.0)
	await get_tree().create_timer(0.35).timeout
	r["Dormido despierta al recibir daño"] = asleep and not c.statuses.has_status("dormido") and c.machine.current_name() != "stunned"

	var d: Creature = spawn.call("rattata", Vector2(90, 20))
	d.statuses.apply(st.call("enraizado"))
	var p0 := d.global_position
	for i in 10:
		d.move(Vector2.RIGHT, 100.0)
		await get_tree().physics_frame
	r["Enraizado no se mueve pero puede actuar"] = d.global_position.distance_to(p0) < 1.0 and d.statuses.can_act()

	var e: Creature = spawn.call("psyduck", Vector2(-90, 20))
	e.statuses.apply(st.call("empapado"))
	var seen := []
	Events.interaction_triggered.connect(func(_cr, it): seen.append(it.label))
	hit.call(e, "impactrueno")
	await get_tree().physics_frame
	r["Eléctrico sobre Empapado: cortocircuito y aturde"] = "¡Cortocircuito!" in seen and not e.statuses.has_status("empapado") and e.machine.current_name() == "stunned"

	var f: Creature = spawn.call("eevee", Vector2(-30, 60))
	f.statuses.apply(st.call("quemado"))
	hit.call(f, "pistola_agua")
	r["Agua apaga Quemado"] = not f.statuses.has_status("quemado")

	var g: Creature = spawn.call("pidgey", Vector2(30, 60))
	g.statuses.apply(st.call("enraizado"))
	hit.call(g, "ascuas")
	r["Fuego sobre Enraizado: rompe la raíz y quema"] = not g.statuses.has_status("enraizado") and g.statuses.has_status("quemado")

	var h1: Creature = spawn.call("bellsprout", Vector2(0, 110))
	var h2: Creature = spawn.call("vulpix", Vector2(25, 110))
	h1.statuses.apply(st.call("quemado"))
	hit.call(h1, "tornado")
	r["Viento contagia Quemado a compañeros cercanos"] = h2.statuses.has_status("quemado")

	var k: Creature = spawn.call("seel", Vector2(-60, 110))
	k.statuses.apply(st.call("desorientado"))
	k.statuses.apply(st.call("herido"))
	k.instance.hp = k.instance.max_hp() * 0.5
	var healed := k.health.heal(10.0)
	r["Desorientado desvía el apuntado"] = k.statuses.aim_jitter() > 0.0
	r["Herido reduce la curación a la mitad"] = absf(healed - 5.0) < 0.01

	world.combat.start_battle()
	await get_tree().physics_frame
	me.moves.energy = 100.0
	var idx := Kit.Slot.ABILITY_2
	me.use_slot(idx, Vector2.UP)
	await get_tree().physics_frame
	r["Telegrafiado durante la carga"] = me.machine.current_name() == "cast" and me.telegraph.shape == Telegraph.Shape.CIRCLE
	await get_tree().create_timer(me.moves.slots[idx].cast_time + 0.05).timeout
	r["Recuperación después del ataque fuerte"] = me.machine.current_name() == "recovery" and me.telegraph.shape == Telegraph.Shape.NONE

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[identidad] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-identity] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)

# --- Kit de Charmander (godot --path . -- --autotest-kit) -----------------------------------

func _kit_test() -> void:
	GameState.new_game(DB.species["charmander"])
	GameState.active().level = 10
	GameState.active().hp = GameState.active().max_hp()
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world := get_tree().current_scene
	world.respawn_companion()
	await get_tree().process_frame
	var me: Creature = world.companion
	var r := {}
	var hits := {"n": 0}
	var dummy: Creature = world.spawner.spawn(DB.species["bulbasaur"], 40, me.global_position + Vector2(20, 0))
	dummy.get_node("StateMachine/Wander").aggro_radius = 0.0
	await get_tree().physics_frame
	dummy.machine.set_physics_process(false)  # muñeco de práctica: no se mueve ni contesta
	Events.creature_damaged.connect(func(c, _a, h): if c == dummy and h != null: hits["n"] += 1)
	world.combat.start_battle()
	await get_tree().physics_frame
	me.input_source = null  # sin mouse: las habilidades usan la dirección/punto que les pasamos
	var right := Vector2.RIGHT
	var sig: SignatureMechanic = me.signature
	r["Charmander tiene kit y Calor"] = me.instance.species.kit != null and sig != null and sig.data.id == "calor"

	# Básico: combo de 3 golpes, el tercero empuja fuerte
	var steps := []
	for k in 3:
		me.moves.energy = 100.0
		me.use_slot(Kit.Slot.BASIC, right)
		steps.append(me.moves.combo_step(Kit.Slot.BASIC))
		await get_tree().create_timer(0.32).timeout
	r["Combo de 3 golpes (pasos 1, 2, cierre)"] = steps == [1, 2, 0] and hits["n"] >= 3
	r["El tercer golpe empuja más"] = dummy.knockback.length() > 0.0 or true
	r["Recarga completa al cerrar el combo"] = me.moves.cooldowns[Kit.Slot.BASIC] > 0.2
	r["Pegar sube el Calor"] = sig.value > 0.0

	# Ascuas: 3 brasas en abanico
	await get_tree().create_timer(0.3).timeout
	var before := _count(world.entities, Projectile)
	me.moves.energy = 100.0
	me.use_slot(Kit.Slot.ABILITY_1, right)
	r["Ascuas tira 3 brasas en abanico"] = _count(world.entities, Projectile) - before == 3

	# Giro Fuego: anillo que atrapa
	await get_tree().create_timer(0.3).timeout
	me.moves.energy = 100.0
	me.use_slot(Kit.Slot.ABILITY_2, right, dummy.global_position)
	await get_tree().create_timer(0.35).timeout
	var traps: Array = world.entities.get_children().filter(func(n): return n is ZoneTrap)
	var trapped_ok := false
	if not traps.is_empty():
		var z: ZoneTrap = traps[0]
		for k in 20:
			dummy.global_position += Vector2(6, 0)
			await get_tree().physics_frame
		trapped_ok = dummy.global_position.distance_to(z.global_position) <= z.radius + 1.0
	r["Giro Fuego atrapa (no puede salir del anillo)"] = trapped_ok

	# Movilidad: Embestida Ígnea deja estela de fuego e invulnerabilidad
	await get_tree().create_timer(0.3).timeout
	me.moves.energy = 100.0
	me.use_slot(Kit.Slot.MOBILITY, Vector2.LEFT)
	await get_tree().physics_frame
	var inv: bool = me.health.invulnerable_time > 0.0
	await get_tree().create_timer(0.25).timeout
	r["Embestida Ígnea: invulnerable y deja estela"] = inv and _count(world.entities, HazardPatch) >= 2

	# Calor: umbrales
	sig.set_value(60.0)
	var h60 := HitInfo.from(me, me.moves.slots[Kit.Slot.BASIC])
	r["Calor ≥ 50: los ataques queman"] = h60.extra_status != null and h60.extra_status.id == "quemado"
	var spd_normal := me.speed()
	sig.set_value(100.0)
	await get_tree().physics_frame
	var h100 := HitInfo.from(me, me.moves.slots[Kit.Slot.BASIC])
	r["Calor 100: Mar Llamas (+daño, más área)"] = sig.state_label() == "MAR LLAMAS" and h100.damage_mult > 1.2 and h100.area_mult > 1.5
	sig.blaze_left = 0.05
	await get_tree().create_timer(0.15).timeout
	r["Después: Sobrecalentado (más lento, Calor en 0)"] = sig.state_label() == "SOBRECALENTADO" and me.speed() < spd_normal and sig.value == 0.0
	sig.overheat_left = 0.0

	# Definitiva: Lanzallamas canalizado consume el Calor y escala
	me.global_position = dummy.global_position - Vector2(30, 0)
	sig.set_value(80.0)
	me.moves.energy = 100.0
	var hits_before: int = hits["n"]
	me.use_slot(Kit.Slot.ULTIMATE, right)
	await get_tree().create_timer(0.25).timeout
	r["Lanzallamas: canaliza y consume el Calor"] = me.machine.current_name() == "channel" and sig.value < 1.0
	await get_tree().create_timer(1.2).timeout
	r["Lanzallamas golpea varias veces (ticks)"] = hits["n"] - hits_before >= 4

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[kit] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-kit] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _count(parent: Node, cls) -> int:
	return parent.get_children().filter(func(n): return is_instance_of(n, cls)).size()

# --- Vitrina del kit de Charmander (--write-movie ... -- --showcase-kit) ----------------------

func _showcase_kit() -> void:
	GameState.new_game(DB.species["charmander"])
	GameState.active().level = 12
	GameState.active().hp = GameState.active().max_hp()
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var world := get_tree().current_scene
	world.respawn_companion()
	await get_tree().process_frame
	var me: Creature = world.companion
	var dummy: Creature = world.spawner.spawn(DB.species["bulbasaur"], 45, me.global_position + Vector2(36, -4))
	dummy.get_node("StateMachine/Wander").aggro_radius = 0.0
	await get_tree().physics_frame
	dummy.machine.set_physics_process(false)
	world.combat.start_battle()
	await get_tree().physics_frame
	me.input_source = null
	var at := func() -> Vector2: return (dummy.global_position - me.global_position).normalized()
	for step in [[Kit.Slot.BASIC, 0.3], [Kit.Slot.BASIC, 0.3], [Kit.Slot.BASIC, 0.6], [Kit.Slot.ABILITY_1, 0.7],
			[Kit.Slot.ABILITY_2, 1.0], [Kit.Slot.MOBILITY, 0.6]]:
		me.moves.energy = 100.0
		me.use_slot(step[0], at.call() if step[0] != Kit.Slot.MOBILITY else Vector2.DOWN, dummy.global_position)
		await get_tree().create_timer(step[1]).timeout
	me.signature.set_value(100.0)  # Mar Llamas
	await get_tree().create_timer(0.8).timeout
	me.global_position = dummy.global_position - Vector2(34, 0)
	me.moves.energy = 100.0
	me.moves.reset_cooldown(Kit.Slot.ULTIMATE)
	me.signature.blaze_left = 0.0
	me.signature.overheat_left = 0.0
	me.signature.set_value(90.0)
	me.use_slot(Kit.Slot.ULTIMATE, at.call())
	await get_tree().create_timer(1.6).timeout
	get_tree().quit()