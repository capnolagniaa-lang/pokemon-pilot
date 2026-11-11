class_name BoonTests
extends Node
## Autotest de R-2 del Modo Desafío (docs/PROPUESTA_ROGUELIKE.md): las bendiciones. Datos, sorteo, rarezas, que cada
## efecto haga lo que dice su tarjeta, la pantalla de elección y los íconos de la partida.
##   godot --headless --path . --fixed-fps 60 --quit-after 60000 -- --autotest-boons
## Vitrina (la pantalla de elección de cada legendario):
##   godot --path . --quit-after 330 --write-movie out/f.png --fixed-fps 30 -- --showcase-boons

var world: Node
var run: RogueRun
var boons: RogueBoons
var me: Creature
## Tres muñecos: A y B juntos, cerca tuyo; C lejos.
var a: Creature
var b: Creature
var c: Creature


func run_tests() -> void:
	var r := {}
	var cfg := RogueBoons.load_config()

	# --- Datos ---
	var per_giver := {}
	var missing: Array[String] = []
	var probe := RogueBoons.new()
	for boon: BoonData in DB.boons.values():
		per_giver[boon.giver] = int(per_giver.get(boon.giver, 0)) + 1
		if not ResourceLoader.exists(BoonScreen.ICONS % boon.id):
			missing.append("ícono de " + boon.id)
		if not probe.has_method("_fx_" + boon.effect) and not boon.effect in ["hit_status", "hit_blast", "dodge_blast",
				"bonus_vs_status", "chain", "kill_pp", "kill_blast", "thorns", "first_strike", "phoenix"]:
			missing.append("efecto de " + boon.id)
		for key in ["status", "need"]:
			if boon.params.has(key) and not DB.statuses.has(boon.params[key]):
				missing.append("estado %s de %s" % [boon.params[key], boon.id])
		for s in boon.params.get("statuses", []):
			if not DB.statuses.has(s):
				missing.append("estado %s de %s" % [s, boon.id])
		if boon.params.has("element") and not DB.types.has(boon.params["element"]):
			missing.append("tipo de " + boon.id)
		if not cfg["givers"].has(boon.giver) or boon.display_name == "" or boon.text == "":
			missing.append("datos de " + boon.id)
		for k in boon.scaled:
			if not boon.params.has(k):
				missing.append("escala de " + boon.id)
	probe.free()
	for g: String in cfg["givers"]:
		if not ResourceLoader.exists(cfg["givers"][g]["banner"]):
			missing.append("cartel de " + g)
		if not DB.species.has(cfg["givers"][g]["species"]) or cfg["givers"][g]["lines"].size() < 3:
			missing.append("dador " + g)
	r["Hay %d bendiciones de 3 legendarios (%s)" % [DB.boons.size(), ", ".join(per_giver.keys().map(func(g): return "%s %d" % [g, per_giver[g]]))]] = \
		DB.boons.size() >= 15 and per_giver.size() == 3 and per_giver.values().all(func(n): return n >= 5 and n <= 6)
	r["Cada una con su ícono, su efecto, sus estados y su dador con cartel y frases%s" % ("" if missing.is_empty() else " — falta: " + "; ".join(missing))] = missing.is_empty()

	# --- En una sala, con tres muñecos ---
	RogueRun.begin(DB.species["squirtle"])
	GameState.rogue["biomes"] = ["cueva", "bosque", "volcan", "hielo", "costa"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	boons = run.boons
	me = world.companion
	var old: Array[Creature] = run.foes.duplicate()
	run._spawn_wave([["snorlax", 30, true], ["snorlax", 30, true], ["snorlax", 30, true]])
	for e in old:
		run.foes.erase(e)
		world.combat.enemies.erase(e)
		e.queue_free()
	a = run.foes[0]
	b = run.foes[1]
	c = run.foes[2]
	await get_tree().physics_frame
	await get_tree().physics_frame
	for e: Creature in [a, b, c]:
		e.process_mode = Node.PROCESS_MODE_DISABLED  # (muñecos: no pelean ni se mueven)
	me.process_mode = Node.PROCESS_MODE_DISABLED
	_place()
	r["Las bendiciones están enganchadas a tu Pokémon y a los desmayos"] = boons._creature == me and me.hit_dealt.is_connected(boons._on_hit) \
		and me.dodged.is_connected(boons._on_dodged) and me.damage_received.is_connected(boons._on_damaged) \
		and Events.creature_fainted.is_connected(boons._on_fainted)
	var texts_ok := true
	for boon: BoonData in DB.boons.values():
		var text := boons.describe(boon, "rara", 2)
		if text.contains("{") or text.contains("}") or text.length() < 20:
			texts_ok = false
			print("[bendiciones]       texto raro en %s: %s" % [boon.id, text])
	r["Los textos de las tarjetas salen completos (números y teclas)"] = texts_ok

	# --- Sorteo y rarezas ---
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var offers_ok := true
	for n in 200:
		var o: Dictionary = boons.offer(rng)
		var ids: Array = o["options"].map(func(x): return x["id"])
		var uniq := {}
		for id in ids:
			uniq[id] = true
		if ids.size() != 3 or uniq.size() != 3 or not ids.all(func(id): return DB.boons[id].giver == o["giver"]) or str(o["line"]) == "":
			offers_ok = false
	r["Una oferta: 3 bendiciones distintas del mismo legendario, con su frase"] = offers_ok
	var count := {}
	for n in 4000:
		var id := boons.roll_rarity(rng)
		count[id] = int(count.get(id, 0)) + 1
	r["Rarezas: común %d, rara %d, épica %d, legendaria %d de 4000" % [count.get("comun", 0), count.get("rara", 0), count.get("epica", 0), count.get("legendaria", 0)]] = \
		count.get("comun", 0) > count.get("rara", 0) and count.get("rara", 0) > count.get("epica", 0) \
		and count.get("epica", 0) > count.get("legendaria", 0) and count.get("legendaria", 0) > 0
	var sob: BoonData = DB.boons["sobrecarga"]
	r["La rareza y el nivel suben los números (Sobrecarga: %d %% común, %d %% épica, %d %% épica Nv. 2)" % [
		roundi(100 * boons.value_of(sob, "pct", "comun", 1)), roundi(100 * boons.value_of(sob, "pct", "epica", 1)),
		roundi(100 * boons.value_of(sob, "pct", "epica", 2))]] = boons.value_of(sob, "pct", "epica", 1) > boons.value_of(sob, "pct", "rara", 1) \
		and boons.value_of(sob, "pct", "rara", 1) > boons.value_of(sob, "pct", "comun", 1) \
		and boons.value_of(sob, "pct", "epica", 2) > boons.value_of(sob, "pct", "epica", 1) \
		and is_equal_approx(boons.value_of(sob, "statuses", "epica", 3), 0.0)

	# --- Cada efecto ---
	var power: float = 4.0 + float(me.instance.level)
	# Golpe con estado (Zapdos, Ataque 1)
	_only("golpe_estatico")
	var para := 0
	for n in 80:
		_reset()
		_hit(a, 0, 10.0)
		if a.statuses.has_status("paralizado"):
			para += 1
	var wrong := 0
	for n in 40:
		_reset()
		_hit(a, 1, 10.0)
		if a.statuses.has_status("paralizado"):
			wrong += 1
	r["Golpe Estático: el Ataque 1 paraliza a veces (%d de 80) y los otros ataques nunca (%d)" % [para, wrong]] = para >= 10 and para <= 45 and wrong == 0
	_only("toque_gelido")
	_reset()
	for n in 40:
		_hit(a, 0, 5.0)
	r["Toque Gélido: el Ataque 1 va sumando Escarcha"] = a.statuses.has_status("escarcha") or a.statuses.has_status("congelado")
	_only("garra_ardiente")
	_reset()
	for n in 40:
		_hit(a, 0, 5.0)
	r["Garra Ardiente: el Ataque 1 quema"] = a.statuses.has_status("quemado")
	# Estallido donde pega (Zapdos Ataque 2, Articuno Ataque 3, Moltres Ataque 4)
	_only("rayo_celeste")
	_reset()
	var d := _hit(a, 1, 20.0)
	r["Rayo Celeste: 35 %% del daño de más al golpeado (%.1f) y al de al lado (%.1f); al lejano nada (%.1f)" % [d[0], d[1], d[2]]] = \
		is_equal_approx(d[0], 7.0) and is_equal_approx(d[1], 7.0) and is_zero_approx(d[2])
	_reset()
	d = _hit(a, 0, 20.0)
	r["Rayo Celeste: con otro ataque no cae"] = is_zero_approx(d[0] + d[1] + d[2])
	_only("ventisca")
	_reset()
	d = _hit(a, 2, 20.0)
	r["Ventisca (Ataque 3): frena a los de alrededor y les hace 25 %% (%.1f)" % d[1]] = is_equal_approx(d[1], 5.0) and a.statuses.has_status("frenado") \
		and b.statuses.has_status("frenado") and not c.statuses.has_status("frenado")
	_only("estallido")
	_reset()
	d = _hit(a, 3, 20.0)
	r["Estallido Ígneo (Ataque 4): 40 %% a él y al de al lado (%.1f, %.1f)" % [d[0], d[1]]] = is_equal_approx(d[0], 8.0) and is_equal_approx(d[1], 8.0) and is_zero_approx(d[2])
	# Esquive
	for id in ["paso_de_trueno", "estela_helada", "estela_de_fuego"]:
		_only(id)
		_reset()
		var before := _hp()
		me.dodged.emit()
		var after := _hp()
		var want: float = float(DB.boons[id].params["power"]) * power
		r["%s: al esquivar, %d de daño a los que tenías cerca (%.1f y %.1f) y nada al lejano" % [DB.boons[id].display_name, roundi(want), before[0] - after[0], before[1] - after[1]]] = \
			is_equal_approx(before[0] - after[0], want) and is_equal_approx(before[1] - after[1], want) and is_equal_approx(before[2], after[2])
	_only("estela_helada")
	_reset()
	me.dodged.emit()
	r["Estela Helada: además los deja Frenados"] = a.statuses.has_status("frenado") and b.statuses.has_status("frenado") and not c.statuses.has_status("frenado")
	# Más daño a los que tienen un estado
	for pair in [["sobrecarga", "paralizado"], ["hielo_quebradizo", "frenado"], ["brasas", "quemado"]]:
		_only(pair[0])
		_reset()
		var none := _hit(a, 0, 20.0)
		a.statuses.apply(DB.statuses[pair[1]], 1.0, me)
		var with := _hit(a, 0, 20.0)
		var pct: float = float(DB.boons[pair[0]].params["pct"])
		r["%s: +%d %% a los que tienen %s (%.1f de más; sin el estado, %.1f)" % [DB.boons[pair[0]].display_name, roundi(pct * 100), pair[1], with[0], none[0]]] = \
			is_equal_approx(with[0], 20.0 * pct) and is_zero_approx(none[0])
	# Cadena
	_only("cadena")
	_reset()
	var no_chain := _hit(a, 0, 20.0)
	a.statuses.apply(DB.statuses["paralizado"], 1.0, me)
	d = _hit(a, 0, 20.0)
	r["Rayo en Cadena: pegarle a un Paralizado le salta 40 %% al más cercano (%.1f), no al lejano" % d[1]] = is_equal_approx(d[1], 8.0) and is_zero_approx(d[2]) \
		and is_zero_approx(no_chain[1])
	# Primer golpe
	_only("aliento_polar")
	_reset()
	d = _hit(a, 0, 20.0, true)
	var again := _hit(a, 0, 20.0, true)
	r["Aliento Polar: +45 %% al primer golpe a uno con la vida entera (%.1f), no al segundo (%.1f)" % [d[0], again[0]]] = is_equal_approx(d[0], 9.0) and is_zero_approx(again[0])
	# Al caer un enemigo
	_only("pila")
	me.moves.set_pp(me.moves.max_pp() * 0.5)
	boons._on_fainted(c)
	r["Pila Cargada: un enemigo que cae devuelve 12 %% de la barra de PP (%d %%)" % roundi(100.0 * me.moves.pp() / me.moves.max_pp())] = \
		is_equal_approx(me.moves.pp(), me.moves.max_pp() * 0.62)
	_only("combustion")
	_reset()
	var hp0 := _hp()
	boons._on_fainted(a)
	var hp1 := _hp()
	a.statuses.apply(DB.statuses["quemado"], 1.0, me)
	boons._on_fainted(a)
	var hp2 := _hp()
	r["Combustión: un Quemado que cae explota (%.1f al de al lado); uno sin quemar, no" % (hp1[1] - hp2[1])] = is_equal_approx(hp0[1], hp1[1]) \
		and is_equal_approx(hp1[1] - hp2[1], 1.1 * power) and is_equal_approx(hp1[2], hp2[2])
	# Cuando te pegan
	_only("coraza_de_escarcha")
	_reset()
	hp0 = _hp()
	var hit := HitInfo.new()
	hit.attacker = a
	hit.move = a.moves.slots[0]
	me.damage_received.emit(5.0, hit)
	hp1 = _hp()
	a.statuses.clear()
	me.damage_received.emit(5.0, hit)
	hp2 = _hp()
	r["Coraza de Escarcha: el que te pega queda Frenado y recibe %d; enseguida de nuevo, no (espera 5 s)" % roundi(0.4 * power)] = \
		is_equal_approx(hp0[0] - hp1[0], 0.4 * power) and is_equal_approx(hp1[0], hp2[0]) and not a.statuses.has_status("frenado")
	_only("ave_fenix")
	boons.room_started()
	me.instance.hp = me.instance.max_hp() * 0.2
	me.damage_received.emit(1.0, null)
	var up: float = me.instance.hp / me.instance.max_hp()
	me.instance.hp = me.instance.max_hp() * 0.2
	me.damage_received.emit(1.0, null)
	var second: float = me.instance.hp / me.instance.max_hp()
	boons.room_started()
	me.damage_received.emit(1.0, null)
	var next_room: float = me.instance.hp / me.instance.max_hp()
	r["Ave Fénix: bajo 25 %% de vida recuperás 30 %% (quedó en %d %%), una vez por sala (la segunda %d %%, en otra sala %d %%)" % [
		roundi(up * 100), roundi(second * 100), roundi(next_room * 100)]] = is_equal_approx(up, 0.5) and is_equal_approx(second, 0.2) and is_equal_approx(next_room, 0.5)
	me.instance.hp = me.instance.max_hp()

	# --- Con un golpe de verdad (no avisado a mano): tu Pokémon le pega a un muñeco ---
	_only("aliento_polar")
	_reset()
	boons.triggers.clear()
	me.process_mode = Node.PROCESS_MODE_INHERIT
	a.process_mode = Node.PROCESS_MODE_INHERIT  # (apagado no recibe golpes)
	a.global_position = me.global_position + Vector2(18, 0)
	var real_t := 0.0
	while real_t < 6.0 and not boons.triggers.has("aliento_polar"):
		me.use_slot(0, Vector2.RIGHT, a.global_position)
		a.global_position = me.global_position + Vector2(18, 0)
		me.health.heal(9999.0)
		await get_tree().physics_frame
		real_t += get_physics_process_delta_time()
	a.process_mode = Node.PROCESS_MODE_DISABLED
	r["Un golpe de verdad de tu Pokémon dispara la bendición (Aliento Polar, a los %.1f s; el muñeco quedó en %d %%)" % [real_t,
		roundi(100.0 * a.instance.hp / a.instance.max_hp())]] = boons.triggers.has("aliento_polar") and a.instance.hp < a.instance.max_hp()
	me.process_mode = Node.PROCESS_MODE_DISABLED

	# --- Tener, subir de nivel, la pantalla y los íconos ---
	GameState.rogue["boons"] = []
	boons.take("sobrecarga", "comun")
	boons.take("sobrecarga", "rara")
	r["Tomar de nuevo una que tenés la sube de nivel y se queda con la mejor rareza"] = boons.owned().size() == 1 \
		and int(boons.entry("sobrecarga")["level"]) == 2 and boons.entry("sobrecarga")["rarity"] == "rara" \
		and boons.value(sob, "pct") > boons.value_of(sob, "pct", "rara", 1)
	for boon: BoonData in DB.boons.values():
		if boon.giver == "zapdos":
			boons.take(boon.id)
	var fresh: Dictionary = boons.offer(rng)
	var all_z: Dictionary = boons.offer(rng, "zapdos")
	r["Con todas las de un legendario, el sorteo va a otro (%s); si igual toca él, ofrece subirlas de nivel" % fresh["giver"]] = fresh["giver"] != "zapdos" \
		and all_z["options"].size() == 3 and all_z["options"].all(func(x): return boons.has(x["id"]))
	GameState.rogue["boons"] = []
	run._refresh_boons()
	var o2: Dictionary = boons.offer(rng, "moltres")
	var screen := BoonScreen.open(run, boons, o2)
	await get_tree().process_frame
	var picked := [-1]
	screen.chosen.connect(func(i: int): picked[0] = i)
	var labels: Array = screen.find_children("*", "Label", true, false).map(func(l): return l.text)
	r["La pantalla: Moltres con su frase y 3 tarjetas (nombre, rareza y texto), con el juego en pausa"] = screen.cards.size() == 3 and get_tree().paused \
		and labels.has("MOLTRES") and labels.has(o2["line"]) and o2["options"].all(func(x): return labels.has(DB.boons[x["id"]].display_name)) \
		and screen.find_children("*", "PokemonAnimView", true, false).size() == 1
	screen.choose(1)
	await get_tree().process_frame
	boons.take(o2["options"][1]["id"], o2["options"][1]["rarity"])
	await get_tree().process_frame
	await get_tree().process_frame
	r["Elegir una la suma, saca la pausa y aparece su ícono arriba"] = picked[0] == 1 and not get_tree().paused and boons.has(o2["options"][1]["id"]) \
		and run._boon_row.get_child_count() == 1

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[bendiciones] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-boons] -> ", "OK" if ok else "FALLO")
	GameState.rogue = {}
	get_tree().quit(0 if ok else 1)


