class_name OnlineBattle
extends Node
## La pelea online del lado del jugador (docs/PLAN_ONLINE.md, O-3). El servidor la simula y decide (NetMatch); acá se
## **imita** con el mismo combate del juego para que se vea igual que una pelea normal (ataques, animaciones, efectos):
## tu Pokémon (el compañero de siempre, con el teclado) y el del rival (con sus teclas, que manda el servidor). Para que
## nadie pierda vida por su cuenta, acá los golpes no pegan (sin hurtbox): la vida, los estados, los debilitados y los
## cambios llegan del servidor, y las posiciones se corrigen con sus fotos (el rival se acerca a donde dice el servidor;
## el tuyo solo si se fue lejos, así no tironea). La EXP la da CombatDirector como siempre: el Pokémon del rival está en
## sus enemigos y, cuando el servidor dice que se debilitó, se debilita acá. Nodo del mundo (world.online.battle).

signal done(result: String)

## Lejos de la arena de las peleas de entrenador (TrainerBattle.ARENA_ORIGIN).
const ARENA_ORIGIN := Vector2(-40000, -30000)
## Corrección de posición: el del rival se acerca rápido; el tuyo solo si se fue más de OWN_SLACK px.
const FOE_LERP := 0.35
const OWN_SLACK := 28.0
const OWN_LERP := 0.12
const SNAP := 96.0
## Esperando el inicio del servidor.
const START_TIMEOUT := 10.0

var world: Node
var active := false
var match_id := 0
var opponent: Dictionary = {}
var my_team: Array[int] = []
var foe_team: Array = []
var foe: Creature
var arena: Node2D
var arena_data: ArenaData
var result := ""
## De dónde salen tus órdenes (el teclado; el autotest pone un bot). Se mandan al servidor cada cuadro.
var local_input: CombatInput
var _foe_input := NetCombatInput.new()
var _start: Dictionary = {}
var _state: Dictionary = {}
var _dodge_seq := 0
var _applying_switch := false
var _going := false
var _end: Dictionary = {}
## Centro de Combate Online desde el que se entró (hay uno por ciudad: ahí se vuelve al terminar).
var _back_zone := "centro_online"


func _ready() -> void:
	world = get_parent().get_parent() if get_parent() is OnlineDesk else get_parent()
	Events.online_battle_event.connect(_on_event)
	Events.online_battle_state.connect(_on_state)


## La pelea entera: arena, cuenta regresiva, pelea, cartel y vuelta al edificio. Devuelve "win" o "lose".
func run(p_match_id: int, p_opponent: Dictionary, p_my_team: Array, p_foe_team: Array) -> String:
	if active:
		return ""
	active = true
	match_id = p_match_id
	opponent = p_opponent
	my_team.assign(p_my_team)
	foe_team = p_foe_team
	result = ""
	_end = {}
	_state = {}
	_going = false
	if local_input == null:
		local_input = world.combat.input_source
	var t: Trainer = world.trainer
	var here: ZoneEntry = world.streamer.world_data.zone_at(t.global_position)
	_back_zone = here.id if here != null and here.id.begins_with("centro_online") else "centro_online"
	t.locked = true
	t.autopilot = Vector2.ZERO
	if world.combat.in_battle:
		world.combat.end_battle(true)
	await world.arena.fade_to(1.0)
	var waited := 0.0
	while _start.get("match", -1) != match_id and waited < START_TIMEOUT and Net.is_online():
		await get_tree().process_frame
		waited += get_process_delta_time()
	if _start.get("match", -1) != match_id:
		await world.arena.fade_to(0.0)
		t.locked = false
		active = false
		Events.message_requested.emit("No arrancó la pelea: se cortó la conexión.")
		return ""
	var ev: Dictionary = _start.ev
	var mine_a: bool = int(ev.a) == Net.client.my_id
	_enter_arena(mine_a)
	Events.trainer_battle_started.emit("entrenador")
	await world.arena.fade_to(0.0)
	await world.arena._show_banner("¡%s!" % opponent.get("name", "Rival"), "Pelea online", 1.4)
	for n in ["2", "1"]:
		Events.message_requested.emit(n)
		await get_tree().create_timer(0.5).timeout
	_go()
	if _end.is_empty():
		await done
	var won := result == "win"
	await get_tree().create_timer(0.8).timeout
	var reason: String = _end.get("reason", "")
	await world.arena._show_banner("¡GANASTE!" if won else "Perdiste...", reason if reason != "" else
		("Le ganaste a %s" % opponent.get("name", "")) if won else "", 1.8)
	await world.arena.fade_to(1.0)
	_leave_arena()
	Events.trainer_battle_ended.emit(result, "entrenador")
	await world.arena.fade_to(0.0)
	t.locked = false
	active = false
	Net.refresh_team()
	return result


