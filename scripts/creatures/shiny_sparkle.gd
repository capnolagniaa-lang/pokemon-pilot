class_name ShinySparkle
extends Node2D
## Destello de un Pokémon shiny al aparecer (como en los juegos): estrellitas que salen del cuerpo y se apagan, con su
## sonido (audio/efectos/shiny.wav). Lo agrega Creature._ready si CreatureInstance.shiny; se borra solo.

const DURATION := 1.3
const STARS := 8
const COLORS := [Color(1.0, 0.95, 0.55), Color(0.75, 0.95, 1.0), Color(1, 1, 1)]

var _time := 0.0


func _ready() -> void:
	position = Vector2(0, -14)  # a la altura del cuerpo (el origen de la criatura está en los pies)
	z_index = 30
	Sound.sfx("shiny")


func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := _time / DURATION
	for i in STARS:
		var a := TAU * i / STARS + t * 1.5
		var r := 6.0 + 18.0 * t + (3.0 if i % 2 == 0 else 0.0)
		var size := 3.5 * (1.0 - t) + 0.5
		var c: Color = COLORS[i % COLORS.size()]
		c.a = 1.0 - t * t
		_star(Vector2(cos(a), sin(a)) * r, size, c)


## Estrella de 4 puntas (dos rombos finos cruzados).
func _star(p: Vector2, s: float, c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p + Vector2(0, -s * 2), p + Vector2(s * 0.4, 0), p + Vector2(0, s * 2),
		p + Vector2(-s * 0.4, 0)]), c)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-s * 2, 0), p + Vector2(0, s * 0.4), p + Vector2(s * 2, 0),
		p + Vector2(0, -s * 0.4)]), c)
