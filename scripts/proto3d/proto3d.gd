extends Node3D
## PRUEBA 3D de verdad (rama mundo3d): una escena chica con modelos hechos con IA (Qwen → TRELLIS.2 → Blender) para
## medir el pipeline: una casa, un árbol y Bulbasaur. Bulbasaur no tiene esqueleto: se anima por código (salto al
## caminar, estirarse y aplastarse, inclinarse, embestida al atacar). No toca el juego.
## Correr: Godot --path . res://scenes/proto3d/proto3d.tscn   (`-- --demo` = se mueve solo, para grabar)

const MODELS := "res://models3d/"
## Hacia dónde mira cada modelo tal como sale del generador (grados a girar para que mire a -Z).
const YAW := {"bulbasaur": 0.0, "casa": 0.0, "arbol": 0.0}

var player: Critter
var foes: Array[Critter] = []
var cam: Camera3D
var demo := false
var _t := 0.0
var cam_yaw := PI


class Critter extends Node3D:
	var body: Node3D          # el modelo; se deforma sin tocar la posición real
	var velocity := Vector3.ZERO
	var facing := 0.0
	var speed := 4.2
	var _phase := 0.0
	var _attack := -1.0       # tiempo dentro de la embestida (-1 = no ataca)
	var _attack_dir := Vector3.FORWARD
	var _hurt := 0.0
	var _knock := Vector3.ZERO
	var wander_t := 0.0
	var wander_dir := Vector3.ZERO
	const ATTACK_TIME := 0.42

	func attacking() -> bool:
		return _attack >= 0.0

	func attack() -> void:
		if _attack < 0.0 and _hurt <= 0.0:
			_attack = 0.0
			_attack_dir = Vector3(sin(facing), 0, cos(facing))

	func hurt(from: Vector3) -> void:
		_hurt = 0.35
		_knock = (global_position - from).normalized() * 7.0
		_knock.y = 0.0

	func tick(delta: float, wish: Vector3) -> void:
		var move := wish * speed
		if _attack >= 0.0:
			_attack += delta
			var k := _attack / ATTACK_TIME
			# toma carrera (se encoge), sale disparado (se estira) y frena
			move = _attack_dir * (-2.0 if k < 0.25 else (13.0 if k < 0.6 else 1.0))
			if _attack >= ATTACK_TIME:
				_attack = -1.0
		if _hurt > 0.0:
			_hurt -= delta
			move = _knock
			_knock = _knock.lerp(Vector3.ZERO, delta * 9.0)
		velocity = velocity.lerp(move, clampf(delta * 12.0, 0.0, 1.0))
		global_position += velocity * delta
		var flat := Vector2(velocity.x, velocity.z)
		var moving := flat.length() > 0.4
		if moving and _attack < 0.0 and _hurt <= 0.0:
			facing = lerp_angle(facing, atan2(velocity.x, velocity.z), clampf(delta * 10.0, 0.0, 1.0))
		rotation.y = facing
		# --- animación por código
		var hop := 0.0
		var sq := Vector3.ONE
		var lean := 0.0
		if _attack >= 0.0:
			var k := _attack / ATTACK_TIME
			if k < 0.25:
				sq = Vector3(1.12, 0.8, 0.9)
				lean = -0.25
			elif k < 0.6:
				sq = Vector3(0.88, 0.92, 1.3)
				lean = 0.35
				hop = 0.25
			else:
				sq = Vector3(1.08, 0.9, 0.95)
		elif _hurt > 0.0:
			var w := sin(_hurt * 60.0) * 0.12
			sq = Vector3(1.15 + w, 0.8, 1.15 - w)
			lean = -0.3
		elif moving:
			_phase += delta * flat.length() * 2.6
			var s := absf(sin(_phase))
			hop = s * 0.22
			sq = Vector3(1.0 - s * 0.06, 0.9 + s * 0.16, 1.0 - s * 0.06)
			lean = 0.12
			body.rotation.z = sin(_phase) * 0.07
		else:
			_phase += delta * 2.2
			var b := sin(_phase) * 0.025
			sq = Vector3(1.0 - b, 1.0 + b, 1.0 - b)
			body.rotation.z = lerpf(body.rotation.z, 0.0, delta * 8.0)
		body.position.y = lerpf(body.position.y, hop, clampf(delta * 22.0, 0.0, 1.0))
		body.scale = body.scale.lerp(sq, clampf(delta * 18.0, 0.0, 1.0))
		body.rotation.x = lerpf(body.rotation.x, lean, clampf(delta * 14.0, 0.0, 1.0))


func _ready() -> void:
	demo = "--demo" in OS.get_cmdline_user_args()
	_environment()
	_ground()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for p in [Vector3(-7, 0, -9), Vector3(6, 0, -11), Vector3(15, 0, -3)]:
		_prop("casa", p, 6.0, rng.randf_range(-0.25, 0.25))
	for i in 46:
		var p := Vector3(rng.randf_range(-30, 30), 0, rng.randf_range(-30, 22))
		if absf(p.x) < 4.0 and p.z > -8.0 or (p.distance_to(Vector3(-7, 0, -9)) < 6.0 or p.distance_to(Vector3(6, 0, -11)) < 6.0 or p.distance_to(Vector3(15, 0, -3)) < 6.0):
			continue
		_prop("arbol", p, rng.randf_range(4.2, 6.2), rng.randf_range(0, TAU))
	player = _critter(Vector3(0, 0, 3), 1.25)
	player.facing = PI
	for p in [Vector3(4.5, 0, -1), Vector3(-5, 0, 0.5)]:
		foes.append(_critter(p, 1.1))
	cam = Camera3D.new()
	cam.fov = 55.0
	var attrs := CameraAttributesPractical.new()
	attrs.dof_blur_far_enabled = true
	attrs.dof_blur_far_distance = 30.0
	attrs.dof_blur_far_transition = 25.0
	attrs.dof_blur_amount = 0.05
	cam.attributes = attrs
	add_child(cam)
	cam.make_current()
	_place_camera(1.0)


