class_name TownMap
extends RefCounted
## Mapa del menú (Esc → Mapa; pedido del usuario 2026-10-25): la región dibujada en miniatura **desde los mapas
## reales** (las capas de tiles de cada zona, `CELL_PX` píxeles por celda), así siempre coincide con el mundo aunque se
## sumen zonas. La imagen se arma la primera vez que se abre el mapa y queda en caché.
## Acá también está la geometría que usa la pantalla (`TownMapScreen`): qué zonas van en el mapa, dónde quedan las
## que no (interiores, cuevas, el Bosque Verde: en su puerta de entrada), nombres, íconos y tu posición.
##
## "En el mapa" = zona exterior que está en la región de arriba. Los interiores y las zonas que están lejos, debajo
## del mundo (a partir de la fila del primer interior: el Bosque Verde), se ubican en la puerta por la que se entra.

## Píxeles de la imagen por celda del mundo (un tile de 16 px se reduce a 4×4).
const CELL_PX := 4
## Capas de la zona que se dibujan, de abajo hacia arriba.
const LAYERS := ["Ground", "Water", "Foliage", "Overhead"]
## Lugares que no están en el mapa pero merecen nombre (cuevas, el bosque, el barco): los de al menos esta área.
const BIG_PLACE := 1200
## Íconos de los interiores: final del id -> letra.
const ICONS := {"_centro": "C", "_tienda": "T", "_gimnasio": "G"}
## Partidas guardadas antes del mapa (sin "visited_zones"): qué zonas se dan por visitadas según la historia.
## [bandera, zonas]. Sin historia (modo libre) se da todo por visitado.
const VISITED_BY_FLAG := [
	["historia", ["pueblo_paleta"]],
	["oak_te_freno", ["ruta1"]],
	["tiene_paquete", ["ciudad_verde"]],
	["rival_ruta22_peleado", ["ruta22"]],
	["tutorial_captura", ["ruta2"]],
	["medalla_roca", ["ruta2", "bosque_verde", "ciudad_plateada"]],
	["fosil_elegido", ["ruta3", "mt_moon"]],
	["rival_celeste_peleado", ["ruta4", "ciudad_celeste"]],
	["rocket_puente_peleado", ["ruta24"]],
	["ticket_barco_recibido", ["ruta24", "ruta25"]],
	["rival_ss_anne_peleado", ["ruta5", "ruta6", "ciudad_carmin", "ss_anne_muelle"]],
]

static var _image: Image
## Celda del mundo que corresponde al píxel (0, 0) de la imagen.
static var _origin := Vector2i.ZERO
static var _mini: Dictionary = {}  # "fuente:x,y" -> Image de CELL_PX×CELL_PX
static var _atlas_images: Dictionary = {}  # fuente -> Image del atlas


# --- Geometría -------------------------------------------------------------------------

## Las zonas que se dibujan en el mapa.
static func map_zones(wd: WorldData) -> Array[ZoneEntry]:
	var limit := _detached_row(wd)
	var out: Array[ZoneEntry] = []
	for z in wd.zones:
		if not z.interior and z.origin.y < limit:
			out.append(z)
	return out


static func on_map(wd: WorldData, z: ZoneEntry) -> bool:
	return z != null and not z.interior and z.origin.y < _detached_row(wd)


## Fila (en celdas) desde la que empiezan las zonas "lejos, debajo del mundo": la del primer interior.
static func _detached_row(wd: WorldData) -> int:
	var row := 1 << 30
	for z in wd.zones:
		if z.interior:
			row = mini(row, z.origin.y)
	return row


## Rectángulo (en celdas del mundo) que cubre las zonas del mapa.
static func bounds(wd: WorldData) -> Rect2i:
	var r := Rect2i()
	var first := true
	for z in map_zones(wd):
		var zr := Rect2i(z.origin, z.size)
		r = zr if first else r.merge(zr)
		first = false
	return r


## Dónde cae en el mapa cada zona que no está en él: id -> celda del mundo de la puerta por la que se entra desde el
## mapa (siguiendo las puertas: la garita lleva al bosque, el Mt. Moon al sótano...).
static func entrances(wd: WorldData) -> Dictionary:
	var by_id := {}
	for z in wd.zones:
		by_id[z.id] = z
	var out := {}
	var queue: Array[ZoneEntry] = []
	for z in map_zones(wd):
		for cell in z.warps:
			var to: String = z.warps[cell].get("to", "")
			if by_id.has(to) and not on_map(wd, by_id[to]) and not out.has(to):
				out[to] = z.origin + Vector2i(cell)
				queue.append(by_id[to])
	while not queue.is_empty():
		var z: ZoneEntry = queue.pop_front()
		for cell in z.warps:
			var to: String = z.warps[cell].get("to", "")
			if by_id.has(to) and not on_map(wd, by_id[to]) and not out.has(to):
				out[to] = out[z.id]
				queue.append(by_id[to])
	return out


## Celda del mundo (en el mapa) de un punto cualquiera: en una zona del mapa, la celda misma; en otra, su entrada.
## Vector2i(-1, -1) si no se puede ubicar.
static func map_cell(wd: WorldData, world_pos: Vector2, ents: Dictionary = {}) -> Vector2i:
	var z := wd.zone_at(world_pos)
	if z == null:
		return Vector2i(-1, -1)
	if on_map(wd, z):
		return Vector2i((world_pos / wd.tile_size).floor())
	if ents.is_empty():
		ents = entrances(wd)
	return ents.get(z.id, Vector2i(-1, -1))


