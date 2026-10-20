class_name ZoneEntry
extends Resource
## Una zona del mundo: qué escena es y dónde va (en celdas).

@export var id: String = ""
@export var display_name: String = ""
@export_file("*.tscn") var scene_path: String = ""
@export var origin: Vector2i = Vector2i.ZERO
@export var size: Vector2i = Vector2i(40, 26)
@export var biome: String = "pradera"


func world_rect(tile_size: int) -> Rect2:
	return Rect2(Vector2(origin * tile_size), Vector2(size * tile_size))
