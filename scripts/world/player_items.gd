class_name PlayerItems
extends Node
## Lo que el jugador usa de la mochila en el mundo (docs/PLAN_CAPTURA_MOCHILA.md):
##  · **E** lanza la Pokébola elegida (GameState.selected_ball) desde el entrenador hacia el mouse (alcance
##    limitado). Funciona en combate y fuera de él.
##    Con joystick (2026-11-05, "lo que dé mejor experiencia"): un toque la lanza al salvaje más cercano, con un poco de
##    anticipación si se mueve; manteniendo aparece la mira (`BallAim`) sobre él, el stick derecho la mueve y se pega al
##    salvaje que tenga cerca; sale al soltar.
##  · **C** usa el objeto de la ranura rápida (GameState.quick_item) sobre tu Pokémon activo. En combate tu
##    Pokémon queda expuesto un instante (ItemData.use_time).

const THROW_RANGE := 160.0
const THROW_COOLDOWN := 1.2
## Joystick: cuánto hay que mantener para que aparezca la mira (menos es un toque).
const AIM_HOLD := 0.18
const AIM_SPEED := 240.0
## La mira suelta se pega a un salvaje a esta distancia, al dejar de mover el stick.
const AIM_MAGNET := 24.0
## Cuánto de lo que el salvaje avanza mientras vuela la bola se tiene en cuenta (1 = todo).
const AIM_LEAD := 0.7

var world: Node
var _cooldown := 0.0
var _aiming := false
var _aim_time := 0.0
var _aim_target: Creature
var _aim_point := Vector2.ZERO
var _aim_moved := false
var _aim_frame := 0
var _aim_mark: BallAim


func _ready() -> void:
	world = get_parent()


func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	var story: StoryDirector = world.get("story")
	var in_arena: bool = world.get("arena") != null and world.arena.active
	# En una conversación E y C no hacen nada más; pero las peleas de entrenador/gimnasio/torneo arrancan desde una
	# charla (la historia queda ocupada toda la pelea): ahí sí (pedido del usuario 2026-10-26).
	if Controls.wheel_open or (story != null and (story.dialog.active or (story.busy and not in_arena))):
		_stop_aiming()
		return
	if _aiming:
		_update_aim(delta)
	if Input.is_action_just_pressed("capture"):
		# E contextual (docs/PLAN_HISTORIA.md): si hay alguien al lado, habla; si no, lanza la Pokébola.
		if story == null or not story.try_interact():
			if world.get("fishing") != null and world.fishing.try_near():
				pass  # en un punto de pesca, la E pesca
			elif world.get("arena") != null and world.arena.active:
				Events.message_requested.emit("¡No se puede atrapar al Pokémon de otro entrenador!")
			else:
				if Controls.gamepad:
					_start_aiming()
				else:
					throw_ball(world.get_global_mouse_position())
	if Input.is_action_just_pressed("quick_item"):
		use_quick_item()


# --- Apuntar con joystick -------------------------------------------------------------------------------------------------

func is_aiming() -> bool:
	return _aiming


## Se apretó el botón. Si no se puede lanzar, lo dice enseguida en vez de mostrar una mira que no sirve.
func _start_aiming() -> void:
	if _cooldown > 0.0 or GameState.party.is_empty() or ball_to_throw() == null or indoors(world.trainer.global_position):
		throw_ball(world.trainer.global_position)
		return
	_aiming = true
	_aim_time = 0.0
	_aim_moved = false
	_aim_frame = Engine.get_process_frames()
	_aim_target = _nearest_wild(world.trainer.global_position, THROW_RANGE)
	_aim_point = _aim_target.global_position if _aim_target != null else _ahead_point()


func _update_aim(delta: float) -> void:
	# Se abrió el menú en el medio (el juego estuvo en pausa): se cancela, no se lanza al volver.
	var frame := Engine.get_process_frames()
	if frame > _aim_frame + 1:
		_stop_aiming()
		return
	_aim_frame = frame
	if not Input.is_action_pressed("capture"):
		var at := aim_throw_point()
		_stop_aiming()
		throw_ball(at)
		return
	_aim_time += delta
	var stick := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if stick != Vector2.ZERO:
		_aim_moved = true
		_aim_target = null
		_aim_point += stick * AIM_SPEED * delta
	elif _aim_target == null and _aim_moved:
		_aim_target = _nearest_wild(_aim_point, AIM_MAGNET)
	if _aim_target != null and (not is_instance_valid(_aim_target) or _aim_target.is_down()):
		_aim_target = null
	if _aim_target != null:
		_aim_point = _aim_target.global_position
	var from: Vector2 = world.trainer.global_position
	var in_range := true
	if _aim_target != null:
		in_range = from.distance_to(_aim_point) <= THROW_RANGE
	else:
		_aim_point = from + (_aim_point - from).limit_length(THROW_RANGE)
	if _aim_time >= AIM_HOLD or _aim_moved:
		if _aim_mark == null:
			_aim_mark = BallAim.new()
			world.entities.add_child(_aim_mark)
		_aim_mark.place(_aim_point, from, _aim_target != null, in_range)


