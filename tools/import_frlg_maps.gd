extends SceneTree
## Convierte data/world/frlg_maps.json (de tools/import_frlg_maps.py: los mapas reales de FireRed de Pueblo Paleta
## a Ciudad Plateada, agrandados) en zonas del juego, y arma la región con ellas (data/world/kanto.tres).
## Uso: godot --headless --path . --script res://tools/import_frlg_maps.gd [-- --keep-others] [--only-new]
##  - --only-new: solo arma las zonas que todavía no están en kanto.tres (las que ya existen quedan tal cual: escena,
##    entrada y tabla de salvajes, aunque se hayan editado a mano). Así se suman mapas sin pisar lo anterior.
##  - --rebuild <id,id>: con --only-new, rearma la escena de esas zonas (para un arreglo del .py, como MOVE_BANDS);
##    su entrada en kanto.tres (plaza, salidas) y su tabla de salvajes quedan.
##  - Rearma el TileSet (con las colisiones por celda que piden los mapas) y guarda cada zona en
##    scenes/world/zones/<id>.tscn, marcada hand_edited (build_world no la pisa; se sigue editando con el editor).
##  - La región queda solo con las zonas importadas: las demás zonas y sus tablas de salvajes se borran (con
##    backup en .backup/), salvo con --keep-others.
##  - Salvajes: cada zona con plantilla de FireRed recibe su tabla (data/world/encounters/<id>.tres), con las filas
##    de agua (las de Surf: salen solo mientras navegás).

const DATA := "res://data/world/frlg_maps.json"

var roles: TileRoleSet
var tileset: TileSet
var rng := RandomNumberGenerator.new()


## Zonas hechas a mano que no salen de FireRed: se conservan siempre de kanto.tres (con su escena), aunque no se
## use --keep-others. El Torneo de Ciudad Plateada (docs/PLAN_TORNEO.md).
const EXTRA_ZONES := ["ciudad_plateada_torneo"]
## Puertas de FireRed que llevan a otro lado: zona -> {celda: {to, cell}}. La puerta del anexo del museo de
## Plateada (en FireRed, la entrada de atrás del museo) es la del Torneo.
## Objetos de FireRed que no se ponen: zona -> celdas. El árbol cortable de Plateada tapa el camino a la entrada de
## atrás del museo, que acá es el Torneo (sin Corte no se llegaría).
const SKIP_OBJECTS := {"ciudad_plateada": [Vector2i(54, 5)]}
const WARP_OVERRIDES := {
	"ciudad_plateada": {Vector2i(39, 4): {"to": "ciudad_plateada_torneo", "cell": Vector2i(7, 8)}},
}


func _init() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA))
	roles = ZoneBuilder.load_roles()
	_backup(ZoneBuilder.TILESET_PATH)
	ResourceSaver.save(ZoneBuilder.build_tileset(roles), ZoneBuilder.TILESET_PATH)
	tileset = ResourceLoader.load(ZoneBuilder.TILESET_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	var templates := {}
	for t in EncounterTable.templates():
		templates[t["id"]] = t

	var old: WorldData = load(ZoneBuilder.WORLD_PATH)
	var args := OS.get_cmdline_user_args()
	var only_new := "--only-new" in args
	var rebuild: PackedStringArray = args[args.find("--rebuild") + 1].split(",") if args.has("--rebuild") else []
	var old_by_id := {}
	for z in old.zones:
		old_by_id[z.id] = z
	var world := WorldData.new()
	world.tile_size = ZoneBuilder.T
	var ids := {}
	for z: Dictionary in data["zones"]:
		ids[z["id"]] = true
	for z: Dictionary in data["zones"]:
		if only_new and old_by_id.has(z["id"]):
			# Ya existe: queda tal cual (escena, plaza, tabla), salvo sus puertas, que pueden llevar a mapas nuevos.
			var kept: ZoneEntry = old_by_id[z["id"]]
			var before := kept.warps.size()
			kept.origin = Vector2i(int(z["origin"][0]), int(z["origin"][1]))  # (los interiores pueden moverse)
			kept.warps = {}
			for w: Dictionary in z["warps"]:
				kept.warps[Vector2i(int(w["cell"][0]), int(w["cell"][1]))] = {"to": w["to"], "cell": Vector2i(int(w["to_cell"][0]), int(w["to_cell"][1]))}
			for cell in WARP_OVERRIDES.get(kept.id, {}):
				kept.warps[cell] = WARP_OVERRIDES[kept.id][cell].duplicate()
			if kept.warps.size() != before:
				print("%-26s puertas: %d -> %d" % [kept.id, before, kept.warps.size()])
			if kept.id in rebuild:
				var built := _build(z)
				_backup(kept.scene_path)
				ZoneBuilder.save_zone(built, kept.scene_path)
				built.free()
				print("%-26s escena rearmada" % kept.id)
			world.zones.append(kept)
			continue
		var e := ZoneEntry.new()
		e.id = z["id"]
		e.display_name = z["name"]
		e.scene_path = "%s/%s.tscn" % [ZoneBuilder.ZONES_DIR, e.id]
		e.origin = Vector2i(int(z["origin"][0]), int(z["origin"][1]))
		e.size = Vector2i(int(z["size"][0]), int(z["size"][1]))
		e.interior = z["kind"] in ["interior", "cave"]  # sin sombras de nubes
		e.biome = _biome(z)
		for w: Dictionary in z["warps"]:
			e.warps[Vector2i(int(w["cell"][0]), int(w["cell"][1]))] = {"to": w["to"], "cell": Vector2i(int(w["to_cell"][0]), int(w["to_cell"][1]))}
		for cell in WARP_OVERRIDES.get(e.id, {}):
			e.warps[cell] = WARP_OVERRIDES[e.id][cell].duplicate()
		var root := _build(z)
		e.hub = _hub(root, e)
		_backup(e.scene_path)
		ZoneBuilder.save_zone(root, e.scene_path)
		root.free()
		world.zones.append(e)
		var tpl: String = z.get("template", "")
		var tpath := EncounterTable.zone_path(e.id)
		var table := EncounterTable.from_template(templates[tpl]) if templates.has(tpl) else null
		if table != null:
			# Las filas de agua (las de Surf) quedan: WildSpawner las saca solo mientras navegás.
			if z["kind"] == "cave":  # en las cuevas de FireRed aparecen en cualquier lugar del suelo
				for r in table.entries:
					if r.where == "pasto_alto":
						r.where = "suelo"
		_backup(tpath)
		if table != null and not table.entries.is_empty():
			ResourceSaver.save(table, tpath)
		elif FileAccess.file_exists(tpath):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(tpath))
		print("%-26s %s  puertas: %d" % [e.id, e.size, e.warps.size()])
	world.spawn_cell = old.spawn_cell if only_new else Vector2i(int(data["spawn"][0]), int(data["spawn"][1]))

	var keep_others := only_new or "--keep-others" in OS.get_cmdline_user_args()
	for z in old.zones:
		if ids.has(z.id):
			continue
		if keep_others or z.id in EXTRA_ZONES:
			world.zones.append(z)
			continue
		for p in [z.scene_path, EncounterTable.zone_path(z.id)]:
			if FileAccess.file_exists(p):
				_backup(p)
				DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
		print("borrada: ", z.id)
	_backup(ZoneBuilder.WORLD_PATH)
	ResourceSaver.save(world, ZoneBuilder.WORLD_PATH)
	print("Región: %d zonas, inicio %s." % [world.zones.size(), world.spawn_cell])
	quit()