func _enter_arena(mine_a: bool) -> void:
	arena_data = load("res://data/arenas/%s.tres" % _start.ev.get("arena", "arena_campo"))
	arena = load(arena_data.scene_path).instantiate()
	arena.position = ARENA_ORIGIN
	world.get_node("YSort/Zones").add_child(arena)
	ZoneBounds.seal(arena)  # paredes en el borde: de la arena no se sale
	var decor := ArenaDecor.new()
	arena.add_child(decor)
	decor.setup(arena_data)
	world.trainer.global_position = _cell(arena_data.player_cell if mine_a else arena_data.foe_trainer_cell)
	# Tu Pokémon: el compañero de siempre, el primero que elegiste.
	GameState.set_active(my_team[0])
	world.respawn_companion()
	var c: Creature = world.companion
	c.global_position = _cell(arena_data.player_mon_cell if mine_a else arena_data.foe_mon_cell)
	world.combat.arena_lock = true
	world.combat.start_battle()
	_no_local_hits(c)
	c.input_source = null  # quieto hasta el "¡Ya!"
	_foe_input.origin = arena.global_position
	_foe_input.enabled = false
	_spawn_foe(0, _cell(arena_data.foe_mon_cell if mine_a else arena_data.player_mon_cell))
	world.camera.target = c
	world.camera.snap()


func _go() -> void:
	_going = true
	_foe_input.enabled = true
	if is_instance_valid(world.companion):
		world.companion.input_source = world.combat.input_source
	Events.message_requested.emit("¡Ya!")


func _leave_arena() -> void:
	world.combat.arena_lock = false
	world.combat.end_battle(true)
	if is_instance_valid(foe):
		foe.queue_free()
	foe = null
	if is_instance_valid(arena):
		arena.queue_free()
	arena = null
	# De vuelta al edificio, frente a la recepcionista.
	var data: WorldData = world.streamer.world_data
	var inside: ZoneEntry = null
	for z in data.zones:
		if z.id == _back_zone:
			inside = z
	var back: Vector2 = Vector2((inside.origin + Vector2i(10, 4)) * data.tile_size) + Vector2.ONE * data.tile_size / 2.0 \
		if inside != null else world.trainer.global_position
	world.streamer.load_around_now(back)
	world.trainer.global_position = back
	var trail: Array[Vector2] = [back]
	world.trainer.trail = trail
	world.camera.target = world.trainer
	world.camera.snap()
	if GameState.active() == null or GameState.active().hp <= 0.0:
		for i in GameState.party.size():
			if GameState.party[i].hp > 0.0:
				GameState.set_active(i)
				break
	world.respawn_companion()
	if is_instance_valid(world.companion):
		world.companion.global_position = back + Vector2(0, -12)
		world.companion.machine.transition_to("follow")


func _physics_process(_delta: float) -> void:
	if not active or arena == null:
		return
	var c = world.companion  # (sin tipo: puede estar liberada)
	if is_instance_valid(foe) and is_instance_valid(c):
		foe.target = c  # (CombatDirector cuenta como enemigos a los que te apuntan)
		if not foe.is_down() and not world.combat.enemies.has(foe):
			world.combat.enemies.append(foe)  # que siga en sus enemigos: de ahí sale la EXP al debilitarlo
	if _going and is_instance_valid(c) and not c.is_down() and local_input != null and _end.is_empty():
		if local_input.wants_dodge():
			_dodge_seq += 1
		Net.battle_input(match_id, NetCombatInput.pack(local_input, c, arena.global_position, _dodge_seq))
	_correct(c, Net.client.my_id, OWN_SLACK, OWN_LERP)
	_correct(foe, int(opponent.get("id", 0)), 0.0, FOE_LERP)


## Acerca la criatura a donde la tiene el servidor (solo si se fue más de `slack`).
func _correct(c, id: int, slack: float, lerp_w: float) -> void:  # (c sin tipo: puede estar liberada)
	if not is_instance_valid(c) or c.is_down() or not _state.has(id):
		return
	var target: Vector2 = arena.global_position + (_state[id].p as Vector2)
	var d: float = c.global_position.distance_to(target)
	if d > SNAP:
		c.global_position = target
	elif d > slack:
		c.global_position = c.global_position.lerp(target, lerp_w)


## ¿Lo maneja la pelea online? (CombatDirector.switch_to: el cambio lo decide el servidor.)
func intercepts_switch(index: int) -> bool:
	if not active or _applying_switch:
		return false
	if _going and index in my_team and _end.is_empty():
		Net.battle_switch(match_id, index)
	elif index not in my_team:
		Events.message_requested.emit("Ese Pokémon no está en esta pelea.")
	return true


# --- Lo que manda el servidor ------------------------------------------------------------------

