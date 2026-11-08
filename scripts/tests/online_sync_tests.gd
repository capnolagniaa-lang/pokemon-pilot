class_name OnlineSyncTests
extends Node
## Autotest de la pelea online a fondo (docs/ONLINE_INFORME.md): lo que viaja por la red y cómo se queda sincronizado.
##   godot --headless --path . --quit-after 400000 -- --autotest-online-sync [--only paquetes|equipo|formas|lag|varias|mundo]
## Partes:
##   · Paquetes de teclas (NetCombatInput): un toque de un solo cuadro no se pierde (contadores), y la basura se ignora.
##   · Equipo trucho (clean_battle_team): nivel, habilidad, ataques que no aprende, IV, vida, apodo.
##   · Cada forma de ataque en el servidor (disparo, cuerpo a cuerpo, Surf montado, Rayo del cielo, canalizado, Excavar,
##     clima, mejora propia): el aviso "use", el golpe, y que la copia del rival (`force_move`) lo haga igual.
##   · Red con demora y pérdida simuladas: los toques llegan igual y los hechos llegan en orden.
##   · Varias peleas a la vez: lugares distintos, clima por pelea, todas terminan, cuánto tarda el servidor por cuadro.
##   · Con el mundo: la vida en el aviso "send", la gracia de los estados, el golpe fuerte corta la carga de la copia, y
##     si se corta la conexión en plena pelea la arena se cierra y se puede caminar.

const PORT := 24791

var autotest: Node
var world: Node
var r := {}
var server: NetPeer
## Peer → lista de hechos recibidos; peer → última foto.
var ev := {}
var st := {}


## Manda las teclas de un jugador como lo hace OnlineBattle (con los contadores de toques y de esquives).
class Driver:
	var peer: NetPeer
	var mid: int
	var prev_bits := 0
	var press_seq := [0, 0, 0, 0]
	var dodge_seq := 0

	func _init(p: NetPeer, m: int) -> void:
		peer = p
		mid = m

	func packet(move: Vector2, aim: Vector2, point: Vector2, bits: int) -> Array:
		prev_bits = NetCombatInput.count_presses(prev_bits, bits, press_seq)
		return [move, aim, point, bits, dodge_seq, NetCombatInput.pack_presses(press_seq)]

	func send(move: Vector2, aim: Vector2, point: Vector2, bits: int) -> void:
		peer.send_battle_input(mid, packet(move, aim, point, bits))


func run() -> void:
	GameState.new_game(DB.species["charmander"])
	server = _peer("Server")
	r["El servidor abre el puerto"] = server.host(PORT, Net.game_version()) == OK
	r["El servidor no deja que los clientes se hablen entre ellos (server_relay apagado)"] = not server._api.server_relay
	var args := OS.get_cmdline_user_args()
	var only := args[args.find("--only") + 1] if "--only" in args and args.find("--only") + 1 < args.size() else ""
	if only in ["", "paquetes"]:
		await _packet_tests()
	if only in ["", "equipo"]:
		_team_tests()
	if only in ["", "formas"]:
		await _shape_tests()
	if only in ["", "lag"]:
		await _lag_tests()
	if only in ["", "varias"]:
		await _many_tests()
	if only in ["", "mundo"]:
		await _world_tests()
	_results()


# --- Paquetes -------------------------------------------------------------------------------------

