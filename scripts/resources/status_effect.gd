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
## Multiplica el Ataque en ataques físicos (la quemadura lo divide por 2, como en los juegos).
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

@export_group("Efecto visual")
## Partículas sobre la criatura.
@export var fx_amount: int = 6
## Gravedad de las partículas (negativa = suben, como llamas; positiva = caen, como nieve).
@export var fx_gravity: float = 10.0
@export var fx_size: float = 1.5
## Luz parpadeante alrededor de la criatura (llamas, chispas).
@export var fx_light: bool = false
## Cuánto se tiñe el sprite con el color del estado (0..1).
@export var tint_strength: float = 0.45
