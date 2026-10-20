class_name Zone
extends Node2D
## Una zona del mundo: capas de tiles, objetos del entorno y consultas sobre sus celdas.

const TILE := 16

@export var zone_id: String = ""
## Celda superior izquierda de cada árbol (2x2), para dibujar sus sombras.
@export var tree_cells: Array[Vector2i] = []

@onready var ground: TileMapLayer = $Ground
@onready var water: TileMapLayer = $Water
@onready var foliage: TileMapLayer = $Foliage


## Tags de una celda (combina suelo, agua y follaje), según el custom data "tags" del TileSet.
func get_tags(cell: Vector2i) -> PackedStringArray:
	var tags := PackedStringArray()
	for layer in [ground, water, foliage]:
		var td: TileData = layer.get_cell_tile_data(cell)
		if td != null:
			tags.append_array(td.get_custom_data("tags"))
	return tags


## Celda local de una posición global.
func cell_at(global_pos: Vector2) -> Vector2i:
	return ground.local_to_map(to_local(global_pos))
