class_name Minimap
extends Control
## Minimapa (Tab lo muestra o lo oculta; pedido del usuario 2026-11-03): arriba a la derecha, lo que te rodea en
## miniatura, girando con vos en el centro. Afuera = la imagen del Mapa del menú (`TownMap.image`, con niebla en lo no
## visitado e íconos de Centro / Tienda / Gimnasio); en un lugar que no está en el mapa (interiores, cuevas, la Torre)
## = ese lugar solo (`TownMap.zone_image`), más grande si es chico, con sus puertas y escaleras marcadas. Sin el
## minimapa en las arenas. Si está prendido se recuerda en PREFS_PATH.

const SIZE := Vector2(208, 208)
const MARGIN := 12.0
const PREFS_PATH := "user://interfaz.cfg"
const BG := Color(0.04, 0.05, 0.08, 0.82)
const BORDER := Color(0.85, 0.9, 1.0, 0.55)
const FOG := Color(0.05, 0.07, 0.1, 0.92)
const DOOR := Color(1.0, 0.85, 0.3)
const ICON_COLORS := {"C": Color(0.9, 0.3, 0.3), "T": Color(0.3, 0.55, 0.95), "G": Color(0.95, 0.75, 0.25)}

var world: Node
var shown := true
var _wd: WorldData
var _region: ImageTexture
var _zone_tex: Dictionary = {}  # id -> ImageTexture
var _icons: Array = []
var _zone: ZoneEntry
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	custom_minimum_size = SIZE
	size = SIZE
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	position = Vector2(get_viewport_rect().size.x - SIZE.x - MARGIN, MARGIN)
	var cfg := ConfigFile.new()
	if not CameraRig._automated() and cfg.load(PREFS_PATH) == OK:  # los tests y vitrinas no miran ni tocan tu archivo
		shown = bool(cfg.get_value("minimapa", "visible", true))
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("minimap") and not event.is_echo():
		shown = not shown
		get_viewport().set_input_as_handled()
		if CameraRig._automated():
			return
		var cfg := ConfigFile.new()
		cfg.load(PREFS_PATH)
		cfg.set_value("minimapa", "visible", shown)
		cfg.save(PREFS_PATH)


func _process(delta: float) -> void:
	_time += delta
	var t: Node2D = world.get("trainer") if world != null else null
	var arena_on: bool = world != null and world.get("arena") != null and world.arena.active
	visible = shown and t != null and not arena_on
	if not visible:
		return
	if _wd == null:
		_wd = world.streamer.world_data
	_zone = _wd.zone_at(t.global_position)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), BG)
	var t: Node2D = world.trainer
	var cell_f: Vector2 = t.global_position / float(_wd.tile_size)
	var center := SIZE / 2.0
	if _zone != null and not TownMap.on_map(_wd, _zone):
		_draw_place(cell_f, center)
	else:
		_draw_region(cell_f, center)
	# Vos: punto con la dirección en que mirás.
	var face: Vector2 = t.get("facing") if t.get("facing") != null else Vector2.DOWN
	var tip := center + face.normalized() * 9.0
	var side := face.orthogonal().normalized() * 4.0
	draw_colored_polygon(PackedVector2Array([tip, center + side, center - side]), Color(1, 1, 1, 0.9))
	var pulse := 0.5 + 0.5 * sin(_time * 6.0)
	draw_circle(center, 7.0 + pulse * 3.0, Color(1, 0.3, 0.3, 0.25 * (1.0 - pulse)))
	draw_circle(center, 5.0, Color.WHITE)
	draw_circle(center, 3.5, Color(0.9, 0.2, 0.25))
	# Nombre del lugar abajo.
	if _zone != null:
		var font := get_theme_default_font()
		var label := _zone.display_name
		var fs := 12
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var at := Vector2((SIZE.x - w) / 2.0, SIZE.y - 7.0)
		draw_string_outline(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0, 0, 0, 0.9))
		draw_string(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.92, 0.95, 1.0))
	draw_rect(Rect2(Vector2.ONE, SIZE - Vector2.ONE * 2.0), BORDER, false, 2.0)


## Afuera: la región, con vos en el centro.
func _draw_region(cell_f: Vector2, center: Vector2) -> void:
	if _region == null:
		_region = ImageTexture.create_from_image(TownMap.image(_wd))
		_icons = TownMap.icons(_wd)
	var px := float(TownMap.CELL_PX)
	var o := Vector2(TownMap.origin())
	var shift := center - (cell_f - o) * px
	draw_texture(_region, shift)
	var view := Rect2(Vector2.ZERO, SIZE)
	for z in TownMap.map_zones(_wd):
		if GameState.visited_zones.has(z.id):
			continue
		var r := Rect2(shift + (Vector2(z.origin) - o) * px, Vector2(z.size) * px)
		if r.intersects(view):
			draw_rect(r, FOG)
	var font := get_theme_default_font()
	for ic in _icons:
		var p: Vector2 = shift + (Vector2(ic["cell"]) - o + Vector2.ONE * 0.5) * px
		if not view.grow(8).has_point(p) or not GameState.visited_zones.has(TownMap.map_zone_at(_wd, ic["cell"])):
			continue
		draw_circle(p, 6.5, Color(0, 0, 0, 0.7))
		draw_circle(p, 5.5, ICON_COLORS[ic["letter"]])
		var w := font.get_string_size(ic["letter"], HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
		draw_string(font, p + Vector2(-w / 2.0, 3.2), ic["letter"], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)


## Un lugar fuera del mapa (interior, cueva): ese lugar solo, agrandado si es chico, con las puertas marcadas.
func _draw_place(cell_f: Vector2, center: Vector2) -> void:
	if not _zone_tex.has(_zone.id):
		_zone_tex[_zone.id] = ImageTexture.create_from_image(TownMap.zone_image(_zone))
	var tex: ImageTexture = _zone_tex[_zone.id]
	var px := float(TownMap.CELL_PX)
	var big := maxf(_zone.size.x, _zone.size.y) * px
	var k := clampf(SIZE.x * 0.85 / big, 1.0, 3.0)
	var local := cell_f - Vector2(_zone.origin)
	var shift := center - local * px * k
	draw_texture_rect(tex, Rect2(shift, Vector2(tex.get_size()) * k), false)
	var pulse := 0.6 + 0.4 * sin(_time * 4.0)
	for c: Vector2i in _zone.warps:
		var p := shift + (Vector2(c) + Vector2.ONE * 0.5) * px * k
		draw_circle(p, 2.0 + k, Color(0, 0, 0, 0.6))
		draw_circle(p, 1.2 + k, Color(DOOR, pulse))
