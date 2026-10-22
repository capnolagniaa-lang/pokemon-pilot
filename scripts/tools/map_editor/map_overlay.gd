class_name MapOverlay
extends Node2D
## Superposiciones "fijas" del lienzo del editor de mapas (se redibujan solo cuando cambia la zona o un
## toggle): zonas vecinas atenuadas, borde de la zona, grilla, colisión (sólido rojo / agua azul), un tag
## resaltado y celdas sin tags. Coordenadas locales de la zona abierta.

const T := ZoneBuilder.T
const SOLID_COLOR := Color(1.0, 0.1, 0.1, 0.45)
const WATER_COLOR := Color(0.2, 0.45, 1.0, 0.42)
const TAG_COLOR := Color(1.0, 0.85, 0.2, 0.45)
const UNTAGGED_COLOR := Color(1.0, 0.2, 0.9, 0.35)

var doc: MapDocument
var show_grid := true
var show_collision := false
var show_untagged := false
var show_neighbors := true
## Tag resaltado ("" = ninguno).
var tag := ""


func _draw() -> void:
	if doc == null:
		return
	var size := Vector2(doc.entry.size * T)
	# Afuera de la zona: oscurecido (las vecinas se ven atenuadas para empalmar caminos y agua).
	var far := 4000.0
	var shade := Color(0.02, 0.03, 0.05, 0.5 if show_neighbors else 1.0)
	draw_rect(Rect2(-far, -far, far * 2 + size.x, far), shade)
	draw_rect(Rect2(-far, size.y, far * 2 + size.x, far), shade)
	draw_rect(Rect2(-far, 0, far, size.y), shade)
	draw_rect(Rect2(size.x, 0, far, size.y), shade)
	var objects := MapRules.objects_by_cell(doc.zone)
	if show_collision or show_untagged or tag != "":
		for y in doc.entry.size.y:
			for x in doc.entry.size.x:
				var c := Vector2i(x, y)
				var r := Rect2(Vector2(c * T), Vector2(T, T))
				if show_collision:
					var p := MapRules.cell_physics(doc.zone, c, objects)
					if p == MapRules.SOLID:
						draw_rect(r, SOLID_COLOR)
						draw_rect(r.grow(-1), Color(SOLID_COLOR, 0.9), false, 1.0)
					elif p == MapRules.WATER:
						draw_rect(r, WATER_COLOR)
						draw_rect(r.grow(-1), Color(WATER_COLOR, 0.9), false, 1.0)
				if tag != "" or show_untagged:
					var tags := _tags(c, objects)
					if tag != "" and tags.has(tag):
						draw_rect(r.grow(-2), TAG_COLOR)
					if show_untagged and tags.is_empty():
						draw_rect(r.grow(-5), UNTAGGED_COLOR)
	if show_grid:
		var line := Color(0, 0, 0, 0.18)
		for x in doc.entry.size.x + 1:
			draw_line(Vector2(x * T, 0), Vector2(x * T, size.y), line, -1.0)
		for y in doc.entry.size.y + 1:
			draw_line(Vector2(0, y * T), Vector2(size.x, y * T), line, -1.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.55), false, 2.0)


## Tags de la celda (tiles + objeto), como los ve el juego.
func _tags(c: Vector2i, objects: Dictionary) -> PackedStringArray:
	var tags := doc.zone.get_tags(c)
	if objects.has(c) and objects[c] is EnvObject:
		tags.append_array((objects[c] as EnvObject).tags)
	return tags