func _packet_tests() -> void:
	var inp := NetCombatInput.new()
	inp.set_packet([Vector2.ZERO, Vector2.RIGHT, Vector2(10, 0), 0, 0, 0])
	r["Paquete: sin bit ni toque, no quiere atacar"] = not inp.wants_slot(0)
	# El paquete con el bit se perdió; el siguiente trae el contador avanzado: el toque llega igual.
	inp.set_packet([Vector2.ZERO, Vector2.RIGHT, Vector2(10, 0), 0, 0, NetCombatInput.pack_presses([1, 0, 0, 0])])
	r["Paquete: un toque cuyo paquete se perdió llega con el contador"] = inp.wants_slot(0) and not inp.wants_slot(1)
	inp.set_packet([Vector2.ZERO, Vector2.RIGHT, Vector2(10, 0), 0, 0, NetCombatInput.pack_presses([1, 0, 0, 0])])
	r["Paquete: el toque dura %d ms aunque llegue otro paquete en el mismo cuadro" % NetCombatInput.PRESS_HOLD_MS] = inp.wants_slot(0)
	var t_before := Time.get_ticks_msec()
	await _until(func(): return Time.get_ticks_msec() - t_before > NetCombatInput.PRESS_HOLD_MS + 50, 2.0)  # (reloj real)
	r["Paquete: el mismo contador no vale por dos toques"] = not inp.wants_slot(0)
	inp.set_packet([Vector2.ZERO, Vector2.RIGHT, Vector2(10, 0), 0b1000, 0, NetCombatInput.pack_presses([1, 0, 0, 2])])
	r["Paquete: el bit apretado y el contador de otra ranura, los dos valen"] = inp.wants_slot(3) and not inp.wants_slot(0)
	# Contadores del lado que manda.
	var seq := [0, 0, 0, 0]
	var prev := NetCombatInput.count_presses(0, 0b0001, seq)
	prev = NetCombatInput.count_presses(prev, 0b0001, seq)  # sigue apretado: no es otro toque
	prev = NetCombatInput.count_presses(prev, 0b0000, seq)
	prev = NetCombatInput.count_presses(prev, 0b0101, seq)
	r["Contadores: suben al apretar, no al mantener (%s)" % str(seq)] = seq == [2, 0, 1, 0]
	r["Contadores: dan la vuelta a los 256 sin romperse"] = NetCombatInput.pack_presses([255, 0, 0, 0]) == 255 \
		and NetCombatInput.count_presses(0, 1, [255, 0, 0, 0]) == 1
	# Basura: se ignora sin romper nada.
	var bad := NetCombatInput.new()
	bad.set_packet([Vector2.ZERO, Vector2.RIGHT, Vector2(10, 0), 0, 0, 0])
	bad.set_packet([Vector2(INF, NAN), Vector2(1e9, 0), "x", "a", null, 1e30])
	r["Basura: NaN, infinitos y textos se ignoran (queda lo de antes)"] = bad.move == Vector2.ZERO and bad.aim_vec == Vector2.RIGHT \
		and bad.point == Vector2(10, 0) and bad.slots == 0 and bad.move.is_finite()
	bad.set_packet([Vector2(5, 5), Vector2.LEFT, Vector2(-20, 3), 0b1111, 1, 0])
	print("[online-sync] movimiento recortado: %s" % str(bad.move))
	r["Basura: un movimiento más largo que 1 se recorta"] = is_equal_approx(bad.move.length(), 1.0) and bad.slots == 0b1111
	bad.set_packet([1, 2])
	r["Basura: un paquete corto se ignora"] = bad.slots == 0b1111
	bad.set_packet([Vector2.ZERO, Vector2.ZERO, Vector2(NAN, 0), 0, 0, 0])
	r["Basura: un punto NaN no entra"] = bad.point == Vector2(-20, 3)


# --- Equipo trucho --------------------------------------------------------------------------------

