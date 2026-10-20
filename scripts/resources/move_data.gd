class_name MoveData
extends Resource
## Definición de un ataque. Cada .tres en data/moves es un ataque.

enum Kind { PROJECTILE, DASH, AREA, SHIELD }

@export var id: String = ""
@export var display_name: String = ""
@export var element: ElementType
@export var kind: Kind = Kind.PROJECTILE
@export var power: float = 10.0
@export var cooldown: float = 1.0
@export var energy_cost: float = 10.0
## Tiempo de carga antes de que salga el ataque (lo interrumpe un golpe fuerte).
@export var cast_time: float = 0.0
## Empuje que recibe el que es golpeado (píxeles/segundo iniciales).
@export var knockback: float = 160.0

@export_group("Estado alterado")
@export var status: StatusEffect
@export_range(0.0, 1.0) var status_chance: float = 0.0

@export_group("Proyectil")
@export var speed: float = 300.0
@export var size: float = 4.0
@export var lifetime: float = 1.0

@export_group("Área")
@export var radius: float = 48.0

@export_group("Embestida")
@export var dash_time: float = 0.22

@export_group("Escudo")
@export var duration: float = 1.4


## Alcance aproximado (para la IA).
func reach() -> float:
	match kind:
		Kind.PROJECTILE:
			return speed * lifetime * 0.85
		Kind.DASH:
			return 520.0 * dash_time + 12.0
		Kind.AREA:
			return radius * 0.85
	return 0.0
