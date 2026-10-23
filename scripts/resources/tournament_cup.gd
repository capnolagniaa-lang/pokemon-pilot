class_name TournamentCup
extends Resource
## Una copa del Torneo de Ciudad Plateada (docs/PLAN_TORNEO.md): cuántos Pokémon se inscriben, el nivel máximo para
## poder inscribirlos (peleás con tu equipo tal cual: no se nivela), la entrada y el premio. data/tournament/*.tres.

@export var id: String = ""
@export var display_name: String = ""
## Pokémon que se inscriben (3 o 6).
@export var team_size: int = 3
## Nivel máximo para inscribir a un Pokémon (0 = libre).
@export var level_cap: int = 15
@export var entry_fee: int = 500
@export var prize: int = 3000
## Orden en el menú de la recepción.
@export var order: int = 0
