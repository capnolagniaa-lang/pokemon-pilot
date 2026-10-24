class_name LedgeJumper
extends Node
## Saltos de los salientes de FireRed (behaviors MB_JUMP_*): el saliente es sólido, pero caminando contra él en
## su dirección (casi siempre hacia abajo) el entrenador lo salta y cae en la celda de al lado. Desde el otro lado
## sigue siendo una pared: se bajan, no se suben. El Pokémon que lo sigue salta detrás. En combate no se usan.

## Behavior de FireRed -> dirección del salto.
const DIRS := {0x38: Vector2i.RIGHT, 0x39: Vector2i.LEFT, 0x3A: Vector2i.UP, 0x3B: Vector2i.DOWN}
## Qué tan cerca (px) del saliente hay que estar caminando contra él.
const PUSH := 6.0
const HOP_TIME := 0.3
const HOP_HEIGHT := 9.0

var world: Node
var busy := false


func _ready() -> void:
	world = get_parent()


func _physics_process(_delta: float) -> void:
	var t: Trainer = world.trainer
	if busy or world.combat.in_battle or t.locked or (world.warps != null and world.warps.busy):
		return
	var input := t.input_dir()
	if input == Vector2.ZERO:
		return
	var d := WarpSystem._four(input)
	var data: WorldData = world.streamer.world_data
	var entry := data.zone_at(t.global_position)
	if entry == null:
		return
	var zone: Zone = world.streamer.zone_node(entry.id)
	if zone == null:
		return
	var ledge := zone.cell_at(t.global_position) + d
	if direction_at(zone, ledge) != d:
		return
	var rect := Rect2(zone.to_global(Vector2(ledge * data.tile_size)), Vector2.ONE * data.tile_size)
	if WarpSystem._dist_to_rect(t.global_position, rect) >= PUSH:
		return
	var landing := zone.to_global(zone.ground.map_to_local(ledge + d))
	if not _walkable_at(landing):
		return
	_jump(t, landing, d)


## Dirección del salto del saliente de la celda (Vector2i.ZERO si no es un saliente).
static func direction_at(zone: Zone, cell: Vector2i) -> Vector2i:
	var m := ZoneBuilder.metatile_at(zone.ground, cell)
	if m < 0 or not ZoneBuilder.exists(m):
		return Vector2i.ZERO
	return DIRS.get(ZoneBuilder.behavior_of(m), Vector2i.ZERO)


func _walkable_at(pos: Vector2) -> bool:
	var entry: ZoneEntry = world.streamer.world_data.zone_at(pos)
	var zone: Zone = world.streamer.zone_node(entry.id) if entry != null else null
	return zone != null and MapRules.is_walkable(zone, zone.cell_at(pos))


func _jump(t: Trainer, landing: Vector2, d: Vector2i) -> void:
	busy = true
	t.locked = true
	t.facing = Vector2(d)
	var start := t.global_position
	var mask := t.collision_mask
	t.collision_mask = 0  # pasa por encima del saliente
	var sprite_y := t.sprite.offset.y
	var tw := create_tween().set_parallel()
	tw.tween_property(t, "global_position", landing, HOP_TIME)
	tw.tween_method(func(k: float): t.sprite.offset.y = sprite_y - sin(k * PI) * HOP_HEIGHT, 0.0, 1.0, HOP_TIME)
	await tw.finished
	t.sprite.offset.y = sprite_y
	t.collision_mask = mask
	t.trail.append(start)
	t.trail.append(landing)
	t.locked = false
	busy = false
	_follow(landing, d)


## El Pokémon que sigue al entrenador también salta (si no, queda trabado del otro lado del saliente).
func _follow(landing: Vector2, d: Vector2i) -> void:
	var c: Creature = world.companion
	if not is_instance_valid(c) or world.combat.in_battle or c.global_position.distance_to(landing) > 120.0:
		return
	var mask := c.collision_mask
	c.collision_mask = 0
	var tw := create_tween()
	tw.tween_property(c, "global_position", landing - Vector2(d) * 5.0, HOP_TIME)  # en la celda de llegada, no en el saliente
	await tw.finished
	if is_instance_valid(c):
		c.collision_mask = mask
