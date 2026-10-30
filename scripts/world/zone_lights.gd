class_name ZoneLights
extends Node2D
## Ventanas prendidas de noche (docs/PLAN_DIA_NOCHE.md parte C). World la agrega a cada zona exterior al cargarla.
## Qué píxeles de cada metatile son vidrio sale de data/world/night_windows.json (tools/find_windows.py, desde los
## mapas de FireRed: no hay que marcar nada a mano por zona). Al anochecer el vidrio se pinta de luz cálida y cada
## tira de ventanas tira un charco de luz en el suelo, delante del edificio (como verde_noche.png de
## docs/referencias/iluminacion/). De día, en interiores y en arenas no se ve.

const WINDOWS_PATH := "res://data/world/night_windows.json"
const Z := -6                                   # sobre el suelo y las sombras largas, debajo de los personajes
const Z_HIGH := 21                              # vidrio de las celdas que tapa Overhead (pisos altos): sobre los techos
const WARM := Color(1.0, 0.74, 0.34)            # el vidrio prendido (antes de la luz de luna)
const SPILL := Color(1.0, 0.74, 0.32)           # el charco de luz en el suelo
const GLASS_ALPHA := 1.0
const SPILL_ALPHA := 0.85
const ON_FROM := 0.30                           # oscuridad (DayNight.darkness) a la que empiezan a prenderse
const ON_FULL := 0.80

static var _windows: Dictionary = {}            # id global -> PackedInt32Array (16 filas de 16 bits)
static var _loaded := false
static var _spill_tex: Texture2D
static var _mt_cache: Dictionary = {}           # Vector3i(fuente, x, y) -> metatile

## Celdas con ventana: celda -> máscara; las que tapa la capa Overhead (pisos altos de los edificios); y tiras
## horizontales de ventanas (para los charcos).
var cells: Dictionary = {}
var high: Dictionary = {}
var strips: Array[Rect2i] = []
var _glass: Node2D
var _glass_high: Node2D
var _glow: Node2D
var _world: Node


static func windows() -> Dictionary:
	if not _loaded:
		_loaded = true
		var f := FileAccess.open(WINDOWS_PATH, FileAccess.READ)
		if f != null:
			var data = JSON.parse_string(f.get_as_text())
			if data is Dictionary:
				for k in data.get("windows", {}):
					_windows[int(k)] = PackedInt32Array(data["windows"][k])
	return _windows


## Metatile de una celda, con caché (ZoneBuilder.metatile_of rearma la lista de tilesets en cada llamada: sin caché,
## ubicar las luces de una zona tardaba segundos).
static func metatile_at(layer: TileMapLayer, cell: Vector2i) -> int:
	var src := layer.get_cell_source_id(cell)
	var at := layer.get_cell_atlas_coords(cell)
	var key := Vector3i(src, at.x, at.y)
	if not _mt_cache.has(key):
		_mt_cache[key] = ZoneBuilder.metatile_of(src, at)
	return _mt_cache[key]


static func attach(zone: Node2D, entry: ZoneEntry, _world_data: WorldData) -> ZoneLights:
	var old := zone.get_node_or_null("NightLights")
	if old != null:
		old.free()
	if entry.interior:
		return null
	var node := ZoneLights.new()
	node.name = "NightLights"
	node.z_index = Z
	node.scan(zone.get_node("Ground"), zone.get_node_or_null("Overhead"))
	if node.cells.is_empty():
		node.free()
		return null
	zone.add_child(node)
	return node


## Busca las celdas con vidrio (la misma celda tiene el mismo metatile en Ground y Overhead) y arma las tiras.
func scan(ground: TileMapLayer, overhead: TileMapLayer = null) -> void:
	var w := windows()
	for layer in [ground, overhead]:
		if layer == null:
			continue
		for cell in layer.get_used_cells():
			var mt := metatile_at(layer, cell)
			if w.has(mt):
				cells[cell] = w[mt]
	if overhead != null:
		for cell in cells:
			if overhead.get_cell_source_id(cell) >= 0:
				high[cell] = true
	var done := {}
	for cell in cells:
		if done.has(cell) or cells.has(cell + Vector2i.LEFT):
			continue
		var c: Vector2i = cell
		while cells.has(c):
			done[c] = true
			c += Vector2i.RIGHT
		strips.append(Rect2i(cell, Vector2i(c.x - cell.x, 1)))


