class_name View3D
extends Node3D
## PRUEBA (rama mundo3d): el mismo juego dibujado en 3D. La simulación sigue siendo la 2D de siempre (física, combate,
## IA, historia); esto es solo otra forma de mostrarla: el suelo de cada zona se arma como malla desde sus capas de
## tiles, lo alto (edificios, árboles, cercos) se para como un libro pop-up, y cada persona o Pokémon es un sprite 3D
## que copia cada cuadro al de su nodo 2D. Se prende con `-- --view3d`.

const T := 16.0
## Hasta cuántas celdas seguidas (de norte a sur) se paran como una sola lámina; más que eso es una meseta.
const MAX_STAND := 7
const PLATEAU := 1.2
const CHUNK := 2
## Cuánto se recuesta hacia atrás cada lámina por celda de alto (para que el dibujo no se aplaste visto de arriba).
const LEAN := 0.3
const LAYERS := ["Ground", "Water", "Foliage", "Overhead"]

var world: Node2D
var cam: Camera3D
var sun: DirectionalLight3D
var pitch := 50.0
var distance := 26.0
var _zones := {}    # id de zona -> Node3D
var _mirrors := {}  # id de instancia del nodo 2D -> nodo 3D
var _materials := {}
## Todo lo 2D del combate que todavía no tiene versión 3D (zonas, golpes, marcas, números): se dibuja visto de arriba
## en este viewport y se proyecta sobre el suelo, en su lugar.
var _fx_view: SubViewport
var _fx_plane: MeshInstance3D
const FX_SIZE := Vector2i(768, 576)
const HIDDEN := 2
const FX := 4


static func wanted() -> bool:
	return "--view3d" in OS.get_cmdline_user_args()


func setup(w: Node2D) -> void:
	world = w
	# Lo 2D del mundo deja de dibujarse (sigue andando); los menús y el HUD van en sus CanvasLayer y quedan.
	get_viewport().canvas_cull_mask = 1
	for n in ["YSort/Zones", "AmbientFX", "CloudShadows", "PostProcess/Screen"]:
		var item := w.get_node_or_null(n) as CanvasItem
		if item != null:
			item.visibility_layer = HIDDEN
	for n in ["YSort", "YSort/Entities"]:
		(w.get_node(n) as CanvasItem).visibility_layer = HIDDEN | FX
	(w.get_node("CombatFeedback") as CanvasItem).visibility_layer = FX
	w.entities.child_entered_tree.connect(func(n): if n is CanvasItem: n.visibility_layer = FX)
	for n in w.entities.get_children():
		if n is CanvasItem:
			n.visibility_layer = FX
	_fx_view = SubViewport.new()
	_fx_view.size = FX_SIZE
	_fx_view.transparent_bg = true
	_fx_view.world_2d = get_viewport().world_2d
	_fx_view.canvas_cull_mask = FX
	_fx_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_fx_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(_fx_view)
	_fx_plane = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(FX_SIZE) / T
	var fx_mat := StandardMaterial3D.new()
	fx_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fx_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fx_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	fx_mat.albedo_texture = _fx_view.get_texture()
	fx_mat.no_depth_test = false
	plane.material = fx_mat
	_fx_plane.mesh = plane
	_fx_plane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_fx_plane)
	var env_node := w.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if env_node != null:
		env_node.environment = _environment()
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -35.0, 0.0)
	sun.shadow_enabled = true
	sun.light_energy = 0.72
	sun.shadow_blur = 1.5
	sun.directional_shadow_max_distance = 60.0
	add_child(sun)
	cam = Camera3D.new()
	cam.fov = 32.0
	cam.far = 300.0
	var attrs := CameraAttributesPractical.new()
	attrs.dof_blur_far_enabled = true
	attrs.dof_blur_far_distance = 40.0
	attrs.dof_blur_far_transition = 14.0
	attrs.dof_blur_near_enabled = true
	attrs.dof_blur_near_distance = 16.0
	attrs.dof_blur_near_transition = 4.0
	attrs.dof_blur_amount = 0.035
	cam.attributes = attrs
	add_child(cam)
	cam.make_current()
	Events.zone_loaded.connect(func(_z, node): _build_zone.call_deferred(node))
	Events.zone_unloaded.connect(_drop_zone)
	for z in w.get_node("YSort/Zones").get_children():
		_build_zone(z)


