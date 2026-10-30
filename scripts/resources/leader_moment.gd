class_name LeaderMoment
extends Resource
## Un "momento" del guion de un líder (docs/PLAN_IA.md, IA-4): cuándo pasa y qué hace. Ver LeaderScript.

## HP_BELOW: su Pokémon baja de `value` de vida (una vez por pelea) · LAST_MON: sale el último · FIRST_FAINT: le
## debilitaste el primero.
enum Trigger { HP_BELOW, LAST_MON, FIRST_FAINT }

@export var trigger: Trigger = Trigger.HP_BELOW
@export var value: float = 0.5
## Lo que grita (sale sobre su Pokémon y en los mensajes).
@export var line: String = ""
## Estado que le pone a su Pokémon (data/status) y por cuánto (multiplica su duración).
@export var status_id: String = ""
@export var status_mult: float = 1.0
## Elemento que tira alrededor de su Pokémon (entorno reactivo: "agua" moja la cancha) y radio.
@export var element_id: String = ""
@export var element_radius: float = 60.0
## Se cura esta fracción de la vida.
@export var heal_ratio: float = 0.0
## Ataca más seguido (multiplica el tiempo entre ataques) durante `pace_time` segundos.
@export var pace: float = 1.0
@export var pace_time: float = 0.0
