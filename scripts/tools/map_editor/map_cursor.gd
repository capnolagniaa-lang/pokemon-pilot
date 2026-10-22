class_name MapCursor
extends Node2D
## Superposición "viva" del editor de mapas (se redibuja con el mouse): celda bajo el cursor y huella del
## pincel, vista previa de línea/rectángulo, selección, pegado, y los marcadores de plaza (hub), salidas
## e inicio del juego.

const T := ZoneBuilder.T
const HUB_COLOR := Color(1.0, 0.82, 0.3)
const EXIT_COLOR := Color(0.35, 0.95, 0.45)
const SPAWN_COLOR := Color(0.3, 0.9, 1.0)
const ARROWS := {"up": "▲", "down": "▼", "left": "◀", "right": "▶"}

var doc: MapDocument
var hover := Vector2i(-1, -1)
var hover_inside := false
## Celdas de la huella o vista previa.
var preview: Array[Vector2i] = []
var preview_color := Color(1, 1, 1, 0.35)
var selection := Rect2i()
var paste_rect := Rect2i()
var show_markers := true
var show_spawn := true
## Marcador que se está arrastrando ("hub" o un lado) y dónde va.
var dragging := ""
var drag_cell := Vector2i.ZERO
var font: Font


func _ready() -> void:
	font = ThemeDB.fallback_font


func _draw() -> void:
	if doc == null:
		return
	for c in preview:
		draw_rect(Rect2(Vector2(c * T), Vector2(T, T)), preview_color)
	if hover_inside:
		draw_rect(Rect2(Vector2(hover * T), Vector2(T, T)), Color(1, 1, 1, 0.9), false, 1.0)
	if selection.size != Vector2i.ZERO:
		_dashed(Rect2(Vector2(selection.position * T), Vector2(selection.size * T)), Color(0.4, 0.85, 1.0))
	if paste_rect.size != Vector2i.ZERO:
		draw_rect(Rect2(Vector2(paste_rect.position * T), Vector2(paste_rect.size * T)), Color(0.4, 0.85, 1.0, 0.25))
		_dashed(Rect2(Vector2(paste_rect.position * T), Vector2(paste_rect.size * T)), Color(0.4, 0.85, 1.0))
	if show_markers:
		var hub := drag_cell if dragging == "hub" else doc.entry.hub
		_marker(hub, Vector2i(2, 2), HUB_COLOR, "H")
		for side in doc.entry.exits:
			var c: Vector2i = drag_cell if dragging == side else doc.entry.exits[side]
			_marker(c, Vector2i(2, 2), EXIT_COLOR, ARROWS.get(side, "?"))
	if show_spawn:
		var s := doc.world.spawn_cell - doc.entry.origin
		if doc.inside(s):
			var center := Vector2(s * T) + Vector2(T, T) / 2.0
			draw_circle(center, 6.0, Color(SPAWN_COLOR, 0.35))
			draw_arc(center, 6.0, 0, TAU, 20, SPAWN_COLOR, 1.5)
			draw_string(font, center + Vector2(-3, 4), "S", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, SPAWN_COLOR)


func _marker(cell: Vector2i, size: Vector2i, color: Color, text: String) -> void:
	var r := Rect2(Vector2(cell * T), Vector2(size * T))
	draw_rect(r, Color(color, 0.22))
	draw_rect(r, color, false, 2.0)
	draw_string(font, r.get_center() + Vector2(-4, 5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)


func _dashed(r: Rect2, color: Color) -> void:
	var pts := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y), r.position]
	for i in 4:
		draw_dashed_line(pts[i], pts[i + 1], color, 1.5, 4.0)


## Marcador (hub o lado de salida) bajo una celda, o "".
func marker_at(cell: Vector2i) -> String:
	for side in doc.entry.exits:
		if Rect2i(doc.entry.exits[side], Vector2i(2, 2)).has_point(cell):
			return side
	if Rect2i(doc.entry.hub, Vector2i(2, 2)).has_point(cell):
		return "hub"
	return ""
