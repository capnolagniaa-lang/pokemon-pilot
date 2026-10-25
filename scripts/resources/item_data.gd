class_name ItemData
extends Resource
## Un objeto de la mochila (docs/PLAN_CAPTURA_MOCHILA.md). Datos oficiales de PokeAPI (nombre, descripción,
## ícono) generados por tools/fetch_items.py en data/items/*.tres; el efecto está adaptado al tiempo real.

## Bolsillos de la mochila, como en FireRed.
enum Pocket { ITEMS, BALLS, KEY }

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var pocket: Pocket = Pocket.ITEMS
## Orden dentro del bolsillo (como en los juegos).
@export var sort_order: int = 0
## Precio oficial en la Tienda Pokémon (PokeAPI `cost`, de tools/fetch_items.py). 0 = no se compra ni se vende
## (objetos clave). Se vende a la mitad (sell_price).
@export var price: int = 0

@export_group("Pokéball")
## Multiplicador de captura (Poké Ball 1, Super Ball 1,5, Ultra Ball 2). >= 255 = atrapa siempre (Master Ball).
@export var catch_mult: float = 0.0

@export_group("Curación")
## PS oficiales que cura (se multiplican por CreatureInstance.HP_SCALE en el juego).
@export var heal_hp: float = 0.0
## Cura toda la vida (Poción Máxima).
@export var heal_full: bool = false
## Estados que cura (ids de data/status); "all" = todos los problemas de estado.
@export var cures: PackedStringArray = []
## Revivir: vuelve con esta fracción de la vida (0 = no revive).
@export_range(0.0, 1.0) var revive_ratio: float = 0.0

@export_group("Nivel")
## Niveles que sube (Caramelo Raro: 1), con la EXP justa y aprendiendo lo que toque (GameState.grant_exp).
@export var level_up: int = 0

@export_group("Evolución")
## Piedra evolutiva (Lunar, Fuego, Agua, Trueno, Hoja, Solar): hace evolucionar a quien tenga esa evolución en
## SpeciesData.evolutions (método "piedra" con este id).
@export var evolves: bool = false

@export_group("Máquina técnica")
## MT: enseña este movimiento al Pokémon sobre el que se usa (se gasta, como en la 3ª gen).
@export var teaches_move: MoveData

@export_group("Uso")
## Se puede usar en combate con la ranura rápida (C).
@export var usable_in_battle: bool = true
## Segundos que tu Pokémon queda expuesto al usarlo en combate.
@export var use_time: float = 0.6


## Problemas de estado que cura "all" (Cura Total). Las mejoras propias (Arraigo, Síntesis...) no.
const BAD_STATUSES := ["quemado", "paralizado", "congelado", "envenenado", "dormido", "desorientado",
	"ralentizado", "enraizado", "herido", "empapado"]


func is_ball() -> bool:
	return catch_mult > 0.0


func cures_status(id: String) -> bool:
	return cures.has(id) or (cures.has("all") and BAD_STATUSES.has(id))


## Si sirve sobre un Pokémon (para no gastarlo en vano).
func can_use_on(inst: CreatureInstance, active_statuses: Array = []) -> bool:
	if is_ball():
		return false
	if teaches_move != null:
		return not inst.learned_moves().has(teaches_move)
	if level_up > 0:
		return inst.hp > 0.0 and inst.level < CreatureInstance.MAX_LEVEL
	if evolves:
		return inst.hp > 0.0 and inst.species.evolutions.any(func(e): return e.method == "piedra" and e.item == id)
	if inst.hp <= 0.0:
		return revive_ratio > 0.0
	if revive_ratio > 0.0:
		return false
	if (heal_hp > 0.0 or heal_full) and inst.hp < inst.max_hp():
		return true
	for s in active_statuses:
		if cures_status(s):
			return true
	return false


## Lo que te pagan en la Tienda (la mitad, como en los juegos). 0 = no se vende.
func sell_price() -> int:
	return price / 2 if pocket != Pocket.KEY else 0
