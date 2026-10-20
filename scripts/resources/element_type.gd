class_name ElementType
extends Resource
## Un elemento/tipo (fuego, agua...). Lo usan especies, ataques y el entorno.

@export var id: String = ""
@export var display_name: String = ""
## Color principal de los efectos (cuerpo del proyectil, ondas, luz).
@export var color: Color = Color.WHITE
## Color del centro de los proyectiles (para el fuego: naranja, no blanco).
@export var core_color: Color = Color.WHITE
## Brillo de los efectos de este elemento (>1 hace que el glow los ilumine).
@export var glow: float = 1.0


func hdr(c: Color, factor: float = 1.0) -> Color:
	var g := glow * factor
	return Color(c.r * g, c.g * g, c.b * g, c.a)
