class_name StyleOverlay
extends Node2D
## Terreno propio (docs/PLAN_TERRENO_PROPIO.md, prueba de la fase T-3): dibuja una zona con un paquete de estilo
## (art/estilos/<paquete>/, de tools/style_pack.py) en vez de los tiles de FireRed, **leyendo sus celdas**: la
## colisión, las puertas, los tags y todo lo demás siguen siendo los de la zona (las capas de tiles quedan, invisibles).
## - Suelo: cada celda → un material (pasto, tierra, empedrado, agua, roca, piso de cueva) según su rol/tags; el
##   shader `style_ground` repite la textura de cada material y corre el borde entre materiales con ruido (bordes
##   orgánicos sin dibujar piezas de transición).
## - Objetos: casas y fuente (sellos de FireRed reconocidos por sus metatiles), árboles (`Zone.tree_cells` y celdas
##   "arbol" sueltas), cercas, pasto alto y la boca de la cueva (en su puerta), como sprites con y-sort.
## Por ahora solo en las zonas de pruebas (`ZoneEntry.test_zone`); el paquete se elige con `estilo <nombre>` en la
## consola de Game Master. Sin paquete ("fire") la zona se ve como siempre.

const SHADER := preload("res://shaders/style_ground.gdshader")
const SHADER_HD := preload("res://shaders/style_ground_hd.gdshader")
const DIR := "res://art/estilos/%s/%s.png"
const PACKS := ["campo", "cuento", "siniestro", "campo_hd", "cuento_hd", "siniestro_hd"]
## Los paquetes *_hd tienen HD veces más píxeles por celda (tools/style_pack.py): se dibujan a 1/HD de escala.
const HD := 4
## Índice de cada material en el mapa de celdas y en el shader (tex0..tex5); VOID = sin suelo (el negro de la cueva).
const MATERIALS := ["mat_pasto", "mat_tierra", "mat_empedrado", "mat_agua", "mat_roca", "mat_cueva_piso", "mat_pasto_alto"]
enum { PASTO, TIERRA, EMPEDRADO, AGUA, ROCA, CUEVA_PISO, PASTO_ALTO, VOID = 255 }
const ROLE_MATERIAL := {"grass": PASTO, "meadow": PASTO, "flowers": PASTO, "tall_grass": PASTO, "tree": PASTO,
	"dirt": TIERRA, "sand": TIERRA, "stone_floor": EMPEDRADO, "city_floor": EMPEDRADO, "water": AGUA,
	"cave_floor": CUEVA_PISO}
## Sellos de FireRed que se cambian por un objeto del paquete.
const STAMP_PIECES := {"PalletTown_5_3": "casa", "VermilionCity_25_32": "fuente"}
const FENCE_METATILES := [214, 215]
## Capas de la zona que se esconden (SunShadows = las sombras de FireRed por celda: cada sprite tira la suya).
const LAYERS := ["Ground", "Water", "Foliage", "TreeShadows", "Overhead", "SunShadows"]
## Sombra de contacto: mancha oscura al pie de cada objeto (ancho relativo al sprite, opacidad).
const CONTACT_WIDTH := 1.15
const CONTACT_ALPHA := 0.42
## Luz del sol sobre los sprites HD con relieve (<pieza>_n.png): solo ilumina lo que tiene este bit en light_mask.
const LIGHT_BIT := 1 << 9
## Los sprites con relieve van un poco más oscuros: la luz suma del lado que da al sol (el otro queda en sombra).
const LIT_BASE := 0.72
const SUN_ENERGY := 0.3

## Paquete activo ("" = los tiles de FireRed). No se guarda: es para mirar.
static var active := ""
## El "sol" de los sprites con relieve (uno solo para todas las zonas).
static var _sun: DirectionalLight2D

var zone: Zone
var entry: ZoneEntry
var _hidden: Array[CanvasItem] = []
var _sprites: Array[Node] = []


static func attach(zone_node: Node2D, e: ZoneEntry) -> StyleOverlay:
	var old := zone_node.get_node_or_null("StyleOverlay")
	if old != null:
		(old as StyleOverlay).restore()
		old.free()
	if active == "" or not e.test_zone or (e.interior and e.biome != "cueva"):
		return null
	var node := StyleOverlay.new()
	node.name = "StyleOverlay"
	node.zone = zone_node as Zone
	node.entry = e
	zone_node.add_child(node)
	node.build()
	return node


## Vuelve a armar todas las zonas cargadas (al cambiar de paquete).
static func refresh(world: Node) -> void:
	for id in world.streamer.loaded:
		for z in world.streamer.world_data.zones:
			if z.id == id:
				attach(world.streamer.loaded[id], z)


