extends Node3D
## PRUEBA 3D (rama mundo3d): una zona del juego construida en 3D desde su plano (`data/plan3d/<zona>.json`, que sale
## del mapa 2D con `tools/export_plan3d.gd`): terreno, agua, bosque, casas, cercos, carteles y flores, con colisión
## (la misma del mapa 2D, celda por celda) y cámara en tercera persona que no atraviesa nada.
## Correr: Godot --path . res://scenes/proto3d/town3d.tscn [-- --zone pueblo_paleta] [--demo]
## Teclas: WASD mover, mouse girar la cámara, Shift correr, Esc soltar el mouse.

const MODELS := "res://models3d/"
## Metros por celda del mapa.
const CELL := 1.5
## Hasta cuántas celdas adentro del bosque se plantan árboles (más adentro no se ve).
const FOREST_DEPTH := 5
const WALL_H := 5.0

var plan: Dictionary
var w := 0
var h := 0
var player: CharacterBody3D
var body: Node3D
var arm: SpringArm3D
var cam: Camera3D
var cam_yaw := 0.0
var cam_pitch := -0.22
var facing := 0.0
var demo := false
var _phase := 0.0
var _route: Array = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	demo = "--demo" in args
	var zone := "pueblo_paleta"
	if args.has("--zone") and args.find("--zone") + 1 < args.size():
		zone = args[args.find("--zone") + 1]
	plan = JSON.parse_string(FileAccess.get_file_as_string("res://data/plan3d/%s.json" % zone))
	w = int(plan["w"])
	h = int(plan["h"])
	_rng.seed = 11
	_environment()
	_ground()
	_collision()
	_forest()
	_fences()
	_buildings()
	_small_things()
	_player()
	if not demo:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ---------------------------------------------------------------- plano

func kind(x: int, y: int) -> String:
	if x < 0 or y < 0 or x >= w or y >= h:
		return "T"
	return (plan["cells"][y] as String)[x]


func solid(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= w or y >= h:
		return true
	return (plan["solid"][y] as String)[x] != "0"


func is_fence(x: int, y: int) -> bool:
	## Una tira de "árbol" de una sola celda de espesor es una cerca, no bosque.
	return kind(x, y) == "T" and ((kind(x, y - 1) != "T" and kind(x, y + 1) != "T") or (kind(x - 1, y) != "T" and kind(x + 1, y) != "T"))


func is_forest(x: int, y: int) -> bool:
	return kind(x, y) == "T" and not is_fence(x, y)


func at(x: float, y: float, height: float = 0.0) -> Vector3:
	## Centro de la celda (x, y) en metros.
	return Vector3((x + 0.5) * CELL, height, (y + 0.5) * CELL)


# ---------------------------------------------------------------- ambiente

func _environment() -> void:
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.22, 0.48, 0.9)
	sky_mat.sky_horizon_color = Color(0.7, 0.84, 0.96)
	sky_mat.ground_horizon_color = Color(0.7, 0.84, 0.96)
	sky_mat.ground_bottom_color = Color(0.35, 0.5, 0.35)
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.6
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.ssao_enabled = true
	e.ssao_radius = 1.2
	e.ssao_intensity = 2.0
	e.glow_enabled = true
	e.glow_intensity = 0.15
	e.fog_enabled = true
	e.fog_light_color = Color(0.74, 0.86, 0.96)
	e.fog_density = 0.004
	e.fog_sky_affect = 0.0
	var we := WorldEnvironment.new()
	we.environment = e
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-44, -38, 0)
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	sun.shadow_blur = 1.2
	sun.directional_shadow_max_distance = 90.0
	add_child(sun)


# ---------------------------------------------------------------- suelo y agua

