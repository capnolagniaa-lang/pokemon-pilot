class_name FieldItem
extends Area2D
## Un objeto en el suelo (docs/PLAN_CAPTURA_MOCHILA.md): una Pokéball con un brillo. Se recoge pasando por
## encima con el entrenador. `key` = lugar fijo del mapa ("zona:x,y", se recuerda en GameState.field_picked);
## vacío = botín de un salvaje (se va solo después de `lifetime` segundos).

var item: ItemData
var amount := 1
var key := ""
var lifetime := 0.0
var _time := 0.0


func _ready() -> void:
	add_to_group("field_items")
	collision_layer = 0
	collision_mask = 4  # el entrenador (capa 3)
	var shape := CircleShape2D.new()
	shape.radius = 7.0
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -3)
	add_child(col)
	body_entered.connect(_on_body)


func _process(delta: float) -> void:
	_time += delta
	if lifetime > 0.0 and _time > lifetime:
		queue_free()
	queue_redraw()


func _on_body(body: Node) -> void:
	if body is Trainer:
		pick_up()


func pick_up() -> void:
	if is_queued_for_deletion():
		return
	GameState.add_item(item.id, amount)
	if key != "":
		GameState.field_picked[key] = GameState.play_time
	Events.message_requested.emit("¡Encontraste %s%s!" % [item.display_name, "" if amount == 1 else " ×%d" % amount])
	Fx.burst(get_parent(), global_position + Vector2(0, -4), Color(1.5, 1.4, 0.8), 8, 30.0)
	queue_free()


func _draw() -> void:
	# Pokéball del suelo (como en los juegos) + un destello que aparece cada tanto.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 4.5, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2(0, -5), 0.0, Vector2.ONE)
	draw_circle(Vector2.ZERO, 4.0, Color(0.9, 0.15, 0.15))
	draw_rect(Rect2(-4, 0, 8, 4), Color(0.95, 0.95, 0.95))
	draw_arc(Vector2.ZERO, 4.0, 0.0, TAU, 14, Color(0.1, 0.1, 0.1), 1.0)
	draw_line(Vector2(-4, 0), Vector2(4, 0), Color(0.1, 0.1, 0.1), 1.0)
	draw_circle(Vector2.ZERO, 1.2, Color(1, 1, 1))
	var k := fmod(_time, 1.8)
	if k < 0.35:
		var a := 1.0 - k / 0.35
		var p := Vector2(3, -4)
		var s := 2.0 + k * 8.0
		draw_line(p - Vector2(s, 0), p + Vector2(s, 0), Color(1.6, 1.6, 1.2, a), 1.0)
		draw_line(p - Vector2(0, s), p + Vector2(0, s), Color(1.6, 1.6, 1.2, a), 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
