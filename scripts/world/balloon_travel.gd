class_name BalloonTravel
extends Node
## Globos aerostáticos entre ciudades (pedido del usuario 2026-10-29): en cada ciudad hay un globo (ExtraBuilding
## "globo_<ciudad>" sin puerta, de tools/build_balloons.py) y su piloto (NpcData con la acción "globo"). Hablándole
## elegís una ciudad que ya visitaste (en el modo libre, cualquiera) y el globo sube y vuela por encima de las rutas
## hasta allá, con la cámara siguiéndolo. Gratis. E o Esc lo saltean (llegás directo). Nodo del mundo (world.balloon).

const PREFIX := "globo_"
## Altura del vuelo (px), cuánto tarda en subir y en bajar (s), y la velocidad sobre el mapa (px/s; el viaje dura
## entre MIN_TIME y MAX_TIME).
const ALTITUDE := 72.0
const RISE_TIME := 1.6
const MIN_TIME := 6.0
const MAX_TIME := 18.0
const SPEED := 420.0
## Alto (px) del frente de la canasta en sprites/props/globo.png: se dibuja delante del entrenador.
const BASKET_FRONT := 11

var world: Node
var flying := false
var _skip := false


func _ready() -> void:
	world = get_parent()
	world.story.register_action("globo", _talk)


## Los globos de las ciudades (los edificios agregados "globo_<ciudad>").
static func balloons() -> Array[ExtraBuilding]:
	var out: Array[ExtraBuilding] = []
	for b in ExtraContent.buildings:
		if b.id.begins_with(PREFIX):
			out.append(b)
	return out


## Adónde puede ir desde `from_zone`: las ciudades con globo que ya visitaste (en el modo libre, todas).
static func destinations(from_zone: String) -> Array[ExtraBuilding]:
	var out: Array[ExtraBuilding] = []
	var free_mode := not GameState.has_flag("historia")
	for b in balloons():
		if b.zone_id != from_zone and (free_mode or GameState.visited_zones.has(b.zone_id)):
			out.append(b)
	return out


func _talk() -> void:
	var story: StoryDirector = world.story
	var data: WorldData = world.streamer.world_data
	var here: ZoneEntry = data.zone_at(world.trainer.global_position)
	var from: ExtraBuilding = null
	for b in balloons():
		if here != null and b.zone_id == here.id:
			from = b
	var dests := destinations(here.id if here != null else "")
	if from == null or dests.is_empty():
		await story._say("Piloto", PackedStringArray(["Cuando conozcas otras ciudades, te llevo volando. ¡Hay globos en todas!"]))
		return
	var names := PackedStringArray()
	for b in dests:
		names.append(_zone(data, b.zone_id).display_name)
	names.append("Ahora no")
	var pick: int = await story.dialog.ask("Piloto", "¡Subí! ¿A qué ciudad vamos? (el viaje es gratis)", names)
	if pick < 0 or pick >= dests.size():
		return
	await fly(from, dests[pick])