func _environment() -> void:
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.25, 0.5, 0.9)
	sky_mat.sky_horizon_color = Color(0.72, 0.85, 0.96)
	sky_mat.ground_horizon_color = Color(0.72, 0.85, 0.96)
	sky_mat.ground_bottom_color = Color(0.4, 0.55, 0.4)
	var sky := Sky.new()
	sky.sky_material = sky_mat
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.6
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.0
	e.ssao_enabled = true
	e.ssao_radius = 1.2
	e.ssao_intensity = 2.0
	e.glow_enabled = true
	e.glow_intensity = 0.15
	e.fog_enabled = true
	e.fog_light_color = Color(0.75, 0.86, 0.96)
	e.fog_density = 0.002
	e.fog_sky_affect = 0.0
	var we := WorldEnvironment.new()
	we.environment = e
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -40, 0)
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	sun.shadow_blur = 1.2
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)


func _ground() -> void:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(160, 160)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://scripts/proto3d/ground.gdshader")
	pm.material = mat
	mi.mesh = pm
	add_child(mi)


func _model(model_name: String, height: float) -> Node3D:
	## El modelo importado, escalado a `height` de alto, con los pies en el origen y mirando a -Z.
	var holder := Node3D.new()
	var path := MODELS + model_name + ".glb"
	if not ResourceLoader.exists(path):
		var box := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(height * 0.6, height, height * 0.6)
		box.mesh = bm
		box.position.y = height / 2.0
		holder.add_child(box)
		return holder
	var inst: Node3D = (load(path) as PackedScene).instantiate()
	holder.add_child(inst)
	inst.rotation_degrees.y = YAW.get(model_name, 0.0)
	var box := AABB()
	var first := true
	for m in inst.find_children("*", "MeshInstance3D", true, false):
		var mm := m as MeshInstance3D
		var b: AABB = _global_of(mm, inst) * mm.get_aabb()
		box = b if first else box.merge(b)
		first = false
	if first or box.size.y <= 0.0:
		return holder
	var k := height / box.size.y
	inst.scale *= k
	var c := box.get_center() * k
	inst.position -= Vector3(c.x, box.position.y * k, c.z)
	return holder


func _global_of(n: Node3D, root: Node3D) -> Transform3D:
	var t := n.transform
	var p := n.get_parent()
	while p != null and p != root.get_parent():
		if p is Node3D:
			t = (p as Node3D).transform * t
		p = p.get_parent()
	return t


func _prop(model_name: String, at: Vector3, height: float, yaw: float) -> void:
	var m := _model(model_name, height)
	m.position = at
	m.rotation.y = yaw
	add_child(m)


func _critter(at: Vector3, height: float) -> Critter:
	var c := Critter.new()
	c.body = _model("bulbasaur", height)
	c.add_child(c.body)
	c.position = at
	add_child(c)
	return c


## Tercera persona: la cámara va detrás del Pokémon, cerca del piso, y gira despacio hacia donde él mira.
func _place_camera(k: float) -> void:
	cam_yaw = lerp_angle(cam_yaw, player.facing, clampf(k * 0.25, 0.0, 1.0) if k < 1.0 else 1.0)
	var back := Vector3(sin(cam_yaw), 0, cos(cam_yaw))
	var want := player.global_position - back * 4.6 + Vector3(0, 1.9, 0)
	cam.global_position = cam.global_position.lerp(want, k)
	cam.look_at(player.global_position + back * 2.0 + Vector3(0, 0.9, 0))


func _process(delta: float) -> void:
	_t += delta
	var wish := Vector3.ZERO
	if demo:
		# recorrido fijo: camina en círculo y cada tanto embiste al rival más cercano
		var a := _t * 0.7
		wish = Vector3(cos(a), 0, -sin(a))
		if fmod(_t, 2.6) > 2.2:
			var near := foes[0]
			for f in foes:
				if f.global_position.distance_to(player.global_position) < near.global_position.distance_to(player.global_position):
					near = f
			var d := near.global_position - player.global_position
			player.facing = atan2(d.x, d.z)
			player.attack()
	else:
		wish.x = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
		wish.z = float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
		if Input.is_physical_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			player.attack()
	if not demo:
		wish = wish.rotated(Vector3.UP, cam_yaw + PI)
	player.tick(delta, wish.limit_length(1.0))
	for f in foes:
		f.wander_t -= delta
		if f.wander_t <= 0.0:
			f.wander_t = randf_range(1.0, 2.6)
			f.wander_dir = Vector3.ZERO if randf() < 0.4 else Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * 0.45
		f.tick(delta, f.wander_dir)
		if player.attacking() and f._hurt <= 0.0 and f.global_position.distance_to(player.global_position) < 1.3:
			f.hurt(player.global_position)
	_place_camera(clampf(delta * 6.0, 0.0, 1.0))