func _ground() -> void:
	# Mapa de qué hay en cada celda (R camino, G agua, B piso de bosque), un píxel por celda; el shader lo suaviza.
	var img := Image.create(w, h, false, Image.FORMAT_RGB8)
	for y in h:
		for x in w:
			var k := kind(x, y)
			img.set_pixel(x, y, Color(1.0 if k in ["p", "s"] else 0.0, 1.0 if k == "w" else 0.0, 1.0 if is_forest(x, y) else 0.0))
	var tex := ImageTexture.create_from_image(img)
	var size := Vector2(w, h) * CELL
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = size
	pm.subdivide_width = 1
	var mat := ShaderMaterial.new()
	mat.shader = load("res://scripts/proto3d/town_ground.gdshader")
	mat.set_shader_parameter("kinds", tex)
	mat.set_shader_parameter("map_size", size)
	pm.material = mat
	ground.mesh = pm
	ground.position = Vector3(size.x / 2.0, 0, size.y / 2.0)
	add_child(ground)
	var bed := MeshInstance3D.new()
	var bm := PlaneMesh.new()
	bm.size = size
	var bmat := StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.5, 0.36)
	bm.material = bmat
	bed.mesh = bm
	bed.position = Vector3(size.x / 2.0, -0.7, size.y / 2.0)
	add_child(bed)
	var water := MeshInstance3D.new()
	var wm := PlaneMesh.new()
	wm.size = size
	var wmat := ShaderMaterial.new()
	wmat.shader = load("res://scripts/proto3d/town_water.gdshader")
	wm.material = wmat
	water.mesh = wm
	water.position = Vector3(size.x / 2.0, -0.22, size.y / 2.0)
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(water)


# ---------------------------------------------------------------- colisión

func _collision() -> void:
	## La colisión del mapa 2D, tal cual: cada tira de celdas sólidas de una fila es una caja.
	var sb := StaticBody3D.new()
	sb.name = "Walls"
	add_child(sb)
	for y in range(-1, h + 1):
		var x := -1
		while x <= w:
			if not solid(x, y):
				x += 1
				continue
			var x0 := x
			while x <= w and solid(x, y):
				x += 1
			var cs := CollisionShape3D.new()
			var box := BoxShape3D.new()
			box.size = Vector3((x - x0) * CELL, WALL_H, CELL)
			cs.shape = box
			cs.position = Vector3((x0 + x) / 2.0 * CELL, WALL_H / 2.0 - 0.5, (y + 0.5) * CELL)
			sb.add_child(cs)
	var floor_cs := CollisionShape3D.new()
	var plane := WorldBoundaryShape3D.new()
	floor_cs.shape = plane
	sb.add_child(floor_cs)


# ---------------------------------------------------------------- modelos

func _mesh_of(model_name: String) -> Array:
	## [malla, transformación que la deja con la base en el origen, centrada y de 1 de alto] del modelo, o [].
	var path := MODELS + model_name + ".glb"
	if not ResourceLoader.exists(path):
		return []
	var inst: Node3D = (load(path) as PackedScene).instantiate()
	var mi: MeshInstance3D = null
	for m in inst.find_children("*", "MeshInstance3D", true, false):
		mi = m
		break
	if mi == null:
		inst.free()
		return []
	var xf := Transform3D.IDENTITY
	var n: Node = mi
	while n != null and n is Node3D:
		xf = (n as Node3D).transform * xf
		n = n.get_parent()
	var box: AABB = xf * mi.mesh.get_aabb()
	var mesh := mi.mesh
	inst.free()
	var k := 1.0 / box.size.y
	var c := box.get_center()
	var norm := Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * k), Vector3(-c.x, -box.position.y, -c.z) * k) * xf
	return [mesh, norm, box.size * k]


func _place(model_name: String, pos: Vector3, height: float, yaw: float = 0.0, stretch: Vector3 = Vector3.ONE) -> void:
	var m := _mesh_of(model_name)
	var mi := MeshInstance3D.new()
	if m.is_empty():
		var bm := BoxMesh.new()
		bm.size = Vector3(height * 0.8, height, height * 0.8)
		mi.mesh = bm
		mi.position = pos + Vector3(0, height / 2.0, 0)
	else:
		mi.mesh = m[0]
		mi.transform = Transform3D(Basis(Vector3.UP, yaw).scaled(stretch * height), pos) * (m[1] as Transform3D)
	add_child(mi)


func _forest() -> void:
	var m := _mesh_of("arbol")
	if m.is_empty():
		return
	# distancia de cada celda de bosque al claro más cercano
	var spots: Array = []
	for y in range(0, h, 2):
		for x in range(0, w, 2):
			if not (is_forest(x, y) or is_forest(x + 1, y) or is_forest(x, y + 1) or is_forest(x + 1, y + 1)):
				continue
			var near := false
			for dy in range(-FOREST_DEPTH, FOREST_DEPTH + 2):
				for dx in range(-FOREST_DEPTH, FOREST_DEPTH + 2):
					if not near and kind(x + dx, y + dy) != "T":
						near = true
			if near and is_forest(x, y) and is_forest(x + 1, y + 1):
				spots.append(Vector2(x + 1.0, y + 1.0))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = m[0]
	mm.instance_count = spots.size()
	for i in spots.size():
		var s: Vector2 = spots[i]
		var height := _rng.randf_range(5.2, 7.2)
		var pos := Vector3(s.x * CELL + _rng.randf_range(-0.35, 0.35), 0, s.y * CELL + _rng.randf_range(-0.35, 0.35))
		var basis := Basis(Vector3.UP, _rng.randf_range(0, TAU)).scaled(Vector3.ONE * height)
		mm.set_instance_transform(i, Transform3D(basis, pos) * (m[1] as Transform3D))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	add_child(mmi)
	print("arboles: ", spots.size())


