class_name CaveLights
extends Node2D
## Antorchas y cristales que alumbran las cuevas (pedido del usuario 2026-10-28: "las cuevas deberían sentirse frías y
## oscuras, pero que haya objetos que den luz"). World la agrega a cada zona de bioma "cueva" al cargarla; DayNight
## pinta esas zonas oscuras y frías (CAVE). No se marca nada a mano: se ubican solas sobre las paredes que dan al
## suelo (la celda sólida con suelo justo abajo), separadas por SPACING celdas, en un orden fijo por zona (siempre en
## el mismo lugar). Son decorado: no chocan. Antorcha = luz cálida que titila; cristales = luz fría y quieta.

const SPACING := 9                      # celdas mínimas entre dos luces
const Z := -5                           # sobre el suelo y la pared, debajo de los personajes
const TORCH_PATH := "res://sprites/props/antorcha.png"
const CRYSTAL_PATH := "res://sprites/props/cristales.png"
const TORCH_COLOR := Color(1.0, 0.50, 0.16)
const CRYSTAL_COLOR := Color(0.45, 0.80, 1.0)
const TORCH_ENERGY := 0.62
const CRYSTAL_ENERGY := 0.42
const RADIUS := 5.0                     # celdas que alumbra (aprox.)
## Qué pone cada cueva (por prefijo del id): solo cristales (hielo), solo antorchas (velas de la Torre, la Mansión)
## o mezcla (el resto: 1 de cada 3, cristales).
const ONLY_CRYSTALS := ["islas_espuma"]
const ONLY_TORCHES := ["torre_pokemon", "mansion_pokemon", "central_electrica"]

static var _light_tex: Texture2D

## Las luces puestas: [celda de la pared, "antorcha" o "cristales"].
var spots: Array = []
var _lights: Array[PointLight2D] = []
var _t := 0.0


static func attach(zone: Node2D, entry: ZoneEntry, _world_data: WorldData) -> CaveLights:
	var old := zone.get_node_or_null("CaveLights")
	if old != null:
		old.free()
	if entry.biome != "cueva":
		return null
	var node := CaveLights.new()
	node.name = "CaveLights"
	node.z_index = Z
	node.place(zone, entry)
	zone.add_child(node)
	return node


## Elige dónde van las luces y las arma.
func place(zone: Node2D, entry: ZoneEntry) -> void:
	var objects := MapRules.objects_by_cell(zone)
	var walls: Array[Vector2i] = []
	for y in range(1, entry.size.y - 1):
		for x in range(1, entry.size.x - 1):
			var c := Vector2i(x, y)
			if MapRules.cell_physics(zone, c, objects) == MapRules.SOLID \
					and MapRules.cell_physics(zone, c + Vector2i.DOWN, objects) < 0 \
					and MapRules.cell_physics(zone, c + Vector2i.DOWN * 2, objects) < 0:
				walls.append(c)
	# Orden fijo pero salteado (si no, todas quedan pegadas al borde de arriba).
	walls.sort_custom(func(a: Vector2i, b: Vector2i): return _hash(a, entry.id) < _hash(b, entry.id))
	for c in walls:
		var free := true
		for s in spots:
			var d: Vector2i = (s[0] as Vector2i) - c
			if maxi(absi(d.x), absi(d.y)) < SPACING:
				free = false
				break
		if free:
			spots.append([c, _kind(c, entry.id)])
	for s in spots:
		_build(s[0], s[1])


func _kind(c: Vector2i, zone_id: String) -> String:
	for p in ONLY_CRYSTALS:
		if zone_id.begins_with(p):
			return "cristales"
	for p in ONLY_TORCHES:
		if zone_id.begins_with(p):
			return "antorcha"
	return "cristales" if _hash(c, zone_id + "k") % 3 == 0 else "antorcha"


static func _hash(c: Vector2i, salt: String) -> int:
	return absi(hash("%s:%d:%d" % [salt, c.x, c.y]))


func _build(cell: Vector2i, kind: String) -> void:
	var t := float(Zone.TILE)
	var torch := kind == "antorcha"
	var path := TORCH_PATH if torch else CRYSTAL_PATH
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	if tex == null:  # sin el dibujo: solo la luz, al pie de la pared
		tex = PlaceholderTexture2D.new()
		(tex as PlaceholderTexture2D).size = Vector2(1, 16)
	# Al pie de la pared, centrada en la celda.
	var foot := Vector2(cell.x * t + t / 2.0, (cell.y + 1) * t)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	sprite.position = foot - Vector2(tex.get_width() / 2.0, tex.get_height())
	sprite.name = kind.capitalize()
	add_child(sprite)
	var light := PointLight2D.new()
	light.texture = light_texture()
	light.color = TORCH_COLOR if torch else CRYSTAL_COLOR
	light.energy = TORCH_ENERGY if torch else CRYSTAL_ENERGY
	light.texture_scale = RADIUS * 2.0 * t / light.texture.get_width()
	light.position = foot - Vector2(0, tex.get_height() * (0.75 if torch else 0.4))
	light.set_meta("base", light.energy)
	light.set_meta("torch", torch)
	light.set_meta("phase", float(_hash(cell, "f") % 1000) / 100.0)
	add_child(light)
	_lights.append(light)


func _process(delta: float) -> void:
	_t += delta
	for l in _lights:
		if not l.get_meta("torch"):
			continue
		var ph: float = l.get_meta("phase")
		var f := 0.88 + 0.08 * sin(_t * 9.0 + ph) + 0.05 * sin(_t * 23.0 + ph * 2.0)
		l.energy = float(l.get_meta("base")) * f


static func light_texture() -> Texture2D:
	if _light_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.35, Color(1, 1, 1, 0.55))
		var tex := GradientTexture2D.new()
		tex.gradient = g
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(0.5, 0.0)
		tex.width = 128
		tex.height = 128
		_light_tex = tex
	return _light_tex