func _team_tests() -> void:
	var pika: SpeciesData = DB.species["pikachu"]
	var fake := {"species_id": "pikachu", "level": 999, "ability": "levitacion", "ivs": {"attack": 99, "speed": -5},
		"equipped_moves": ["lanzallamas", "impactrueno", "hiperrayo", "placaje"], "hp": 99999.0, "hp_ratio": 7.0,
		"nickname": "  <<Un apodo larguísimo y raro>>  "}
	var team := NetPeer.clean_battle_team(["basura", {}, {"species_id": "no_existe"}, fake,
		CreatureInstance.create(DB.species["eevee"], 10).to_dict(), CreatureInstance.create(DB.species["pidgey"], 10).to_dict()], 2)
	r["Equipo trucho: la basura se salta y no pasa del formato (%d)" % team.size()] = team.size() == 2 \
		and team[0].species_id == "pikachu" and team[1].species_id == "eevee"
	var d: Dictionary = team[0] if not team.is_empty() else {}
	var inst := CreatureInstance.from_dict(d) if not d.is_empty() else null
	r["Equipo trucho: nivel 999 → 100"] = inst != null and inst.level == 100
	r["Equipo trucho: una habilidad ajena → una de su especie"] = inst != null \
		and inst.ability in pika.abilities.map(func(a): return a.id)
	var ids: Array = inst.equipped_moves.filter(func(m): return m != null).map(func(m): return m.id) if inst != null else []
	r["Equipo trucho: ataques que no aprende afuera, los suyos quedan (%s)" % str(ids)] = inst != null \
		and not ids.has("lanzallamas") and not ids.has("hiperrayo") and ids.has("impactrueno")
	r["Equipo trucho: IV de 0 a 31"] = inst != null and inst.ivs["attack"] == 31 and inst.ivs["speed"] == 0
	r["Equipo trucho: la vida en proporción, a lo sumo 1"] = not d.is_empty() and d.hp_ratio == 1.0
	r["Equipo trucho: apodo limpio y corto (\"%s\")" % d.get("nickname", "")] = not d.is_empty() and d.nickname.length() <= 12 \
		and not d.nickname.begins_with(" ")
	var ok := NetPeer.clean_battle_team([CreatureInstance.create(pika, 20).to_dict()], 3)
	var ok_inst := CreatureInstance.from_dict(ok[0]) if not ok.is_empty() else null
	r["Equipo sano: pasa entero (ataques, habilidad, nivel)"] = ok_inst != null and ok_inst.level == 20 \
		and ok_inst.equipped_moves.filter(func(m): return m != null).size() >= 1 and ok[0].hp_ratio == 1.0


# --- Cada forma de ataque -------------------------------------------------------------------------

