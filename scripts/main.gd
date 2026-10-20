extends Node2D
## Arena de combate: elige inicial, aparecen salvajes, captura, experiencia y cambio de criatura.

const PlayerCreature = preload("res://scripts/player_creature.gd")
const WildCreature = preload("res://scripts/wild_creature.gd")
const Projectile = preload("res://scripts/projectile.gd")
const AreaBlast = preload("res://scripts/area_blast.gd")
const Hud = preload("res://scripts/hud.gd")

const ARENA := Rect2(40, 90, 1200, 520)

var choosing := true
var player: Node2D = null
var wild: Node2D = null
var hud: Control
var camera: Camera2D
var message := ""
var message_time := 0.0
var switch_cooldown := 0.0
var respawn_timer := -1.0
var shake := 0.0
var rng := RandomNumberGenerator.new()

# Modo de prueba automática: godot --path . -- --autotest
var autotest := false
var autotest_time := 0.0
var autotest_attack_timer := 0.0
var autotest_ball_timer := 3.0
var stats := {"hits": 0, "wild_fainted": 0, "captures": 0, "player_fainted": 0}


func _ready() -> void:
	rng.randomize()
	_build_walls()
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	add_child(camera)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.main = self
	layer.add_child(hud)
	autotest = "--autotest" in OS.get_cmdline_user_args()
	if autotest:
		Engine.time_scale = 3.0
		start_game(Game.STARTERS[0])


func _build_walls() -> void:
	var body := StaticBody2D.new()
	add_child(body)
	var t := 40.0
	var rects := [
		Rect2(ARENA.position.x - t, ARENA.position.y - t, ARENA.size.x + 2 * t, t),
		Rect2(ARENA.position.x - t, ARENA.end.y, ARENA.size.x + 2 * t, t),
		Rect2(ARENA.position.x - t, ARENA.position.y, t, ARENA.size.y),
		Rect2(ARENA.end.x, ARENA.position.y, t, ARENA.size.y),
	]
	for r in rects:
		var shape := RectangleShape2D.new()
		shape.size = r.size
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = r.get_center()
		body.add_child(col)


func start_game(starter: String) -> void:
	Game.party = [Game.make_entry(starter, 5)]
	Game.active = 0
	Game.balls = 10
	choosing = false
	spawn_player(Vector2(ARENA.position.x + 200, ARENA.get_center().y))
	show_message("¡Elegiste a %s! Buscá criaturas salvajes..." % starter)
	respawn_timer = 1.5


func _process(delta: float) -> void:
	if choosing:
		for i in 3:
			if Input.is_action_just_pressed("attack_%d" % (i + 1)):
				start_game(Game.STARTERS[i])
		return

	message_time = maxf(0.0, message_time - delta)
	switch_cooldown = maxf(0.0, switch_cooldown - delta)
	shake = move_toward(shake, 0.0, delta * 30.0)
	camera.offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * shake

	if respawn_timer > 0.0:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			respawn_timer = -1.0
			_heal_between_fights()
			spawn_wild()

	if Input.is_action_just_pressed("capture") and is_instance_valid(player):
		throw_ball(get_global_mouse_position() - player.global_position)
	if Input.is_action_just_pressed("switch"):
		switch_next()

	if autotest:
		_autotest_step(delta)


func spawn_player(pos: Vector2) -> void:
	player = PlayerCreature.new()
	player.arena = self
	player.setup(Game.party[Game.active], 0)
	player.position = pos
	player.fainted.connect(_on_player_fainted)
	add_child(player)


func spawn_wild() -> void:
	var names: Array = Game.SPECIES.keys()
	var sp: String = names[rng.randi() % names.size()]
	var lvl: int = maxi(1, Game.party[Game.active]["level"] + rng.randi_range(-2, 1))
	wild = WildCreature.new()
	wild.arena = self
	wild.setup(Game.make_entry(sp, lvl), 1)
	var x := ARENA.end.x - 200.0
	if is_instance_valid(player) and player.global_position.x > ARENA.get_center().x:
		x = ARENA.position.x + 200.0
	wild.position = Vector2(x, rng.randf_range(ARENA.position.y + 100, ARENA.end.y - 100))
	wild.fainted.connect(_on_wild_fainted)
	add_child(wild)
	show_message("¡Apareció un %s salvaje! (Nv. %d)" % [sp, lvl])


func _heal_between_fights() -> void:
	Game.heal_all(0.25)
	if is_instance_valid(player):
		player.hp = Game.party[Game.active]["hp"]


func spawn_projectile(user: Node2D, m: Dictionary, dir: Vector2) -> void:
	var p := Projectile.new()
	p.arena = self
	p.team = user.team
	p.attack = user.make_attack(m)
	p.velocity = dir * m["speed"]
	p.radius = m["size"]
	p.life = m["life"]
	p.color = Game.TYPE_COLORS[m["type"]]
	p.bounds = ARENA
	p.position = user.global_position + dir * (user.radius + 4.0)
	add_child(p)


func spawn_area(user: Node2D, m: Dictionary) -> void:
	var fx := AreaBlast.new()
	fx.radius = m["radius"]
	fx.color = Game.TYPE_COLORS[m["type"]]
	fx.position = user.global_position
	add_child(fx)
	var attack: Dictionary = user.make_attack(m)
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.team != user.team and c.hp > 0.0 and c.global_position.distance_to(user.global_position) < m["radius"] + c.radius:
			c.take_hit(attack, user.global_position)


