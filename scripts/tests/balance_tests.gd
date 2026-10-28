class_name BalanceTests
extends Node
## Batería de balance (pedido del usuario 2026-10-28: "muchísimas peleas entre diferentes Pokémon con IA en buena
## dificultad para probar el balance"): dos Pokémon con kit pelean solos con la IA de los salvajes en Difícil, uno de
## cada bando, en un lugar abierto del mapa. Se emparejan por stats base parecidos (suma de los 6, ±`--bst`), así lo
## que se mide es el kit, el tipo y la IA y no solo los números; cada pareja pelea dos veces cambiando de lado. Al
## final escribe docs/BALANCE_INFORME.md (victorias por especie, estilo y tipo; daño por ataque) y un CSV con cada
## pelea en user://balance/peleas.csv.
##   godot --headless --path . --fixed-fps 60 --quit-after 9000000 -- --autotest-balance [--fights 400] [--level 40]
##     [--bst 60] [--seed 1] [--species a,b,c] [--arena] [--timeout 60]
## `--fixed-fps 60` hace que corra lo más rápido que da la PC (sin esperar al reloj real): sin eso va a velocidad normal.

const CreatureScene := preload("res://scenes/creatures/creature.tscn")
const OUT := "res://docs/BALANCE_INFORME.md"
const CSV_DIR := "user://balance"

var autotest: Node
var world: Node
var spot := Vector2.ZERO
var opts := {"fights": 400, "level": 40, "bst": 60, "seed": 1, "species": "", "arena": false, "timeout": 60.0}

## Por especie: {fights, wins, timeouts, time_win, hp_left, dealt, taken, secs}
var by_species := {}
## Por ataque: {uses, hits, damage}
var by_move := {}
var rows: Array[String] = ["pelea,a,b,ganador,segundos,vida_ganador,dano_a,dano_b"]
var _fight_dealt := {}


func run() -> void:
	_read_args()
	seed(int(opts["seed"]))
	var pool := _pool()
	print("[balance] %d especies con kit · %d peleas · nivel %d · ±%d de stats base · %s" % [pool.size(), opts["fights"],
		opts["level"], opts["bst"], "reglas de arena" if opts["arena"] else "reglas del mundo"])
	world = await autotest._setup_kit_world(pool[0].id)
	world.combat.end_battle()
	world.companion.set_captured(true)  # tu Pokémon no participa
	world.story.set_physics_process(false)  # ni charlas ni entrenadores que te vean
	GameState.difficulty = DB.difficulties["dificil"]
	if opts["arena"]:
		GameState.set_setting("arena_everywhere", true)
	for c in Events.hitstop.get_connections():
		Events.hitstop.disconnect(c["callable"])  # sin congelar el tiempo en cada golpe
	Events.move_used.connect(_on_move_used)
	Events.creature_damaged.connect(_on_damaged)
	spot = _open_spot()
	var fights := 0
	var t0 := Time.get_ticks_msec()
	var order := pool.duplicate()
	order.shuffle()
	var turn := 0
	while fights < int(opts["fights"]):
		var a: SpeciesData = order[turn % order.size()]  # todas por turno: la misma cantidad de peleas cada una
		turn += 1
		var rivals := pool.filter(func(s): return s != a and absi(_bst(s) - _bst(a)) <= int(opts["bst"]))
		if rivals.is_empty():
			continue
		var b: SpeciesData = rivals[randi() % rivals.size()]
		for side in 2:  # la misma pareja dos veces, cambiando de lado
			await _fight(a if side == 0 else b, b if side == 0 else a, fights)
			fights += 1
		if fights % 20 == 0:
			print("[balance] %d/%d peleas (%.0f s)" % [fights, opts["fights"], (Time.get_ticks_msec() - t0) / 1000.0])
	_write_report(fights, (Time.get_ticks_msec() - t0) / 1000.0)
	print("[autotest-balance] -> OK")
	get_tree().quit(0)


