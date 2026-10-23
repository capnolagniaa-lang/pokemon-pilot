class_name TrainerData
extends Resource
## Un entrenador vivo (docs/PLAN_ENTRENADORES.md): quién es, cómo es y qué hace. Datos a mano en
## data/trainers/<id>.tres. Lo que cambia jugando (equipo actual, memoria, récord) vive en TrainerState y se
## guarda con la partida.

@export var id: String = ""
@export var display_name: String = ""
## Rol corto para la interfaz ("Rival", "Estratega", "Explorador").
@export var title: String = ""
## Hoja de sprites estilo FireRed (frames de 16×32: quieto abajo/arriba/costado y pasos).
@export var sprite: Texture2D
@export var personality: PersonalityData
## Equipo con el que empieza (hasta 3 en el prototipo).
@export var starting_team: Array[TrainerMon] = []
## Especies que puede sumar (capturas simuladas, fase E-6). Vacío = las de las zonas que recorre.
@export var species_pool: Array[SpeciesData] = []
## Rutina diaria (fase E-5). En E-0 aparece en el lugar del primer bloque.
@export var routine: Array[RoutineBlock] = []
## Frases (fase E-1/E-4): saludo, desafío, al ganar, al perder.
@export var lines: Dictionary = {}
