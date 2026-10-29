class_name PlayerItems
extends Node
## Lo que el jugador usa de la mochila en el mundo (docs/PLAN_CAPTURA_MOCHILA.md):
##  · **E** lanza la Pokébola elegida (GameState.selected_ball) desde el entrenador hacia el mouse (alcance
##    limitado). Funciona en combate y fuera de él.
##  · **C** usa el objeto de la ranura rápida (GameState.quick_item) sobre tu Pokémon activo. En combate tu
##    Pokémon queda expuesto un instante (ItemData.use_time).

const THROW_RANGE := 160.0
const THROW_COOLDOWN := 1.2

var world: Node
var _cooldown := 0.0


func _ready() -> void:
	world = get_parent()


func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	var story: StoryDirector = world.get("story")
	var in_arena: bool = world.get("arena") != null and world.arena.active
	# En una conversación E y C no hacen nada más; pero las peleas de entrenador/gimnasio/torneo arrancan desde una
	# charla (la historia queda ocupada toda la pelea): ahí sí (pedido del usuario 2026-10-26).
	if story != null and (story.dialog.active or (story.busy and not in_arena)):
		return
	if Input.is_action_just_pressed("capture"):
		# E contextual (docs/PLAN_HISTORIA.md): si hay alguien al lado, habla; si no, lanza la Pokébola.
		if story == null or not story.try_interact():
			if world.get("arena") != null and world.arena.active:
				Events.message_requested.emit("¡No se puede atrapar al Pokémon de otro entrenador!")
			else:
				throw_ball(world.get_global_mouse_position())
	if Input.is_action_just_pressed("quick_item"):
		use_quick_item()


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
	if on_field:
		Fx.burst(c.get_parent(), c.global_position + Vector2(0, -8), Color(0.6, 1.4, 0.7), 10, 30.0)
	# (la vida en pantalla y quedar expuesto en combate los maneja CombatDirector con Events.item_used)
	return true