func _shape_tests() -> void:
	var a := _join("A", "Ash")
	var b := _join("B", "Gary")
	await _until(func(): return a.state == "online" and b.state == "online" and a.players.size() == 2)
	var mid := await _start_match(a, b, [CreatureInstance.create(DB.species["pikachu"], 40)],
		[CreatureInstance.create(DB.species["snorlax"], 40)])
	r["Formas: la pelea arranca"] = mid > 0 and server.battles.has(mid)
	if mid <= 0:
		return
	var nm: NetMatch = server.battles[mid]
	var me: Creature = nm.sides[a.my_id].creature
	var foe: Creature = nm.sides[b.my_id].creature
	# La copia del rival en una pantalla: un Pokémon igual, manejado por un NetCombatInput que no ataca solo.
	var stage := Node2D.new()
	stage.position = Vector2(-80000, -80000)
	add_child(stage)
	var copy: Creature = WildSpawner.CreatureScene.instantiate()
	copy.instance = CreatureInstance.create(DB.species["pikachu"], 40)
	copy.team = Creature.Team.WILD
	copy.player_controlled = true
	var copy_input := NetCombatInput.new()
	copy_input.attacks = false
	copy.input_source = copy_input
	copy.owner_name = "copia"
	stage.add_child(copy)
	copy.machine.transition_to.call_deferred("controlled")
	var drv := Driver.new(a, mid)
	await get_tree().create_timer(NetMatch.COUNTDOWN + 0.2).timeout
	var shapes := [
		["impactrueno", "disparo", 40.0, true], ["agarre", "cuerpo a cuerpo", 22.0, true],
		["surf", "montado en la ola (ride)", 40.0, true], ["rayo", "zona que cae del cielo", 40.0, true],
		["lanzallamas", "canalizado", 40.0, true], ["danza_lluvia", "clima", 40.0, false],
		["danza_espada", "mejora propia", 40.0, false], ["excavar", "Excavar en dos tiempos", 20.0, true],
	]
	var copy_used := []
	var on_used := func(c, m): if c == copy: copy_used.append(m.id)
	Events.move_used.connect(on_used)
	for sh in shapes:
		var id: String = sh[0]
		var m: MoveData = DB.moves[id]
		for c in [me, copy]:
			c.moves.slots[0] = m
			c.moves.reset_cooldown(0)
			c.moves.set_pp(c.moves.max_pp())
			c.hitstun_left = 0.0
			if c.machine.current_name() != "controlled":
				c.machine.transition_to("controlled")
		me.global_position = nm._cell_pos(nm.sides[a.my_id].cell)
		me.knockback = Vector2.ZERO
		foe.global_position = me.global_position + Vector2(sh[2], 0)
		foe.knockback = Vector2.ZERO
		foe.hitstun_left = 0.0
		foe.instance.hp = foe.instance.max_hp()
		var hp0: float = foe.health.hp()
		ev[a].clear()
		var pt: Vector2 = foe.global_position - nm.arena.global_position
		for i in 3:
			drv.send(Vector2.ZERO, Vector2.RIGHT, pt, 1)
			await get_tree().physics_frame
		for i in 4:
			drv.send(Vector2.ZERO, Vector2.RIGHT, pt, 0)
			await get_tree().physics_frame
		await _until(func(): return not _uses(a, a.my_id, id).is_empty(), 3.0)
		var uses: Array = _uses(a, a.my_id, id)
		var use_ok := not uses.is_empty() and uses[0].get("aim") is Vector2
		if id == "excavar":  # el segundo toque lo saca (con la tecla soltada antes)
			await get_tree().create_timer(0.4).timeout
			var bw_in: bool = st[a].get(a.my_id, {}).get("bw", false)
			for i in 3:
				drv.send(Vector2.ZERO, Vector2.RIGHT, pt, 1)
				await get_tree().physics_frame
			for i in 4:
				drv.send(Vector2.ZERO, Vector2.RIGHT, pt, 0)
				await get_tree().physics_frame
			await _until(func(): return _uses(a, a.my_id, id).size() >= 2, 3.0)
			use_ok = use_ok and bw_in and _uses(a, a.my_id, id).size() == 2
		if sh[3]:
			await _until(func(): return not _hits(a, b.my_id).is_empty(), 3.5)
		var hit_ok: bool = (not sh[3]) or (not _hits(a, b.my_id).is_empty() and foe.health.hp() < hp0)
		var extra := true
		match id:
			"surf":
				extra = uses.size() > 0 and uses[0].get("pt") is Vector2
			"danza_lluvia":
				extra = CombatWeather.kind_for(me) == "lluvia" and CombatWeather.current == ""
			"danza_espada":
				extra = me.statuses.has_status("potenciado") and st[a].get(a.my_id, {}).get("st", []).has("potenciado")
		r["Servidor · %s (%s): aviso \"use\", %s" % [m.display_name, sh[1], "golpe en el rival" if sh[3] else "efecto"]] = use_ok and hit_ok and extra
		# La copia del rival: lo hace con el aviso, sin mirar recargas ni PP.
		copy_used.clear()
		copy.moves.cooldowns[0] = 99.0
		copy.moves.set_pp(0.0)
		copy.hitstun_left = 0.5
		var ok_copy := false
		if not uses.is_empty():
			var u: Dictionary = uses[0]
			var p: Vector2 = stage.global_position + u.pt if u.get("pt") is Vector2 else Vector2.INF
			ok_copy = copy.force_move(id, u.aim, p)
			await get_tree().physics_frame
			await get_tree().physics_frame
			match id:
				"surf":
					ok_copy = ok_copy and (copy.machine.current_name() in ["cast", "ride"])
				"lanzallamas":
					ok_copy = ok_copy and copy.machine.current_name() == "channel"
				"rayo":
					ok_copy = ok_copy and stage.get_children().any(func(n): return n is SkyStrike)
				"excavar":
					ok_copy = ok_copy and copy.is_burrowed() and copy.burrow.remote
					if ok_copy:
						ok_copy = copy.force_move(id, u.aim, Vector2.INF) and not copy.is_burrowed()
				"danza_lluvia":
					ok_copy = ok_copy and CombatWeather.current == "lluvia"
					CombatWeather.stop(get_tree())
				"danza_espada":
					ok_copy = ok_copy and copy.statuses.has_status("potenciado")
		r["Copia del rival · %s: force_move lo hace igual (recarga y PP de la copia no importan)" % m.display_name] = ok_copy \
			and copy_used == [id]
		await get_tree().create_timer(1.6).timeout  # (que termine: ola, canalizado, recuperación)
		for c in [me, copy]:
			if c.is_burrowed():
				c.burrow.finish()
			if c.machine.current_name() != "controlled":
				c.machine.transition_to("controlled")
	Events.move_used.disconnect(on_used)
	# El golpe fuerte que llega del servidor corta la carga de la copia (como en el servidor).
	copy.moves.slots[0] = DB.moves["surf"]
	copy.force_move("surf", Vector2.RIGHT, copy.global_position + Vector2(60, 0))
	await get_tree().physics_frame
	var casting := copy.machine.current_name() == "cast"
	if (Vector2(300, 0)).length() >= Creature.STAGGER_KNOCKBACK and casting:
		copy.stun(0.25)
	r["Copia del rival: un golpe fuerte le corta la carga (stun)"] = casting and copy.machine.current_name() == "stunned"
	# El rival nunca ataca por sus teclas en la copia (solo con el aviso).
	copy_used.clear()
	Events.move_used.connect(on_used)
	copy.moves.slots[0] = DB.moves["impactrueno"]
	copy.moves.reset_cooldown(0)
	copy.moves.set_pp(copy.moves.max_pp())
	await get_tree().create_timer(0.4).timeout
	copy.machine.transition_to("controlled")
	copy_input.set_packet([Vector2.ZERO, Vector2.RIGHT, Vector2.ZERO, 0b1111, 0, NetCombatInput.pack_presses([3, 3, 3, 3])])
	for i in 6:
		await get_tree().physics_frame
	r["Copia del rival: con sus teclas (bits y contadores) no ataca sola"] = copy_used.is_empty()
	Events.move_used.disconnect(on_used)
	# Cambios: reglas del servidor.
	nm.sides[a.my_id].switch_cd = 0.0
	r["Cambio: al mismo, a uno que no existe o a uno debilitado, no"] = not nm.request_switch(a.my_id, 0) \
		and not nm.request_switch(a.my_id, 5) and not nm.request_switch(a.my_id, -1)
	stage.queue_free()
	nm.finish(a.my_id, "")
	await _until(func(): return server.battles.is_empty() and _entry(a, a.my_id).get("status") == "libre")
	a.close()
	b.close()
	await _until(func(): return server.players.is_empty())


