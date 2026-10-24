class_name EnvCellState
extends Resource
## Estado dinámico de una celda del mundo (Etapa 3, entorno reactivo): ardiendo, quemado, mojado,
## congelado, electrificado. Va encima de los tags del TileSet. Datos en data/environment/states/*.tres.

enum Look { FIRE, SCORCH, WET, ICE, SPARK, CRATER }

@export var id: String = ""
@export var display_name: String = ""
## Segundos que dura (0 = no vence).
@export var duration: float = 5.0
## Estado al que pasa cuando vence ("" = vuelve a la normalidad). Ej: ardiendo -> quemado.
@export var next_state: String = ""
## Al vencer, vuelve al estado que tenía antes (electrificado sobre una celda mojada vuelve a mojada).
@export var restore_previous: bool = false

@export_group("Propagación")
## Elemento que emite a las 4 celdas vecinas mientras dura (el fuego se contagia).
@export var spread_element: ElementType
## Probabilidad por segundo de contagiar a cada vecina.
@export var spread_chance: float = 0.0

@export_group("Efectos")
## Estado que reciben las criaturas paradas encima (ardiendo -> Quemado, mojado -> Empapado...).
@export var creature_status: StatusEffect
## Tags que la celda pierde y gana mientras dura (el pasto quemado deja de ser inflamable y pasto alto).
@export var removes_tags: PackedStringArray = []
@export var adds_tags: PackedStringArray = []
## El agua congelada se puede caminar (puente de hielo).
@export var walkable_water: bool = false

@export_group("Visual")
@export var look: Look = Look.SCORCH
@export var color: Color = Color.WHITE