func _read_args() -> void:
	var args := OS.get_cmdline_user_args()
	for k in opts:
		var i := args.find("--" + k)
		if i < 0:
			continue
		if opts[k] is bool:
			opts[k] = true
		elif i + 1 < args.size():
			opts[k] = args[i + 1] if opts[k] is String else (float(args[i + 1]) if opts[k] is float else int(args[i + 1]))


## Especies con kit (propio o heredado); con --species, solo esas.
func _pool() -> Array:
	var only: Array = Array(String(opts["species"]).split(",", false))
	var out := DB.species.values().filter(func(s): return s.kit != null and (only.is_empty() or s.id in only))
	out.sort_custom(func(x, y): return x.dex < y.dex)
	return out


func _bst(s: SpeciesData) -> int:
	return s.base_hp + s.base_attack + s.base_defense + s.base_sp_attack + s.base_sp_defense + s.base_speed


## Una pelea: A (tu bando) contra B (salvaje), los dos con la IA. Termina cuando uno cae o a los `timeout` s.
func _fight(a: SpeciesData, b: SpeciesData, n: int) -> void:
	var temp := Temperament.new()  # pelea hasta el final: no huye, no se espanta, no suelta
	temp.flee_below = 0.0
	temp.leash = 99999.0
	temp.spook_chance = 0.0
	var before: Array = world.entities.get_children()
	var ca := _spawn(a, Creature.Team.ALLY, spot + Vector2(-70, 0), temp)
	var cb := _spawn(b, Creature.Team.WILD, spot + Vector2(70, 0), temp)
	_fight_dealt = {ca: 0.0, cb: 0.0}
	await get_tree().physics_frame
	await get_tree().physics_frame
	ca.target = cb
	cb.target = ca
	ca.machine.transition_to("chase")
	cb.machine.transition_to("chase")
	var t := 0.0
	while t < float(opts["timeout"]) and not ca.is_down() and not cb.is_down():
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if not ca.is_down() and not cb.is_down() and ca.global_position.distance_to(spot) > 400.0:
			ca.global_position = spot  # (si se fue muy lejos persiguiendo, vuelve: que no salga de lo cargado)
	var winner := ""
	var hp_left := 0.0
	if ca.is_down() != cb.is_down():
		var w := cb if ca.is_down() else ca
		winner = w.instance.species.id
		hp_left = clampf(w.instance.hp / w.instance.max_hp(), 0.0, 1.0)
	_note(a.id, ca, cb, winner, t, hp_left)
	_note(b.id, cb, ca, winner, t, hp_left)
	rows.append("%d,%s,%s,%s,%.1f,%.2f,%.0f,%.0f" % [n, a.id, b.id, winner if winner != "" else "empate", t, hp_left,
		_fight_dealt[ca], _fight_dealt[cb]])
	for c in world.entities.get_children():
		if not c in before:
			c.queue_free()  # lo de esta pelea (los dos, disparos, zonas...)
	await get_tree().physics_frame


func _spawn(sp: SpeciesData, team: int, pos: Vector2, temp: Temperament) -> Creature:
	var c: Creature = CreatureScene.instantiate()
	c.instance = CreatureInstance.create(sp, int(opts["level"]))
	c.team = team
	c.ai_fighter = true
	c.temperament = temp
	c.position = pos
	world.entities.add_child(c)
	c.home = pos
	c.get_node("StateMachine/Attack").flee_below = 0.0
	return c


func _note(id: String, me: Creature, foe: Creature, winner: String, t: float, hp_left: float) -> void:
	var d: Dictionary = by_species.get(id, {"fights": 0, "wins": 0, "timeouts": 0, "time_win": 0.0, "hp_left": 0.0,
		"dealt": 0.0, "taken": 0.0, "secs": 0.0})
	d["fights"] += 1
	d["secs"] += t
	d["dealt"] += _fight_dealt.get(me, 0.0) / maxf(1.0, foe.instance.max_hp())
	d["taken"] += _fight_dealt.get(foe, 0.0) / maxf(1.0, me.instance.max_hp())
	if winner == "":
		d["timeouts"] += 1
	elif winner == id and not me.is_down():
		d["wins"] += 1
		d["time_win"] += t
		d["hp_left"] += hp_left
	by_species[id] = d


