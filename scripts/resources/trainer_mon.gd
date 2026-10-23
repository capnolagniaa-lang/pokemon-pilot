class_name TrainerMon
extends Resource
## Un Pokémon del equipo inicial de un entrenador vivo. Los movimientos salen de su learnset a ese nivel.

@export var species: SpeciesData
@export_range(1, 100) var level: int = 8
## Solo está en el equipo si esta bandera está puesta (ej. el rival tiene el inicial que le gana al tuyo:
## Charmander si elegiste Bulbasaur). Vacío = siempre.
@export var requires_flag: String = ""
