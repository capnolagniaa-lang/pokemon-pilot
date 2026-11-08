class_name AiThreatTests
extends Node
## Autotest de la IA que lee la amenaza que viene (S-0, docs/PLAN_SPARRING_IA.md; queja del usuario 2026-11-08: "se me
## viene encima aunque le dispare y no hace sidesteps"): TacticalMind.threat, el paso al costado y el esquive de
## CombatBody, y el estado de ataque que deja de venir de frente cuando se come golpes.
##   godot --headless --path . --quit-after 30000 -- --autotest-ai-threat

var autotest: Node
var world: Node
var r := {}
var debug := false
## Dirección de tiro despejada (de tu Pokémon hacia el rival de prueba) y su perpendicular.
var d := Vector2.ZERO
var perp := Vector2.DOWN


func run() -> void:
	world = await autotest._setup_kit_world("squirtle")
	GameState.difficulty = DB.difficulties["dificil"].duplicate()
	GameState.difficulty.dodge_chance = 1.0  # (que siempre decida reaccionar: acá se prueba el cómo, no el azar)
	GameState.difficulty.aim_error_deg = 0.0
	CombatBody.debug_threats = debug
	var me: Creature = world.companion
	me.instance.level = 40  # (barra de PP para Hidrobomba y Lanzallamas)
	me.instance.hp = me.instance.max_hp()
	me.health.invulnerable_time = 9999.0
	me.input_source = NetCombatInput.new()  # mudo: que la carga y el chorro apunten adonde se los tiró
	await get_tree().physics_frame
	# Un lugar del pueblo con 200 px despejados en alguna dirección: ahí se arman los escenarios.
	var rect: Rect2 = world.streamer.current.world_rect(world.streamer.world_data.tile_size)
	var y := rect.position.y + 48.0
	while d == Vector2.ZERO and y < rect.end.y - 48.0:
		var x := rect.position.x + 48.0
		while d == Vector2.ZERO and x < rect.end.x - 48.0:
			var tags: PackedStringArray = world.tags_at(Vector2(x, y))
			if not ("solido" in tags or "agua" in tags or "arbol" in tags):
				var dir := _clear_line(Vector2(x, y), 200.0)
				if dir != Vector2.ZERO:
					d = dir
					me.global_position = Vector2(x, y)
					world.trainer.global_position = Vector2(x, y) - dir * 24.0
			x += 32.0
		y += 32.0
	perp = d.orthogonal()
	await get_tree().physics_frame
	r["Hay una línea de tiro despejada de 200 px (%s desde %s)" % [str(d), str(me.global_position)]] = d != Vector2.ZERO
	if d == Vector2.ZERO:
		_results()
		return
	var hits := {}
	Events.creature_damaged.connect(func(c, _a, h): if h != null: hits[c] = hits.get(c, 0) + 1)

	# --- 1. Un disparo común en línea: da un paso al costado, sin gastar el esquive, y no lo toca ---
	var ai := _ai(me, 190.0)
	var dodges := [0]
	ai.dodged.connect(func(): dodges[0] += 1)
	me.moves.slots[0] = DB.moves["pistola_agua"]
	var p0 := ai.global_position
	_fire(me, d)
	await get_tree().physics_frame
	var th: Dictionary = ai.mind.threat()
	r["Ve venir el disparo (shot, eta %.2f s, sale perpendicular)" % th.get("eta", -1.0)] = th.get("kind") == "shot" \
		and float(th.get("eta", 0.0)) > 0.2 and absf((th.get("out", Vector2.ZERO) as Vector2).dot(d)) < 0.01
	await _react(ai, 1.2)
	var off := _off_line(ai, p0)
	r["Da un paso al costado y el disparo no lo toca (se corrió %.0f px, esquives %d, golpes %d)" % [off, dodges[0], hits.get(ai, 0)]] = \
		off > 10.0 and dodges[0] == 0 and hits.get(ai, 0) == 0
	# Un disparo que no viene hacia él no es amenaza.
	_fire(me, -d)
	await get_tree().physics_frame
	r["Un disparo que va para otro lado no es amenaza"] = ai.mind.threat().is_empty()
	await get_tree().create_timer(1.0).timeout
	ai.queue_free()

	# --- 2. Un disparo fuerte (tira): esquiva con el botón, justo antes de que llegue ---
	ai = _ai(me, 190.0)
	dodges[0] = 0
	ai.dodged.connect(func(): dodges[0] += 1)
	var strong: MoveData = DB.moves["pistola_agua"].duplicate()
	strong.knockback = Creature.STAGGER_KNOCKBACK + 40.0
	me.moves.slots[0] = strong
	_fire(me, d)
	await get_tree().physics_frame
	th = ai.mind.threat()
	r["Un disparo fuerte se ve como fuerte"] = th.get("kind") == "shot" and bool(th.get("strong", false))
	await _react(ai, 1.2)
	r["Al fuerte lo esquiva rodando (esquives %d, golpes %d) y no lo toca" % [dodges[0], hits.get(ai, 0)]] = dodges[0] == 1 and hits.get(ai, 0) == 0
	await get_tree().create_timer(1.0).timeout
	ai.queue_free()

	# --- 3. Una carga apuntada (Hidrobomba, línea en el piso): se sale de la franja antes de que salga ---
	ai = _ai(me, 120.0)
	me.moves.slots[0] = DB.moves["hidrobomba"]
	p0 = ai.global_position
	_fire(me, d)
	await get_tree().physics_frame
	th = ai.mind.threat()
	r["Ve la carga apuntada (cast, eta %.2f s)" % th.get("eta", -1.0)] = th.get("kind") == "cast" and me.machine.current_name() == "cast"
	await _react(ai, 0.45)
	off = _off_line(ai, p0)
	await _react(ai, 1.0)
	r["Se corre de la franja antes de que salga (%.0f px) y la Hidrobomba no lo toca" % off] = off > 12.0 and hits.get(ai, 0) == 0
	await get_tree().create_timer(0.8).timeout
	ai.queue_free()

	# --- 4. Rayo marcado en el piso: sale del círculo antes de que caiga ---
	ai = _ai(me, 100.0)
	me.moves.slots[0] = DB.moves["rayo"]
	var center := ai.global_position
	_fire(me, d, center)
	await get_tree().physics_frame
	th = ai.mind.threat()
	r["Ve la marca del Rayo (zone, eta %.2f s)" % th.get("eta", -1.0)] = th.get("kind") == "zone" and float(th.get("eta", 0.0)) > 0.3
	await _react(ai, 0.5)
	var away := ai.global_position.distance_to(center)
	await _react(ai, 0.6)
	r["Sale del círculo antes de que caiga (%.0f px del centro) y el Rayo no lo toca" % away] = away > 20.0 and hits.get(ai, 0) == 0
	await get_tree().create_timer(0.5).timeout
	ai.queue_free()

	# --- 5. Un chorro (Lanzallamas) que lo barre: se corre del cono ---
	ai = _ai(me, 90.0)
	me.moves.slots[0] = DB.moves["lanzallamas"]
	p0 = ai.global_position
	_fire(me, d)
	await get_tree().physics_frame
	await get_tree().physics_frame
	th = ai.mind.threat()
	r["Ve el chorro (beam)"] = th.get("kind") == "beam"
	await _react(ai, 0.9)
	off = _off_line(ai, p0)
	r["Se corre del chorro (%.0f px)" % off] = off > 12.0
	await get_tree().create_timer(0.5).timeout
	ai.queue_free()
	me.moves.slots[0] = DB.moves["pistola_agua"]
	for i in range(1, MoveUser.SLOT_COUNT):
		me.moves.slots[i] = null  # (sin ataques fuertes: así no hay "ventana" y se ve qué hace mientras se cuida)

	# --- 6. Bajo fuego: un cuerpo a cuerpo que se come dos disparos viniendo de frente deja de venir de frente ---
	var melee: Creature = world.spawner.spawn(DB.species["rattata"], 40, me.global_position + d * 200.0)
	melee.get_node("StateMachine/Wander").aggro_radius = 0.0
	melee.home = melee.global_position
	melee.target = me
	melee.machine.transition_to("attack")
	var mind: TacticalMind = melee.mind
	await get_tree().physics_frame
	GameState.difficulty.dodge_chance = 0.0  # (que no esquive ni se corra: acá se mide qué hace después de comerse los golpes)
	var t := 0.0
	var shoot := 0.0
	while t < 6.0 and mind.wary_count == 0 and is_instance_valid(melee) and not melee.is_down():
		me.moves.set_pp(me.moves.max_pp())  # (con la barra vacía tus fuertes no salen y eso ya es una ventana para entrar)
		shoot -= get_physics_process_delta_time()
		if shoot <= 0.0:
			shoot = 0.3
			_fire(me, (melee.global_position - me.global_position).normalized())
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	var dist_then: float = melee.global_position.distance_to(me.global_position) if is_instance_valid(melee) else 0.0
	r["Bajo fuego: tras %d golpes de frente se pone a cubierto (en %.1f s, a %.0f px)" % [hits.get(melee, 0), t, dist_then]] = \
		is_instance_valid(melee) and mind.wary_count >= 1 and mind.wary() and dist_then > 70.0
	# Mientras se cuida: no entra en línea recta (se queda lejos o entra en zigzag), aunque le siga disparando.
	var straight := 0
	var frames := 0
	var min_dist := INF
	t = 0.0
	while t < 1.5 and is_instance_valid(melee) and mind.wary():
		me.moves.set_pp(me.moves.max_pp())
		shoot -= get_physics_process_delta_time()
		if shoot <= 0.0:
			shoot = 0.3
			_fire(me, (melee.global_position - me.global_position).normalized())
		var to: Vector2 = (me.global_position - melee.global_position).normalized()
		if melee.velocity.length() > 20.0 and melee.velocity.normalized().dot(to) > 0.95 \
				and melee.global_position.distance_to(me.global_position) > 60.0:
			straight += 1
		frames += 1
		min_dist = minf(min_dist, melee.global_position.distance_to(me.global_position))
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	r["Mientras se cuida no viene en línea recta (%d de %d cuadros) y no se te pega (mín. %.0f px)" % [straight, frames, min_dist]] = \
		frames > 20 and straight < frames * 0.15 and min_dist > 55.0
	if is_instance_valid(melee):
		melee.queue_free()

	_results()


