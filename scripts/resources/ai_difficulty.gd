class_name AiDifficulty
extends Resource
## Dificultad de la IA salvaje (data/config/difficulty/*.tres). "Difícil" es el comportamiento original.

@export var id: String = ""
@export var display_name: String = ""
## Multiplica el tiempo entre ataques (más alto = ataca menos seguido).
@export var attack_interval_mult: float = 1.0
## Error de apuntado en grados (± al azar).
@export var aim_error_deg: float = 7.0
## Probabilidad de esquivar un proyectil que le viene encima.
@export var dodge_chance: float = 0.3
## Multiplica el daño que hacen los salvajes.
@export var damage_mult: float = 1.0
## Multiplica cada cuánto "piensa" (cambia de táctica: acercarse, rodear, alejarse).
@export var think_interval_mult: float = 1.0
