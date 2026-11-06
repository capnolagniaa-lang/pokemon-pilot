class_name ExtraPen
extends Resource
## Un corral agregado a una zona (el mini estadio de Fucsia): Pokémon de adorno que pasean adentro. No pelean ni se
## atrapan. Lo pone `ExtraContent` al cargar la zona.

@export var id: String = ""
@export var zone_id: String = ""
## Dónde pasean, en celdas locales de la zona.
@export var area: Rect2i = Rect2i()
## Uno por cada especie de la lista.
@export var species: PackedStringArray = []
