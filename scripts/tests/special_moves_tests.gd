class_name SpecialMovesTests
extends Node
## Autotest de los ataques con efecto propio (SpecialMoves y los estados con reglas): que cada uno haga lo que dice.
##   godot --headless --path . --quit-after 60000 -- --autotest-special-moves

var autotest: Node
var _me: Creature
var _foe: Creature
var _world: Node


func run() -> void:
	var r := {}
	_world = await autotest._setup_kit_world("kadabra")
	_me = _world.companion
	GameState.set_setting("pp_mode", false)
	_me.instance.level = 40
	_me.instance.hp = _me.health.max_hp()
	_foe = autotest._dummy(_world, "pikachu", _me.global_position + Vector2(30, 0))
	_me.target = _foe
	_foe.target = _me
	var swift: MoveData = DB.moves["rapidez"]

	# --- Llaman a otro ataque ---
	var fired := []
	Events.move_used.connect(func(_c, _m): pass)
	_me.move_released.connect(func(m): fired.append(m))
	await _use("metronomo")
	r["Metrónomo tira otro ataque de daño"] = fired.size() >= 2 and fired[1].power > 0.0
	fired.clear()
	_foe.last_move = swift
	await _use("espejo")
	r["Espejo repite el del rival"] = fired.has(swift)
	fired.clear()
	await _use("adaptacion")
	r["Adaptación tira uno según el lugar"] = fired.size() >= 2
	fired.clear()
	await _use("ayuda")
	r["Ayuda sin nadie más en el equipo falla sin romper nada"] = fired.size() >= 1

	# --- Copian ---
	_foe.last_move = swift
	await _use("mimetico")
	r["Mimético copia el ataque en la ranura"] = _me.moves.slots[1] == swift
	_me.reset_fight_changes()
	r["Al terminar la pelea vuelve lo de antes"] = not _me.moves.slots.has(swift)

	var smeargle: CreatureInstance = CreatureInstance.create(DB.species["smeargle"], 20)
	r["Smeargle viene con Esquema"] = smeargle.equipped_moves.has(DB.moves["esquema"])

	if _me.signature != null and _foe.signature != null and _me.signature.get_script() == _foe.signature.get_script():
		var mine: SignatureData = _me.signature.data
		var theirs: SignatureData = _foe.signature.data
		await _use("intercambio")
		var swapped: bool = mine == theirs or (_me.signature.data == theirs and _foe.signature.data == mine)
		_me.reset_fight_changes()
		_foe.reset_fight_changes()
		r["Intercambio cambia las habilidades y vuelve al final"] = swapped and _me.signature.data == mine and _foe.signature.data == theirs

	await _use("transformacion")
	var as_foe: bool = _me.instance.types() == _foe.instance.types() and _me.instance.stat("attack") == _foe.instance.stat("attack") \
		and _me.sprite.species == _foe.instance.species and _me.moves.slots[0] == _foe.moves.slots[0]
	r["Transformación: tipos, stats, aspecto y ataques"] = as_foe
	var hp_before: float = _me.health.max_hp()
	r["La vida máxima sigue siendo la suya"] = hp_before == _me.instance.max_hp() and _me.instance.stat("hp") != _foe.instance.stat("hp")
	_me.reset_fight_changes()
	r["Vuelve a ser el de antes"] = _me.sprite.species == _me.instance.species and _me.instance.fight_stats == null

	# --- Tipos ---
	_me.moves.slots[0] = DB.moves["ascuas"]
	await _use("conversion")
	r["Conversión: tipo de su primer ataque"] = _me.instance.types()[0].id == "fuego"
	_me.reset_fight_changes()
	await _use("camuflaje")
	r["Camuflaje: tipo del lugar"] = _me.instance.types()[0].id in ["normal", "agua", "planta", "roca"] and not _me.instance.fight_types.is_empty()
	_me.reset_fight_changes()
	_me.last_hit_by = _foe
	_foe.last_move = DB.moves["ascuas"]
	await _use("conversion_2")
	r["Conversión 2: resiste el último golpe"] = DB.type_chart.get_multiplier(DB.moves["ascuas"].element, _me.instance.types()) < 1.0
	_me.reset_fight_changes()
	var fire_hit := HitInfo.from(_foe, DB.moves["ascuas"])
	Damage.resolve(fire_hit, _me.instance)
	var neutral := fire_hit.effectiveness
	var water: Array[ElementType] = [DB.types["agua"]]
	_me.instance.fight_types = water
	Damage.resolve(fire_hit, _me.instance)
	r["Los tipos de pelea cuentan para el daño"] = fire_hit.effectiveness < neutral
	_me.reset_fight_changes()

	# --- Estados ---
	var pot: StatusEffect = DB.statuses["maldicion_cuerpo"]
	_foe.statuses.apply(pot)
	await _use("autosugestion")
	r["Autosugestión copia sus mejoras"] = _me.statuses.has_status("maldicion_cuerpo")
	await _use("niebla")
	r["Niebla borra todo, de los dos"] = not _me.statuses.has_status("maldicion_cuerpo") and not _foe.statuses.has_status("maldicion_cuerpo")
	_me.statuses.apply(DB.statuses["expuesto"])
	await _use("truco")
	r["Truco le pasa tus problemas"] = not _me.statuses.has_status("expuesto") and _foe.statuses.has_status("expuesto")
	_foe.statuses.clear()

	_me.statuses.apply(DB.statuses["reflejo"])
	_foe.moves.slots[0] = DB.moves["malicioso"]
	_foe.moves.reset_cooldown(0)
	_foe.moves.gap_left = 0.0
	_foe.use_slot(0, Vector2.LEFT, _me.global_position)
	await _frames(20)
	r["Capa Mágica se lo devuelve"] = _foe.statuses.has_status("expuesto") and not _me.statuses.has_status("expuesto")
	_foe.statuses.clear()
	_me.statuses.clear()

	_me.statuses.apply(DB.statuses["al_acecho"])
	_foe.moves.slots[1] = DB.moves["danza_espada"]
	_foe.moves.reset_cooldown(1)
	_foe.moves.gap_left = 0.0
	_foe.machine.transition_to("wander")
	_foe.use_slot(1, Vector2.LEFT, _me.global_position)
	await _frames(5)
	r["Robo se queda con la mejora"] = _me.statuses.has_status(DB.moves["danza_espada"].self_status.id) \
		and not _foe.statuses.has_status(DB.moves["danza_espada"].self_status.id)
	_foe.statuses.clear()
	_me.statuses.clear()

	_foe.moves.slots[0] = swift
	_me.moves.slots[2] = swift
	_foe.statuses.apply(DB.statuses["sellado"], 1.0, _me)
	r["Sellar: no usa lo que vos también sabés"] = _foe.moves.status_locked(0)
	_foe.statuses.clear()
	_me.moves.slots[2] = null
	_foe.moves.slots[1] = DB.moves["placaje"]
	_foe.moves.last_used = 0
	_foe.statuses.apply(DB.statuses["obligado"])
	r["Otra Vez: solo puede el último"] = _foe.moves.status_locked(1) and not _foe.moves.status_locked(0)
	_foe.statuses.clear()

	var mud := HitInfo.from(_foe, DB.moves["impactrueno"])
	_me.statuses.apply(DB.statuses["enlodado"])
	r["Chapoteo Lodo: mitad de daño eléctrico"] = _me.statuses.type_taken_mult(mud.move.element) == 0.5 \
		and _me.statuses.type_taken_mult(DB.moves["ascuas"].element) == 1.0
	_me.statuses.clear()

	# --- Sustituto ---
	_me.instance.hp = _me.health.max_hp()
	await _use("sustituto")
	var full: float = _me.health.max_hp()
	r["Sustituto cuesta un cuarto de la vida"] = absf(_me.instance.hp - full * 0.75) < 1.0 and _me.sub_hp > 0.0
	var hp0: float = _me.instance.hp
	_foe.moves.slots[2] = DB.moves["impactrueno"]
	_foe.moves.reset_cooldown(2)
	_foe.moves.gap_left = 0.0
	_foe.global_position = _me.global_position + Vector2(30, 0)
	_foe.use_slot(2, Vector2.LEFT, _me.global_position)
	await _frames(40)
	r["El muñeco recibe el golpe"] = _me.instance.hp == hp0
	_me.reset_fight_changes()
	_me.statuses.clear()

	# --- Púas ---
	var before := _foe.instance.hp
	_foe.statuses.clear()
	_me.moves.slots[1] = DB.moves["puas"]
	_me.moves.reset_cooldown(1)
	_me.moves.gap_left = 0.0
	_me.use_slot(1, Vector2.RIGHT, _foe.global_position)
	await _frames(100)
	r["Púas lastima al que las pisa"] = _foe.instance.hp < before or _foe.statuses.has_status("pinchado")
	_foe.statuses.clear()

	# --- Finales ---
	var victim: Creature = autotest._dummy(_world, "rattata", _me.global_position + Vector2(-30, 0))
	victim.statuses.apply(DB.statuses["condenado"])
	victim.statuses.active["condenado"]["time"] = 0.2
	await _frames(30)
	r["Canto Mortal: se debilita al terminarse"] = not is_instance_valid(victim) or victim.is_down()

	var killer: Creature = autotest._dummy(_world, "rattata", _me.global_position + Vector2(-30, 30))
	var bond: Creature = autotest._dummy(_world, "gastly", killer.global_position + Vector2(20, 0))
	bond.statuses.apply(DB.statuses["destino"])
	bond.instance.hp = 1.0
	var strike := HitInfo.from(killer, DB.moves["ascuas"])
	bond._on_hit(strike)
	await _frames(3)
	r["Mismo Destino se lleva al que lo debilitó"] = not is_instance_valid(killer) or killer.is_down()

	var grudge_killer: Creature = autotest._dummy(_world, "rattata", _me.global_position + Vector2(-60, 30))
	grudge_killer.moves.last_used = 0
	var grudge: Creature = autotest._dummy(_world, "gastly", grudge_killer.global_position + Vector2(20, 0))
	grudge.statuses.apply(DB.statuses["rencoroso"])
	grudge.instance.hp = 1.0
	GameState.set_setting("pp_mode", true)
	grudge._on_hit(HitInfo.from(grudge_killer, DB.moves["ascuas"]))
	r["Rabia: sin PP y con el ataque en recarga larga"] = grudge_killer.moves.pp() <= 0.0 and grudge_killer.moves.cooldowns[0] >= 25.0
	GameState.set_setting("pp_mode", false)

	_me.statuses.clear()
	await _use("maldicion")
	r["Maldición de un no fantasma: mejora"] = _me.statuses.has_status("maldicion_cuerpo")
	_me.statuses.clear()

	var ghost: Creature = autotest._dummy(_world, "gastly", _me.global_position + Vector2(-40, -40))
	ghost.target = _foe
	var ghost_hp: float = ghost.instance.hp
	_foe.statuses.clear()
	SpecialMoves.run(DB.moves["maldicion"], ghost)
	r["Maldición de un fantasma: media vida y el rival maldito"] = ghost.instance.hp <= ghost_hp * 0.6 and _foe.statuses.has_status("maldito")
	_foe.statuses.clear()

	var sleeper_shots := []
	_me.moves.slots[1] = DB.moves["sonambulo"]
	_me.moves.slots[2] = swift
	var on_shot := func(m): sleeper_shots.append(m)
	_me.move_released.connect(on_shot)
	_me.statuses.apply(DB.statuses["dormido"])
	await _frames(100)
	_me.move_released.disconnect(on_shot)
	r["Sonámbulo: dormido, tira otro ataque"] = not sleeper_shots.is_empty()
	_me.statuses.clear()
	_me.machine.transition_to("controlled")
	_me.moves.slots[2] = null

	var napper: Creature = autotest._dummy(_world, "snorlax", _me.global_position + Vector2(50, 50))
	napper.moves.slots[1] = DB.moves["sonambulo"]
	napper.moves.slots[2] = swift
	napper.napping = true
	var nap_shots := []
	var on_nap := func(m): nap_shots.append(m)
	napper.move_released.connect(on_nap)
	SpecialMoves.sleep_talk(napper)
	r["En su siesta un salvaje no dispara"] = nap_shots.is_empty()
	napper.move_released.disconnect(on_nap)
	napper.queue_free()

	var far: Creature = autotest._dummy(_world, "rattata", _me.global_position + Vector2(60, -30))
	far.target = null
	await _frames(3)  # (que arranque: Wander le borra el objetivo al entrar)
	await _use("senuelo")
	r["Señuelo: los salvajes cercanos van por vos"] = far.target == _me

	GameState.add_item("pocion", 1)
	var potions := GameState.item_count("pocion")
	GameState.last_item_used = "pocion"
	await _use("reciclaje")
	r["Reciclaje devuelve el último objeto, una vez"] = GameState.item_count("pocion") == potions + 1 and GameState.last_item_used == ""
	await _use("reciclaje")
	r["La segunda vez falla"] = GameState.item_count("pocion") == potions + 1

	GameState.party.append(CreatureInstance.create(DB.species["pidgey"], 20))
	_me.statuses.apply(DB.statuses["maldicion_cuerpo"])
	_me.moves.last_used = -1
	await _use("relevo")
	await _frames(5)
	var next: Creature = _world.companion
	r["Relevo: sale otro y hereda las mejoras"] = next != _me and next.instance.species.id == "pidgey" and next.statuses.has_status("maldicion_cuerpo")
	GameState.set_active(0)
	await _frames(5)
	_me = _world.companion
	_me.statuses.clear()
	_me.machine.transition_to("controlled")

	var mate: Creature = autotest._dummy(_world, "rattata", _me.global_position + Vector2(30, 40))
	_me.target = mate
	mate.target = _me
	_me.instance.hp = _me.health.max_hp()
	await _use("legado")
	r["Legado: te debilitás y lo intimidás"] = _me.is_down() and mate.statuses.has_status("muy_intimidado")

	# --- Ninguno vacío + IA + textos ---
	var empty: Array = DB.moves.values().filter(func(m): return m.does_nothing())
	r["Ya no queda ninguno sin efecto (%s)" % ", ".join(empty.map(func(m): return m.id))] = empty.is_empty()
	var no_text: Array = DB.moves.values().filter(func(m): return m.special != "" and not SpecialMoves.TEXT.has(m.special) and m.self_status == null)
	r["Todos explican lo que hacen (%s)" % ", ".join(no_text.map(func(m): return m.id))] = no_text.is_empty()
	r["Púas y Sonámbulo se entienden"] = MoveInfo.what_it_does(DB.moves["sonambulo"]).contains("dormido") \
		and MoveInfo.what_it_does(DB.moves["puas"]).contains("Pinchado")

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[especial] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-special-moves] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _use(id: String) -> void:
	_me.moves.slots[1] = DB.moves[id]
	_me.moves.reset_cooldown(1)
	_me.moves.gap_left = 0.0
	_me.machine.transition_to("controlled")  # (el ataque anterior pudo dejarlo cargando: Metrónomo)
	_me.hitstun_left = 0.0
	_me.use_slot(1, Vector2.RIGHT, _foe.global_position)
	await _frames(12)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame
