class_name ExtraBuilding
extends Resource
## Un edificio agregado encima de una zona importada, sin tocar su escena ni kanto.tres (docs/PLAN_ONLINE.md, O-1):
## un sprite, sus celdas sólidas y una puerta a un interior. Lo pone `ExtraContent` al cargar la zona.

@export var id: String = ""
@export var zone_id: String = ""
## Celda (local de la zona) de arriba a la izquierda del edificio.
@export var cell: Vector2i = Vector2i.ZERO
## Tamaño en celdas (todas sólidas; la puerta también: se entra caminando contra ella, como en una casa).
@export var size: Vector2i = Vector2i(5, 4)
## Sprite del edificio (size × 16 px). Sin él no se dibuja nada (la colisión y la puerta siguen).
@export var texture: Texture2D
## Celda de la puerta (local de la zona).
@export var door: Vector2i = Vector2i.ZERO
## A qué zona lleva la puerta y a qué celda (local de esa zona) se llega.
@export var to_zone: String = ""
@export var to_cell: Vector2i = Vector2i.ZERO


func cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in size.y:
		for x in size.x:
			out.append(cell + Vector2i(x, y))
	return out