func _box(size: Vector3, pos: Vector3, color: Color, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	bm.material = mat
	mi.mesh = bm
	mi.position = pos
	(parent if parent != null else self).add_child(mi)
	return mi


func _fences() -> void:
	var white := Color(0.93, 0.92, 0.88)
	for y in h:
		for x in w:
			if not is_fence(x, y):
				continue
			var c := at(x, y)
			var along_x := kind(x - 1, y) == "T" or kind(x + 1, y) == "T" or not (kind(x, y - 1) == "T" or kind(x, y + 1) == "T")
			var rail := Vector3(CELL, 0.09, 0.07) if along_x else Vector3(0.07, 0.09, CELL)
			_box(rail, c + Vector3(0, 0.75, 0), white)
			_box(rail, c + Vector3(0, 0.4, 0), white)
			for k in [-0.5, 0.0]:
				var off := Vector3(k * CELL, 0, 0) if along_x else Vector3(0, 0, k * CELL)
				_box(Vector3(0.14, 1.0, 0.14), c + off + Vector3(0, 0.5, 0), white)


func _buildings() -> void:
	var done := {}
	for y in h:
		for x in w:
			if kind(x, y) != "B" or done.has(Vector2i(x, y)):
				continue
			# el rectángulo del edificio
			var x1 := x
			while kind(x1 + 1, y) == "B":
				x1 += 1
			var y1 := y
			while kind(x, y1 + 1) == "B":
				y1 += 1
			for yy in range(y, y1 + 1):
				for xx in range(x, x1 + 1):
					done[Vector2i(xx, yy)] = true
			var model := "casa"
			for wp in plan["warps"]:
				if int(wp["x"]) >= x and int(wp["x"]) <= x1 and int(wp["y"]) >= y - 1 and int(wp["y"]) <= y1 + 1 and "laboratorio" in str(wp["to"]):
					model = "laboratorio"
			var bw := (x1 - x + 1) * CELL
			var bd := (y1 - y + 1) * CELL
			var m := _mesh_of(model)
			# apoyado en el frente (sur) de su rectángulo, del ancho del rectángulo
			var height := 6.5
			var stretch := Vector3.ONE
			if not m.is_empty():
				var size: Vector3 = m[2]
				height = bw * 0.96 / size.x
				var depth := size.z * height
				var want_depth := minf(depth, bd * 0.98)
				stretch = Vector3(1, 1, want_depth / depth)
				_place(model, Vector3((x + x1 + 1) / 2.0 * CELL, 0, (y1 + 1) * CELL - want_depth / 2.0 - 0.05), height, 0.0, stretch)
			else:
				_place(model, Vector3((x + x1 + 1) / 2.0 * CELL, 0, (y + y1 + 1) / 2.0 * CELL), height)


func _small_things() -> void:
	var wood := Color(0.62, 0.44, 0.26)
	var petals := [Color(0.93, 0.25, 0.25), Color(0.98, 0.85, 0.3), Color(0.96, 0.96, 0.98), Color(0.95, 0.5, 0.75)]
	for y in h:
		for x in w:
			var k := kind(x, y)
			var c := at(x, y)
			if k in ["A", "S"]:  # cartel de madera
				_box(Vector3(0.12, 0.9, 0.12), c + Vector3(0, 0.45, 0), wood.darkened(0.2))
				_box(Vector3(1.0, 0.6, 0.1), c + Vector3(0, 1.05, 0), wood)
				_box(Vector3(0.8, 0.4, 0.02), c + Vector3(0, 1.05, 0.06), Color(0.93, 0.88, 0.72))
			elif k == "f":  # flores
				for i in 5:
					var p := c + Vector3(_rng.randf_range(-0.6, 0.6), 0, _rng.randf_range(-0.6, 0.6))
					var hh := _rng.randf_range(0.22, 0.38)
					_box(Vector3(0.04, hh, 0.04), p + Vector3(0, hh / 2.0, 0), Color(0.25, 0.55, 0.2))
					var ball := MeshInstance3D.new()
					var sm := SphereMesh.new()
					sm.radius = 0.1
					sm.height = 0.14
					sm.radial_segments = 8
					sm.rings = 4
					var mat := StandardMaterial3D.new()
					mat.albedo_color = petals[_rng.randi() % petals.size()]
					sm.material = mat
					ball.mesh = sm
					ball.position = p + Vector3(0, hh + 0.04, 0)
					add_child(ball)


# ---------------------------------------------------------------- jugador y cámara

func _player() -> void:
	player = CharacterBody3D.new()
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.38
	cap.height = 1.0
	cs.shape = cap
	cs.position.y = 0.5
	player.add_child(cs)
	body = Node3D.new()
	player.add_child(body)
	var m := _mesh_of("bulbasaur")
	if not m.is_empty():
		var mi := MeshInstance3D.new()
		mi.mesh = m[0]
		mi.transform = Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * 1.0), Vector3.ZERO) * (m[1] as Transform3D)
		body.add_child(mi)
	# arranca en la primera celda libre cerca del centro
	var start := Vector2i(w / 2, h / 2)
	for r in 20:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if solid(start.x, start.y) and not solid(w / 2 + dx, h / 2 + dy):
					start = Vector2i(w / 2 + dx, h / 2 + dy)
	player.position = at(start.x, start.y)
	add_child(player)
	arm = SpringArm3D.new()
	arm.spring_length = 4.4
	arm.margin = 0.3
	var sphere := SphereShape3D.new()
	sphere.radius = 0.25
	arm.shape = sphere
	arm.add_excluded_object(player.get_rid())
	add_child(arm)
	cam = Camera3D.new()
	cam.fov = 58.0
	arm.add_child(cam)
	cam.make_current()
	if demo:
		# recorrido por el pueblo (celdas): las dos casas, el laboratorio, las flores y el estanque
		for c in [Vector2(52, 20), Vector2(46, 9), Vector2(44.5, 8.4), Vector2(56, 9), Vector2(65, 8.6), Vector2(62, 14.5), Vector2(66, 14.4), Vector2(56, 21), Vector2(47, 27.5), Vector2(49, 30), Vector2(56, 29)]:
			_route.append(at(c.x - 0.5, c.y - 0.5))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cam_yaw -= event.relative.x * 0.004
		cam_pitch = clampf(cam_pitch - event.relative.y * 0.003, -1.0, 0.25)
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	var wish := Vector3.ZERO
	var speed := 4.0
	if demo:
		if not _route.is_empty():
			var d: Vector3 = _route[0] - player.global_position
			d.y = 0.0
			if d.length() < 0.5:
				_route.pop_front()
			else:
				wish = d.normalized()
		cam_yaw = lerp_angle(cam_yaw, facing + PI, clampf(delta * 1.6, 0.0, 1.0))
	else:
		var ix := float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
		var iz := float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
		wish = Vector3(ix, 0, iz).limit_length(1.0).rotated(Vector3.UP, cam_yaw)
		if Input.is_physical_key_pressed(KEY_SHIFT):
			speed = 7.0
	player.velocity = player.velocity.lerp(wish * speed, clampf(delta * 12.0, 0.0, 1.0))
	player.velocity.y = 0.0
	player.move_and_slide()
	player.position.y = 0.0
	var flat := Vector2(player.velocity.x, player.velocity.z)
	var moving := flat.length() > 0.4
	if moving:
		facing = lerp_angle(facing, atan2(player.velocity.x, player.velocity.z), clampf(delta * 10.0, 0.0, 1.0))
	body.rotation.y = facing
	# animación por código: saltito al caminar, respiración parado
	_phase += delta * (flat.length() * 2.6 if moving else 2.2)
	var s := absf(sin(_phase)) if moving else 0.0
	var breath := 0.0 if moving else sin(_phase) * 0.025
	body.position.y = lerpf(body.position.y, s * 0.2, clampf(delta * 22.0, 0.0, 1.0))
	body.scale = body.scale.lerp(Vector3(1.0 - s * 0.06 - breath, 0.9 + s * 0.16 + breath if moving else 1.0 + breath, 1.0 - s * 0.06 - breath), clampf(delta * 18.0, 0.0, 1.0))
	body.rotation.z = sin(_phase) * 0.07 if moving else lerpf(body.rotation.z, 0.0, delta * 8.0)
	arm.global_position = player.global_position + Vector3(0, 1.25, 0)
	arm.rotation = Vector3(cam_pitch, cam_yaw, 0)
