class_name BoonData
extends Resource
## Una bendición del Modo Desafío (R-2 de docs/PROPUESTA_ROGUELIKE.md): la ofrece un legendario al limpiar una sala y
## cambia cómo pelea tu Pokémon por el resto de la partida. Los datos salen de tools/build_boons.py (tabla BOONS →
## data/boons/<id>.tres); lo que hace cada `effect` está en RogueBoons.

@export var id: String = ""
@export var display_name: String = ""
## Quién la da: id del dador en data/rogue/bendiciones.json ("zapdos", "articuno", "moltres").
@export var giver: String = ""
## A qué se engancha (para la tarjeta): "ataque1".."ataque4", "esquive" o "pasiva".
@export var slot: String = "pasiva"
## Qué hace (clave de RogueBoons.EFFECTS): hit_status, hit_blast, dodge_blast, bonus_vs_status, chain, kill_pp,
## kill_blast, thorns, first_strike, phoenix.
@export var effect: String = ""
## Números y datos del efecto (según `effect`): slot (0-3 o -1 = cualquiera), status, chance, pct, power, radius...
@export var params: Dictionary = {}
## Claves de `params` que crecen con la rareza y el nivel de la bendición.
@export var scaled: PackedStringArray = []
## Texto de la tarjeta. `{clave}` = el valor, `{clave%}` = como porcentaje, `{tecla}` = la tecla de su ranura.
@export_multiline var text: String = ""


## El número de la ranura de ataque (0-3), o -1 si no es de una ranura.
func slot_index() -> int:
	return int(slot.trim_prefix("ataque")) - 1 if slot.begins_with("ataque") else -1


func slot_label() -> String:
	match slot:
		"esquive":
			return "Esquive"
		"pasiva":
			return "Pasiva"
	return "Ataque %d" % (slot_index() + 1)
