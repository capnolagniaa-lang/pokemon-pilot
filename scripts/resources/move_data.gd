class_name MoveData
extends Resource
## Definición de un ataque o habilidad de kit. Los ataques sueltos están en data/moves; las habilidades de
## cada kit (plan de identidad) en data/kits/<pokémon>/.

## PROJECTILE disparo · DASH embestida/movilidad · AREA onda alrededor · SHIELD escudo ·
## MELEE golpe cuerpo a cuerpo (con combo) · ZONE zona en el suelo (trampa) · CHANNEL canalizado en cono
enum Kind { PROJECTILE, DASH, AREA, SHIELD, MELEE, ZONE, CHANNEL }
## Físico usa Ataque/Defensa; Especial usa At. Esp./Def. Esp. (como en los juegos desde la 4ª gen).
enum Category { PHYSICAL, SPECIAL, STATUS }

@export var id: String = ""
@export var display_name: String = ""
@export var element: ElementType
@export var kind: Kind = Kind.PROJECTILE
@export var category: Category = Category.PHYSICAL
## Potencia oficial (data/source/official.json).
@export var power: float = 40.0
## Multiplicador sobre la potencia (para repartirla: abanico de 3 brasas, ticks de un canalizado...).
@export var power_mult: float = 1.0
@export var cooldown: float = 1.0
@export var energy_cost: float = 10.0
## Tiempo de carga antes de que salga el ataque (lo interrumpe un golpe fuerte). Se telegrafía.
@export var cast_time: float = 0.0
## Empuje que recibe el que es golpeado (píxeles/segundo iniciales).
@export var knockback: float = 160.0
## Recuperación: después de lanzarlo, el usuario queda expuesto este tiempo (ventana de castigo).
@export var recovery: float = 0.0

@export_group("Estado alterado")
@export var status: StatusEffect
@export_range(0.0, 1.0) var status_chance: float = 0.0

@export_group("Recurso de firma")
## Cuánto recurso de la mecánica de firma consume (-1 = todo lo que haya).
@export var resource_cost: float = 0.0
## Cuánto escala con el recurso consumido: daño × (1 + escala × consumido/máximo).
@export var resource_scaling: float = 0.0

@export_group("Proyectil")
@export var speed: float = 300.0
@export var size: float = 4.0
@export var lifetime: float = 1.0
## Cantidad de proyectiles y apertura del abanico en grados.
@export var projectile_count: int = 1
@export var spread_deg: float = 0.0

@export_group("Área")
@export var radius: float = 48.0

@export_group("Embestida / movilidad")
@export var dash_time: float = 0.22
## Si la embestida golpea. Las movilidades sin golpe dan invulnerabilidad breve.
@export var dash_hits: bool = true
@export var invulnerable_time: float = 0.0
## Estela que deja en el suelo (fuego de la Embestida Ígnea): potencia por toque, estado y duración.
@export var trail_power: float = 0.0
@export var trail_status: StatusEffect
@export_range(0.0, 1.0) var trail_status_chance: float = 0.0
@export var trail_duration: float = 0.0

@export_group("Cuerpo a cuerpo")
@export var melee_range: float = 14.0
@export var swing_radius: float = 11.0
## Golpes del combo (el último cierra el combo, empuja más y dispara la recarga completa).
@export var combo_steps: int = 1
## Tiempo para encadenar el siguiente golpe del combo.
@export var combo_window: float = 0.7
## Recarga entre golpes del combo (la `cooldown` normal se aplica al terminar el combo).
@export var combo_step_cooldown: float = 0.3
@export var final_knockback: float = 260.0

@export_group("Zona")
@export var zone_radius: float = 30.0
@export var zone_duration: float = 3.0
## Hasta qué distancia se puede ubicar la zona (apuntando con el mouse).
@export var placement_range: float = 110.0
## Si atrapa: quien está adentro al aparecer no puede salir (Giro Fuego).
@export var zone_traps: bool = true

@export_group("Escudo")
@export var duration: float = 1.4

@export_group("Canalizado")
@export var channel_time: float = 1.2
@export var cone_angle_deg: float = 35.0
@export var cone_length: float = 70.0
@export var tick_interval: float = 0.15


## Alcance aproximado (para la IA).
func reach() -> float:
	match kind:
		Kind.PROJECTILE:
			return speed * lifetime * 0.85
		Kind.DASH:
			return 520.0 * dash_time + 12.0
		Kind.AREA:
			return radius * 0.85
		Kind.MELEE:
			return melee_range + swing_radius
		Kind.ZONE:
			return placement_range
		Kind.CHANNEL:
			return cone_length * 0.9
	return 0.0
