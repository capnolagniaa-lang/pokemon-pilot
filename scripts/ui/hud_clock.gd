class_name HudClock
extends Control
## Relojito arriba a la izquierda (pedido del usuario 2026-10-30): la hora del juego (GameState.time_of_day, la corre
## DayNight) con un sol o una luna según sea de día o de noche; los dos puntos titilan mientras el tiempo corre.

const SIZE := Vector2(96, 30)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = SIZE
	size = SIZE


func _process(_delta: float) -> void:
	queue_redraw()


## "HH:MM" de una hora del juego (0-24).
static func text_for(h: float) -> String:
	var minutes := int(fposmod(h, 24.0) * 60.0)
	return "%02d:%02d" % [minutes / 60, minutes % 60]


func _draw() -> void:
	var h := GameState.time_of_day
	var r := Rect2(Vector2.ZERO, SIZE)
	draw_style_box(UiStyle.box(Color(UiStyle.BG, 0.72), UiStyle.BORDER, 1, 0), r)
	var day := h >= DayNight.SUNRISE and h < DayNight.SUNSET
	_draw_icon(Vector2(17, SIZE.y / 2.0), day)
	var font := get_theme_default_font()
	var txt := text_for(h)
	# Los dos puntos titilan cada segundo real si la hora corre (con hora fija quedan quietos).
	var running := float(GameState.setting("time_lock")) < 0.0
	if running and Time.get_ticks_msec() % 1000 >= 500:
		txt = txt.replace(":", " ")
	draw_string(font, Vector2(32, 21), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, UiStyle.TEXT)


## Sol (círculo con rayitos) o luna (medialuna), dibujados por código.
func _draw_icon(c: Vector2, day: bool) -> void:
	if day:
		var sun := Color(1.0, 0.82, 0.3)
		draw_circle(c, 5.0, sun)
		for i in 8:
			var d := Vector2.RIGHT.rotated(TAU * i / 8.0)
			draw_line(c + d * 7.0, c + d * 9.5, sun, 1.5)
	else:
		# Medialuna de a píxel: adentro del círculo grande y afuera del corrido (el fondo es semitransparente).
		for y in range(-7, 8):
			for x in range(-7, 8):
				var p := Vector2(x + 0.5, y + 0.5)
				if p.length() <= 6.5 and (p - Vector2(3.0, -2.5)).length() > 5.5:
					draw_rect(Rect2(c + Vector2(x, y), Vector2.ONE), Color(0.86, 0.90, 1.0))
