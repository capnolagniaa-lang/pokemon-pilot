class_name MoveData
extends Resource
## Definición de un ataque. Los ataques sueltos están en data/moves; los de cada kit (plan de identidad)
## en data/kits/<pokémon>/. Sin energía: lo único que limita es la recarga.

## PROJECTILE disparo (o abanico) · DASH embestida · AREA onda alrededor · SHIELD escudo ·
## MELEE golpe cuerpo a cuerpo (con combo) · ZONE zona en el suelo (trampa, esporas, nube) ·
## CHANNEL canalizado en cono · LUNGE se lanza al punto apuntado y si conecta encadena un 2º golpe ·
## WHIP látigo en línea que agarra al primero que alcanza · SELF_BUFF se aplica un estado a sí mismo
enum Kind { PROJECTILE, DASH, AREA, SHIELD, MELEE, ZONE, CHANNEL, LUNGE, WHIP, SELF_BUFF }
## Físico usa Ataque/Defensa; Especial usa At. Esp./Def. Esp. (como en los juegos desde la 4ª gen).
enum Category { PHYSICAL, SPECIAL, STATUS }

@export var id: String = ""
@export var display_name: String = ""
@export var element: ElementType
@export var kind: Kind = Kind.PROJECTILE
@export var category: Category = Category.PHYSICAL
## Potencia oficial (data/source/official.json).
@export var power: float = 40.0
## Multiplicador sobre la potencia (para repartirla: abanico de 3 brasas, ticks de una zona...).
@export var power_mult: float = 1.0
@export var cooldown: float = 1.0
## Tiempo de carga antes de que salga el ataque (lo interrumpe un golpe fuerte). Se telegrafía.
@export var cast_time: float = 0.0
## Empuje que recibe el que es golpeado (negativo = lo atrae hacia el atacante).
@export var knockback: float = 160.0
## Recuperación: después de lanzarlo, el usuario queda expuesto este tiempo (ventana de castigo).
@export var recovery: float = 0.0

@export_group("Estados")
## Estado con probabilidad (ej: Ascuas quema 10%).
@export var status: StatusEffect
@export_range(0.0, 1.0) var status_chance: float = 0.0
## Estados que aplica siempre (ej: las esporas ralentizan y envenenan).
@export var statuses_on_hit: Array[StatusEffect] = []

@export_group("Efectos especiales")
## Ejecución (Hipercolmillo): si el objetivo tiene esta fracción de vida o menos, lo debilita. 0 = no.
@export_range(0.0, 1.0) var execute_below: float = 0.0
## Viento (Tornado, Remolino): los proyectiles enemigos que toca salen desviados.
@export var deflects_projectiles: bool = false
## Drenar (Absorber, Chupavidas): el atacante se cura esta fracción del daño que hace.
@export_range(0.0, 1.0) var drain: float = 0.0
## Limpiarse (Giro Rápido): al usarlo se cura de los problemas de estado propios.
@export var cleanse_self: bool = false
## Anulación: el golpeado tarda estos segundos más en recargar todos sus ataques.
@export var cooldown_lock: float = 0.0
## Esporas inflamables (Paras): si un ataque de fuego toca este parche o nube, arde 3 s y quema a quien esté adentro.
@export var zone_flammable: bool = false
## Deja un cráter en el suelo donde impacta, de este radio en px (0 = no). Excavar, Tumba Rocas, Lanzarrocas,
## Terremoto... Por ahora solo en las arenas (docs/PLAN_IDENTIDAD_COMBATE.md "Combate de arena").
@export var crater_radius: float = 0.0
## Cuántos cráteres de este ataque (de cada Pokémon) pueden quedar a la vez: al dejar uno más se borra el más viejo.
## Así no llenan la cancha (pedido del usuario 2026-10-24).
@export var crater_max: int = 3
## No aplica el estado de su elemento al pegar (Burbuja no empapa aunque sea de agua).
@export var skip_element_status: bool = false

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

@export_group("Embestida")
@export var dash_time: float = 0.22
## Si la embestida golpea.
@export var dash_hits: bool = true
## Invulnerabilidad durante la embestida.
@export var invulnerable_time: float = 0.0
## Estela que deja en el suelo (fuego de la Embestida Ígnea): potencia por toque, estado y duración.
@export var trail_power: float = 0.0
@export var trail_status: StatusEffect
@export_range(0.0, 1.0) var trail_status_chance: float = 0.0
@export var trail_duration: float = 0.0

@export_group("Embestida con combo (LUNGE)")
## Hasta qué distancia se lanza hacia el punto apuntado.
@export var lunge_range: float = 60.0
@export var lunge_speed: float = 380.0
## Si la embestida conecta: segundo golpe tras esta demora.
@export var followup_delay: float = 0.18
@export var followup_power_mult: float = 1.0
@export var followup_knockback: float = 140.0

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
## Si atrapa: quien está adentro al aparecer no puede salir (Giro Fuego). Si no, es un parche/nube.
@export var zone_traps: bool = true
## Parche/nube: cada cuánto afecta a los enemigos de adentro (daño de la zona + estados).
@export var zone_tick: float = 0.5
## Máximo de zonas de este ataque a la vez (al pasarse, se borra la más vieja). 0 = sin límite.
@export var zone_max_count: int = 0
## Nube: si un enemigo se queda adentro este tiempo seguido, recibe `dwell_status` (Somnífero duerme).
@export var dwell_time: float = 0.0
@export var dwell_status: StatusEffect
## Golpe desde el cielo (Rayo): en vez de quedarse, marca el círculo y a los `strike_delay` s cae una sola vez.
@export var zone_strike: bool = false
@export var strike_delay: float = 0.3
## Varios golpes desde el cielo (Tumba Rocas): el primero donde apuntás, los demás al azar a `strike_spread` px.
@export var strike_count: int = 1
@export var strike_spread: float = 30.0
## Excavar: el que lo usa se mete bajo tierra (invisible e invulnerable) y sale donde cae el golpe.
@export var strike_burrow: bool = false

@export_group("Látigo (WHIP)")
@export var whip_length: float = 70.0
@export var whip_width: float = 8.0

@export_group("Mejora propia (SELF_BUFF) / escudo")
@export var self_status: StatusEffect
@export var duration: float = 1.4

@export_group("Canalizado")
@export var channel_time: float = 1.2
@export var cone_angle_deg: float = 35.0
@export var cone_length: float = 70.0
@export var tick_interval: float = 0.15


@export_group("Efecto con sprite (VFX)")
## Animación del cuerpo del ataque (proyectil, onda de área, corte), dibujada apuntando a la derecha. Si está
## vacía: hoja sprites/fx/moves/<id>.png, después la del tipo; sin ninguna se dibuja por código (DB.vfx_for).
@export var vfx: SpriteFrames
## Animación al pegarle a alguien (o sprites/fx/moves/<id>_impacto.png, después la del tipo).
@export var impact_vfx: SpriteFrames

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
		Kind.LUNGE:
			return lunge_range + 8.0
		Kind.WHIP:
			return whip_length
		Kind.SELF_BUFF:
			return 9999.0
	return 0.0
