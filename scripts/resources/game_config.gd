class_name GameConfig
extends Resource
## Parámetros generales de una partida nueva.

@export var starters: Array[SpeciesData] = []
@export var starting_level: int = 5
## Multiplicador de la EXP que se gana (1 = fórmula oficial). 0,5: subir de nivel cuesta el doble (pedido del
## usuario 2026-10-23: "se sube de nivel muy rápido").
@export var exp_multiplier: float = 0.5
## Reglas del combate de arena (estilos de movimiento, combos, superficies, cráteres) también en el mundo abierto.
## Por ahora solo en las arenas (decisión del usuario 2026-10-24: "empezá en los torneos, después en el mundo").
@export var arena_rules_everywhere: bool = false
## Cadena de golpes (+5% c/u, "COMBO ×N") y combos con nombre del estilo de pelea. Apagado por ahora (decisión del
## usuario 2026-10-24: "por ahora sacá los combos"); los datos (data/estilos) y el código quedan para retomarlos.
@export var combos_enabled: bool = false
@export var starting_balls: int = 10
## Mochila inicial (id de data/items -> cantidad). docs/PLAN_CAPTURA_MOCHILA.md.
@export var starting_bag: Dictionary = {"poke_ball": 10, "pocion": 3, "antidoto": 1, "antiparalizador": 1}
@export var world: WorldData
