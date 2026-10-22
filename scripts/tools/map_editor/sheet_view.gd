class_name MapSheetView
extends Control
## Paleta "como en la hoja": los metatiles en la misma disposición que la hoja de tiles del mundo de
## FireRed/LeafGreen (TileCatalog.sheet_*), con sus secciones marcadas. Clic = elegir el tile. Los filtros de
## la paleta atenúan lo que no coincide, sin mover nada.

signal tile_clicked(metatile: int)

const CELL := 16
const GAP := 1

var catalog: TileCatalog
var roles: TileRoleSet
## Predicado de los filtros (metatile -> bool); los que no pasan se dibujan atenuados.
var filter: Callable
var selected := -1
var _hover := Vector2i(-1, -1)


func setup(p_catalog: TileCatalog, p_roles: TileRoleSet) -> void:
	catalog = p_catalog
	roles = p_roles
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(catalog.sheet_size * (CELL + GAP)) if catalog != null else Vector2.ZERO


func cell_at(pos: Vector2) -> Vector2i:
	return Vector2i((pos / (CELL + GAP)).floor())


func metatile_at(c: Vector2i) -> int:
	if catalog == null or c.x < 0 or c.y < 0 or c.x >= catalog.sheet_size.x or c.y >= catalog.sheet_size.y:
		return -1
	return catalog.sheet_cells[c.y * catalog.sheet_size.x + c.x]


func section_at(c: Vector2i) -> Dictionary:
	for s in catalog.sheet_sections:
		if (s["rect"] as Rect2i).has_point(c):
			return s
	return {}


func _draw() -> void:
	if catalog == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.06, 0.08))
	var step := CELL + GAP
	for y in catalog.sheet_size.y:
		for x in catalog.sheet_size.x:
			var m := catalog.sheet_cells[y * catalog.sheet_size.x + x]
			if m < 0 or not ZoneBuilder.exists(m):
				continue
			var r := Rect2(Vector2(x, y) * step, Vector2(CELL, CELL))
			draw_texture_rect(MapIcons.metatile_full(m), r, false)
			if filter.is_valid() and not filter.call(m):
				draw_rect(r, Color(0.05, 0.06, 0.08, 0.78))
			if m == selected:
				draw_rect(r.grow(1), UiStyle.ACCENT, false, 2.0)
	for s in catalog.sheet_sections:
		var rr: Rect2i = s["rect"]
		draw_rect(Rect2(Vector2(rr.position) * step - Vector2(1, 1), Vector2(rr.size) * step + Vector2(1, 1)), Color(1, 1, 1, 0.18), false, 1.0)
	if metatile_at(_hover) >= 0:
		draw_rect(Rect2(Vector2(_hover) * step, Vector2(CELL, CELL)).grow(1), Color.WHITE, false, 1.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var c := cell_at((event as InputEventMouseMotion).position)
		if c != _hover:
			_hover = c
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var m := metatile_at(cell_at(event.position))
		if m >= 0:
			selected = m
			tile_clicked.emit(m)
			queue_redraw()
			accept_event()


func _get_tooltip(at_position: Vector2) -> String:
	var c := cell_at(at_position)
	var m := metatile_at(c)
	if m < 0:
		return ""
	var sec := section_at(c)
	return ("Sección: %s\n" % sec["name"] if not sec.is_empty() else "") + MapTilePalette.tooltip(roles, m)


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_hover = Vector2i(-1, -1)
		queue_redraw()