## El viaje: sube, vuela por encima de las rutas (zona por zona) y baja frente al globo de la otra ciudad.
func fly(from: ExtraBuilding, to: ExtraBuilding) -> void:
	flying = true
	_skip = false
	# Volando por arriba no se "visita" nada (bug del usuario 2026-10-29: pasar sobre una ciudad la desbloqueaba para el
	# globo y le sacaba la niebla en el Mapa): al bajar quedan las de antes + la de destino.
	var visited_before: Dictionary = GameState.visited_zones.duplicate()
	var data: WorldData = world.streamer.world_data
	var t: Trainer = world.trainer
	var start := ground_point(data, from)
	var end := ground_point(data, to)
	var curve := Curve2D.new()
	for p in route_points(data, from.zone_id, to.zone_id, start, end):
		curve.add_point(p)
	_smooth(curve)
	var length := curve.get_baked_length()
	var cruise := clampf(length / SPEED, MIN_TIME, MAX_TIME)
	# El globo que vuela (el de la ciudad se esconde mientras tanto) con el entrenador adentro.
	var parked := [_parked(from), _parked(to)]
	for n in parked:
		if n != null:
			n.visible = false
	var ship := _make_ship(from.texture, t)
	world.add_child(ship)
	ship.global_position = start
	t.locked = true
	t.autopilot = Vector2.ZERO
	t.visible = false
	if is_instance_valid(world.companion):
		world.companion.visible = false
	var body: Node2D = ship.get_node("Body")
	world.streamer.target = ship
	world.camera.target = body  # (la cámara va con el globo, no con su sombra)
	var shadow: Node2D = ship.get_node("Shadow")
	var time := 0.0
	var total := cruise + 2.0 * RISE_TIME
	while time < total and not _skip:
		await get_tree().process_frame
		time += get_process_delta_time()
		var up := clampf(minf(time, total - time) / RISE_TIME, 0.0, 1.0)
		var along := clampf((time - RISE_TIME) / cruise, 0.0, 1.0)
		along = along * along * (3.0 - 2.0 * along)  # arranca y frena suave
		ship.global_position = curve.sample_baked(along * length)
		var alt := ALTITUDE * (up * up * (3.0 - 2.0 * up)) + sin(time * 2.2) * 2.0 * up
		body.position.y = -alt
		shadow.scale = Vector2.ONE * (1.0 - 0.35 * up)
		shadow.modulate.a = 0.45 - 0.2 * up
		var dest := _parked(to)  # (la ciudad de destino se carga en el camino: su globo no se ve hasta bajar)
		if dest != null:
			dest.visible = false
		world.camera.snap()  # pegada: a esta velocidad, con su suavizado el globo se le escapa
	if _skip:
		await world.arena.fade_to(1.0)
	# Bajaste: frente al globo de la otra ciudad.
	var land := landing_point(data, to)
	world.streamer.load_around_now(land)
	GameState.visited_zones = visited_before
	GameState.visit_zone(to.zone_id)
	t.global_position = land
	var trail: Array[Vector2] = [land]
	t.trail = trail
	t.facing = Vector2.DOWN
	t.visible = true
	world.streamer.target = t
	world.camera.target = t
	world.camera.snap()
	ship.queue_free()
	for n in [_parked(from), _parked(to)]:
		if n != null:
			n.visible = true
	world.respawn_companion()
	if _skip:
		await world.arena.fade_to(0.0)
	flying = false
	Events.message_requested.emit("¡Llegaste a %s!" % _zone(data, to.zone_id).display_name)


func _input(event: InputEvent) -> void:
	if flying and (event.is_action_pressed("interact") or event.is_action_pressed("pause")):
		_skip = true
		get_viewport().set_input_as_handled()


## Punto del suelo debajo del globo (al medio de su base).
static func ground_point(data: WorldData, b: ExtraBuilding) -> Vector2:
	var z := _zone(data, b.zone_id)
	return Vector2((z.origin + b.cell) * data.tile_size) + Vector2(b.size.x * data.tile_size / 2.0, b.size.y * data.tile_size)


## Dónde quedás al bajar: la celda de abajo del globo, al medio.
static func landing_point(data: WorldData, b: ExtraBuilding) -> Vector2:
	var z := _zone(data, b.zone_id)
	var cell := z.origin + b.cell + Vector2i(b.size.x / 2, b.size.y)
	return Vector2(cell * data.tile_size) + Vector2.ONE * data.tile_size / 2.0


## El camino del vuelo: de zona exterior en zona exterior (las rutas), pasando por el medio de cada borde que comparten.
static func route_points(data: WorldData, from_zone: String, to_zone: String, start: Vector2, end: Vector2) -> Array[Vector2]:
	var ts := float(data.tile_size)
	var outdoor: Array[ZoneEntry] = []
	for z in data.zones:
		if not z.interior:
			outdoor.append(z)
	var prev := {from_zone: ""}
	var queue: Array[String] = [from_zone]
	var i := 0
	while i < queue.size():
		var id := queue[i]
		i += 1
		if id == to_zone:
			break
		var a := _zone(data, id)
		for b in outdoor:
			if not prev.has(b.id) and _border(a, b).size() > 0:
				prev[b.id] = id
				queue.append(b.id)
	var chain: Array[String] = []
	if prev.has(to_zone):
		var id := to_zone
		while id != "":
			chain.push_front(id)
			id = prev[id]
	var out: Array[Vector2] = [start]
	for k in range(chain.size() - 1):
		var seg := _border(_zone(data, chain[k]), _zone(data, chain[k + 1]))
		out.append((seg[0] + seg[1]) * 0.5 * ts)
	out.append(end)
	return out