func _environment() -> Environment:
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.55, 0.74, 0.92)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.9, 0.93, 1.0)
	e.ambient_light_energy = 0.38
	e.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	e.glow_enabled = true
	e.glow_intensity = 0.25
	e.glow_bloom = 0.0
	e.glow_hdr_threshold = 1.0
	e.ssao_enabled = true
	e.ssao_radius = 0.8
	e.ssao_intensity = 1.6
	e.fog_enabled = false
	e.fog_light_color = Color(0.72, 0.84, 0.95)
	e.fog_density = 0.004
	return e


func to3(p: Vector2, h: float = 0.0) -> Vector3:
	return Vector3(p.x / T, h, p.y / T)


func _process(_delta: float) -> void:
	if world == null:
		return
	var target := to3(world.camera.global_position)
	var a := deg_to_rad(pitch)
	cam.global_position = target + Vector3(0.0, sin(a), cos(a)) * distance
	cam.look_at(target + Vector3(0, 0.6, 0))
	var center: Vector2 = world.camera.global_position.round()
	_fx_view.canvas_transform = Transform2D(0.0, Vector2(FX_SIZE) / 2.0 - center)
	_fx_plane.position = to3(center, 0.06)
	var day := world.get_node_or_null("Daylight") as CanvasModulate
	if day != null:
		sun.light_color = day.color
	_sync()


# ---------------------------------------------------------------- terreno

func _drop_zone(z: ZoneEntry) -> void:
	if _zones.has(z.id):
		_zones[z.id].queue_free()
		_zones.erase(z.id)


