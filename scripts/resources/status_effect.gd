class_name StatusEffect
extends Resource
## Estado alterado. Cada .tres en data/status es uno. Las interacciones con elementos (agua apaga quemado,
## eléctrico sobre empapado aturde...) están aparte, en data/status/interactions (StatusInteraction).
## Diseño: docs/PLAN_IDENTIDAD_COMBATE.md, sección 3.

@export var id: String = ""
@export var display_name: String = ""
@export var color: Color = Color.WHITE
@export var duration: float = 4.0
## Daño por segundo (fracción de la vida máxima), por cada stack.
@export var damage_per_second: float = 0.0
## Multiplicador de velocidad de movimiento.
@export var speed_mult: float = 1.0
## Multiplica el daño físico que hace el afectado (Quemado: 0.85).
@export var attack_mult: float = 1.0
## Si es false, no puede moverse ni atacar (congelado, dormido).
@export var can_act: bool = true
## Si es false, no puede moverse pero sí atacar (enraizado).
@export var can_move: bool = true
## Elemento que lo representa (para el entorno: un quemado prende el pasto, etc.).
@export var element: ElementType

@export_group("Stacks y acumulación")
## Máximo de stacks (Envenenado: 5). Cada aplicación suma uno y renueva la duración.
@export var max_stacks: int = 1
## Acumulación por barra (Paralizado): cada aplicación llena `buildup_per_apply`; al llegar a 1 aturde
## `stun_time` segundos y se vacía. La barra baja `buildup_decay` por segundo; en 0 se va el estado.
@export var buildup: bool = false
@export var buildup_per_apply: float = 0.35
@export var buildup_decay: float = 0.12
@export var stun_time: float = 0.8

@export_group("Tirones (Paralizado)")
## Cada `jolt_interval` s, con probabilidad `jolt_chance`, queda totalmente quieto `jolt_time` s (como la parálisis
## de los juegos: "¡está paralizado, no se puede mover!"). 0 = sin tirones.
@export var jolt_interval: float = 0.0
@export_range(0.0, 1.0) var jolt_chance: float = 0.35
@export var jolt_time: float = 0.6

@export_group("Reglas especiales")
## Se cura al recibir daño (Dormido).
@export var wake_on_damage: bool = false
## Desorienta: el apuntado y el movimiento se desvían hasta estos grados.
@export var aim_jitter_deg: float = 0.0
## Multiplica la curación que recibe (Herido: 0.5).
@export var heal_mult: float = 1.0
## Cuenta como control (aturde/inmoviliza): dispara la resistencia a control al terminar.
@export var is_cc: bool = false
## Multiplica el daño que recibe (Arraigo: 0.5).
@export var damage_taken_mult: float = 1.0
## Curación por segundo (fracción de la vida máxima): Arraigo, Síntesis.
@export var heal_per_second: float = 0.0
## Multiplica el empuje que recibe (0 = no lo pueden empujar).
@export var knockback_mult: float = 1.0

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
## Dibuja una burbuja alrededor de la criatura (Encerrado en burbuja).
@export var fx_bubble: bool = false
