class_name SoccerMatch
extends Node2D
## El partido de adorno del estadio de Fucsia (`ExtraPitch`): dos equipos de Pokémon con camiseta (shaders/jersey). El que lleva la
## pelota va al arco de enfrente, esquiva si tiene un rival adelante y se la pasa a un compañero en cuanto ve uno libre (idea del
## usuario, 2026-11-06); los demás buscan espacios vacíos durante el ataque, los rivales se la intentan robar y de cerca patea.
## Nadie lo controla, no se pelea con ellos y no choca con nada; los goles van al marcador.

const JERSEY := preload("res://shaders/jersey.gdshader")
const CONTROL_RANGE := 11.0
const FOOT_OFFSET := 8.0
## Después de patearla, el que la pateó no la puede agarrar por un rato (si no, se la queda).
const OWN_KICK_LOCK := 0.5
const KICK_ANIM := 0.35
const KICK_STOP := 0.2
const SHOOT_RANGE := 80.0
const SHOT_SPREAD := 0.14
const SHOOT_SPEED := 210.0
const PASS_SPEED := 150.0
const CLEAR_SPEED := 130.0
const BALL_FRICTION := 1.3
## Una pelota más rápida que esto no la controla un jugador de campo (un tiro), solo el arquero.
const TOO_FAST := 165.0
## Parte de los tiros que el arquero no llega a sacar (si no, los ataja todos).
const SHOT_BEATS_KEEPER := 0.28
const RUN_MIN := 40.0
const RUN_MAX := 52.0
const CARRY_SLOW := 0.8
const KEEPER_SPEED := 58.0
const KEEPER_REACH := 0.3
const KEEPER_HOLD := 0.7
## Lo mínimo que la lleva antes de poder pasarla.
const CARRY_MIN := 0.2
const CARRY_MAX := 0.45
## Un rival adelante a esta distancia: lo esquiva.
const RIVAL_SEE := 46.0
const RIVAL_AHEAD_DOT := 0.15
## Encerrado este rato sin nadie libre: la revienta para adelante.
const PRESSED_MAX := 1.8
## Un compañero está libre si no tiene un rival a esta distancia ni en el camino del pase.
const FREE_RADIUS := 26.0
const LANE_CLEAR := 12.0
## Sin presión, solo la pasa si el compañero está más adelante que esto.
const PASS_AHEAD := 8.0
const TACKLE_RANGE := 13.0
const TACKLE_CHANCE := 0.3
## Recién agarrada la pelota no se la pueden sacar (si no, se la roban de un lado a otro sin parar).
const SAFE_AFTER_TAKE := 0.9
const TACKLE_COOLDOWN := 0.9
## Al que le roban la pelota queda aturdido este rato (pedido del usuario): así no se la sacan uno al otro sin parar.
const ROBBED_STUN := 1.0
const ROBBED_ANIM := 0.7
## Cuánto sigue a la pelota cada uno desde su puesto, y cuánto se adelanta si su equipo la tiene.
const FOLLOW_X := 0.5
const FOLLOW_Y := 0.35
## Buscar espacio: cuántos lugares mira, cada cuánto vuelve a mirar y hasta dónde adelante de la pelota.
const SPACE_TRIES := 10
const SPACE_EVERY := 0.6
const SPACE_AHEAD := 120.0
const SPACE_FROM_MATE := 42.0
const KEEPER_OFF := 10.0
const GOAL_PAUSE := 2.6
## Colores de cada equipo: [principal, segundo, dibujo] (0 rayas, 1 banda).
const KITS := [[Color(0.42, 0.72, 0.96), Color(0.97, 0.97, 0.97), 0], [Color(0.09, 0.2, 0.56), Color(0.98, 0.82, 0.16), 1]]


## Un jugador. Lo mueve el partido; `facing` y `velocity` los lee CreatureSprite.
class Player extends CharacterBody2D:
	var team := 0
	var keeper := false
	var home := Vector2.ZERO
	var speed := 45.0
	var own_lock := 0.0
	var tackle_cd := 0.0
	var stop := 0.0
	var facing := Vector2.DOWN
	var space_target := Vector2.ZERO
	var space_left := 0.0
	var sprite: CreatureSprite


var pitch: ExtraPitch
var field := Rect2()
var players: Array[Player] = []
var ball := Vector2.ZERO
var ball_vel := Vector2.ZERO
var ball_height := 0.0
var ball_rise := 0.0
var score: Array[int] = [0, 0]
var kicks := 0
var kicks_of: Array[int] = [0, 0]
var passes := 0
var steals := 0
var dodges := 0
var carrier: Player
var _receiver: Player
var _carry_left := 0.0
var _pressed := 0.0
var _safe := 0.0
var _dodging := false
var _keeper_beaten := false
var _pause := 0.0
var _last_scorer := -1
var _ball_node: Node2D
var _board: Label
var _shout: Label


