class_name StatusInteraction
extends Resource
## Interacción elemento × estado: cuando un golpe de `element` le pega a alguien con `requires`, pasa algo.
## Cada .tres en data/status/interactions es una. Ejemplos: agua apaga Quemado; eléctrico sobre Empapado
## aturde y pega más; fuego sobre Enraizado rompe la raíz y quema; viento sobre Quemado lo contagia.

@export var description: String = ""
## Texto que aparece flotando al dispararse (ej: "¡Cortocircuito!").
@export var label: String = ""
@export var element: ElementType
@export var requires: StatusEffect
## Quita el estado requerido.
@export var consume: bool = false
## Multiplica el daño de este golpe.
@export var damage_mult: float = 1.0
## Aturde este tiempo (cuenta como control).
@export var stun_time: float = 0.0
## Aplica otro estado.
@export var apply: StatusEffect
## Si el objetivo tiene (o recibe con este golpe) este estado, multiplica lo que le queda de duración.
@export var extend: StatusEffect
@export var extend_mult: float = 1.5
## Contagia el estado requerido a los compañeros del objetivo en este radio (viento sobre quemado).
@export var spread_radius: float = 0.0
