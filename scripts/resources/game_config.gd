class_name GameConfig
extends Resource
## Parámetros generales de una partida nueva.

@export var starters: Array[SpeciesData] = []
@export var starting_level: int = 5
@export var starting_balls: int = 10
## Mochila inicial (id de data/items -> cantidad). docs/PLAN_CAPTURA_MOCHILA.md.
@export var starting_bag: Dictionary = {"poke_ball": 10, "pocion": 3, "antidoto": 1, "antiparalizador": 1}
@export var world: WorldData