## Solo esa bendición, común.
func _only(id: String) -> void:
	GameState.rogue["boons"] = [{"id": id, "rarity": "comun", "level": 1}]
	boons._thorns_ready = 0.0


## Los muñecos en su lugar, sanos y sin estados.
func _reset() -> void:
	for e: Creature in [a, b, c]:
		e.statuses.clear()
		e.instance.hp = e.instance.max_hp()
	_place()


func _place() -> void:
	a.global_position = me.global_position + Vector2(22, 0)
	b.global_position = me.global_position + Vector2(38, 0)
	c.global_position = me.global_position + Vector2(260, 0)


func _hp() -> Array[float]:
	return [a.instance.hp, b.instance.hp, c.instance.hp]


## Un golpe tuyo de `damage` a `target` con el ataque de esa ranura (como lo avisa Creature: `hit_dealt`). Devuelve el
## daño DE MÁS que hicieron las bendiciones a [A, B, C]. Con `real`, el golpe también le saca la vida al golpeado.
func _hit(target: Creature, slot: int, damage: float, real := false) -> Array[float]:
	var hit := HitInfo.new()
	hit.attacker = me
	hit.move = _slot_move(slot)
	if real:
		target.instance.hp -= damage
	var before := _hp()
	me.hit_dealt.emit(target, hit, damage)
	var after := _hp()
	return [before[0] - after[0], before[1] - after[1], before[2] - after[2]]


