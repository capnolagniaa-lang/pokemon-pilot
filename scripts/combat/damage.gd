class_name Damage
extends RefCounted
## Fórmula de daño oficial (3ª gen en adelante):
##   ((2·Nivel/5 + 2) · Potencia · A/D / 50 + 2) · STAB · efectividad · variación(0.85..1)
## A/D = Ataque/Defensa (físico) o At.Esp./Def.Esp. (especial). La vida está escalada por
## CreatureInstance.HP_SCALE para que los combates en tiempo real duren varios golpes.

const STAB := 1.5


static func resolve(hit: HitInfo, defender: CreatureInstance) -> float:
	var move := hit.move
	hit.effectiveness = flat(DB.type_chart.get_multiplier(move.element, defender.types()))
	if move.category == MoveData.Category.STATUS or move.power <= 0.0:
		return 0.0
	var def_stat := "defense" if move.category == MoveData.Category.PHYSICAL else "sp_defense"
	var d := float(maxi(1, defender.stat(def_stat)))
	var power := move.power * move.power_mult
	var base := (2.0 * hit.attacker_level / 5.0 + 2.0) * power * hit.attack / d / 50.0 + 2.0 * move.power_mult
	var stab := STAB if move.element in hit.attacker_types else 1.0
	return base * stab * hit.effectiveness * hit.damage_mult * CombatWeather.damage_mult(move.element, hit.attacker if is_instance_valid(hit.attacker) else null) * randf_range(0.85, 1.0)


## Tipos aplanados (ajuste "flat_types", lo prende el Modo Desafío; decisión del usuario 2026-11-12: que el tipo ayude
## pero no decida): la ventaja queda en ×1,25, y la desventaja y la inmunidad en ×0,8.
const FLAT_STRONG := 1.25
const FLAT_WEAK := 0.8


static func flat(mult: float) -> float:
	if not GameState.setting("flat_types"):
		return mult
	return FLAT_STRONG if mult > 1.0 else (FLAT_WEAK if mult < 1.0 else 1.0)
