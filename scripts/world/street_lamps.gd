class_name StreetLamps
extends Node2D
## Faroles al costado de los caminos de ciudades y rutas (pedido del usuario 2026-10-28: "faroles también en caminos").
## World la agrega a cada zona exterior al cargarla. No se marca nada a mano: van en las celdas de suelo pegadas a un
## camino ("paths" de data/world/night_windows.json: tools/find_windows.py los saca por color de los mapas de FireRed), con lugar libre arriba (el poste mide 2,5 celdas), lejos de las
## puertas, separados por SPACING celdas (más en las rutas), en un orden fijo por zona. Son decorado: no chocan.
## De día son un poste; al anochecer se prende la luz (PointLight2D cálida, según DayNight.darkness).

const TEX_PATH := "res://sprites/props/poste.png"
const Z := -5
const SPACING_CITY := 10
const SPACING_ROUTE := 15
const NO_LAMPS := ["bosque", "cueva", "interior"]  # biomas sin faroles
const COLOR := Color(1.0, 0.72, 0.36)
const ENERGY := 0.62                # de noche (el suelo ya está oscuro; de día está apagado)
const GLASS_ENERGY := 1.6           # el brillo chico del vidrio
const RADIUS := 3.5                 # celdas que alumbra
const ON_FROM := 0.30
const ON_FULL := 0.80

static var _paths: Dictionary = {}
static var _loaded := false

## Celdas donde quedó un farol.
var spots: Array[Vector2i] = []
var _lights: Array[PointLight2D] = []
var _world: Node


static func attach(zone: Node2D, entry: ZoneEntry, _world_data: WorldData) -> StreetLamps:
	var old := zone.get_node_or_null("StreetLamps")
	if old != null:
		old.free()
	if entry.interior or entry.biome in NO_LAMPS or not ResourceLoader.exists(TEX_PATH):
		return null
	var node := StreetLamps.new()
	node.name = "StreetLamps"
	node.z_index = Z
	node.place(zone, entry)
	if node.spots.is_empty():
		node.free()
		return null
	zone.add_child(node)
	return node


## Metatiles de camino (id global -> true).
static func path_tiles() -> Dictionary:
	if not _loaded:
		_loaded = true
		var f := FileAccess.open(ZoneLights.WINDOWS_PATH, FileAccess.READ)
		if f != null:
			var data = JSON.parse_string(f.get_as_text())
			if data is Dictionary:
				for id in data.get("paths", []):
					_paths[int(id)] = true
	return _paths


## Elige dónde van los faroles y los arma.
func place(zone: Node2D, entry: ZoneEntry) -> void:
	var paths := path_tiles()
	var ground: TileMapLayer = zone.get_node("Ground")
	var objects := MapRules.objects_by_cell(zone)
	var foliage: TileMapLayer = zone.get_node("Foliage")
	var path := {}
	for cell in ground.get_used_cells():
		var mt := ZoneLights.metatile_at(ground, cell)
		if paths.has(mt):
			path[cell] = true
	if path.is_empty():
		return
	var doors: Array = entry.warps.keys()
	var candidates: Array[Vector2i] = []
	for y in range(3, entry.size.y - 1):
		for x in range(1, entry.size.x - 1):
			var c := Vector2i(x, y)
			if path.has(c) or not _side_of_path(c, path):
				continue
			if not _free(zone, c, objects) or not _free(zone, c + Vector2i.UP, objects) \
					or not _free(zone, c + Vector2i.UP * 2, objects):
				continue
			# Pasto alto = algo en Foliage. (Zone.get_tags no: leer los tags tarda ~10 ms por celda.)
			if foliage.get_cell_source_id(c) >= 0 or _near_door(c, doors):
				continue
			candidates.append(c)
	var keyed := {}
	for c in candidates:
		keyed[c] = _hash(c, entry.id)
	candidates.sort_custom(func(a: Vector2i, b: Vector2i): return keyed[a] < keyed[b])
	var spacing := SPACING_CITY if entry.biome == "ciudad" else SPACING_ROUTE
	for c in candidates:
		var ok := true
		for s in spots:
			var d := s - c
			if maxi(absi(d.x), absi(d.y)) < spacing:
				ok = false
				break
		if ok:
			spots.append(c)
	var tex: Texture2D = load(TEX_PATH)
	for c in spots:
		_build(c, tex)


static func _side_of_path(c: Vector2i, path: Dictionary) -> bool:
	return path.has(c + Vector2i.LEFT) or path.has(c + Vector2i.RIGHT) or path.has(c + Vector2i.DOWN) \
		or path.has(c + Vector2i.UP)


static func _free(zone: Node2D, c: Vector2i, objects: Dictionary) -> bool:
	return MapRules.cell_physics(zone, c, objects) < 0  # el agua tiene su colisión: queda afuera


static func _near_door(c: Vector2i, doors: Array) -> bool:
	for d in doors:
		var v: Vector2i = d
		if absi(v.x - c.x) <= 2 and absi(v.y - c.y) <= 3:
			return true
	return false


static func _hash(c: Vector2i, salt: String) -> int:
	return absi(hash("%s:farol:%d:%d" % [salt, c.x, c.y]))


func _build(cell: Vector2i, tex: Texture2D) -> void:
	var t := float(Zone.TILE)
	var foot := Vector2(cell.x * t + t / 2.0, (cell.y + 1) * t - 2.0)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	sprite.position = foot - Vector2(tex.get_width() / 2.0, tex.get_height())
	add_child(sprite)
	var light := PointLight2D.new()
	light.texture = CaveLights.light_texture()
	light.color = COLOR
	light.energy = 0.0
	light.texture_scale = RADIUS * 2.0 * t / light.texture.get_width()
	light.position = foot - Vector2(0, tex.get_height() * 0.55)
	light.visible = false
	add_child(light)
	_lights.append(light)
	# El vidrio del farol: una luz chiquita y fuerte justo en la cabeza.
	var glass := PointLight2D.new()
	glass.texture = light.texture
	glass.color = COLOR
	glass.texture_scale = 14.0 / light.texture.get_width()
	glass.position = foot - Vector2(0, tex.get_height() * 0.80)
	glass.set_meta("glass", true)
	glass.visible = false
	add_child(glass)
	_lights.append(glass)


func _ready() -> void:
	_world = get_tree().get_first_node_in_group("world")


func _process(_delta: float) -> void:
	var dn: DayNight = _world.get("day_night") if _world != null else null
	var k := 0.0
	if dn != null and dn.casts_shadows:
		k = smoothstep(ON_FROM, ON_FULL, dn.darkness)
	for l in _lights:
		l.visible = k > 0.01
		l.energy = (GLASS_ENERGY if l.has_meta("glass") else ENERGY) * k