## El StyleOverlay de la zona en esa posición (global), o null.
static func at(world: Node, pos: Vector2) -> StyleOverlay:
	if active == "" or world == null or world.get("streamer") == null:
		return null
	for z in world.streamer.loaded.values():
		var ov := (z as Node).get_node_or_null("StyleOverlay") as StyleOverlay
		if ov != null and Rect2(Vector2(ov.entry.origin * Zone.TILE), Vector2(ov.entry.size * Zone.TILE)).has_point(pos):
			return ov
	return null


static func is_hd() -> bool:
	return active.ends_with("_hd")


static func texture(piece: String) -> Texture2D:
	var path := DIR % [active, piece]
	return load(path) if ResourceLoader.exists(path) else null


func build() -> void:
	var size := entry.size
	var cave := entry.biome == "cueva"
	var roles := ZoneBuilder.load_roles()
	var covered := {}  # celdas tapadas por un objeto (casa, fuente): suelo de pasto debajo
	_place_stamps(covered)
	var cells := Image.create(size.x, size.y, false, Image.FORMAT_R8)
	for y in size.y:
		for x in size.x:
			var c := Vector2i(x, y)
			cells.set_pixel(x, y, Color8(_material_at(c, roles, cave, covered), 0, 0))
	_ground(cells)  # (se mueve al principio: la zona ordena por Y y el suelo tiene que ir antes que todo)
	zone.move_child(zone.get_node("StyleGround"), 0)
	_trees()
	_cell_pieces(roles)
	_cave_mouths()
	if OS.get_cmdline_user_args().has("--shadow-debug"):
		for sp in _sprites:
			if sp is Sprite2D and sp.texture != null:
				var tp: String = (sp.texture.diffuse_texture if sp.texture is CanvasTexture else sp.texture).resource_path.get_file()
				print("[ovdbg] ", tp, " at ", sp.position, " z=", sp.z_index, " mod=", sp.modulate, " scale=", sp.scale)
	for name in LAYERS:
		var l := zone.get_node_or_null(name) as CanvasItem
		if l != null and l.visible:
			l.visible = false
			l.set_process(false)  # ZoneShadows se vuelve a prender sola en _process
			_hidden.append(l)


func _ensure_sun() -> void:
	if _sun != null and is_instance_valid(_sun):
		return
	_sun = DirectionalLight2D.new()
	_sun.name = "StyleSun"
	_sun.range_item_cull_mask = LIGHT_BIT
	_sun.blend_mode = Light2D.BLEND_MODE_ADD
	get_tree().get_first_node_in_group("world").add_child(_sun)


## El sol de los sprites con relieve sigue a DayNight: dirección de las sombras, altura y color de la hora.
func _process(_delta: float) -> void:
	if _sun == null or not is_instance_valid(_sun):
		return
	var dn: DayNight = get_tree().get_first_node_in_group("world").get("day_night")
	if dn == null:
		return
	var sun := DayNight.sun_at(dn.hour())
	_sun.rotation = (sun[1] as Vector2).angle() - PI / 2.0  # la luz baja (+Y) hacia donde caen las sombras
	_sun.height = clampf(DayNight.SHADOW_MIN / float(sun[2]), 0.15, 0.95)
	var lk := DayNight.look_at(dn.hour())
	_sun.color = lk[6]
	var args := OS.get_cmdline_user_args()
	var at := args.find("--sun-energy")  # calibración desde la línea de comandos
	var base := float(args[at + 1]) if at >= 0 and at + 1 < args.size() else SUN_ENERGY
	_sun.energy = base * (1.0 - dn.darkness * 0.8)


## Deja la zona como estaba (los tiles de FireRed a la vista).
func restore() -> void:
	for l in _hidden:
		if is_instance_valid(l):
			l.visible = true
			l.set_process(true)
	_hidden.clear()
	for s in _sprites:
		if is_instance_valid(s):
			s.queue_free()
	_sprites.clear()


func _material_at(c: Vector2i, roles: TileRoleSet, cave: bool, covered: Dictionary) -> int:
	if covered.has(c):
		return PASTO
	if zone.water.get_cell_source_id(c) >= 0:
		return AGUA
	if _foliage_role(c, roles) == "tall_grass" and texture("mat_pasto_alto") != null:
		return PASTO_ALTO
	var src := zone.ground.get_cell_source_id(c)
	if src < 0:
		return VOID if cave else PASTO
	var m := ZoneBuilder.metatile_of(src, zone.ground.get_cell_atlas_coords(c))
	var role := roles.role_of(m)
	if role != null and ROLE_MATERIAL.has(role.id):
		return ROLE_MATERIAL[role.id]
	if m in FENCE_METATILES:
		return PASTO
	var tags := zone.get_tags(c)
	if "agua" in tags:
		return AGUA
	if "arbol" in tags:
		return PASTO
	if MapRules.cell_physics(zone, c) == MapRules.SOLID:
		return ROCA
	if cave:
		return CUEVA_PISO
	return TIERRA if "arena" in tags else PASTO