## El ataque de esa ranura (si tu Pokémon no tiene tantos, se le pone uno para la prueba).
func _slot_move(slot: int) -> MoveData:
	if me.moves.slots[slot] == null:
		var used: Array = me.moves.slots.filter(func(m): return m != null)
		for m: MoveData in DB.moves.values():
			if not used.has(m) and m.power > 0.0:
				me.moves.slots[slot] = m
				break
	return me.moves.slots[slot]


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


## Vitrina: la pantalla de elección de cada legendario, unos segundos cada una.
func showcase() -> void:
	RogueRun.begin(DB.species["charmander"])
	GameState.rogue["biomes"] = ["volcan", "bosque", "cueva", "hielo", "costa"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	boons = run.boons
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for g in ["zapdos", "articuno", "moltres"]:
		var o: Dictionary = boons.offer(rng, g)
		o["options"][0]["rarity"] = "comun"
		o["options"][1]["rarity"] = "rara"
		o["options"][2]["rarity"] = "epica" if g != "moltres" else "legendaria"
		var screen := BoonScreen.open(run, boons, o)
		await get_tree().create_timer(3.0).timeout
		screen.choose(1)
		boons.take(o["options"][1]["id"], o["options"][1]["rarity"])
		await get_tree().create_timer(0.5).timeout
	await get_tree().create_timer(30.0).timeout
