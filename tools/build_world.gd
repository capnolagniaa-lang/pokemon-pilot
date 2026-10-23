extends SceneTree
## Construye el TileSet (a partir de los atlas de FireRed generados por tools/pret_import.py y de los roles
## de data/world/tile_roles.tres) y la región: una grilla de zonas generadas según su bioma, conectadas por
## caminos. La generación vive en scripts/world/zone_generator.gd (la comparte el editor de mapas).
## Uso: godot --headless --path . --script res://tools/build_world.gd [-- --force | --force-all]
##  (nada)       no pisa archivos existentes (para no perder lo que pintes en el editor).
##  --force      regenera el TileSet y las zonas, salvo las editadas con el editor de mapas (hand_edited),
##               que conservan también su entrada (hub, salidas) en kanto.tres.
##  --force-all  regenera todo, incluidas las zonas editadas a mano (se pierde lo pintado).
##  --tileset    solo rearma el catálogo (data/world/tile_catalog.tres, desde art/pret/tiles/catalog.json) y el
##               TileSet con todos los tilesets importados; no toca zonas. Correrlo después de tools/pret_import.py.
## Zonas agregadas con el editor (que no están en REGION) se conservan siempre.

const ZONE_SIZE := Vector2i(48, 32)
const START_ZONE := "pueblo_paleta"

# Región generada: [id, nombre, columna, fila, bioma]. Las zonas vecinas quedan conectadas. Vacía desde que el mundo
# son los mapas reales de FireRed (tools/import_frlg_maps.py + .gd): las zonas que no están acá se conservan siempre.
# Para volver a generar zonas de prueba, sumar filas, por ejemplo ["pradera", "Pradera", 5, 0, "pradera"].
const REGION := []

const CATALOG_PATH := "res://data/world/tile_catalog.tres"

var force := false
var force_all := false
var rng := RandomNumberGenerator.new()


func _init() -> void:
	force_all = "--force-all" in OS.get_cmdline_user_args()
	force = force_all or "--force" in OS.get_cmdline_user_args()
	for d in ["res://data/world", ZoneBuilder.ZONES_DIR, "res://art/tiles"]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(d))
	var roles := ZoneBuilder.load_roles()
	if "--tileset" in OS.get_cmdline_user_args() or roles.catalog == null:
		_catalog(roles)
		if "--tileset" in OS.get_cmdline_user_args():
			ResourceSaver.save(ZoneBuilder.build_tileset(roles), ZoneBuilder.TILESET_PATH)
			print("Catálogo y TileSet rearmados: %d tilesets, %d sellos." % [ZoneBuilder.set_names().size(), roles.catalog.stamps.size()])
			quit()
			return
	var tileset := _tileset(roles)
	var generator := ZoneGenerator.new(roles, tileset)

	var old: WorldData = load(ZoneBuilder.WORLD_PATH) if ResourceLoader.exists(ZoneBuilder.WORLD_PATH) else null
	var zones: Array[ZoneEntry] = []
	var spawn := Vector2i.ZERO
	var skipped: Array[String] = []
	for planned in _plan_region():
		var e: ZoneEntry = planned
		if ZoneBuilder.is_hand_edited(e.scene_path) and not force_all:
			# Editada con el editor de mapas: se queda su escena y su hub/salidas.
			var kept := _old_entry(old, e.id)
			if kept != null:
				e = kept
			skipped.append(e.id)
		elif force or not ResourceLoader.exists(e.scene_path):
			var root := generator.generate(e)
			ZoneBuilder.save_zone(root, e.scene_path)
			root.free()
		zones.append(e)
		if e.id == START_ZONE:
			spawn = e.origin + e.hub + Vector2i(1, 1)
	if old != null:
		for z in old.zones:  # zonas creadas con el editor
			if not REGION.any(func(r): return r[0] == z.id):
				zones.append(z)

	if force or old == null:
		var world := WorldData.new()
		world.tile_size = ZoneBuilder.T
		world.zones = zones
		world.spawn_cell = old.spawn_cell if old != null and not force_all else spawn
		ResourceSaver.save(world, ZoneBuilder.WORLD_PATH)
	var cfg_path := "res://data/config/game_config.tres"
	if ResourceLoader.exists(cfg_path):
		var cfg: GameConfig = load(cfg_path)
		cfg.world = load(ZoneBuilder.WORLD_PATH)
		ResourceSaver.save(cfg, cfg_path)
	if not skipped.is_empty():
		print("Zonas editadas a mano que no se regeneraron (usá --force-all para pisarlas): ", skipped)
	print("Mundo construido: %d zonas." % zones.size())
	quit()


## Catálogo de metatiles (categorías, tags/colisión sugeridos, sellos) desde el JSON del importador.
func _catalog(roles: TileRoleSet) -> void:
	var catalog := TileCatalog.from_json()
	ResourceSaver.save(catalog, CATALOG_PATH)
	catalog.take_over_path(CATALOG_PATH)  # el recién armado, no el viejo de la caché
	roles.catalog = catalog
	ResourceSaver.save(roles, ZoneBuilder.ROLES_PATH)


func _tileset(roles: TileRoleSet) -> TileSet:
	if not force and ResourceLoader.exists(ZoneBuilder.TILESET_PATH):
		return load(ZoneBuilder.TILESET_PATH)
	ResourceSaver.save(ZoneBuilder.build_tileset(roles), ZoneBuilder.TILESET_PATH)
	return load(ZoneBuilder.TILESET_PATH)


func _old_entry(old: WorldData, id: String) -> ZoneEntry:
	if old == null:
		return null
	for z in old.zones:
		if z.id == id:
			return z
	return null


## Crea las ZoneEntry con su plaza central y las salidas alineadas con cada vecina.
func _plan_region() -> Array[ZoneEntry]:
	var by_pos := {}
	var out: Array[ZoneEntry] = []
	for z in REGION:
		var e := ZoneEntry.new()
		e.id = z[0]
		e.display_name = z[1]
		e.origin = Vector2i(z[2], z[3]) * ZONE_SIZE
		e.size = ZONE_SIZE
		e.biome = z[4]
		e.scene_path = "%s/%s.tscn" % [ZoneBuilder.ZONES_DIR, e.id]
		rng.seed = hash(e.id + "hub")
		e.hub = Vector2i(rng.randi_range(9, 14) * 2, rng.randi_range(5, 9) * 2)
		by_pos[Vector2i(z[2], z[3])] = e
		out.append(e)
	for pos in by_pos:
		var e: ZoneEntry = by_pos[pos]
		for side in [["right", Vector2i(1, 0)], ["down", Vector2i(0, 1)]]:
			var other: ZoneEntry = by_pos.get(pos + side[1])
			if other == null:
				continue
			rng.seed = hash(e.id + other.id)
			if side[0] == "right":
				var y := rng.randi_range(4, ZONE_SIZE.y / 2 - 5) * 2
				e.exits["right"] = Vector2i(ZONE_SIZE.x - 2, y)
				other.exits["left"] = Vector2i(0, y)
			else:
				var x := rng.randi_range(4, ZONE_SIZE.x / 2 - 5) * 2
				e.exits["down"] = Vector2i(x, ZONE_SIZE.y - 2)
				other.exits["up"] = Vector2i(x, 0)
	return out