func _on_move_used(user: Node, m: MoveData) -> void:
	if user is Creature and user.ai_fighter:
		var d: Dictionary = by_move.get(m.id, {"name": m.display_name, "uses": 0, "hits": 0, "damage": 0.0, "users": {}})
		d["uses"] += 1
		d["users"][user.instance.species.display_name] = true
		by_move[m.id] = d


func _on_damaged(c: Node, amount: float, hit: HitInfo) -> void:
	if hit == null or not is_instance_valid(hit.attacker) or not hit.attacker is Creature or not hit.attacker.ai_fighter:
		return
	amount = clampf(amount, 0.0, c.instance.max_hp())  # (un remate pasa INF: cuenta como la vida entera)
	if _fight_dealt.has(hit.attacker):
		_fight_dealt[hit.attacker] += amount
	if hit.move != null and amount > 0.0:
		var d: Dictionary = by_move.get(hit.move.id, {"name": hit.move.display_name, "uses": 0, "hits": 0, "damage": 0.0, "users": {}})
		d["hits"] += 1
		# en % de la vida del que lo recibe (comparable entre niveles y especies)
		d["damage"] += 100.0 * amount / maxf(1.0, c.instance.max_hp())
		by_move[hit.move.id] = d


## Un lugar abierto (16×12 celdas sin nada sólido) en la zona cargada, lo más cerca posible del entrenador.
func _open_spot() -> Vector2:
	var zone: Zone = world.streamer.zone_node(world.streamer.current.id)
	var objects := MapRules.objects_by_cell(zone)
	var used := zone.ground.get_used_rect()
	var here: Vector2i = zone.ground.local_to_map(zone.to_local(world.trainer.global_position))
	var best := Vector2i(-9999, -9999)
	var best_d := INF
	for y in range(used.position.y + 6, used.end.y - 6, 2):
		for x in range(used.position.x + 8, used.end.x - 8, 2):
			var ok := true
			for dy in range(-6, 6):
				for dx in range(-8, 8):
					if not MapRules.is_walkable(zone, Vector2i(x + dx, y + dy), objects):
						ok = false
						break
				if not ok:
					break
			var d := Vector2(x - here.x, y - here.y).length()
			if ok and d < best_d:
				best_d = d
				best = Vector2i(x, y)
	if best.x < -1000:
		return world.trainer.global_position + Vector2(0, -120)
	return zone.to_global(zone.ground.map_to_local(best))