# --- Red con demora y pérdida ---------------------------------------------------------------------

func _lag_tests() -> void:
	var a := _join("LagA", "Lento")
	var b := _join("LagB", "Quieto")
	await _until(func(): return a.state == "online" and b.state == "online" and a.players.size() == 2)
	var mid := await _start_match(a, b, [CreatureInstance.create(DB.species["pikachu"], 40)],
		[CreatureInstance.create(DB.species["snorlax"], 40)])
	if mid <= 0:
		r["Lag: la pelea arranca"] = false
		return
	var nm: NetMatch = server.battles[mid]
	var me: Creature = nm.sides[a.my_id].creature
	var foe: Creature = nm.sides[b.my_id].creature
	me.moves.slots[0] = DB.moves["impactrueno"]
	await get_tree().create_timer(NetMatch.COUNTDOWN + 0.2).timeout
	server.sim_latency_ms = 120
	server.sim_loss = 0.35
	a.sim_latency_ms = 120
	a.sim_loss = 0.35
	var drv := Driver.new(a, mid)
	ev[a].clear()
	var times := []
	var on_state := func(_mid, s): times.append(float(s.get("t", 0.0)))
	a.battle_state_received.connect(on_state)
	# 12 toques de un solo cuadro, con el 35 % de los paquetes perdidos: con los contadores llegan todos.
	for k in 12:
		me.moves.reset_cooldown(0)
		me.moves.set_pp(me.moves.max_pp())
		me.hitstun_left = 0.0
		foe.global_position = me.global_position + Vector2(40, 0)
		drv.send(Vector2.ZERO, Vector2.RIGHT, Vector2.ZERO, 1)
		await get_tree().physics_frame
		for i in 24:
			drv.send(Vector2.ZERO, Vector2.RIGHT, Vector2.ZERO, 0)
			await get_tree().physics_frame
	await get_tree().create_timer(0.6).timeout
	var uses := _uses(a, a.my_id, "impactrueno").size()
	r["Lag (120 ms, 35 %% perdidos): los 12 toques de un cuadro llegan al servidor (%d)" % uses] = uses >= 11
	var ordered := true
	for i in range(1, times.size()):
		if times[i] < times[i - 1]:
			ordered = false
	r["Lag: las fotos llegan en orden (%d fotos)" % times.size()] = ordered and times.size() > 10
	var first_kinds: Array = ev[a].map(func(e): return e.t)
	r["Lag: los hechos llegan (golpes) y nunca un \"end\" antes de tiempo"] = first_kinds.has("hit") and not first_kinds.has("end")
	a.battle_state_received.disconnect(on_state)
	for p in [server, a]:
		p.sim_latency_ms = 0
		p.sim_loss = 0.0
	nm.finish(a.my_id, "")
	await _until(func(): return server.battles.is_empty())
	a.close()
	b.close()
	await _until(func(): return server.players.is_empty())


