class_name RoomPieces
extends RefCounted
## "Salas por piezas" del Modo Desafío (sección 10 de docs/PROPUESTA_ROGUELIKE.md; P-0, bioma de muestra: Costa). Una
## sala por piezas es un fondo (el marco del bioma: piso + paredes, pixel art a la resolución del juego) más objetos
## sueltos colocados encima:
##  · **sólidas** (roca, palmera, bote...): sprite con el origen en los pies dentro del y-sort del mundo (se pasa por
##    detrás) y colisión con la forma de su base (una elipse), no con celdas enteras;
##  · **zonas** (charco, laguna): dibujo acostado en el piso; el agua de verdad la ponen las celdas de la zona, que arma
##    tools/paint_arenas.py desde la misma lista de piezas;
##  · **decorado** (conchas, estrellas): dibujo en el piso, sin colisión.
## La grilla sigue debajo: las celdas que tapa la base de una pieza sólida quedan marcadas en la zona
## (`ExtraContent.SOLID_META`), así MapRules, los caminos de la IA y los puntos de aparición las ven.
## Datos: catálogo `data/rogue/piezas/<bioma>.json` (de tools/make_room_pieces.py) y la lista de cada sala en
## `data/rogue/salas/<id de la arena>.json` = {"biome", "pieces": [[pieza, x, y, espejada], ...]} (x, y = px de los pies
## desde la esquina de la sala).

const CATALOG := "res://data/rogue/piezas/%s.json"
const ROOM := "res://data/rogue/salas/%s.json"
## Capa de colisión "mundo" (frena a personas, Pokémon y disparos, como una pared).
const WORLD_LAYER := 1


static func has_room(arena_id: String) -> bool:
	return FileAccess.file_exists(ROOM % arena_id)


static func load_room(arena_id: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(ROOM % arena_id)) if has_room(arena_id) else {}


static func load_catalog(biome: String) -> Dictionary:
	var path := CATALOG % biome
	return JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else {}


## Coloca las piezas de esa sala (si es una sala por piezas): los nodos van a `parent` (el y-sort de las entidades),
## en coordenadas del mundo, y las celdas de las bases sólidas quedan marcadas en la zona. Devuelve los nodos creados
## (el que carga la sala los libera con ella).
static func populate(parent: Node, zone: Zone, arena_id: String) -> Array[Node2D]:
	var out: Array[Node2D] = []
	var room := load_room(arena_id)
	if room.is_empty():
		return out
	var catalog := load_catalog(str(room["biome"]))
	var solid: Dictionary = zone.get_meta(ExtraContent.SOLID_META) if zone.has_meta(ExtraContent.SOLID_META) else {}
	for entry: Array in room["pieces"]:
		var def: Dictionary = catalog.get(str(entry[0]), {})
		if def.is_empty():
			continue
		var at := Vector2(float(entry[1]), float(entry[2]))
		var node := make(str(room["biome"]), str(entry[0]), def, entry.size() > 3 and bool(entry[3]))
		node.position = zone.global_position + at
		parent.add_child(node)
		out.append(node)
		if str(def["kind"]) == "solida":
			for cell in base_cells(def, at):
				solid[cell] = true
	zone.set_meta(ExtraContent.SOLID_META, solid)
	return out


## El nodo de una pieza: sólida = cuerpo con su colisión y el sprite parado sobre el origen; zona y decorado = solo el
## dibujo, acostado en el piso (debajo de todos).
static func make(biome: String, id: String, def: Dictionary, flipped := false) -> Node2D:
	var tex: Texture2D = load("res://sprites/rogue/piezas/%s/%s.png" % [biome, id])
	var spr := Sprite2D.new()
	spr.name = "Sprite"
	spr.texture = tex
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.flip_h = flipped
	var kind := str(def["kind"])
	if kind != "solida":
		var flat := Node2D.new()
		flat.name = id
		flat.z_index = -6 if kind == "zona" else -5  # sobre la pintura del piso (-7), debajo de personas y Pokémon
		flat.add_child(spr)  # (centrado en su punto)
		if kind == "zona":
			spr.material = water_material(biome)  # el agua de la poza se mueve
		flat.set_meta("piece", id)
		return flat
	var body := StaticBody2D.new()
	body.name = id
	body.collision_layer = WORLD_LAYER
	body.collision_mask = 0
	body.set_meta("piece", id)
	var base: Array = def["base"]
	# El sprite parado: sus pies (el centro de la base) en el origen del nodo.
	spr.centered = false
	var foot := float(def.get("foot", 0.0)) * (-1.0 if flipped else 1.0)  # (dónde pisa el dibujo, respecto de su centro)
	spr.position = Vector2(-tex.get_width() / 2.0 - foot, -tex.get_height() + float(base[1]) / 2.0 + float(def.get("sink", 0.0)))
	body.add_child(spr)
	var shape := CollisionPolygon2D.new()
	shape.polygon = ellipse(float(base[0]) / 2.0, float(base[1]) / 2.0)
	body.add_child(shape)
	return body


## El material del agua en movimiento (shaders/pixel_water.gdshader): ondulación, brillos y espuma en pixel art.
## `WATER_STRENGTH` = cuánto se mueve (0 = quieta).
const WATER_SHADER := "res://shaders/pixel_water.gdshader"
const WATER_STRENGTH := 1.0


## Cómo se mueve el líquido de cada bioma: [fuerza, pasos por segundo, brillo, ¿lava?]. Sin fila = quieto (el hielo).
const LIQUIDS := {
	"costa": [1.0, 7.0, 0.14, false],
	"bosque": [0.7, 6.0, 0.10, false],
	"cueva": [0.6, 5.0, 0.12, false],
	"volcan": [0.9, 4.0, 0.22, true],
}


## El material del líquido de ese bioma, o null si ahí no se mueve nada.
static func water_material(biome: String = "costa") -> ShaderMaterial:
	if not LIQUIDS.has(biome):
		return null
	var k: Array = LIQUIDS[biome]
	var m := ShaderMaterial.new()
	m.shader = load(WATER_SHADER)
	m.set_shader_parameter("strength", float(k[0]) * WATER_STRENGTH)
	m.set_shader_parameter("fps", float(k[1]))
	m.set_shader_parameter("glow", float(k[2]))
	m.set_shader_parameter("lava", bool(k[3]))
	return m


static func ellipse(rx: float, ry: float, points := 12) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in points:
		var a := TAU * float(i) / float(points)
		out.append(Vector2(cos(a) * rx, sin(a) * ry))
	return out


## Las celdas que tapa la base de una pieza sólida puesta en `at` (px de la sala): aquellas cuyo centro cae en la elipse.
static func base_cells(def: Dictionary, at: Vector2) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var rx := maxf(float(def["base"][0]) / 2.0, 1.0)
	var ry := maxf(float(def["base"][1]) / 2.0, 1.0)
	var t := float(Zone.TILE)
	for cy in range(floori((at.y - ry) / t), floori((at.y + ry) / t) + 1):
		for cx in range(floori((at.x - rx) / t), floori((at.x + rx) / t) + 1):
			var c := Vector2((cx + 0.5) * t, (cy + 0.5) * t) - at
			if (c.x * c.x) / (rx * rx) + (c.y * c.y) / (ry * ry) <= 1.0:
				out.append(Vector2i(cx, cy))
	if out.is_empty():  # (base más chica que una celda: la celda en la que está parada)
		out.append(Vector2i(floori(at.x / t), floori(at.y / t)))
	return out
