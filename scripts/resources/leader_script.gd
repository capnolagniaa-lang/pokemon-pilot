class_name LeaderScript
extends Resource
## Guion de un líder (docs/PLAN_IA.md, IA-4): 2-3 momentos que le dan identidad a su pelea (Brock se planta con
## Fortaleza, Misty inunda la cancha...). Datos en data/ai/leader_scripts/<id>.tres; `trainer_ids` = ids de TrainerData.

@export var id: String = ""
@export var trainer_ids: PackedStringArray = []
@export var moments: Array[LeaderMoment] = []
