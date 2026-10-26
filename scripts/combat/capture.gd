class_name Capture
extends RefCounted
## Fórmula oficial de captura de la 3ª generación (docs/PLAN_CAPTURA_MOCHILA.md):
##   a = ((3·PSmáx − 2·PS) · tasa · bola) / (3·PSmáx) · estado      (estado: Dormido/Congelado ×2;
##                                                                    Paralizado/Envenenado/Quemado ×1,5)
##   si a ≥ 255 → atrapado; si no, b = 1048560 / √(√(16711680 / a)) y se hacen 4 tiradas (0..65535 < b):
##   cada una que pasa es un temblor de la bola; con las 4, queda atrapado.
## La vida está escalada (HP_SCALE) pero la fórmula usa la proporción, así que da igual.

const STATUS_BONUS := {"dormido": 2.0, "congelado": 2.0, "paralizado": 1.5, "envenenado": 1.5, "quemado": 1.5}
const SHAKES_TO_CATCH := 4


## Valor "a" de la fórmula (sin tope).
static func catch_value(inst: CreatureInstance, ball_mult: float, status_ids: Array = []) -> float:
	var max_hp := inst.max_hp()
	var hp := clampf(inst.hp, 1.0, max_hp)
	var bonus := 1.0
	for s in status_ids:
		bonus = maxf(bonus, STATUS_BONUS.get(s, 1.0))
	return (3.0 * max_hp - 2.0 * hp) * inst.species.capture_rate * ball_mult / (3.0 * max_hp) * bonus \
		* float(GameState.setting("catch_mult"))  # Ajustes del juego


## Cuántas tiradas pasa (0-4). 4 = atrapado. La Master Ball (mult ≥ 255) atrapa siempre.
static func roll(inst: CreatureInstance, ball_mult: float, status_ids: Array = []) -> int:
	if ball_mult >= 255.0:
		return SHAKES_TO_CATCH
	var a := catch_value(inst, ball_mult, status_ids)
	if a >= 255.0:
		return SHAKES_TO_CATCH
	var b := 1048560.0 / sqrt(sqrt(16711680.0 / maxf(a, 0.0001)))
	var shakes := 0
	while shakes < SHAKES_TO_CATCH and randi_range(0, 65535) < b:
		shakes += 1
	return shakes


## Probabilidad de atraparlo (para la interfaz y los tests): (b/65536)^4.
static func chance(inst: CreatureInstance, ball_mult: float, status_ids: Array = []) -> float:
	if ball_mult >= 255.0:
		return 1.0
	var a := catch_value(inst, ball_mult, status_ids)
	if a >= 255.0:
		return 1.0
	var b := 1048560.0 / sqrt(sqrt(16711680.0 / maxf(a, 0.0001)))
	return pow(minf(b / 65536.0, 1.0), 4)
