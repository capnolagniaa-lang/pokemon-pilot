class_name StoryTrigger
extends Resource
## Disparador de historia (docs/PLAN_HISTORIA.md, H-0): pisar alguna celda de `rect` en la zona `zone_id`
## dispara la conversación `talk` si se cumplen sus condiciones (ej. Oak te frena en el pasto). Con
## `push_back` el entrenador vuelve un paso para atrás (bloqueo con aviso). Datos en data/story/triggers/.

@export var id: String = ""
@export var zone_id: String = ""
## Celdas locales de la zona que lo disparan.
@export var rect: Rect2i = Rect2i()
@export var talk: NpcTalk
## Una sola vez (se anota la bandera "visto_<id>").
@export var once: bool = true
@export var push_back: bool = false


func flag() -> String:
	return "visto_" + id


func ready_to_fire() -> bool:
	return talk != null and talk.applies() and not (once and GameState.has_flag(flag()))
