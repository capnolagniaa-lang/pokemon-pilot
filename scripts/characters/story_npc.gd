class_name StoryNPC
extends CharacterBody2D
## Una persona del mundo que habla (docs/PLAN_HISTORIA.md, H-0). Datos en su NpcData; la saca StoryDirector.
## Bloquea el paso, se da vuelta a mirarte cuando te acercás y, si tiene `look_around`, mira a los costados.

const NOTICE_RADIUS := 40.0
## Sprites de FireRed: art/pret/characters/<gfx>.png + npcs.json (ancho de cada cuadro). Cuadro 0 = abajo,
## 1 = arriba, 2 = costado (izquierda; la derecha es espejada).
const SPRITES_DIR := "res://art/pret/characters/"

const WALK_SPEED := 30.0
const WALK_STEP_TIME := 0.16
const WALK_CELLS_MAX := 5
const REST_MIN := 1.0
const REST_MAX := 4.5
## Cuadros de caminar de las hojas de FireRed: abajo, arriba, costado.
const WALK_FRAMES := [[3, 0, 4, 0], [5, 1, 6, 1], [7, 2, 8, 2]]

static var _index: Dictionary = {}

var data: NpcData
var facing := Vector2i.DOWN
var _look_timer := 0.0
var _rest := 0.0
## Dónde puede caminar (en coordenadas del mundo; lo pone StoryDirector desde NpcData.wander_rect).
var wander_area := Rect2()
var _walk_left := 0.0
var _step := 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var name_label: Label = $Name


func _ready() -> void:
	add_to_group("story_npcs")
	var path := SPRITES_DIR + data.gfx + ".png"
	if ResourceLoader.exists(path):
		sprite.texture = load(path)
		var info: Dictionary = _frames_index().get(data.gfx, {})
		sprite.hframes = maxi(1, sprite.texture.get_width() / int(info.get("w", 16)))
		sprite.offset = Vector2(0, -int(info.get("h", 32)) / 2.0)  # pies en el origen
	name_label.text = data.display_name
	name_label.visible = false
	facing = data.facing
	_apply_facing()
	_look_timer = randf_range(1.5, 4.0)
	_rest = randf_range(0.0, REST_MAX)


static func _frames_index() -> Dictionary:
	if _index.is_empty() and FileAccess.file_exists(SPRITES_DIR + "npcs.json"):
		var d = JSON.parse_string(FileAccess.get_file_as_string(SPRITES_DIR + "npcs.json"))
		if d is Dictionary:
			_index = d
	return _index


func _process(delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("trainer")
	var near := player != null and player.global_position.distance_to(global_position) < NOTICE_RADIUS
	# El nombre, solo el del más cercano (en un mostrador con tres juntos se pisaban).
	name_label.visible = near and _closest_to(player)
	if near:
		look_at_point(player.global_position)
	elif data.look_around:
		_look_timer -= delta
		if _look_timer <= 0.0:
			_look_timer = randf_range(1.5, 4.0)
			facing = [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP].pick_random()
			_apply_facing()


## Los que caminan (NpcData.wander_rect): un tramo en línea recta, un descanso. Con vos cerca se quedan a hablarte.
func _physics_process(delta: float) -> void:
	if wander_area.size == Vector2.ZERO:
		return
	var player: Node2D = get_tree().get_first_node_in_group("trainer")
	if player != null and player.global_position.distance_to(global_position) < NOTICE_RADIUS:
		_stop_walking()
		return
	if _walk_left <= 0.0:
		_rest -= delta
		if _rest <= 0.0:
			_start_walking()
		return
	velocity = Vector2(facing) * WALK_SPEED
	move_and_slide()
	_walk_left -= WALK_SPEED * delta
	_step += delta
	_animate_walk()
	if get_real_velocity().length() < WALK_SPEED * 0.5 or not wander_area.has_point(global_position):
		_stop_walking()


func _start_walking() -> void:
	_rest = randf_range(REST_MIN, REST_MAX)
	var f: Vector2i = [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP].pick_random()
	var length := randi_range(1, WALK_CELLS_MAX) * 16.0
	# Hasta dónde puede ir sin salirse de su rectángulo.
	while length > 0.0 and not wander_area.has_point(global_position + Vector2(f) * length):
		length -= 16.0
	if length <= 0.0:
		return
	facing = f
	_apply_facing()
	_walk_left = length


func _stop_walking() -> void:
	if _walk_left > 0.0:
		_walk_left = 0.0
		velocity = Vector2.ZERO
		_apply_facing()


func _animate_walk() -> void:
	if sprite.hframes < 9:
		return
	var row: int = 0 if facing.y > 0 else (1 if facing.y < 0 else 2)
	sprite.frame = WALK_FRAMES[row][int(_step / WALK_STEP_TIME) % 4]
	sprite.flip_h = facing.x > 0


## "¡!" sobre la cabeza (un entrenador que te vio).
func show_emote(text: String = "!") -> void:
	var l := UiStyle.label(text, 16, Color(1, 0.95, 0.4))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 5)
	l.position = Vector2(-4, -50)
	add_child(l)
	l.scale = Vector2(0.2, 0.2)
	var tw := l.create_tween()
	tw.tween_property(l, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.7)
	tw.tween_callback(l.queue_free)


## Camina hasta quedar al lado de `p` (a `stop` px) y vuelve cuando llegó.
func walk_to(p: Vector2, stop: float = 18.0) -> void:
	look_at_point(p)
	var d := p - global_position
	var dest := global_position + d - d.normalized() * stop if d.length() > stop else global_position
	var tw := create_tween()
	tw.tween_property(self, "global_position", dest, global_position.distance_to(dest) / 70.0)
	await tw.finished


func look_at_point(p: Vector2) -> void:
	var d := p - global_position
	var f := Vector2i(int(signf(d.x)), 0) if absf(d.x) > absf(d.y) else Vector2i(0, int(signf(d.y)))
	if f != facing and f != Vector2i.ZERO:
		facing = f
		_apply_facing()


func _apply_facing() -> void:
	if sprite.hframes < 3:
		sprite.frame = 0
		return
	if facing.y > 0:
		sprite.frame = 0
	elif facing.y < 0:
		sprite.frame = 1
	else:
		sprite.frame = 2
	sprite.flip_h = facing.x > 0


func _closest_to(player: Node2D) -> bool:
	var d := player.global_position.distance_squared_to(global_position)
	for other: Node2D in get_tree().get_nodes_in_group("story_npcs"):
		if other != self and other.visible and player.global_position.distance_squared_to(other.global_position) < d:
			return false
	return true