static func make(p: ExtraPitch) -> SoccerMatch:
	var m := SoccerMatch.new()
	m.pitch = p
	m.field = p.field
	m.name = "Pitch_" + p.id
	return m


func _ready() -> void:
	y_sort_enabled = true
	var sp: SpeciesData = DB.species.get(pitch.species_id)
	if sp == null:
		return
	for team in 2:
		var mat := ShaderMaterial.new()
		mat.shader = JERSEY
		var kit: Array = KITS[team]
		mat.set_shader_parameter("main_color", Vector3(kit[0].r, kit[0].g, kit[0].b))
		mat.set_shader_parameter("second_color", Vector3(kit[1].r, kit[1].g, kit[1].b))
		mat.set_shader_parameter("pattern", kit[2])
		for i in pitch.players_per_team:
			players.append(_new_player(sp, team, i, mat))
	_ball_node = _Ball.new()
	_ball_node.match_ = self
	add_child(_ball_node)
	_add_board()
	_kick_off(randi() % 2)


func _new_player(sp: SpeciesData, team: int, i: int, mat: ShaderMaterial) -> Player:
	var p := Player.new()
	p.team = team
	p.keeper = i == 0
	p.collision_layer = 0
	p.collision_mask = 0
	p.speed = KEEPER_SPEED if p.keeper else randf_range(RUN_MIN, RUN_MAX)
	p.home = _home_of(team, i)
	var spr := CreatureSprite.new()
	spr.name = "Sprite"
	spr.material = mat
	p.sprite = spr
	p.add_child(spr)
	spr.species = sp
	add_child(p)
	return p


func _side(team: int) -> float:
	return 1.0 if team == 0 else -1.0


## Su puesto: el arquero en su arco y los demás repartidos por su mitad.
func _home_of(team: int, i: int) -> Vector2:
	var side := _side(team)
	var mid := field.get_center()
	if i == 0:
		return Vector2(mid.x - side * (field.size.x * 0.5 - KEEPER_OFF), mid.y)
	var others := maxi(1, pitch.players_per_team - 1)
	var x := mid.x - side * field.size.x * lerpf(0.3, 0.08, (i - 1.0) / maxf(1.0, others - 1.0))
	var y: float = mid.y + field.size.y * 0.3 * ([-1.0, 1.0, 0.0][(i - 1) % 3])
	return Vector2(x, y)


## Saque del medio para `team` (el que recibió el gol).
func _kick_off(team: int) -> void:
	ball = field.get_center()
	ball_vel = Vector2.ZERO
	ball_height = 0.0
	ball_rise = 0.0
	carrier = null
	_receiver = null
	_keeper_beaten = false
	for p in players:
		p.position = p.home
		p.velocity = Vector2.ZERO
		p.sprite.lift = 0.0
		p.stop = 0.0
		p.own_lock = 0.0
		p.facing = Vector2.RIGHT if p.team == 0 else Vector2.LEFT
	# El más adelantado del que saca arranca con la pelota.
	var best: Player = null
	for p in players:
		if p.team == team and not p.keeper and (best == null or _side(team) * p.position.x > _side(team) * best.position.x):
			best = p
	if best != null:
		best.position = ball - Vector2(_side(team) * FOOT_OFFSET, 0)
		_take(best)
	if _shout != null:
		_shout.visible = false


func _physics_process(delta: float) -> void:
	if players.is_empty():
		return
	if _pause > 0.0:
		_pause -= delta
		_celebrate()
		if _pause <= 0.0:
			_kick_off(1 - _last_scorer)
		return
	_move_ball(delta)
	if _pause > 0.0:
		return
	var chasers := [_chaser(0), _chaser(1)]
	var first := randi() % players.size()  # (en distinto orden cada vez: así ningún equipo llega siempre primero)
	for i in players.size():
		var p := players[(first + i) % players.size()]
		_update(p, p == chasers[p.team], delta)


