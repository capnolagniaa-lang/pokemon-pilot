class_name ExtraPitch
extends Resource
## Una cancha de fútbol agregada a una zona (el estadio de Fucsia): un partido de adorno que se juega solo, sin parar. Lo pone
## `ExtraContent` al cargar la zona.

@export var id: String = ""
@export var zone_id: String = ""
@export var species_id: String = ""
@export var players_per_team: int = 4
## Las líneas de la cancha, en píxeles locales de la zona.
@export var field: Rect2 = Rect2()
## Mitad del alto del arco, en píxeles.
@export var goal_half: float = 24.0
@export var team_names: PackedStringArray = ["Celeste", "Azul"]