func _ready() -> void:
	_world = get_tree().get_first_node_in_group("world")
	_glow = Node2D.new()
	_glow.name = "Glow"
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow.material = add
	_glow.draw.connect(_draw_glow)
	add_child(_glow)
	_glass = Node2D.new()
	_glass.name = "Glass"
	_glass.draw.connect(func(): _draw_glass(_glass, false))
	add_child(_glass)
	_glass_high = Node2D.new()
	_glass_high.name = "GlassHigh"
	_glass_high.z_as_relative = false
	_glass_high.z_index = Z_HIGH
	_glass_high.draw.connect(func(): _draw_glass(_glass_high, true))
	add_child(_glass_high)
	visible = false


func _process(_delta: float) -> void:
	var dn: DayNight = _world.get("day_night") if _world != null else null
	var k := 0.0
	if dn != null and dn.casts_shadows and not PaintedZone.covers(get_parent()):  # con skin, las ventanas ya vienen pintadas
		k = smoothstep(ON_FROM, ON_FULL, dn.darkness)
	visible = k > 0.01
	if not visible:
		return
	# El Daylight (CanvasModulate) multiplica todo: se compensa para que la luz quede cálida y no azul de luna.
	var day := Color.WHITE
	var daylight := _world.get_node_or_null("Daylight") as CanvasModulate
	if daylight != null:
		day = daylight.color
	var undo := Color(1.0 / maxf(day.r, 0.2), 1.0 / maxf(day.g, 0.2), 1.0 / maxf(day.b, 0.2))
	_glass.self_modulate = Color(undo.r, undo.g, undo.b, k * GLASS_ALPHA)
	_glass_high.self_modulate = _glass.self_modulate
	_glow.self_modulate = Color(undo.r, undo.g, undo.b, k * SPILL_ALPHA)


## El vidrio: cada fila de píxeles prendidos, en tiras (en `node`: las celdas bajas o las altas).
func _draw_glass(node: Node2D, upper: bool) -> void:
	var t := Zone.TILE
	for cell in cells:
		if high.has(cell) != upper:
			continue
		var rows: PackedInt32Array = cells[cell]
		var o := Vector2(cell * t)
		for y in rows.size():
			var bits := rows[y]
			var x := 0
			while x < t:
				if bits & (1 << x) == 0:
					x += 1
					continue
				var x0 := x
				while x < t and bits & (1 << x) != 0:
					x += 1
				node.draw_rect(Rect2(o + Vector2(x0, y), Vector2(x - x0, 1)), WARM)


## El charco de luz delante de cada tira de ventanas y un halo suave sobre el vidrio.
func _draw_glow() -> void:
	var t := float(Zone.TILE)
	var tex := spill_texture()
	for s in strips:
		if high.has(s.position):
			continue
		var r := Rect2(Vector2(s.position) * t, Vector2(s.size) * t)
		var halo := r.grow(t * 0.45)
		_glow.draw_texture_rect(tex, halo, false, Color(SPILL, 0.45))
		if _has_windows_below(s):
			continue
		var pool := Rect2(r.position.x - t * 0.8, r.end.y - t * 0.3, r.size.x + t * 1.6, t * 3.0)
		_glow.draw_texture_rect(tex, pool, false, SPILL)


## ¿Hay más ventanas en las 2 filas de abajo? (entonces no es la planta baja: el charco va solo bajo la última).
func _has_windows_below(s: Rect2i) -> bool:
	for dy in [1, 2]:
		for x in range(s.position.x, s.end.x):
			if cells.has(Vector2i(x, s.position.y + dy)):
				return true
	return false


static func spill_texture() -> Texture2D:
	if _spill_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.45, Color(1, 1, 1, 0.45))
		var tex := GradientTexture2D.new()
		tex.gradient = g
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(0.5, 0.0)
		tex.width = 64
		tex.height = 64
		_spill_tex = tex
	return _spill_tex
