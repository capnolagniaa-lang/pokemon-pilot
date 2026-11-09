class_name AIProfile
extends Resource
## Perillas de la IA nueva de entrenadores (docs/IA_AUDITORIA.md): una por dificultad (`data/ai/profiles/<id de la
## dificultad>.tres`, DB.ai_profiles) y, si hace falta, una propia de un estilo de entrenador (`TrainerStyle.profile`).
## La dificultad sale de **cómo piensa**, nunca de más daño, más vida ni reflejos perfectos. Cada fase suma lo suyo.

@export var id: String = ""
@export var display_name: String = ""

@export_group("Percepción (Fase 2)")
## Cuánto tarda en enterarse de lo que pasa (s): ve la pelea como era hace este tiempo. Rango pedido: 0,15 a 0,4.
@export_range(0.1, 0.6) var perception_delay: float = 0.25
## Variación del retraso (± s), cambia cada `JITTER_EVERY` s: no reacciona siempre al mismo tiempo exacto.
@export_range(0.0, 0.2) var perception_jitter: float = 0.04

## Retraso tolerado como mínimo y máximo (el usuario pidió 0,15 a 0,4 según la dificultad).
const MIN_DELAY := 0.15
const MAX_DELAY := 0.4


## El perfil de una criatura: el de su estilo de entrenador si tiene uno propio; si no, el de la dificultad
## (la "personalizada" usa el de Normal).
static func of(c: Node) -> AIProfile:
	var st = c.get("trainer_style") if c != null else null
	if st is TrainerStyle and st.profile != null:
		return st.profile
	return current()


static func current() -> AIProfile:
	var id: String = GameState.difficulty_id() if GameState.difficulty != null else "normal"
	if DB.ai_profiles.has(id):
		return DB.ai_profiles[id]
	return DB.ai_profiles.get("normal", AIProfile.new())


## Retraso de percepción dentro del rango acordado.
func delay() -> float:
	return clampf(perception_delay, MIN_DELAY, MAX_DELAY)