## Celda del mundo que representa una zona en el mapa (su centro, o su entrada si no está en el mapa).
static func zone_cell(wd: WorldData, zone_id: String, ents: Dictionary = {}) -> Vector2i:
	for z in wd.zones:
		if z.id == zone_id:
			if on_map(wd, z):
				return z.origin + z.size / 2
			if ents.is_empty():
				ents = entrances(wd)
			return ents.get(zone_id, Vector2i(-1, -1))
	return Vector2i(-1, -1)


## Lugares con nombre fuera del mapa (Bosque Verde, Mt. Moon, el muelle del S.S. Anne): [{name, cell, zone}].
## Uno por nombre (sin lo que va entre paréntesis), en la entrada desde el mapa.
static func places(wd: WorldData, ents: Dictionary = {}) -> Array:
	if ents.is_empty():
		ents = entrances(wd)
	var out := []
	var seen := {}
	for z in wd.zones:
		if on_map(wd, z) or not ents.has(z.id) or z.size.x * z.size.y < BIG_PLACE:
			continue
		var name := z.display_name.get_slice(" (", 0)
		if seen.has(name):
			continue
		seen[name] = true
		out.append({"name": name, "cell": ents[z.id], "zone": z.id})
	return out


## Íconos de Centro, Tienda y Gimnasio: [{letter, cell, zone, name}] en la puerta de cada uno.
static func icons(wd: WorldData, ents: Dictionary = {}) -> Array:
	if ents.is_empty():
		ents = entrances(wd)
	var out := []
	for z in wd.zones:
		if not ents.has(z.id):
			continue
		for suffix in ICONS:
			if z.id.ends_with(suffix):
				out.append({"letter": ICONS[suffix], "cell": ents[z.id], "zone": z.id, "name": z.display_name})
	return out


## Zona del mapa que contiene una celda del mundo ("" si ninguna).
static func map_zone_at(wd: WorldData, cell: Vector2i) -> String:
	for z in map_zones(wd):
		if Rect2i(z.origin, z.size).has_point(cell):
			return z.id
	return ""


## Zonas visitadas para una partida vieja (sin "visited_zones"), según sus banderas de historia.
static func visited_from_progress(flags: Dictionary, wd: WorldData) -> Dictionary:
	var out := {}
	if not flags.has("historia"):
		for z in wd.zones:
			out[z.id] = true  # modo libre: todo a la vista
		return out
	for row in VISITED_BY_FLAG:
		if flags.has(row[0]):
			for id in row[1]:
				out[id] = true
	return out


# --- Imagen ----------------------------------------------------------------------------

## La imagen (la arma la primera vez: ~0,5 s, en el hilo principal: cargar escenas desde otro hilo puede trabar el
## juego al cerrar). Píxel = (celda - origin()) * CELL_PX.
static func image(wd: WorldData) -> Image:
	if _image == null:
		_build(wd)
	return _image


static func origin() -> Vector2i:
	return _origin


static func _build(wd: WorldData) -> void:
	var b := bounds(wd)
	var img := Image.create_empty(maxi(1, b.size.x * CELL_PX), maxi(1, b.size.y * CELL_PX), false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for z in map_zones(wd):
		var packed: PackedScene = load(z.scene_path)
		if packed == null:
			continue
		var root := packed.instantiate()
		var at := (z.origin - b.position) * CELL_PX
		for layer_name in LAYERS:
			var layer := root.get_node_or_null(layer_name) as TileMapLayer
			if layer == null or layer.tile_set == null:
				continue
			for cell in layer.get_used_cells():
				if cell.x < 0 or cell.y < 0 or cell.x >= z.size.x or cell.y >= z.size.y:
					continue
				var mini := _mini_tile(layer.tile_set, layer.get_cell_source_id(cell), layer.get_cell_atlas_coords(cell))
				if mini != null:
					img.blend_rect(mini, Rect2i(Vector2i.ZERO, Vector2i(CELL_PX, CELL_PX)), at + cell * CELL_PX)
		root.free()
	_origin = b.position
	_image = img


## Un tile reducido a CELL_PX×CELL_PX (con caché).
static func _mini_tile(ts: TileSet, source_id: int, coords: Vector2i) -> Image:
	var key := "%d:%d,%d" % [source_id, coords.x, coords.y]
	if _mini.has(key):
		return _mini[key]
	var mini: Image = null
	var src := ts.get_source(source_id) as TileSetAtlasSource
	if src != null and src.texture != null:
		if not _atlas_images.has(source_id):
			var full := src.texture.get_image()
			if full != null and full.is_compressed():
				full.decompress()
			if full != null:
				full.convert(Image.FORMAT_RGBA8)
			_atlas_images[source_id] = full
		var atlas: Image = _atlas_images[source_id]
		if atlas != null:
			mini = atlas.get_region(src.get_tile_texture_region(coords))
			mini.resize(CELL_PX, CELL_PX, Image.INTERPOLATE_BILINEAR)
	_mini[key] = mini
	return mini
