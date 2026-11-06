class_name ExtraContent
extends RefCounted
## Lo agregado al mundo **sin tocar las zonas importadas ni kanto.tres** (las maneja otro agente; docs/PLAN_ONLINE.md,
## O-1): zonas nuevas (`data/world/extra/zones/*.tres`, ZoneEntry: interiores propios) y edificios encima de una zona
## (`data/world/extra/buildings/*.tres`, ExtraBuilding). DB los suma a la región al arrancar (`apply`); World pone el
## sprite y la colisión de cada edificio al cargar su zona (`attach`). El editor de mapas guarda la región sin
## ellos (`without_extras`).

const ZONES_DIR := "res://data/world/extra/zones"
const BUILDINGS_DIR := "res://data/world/extra/buildings"
const PENS_DIR := "res://data/world/extra/pens"
## Marca de las puertas agregadas (para sacarlas al guardar la región).
const EXTRA_KEY := "extra"
## Meta de la zona con las celdas sólidas de los edificios (la lee MapRules.cell_physics).
const SOLID_META := "extra_solid"

static var buildings: Array[ExtraBuilding] = []
static var pens: Array[ExtraPen] = []
static var zone_ids: PackedStringArray = []


## Suma a la región las zonas y las puertas agregadas (una sola vez).
static func apply(world: WorldData) -> void:
	buildings.clear()
	pens.clear()
	pens.assign(_load_dir(PENS_DIR, "ExtraPen"))
	zone_ids.clear()
	var by_id := {}
	for z in world.zones:
		by_id[z.id] = z
	for z in _load_dir(ZONES_DIR, "ZoneEntry"):
		zone_ids.append(z.id)
		if not by_id.has(z.id):
			world.zones.append(z)
			by_id[z.id] = z
	for b: ExtraBuilding in _load_dir(BUILDINGS_DIR, "ExtraBuilding"):
		var host: ZoneEntry = by_id.get(b.zone_id)
		if host == null or (b.to_zone != "" and not by_id.has(b.to_zone)):
			push_warning("Edificio agregado %s: no existe la zona %s o %s" % [b.id, b.zone_id, b.to_zone])
			continue
		buildings.append(b)
		if b.to_zone != "":  # (sin puerta: un objeto grande, como los globos aerostáticos)
			host.warps[b.door] = {"to": b.to_zone, "cell": b.to_cell, EXTRA_KEY: true}


## Copia de la región sin lo agregado (para guardarla: así no queda escrito en kanto.tres).
static func without_extras(world: WorldData) -> WorldData:
	var out: WorldData = world.duplicate()
	var zones: Array[ZoneEntry] = []
	for z in world.zones:
		if z.id in zone_ids:
			continue
		var clean := z
		if z.warps.values().any(func(w): return w is Dictionary and w.get(EXTRA_KEY, false)):
			clean = z.duplicate()
			var warps := {}
			for c in z.warps:
				if not (z.warps[c] is Dictionary and z.warps[c].get(EXTRA_KEY, false)):
					warps[c] = z.warps[c]
			clean.warps = warps
		zones.append(clean)
	out.zones = zones
	return out


## Pone los edificios de esta zona: sprite (con y-sort por la base), colisión y celdas sólidas para MapRules.
static func attach(zone: Node2D, entry: ZoneEntry, world: WorldData) -> void:
	var ts := world.tile_size
	for b in buildings:
		if b.zone_id != entry.id or zone.has_node("Extra_" + b.id):
			continue
		var root := Node2D.new()
		root.name = "Extra_" + b.id
		# Origen en la base del edificio (como las entidades: los pies), así el y-sort de la zona lo ordena.
		root.position = Vector2(b.cell.x * ts, (b.cell.y + b.size.y) * ts)
		if b.texture != null:
			var spr := Sprite2D.new()
			spr.texture = b.texture
			spr.centered = false
			spr.position = Vector2(0, -b.texture.get_height())
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			root.add_child(spr)
			if b.walkable:
				# Una pintura más grande que sus celdas (el Centro Online, ×3) se achica a su lugar y se dibuja suave.
				var fit := minf(float(b.size.x * ts) / b.texture.get_width(), float(b.size.y * ts) / b.texture.get_height())
				if fit < 1.0:
					spr.scale = Vector2.ONE * fit
					spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
				var drawn := b.texture.get_size() * minf(fit, 1.0)
				spr.position = ((Vector2(b.size * ts) - drawn) / 2.0).floor() - Vector2(0, b.size.y * ts)
				root.z_index = -5  # piso: debajo de los personajes
		if b.walkable:
			zone.add_child(root)
			continue
		var body := StaticBody2D.new()
		body.name = "Body"
		body.collision_layer = 1  # mundo
		body.collision_mask = 0
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(b.size * ts)
		shape.shape = rect
		shape.position = Vector2(b.size.x * ts / 2.0, -b.size.y * ts / 2.0)
		body.add_child(shape)
		root.add_child(body)
		zone.add_child(root)
		var solid: Dictionary = zone.get_meta(SOLID_META, {})
		for c in b.cells():
			solid[c] = true
		zone.set_meta(SOLID_META, solid)
	for pen in pens:
		if pen.zone_id != entry.id or zone.has_node("Pen_" + pen.id):
			continue
		var holder := Node2D.new()
		holder.name = "Pen_" + pen.id
		holder.y_sort_enabled = true
		zone.add_child(holder)
		var area := Rect2(Vector2(pen.area.position * ts), Vector2(pen.area.size * ts))
		for sid in pen.species:
			if DB.species.has(sid):
				holder.add_child(PenPokemon.make(DB.species[sid], area))


static func _load_dir(dir: String, cls: String) -> Array:
	var out := []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	for f in DirAccess.get_files_at(dir):
		f = f.trim_suffix(".remap")
		if not f.ends_with(".tres"):
			continue
		var r = load(dir.path_join(f))
		if r != null and r.get_script() != null and r.get_script().get_global_name() == cls:
			out.append(r)
	return out
