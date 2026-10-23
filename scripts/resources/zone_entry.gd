class_name ZoneEntry
extends Resource
## Una zona del mundo: qué escena es y dónde va (en celdas).

@export var id: String = ""
@export var display_name: String = ""
@export_file("*.tscn") var scene_path: String = ""
@export var origin: Vector2i = Vector2i.ZERO
@export var size: Vector2i = Vector2i(48, 32)
@export var biome: String = "pradera"
## Celda (local) de la plaza central donde se juntan los caminos.
@export var hub: Vector2i = Vector2i.ZERO
## Salidas hacia zonas vecinas: lado ("up", "down", "left", "right") -> celda local donde empieza el camino.
@export var exits: Dictionary = {}
## Puertas: celda local -> {"to": id de la zona destino, "cell": celda local de llegada (Vector2i)}. Una puerta
## sólida (la de una casa) se usa caminando contra ella; una transitable (alfombra, escalera), pisándola.
@export var warps: Dictionary = {}
## Interior (casa, Centro, gimnasio...): sin salvajes ni clima.
@export var interior := false


func world_rect(tile_size: int) -> Rect2:
	return Rect2(Vector2(origin * tile_size), Vector2(size * tile_size))


## Centro (en píxeles del mundo) de un camino de 2 celdas que arranca en la celda local dada.
func path_point(local_cell: Vector2i, tile_size: int) -> Vector2:
	return Vector2((origin + local_cell + Vector2i.ONE) * tile_size)
