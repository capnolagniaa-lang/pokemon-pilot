class_name Damage
extends RefCounted
## Fórmula de daño oficial (3ª gen en adelante):
##   ((2·Nivel/5 + 2) · Potencia · A/D / 50 + 2) · STAB · efectividad · variación(0.85..1)
## A/D = Ataque/Defensa (físico) o At.Esp./Def.Esp. (especial). La vida está escalada por
## CreatureInstance.HP_SCALE para que los combates en tiempo real duren varios golpes.

const STAB := 1.5


static func resolve(hit: HitInfo, defender: CreatureInstance) -> float:
	var move := hit.move
	hit.effectiveness = DB.type_chart.get_multiplier(move.element, defender.species.types)
	if move.category == MoveData.Category.STATUS or move.power <= 0.0:
		return 0.0
	var def_stat := "defense" if move.category == MoveData.Category.PHYSICAL else "sp_defense"
	var d := float(maxi(1, defender.stat(def_stat)))
	var base := (2.0 * hit.attacker_level / 5.0 + 2.0) * move.power * hit.attack / d / 50.0 + 2.0
	var stab := STAB if move.element in hit.attacker_types else 1.0
	return base * stab * hit.effectiveness * randf_range(0.85, 1.0)
