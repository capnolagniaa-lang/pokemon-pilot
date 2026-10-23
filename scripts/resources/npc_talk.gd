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
@export var heal: bool = false


func applies() -> bool:
	for f in requires:
		if not GameState.has_flag(f):
			return false
	for f in forbids:
		if GameState.has_flag(f):
			return false
	return true
