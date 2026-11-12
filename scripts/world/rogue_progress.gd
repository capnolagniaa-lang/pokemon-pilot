class_name RogueProgress
extends RefCounted
## Progreso permanente del Modo Desafío (docs/PROPUESTA_ROGUELIKE.md, decisiones del usuario 2026-11-11): qué Pokémon
## tenés desbloqueados como inicial. De entrada, los 3 de `BASE`; atrapar uno en una partida del modo desbloquea su
## especie para las próximas. Va en un archivo propio de esta PC (`user://desafio.json`), aparte de las partidas de la
## historia: no lo toca SaveManager ni se manda al servidor.

const BASE: Array[String] = ["charmander", "squirtle", "bulbasaur"]
const DEFAULT_PATH := "user://desafio.json"
## En los autotests y las vitrinas se usa este otro: el progreso de verdad no se toca.
const TEST_PATH := "user://desafio_autotest.json"

# (Sin variables estáticas: Godot descarga este script cuando nadie lo usa, entre escena y escena, y se perderían. Se lee
# el archivo cada vez, que es chico.)


static func path() -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--autotest") or a.begins_with("--showcase"):
			return TEST_PATH
	return DEFAULT_PATH


## El archivo, leído ({} si no está o está roto: se arranca de los de base, sin romper nada).
static func _read() -> Dictionary:
	if not FileAccess.file_exists(path()):
		return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(path()))
	return d if d is Dictionary else {}


static func _write(d: Dictionary) -> void:
	var f := FileAccess.open(path(), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(d, "  "))


## Las especies desbloqueadas, en el orden en que se consiguieron (primero las de base).
static func unlocked() -> Array[String]:
	var out: Array[String] = BASE.duplicate()
	for id in _read().get("unlocked", []):
		if id is String and DB.species.has(id) and not out.has(id) and in_mode(id):
			out.append(id)
	return out


## El modo es solo de la primera generación (decisión del usuario 2026-11-12): una especie de otra región que
## hubiera quedado desbloqueada de antes no se ofrece (queda en el archivo, por si vuelve).
const MAX_DEX := 151


static func in_mode(id: String) -> bool:
	return DB.species.has(id) and DB.species[id].dex <= MAX_DEX


static func is_unlocked(id: String) -> bool:
	return unlocked().has(id)


## Desbloquea una especie como inicial. Devuelve true si era nueva.
static func unlock(id: String) -> bool:
	var list := unlocked()
	if list.has(id) or not in_mode(id):
		return false
	list.append(id)
	var d := _read()
	d["unlocked"] = list
	_write(d)
	return true


## Suerte (paso O-c de docs/PROPUESTA_ROGUELIKE.md, decisión del usuario 2026-11-11): sale de la Pokédex del modo. Un
## punto cada `LUCK_EVERY` especies desbloqueadas **por captura** (los 3 de base no cuentan), hasta `LUCK_CAP`; un inicial
## shiny suma `LUCK_SHINY` aparte. Cada punto le da a cada opción ofrecida (bendiciones y objetos) `LUCK_STEP` de
## probabilidad de subir un escalón de rareza (RogueBoons.roll_rarity).
const LUCK_EVERY := 3
const LUCK_CAP := 6
const LUCK_SHINY := 2
const LUCK_STEP := 0.04


static func caught_count() -> int:
	return maxi(0, unlocked().size() - BASE.size())


static func luck(shiny := false) -> int:
	return mini(LUCK_CAP, caught_count() / LUCK_EVERY) + (LUCK_SHINY if shiny else 0)


## Cosas que ya pasaron una vez (p. ej. "intro": Mew ya te contó la historia).
static func has_flag(flag: String) -> bool:
	return flag in _read().get("flags", [])


static func set_flag(flag: String) -> void:
	var d := _read()
	var flags: Array = d.get("flags", [])
	if not flags.has(flag):
		flags.append(flag)
		d["flags"] = flags
		_write(d)
