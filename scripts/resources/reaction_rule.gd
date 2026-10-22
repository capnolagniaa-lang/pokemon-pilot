class_name ReactionRule
extends Resource
## Regla del entorno reactivo: cuando un elemento impacta una celda que cumple las condiciones, le cambia el
## estado (y opcionalmente lo propaga por las celdas conectadas). Datos en data/environment/reactions/*.tres.
## Se evalúan por `priority` (mayor primero); se aplica la primera que coincide en cada celda.

enum Effect { NONE, STEAM, SPARKS, ICE, FIRE, SPLASH }

@export var id: String = ""
@export var element: ElementType
@export var priority: int = 0

@export_group("Condiciones")
## La celda necesita al menos uno de estos tags (vacío = cualquiera).
@export var tags_any: PackedStringArray = []
## Estado que tiene que tener la celda ("" = no importa; "none" = ninguno).
@export var state_required: String = ""
## Estados con los que la regla no aplica.
@export var states_blocked: PackedStringArray = []

@export_group("Resultado")
## Estado nuevo ("" = se limpia la celda).
@export var set_state: String = ""
## Propagación instantánea por celdas conectadas (eléctrico por el agua y el suelo mojado): se extiende a
## las vecinas que tengan alguno de estos tags o estados, hasta `flood_limit` celdas.
@export var flood_tags: PackedStringArray = []
@export var flood_states: PackedStringArray = []
@export var flood_limit: int = 0
@export var effect: Effect = Effect.NONE
## Texto flotante (vacío = nada). Ej: "¡Vapor!".
@export var text: String = ""
