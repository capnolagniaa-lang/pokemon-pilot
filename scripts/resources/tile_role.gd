class_name TileRole
extends Resource
## Un "rol" de tile del mundo (pasto, arena, agua, árbol...): qué metatiles lo forman, en qué capa va, qué
## va abajo, sus tags y su colisión. Lo leen tools/build_world.gd (generar zonas y el TileSet) y el editor
## de mapas (pinceles semánticos). Vive en data/world/tile_roles.tres (TileRoleSet).

enum Kind {
	TILE,      ## un tile suelto (con variantes al azar)
	AUTOTILE,  ## bloque 3x3 de FireRed: bordes y esquinas según los vecinos
	TREE,      ## árbol 2x2 con copa (Overhead) y copa "apilada" si hay otro árbol justo arriba
}
enum Physics { NONE = -1, SOLID = 0, WATER = 1 }

@export var id: String = ""
@export var display_name: String = ""
@export var kind: Kind = Kind.TILE
## Carácter del mapa de suelo del generador (build_world): "." pasto, "," pasto alto, "=" arena...
@export var symbol: String = ""
## Capa de la zona donde se pinta: Ground, Water o Foliage.
@export var layer: String = "Ground"
## Rol que va abajo, en Ground (por ejemplo pasto bajo el agua y bajo el pasto alto). Vacío = nada.
@export var under: String = ""
## TILE: todos los metatiles del rol. AUTOTILE: el 3x3 por filas (sup. izq. ... inf. der.).
## TREE: copa izq./der., copa apilada izq./der., tronco izq./der.
@export var metatiles: PackedInt32Array = []
## Al pintar se elige uno al azar (repetir un id lo hace más probable). Vacío = metatiles[0].
@export var variants: PackedInt32Array = []
@export var tags: PackedStringArray = []
@export var physics: Physics = Physics.NONE
## ¿Aparece como pincel en el editor de mapas?
@export var brush: bool = true
## Color del botón del pincel en el editor.
@export var color: Color = Color.WHITE


## Pieza del 3x3 (AUTOTILE) para una fila y columna (0-2).
func piece(row: int, col: int) -> int:
	return metatiles[row * 3 + col]


## Metatile al pintar (variante al azar).
func pick(rng: RandomNumberGenerator) -> int:
	if variants.is_empty():
		return metatiles[0]
	return variants[rng.randi() % variants.size()]
