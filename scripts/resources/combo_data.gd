class_name ComboData
extends Resource
## Un combo con nombre (estilo Pokkén, docs/PLAN_IDENTIDAD_COMBATE.md "Combate de arena"): si un Pokémon le pega a
## un rival con `first` y antes de `window` segundos lo vuelve a golpear con `second`, el segundo golpe pega
## `damage_mult` más, empuja `knockback_mult` más y aplica `status` (si hay). Va en el FightStyle de la especie.

@export var display_name: String = ""
## ids de MoveData (los del kit).
@export var first: String = ""
@export var second: String = ""
@export var window: float = 1.6
@export var damage_mult: float = 1.4
@export var knockback_mult: float = 1.0
@export var status: StatusEffect