## Una dirección (de las 4) en la que hay `length` px de suelo libre (sin nada sólido ni agua) desde `from`, con
## lugar a los costados para correrse; ZERO si no hay.
func _clear_line(from: Vector2, length: float) -> Vector2:
	for dir in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		var ok := true
		var k := 16.0
		while ok and k <= length + 24.0:
			for side in [-1.0, 0.0, 1.0]:
				var tags: PackedStringArray = world.tags_at(from + dir * k + dir.orthogonal() * side * 28.0)
				if "solido" in tags or "agua" in tags or "arbol" in tags:
					ok = false
			k += 16.0
		if ok:
			return dir
	return Vector2.ZERO


## Cuánto se corrió de la línea de tiro (perpendicular a `d`) desde `p0`.
func _off_line(ai: Creature, p0: Vector2) -> float:
	return absf((ai.global_position - p0).dot(perp))


## Dispara la ranura 0 con la barra llena y sin recarga.
func _fire(me: Creature, aim: Vector2, point: Vector2 = Vector2.INF) -> void:
	me.moves.reset_cooldown(0)
	me.moves.set_pp(me.moves.max_pp())
	var ok := me.use_slot(0, aim, point)
	if debug:
		print("[ai-threat] dispara %s: %s (estado %s)" % [me.moves.slots[0].id, ok, me.machine.current_name()])


## Un rival de prueba a `dist` px de tu Pokémon, en la línea despejada, que te apunta pero no decide nada solo (está
## "controlado" por un input mudo, con la máquina andando porque el esquive es un estado): el test le hace mirar la
## amenaza y dar el paso, como lo haría el estado de ataque.
func _ai(me: Creature, dist: float) -> Creature:
	var ai: Creature = autotest._dummy(world, "pikachu", me.global_position + d * dist, false)
	ai.player_controlled = true
	ai.input_source = NetCombatInput.new()
	ai.machine.transition_to("controlled")
	ai.target = me
	ai.home = ai.global_position
	me.target = ai
	return ai


## Como el estado de ataque: cada cuadro reacciona a la amenaza y sigue el paso al costado si lo hay.
func _react(ai: Creature, seconds: float) -> void:
	var t := 0.0
	while t < seconds and is_instance_valid(ai):
		if not ai.body.try_dodge():
			var step: Vector2 = ai.body.sidestep_dir()
			if step != Vector2.ZERO:
				ai.move(step, ai.speed() * CombatBody.SIDESTEP_SPEED)
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


func _results() -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[ai-threat] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-ai-threat] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