func _move_ball(delta: float) -> void:
	if carrier != null:
		ball = carrier.position + carrier.facing * FOOT_OFFSET
		ball.x = clampf(ball.x, field.position.x, field.end.x)
		ball.y = clampf(ball.y, field.position.y, field.end.y)
		ball_vel = Vector2.ZERO
		ball_height = 0.0
		return
	ball += ball_vel * delta
	ball_vel *= exp(-BALL_FRICTION * delta)
	ball_height = maxf(0.0, ball_height + ball_rise * delta)
	ball_rise -= 150.0 * delta
	if ball_height <= 0.0:
		ball_rise = absf(ball_rise) * 0.45 if absf(ball_rise) > 16.0 else 0.0
	var mid := field.get_center()
	# Entró al arco.
	if absf(ball.x - mid.x) > field.size.x * 0.5 and absf(ball.y - mid.y) < pitch.goal_half:
		_goal(0 if ball.x > mid.x else 1)
		return
	# Afuera: rebota en la línea (no hay laterales).
	if ball.x < field.position.x or ball.x > field.end.x:
		ball.x = clampf(ball.x, field.position.x, field.end.x)
		ball_vel.x *= -0.6
	if ball.y < field.position.y or ball.y > field.end.y:
		ball.y = clampf(ball.y, field.position.y, field.end.y)
		ball_vel.y *= -0.6


## Quién va a buscar la pelota en ese equipo: al que le pasaron, o el más cerca. Si la tiene su equipo, nadie.
func _chaser(team: int) -> Player:
	if carrier != null and carrier.team == team:
		return null
	if _receiver != null and _receiver.team == team:
		return _receiver
	var best: Player = null
	var best_d := INF
	for p in players:
		if p.team != team or p.keeper or p.stop > KICK_STOP:  # (el aturdido no: va otro)
			continue
		var d := p.position.distance_to(ball)
		if d < best_d:
			best_d = d
			best = p
	return best


func _update(p: Player, chasing: bool, delta: float) -> void:
	p.own_lock = maxf(0.0, p.own_lock - delta)
	p.tackle_cd = maxf(0.0, p.tackle_cd - delta)
	p.stop = maxf(0.0, p.stop - delta)
	if p.stop > 0.0:
		p.velocity = Vector2.ZERO
		return
	if p == carrier:
		_carry(p, delta)
		return
	_try_control(p)
	if p == carrier:
		return
	_run_to(p, _target_of(p, chasing), p.speed, delta)


## Agarra la pelota si está suelta y a su alcance, o se la intenta robar al que la lleva.
func _try_control(p: Player) -> void:
	var d := p.position.distance_to(ball)
	if carrier != null:
		if carrier.team != p.team and not carrier.keeper and not p.keeper and d < TACKLE_RANGE and p.tackle_cd <= 0.0 and _safe <= 0.0:
			p.tackle_cd = TACKLE_COOLDOWN
			if randf() < TACKLE_CHANCE:
				steals += 1
				var robbed := carrier
				_take(p)
				robbed.stop = ROBBED_STUN
				robbed.velocity = Vector2.ZERO
				robbed.sprite.play_once("Hurt", ROBBED_ANIM)
		return
	if d > CONTROL_RANGE or p.own_lock > 0.0 or ball_height > 7.0:
		return
	var fast := ball_vel.length() > TOO_FAST
	if p.keeper:
		if fast and _keeper_beaten:
			return
	elif fast:
		return
	_take(p)


func _take(p: Player) -> void:
	carrier = p
	_receiver = null
	_keeper_beaten = false
	_carry_left = KEEPER_HOLD if p.keeper else randf_range(CARRY_MIN, CARRY_MAX)
	_pressed = 0.0
	_safe = SAFE_AFTER_TAKE
	_dodging = false


## Con la pelota: avanza al arco y decide.
func _carry(p: Player, delta: float) -> void:
	_carry_left -= delta
	_safe -= delta
	var goal := _goal_point(p.team)
	if p.keeper:
		p.velocity = Vector2.ZERO
		if _carry_left <= 0.0:
			_pass_or_clear(p, goal)
		return
	if p.position.distance_to(goal) < SHOOT_RANGE:
		_shoot(p, goal)
		return
	var rival := _rival_ahead(p, goal)
	if _carry_left <= 0.0:
		var mate := _free_mate(p, rival != null)
		if mate != null:
			_pass_to(p, mate)
			return
	if rival == null:
		_pressed = 0.0
		_dodging = false
		_run_to(p, goal, p.speed * CARRY_SLOW, delta)
		return
	_pressed += delta
	if _pressed > PRESSED_MAX:
		_pass_or_clear(p, goal)
		return
	if not _dodging:
		_dodging = true
		dodges += 1
	_run_to(p, _dodge_point(p, rival, goal), p.speed * CARRY_SLOW, delta)