## Dónde caería ahora: en la mira o, sobre un salvaje que se mueve, un poco adelante suyo.
func aim_throw_point() -> Vector2:
	if not is_instance_valid(_aim_target):
		return _aim_point
	var pos := _aim_target.global_position
	var flight := clampf(world.trainer.global_position.distance_to(pos) / 260.0, 0.25, 0.6)
	return pos + _aim_target.velocity * flight * AIM_LEAD


func aim_mark() -> BallAim:
	return _aim_mark


func _stop_aiming() -> void:
	_aiming = false
	_aim_target = null
	if is_instance_valid(_aim_mark):
		_aim_mark.queue_free()
	_aim_mark = null


## El salvaje más cercano a un punto, hasta esa distancia.
func _nearest_wild(at: Vector2, max_dist: float) -> Creature:
	var best: Creature = null
	var best_d := max_dist
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.team == Creature.Team.WILD and c.owner_name == "" and not c.is_down() and c.visible and not c.is_burrowed() \
				and c.global_position.distance_to(at) < best_d:
			best_d = c.global_position.distance_to(at)
			best = c
	return best


## Sin salvajes al alcance: adelante de quien manejás.
func _ahead_point() -> Vector2:
	var c: Creature = world.companion
	if world.combat.in_battle and is_instance_valid(c):
		return c.global_position + c.facing.normalized() * THROW_RANGE * 0.6
	return world.trainer.global_position + world.trainer.facing * THROW_RANGE * 0.6


## Bola que se lanzaría: la elegida si quedan; si no, la primera que haya.
func ball_to_throw() -> ItemData:
	var chosen: ItemData = DB.items.get(GameState.selected_ball)
	if chosen != null and GameState.item_count(chosen.id) > 0:
		return chosen
	var balls := GameState.pocket_items(ItemData.Pocket.BALLS)
	return balls[0] if not balls.is_empty() else null


## Lanza una bola hacia un punto del mundo. Devuelve la bola en vuelo (o null si no se pudo).
func throw_ball(at: Vector2) -> BallThrow:
	if _cooldown > 0.0 or GameState.party.is_empty():
		return null
	var ball := ball_to_throw()
	if ball == null:
		Events.message_requested.emit("No te quedan Pokéballs.")
		return null
	if indoors(world.trainer.global_position):
		Events.message_requested.emit("Acá adentro no se pueden tirar Pokébolas.")
		return null
	var from: Vector2 = world.trainer.global_position + Vector2(0, -4)
	var to := from + (at - from).limit_length(THROW_RANGE)
	GameState.remove_item(ball.id)
	_cooldown = THROW_COOLDOWN
	var b := BallThrow.new()
	world.entities.add_child(b)
	b.throw(ball, from, to)
	if to != from:
		world.trainer.facing = world.trainer._four_dir((to - from).normalized())
	return b


## Adentro de una casa, Centro, tienda, gimnasio o garita (bioma "interior": ahí nunca hay salvajes) no se tiran
## Pokébolas (pedido del usuario 2026-10-29). Las cuevas, la Torre, la Central y la Mansión son "cueva": ahí sí.
func indoors(pos: Vector2) -> bool:
	var entry: ZoneEntry = world.streamer.world_data.zone_at(pos)
	return entry != null and entry.biome == "interior"


## Usa el objeto rápido sobre el Pokémon activo. Devuelve si se usó.
func use_quick_item() -> bool:
	var inst := GameState.active()
	var it: ItemData = DB.items.get(GameState.quick_item)
	if inst == null or it == null:
		return false
	if GameState.item_count(it.id) <= 0:
		Events.message_requested.emit("No te quedan %s." % it.display_name)
		return false
	var c: Creature = world.companion
	var on_field: bool = is_instance_valid(c) and c.instance == inst and not c.is_down()
	if world.combat.in_battle and not it.usable_in_battle:
		Events.message_requested.emit("%s no se puede usar en combate." % it.display_name)
		return false
	if on_field and world.combat.in_battle and not c.can_act():
		return false
	var text := GameState.use_item_on(it.id, inst, c.statuses if on_field else null)
	if text == "":
		Events.message_requested.emit("%s no tendría efecto." % it.display_name)
		return false
	Events.message_requested.emit(text)
	if world.combat.in_battle:
		GameState.last_item_used = it.id  # (Reciclaje)
	if on_field:
		Fx.burst(c.get_parent(), c.global_position + Vector2(0, -8), Color(0.6, 1.4, 0.7), 10, 30.0)
	# (la vida en pantalla y quedar expuesto en combate los maneja CombatDirector con Events.item_used)
	return true
