class_name NetMatch
extends Node2D
## Una pelea online simulada en el **servidor** (docs/PLAN_ONLINE.md, O-3): la arena (solo sus tiles, sin el mundo) y el
## Pokémon de cada jugador, movidos por las teclas que llegan por red (`NetCombatInput`). Usa el mismo combate del juego
## (Creature, ataques, daño, estados). El servidor decide golpes, debilitados, cambios y quién gana; a los clientes les
## manda una foto 20 veces por segundo (`state`) y los hechos (`event`: inicio, golpe, debilitado, sale otro, fin).
## Lado A = el que desafió (abajo, como tu Pokémon en las arenas); lado B = el que aceptó (arriba).

signal event(ev: Dictionary)
signal snapshot(state: Dictionary)
signal finished(winner: int, reason: String)

const ARENA_ID := "arena_campo"
## Cuenta regresiva antes de que se puedan mover.
const COUNTDOWN := 3.0
## Tope de una pelea: gana el que tiene más vida (en proporción) en el equipo.
const MAX_TIME := 300.0
const SNAPSHOT_EVERY := 0.033  # (30 por segundo: con 20 el stagger y los empujones se notaban tarde)
const NEXT_MON_DELAY := 1.2
const SWITCH_COOLDOWN := 1.5

var match_id := 0
var a := 0
var b := 0
var arena_data: ArenaData
var arena: Node2D
## id del jugador → {team: Array[CreatureInstance], index, creature, input, cell, team_enum, switch_cd, down, packet}
var sides: Dictionary = {}
var time := 0.0
var over := false
## Congelada: se espera a uno que se cayó (NetPeer.RECONNECT_GRACE). No corre nada: ni el tiempo ni los Pokémon.
var held := false
var _snap := 0.0
## Un jugador que volvió tiene otro id de red: el viejo → el nuevo (para lo que quedó atado al viejo).
var _alias: Dictionary = {}


## `teams`: id → [CreatureInstance.to_dict con "hp_ratio"] (lo que eligió cada uno, ya limpio).
func setup(p_match_id: int, p_a: int, p_b: int, teams: Dictionary) -> void:
	match_id = p_match_id
	a = p_a
	b = p_b
	arena_data = load("res://data/arenas/%s.tres" % ARENA_ID)
	for id in [a, b]:
		var team: Array[CreatureInstance] = []
		for d in teams[id]:
			var inst := CreatureInstance.from_dict(d)
			if inst == null:
				continue
			inst.hp = clampf(float(d.get("hp_ratio", 1.0)), 0.0, 1.0) * inst.max_hp()
			team.append(inst)
		var input := NetCombatInput.new()
		input.enabled = false
		sides[id] = {"team": team, "index": -1, "creature": null, "input": input, "switch_cd": 0.0, "down": false,
			"cell": arena_data.player_mon_cell if id == a else arena_data.foe_mon_cell,
			"team_enum": Creature.Team.ALLY if id == a else Creature.Team.WILD, "packet": []}


func _ready() -> void:
	arena = load(arena_data.scene_path).instantiate()
	add_child(arena)
	ZoneBounds.seal(arena)  # paredes en el borde: de la arena no se sale
	for id in sides:
		sides[id].input.origin = arena.global_position
		_send(id, _first_healthy(id), _cell_pos(sides[id].cell))
	event.emit({"t": "start", "a": a, "b": b, "arena": ARENA_ID, "countdown": COUNTDOWN})


func _physics_process(delta: float) -> void:
	if over:
		return
	time += delta
	for id in sides:
		var s: Dictionary = sides[id]
		s.input.enabled = time >= COUNTDOWN
		s.switch_cd = maxf(0.0, s.switch_cd - delta)
		var c = s.creature  # (sin tipo: puede estar liberada)
		if is_instance_valid(c) and c.health.is_dead() and not s.down:
			s.down = true
			event.emit({"t": "faint", "side": id})
			get_tree().create_timer(NEXT_MON_DELAY).timeout.connect(_after_faint.bind(id))
	_snap -= delta
	if _snap <= 0.0:
		_snap = SNAPSHOT_EVERY
		snapshot.emit(state())
	if time > COUNTDOWN + MAX_TIME:
		var ra := _team_ratio(a)
		var rb := _team_ratio(b)
		finish(a if ra >= rb else b, "Se terminó el tiempo: gana el que tiene más vida.")


## Las teclas de un jugador (paquete de NetCombatInput.pack).
func set_input(id: int, packet: Array) -> void:
	id = _resolve(id)
	if sides.has(id) and not held:
		sides[id].input.set_packet(packet)
		sides[id].packet = packet


## Un jugador pide cambiar de Pokémon (1-6). Devuelve si se hizo.
func request_switch(id: int, index: int) -> bool:
	id = _resolve(id)
	if over or held or not sides.has(id) or time < COUNTDOWN:
		return false
	var s: Dictionary = sides[id]
	if s.switch_cd > 0.0 or s.down or index == s.index or index < 0 or index >= s.team.size() or s.team[index].hp <= 0.0:
		return false
	var at: Vector2 = s.creature.global_position if is_instance_valid(s.creature) else _cell_pos(s.cell)
	_send(id, index, at)
	s.switch_cd = SWITCH_COOLDOWN
	return true


## Foto para los clientes: por jugador, posición (relativa a la arena), mirada, vida (proporción), estados, stagger,
## quién está afuera y sus últimas teclas (para que el otro lo imite).
func state() -> Dictionary:
	var out := {"t": time}
	for id in sides:
		var s: Dictionary = sides[id]
		var c = s.creature  # (sin tipo: puede estar liberada)
		if not is_instance_valid(c):
			continue
		out[id] = {"p": c.global_position - arena.global_position, "f": c.facing, "hp": c.health.ratio(),
			"st": c.statuses.active.keys(), "hs": c.hitstun_left, "bw": c.is_burrowed(), "i": s.index, "in": s.packet}
	return out