func _on_event(mid: int, ev: Dictionary) -> void:
	if ev.get("t") == "start":
		_start = {"match": mid, "ev": ev}
		return
	if not active or mid != match_id or arena == null:
		return
	var me: int = Net.client.my_id
	match ev.get("t"):
		"hit":
			var c := _creature_of(int(ev.side))
			if is_instance_valid(c):
				_set_hp(c, float(ev.hp))
				Events.creature_damaged.emit(c, float(ev.amount) * c.health.max_hp(), null)
				_drop_projectiles_near(c.global_position)
		"faint":
			var c := _creature_of(int(ev.side))
			if is_instance_valid(c) and not c.is_down():
				c.health.invulnerable_time = 0.0
				c.health.shield_time = 0.0
				c.health.apply_damage(c.health.hp() + 1.0)
		"send":
			var at: Vector2 = arena.global_position + (ev.p as Vector2)
			if int(ev.side) == me:
				_switch_own(int(ev.index), at)
			else:
				_spawn_foe(int(ev.index), at)
		"end":
			_end = ev
			result = "win" if int(ev.winner) == me else "lose"
			var mine: Array = ev.get("hp", {}).get(me, [])
			for k in mini(mine.size(), my_team.size()):
				var inst: CreatureInstance = GameState.party[my_team[k]]
				inst.hp = clampf(float(mine[k]), 0.0, 1.0) * inst.max_hp()
			for c in [world.companion, foe]:
				if is_instance_valid(c):
					c.input_source = null
			done.emit(result)


func _on_state(mid: int, st: Dictionary) -> void:
	if not active or mid != match_id or arena == null:
		return
	_state = st
	var opp := int(opponent.get("id", 0))
	if st.has(opp):
		_foe_input.set_packet(st[opp].get("in", []))
	for id in [Net.client.my_id, opp]:
		var c := _creature_of(id)
		if not is_instance_valid(c) or c.is_down() or not st.has(id):
			continue
		_set_hp(c, float(st[id].hp))
		_sync_statuses(c, st[id].get("st", []))
		c.hitstun_left = maxf(c.hitstun_left, float(st[id].get("hs", 0.0)))


func _creature_of(id: int) -> Creature:
	var c = world.companion if id == Net.client.my_id else foe  # (sin tipo: puede estar liberada)
	return c if is_instance_valid(c) else null


func _set_hp(c: Creature, ratio: float) -> void:
	var hp := clampf(ratio, 0.0, 1.0) * c.health.max_hp()
	if absf(hp - c.instance.hp) < 0.01 or c.is_down():
		return
	c.instance.hp = maxf(hp, 0.01)  # debilitar lo decide el "faint" del servidor
	c.health.changed.emit(c.instance.hp, c.health.max_hp())


func _sync_statuses(c: Creature, ids: Array) -> void:
	for id in ids:
		if not c.statuses.has_status(id) and DB.statuses.has(id):
			c.statuses.apply(DB.statuses[id])
	for id in c.statuses.active.keys():
		if id not in ids:
			c.statuses.cure(c.statuses.active[id].status)


func _switch_own(index: int, at: Vector2) -> void:
	_applying_switch = true
	world.combat._switch_cd = 0.0
	world.combat.switch_to(index)
	_applying_switch = false
	var c: Creature = world.companion
	if is_instance_valid(c):
		c.global_position = at
		_no_local_hits(c)
		if not _going:
			c.input_source = null


func _spawn_foe(index: int, at: Vector2) -> void:
	if is_instance_valid(foe):
		world.combat.enemies.erase(foe)
		foe.queue_free()
	if index < 0 or index >= foe_team.size():
		return
	var inst := CreatureInstance.from_dict(foe_team[index])
	if inst == null:
		return
	inst.hp = clampf(float(foe_team[index].get("hp_ratio", 1.0)), 0.01, 1.0) * inst.max_hp()
	var c: Creature = WildSpawner.CreatureScene.instantiate()
	c.instance = inst
	c.team = Creature.Team.WILD
	c.owner_name = opponent.get("name", "Rival")
	c.player_controlled = true
	c.input_source = _foe_input
	c.position = at
	world.entities.add_child(c)
	c.machine.transition_to.call_deferred("controlled")
	_no_local_hits(c)
	c.target = world.companion
	if not world.combat.enemies.has(c):
		world.combat.enemies.append(c)
	foe = c
	Events.message_requested.emit("¡%s saca a %s!" % [c.owner_name, inst.display_name()])


## Acá los golpes no pegan (los decide el servidor): sin hurtbox.
func _no_local_hits(c: Creature) -> void:
	var hb: Area2D = c.get_node_or_null("Hurtbox")
	if hb != null:
		hb.set_deferred("monitorable", false)
		hb.set_deferred("monitoring", false)


## Los disparos que el servidor dice que pegaron: que no sigan de largo.
func _drop_projectiles_near(at: Vector2) -> void:
	for n in world.entities.get_children():
		if n is Projectile and n.global_position.distance_to(at) < 28.0:
			n.queue_free()


func _cell(cell: Vector2i) -> Vector2:
	return arena.to_global(arena.ground.map_to_local(cell))