func _write_report(fights: int, secs: float) -> void:
	var L: Array[String] = ["# Informe de balance (batería de peleas IA contra IA)", "",
		"> **Generado** por `--autotest-balance` (%s). Ver cómo correrlo en `scripts/tests/balance_tests.gd`." % Time.get_date_string_from_system(),
		"> Cada pelea: dos Pokémon con kit, IA en Difícil, nivel %d, %s, emparejados por stats base (±%d), cada pareja" % [
			opts["level"], "reglas de arena" if opts["arena"] else "reglas del mundo", opts["bst"]],
		"> dos veces cambiando de lado. %d peleas en %.0f s (semilla %d). Con pocas peleas por especie los %% varían mucho:" % [fights, secs, opts["seed"]],
		"> mirar las que tienen 10 o más.", ""]
	var timeouts := 0
	for r in rows.slice(1):
		if r.contains(",empate,"):
			timeouts += 1
	L.append("Empates por tiempo (%d s): %d de %d (%.0f%%)." % [int(opts["timeout"]), timeouts / 2, fights / 2, 100.0 * timeouts / maxf(1, rows.size() - 1)])
	L.append("")
	var ids := by_species.keys()
	ids.sort_custom(func(x, y): return _rate(x) > _rate(y))
	L.append("## Por especie (de más fuerte a más débil)")
	L.append("")
	L.append("Daño hecho/recibido = de golpes (sin veneno ni quemaduras), en vidas enteras del rival/propias por pelea (1,0 = una vida). ⬆ = gana 65% o más, ⬇ = 35% o menos (con 10+ peleas).")
	L.append("")
	L.append("| Pokémon | Estilo | Stats base | Peleas | Victorias | % | Vida al ganar | Seg. por victoria | Daño hecho | Daño recibido | Empates |")
	L.append("|---|---|---|---|---|---|---|---|---|---|---|")
	for id in ids:
		var d: Dictionary = by_species[id]
		var sp: SpeciesData = DB.species[id]
		var r := _rate(id)
		var flag := (" ⬆" if r >= 0.65 else (" ⬇" if r <= 0.35 else "")) if d["fights"] >= 10 else ""
		L.append("| %s%s | %s | %d | %d | %d | %.0f%% | %s | %s | %.2f | %.2f | %d |" % [sp.display_name, flag, sp.kit.archetype,
			_bst(sp), d["fights"], d["wins"], 100.0 * r,
			"%.0f%%" % (100.0 * d["hp_left"] / d["wins"]) if d["wins"] > 0 else "—",
			"%.1f" % (d["time_win"] / d["wins"]) if d["wins"] > 0 else "—",
			d["dealt"] / d["fights"], d["taken"] / d["fights"], d["timeouts"]])
	L.append("")
	_group(L, "Por estilo (arquetipo del kit)", func(sp): return [sp.kit.archetype])
	_group(L, "Por tipo (un Pokémon de dos tipos cuenta en los dos)", func(sp): return sp.types.map(func(t): return t.display_name))
	L.append("## Por ataque (los más usados)")
	L.append("")
	L.append("Daño = %% de la vida del que lo recibe, sumado. Por uso = daño medio cada vez que se lanza (los de estado dan 0).")
	L.append("")
	L.append("| Ataque | Usos | Golpes | Daño total | Por uso | Lo usan |")
	L.append("|---|---|---|---|---|---|")
	var moves := by_move.keys()
	moves.sort_custom(func(x, y): return by_move[x]["uses"] > by_move[y]["uses"])
	for mid in moves.slice(0, 80):
		var m: Dictionary = by_move[mid]
		var users: Array = m["users"].keys()
		L.append("| %s (`%s`) | %d | %d | %.0f | %.1f | %s |" % [m["name"], mid, m["uses"], m["hits"], m["damage"],
			m["damage"] / maxf(1, m["uses"]), ", ".join(users.slice(0, 4)) + (" +%d" % (users.size() - 4) if users.size() > 4 else "")])
	L.append("")
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_string("\n".join(L) + "\n")
	f.close()
	DirAccess.make_dir_recursive_absolute(CSV_DIR)
	var csv := FileAccess.open(CSV_DIR + "/peleas.csv", FileAccess.WRITE)
	csv.store_string("\n".join(rows) + "\n")
	csv.close()
	print("[balance] informe: %s · peleas: %s" % [OUT, ProjectSettings.globalize_path(CSV_DIR + "/peleas.csv")])


func _rate(id: String) -> float:
	var d: Dictionary = by_species[id]
	return float(d["wins"]) / maxf(1, d["fights"])


func _group(L: Array[String], title: String, keys_of: Callable) -> void:
	var g := {}
	for id in by_species:
		for k in keys_of.call(DB.species[id]):
			var d: Dictionary = g.get(k, {"fights": 0, "wins": 0, "species": 0})
			d["fights"] += by_species[id]["fights"]
			d["wins"] += by_species[id]["wins"]
			d["species"] += 1
			g[k] = d
	var ks := g.keys()
	ks.sort_custom(func(x, y): return float(g[x]["wins"]) / maxf(1, g[x]["fights"]) > float(g[y]["wins"]) / maxf(1, g[y]["fights"]))
	L.append("## " + title)
	L.append("")
	L.append("| | Especies | Peleas | % de victorias |")
	L.append("|---|---|---|---|")
	for k in ks:
		L.append("| %s | %d | %d | %.0f%% |" % [k, g[k]["species"], g[k]["fights"], 100.0 * g[k]["wins"] / maxf(1, g[k]["fights"])])
	L.append("")
