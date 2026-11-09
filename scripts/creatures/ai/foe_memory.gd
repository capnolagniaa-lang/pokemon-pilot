class_name FoeMemory
extends RefCounted
## Lo que la IA fue viendo de cómo jugás (docs/PLAN_IA.md, IA-7): hacia dónde esquivás, de qué distancia peleás, qué ataques
## tiene cada Pokémon tuyo y si repetís siempre el mismo. No hace trampa: solo sabe lo que vio. Cada TacticalMind tiene la
## suya; en una pelea de entrenador, todo su equipo comparte una (TrainerBattle), así lo aprendido sigue al cambiar.

const MEMORY := 10
## Un ataque es costumbre si es más de esta parte de los últimos que usaste.
const HABIT_WINDOW := 6
const HABIT_MIN := 4
const HABIT_SHARE := 0.6

## Lo que aprende la IA nueva de cómo jugás (PlayerModel, Fase 4 de docs/IA_AUDITORIA.md).
var model := PlayerModel.new()
var dodge_sides: Array[int] = []
var ranged_seen: Array[bool] = []
var _recent: Array[MoveData] = []
var _seen := {}  # CreatureInstance -> {MoveData: veces}


func note_dodge(side: int) -> void:
	dodge_sides.append(side)
	if dodge_sides.size() > MEMORY:
		dodge_sides.pop_front()


## Usaste este ataque con este Pokémon.
func note_move(user: CreatureInstance, m: MoveData, ranged: bool) -> void:
	ranged_seen.append(ranged)
	if ranged_seen.size() > MEMORY:
		ranged_seen.pop_front()
	_recent.append(m)
	if _recent.size() > HABIT_WINDOW:
		_recent.pop_front()
	if not _seen.has(user):
		_seen[user] = {}
	_seen[user][m] = int(_seen[user].get(m, 0)) + 1


## Los ataques que le viste a ese Pokémon.
func seen_moves(user: CreatureInstance) -> Array:
	return _seen.get(user, {}).keys()


## El ataque que repetís, o null si todavía no se nota.
func habit() -> MoveData:
	if _recent.size() < HABIT_MIN:
		return null
	for m in _recent:
		if float(_recent.count(m)) / _recent.size() >= HABIT_SHARE:
			return m
	return null


func clear() -> void:
	model.clear()
	dodge_sides.clear()
	ranged_seen.clear()
	_recent.clear()
	_seen.clear()