func _foliage_role(c: Vector2i, roles: TileRoleSet) -> String:
	var src := zone.foliage.get_cell_source_id(c)
	if src < 0:
		return ""
	var role := roles.role_of(ZoneBuilder.metatile_of(src, zone.foliage.get_cell_atlas_coords(c)))
	return role.id if role != null else ""


## Número fijo por celda (para variar sin azar: la zona se ve igual cada vez).
static func _hash(c: Vector2i) -> int:
	return absi((c.x * 73856093) ^ (c.y * 19349663))


func _ground(cells: Image) -> void:
	var rect := ColorRect.new()
	rect.name = "StyleGround"
	rect.size = Vector2(entry.size * Zone.TILE)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.z_index = -10
	var mat := ShaderMaterial.new()
	mat.shader = SHADER_HD if is_hd() else SHADER
	mat.set_shader_parameter("cells", ImageTexture.create_from_image(cells))
	mat.set_shader_parameter("zone_cells", Vector2(entry.size))
	for i in MATERIALS.size():
		var t := texture(MATERIALS[i])
		if t != null:
			mat.set_shader_parameter("tex%d" % i, t)
	rect.material = mat
	zone.add_child(rect)
	_sprites.append(rect)


## Sprite con los pies en `feet` (local de la zona), y-sort con los personajes.
func _sprite(piece: String, feet: Vector2, flip := false, shadows := true) -> Sprite2D:
	var t := texture(piece)
	if t == null:
		return null
	var s := Sprite2D.new()
	s.texture = t
	var normal := texture(piece + "_n") if is_hd() else null
	if normal != null:
		var ct := CanvasTexture.new()
		ct.diffuse_texture = t
		ct.normal_texture = normal
		s.texture = ct
		s.light_mask = LIGHT_BIT
		s.self_modulate = Color(LIT_BASE, LIT_BASE, LIT_BASE)
		_ensure_sun()
	s.centered = false
	s.offset = Vector2(-t.get_width() / 2.0, -t.get_height())
	s.position = feet
	s.flip_h = flip
	_scale_hd(s)
	zone.add_child(s)
	_sprites.append(s)
	if shadows:
		if not OS.get_cmdline_user_args().has("--no-contact"):
			_contact(feet, t.get_width() * s.scale.x)
		var sh := SunShadow.new()  # (no attach_to: agrega diferido y al cambiar de estilo quedaba huérfana)
		sh.source = s
		sh.position = feet - Vector2(0, 0.5)  # y-sort de la zona: en su lugar, un pelo antes que el objeto
		sh.soft = true
		sh.flatten_k = 0.65  # más larga que la de los personajes (como en los HD-2D)
		sh.z_index = SunShadow.Z
		zone.add_child(sh)
		_sprites.append(sh)
	return s


## Mancha oscura y suave al pie de un objeto (lo "apoya" en el suelo).
func _contact(feet: Vector2, width: float) -> void:
	var c := Sprite2D.new()
	c.texture = _contact_texture()
	c.position = feet + Vector2(0, -0.6)
	c.scale = Vector2(width * CONTACT_WIDTH, width * CONTACT_WIDTH * 0.42) / c.texture.get_width()
	c.modulate = Color(0.1, 0.08, 0.16, CONTACT_ALPHA)
	c.z_index = SunShadow.Z
	zone.add_child(c)
	_sprites.append(c)


static var _contact_tex: Texture2D


static func _contact_texture() -> Texture2D:
	if _contact_tex == null:
		var g := Gradient.new()
		g.set_color(0, Color.WHITE)
		g.set_color(1, Color(1, 1, 1, 0))
		var t := GradientTexture2D.new()
		t.gradient = g
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.0, 0.5)
		t.width = 64
		t.height = 64
		_contact_tex = t
	return _contact_tex


## HD: la textura tiene HD veces más píxeles: se achica y se filtra suave.
func _scale_hd(s: Sprite2D) -> void:
	if is_hd():
		s.scale = Vector2.ONE / HD
		s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func _place_stamps(covered: Dictionary) -> void:
	var catalog: TileCatalog = load("res://data/world/tile_catalog.tres")
	var n := 0
	for st: Dictionary in catalog.stamps:
		if not STAMP_PIECES.has(st["id"]):
			continue
		var size: Vector2i = st["size"]
		var want: PackedInt32Array = (st["variants"][0] if st.has("variants") else st)["cells"]
		for y in range(entry.size.y - size.y + 1):
			for x in range(entry.size.x - size.x + 1):
				if not _matches(Vector2i(x, y), size, want):
					continue
				var piece: String = STAMP_PIECES[st["id"]]
				if piece == "casa" and n % 2 == 1 and texture("tienda") != null:
					piece = "tienda"  # una casa sí y una no: el almacén
				n += 1
				for j in size.y:
					for i in size.x:
						covered[Vector2i(x + i, y + j)] = true
				_sprite(piece, Vector2((x + size.x / 2.0) * Zone.TILE, (y + size.y) * Zone.TILE))