# --- Varias peleas a la vez -----------------------------------------------------------------------

func _many_tests() -> void:
	const N := 6
	var pairs := []
	for k in N:
		var a := _join("MA%d" % k, "Rojo %d" % k)
		var b := _join("MB%d" % k, "Azul %d" % k)
		pairs.append([a, b])
	await _until(func(): return pairs.all(func(p): return p[0].state == "online" and p[1].state == "online"), 10.0)
	var mids := []
	for p in pairs:
		mids.append(await _start_match(p[0], p[1], [CreatureInstance.create(DB.species["mewtwo"], 70)],
			[CreatureInstance.create(DB.species["caterpie"], 5), CreatureInstance.create(DB.species["weedle"], 5)]))
	r["Varias: %d peleas arrancan a la vez" % N] = mids.all(func(m): return m > 0) and server.battles.size() == N
	var positions := server.battles.values().map(func(nm): return nm.position)
	var distinct := true
	for i in positions.size():
		for j in range(i + 1, positions.size()):
			if positions[i].distance_to(positions[j]) < NetPeer.ARENA_GAP * 0.5:
				distinct = false
	r["Varias: cada pelea en su lugar, lejos de las demás"] = distinct
	# Clima por pelea: la lluvia de una no moja a la otra.
	var c1: Creature = server.battles[mids[0]].sides[pairs[0][0].my_id].creature
	var c2: Creature = server.battles[mids[1]].sides[pairs[1][0].my_id].creature
	var water: ElementType = DB.types["agua"]
	CombatWeather.start("lluvia", c1)
	r["Clima por pelea: la lluvia de una pelea no toca a la otra ni al juego del jugador"] = CombatWeather.kind_for(c1) == "lluvia" \
		and CombatWeather.kind_for(c2) == "" and CombatWeather.current == "" \
		and CombatWeather.damage_mult(water, c1) == 1.5 and CombatWeather.damage_mult(water, c2) == 1.0 \
		and CombatWeather.damage_mult(water) == 1.0
	# Todos pelean (los A atacan a su rival) hasta que terminen.
	var drivers := []
	for k in N:
		drivers.append(Driver.new(pairs[k][0], mids[k]))
	await get_tree().create_timer(NetMatch.COUNTDOWN).timeout
	var t := 0.0
	var frames := 0
	var physics_ms := 0.0
	while t < 60.0 and not server.battles.is_empty():
		for k in N:
			var a: NetPeer = pairs[k][0]
			var me: Dictionary = st[a].get(a.my_id, {})
			var foe: Dictionary = st[a].get(pairs[k][1].my_id, {})
			if me.is_empty() or foe.is_empty():
				continue
			var to: Vector2 = foe.p - me.p
			drivers[k].send(to.normalized() if to.length() > 26.0 else Vector2.ZERO, to, foe.p, 0b1111)
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		frames += 1
		physics_ms += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var avg_ms := physics_ms / maxf(1.0, frames)
	print("[online-sync] %d peleas a la vez: %.1f ms de física por cuadro en promedio, terminaron en %.0f s" % [N, avg_ms, t])
	var ends := pairs.map(func(p): return ev[p[0]].filter(func(e): return e.t == "end").size())
	r["Varias: las %d terminan solas, cada una con su ganador (%s)" % [N, str(ends)]] = server.battles.is_empty() \
		and ends.all(func(n): return n == 1)
	r["Varias: el servidor aguanta (%.1f ms de física por cuadro, con %d peleas)" % [avg_ms, N]] = avg_ms < 12.0
	r["Clima por pelea: al terminar la pelea se va su clima"] = CombatWeather.scopes.is_empty()
	# Un lugar que se liberó se vuelve a usar (no se enciman la 1.ª y la 17.ª).
	var mid2 := await _start_match(pairs[0][0], pairs[0][1], [CreatureInstance.create(DB.species["pikachu"], 10)],
		[CreatureInstance.create(DB.species["eevee"], 10)])
	r["Varias: una pelea nueva toma el primer lugar libre"] = mid2 > 0 and server.battles.has(mid2) \
		and int(server.battles[mid2].get_meta("arena_slot")) == 0
	if mid2 > 0 and server.battles.has(mid2):
		server.battles[mid2].finish(pairs[0][0].my_id, "")
	await _until(func(): return server.battles.is_empty())
	for p in pairs:
		p[0].close()
		p[1].close()
	await _until(func(): return server.players.is_empty())


