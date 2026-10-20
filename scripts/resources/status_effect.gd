class_name StatusEffect
extends Resource
## Estado alterado (quemado, paralizado, congelado...). Cada .tres en data/status es uno.

@export var id: String = ""
@export var display_name: String = ""
@export var color: Color = Color.WHITE
@export var duration: float = 4.0
## Daño por segundo como fracción de la vida máxima.
@export var damage_per_second: float = 0.0
@export var speed_mult: float = 1.0
@export var attack_mult: float = 1.0
## Si es false, no puede moverse ni atacar (congelado).
@export var can_act: bool = true
## Probabilidad por segundo de quedar inmovilizado un instante (parálisis).
@export var stun_chance_per_second: float = 0.0
@export var stun_time: float = 0.6
## Elementos que lo curan al recibir un golpe (ej: el fuego descongela).
@export var cured_by: Array[ElementType] = []
## Elemento que lo representa (para el entorno: un quemado prende el pasto, etc.).
@export var element: ElementType
