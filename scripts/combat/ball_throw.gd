class_name BallThrow
extends Node2D
## Una Pokébola lanzada (docs/PLAN_CAPTURA_MOCHILA.md): vuela en arco hasta el punto apuntado. Si al bajar toca
## a un salvaje, lo mete adentro, tiembla según la fórmula oficial (Capture.roll) y lo atrapa o lo deja escapar.
## Si no toca a nadie, rebota y se pierde (la bola ya se gastó al lanzarla).

## Terminó: "miss", "caught" o "escaped".
signal finished(result: String)

const HIT_RADIUS := 13.0
const SHAKE_TIME := 0.55
const ARC_HEIGHT := 26.0

var ball: ItemData
var from := Vector2.ZERO
var to := Vector2.ZERO
var thrower_team := Creature.Team.ALLY
## Resultado (para los autotests): "" en vuelo, "miss", "caught", "escaped".
var result := ""
var _flight := 0.4
var _time := 0.0
var _phase := "fly"  # fly, capture, done
var _height := 0.0
var _wobble := 0.0
var _target: Creature


func throw(p_ball: ItemData, p_from: Vector2, p_to: Vector2) -> void:
	Events.ball_thrown.emit()
	ball = p_ball
	from = p_from
	to = p_to
	global_position = from
	_flight = clampf(from.distance_to(to) / 260.0, 0.25, 0.6)
	z_index = 5


func _physics_process(delta: float) -> void:
	if _phase != "fly":
		queue_redraw()
		return
	_time += delta
	var k := clampf(_time / _flight, 0.0, 1.0)
	global_position = from.lerp(to, k)
	_height = sin(k * PI) * ARC_HEIGHT
	if k > 0.55:
		var hit := _wild_at(global_position)
		if hit != null:
			_capture(hit)
			return
	if k >= 1.0:
		_miss()
	queue_redraw()


func _wild_at(pos: Vector2) -> Creature:
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.team != thrower_team and not c.is_down() and c.visible and c.global_position.distance_to(pos) < HIT_RADIUS:
			return c
	return null


func _miss() -> void:
	_phase = "done"
	result = "miss"
	finished.emit(result)
	var tw := create_tween()
	tw.tween_property(self, "global_position", global_position + Vector2(10, 4), 0.25)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.35)
	tw.tween_callback(queue_free)


## Mete al salvaje en la bola, tiembla y decide.
func _capture(c: Creature) -> void:
	_phase = "capture"
	_target = c
	global_position = c.global_position
	_height = 0.0
	var statuses: Array = c.statuses.active.keys()
	var shakes := Capture.roll(c.instance, ball.catch_mult, statuses)
	Fx.burst(get_parent(), c.global_position + Vector2(0, -8), Color(1.4, 1.2, 1.4), 14, 50.0)
	c.set_captured(true)
	for i in mini(shakes, 3):
		await get_tree().create_timer(SHAKE_TIME * 0.5).timeout
		Events.ball_shook.emit()
		var tw := create_tween()
		tw.tween_property(self, "_wobble", 0.5, 0.08)
		tw.tween_property(self, "_wobble", -0.5, 0.12)
		tw.tween_property(self, "_wobble", 0.0, 0.08)
		await get_tree().create_timer(SHAKE_TIME * 0.5).timeout
		if not is_instance_valid(c):
			queue_free()
			return
	await get_tree().create_timer(0.3).timeout
	if not is_instance_valid(c):
		queue_free()
		return
	if shakes >= Capture.SHAKES_TO_CATCH:
		_caught(c)
	else:
		_escaped(c)


func _caught(c: Creature) -> void:
	result = "caught"
	_phase = "done"
	finished.emit(result)
	var inst := c.instance
	var where := GameState.add_caught(inst)
	Fx.burst(get_parent(), global_position + Vector2(0, -4), Color(1.6, 1.5, 0.6), 12, 40.0)
	Events.message_requested.emit("¡Atrapaste a %s!%s" % [inst.species.display_name,
		"" if where == "equipo" else " Como el equipo está lleno, fue a la Caja."])
	Events.pokemon_caught.emit(inst, where)
	c.queue_free()
	var tw := create_tween()
	tw.tween_interval(0.6)
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(queue_free)


func _escaped(c: Creature) -> void:
	Events.capture_escaped.emit()
	result = "escaped"
	_phase = "done"
	finished.emit(result)
	c.set_captured(false)
	c.emote("!", 1.0)
	Fx.burst(get_parent(), c.global_position + Vector2(0, -8), Color(1.4, 1.2, 1.4), 16, 60.0)
	Events.message_requested.emit("¡Oh, no! ¡%s se escapó!" % c.instance.species.display_name)
	queue_free()


func _draw() -> void:
	if ball == null or ball.icon == null:
		return
	# Sombra en el suelo y la bola arriba (en arco).
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 4.0, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2(0, -6 - _height), _wobble, Vector2.ONE * 0.5)
	var s := ball.icon.get_size()
	draw_texture(ball.icon, -s / 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