# --- Con el mundo ---------------------------------------------------------------------------------

func _world_tests() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await get_tree().physics_frame
	Net.address = "127.0.0.1"
	Net.port = PORT
	Net.go_online()
	var gary := _join("Gary", "Gary", [{"species": "magikarp", "level": 3}])
	await _until(func(): return Net.is_online() and gary.state == "online" and Net.players.size() == 2, 10.0)
	var battle: OnlineBattle = world.online.battle
	var mon: CreatureInstance = GameState.party[0]
	mon.level = 30
	mon.hp = mon.max_hp()
	world.online.open_lobby()
	await get_tree().process_frame
	var lobby: OnlineLobbyScreen = world.online.screen
	var chose := [0]
	gary.match_choose.connect(func(mid, _o, _c, _t): chose[0] = mid)
	gary.send_challenge(Net.client.my_id, 3)  # (3 contra 3: Gary lleva 2 y vos 1, el único que tenés)
	await _until(func(): return not lobby.incoming.is_empty())
	lobby.accept_incoming()
	await _until(func(): return lobby.step == "elegir" and chose[0] != 0)
	battle.local_input = NetCombatInput.new()  # quieto: acá se prueban los avisos, no la pelea (nadie se debilita)
	lobby.toggle_pick(0)
	lobby.confirm_pick()
	var karp := CreatureInstance.create(DB.species["magikarp"], 3)
	gary.send_choice(chose[0], [karp, CreatureInstance.create(DB.species["magikarp"], 3)])
	await _until(func(): return battle.active and battle._going, 20.0)
	r["Mundo: la pelea arranca contra Gary"] = battle.active and battle._going and is_instance_valid(battle.foe)
	if not battle.active:
		return
	var mid := battle.match_id
	var opp := int(battle.opponent.get("id", 0))
	# El aviso "send" trae la vida de ahora: el que vuelve a salir aparece con la que tiene, no con la de cuando eligió.
	battle._on_event(mid, {"t": "send", "side": opp, "index": 1, "p": battle.foe.global_position - battle.arena.global_position, "hp": 0.4})
	r["Mundo: el \"send\" trae la vida de ahora (sale con el 40 %)"] = is_instance_valid(battle.foe) \
		and is_equal_approx(battle.foe.health.ratio(), 0.4) and world.combat.enemies.has(battle.foe)
	await get_tree().physics_frame  # (el que acaba de salir entra a "controlled" en diferido)
	# Gracia de estados: lo que tu pantalla acaba de poner no lo borra una foto vieja.
	var me: Creature = world.companion
	me.statuses.apply(DB.statuses["potenciado"])
	battle._sync_statuses(me, [])
	var kept := me.statuses.has_status("potenciado")
	me.statuses.active["potenciado"]["time"] = 1.0
	battle._sync_statuses(me, [])
	r["Mundo: un estado recién puesto acá sobrevive a una foto sin él; uno viejo que el servidor no tiene se va"] = kept \
		and not me.statuses.has_status("potenciado")
	battle._sync_statuses(me, ["quemado"])
	r["Mundo: un estado que trae la foto se pone"] = me.statuses.has_status("quemado")
	battle._sync_statuses(me, [])
	# Un golpe fuerte del servidor corta el canalizado de la copia del rival.
	var foe: Creature = battle.foe
	foe.moves.slots[0] = DB.moves["lanzallamas"]
	# (Magikarp Nv. 3: su barra de PP es más chica que el costo de Lanzallamas; la copia lo hace igual, lo decidió el servidor.)
	var forced := foe.force_move("lanzallamas", Vector2.UP)
	await get_tree().physics_frame
	var channeling := forced and not foe.is_down() and foe.machine.current_name() == "channel"
	r["Mundo: la copia hace un ataque más caro que su barra de PP (lo decidió el servidor)"] = forced
	battle._on_event(mid, {"t": "hit", "side": opp, "amount": 0.05, "hp": 0.35, "p": foe.global_position - battle.arena.global_position,
		"hs": 0.3, "kb": Vector2(0, Creature.STAGGER_KNOCKBACK + 10.0)})
	r["Mundo: el golpe fuerte que avisa el servidor corta el canalizado de la copia"] = channeling \
		and foe.machine.current_name() == "stunned"
	await get_tree().create_timer(0.5).timeout
	# Se corta la conexión en plena pelea: la arena se cierra, se puede caminar y la sala queda offline.
	var t0 := Time.get_ticks_msec()
	server.close()
	await _until(func(): return not battle.active, 30.0)
	var took := (Time.get_ticks_msec() - t0) / 1000.0
	r["Mundo: se cae el servidor en plena pelea: la pelea se cierra sola (%.1f s), sin quedar trabado" % took] = not battle.active \
		and battle.result == "lose" and not Net.is_online() and took < 25.0
	await _until(func(): return not world.trainer.locked and not world.story.busy, 10.0)
	var zone: ZoneEntry = world.streamer.world_data.zone_at(world.trainer.global_position)
	r["Mundo: vuelve al Centro y puede caminar"] = not world.trainer.locked and zone != null and zone.id.begins_with("centro_online") \
		and is_instance_valid(world.companion)
	gary.close()


