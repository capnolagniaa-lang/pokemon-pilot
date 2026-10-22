class_name SignatureData
extends Resource
## Mecánica de firma de un Pokémon (plan de identidad, capa 2): un recurso propio que sube con eventos de
## combate y dispara efectos en umbrales. Los números viven acá; el comportamiento, en `mechanic_script`
## (una subclase de SignatureMechanic), así se balancea sin tocar código.

@export var id: String = ""
@export var display_name: String = ""
## Explicación corta para la ficha del Pokémon.
@export_multiline var description: String = ""
@export var color: Color = Color.WHITE
## 0 = mecánica sin recurso (la interfaz no dibuja barra, solo el estado).
@export var max_value: float = 100.0
## Evento de combate -> cuánto suma. Eventos: hit_dealt, damage_received, moved (por píxel),
## dodged, killed, status_inflicted, blocked.
@export var gains: Dictionary = {}
## Cuánto baja por segundo en combate y fuera de combate.
@export var decay_in_combat: float = 0.0
@export var decay_out_of_combat: float = 5.0
## Umbrales para la interfaz (marcas en la barra).
@export var thresholds: Array[float] = []
## Script con el comportamiento (extends SignatureMechanic).
@export var mechanic_script: Script
## Parámetros propios de cada mecánica (duraciones, multiplicadores...).
@export var params: Dictionary = {}
