class_name TrainerCard
extends Control
## Tarjeta de entrenador (menú de pausa, docs/PLAN_HISTORIA.md H-5): tiempo de juego, Pokédex y las 8 medallas de
## Kanto. Las que ganaste se ven con su forma y color (la Medalla Roca: un octógono de piedra); las que faltan,
## como siluetas. Cada medalla es una bandera de la historia (medalla_roca, medalla_cascada...).

signal closed

## [bandera, nombre, líder, color, puntas del polígono]
const BADGES := [
	["medalla_roca", "Roca", "Brock", Color(0.62, 0.6, 0.58), 8],
	["medalla_cascada", "Cascada", "Misty", Color(0.4, 0.7, 1.0), 6],
	["medalla_trueno", "Trueno", "Lt. Surge", Color(1.0, 0.75, 0.25), 8],
	["medalla_arcoiris", "Arcoíris", "Erika", Color(0.6, 0.9, 0.5), 10],
	["medalla_alma", "Alma", "Koga", Color(0.85, 0.4, 0.7), 4],
	["medalla_pantano", "Pantano", "Sabrina", Color(1.0, 0.85, 0.3), 6],
	["medalla_volcan", "Volcán", "Blaine", Color(1.0, 0.4, 0.25), 5],
	["medalla_tierra", "Tierra", "Giovanni", Color(0.4, 0.8, 0.45), 7],
]


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.ACCENT.darkened(0.3), 2, 22))
	panel.position = Vector2(240, 110)
	panel.custom_minimum_size = Vector2(800, 480)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(UiStyle.label("TARJETA DE ENTRENADOR", 26, UiStyle.ACCENT))
	var secs := int(GameState.play_time)
	box.add_child(UiStyle.label("Tiempo de juego: %d:%02d" % [secs / 3600, (secs / 60) % 60], 18))
	box.add_child(UiStyle.label("Dinero: $%d" % GameState.money, 18, UiStyle.ACCENT))
	if GameState.has_pokedex():
		box.add_child(UiStyle.label("Pokédex: %d vistos · %d atrapados" % [GameState.pokedex_seen.size(),
			GameState.pokedex_caught.size()], 18))
	else:
		box.add_child(UiStyle.label("Pokédex: todavía no tenés", 18, UiStyle.TEXT_DIM))
	var got := BADGES.filter(func(b): return GameState.has_flag(b[0])).size()
	box.add_child(UiStyle.label("Medallas: %d / %d" % [got, BADGES.size()], 18))
	var case := BadgeCase.new()
	case.custom_minimum_size = Vector2(760, 230)
	box.add_child(case)
	var back := UiStyle.button("Volver", 160)
	back.pressed.connect(func(): closed.emit())
	box.add_child(back)
	UiStyle.focus_later(back)


## El estuche con las 8 medallas.
class BadgeCase:
	extends Control

	func _draw() -> void:
		var font := ThemeDB.fallback_font
		for i in TrainerCard.BADGES.size():
			var b: Array = TrainerCard.BADGES[i]
			var center := Vector2(48 + (i % 4) * 190, 60 + (i / 4) * 115)
			var has := GameState.has_flag(b[0])
			var col: Color = b[3] if has else Color(0.18, 0.2, 0.24)
			var pts := PackedVector2Array()
			var n: int = b[4]
			for k in n:
				pts.append(center + Vector2.from_angle(TAU * k / n - PI / 2.0) * 30.0)
			draw_colored_polygon(pts, col)
			pts.append(pts[0])
			draw_polyline(pts, col.lightened(0.35) if has else Color(1, 1, 1, 0.12), 2.0)
			if has:
				draw_circle(center + Vector2(-8, -8), 6.0, Color(1, 1, 1, 0.35))  # brillo
			draw_string(font, center + Vector2(40, -4), "Medalla %s" % b[1] if has else "???",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UiStyle.TEXT if has else UiStyle.TEXT_DIM)
			draw_string(font, center + Vector2(40, 16), b[2] if has else "", HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
				UiStyle.TEXT_DIM)
