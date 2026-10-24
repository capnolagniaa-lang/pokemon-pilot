class_name FightStyle
extends Resource
## Estilo de combate de arena de una especie (pedido del usuario 2026-10-24, inspirado en Pokémon Arena 2D / Pokkén;
## docs/PLAN_IDENTIDAD_COMBATE.md "Combate de arena"): cómo se mueve y sus combos. data/estilos/<especie>.tres.
## Por ahora rige en las peleas de arena (torneo, gimnasio, entrenadores); GameConfig.arena_rules_everywhere lo
## lleva al mundo abierto.

## "normal": como siempre · "agil": arranca y frena al instante, esquiva más seguido · "pesado": tiene inercia
## (acelera y frena de a poco) y lo empujan menos · "volador": el terreno no lo frena (cráteres, pasto, arena).
@export var species_id: String = ""
@export var move_style: String = "normal"
## Salta los cráteres con el esquive (Espacio): cruza hasta la otra punta en la dirección en que apuntás.
## Los que no tienen patas (bichos, Geodude, Onix, Seel) no; los voladores ya pasan por arriba.
@export var can_jump: bool = false
@export var combos: Array[ComboData] = []
