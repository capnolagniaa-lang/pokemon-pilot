class_name WorldData
extends Resource
## Mapa del mundo: lista de zonas y punto de inicio.

@export var tile_size: int = 16
@export var zones: Array[ZoneEntry] = []
@export var spawn_cell: Vector2i = Vector2i.ZERO


func zone_at(world_pos: Vector2) -> ZoneEntry:
	for z in zones:
		if z.world_rect(tile_size).has_point(world_pos):
			return z
	return null