func _build_zone(zone: Node) -> void:
	if not is_instance_valid(zone) or not (zone is Zone):
		return
	var id: String = zone.zone_id
	if _zones.has(id):
		_zones[id].queue_free()
	var tiles := {}  # celda -> [[textura, región, capa]...]
	var over := {}
	for li in LAYERS.size():
		var layer := zone.get_node_or_null(LAYERS[li]) as TileMapLayer
		if layer == null or layer.tile_set == null:
			continue
		for cell: Vector2i in layer.get_used_cells():
			var src := layer.tile_set.get_source(layer.get_cell_source_id(cell)) as TileSetAtlasSource
			if src == null:
				continue
			var region := src.get_tile_texture_region(layer.get_cell_atlas_coords(cell))
			if not tiles.has(cell):
				tiles[cell] = []
			tiles[cell].append([src.texture, region, li])
			if li == 3:
				over[cell] = true
	var tall := {}
	for cell: Vector2i in tiles:
		if over.has(cell) or MapRules.cell_physics(zone, cell) == MapRules.SOLID:
			tall[cell] = true
	# Tramos de celdas altas por columna, de norte a sur.
	var stand := {}  # celda -> [fila base, largo del tramo]
	for cell: Vector2i in tall:
		if tall.has(cell + Vector2i.UP):
			continue
		var y1 := cell.y
		while tall.has(Vector2i(cell.x, y1 + 1)):
			y1 += 1
		var n := y1 - cell.y + 1
		for y in range(cell.y, y1 + 1):
			if n > MAX_STAND:  # bosque: cada 2 filas, una lámina con su propia base
				stand[Vector2i(cell.x, y)] = [y1 - ((y1 - y) / CHUNK) * CHUNK, CHUNK]
			else:
				stand[Vector2i(cell.x, y)] = [y1, n]
	var tools := {}
	var count := {}
	var common: Array = []
	for cell: Vector2i in tiles:
		if stand.has(cell) or tiles[cell][0][2] != 0:
			continue
		var k0: Array = [tiles[cell][0][0], tiles[cell][0][1]]
		count[k0] = int(count.get(k0, 0)) + 1
		if common.is_empty() or count[k0] > count[common]:
			common = k0
	for cell: Vector2i in tiles:
		for t in tiles[cell]:
			var tex: Texture2D = t[0]
			if not tools.has(tex):
				var nst := SurfaceTool.new()
				nst.begin(Mesh.PRIMITIVE_TRIANGLES)
				tools[tex] = nst
			var st: SurfaceTool = tools[tex]
			var e: float = t[2] * 0.006
			var x := float(cell.x)
			var y := float(cell.y)
			if not stand.has(cell) and t[2] == 2:
				_quad(st, tex, t[1], Vector3(x, e, y), Vector3(x + 1, e, y), Vector3(x + 1, e, y + 1), Vector3(x, e, y + 1))
				_quad(st, tex, t[1], Vector3(x, 0.5, y + 0.6), Vector3(x + 1, 0.5, y + 0.6), Vector3(x + 1, 0, y + 0.8), Vector3(x, 0, y + 0.8))
			elif not stand.has(cell):
				var h: float = e - (0.12 if t[2] == 1 else 0.0)
				_quad(st, tex, t[1], Vector3(x, h, y), Vector3(x + 1, h, y), Vector3(x + 1, h, y + 1), Vector3(x, h, y + 1))
			elif stand[cell][1] > MAX_STAND:
				var h: float = PLATEAU + e
				_quad(st, tex, t[1], Vector3(x, h, y), Vector3(x + 1, h, y), Vector3(x + 1, h, y + 1), Vector3(x, h, y + 1))
				if not tall.has(cell + Vector2i.DOWN):  # la cara sur de la meseta
					_quad(st, tex, t[1], Vector3(x, h, y + 1), Vector3(x + 1, h, y + 1), Vector3(x + 1, 0, y + 1 + e), Vector3(x, 0, y + 1 + e))
			else:
				var base: float = stand[cell][0] + 1.0
				var k: float = stand[cell][0] - cell.y
				var z0 := base - k * LEAN + e
				var z1 := base - (k + 1.0) * LEAN + e
				_quad(st, tex, t[1], Vector3(x, k + 1.0, z1), Vector3(x + 1, k + 1.0, z1), Vector3(x + 1, k, z0), Vector3(x, k, z0))
				if t[2] == 0 and not common.is_empty():  # debajo, el suelo más común de la zona
					var ct: Texture2D = common[0]
					if not tools.has(ct):
						var cst := SurfaceTool.new()
						cst.begin(Mesh.PRIMITIVE_TRIANGLES)
						tools[ct] = cst
					_quad(tools[ct], ct, common[1], Vector3(x, -0.01, y), Vector3(x + 1, -0.01, y), Vector3(x + 1, -0.01, y + 1), Vector3(x, -0.01, y + 1))
	var root := Node3D.new()
	root.name = id
	root.position = to3(zone.global_position)
	var mesh := ArrayMesh.new()
	for tex: Texture2D in tools:
		var st: SurfaceTool = tools[tex]
		st.generate_normals()
		st.set_material(_material(tex))
		st.commit(mesh)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	root.add_child(mi)
	add_child(root)
	_zones[id] = root