func on_creature_hit(c: Node2D, dmg: float, eff: float) -> void:
	stats["hits"] += 1
	if c.team == 0:
		shake = 7.0
	var l := Label.new()
	l.text = str(int(round(dmg)))
	var col := Color.WHITE
	var size := 18
	if eff > 1.0:
		l.text += "!"
		col = Color(1.0, 0.75, 0.2)
		size = 24
	elif eff < 1.0:
		col = Color(0.7, 0.7, 0.7)
		size = 15
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 5)
	l.position = c.global_position + Vector2(rng.randf_range(-16, 4), -c.radius - 40.0)
	l.z_index = 10
	add_child(l)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 40.0, 0.7)
	tw.tween_property(l, "modulate:a", 0.0, 0.7)
	tw.chain().tween_callback(l.queue_free)


func _on_wild_fainted(c: Node2D) -> void:
	stats["wild_fainted"] += 1
	var entry: Dictionary = Game.party[Game.active]
	var gained: int = 15 + c.level * 6
	var ups := Game.add_xp(entry, gained)
	var text := "¡%s salvaje se debilitó! +%d EXP" % [c.species_name, gained]
	if ups > 0 and is_instance_valid(player):
		player.refresh_stats()
		text += " — ¡%s subió a Nv. %d!" % [entry["species"], entry["level"]]
	if rng.randf() < 0.35:
		Game.balls += 1
		text += " (+1 Poké Ball)"
	show_message(text)
	_remove_wild(c)


func _remove_wild(c: Node2D) -> void:
	wild = null
	c.remove_from_group("creatures")
	c.set_physics_process(false)
	c.collision_layer = 0
	var tw := create_tween()
	tw.tween_property(c, "modulate:a", 0.0, 0.5)
	tw.tween_callback(c.queue_free)
	respawn_timer = 2.0


func _on_player_fainted(c: Node2D) -> void:
	stats["player_fainted"] += 1
	var next := Game.next_alive(Game.active)
	if next >= 0:
		show_message("¡%s se debilitó!" % c.species_name)
		_swap_to(next)
		return
	# Todo el equipo cayó: curar y empezar otra pelea
	Game.heal_all()
	var pos: Vector2 = c.global_position
	c.queue_free()
	Game.active = 0
	spawn_player(pos)
	if is_instance_valid(wild):
		_remove_wild(wild)
	show_message("Todo tu equipo se debilitó... Los curaste y volvés a intentarlo.")


func switch_next() -> void:
	if switch_cooldown > 0.0 or not is_instance_valid(player):
		return
	var next := Game.next_alive(Game.active)
	if next < 0 or next == Game.active:
		return
	_swap_to(next)


func _swap_to(index: int) -> void:
	switch_cooldown = 1.5
	var pos: Vector2 = player.global_position
	player.remove_from_group("creatures")
	player.queue_free()
	Game.active = index
	spawn_player(pos)
	show_message("¡Adelante, %s!" % Game.party[index]["species"])


func throw_ball(aim: Vector2) -> void:
	if not is_instance_valid(wild) or Game.balls <= 0 or not get_tree().get_nodes_in_group("balls").is_empty():
		return
	if Game.party.size() >= Game.MAX_PARTY:
		show_message("Tu equipo está lleno (máx. %d)." % Game.MAX_PARTY)
		return
	Game.balls -= 1
	var b := Projectile.new()
	b.arena = self
	b.is_ball = true
	b.team = 0
	b.radius = 8.0
	b.life = 1.5
	b.bounds = ARENA
	b.velocity = aim.normalized() * 640.0
	b.position = player.global_position
	b.add_to_group("balls")
	add_child(b)


func on_ball_hit(c: Node2D) -> void:
	var ratio: float = c.hp / c.max_hp
	var chance := clampf(1.0 - ratio, 0.0, 1.0) * 0.85 + 0.08
	if rng.randf() < chance:
		stats["captures"] += 1
		var entry: Dictionary = c.data
		entry["hp"] = c.hp
		Game.party.append(entry)
		show_message("¡Atrapaste a %s! Ya está en tu equipo (Tab para cambiar)." % c.species_name)
		_remove_wild(c)
	else:
		show_message("¡%s se escapó de la Poké Ball! (%d%% de chance)" % [c.species_name, int(chance * 100)])


func on_ball_missed() -> void:
	show_message("La Poké Ball no le pegó a nada...")


func show_message(text: String) -> void:
	message = text
	message_time = 3.5
	if autotest:
		print("[msg] ", text)


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.11, 0.18, 0.13))
	draw_rect(ARENA, Color(0.36, 0.62, 0.32))
	var r := RandomNumberGenerator.new()
	r.seed = 7
	for i in 160:
		var p := Vector2(r.randf_range(ARENA.position.x + 10, ARENA.end.x - 10), r.randf_range(ARENA.position.y + 10, ARENA.end.y - 10))
		var c := Color(0.27, 0.5, 0.24)
		draw_line(p, p + Vector2(-4, -7), c, 2.0)
		draw_line(p, p + Vector2(0, -9), c, 2.0)
		draw_line(p, p + Vector2(4, -7), c, 2.0)
	draw_rect(ARENA, Color(0.2, 0.34, 0.18), false, 5.0)


func _autotest_step(delta: float) -> void:
	autotest_time += delta
	if is_instance_valid(player) and is_instance_valid(wild):
		var aim: Vector2 = wild.global_position - player.global_position
		autotest_attack_timer -= delta
		if autotest_attack_timer <= 0.0:
			autotest_attack_timer = 0.4
			player.use_move(rng.randi() % 4, aim)
			if rng.randf() < 0.2:
				player.dodge(aim.orthogonal())
		autotest_ball_timer -= delta
		if autotest_ball_timer <= 0.0:
			autotest_ball_timer = 4.0
			throw_ball(aim)
		if rng.randf() < 0.002:
			switch_next()
	if autotest_time > 40.0:
		print("[autotest] ", stats, " equipo=", Game.party.size(), " balls=", Game.balls)
		get_tree().quit()