## Se cayó `id`: la pelea se congela (nadie se mueve, el tiempo no corre) hasta que vuelva o se venza la espera.
func hold(id: int, seconds: float) -> void:
	if over or held:
		return
	held = true
	process_mode = Node.PROCESS_MODE_DISABLED
	for s in sides.values():
		s.input.enabled = false
	event.emit({"t": "hold", "side": id, "seconds": seconds})


## Volvió el que se había caído (ya con su id nuevo): los dos reciben cómo está cada lado y la pelea sigue.
func resume(new_id: int, old_id: int) -> void:
	if over or not held:
		return
	held = false
	process_mode = Node.PROCESS_MODE_INHERIT
	var info := {}
	for id in sides:
		var s: Dictionary = sides[id]
		var c = s.creature  # (sin tipo: puede estar liberada)
		if is_instance_valid(c):
			info[id] = {"index": s.index, "p": c.global_position - arena.global_position,
				"hp": c.instance.hp / maxf(1.0, c.instance.max_hp())}
	event.emit({"t": "resume", "side": new_id, "was": old_id, "sides": info})
	_snap = 0.0


## El jugador `old_id` ahora es `new_id` (volvió a conectarse).
func rebind(old_id: int, new_id: int) -> void:
	if not sides.has(old_id) or old_id == new_id:
		return
	sides[new_id] = sides[old_id]
	sides.erase(old_id)
	_alias[old_id] = new_id
	if a == old_id:
		a = new_id
	elif b == old_id:
		b = new_id


func _resolve(id: int) -> int:
	while _alias.has(id):
		id = _alias[id]
	return id


func finish(winner: int, reason: String) -> void:
	if over:
		return
	over = true
	held = false
	process_mode = Node.PROCESS_MODE_INHERIT
	CombatWeather.stop_for(self)  # (el clima es por pelea: dos a la vez no se pisan)
	for id in sides:
		sides[id].input.enabled = false
	var hp := {}
	for id in sides:
		hp[id] = sides[id].team.map(func(i: CreatureInstance): return i.hp / i.max_hp() if i.max_hp() > 0.0 else 0.0)
	event.emit({"t": "end", "winner": winner, "reason": reason, "hp": hp})
	finished.emit(winner, reason)


func _after_faint(id: int) -> void:
	id = _resolve(id)
	if over or not sides.has(id):
		return
	var next := _first_healthy(id)
	if next < 0:
		finish(b if id == a else a, "")
		return
	var s: Dictionary = sides[id]
	_send(id, next, s.creature.global_position if is_instance_valid(s.creature) else _cell_pos(s.cell))


func _send(id: int, index: int, at: Vector2) -> void:
	var s: Dictionary = sides[id]
	if is_instance_valid(s.creature):
		s.creature.queue_free()
	var c: Creature = WildSpawner.CreatureScene.instantiate()
	c.instance = s.team[index]
	c.team = s.team_enum
	c.player_controlled = true
	c.input_source = s.input
	c.owner_name = "online"  # no se atrapa
	c.position = at - global_position
	add_child(c)
	c.machine.transition_to.call_deferred("controlled")  # arranca quieto o paseando (salvaje): que obedezca
	c.damage_received.connect(_on_damaged.bind(id, c))
	c.slot_used.connect(_on_slot_used.bind(id, c))
	s.creature = c
	s.index = index
	s.down = false
	# Con la vida que tiene ahora (la que eligió al principio ya es vieja si vuelve a salir).
	event.emit({"t": "send", "side": id, "index": index, "p": at - arena.global_position,
		"hp": c.instance.hp / maxf(1.0, c.instance.max_hp())})


func _on_damaged(amount: float, _hit: HitInfo, id: int, c: Creature) -> void:
	id = _resolve(id)
	if amount <= 0.0 or not is_instance_valid(c):
		return
	# Con el stagger y el empuje del golpe: el juego los aplica apenas llega el golpe, sin esperar la próxima foto.
	event.emit({"t": "hit", "side": id, "amount": amount / maxf(1.0, c.health.max_hp()), "hp": c.health.ratio(),
		"p": c.global_position - arena.global_position, "hs": c.hitstun_left, "kb": c.knockback})


## Atacó: los clientes lo muestran con este aviso (no con las teclas, que en su copia pueden no alcanzar).
func _on_slot_used(slot: int, aim: Vector2, point: Vector2, id: int, c: Creature) -> void:
	id = _resolve(id)
	if not is_instance_valid(c) or slot < 0 or slot >= c.moves.slots.size() or c.moves.slots[slot] == null:
		return
	var ev := {"t": "use", "side": id, "m": c.moves.slots[slot].id, "aim": aim}
	if point.is_finite():
		ev["pt"] = point - arena.global_position
	event.emit(ev)


func _first_healthy(id: int) -> int:
	var team: Array = sides[id].team
	for i in team.size():
		if team[i].hp > 0.0 and i != sides[id].index:
			return i
	return -1


func _team_ratio(id: int) -> float:
	var team: Array = sides[id].team
	if team.is_empty():
		return 0.0
	var total := 0.0
	for i: CreatureInstance in team:
		total += i.hp / i.max_hp() if i.max_hp() > 0.0 else 0.0
	return total / team.size()


func _cell_pos(cell: Vector2i) -> Vector2:
	return arena.to_global(arena.ground.map_to_local(cell))
