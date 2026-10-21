extends Node
## Estado de la partida en curso (equipo, objetos). No conoce escenas ni nodos.

var party: Array[CreatureInstance] = []
var active_index := 0
var balls := 0
## Si es false no aparecen salvajes (lo usa el autotest de recorrido).
var wilds_enabled := true
## Modo práctica (se elige al iniciar): si tu Pokémon se debilita, vuelve al instante con la vida al máximo.
var practice_mode := true
## Dificultad de la IA salvaje (se elige al iniciar). Por defecto Normal.
var difficulty: AiDifficulty


func _ready() -> void:
	difficulty = DB.difficulties.get("normal")


func set_difficulty(id: String) -> void:
	if DB.difficulties.has(id):
		difficulty = DB.difficulties[id]


func new_game(starter: SpeciesData) -> void:
	party.clear()
	party.append(CreatureInstance.create(starter, DB.config.starting_level))
	active_index = 0
	balls = DB.config.starting_balls
	Events.party_changed.emit()
	Events.game_started.emit()


func active() -> CreatureInstance:
	return party[active_index] if active_index < party.size() else null
