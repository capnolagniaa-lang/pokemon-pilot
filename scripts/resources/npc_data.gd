class_name NpcData
extends Resource
## Una persona del mundo que habla (docs/PLAN_HISTORIA.md, H-0). Datos en data/story/npcs/<id>.tres (los arma
## tools/build_story_npcs.py desde los NPC reales de FireRed). StoryDirector la saca cuando su zona está cargada.

@export var id: String = ""
@export var display_name: String = ""
@export var zone_id: String = ""
## Celda local de la zona (la de FireRed ya pasada a la escala del juego).
@export var cell: Vector2i = Vector2i.ZERO
## Sprite: art/pret/characters/<gfx>.png (hoja de FireRed: 0 abajo, 1 arriba, 2 costado).
@export var gfx: String = ""
@export var facing: Vector2i = Vector2i.DOWN
## Mira para los costados de vez en cuando.
@export var look_around: bool = false
## Solo aparece si están todas estas banderas / desaparece si está alguna de estas (bloqueos que se abren).
@export var show_if: PackedStringArray = []
@export var hide_if: PackedStringArray = []
## Conversaciones posibles: se usa la primera que se cumple.
@export var talks: Array[NpcTalk] = []

@export_group("Entrenador (E-1)")
## Si es entrenador: su equipo, frases y arena. Te desafía si te ve (o si le hablás) hasta que le ganes.
@export var trainer: TrainerData
## Cuántas celdas ve hacia donde mira (0 = no desafía al verte, solo si le hablás).
@export var sight: int = 4
## Si hablarle te desafía (el rival del laboratorio no: pelea por un disparador de la historia).
@export var challenge_on_talk: bool = true


## Bandera que queda puesta cuando le ganás.
func defeated_flag() -> String:
	return "vencido_" + id


func is_undefeated_trainer() -> bool:
	return trainer != null and not GameState.has_flag(defeated_flag())


func visible_now() -> bool:
	for f in show_if:
		if not GameState.has_flag(f):
			return false
	for f in hide_if:
		if GameState.has_flag(f):
			return false
	return true


func talk_now() -> NpcTalk:
	for t in talks:
		if t != null and t.applies():
			return t
	return null
