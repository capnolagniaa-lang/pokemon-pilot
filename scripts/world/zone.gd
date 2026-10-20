class_name Zone
extends Node2D
## Una zona del mundo: capas de tiles y consultas sobre sus celdas.

@export var zone_id: String = ""

@onready var ground: TileMapLayer = $Ground
@onready var objects: TileMapLayer = $Objects


## Tags de una celda (combina suelo + objeto), según el custom data "tags" del TileSet.
func get_tags(cell: Vector2i) -> PackedStringArray:
	var tags := PackedStringArray()
	for layer in [ground, objects]:
		var td: TileData = layer.get_cell_tile_data(cell)
		if td != null:
			tags.append_array(td.get_custom_data("tags"))
	return tags
