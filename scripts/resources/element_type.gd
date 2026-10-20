class_name ElementType
extends Resource
## Un elemento/tipo (fuego, agua...). Lo usan especies, ataques y el entorno.

@export var id: String = ""
@export var display_name: String = ""
@export var color: Color = Color.WHITE
## Brillo de los efectos de este elemento (>1 hace que el glow los ilumine).
@export var glow: float = 1.0
