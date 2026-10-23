class_name EncounterArea
extends Resource
## Área de encuentros pintada sobre una zona (editor de mapas): en sus celdas, los ajustes pisan la tabla de la
## zona. Un ajuste de una especie que ya está en la tabla (mismo "dónde") cambia su peso y niveles; una especie
## que no está se suma solo para el área; peso 0 = ahí no aparece.

@export var name: String = "Área"
@export var color: Color = Color(1.0, 0.4, 0.8)
## Celdas (locales de la zona) del área. Una celda pertenece a lo sumo a un área.
@export var cells: Array[Vector2i] = []
@export var adjustments: Array[EncounterEntry] = []

## Colores para áreas nuevas (bien distintos entre sí).
const PALETTE := [Color(1.0, 0.4, 0.8), Color(0.3, 0.8, 1.0), Color(1.0, 0.7, 0.2), Color(0.5, 1.0, 0.4),
	Color(0.7, 0.5, 1.0), Color(1.0, 0.35, 0.35), Color(0.2, 1.0, 0.85), Color(0.95, 0.95, 0.4)]


func copy() -> EncounterArea:
	var a := EncounterArea.new()
	a.name = name
	a.color = color
	a.cells = cells.duplicate()
	for e in adjustments:
		a.adjustments.append(e.copy())
	return a