## El rival más cercano que tiene adelante, entre él y el arco (o null).
func _rival_ahead(p: Player, goal: Vector2) -> Player:
	var forward := (goal - p.position).normalized()
	var best: Player = null
	var best_d := RIVAL_SEE
	for o in players:
		if o.team == p.team or o.keeper:
			continue
		var to := o.position - p.position
		if to.length() < best_d and to.normalized().dot(forward) > RIVAL_AHEAD_DOT:
			best_d = to.length()
			best = o
	return best


## Para dónde escapar: de costado, alejándose del rival, sin dejar de ir para adelante. Contra la línea, hacia el otro lado.
func _dodge_point(p: Player, rival: Player, goal: Vector2) -> Vector2:
	var forward := (goal - p.position).normalized()
	var away := (p.position - rival.position).normalized()
	var side := forward.orthogonal()
	if side.dot(away) < 0.0:
		side = -side
	var margin := 18.0
	if (p.position.y < field.position.y + margin and side.y < 0.0) or (p.position.y > field.end.y - margin and side.y > 0.0):
		side = -side
	var point := p.position + (forward * 0.5 + side + away * 0.3).normalized() * 30.0
	point.x = clampf(point.x, field.position.x + 4.0, field.end.x - 4.0)
	point.y = clampf(point.y, field.position.y + 4.0, field.end.y - 4.0)
	return point


## El compañero al que se la puede pasar ahora: libre y con el camino despejado. Sin un rival encima, solo si está más adelante.
func _free_mate(p: Player, pressed: bool) -> Player:
	var best: Player = null
	var best_score := -INF
	for m in players:
		if m == p or m.team != p.team or m.keeper:
			continue
		var ahead := _side(p.team) * (m.position.x - p.position.x)
		if not pressed and ahead < PASS_AHEAD:
			continue
		if _space_around(m) < FREE_RADIUS or not _lane_clear(p, m):
			continue
		var value := ahead + _space_around(m) * 0.6
		if value > best_score:
			best_score = value
			best = m
	return best


func _lane_clear(p: Player, m: Player) -> bool:
	for o in players:
		if o.team != p.team and Geometry2D.get_closest_point_to_segment(o.position, p.position, m.position).distance_to(o.position) < LANE_CLEAR:
			return false
	return true


func _goal_point(team: int) -> Vector2:
	return Vector2(field.end.x + 4.0 if team == 0 else field.position.x - 4.0, field.get_center().y)


func _shoot(p: Player, goal: Vector2) -> void:
	goal.y += randf_range(-0.85, 0.85) * pitch.goal_half
	_keeper_beaten = randf() < SHOT_BEATS_KEEPER
	ball_rise = 34.0
	_release(p, goal, SHOOT_SPEED, SHOT_SPREAD)


## Se la pasa al compañero mejor ubicado: adelante y sin rivales cerca. Si no hay, la revienta para adelante.
func _pass_or_clear(p: Player, goal: Vector2) -> void:
	var best: Player = null
	var best_score := -INF
	for m in players:
		if m == p or m.team != p.team or m.keeper:
			continue
		var value := _side(p.team) * (m.position.x - p.position.x) + _space_around(m) * 0.6
		if value > best_score:
			best_score = value
			best = m
	if best != null and p.keeper:
		_pass_to(p, best)
	else:
		_release(p, goal, CLEAR_SPEED, 0.3)


func _pass_to(p: Player, mate: Player) -> void:
	passes += 1
	_receiver = mate
	# Adonde va a estar cuando llegue la pelota.
	var lead: Vector2 = mate.position + mate.velocity * (mate.position.distance_to(ball) / PASS_SPEED)
	_release(p, lead, PASS_SPEED, 0.05)


## Hasta dónde está el rival más cercano (con tope).
func _space_around(m: Player) -> float:
	var near := 80.0
	for o in players:
		if o.team != m.team:
			near = minf(near, o.position.distance_to(m.position))
	return near


func _release(p: Player, at: Vector2, speed: float, spread: float) -> void:
	var dir := (at - p.position).normalized()
	ball_vel = dir.rotated(randf_range(-spread, spread)) * speed
	carrier = null
	p.own_lock = OWN_KICK_LOCK
	p.stop = KICK_STOP
	p.velocity = Vector2.ZERO
	p.facing = dir
	p.sprite.play_once("Kick", KICK_ANIM)
	kicks += 1
	kicks_of[p.team] += 1