## Borde que comparten dos zonas (extremos en celdas del mundo, al menos 2 celdas de largo) o [] si no se tocan.
static func _border(a: ZoneEntry, b: ZoneEntry) -> Array[Vector2]:
	var ra := Rect2i(a.origin, a.size)
	var rb := Rect2i(b.origin, b.size)
	var out: Array[Vector2] = []
	if ra.end.x == rb.position.x or rb.end.x == ra.position.x:
		var x := float(ra.end.x if ra.end.x == rb.position.x else ra.position.x)
		var y0 := maxi(ra.position.y, rb.position.y)
		var y1 := mini(ra.end.y, rb.end.y)
		if y1 - y0 >= 2:
			out = [Vector2(x, y0), Vector2(x, y1)]
	elif ra.end.y == rb.position.y or rb.end.y == ra.position.y:
		var y := float(ra.end.y if ra.end.y == rb.position.y else ra.position.y)
		var x0 := maxi(ra.position.x, rb.position.x)
		var x1 := mini(ra.end.x, rb.end.x)
		if x1 - x0 >= 2:
			out = [Vector2(x0, y), Vector2(x1, y)]
	return out


## Curva suave por los puntos (sin esquinas al cambiar de zona).
static func _smooth(curve: Curve2D) -> void:
	for k in curve.point_count:
		var p0 := curve.get_point_position(maxi(k - 1, 0))
		var p1 := curve.get_point_position(mini(k + 1, curve.point_count - 1))
		var tangent := (p1 - p0) * 0.25
		curve.set_point_in(k, -tangent)
		curve.set_point_out(k, tangent)


static func _zone(data: WorldData, id: String) -> ZoneEntry:
	for z in data.zones:
		if z.id == id:
			return z
	return null


## El globo dibujado en la ciudad (lo pone ExtraContent al cargar la zona).
func _parked(b: ExtraBuilding) -> Node2D:
	var zone: Node = world.streamer.zone_node(b.zone_id)
	return zone.get_node_or_null("Extra_" + b.id) if zone != null else null


## El globo que vuela: sombra en el suelo, y arriba el globo con el entrenador en la canasta.
func _make_ship(texture: Texture2D, t: Trainer) -> Node2D:
	var ship := Node2D.new()
	ship.name = "BalloonFlight"
	ship.z_index = 100  # por encima de todo (techos y copas de árboles incluidos)
	var shadow := _Shadow.new()
	shadow.name = "Shadow"
	ship.add_child(shadow)
	var body := Node2D.new()
	body.name = "Body"
	ship.add_child(body)
	if texture != null:
		body.add_child(_part(texture, Rect2(0, 0, texture.get_width(), texture.get_height())))
	# El entrenador en la canasta: delante del globo, con el frente de la canasta tapándole las piernas.
	var rider: Sprite2D = t.sprite.duplicate()
	rider.frame = 0
	rider.flip_h = false
	rider.position = Vector2(0, -BASKET_FRONT + 4.0 - rider.get_rect().end.y)
	body.add_child(rider)
	if texture != null:
		body.add_child(_part(texture, Rect2(0, texture.get_height() - BASKET_FRONT, texture.get_width(), BASKET_FRONT)))
	return ship


## Un pedazo del sprite del globo (abajo al medio en el origen, como el globo entero).
static func _part(texture: Texture2D, region: Rect2) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = texture
	spr.region_enabled = true
	spr.region_rect = region
	spr.centered = false
	spr.position = Vector2(-texture.get_width() / 2.0, region.position.y - texture.get_height())
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return spr


class _Shadow:
	extends Node2D

	func _draw() -> void:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.4))
		draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 1))
