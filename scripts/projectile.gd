extends Node2D
## Disparo de un ataque, o la Poké Ball si is_ball = true.

var arena: Node2D
var team := 0
var attack: Dictionary = {}
var velocity := Vector2.ZERO
var life := 1.0
var radius := 7.0
var color := Color.WHITE
var is_ball := false
var bounds := Rect2()
var spin := 0.0


func _ready() -> void:
	add_to_group("projectiles")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _physics_process(delta: float) -> void:
	position += velocity * delta
	life -= delta
	spin += delta * 12.0
	if life <= 0.0 or not bounds.has_point(position):
		if is_ball:
			arena.on_ball_missed()
		queue_free()
		return
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.team == team or c.hp <= 0.0:
			continue
		if position.distance_to(c.global_position) < radius + c.radius:
			if is_ball:
				arena.on_ball_hit(c)
			else:
				c.take_hit(attack, position)
			queue_free()
			return
	queue_redraw()


func _draw() -> void:
	if is_ball:
		var tex := Game.texture("res://sprites/items/poke-ball.png")
		if tex != null:
			draw_set_transform(Vector2.ZERO, spin, Vector2(1.4, 1.4))
			draw_texture(tex, -tex.get_size() / 2.0)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_circle(Vector2.ZERO, radius, Color.WHITE)
		return
	draw_circle(Vector2.ZERO, radius * 1.7, Color(color, 0.25))
	draw_circle(Vector2.ZERO, radius, color)
	draw_circle(Vector2.ZERO, radius * 0.45, Color(1, 1, 1, 0.7))