func _target_of(p: Player, chasing: bool) -> Vector2:
	var mid := field.get_center()
	if p.keeper:
		var t := p.home
		t.y = clampf(ball.y, mid.y - pitch.goal_half, mid.y + pitch.goal_half)
		var loose := carrier == null and not (_keeper_beaten and ball_vel.length() > TOO_FAST)
		if loose and p.position.distance_to(ball) < field.size.y * KEEPER_REACH:
			return ball
		return t
	if chasing:
		return ball
	if carrier != null and carrier.team == p.team:
		return _space_for(p)
	var t := p.home + Vector2((ball.x - mid.x) * FOLLOW_X, (ball.y - mid.y) * FOLLOW_Y)
	t.x = clampf(t.x, field.position.x + 8.0, field.end.x - 8.0)
	t.y = clampf(t.y, field.position.y + 8.0, field.end.y - 8.0)
	return t


## Atacando sin la pelota: el lugar más vacío adelante de ella, lejos de los rivales y de los compañeros.
func _space_for(p: Player) -> Vector2:
	p.space_left -= get_physics_process_delta_time()
	if p.space_left > 0.0:
		return p.space_target
	p.space_left = SPACE_EVERY
	var side := _side(p.team)
	var best := p.position
	var best_score := -INF
	for i in SPACE_TRIES:
		var point := Vector2(ball.x + side * randf_range(10.0, SPACE_AHEAD), randf_range(field.position.y + 10.0, field.end.y - 10.0))
		point.x = clampf(point.x, field.position.x + 10.0, field.end.x - 10.0)
		var value := minf(_nearest_rival(point, p.team), 70.0) + side * (point.x - ball.x) * 0.35 - p.position.distance_to(point) * 0.12
		for m in players:
			if m != p and m.team == p.team and m.space_target.distance_to(point) < SPACE_FROM_MATE:
				value -= 40.0
		if value > best_score:
			best_score = value
			best = point
	p.space_target = best
	return best


func _nearest_rival(point: Vector2, team: int) -> float:
	var near := INF
	for o in players:
		if o.team != team:
			near = minf(near, o.position.distance_to(point))
	return near


func _run_to(p: Player, target: Vector2, speed: float, delta: float) -> void:
	var to := target - p.position
	if to.length() < 3.0:
		p.velocity = Vector2.ZERO
		var look := ball - p.position
		if look.length() > 1.0:
			p.facing = look.normalized()
		return
	p.velocity = to.normalized() * speed
	p.facing = p.velocity.normalized()
	p.position += p.velocity * delta


func _goal(team: int) -> void:
	score[team] += 1
	_last_scorer = team
	_pause = GOAL_PAUSE
	ball_vel = Vector2.ZERO
	carrier = null
	_board.text = _board_text()
	_shout.text = "¡GOL DE %s!" % pitch.team_names[team].to_upper()
	_shout.visible = true
	for p in players:
		p.velocity = Vector2.ZERO


## El que hizo el gol salta, los otros miran el piso.
func _celebrate() -> void:
	var t := Time.get_ticks_msec() * 0.012
	for i in players.size():
		var p := players[i]
		p.sprite.lift = maxf(0.0, sin(t + i)) * 9.0 if p.team == _last_scorer else 0.0


func _add_board() -> void:
	_board = _label(_board_text(), 16, Color(1, 0.95, 0.6))
	_board.position = Vector2(field.get_center().x - 90.0, field.position.y - 34.0)
	_board.size = Vector2(180, 20)
	_shout = _label("", 22, Color(1, 0.9, 0.3))
	_shout.position = Vector2(field.get_center().x - 140.0, field.get_center().y - 40.0)
	_shout.size = Vector2(280, 30)
	_shout.visible = false


func _label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	l.add_theme_constant_override("outline_size", 3)
	l.z_index = 6
	add_child(l)
	return l


func _board_text() -> String:
	return "%s %d - %d %s" % [pitch.team_names[0], score[0], score[1], pitch.team_names[1]]


## La pelota: blanca con manchas, con sombra en el piso.
class _Ball extends Node2D:
	var match_: SoccerMatch

	func _process(_delta: float) -> void:
		position = match_.ball
		queue_redraw()

	func _draw() -> void:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
		draw_circle(Vector2(0, 2), 3.5, Color(0, 0, 0, 0.3))
		draw_set_transform(Vector2(0, -3.0 - match_.ball_height), 0.0, Vector2.ONE)
		draw_circle(Vector2.ZERO, 3.5, Color(0.08, 0.08, 0.1))
		draw_circle(Vector2.ZERO, 2.8, Color(0.98, 0.98, 0.96))
		draw_rect(Rect2(-1, -1, 2, 2), Color(0.1, 0.1, 0.12))
		draw_rect(Rect2(-3, -1, 1, 1), Color(0.1, 0.1, 0.12))
		draw_rect(Rect2(2, 0, 1, 1), Color(0.1, 0.1, 0.12))