## Copia de seguridad en <carpeta>/.backup/ (como el editor de mapas).
func _backup(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var dir := path.get_base_dir().path_join(".backup")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "_")
	DirAccess.copy_absolute(ProjectSettings.globalize_path(path),
		ProjectSettings.globalize_path(dir.path_join("%s_%s.%s" % [path.get_file().get_basename(), stamp, path.get_extension()])))


func _biome(z: Dictionary) -> String:
	if z["kind"] == "interior":
		return "interior"
	if z["kind"] == "cave":
		return "cueva"
	var id: String = z["id"]
	if id.begins_with("ruta"):
		return "pradera"
	if id.begins_with("bosque"):
		return "bosque"
	return "ciudad"


## Zona con cada celda del mapa: el tile en su capa (agua y follaje en las suyas, como los pinceles), su parte
## de arriba en Overhead y la colisión que tiene en el mapa de FireRed (tile alternativo si hace falta).
func _build(z: Dictionary) -> Node2D:
	var root := ZoneBuilder.new_zone_root(z["id"], tileset)
	root.set("hand_edited", true)
	var w := int(z["size"][0])
	var cells: Array = z["cells"]
	var col: Array = z["col"]
	var ground: TileMapLayer = root.get_node("Ground")
	var overhead: TileMapLayer = root.get_node("Overhead")
	rng.seed = hash(z["id"])
	for i in cells.size():
		var m := int(cells[i])
		if m < 0 or not ZoneBuilder.exists(m):
			continue
		var c := Vector2i(i % w, i / w)
		# Capa como la de los pinceles: agua en Water y pasto alto en Foliage, con pasto abajo (así funcionan el
		# shader, el hielo que hace puente y el pasto que tapa las piernas).
		var layer_name := "Ground"
		var under := ""
		var role := roles.role_of(m)
		if role != null and role.layer in ["Water", "Foliage"]:
			layer_name = role.layer
			under = role.under
		elif roles.physics_for(m) == MapRules.WATER:
			layer_name = "Water"
			under = "grass"
		elif roles.tags_for(m).has("pasto_alto"):
			layer_name = "Foliage"
			under = "grass"
		var layer: TileMapLayer = root.get_node(layer_name)
		if under != "":
			ZoneBuilder.set_metatile(ground, c, roles.get_role(under).pick(rng))
		var ref := ZoneBuilder.below_ref(m)
		layer.set_cell(c, ref[0], ref[1], ZoneBuilder.collision_alt(tileset, roles, m, int(col[i]) != 0))
		if ZoneBuilder.has_above(m):
			ZoneBuilder.set_above(overhead, c, m)
	for o: Dictionary in z.get("objects", []):
		var oc := Vector2i(int(o["cell"][0]), int(o["cell"][1]))
		if oc not in SKIP_OBJECTS.get(z["id"], []):
			ZoneBuilder.add_object(root, o["scene"], oc)
	return root


## Plaza de la zona: la celda transitable más cercana al centro (la usan el editor y el autotest).
func _hub(root: Node, e: ZoneEntry) -> Vector2i:
	var objects := MapRules.objects_by_cell(root)
	var center := e.size / 2
	var best := center
	var best_d := INF
	for y in e.size.y:
		for x in e.size.x:
			var c := Vector2i(x, y)
			if e.warps.has(c) or not MapRules.is_walkable(root, c, objects):
				continue
			var d := Vector2(c - center).length()
			if d < best_d:
				best_d = d
				best = c
	return best