func _quad(st: SurfaceTool, tex: Texture2D, region: Rect2, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	var size := Vector2(tex.get_size())
	var r := region.grow(-0.02)
	var u0 := r.position / size
	var u1 := r.end / size
	var uvs := [u0, Vector2(u1.x, u0.y), u1, Vector2(u0.x, u1.y)]
	var vs := [a, b, c, d]
	for i in [0, 1, 2, 0, 2, 3]:
		st.set_uv(uvs[i])
		st.add_vertex(vs[i])


func _material(tex: Texture2D) -> StandardMaterial3D:
	if not _materials.has(tex):
		var m := StandardMaterial3D.new()
		m.albedo_texture = tex
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		m.alpha_scissor_threshold = 0.5
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.roughness = 1.0
		_materials[tex] = m
	return _materials[tex]


# ---------------------------------------------------------------- personas, Pokémon, disparos

func _sync() -> void:
	var seen := {}
	var nodes: Array = world.entities.get_children()
	for z in world.get_node("YSort/Zones").get_children():
		var objs := z.get_node_or_null("Objects")
		if objs != null:
			nodes.append_array(objs.get_children())
	for n in nodes:
		var n2 := n as Node2D
		if n2 == null:
			continue
		var key := n2.get_instance_id()
		var m: Node3D = _mirrors.get(key)
		if m == null:
			m = _make_mirror(n2)
			if m == null:
				continue
			add_child(m)
			_mirrors[key] = m
		seen[key] = true
		n2.visibility_layer = HIDDEN
		_update_mirror(n2, m)
	for key in _mirrors.keys():
		if not seen.has(key):
			_mirrors[key].queue_free()
			_mirrors.erase(key)


func _creature_sprite(n: Node) -> CreatureSprite:
	for c in n.get_children():
		if c is CreatureSprite:
			return c
	return null


func _make_mirror(n: Node2D) -> Node3D:
	if n is Projectile:
		var mi := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = maxf(n.radius, 2.0) / T
		s.height = s.radius * 2.0
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = n.color * 2.5
		s.material = mat
		mi.mesh = s
		var light := OmniLight3D.new()
		light.light_color = n.color
		light.omni_range = 3.0
		light.light_energy = 1.5
		mi.add_child(light)
		return mi
	if _creature_sprite(n) == null and not (n.get_node_or_null("Sprite") is Sprite2D):
		return null
	var sp := Sprite3D.new()
	sp.pixel_size = 1.0 / T
	sp.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sp.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sp.shaded = true
	sp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return sp


func _update_mirror(n: Node2D, m: Node3D) -> void:
	if n is Projectile:
		m.position = to3(n.global_position, 0.6)
		return
	var sp := m as Sprite3D
	var cs := _creature_sprite(n)
	if cs != null:
		var cur := cs._current()
		if cur.is_empty() or cur[0] == null:
			sp.visible = false
			return
		var at := sp.texture as AtlasTexture
		if at == null:
			at = AtlasTexture.new()
			sp.texture = at
		at.atlas = cur[0]
		at.region = cur[1]
		var dst: Rect2 = cur[2]
		sp.centered = false
		sp.offset = Vector2(dst.position.x, -dst.end.y)
		sp.flip_h = cur[3]
		sp.visible = n.visible and cs.visible
		sp.position = to3(n.global_position, cs.lift / T)
		return
	var s2 := n.get_node("Sprite") as Sprite2D
	sp.texture = s2.texture
	sp.hframes = s2.hframes
	sp.vframes = s2.vframes
	sp.frame = s2.frame
	sp.flip_h = s2.flip_h
	sp.centered = s2.centered
	sp.region_enabled = s2.region_enabled
	sp.region_rect = s2.region_rect
	var fh := 0.0
	if s2.texture != null:
		fh = (s2.region_rect.size.y if s2.region_enabled else float(s2.texture.get_height())) / s2.vframes
	# Sprite2D centrado: su centro en offset; en 3D la Y va para arriba.
	if s2.centered:
		sp.offset = Vector2(s2.offset.x + s2.position.x, -(s2.offset.y + s2.position.y))
	else:
		sp.offset = Vector2(s2.offset.x, -(s2.offset.y + fh))
	sp.visible = n.visible and s2.visible
	sp.position = to3(n.global_position)