# --- Piezas --------------------------------------------------------------------------------------

## Desafío, aceptación y equipos: devuelve el id de la partida (0 si no arrancó).
func _start_match(a: NetPeer, b: NetPeer, team_a: Array, team_b: Array) -> int:
	var chose := [0]
	var cb := func(mid, _o, _c, _t): chose[0] = mid
	a.match_choose.connect(cb)
	ev[a].clear()
	ev[b].clear()
	a.send_challenge(b.my_id, 3)
	await get_tree().create_timer(0.3).timeout
	b.send_answer(a.my_id, true)
	await _until(func(): return chose[0] != 0)
	a.match_choose.disconnect(cb)
	if chose[0] == 0:
		return 0
	a.send_choice(chose[0], team_a)
	b.send_choice(chose[0], team_b)
	await _until(func(): return ev[a].any(func(e): return e.t == "start") and server.battles.has(chose[0]), 8.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	return chose[0] if server.battles.has(chose[0]) else 0


func _uses(p: NetPeer, side: int, move_id: String) -> Array:
	return ev[p].filter(func(e): return e.t == "use" and int(e.side) == side and e.m == move_id)


func _hits(p: NetPeer, side: int) -> Array:
	return ev[p].filter(func(e): return e.t == "hit" and int(e.side) == side)


func _peer(n: String) -> NetPeer:
	var p := NetPeer.new()
	p.name = n
	add_child(p)
	ev[p] = []
	st[p] = {}
	p.battle_event_received.connect(func(_mid, e): ev[p].append(e))
	p.battle_state_received.connect(func(_mid, s2): st[p] = s2)
	return p


func _join(n: String, player_name: String, team: Array = [{"species": "pikachu", "level": 12}]) -> NetPeer:
	var p := _peer(n)
	p.join("127.0.0.1", PORT, {"version": Net.game_version(), "name": player_name, "team": team})
	return p


func _entry(p: NetPeer, id: int) -> Dictionary:
	for e in p.players:
		if e.id == id:
			return e
	return {}


func _until(cond: Callable, limit: float = 5.0) -> void:
	var t := 0.0
	while t < limit and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func _results() -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[online-sync] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-online-sync] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
