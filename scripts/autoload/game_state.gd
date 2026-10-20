extends Node
## Estado de la partida en curso (equipo, objetos). No conoce escenas ni nodos.

var party: Array[CreatureInstance] = []
var active_index := 0
var balls := 0


func new_game(starter: SpeciesData) -> void:
	party.clear()
	party.append(CreatureInstance.create(starter, DB.config.starting_level))
	active_index = 0
	balls = DB.config.starting_balls
	Events.party_changed.emit()
	Events.game_started.emit()


func active() -> CreatureInstance:
	return party[active_index] if active_index < party.size() else null
