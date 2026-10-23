class_name NpcTalk
extends Resource
## Una conversación (docs/PLAN_HISTORIA.md, H-0): lo que dice un NPC o un disparador si se cumplen sus
## condiciones de banderas (GameState.story_flags), y lo que pasa al terminar (banderas, objetos, curar).
## Un NpcData prueba sus `talks` en orden y usa la primera que se cumple.

## Banderas que tienen que estar puestas / que no tienen que estar.
@export var requires: PackedStringArray = []
@export var forbids: PackedStringArray = []
## Quién habla (vacío = el nombre del NPC).
@export var speaker: String = ""
## Una línea por globo (se escribe de a poco; E, Espacio, Enter o clic avanza).
@export_multiline var lines: PackedStringArray = []
## Al terminar: banderas que se ponen, objetos que se dan (id de data/items -> cantidad), curar el equipo.
@export var set_flags: PackedStringArray = []
@export var give_items: Dictionary = {}
## Objetos que te saca (ej. el Correo-Oak al entregárselo). id de data/items -> cantidad.
@export var take_items: Dictionary = {}
@export var heal: bool = false

@export_group("Efectos de historia (H-1)")
## Pregunta Sí/No después de las líneas: si contesta que no, no pasa nada más (ej. "¿Querés a Bulbasaur?").
@export var confirm: String = ""
## Te da este Pokémon (tu inicial) al nivel `give_level` (0 = el de GameConfig.starting_level).
@export var give_pokemon: SpeciesData
@export var give_level: int = 0
## Pelea contra el entrenador de esta persona (id de NpcData). `battle_no_blackout`: si perdés, la historia sigue
## ahí mismo con el equipo curado (como la 1ª pelea contra el rival).
@export var battle_npc: String = ""
@export var battle_no_blackout: bool = false
## Lo que se dice después de los efectos (ej. el rival: "¡Entonces yo me quedo con Charmander!").
@export var after_speaker: String = ""
@export_multiline var after_lines: PackedStringArray = []
## Acción especial al terminar las líneas (StoryDirector.register_action), ej. "torneo": la recepción del torneo.
@export var action: String = ""
## Al terminar te lleva a esta zona y celda (fundido), ej. Oak te lleva al laboratorio.
@export var warp_zone: String = ""
@export var warp_cell: Vector2i = Vector2i.ZERO


func applies() -> bool:
	for f in requires:
		if not GameState.has_flag(f):
			return false
	for f in forbids:
		if GameState.has_flag(f):
			return false
	return true
