class_name WarpSystem
extends Node
## Puertas entre zonas (casas, Centros, gimnasios, garitas, el Bosque Verde): `ZoneEntry.warps`.
## Una puerta transitable (alfombra de salida, escalera, entrada del bosque) se usa pisándola; una sólida (la
## puerta de una casa), caminando contra ella. Fundido a negro, el entrenador y su Pokémon aparecen en la celda
## libre de al lado de la puerta de destino y la cámara salta. Durante un combate no se usan.

const FADE := 0.16
## Qué tan cerca (px) de una puerta sólida hay que estar caminando contra ella.
const PUSH := 7.0
## Orden en que se busca dónde aparecer al lado de la puerta de destino (abajo primero: se sale de una casa
## hacia abajo; en una alfombra de salida, abajo es la pared y se aparece arriba).
const ARRIVAL_DIRS: Array[Vector2i] = [Vector2i.DOWN, Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT]

var world: Node
var busy := false
## ¿El entrenador estaba parado en una puerta? Una transitable se usa al pisarla viniendo de otra celda (así no
## se vuelve a usar enseguida si se aparece o se arranca la partida encima de una).
var _on_warp := true
var _cooldown := 0.3
var _fade: ColorRect


func _ready() -> void:
	world = get_parent()
	var layer := CanvasLayer.new()
	layer.layer = 9
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade)


func _physics_process(delta: float) -> void:
	_cooldown -= delta
	var t: Trainer = world.trainer
	if busy or world.combat.in_battle or t.locked:
		return
	var data: WorldData = world.streamer.world_data
	var entry := data.zone_at(t.global_position)
	if entry == null or entry.warps.is_empty():
		_on_warp = false
		return
	var zone: Zone = world.streamer.zone_node(entry.id)
	if zone == null:
		return
	var cell := zone.cell_at(t.global_position)
	var hit = null
	var on_warp := entry.warps.has(cell)
	if on_warp and not _on_warp:
		hit = cell
	elif t.input_dir() != Vector2.ZERO and _cooldown <= 0.0:
		var d := _four(t.input_dir())
		var n := cell + d
		if entry.warps.has(n) and not MapRules.is_walkable(zone, n):
			var rect := Rect2(zone.to_global(Vector2(n * data.tile_size)), Vector2.ONE * data.tile_size)
			if _dist_to_rect(t.global_position, rect) < PUSH:
				hit = n
	_on_warp = on_warp
	if hit != null:
		use(entry, hit)


## Usa la puerta `cell` (local) de la zona `entry`.
func use(entry: ZoneEntry, cell: Vector2i) -> void:
	var w: Dictionary = entry.warps[cell]
	var dest := _entry(w["to"])
	if dest == null:
		return
	busy = true
	var t: Trainer = world.trainer
	t.locked = true  # quieto durante el fundido
	t.autopilot = Vector2.ZERO
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, FADE)
	await tw.finished
	var ts: int = world.streamer.world_data.tile_size
	world.streamer.load_around_now(Vector2((dest.origin + w["cell"]) * ts))
	var zone: Zone = world.streamer.zone_node(dest.id)
	var at: Vector2i = w["cell"]
	var dir := Vector2i.DOWN
	if zone != null:
		var found := arrival(func(c: Vector2i) -> bool: return MapRules.is_walkable(zone, c), dest, at)
		dir = found[1]
		at = found[0]
	var pos := Vector2((dest.origin + at) * ts) + Vector2.ONE * ts / 2.0
	t.global_position = pos
	t.trail = [pos]
	t.facing = Vector2(dir)
	if is_instance_valid(world.companion) and not world.combat.in_battle:
		world.companion.global_position = pos - Vector2(dir) * 12.0
		world.companion.velocity = Vector2.ZERO
	world.camera.snap()
	_on_warp = dest.warps.has(at)
	_cooldown = 0.3
	Events.warped.emit(entry, dest)
	tw = create_tween()
	tw.tween_property(_fade, "color:a", 0.0, FADE)
	await tw.finished
	t.locked = false
	busy = false


## Dónde aparecer al usar una puerta que lleva a `cell`: [celda, dirección hacia donde se sale]. La primera vecina
## transitable que no sea otra puerta (y con lugar para dar un paso más); si no hay, la celda libre más cercana.
static func arrival(walkable: Callable, entry: ZoneEntry, cell: Vector2i) -> Array:
	for strict in [true, false]:
		for d in ARRIVAL_DIRS:
			var n := cell + d
			if not _inside(entry, n) or entry.warps.has(n) or not walkable.call(n):
				continue
			if strict and not (_inside(entry, n + d) and walkable.call(n + d)):
				continue
			return [n, d]
	return [cell, Vector2i.DOWN]


static func _inside(entry: ZoneEntry, c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < entry.size.x and c.y < entry.size.y


func _entry(id: String) -> ZoneEntry:
	for z in world.streamer.world_data.zones:
		if z.id == id:
			return z
	return null


static func _four(v: Vector2) -> Vector2i:
	if absf(v.x) > absf(v.y):
		return Vector2i(signi(int(signf(v.x))), 0)
	return Vector2i(0, int(signf(v.y)))


static func _dist_to_rect(p: Vector2, r: Rect2) -> float:
	var q := Vector2(clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y))
	return p.distance_to(q)
