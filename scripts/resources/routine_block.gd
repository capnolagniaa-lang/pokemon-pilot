class_name RoutineBlock
extends Resource
## Un bloque de la rutina diaria de un entrenador vivo: entre `start_hour` y `end_hour` (horas del juego) está
## en `zone_id`, cerca de `cell` (celda local de la zona), haciendo `activity`. Se usa desde la fase E-5; en
## E-0 el entrenador se para en el lugar de su primer bloque.

@export_range(0, 24) var start_hour: int = 8
@export_range(0, 24) var end_hour: int = 12
@export var zone_id: String = "ruta1"
@export var cell: Vector2i = Vector2i.ZERO
## entrenar · explorar · descansar · buscar_rival · curarse
@export var activity: String = "entrenar"