func _matches(at: Vector2i, size: Vector2i, want: PackedInt32Array) -> bool:
	for i in want.size():
		if want[i] < 0:
			continue
		var c := at + Vector2i(i % size.x, i / size.x)
		var src := zone.ground.get_cell_source_id(c)
		if src < 0 or ZoneBuilder.metatile_of(src, zone.ground.get_cell_atlas_coords(c)) != want[i]:
			return false
	return true


## Un árbol por cada 2×2 de `tree_cells`; las celdas "arbol" sueltas (de mapas pegados) se cubren de a 2×2.
func _trees() -> void:
	var forest := entry.biome == "bosque"
	var piece := "arbol_bosque" if forest and texture("arbol_bosque") != null else "arbol"
	var done := {}
	var origins: Array[Vector2i] = zone.tree_cells.duplicate()
	for y in entry.size.y:
		for x in entry.size.x:
			var c := Vector2i(x, y)
			if done.has(c) or zone.tree_cells.has(c) or not "arbol" in zone.get_tags(c):
				continue
			var inside_known := false
			for o in zone.tree_cells:
				if c.x >= o.x and c.x <= o.x + 1 and c.y >= o.y and c.y <= o.y + 1:
					inside_known = true
			if not inside_known:
				origins.append(c)
				for d in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
					done[c + d] = true
	origins.sort_custom(func(a, b): return a.y < b.y or (a.y == b.y and a.x < b.x))
	for o in origins:
		var h := _hash(o)  # un poco de variedad: corrido unos píxeles y espejado
		var jitter := Vector2(h % 7 - 3, (h / 7) % 5 - 2)
		_sprite(piece, Vector2((o.x + 1) * Zone.TILE, (o.y + 2) * Zone.TILE) + jitter, h % 2 == 0)


## Cercas (tramos de metatiles 214/215) y pasto alto, celda por celda.
func _cell_pieces(roles: TileRoleSet) -> void:
	var fence := texture("cerca")
	for y in entry.size.y:
		var x := 0
		while x < entry.size.x:
			var run := 0
			while x + run < entry.size.x and _is_fence(Vector2i(x + run, y)):
				run += 1
			if run > 0 and fence != null:
				var s := Sprite2D.new()
				s.texture = fence
				s.centered = false
				s.region_enabled = true
				s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
				s.region_rect = Rect2(0, 0, run * Zone.TILE * (HD if is_hd() else 1), fence.get_height())
				s.offset = Vector2(0, -fence.get_height())
				s.position = Vector2(x * Zone.TILE, (y + 1) * Zone.TILE)
				_scale_hd(s)
				zone.add_child(s)
				_sprites.append(s)
			x += max(run, 1)
	if texture("pasto_alto") == null:
		return
	# Con textura de pasto alto, unas matas sueltas encima (una de cada tres celdas); sin ella, una por celda.
	var sparse := texture("mat_pasto_alto") != null
	for y in entry.size.y:
		for x in entry.size.x:
			var c := Vector2i(x, y)
			var h := _hash(c)
			if _foliage_role(c, roles) != "tall_grass" or (sparse and h % 3 != 0):
				continue
			var jitter := Vector2(h % 9 - 4, (h / 9) % 5 - 2) if sparse else Vector2.ZERO
			_sprite("pasto_alto", Vector2((x + 0.5) * Zone.TILE, (y + 1) * Zone.TILE + 1) + jitter, h % 2 == 0, false)


func _is_fence(c: Vector2i) -> bool:
	var src := zone.ground.get_cell_source_id(c)
	return src >= 0 and ZoneBuilder.metatile_of(src, zone.ground.get_cell_atlas_coords(c)) in FENCE_METATILES


## La boca de la cueva va encima de cada puerta que lleva a una cueva (afuera).
func _cave_mouths() -> void:
	if entry.interior:
		return
	for door in entry.warps:
		var to: String = entry.warps[door]["to"]
		for z in DB.config.world.zones:
			if z.id == to and z.biome == "cueva":
				_sprite("cueva", Vector2((door.x + 0.5) * Zone.TILE, (door.y + 1) * Zone.TILE))
