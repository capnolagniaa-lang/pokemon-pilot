class_name TrainerState
extends RefCounted
## Lo que cambia jugando de un entrenador vivo: su equipo actual, récord contra vos, memoria (creencias sobre
## tu forma de pelear, fase E-3) y relación (rivalidad ↔ respeto, fase E-7). Se guarda en la partida como
## diccionario (GameState.trainers) con ids, igual que el equipo del jugador.

var id: String = ""
var team: Array[CreatureInstance] = []
var wins: int = 0  # combates que te ganó
var losses: int = 0  # combates que perdió contra vos
## Creencias: nombre -> confianza 0..1 (ej. "mantiene_distancia": 0.7). Se llena desde E-3.
var memory: Dictionary = {}
## -1 respeto · +1 rivalidad (E-7).
var rivalry: float = 0.0


static func create(data: TrainerData) -> TrainerState:
	var s := TrainerState.new()
	s.id = data.id
	for mon in data.starting_team:
		if mon != null and mon.species != null:
			s.team.append(CreatureInstance.create(mon.species, mon.level))
	return s


func to_dict() -> Dictionary:
	var members := []
	for inst in team:
		members.append(inst.to_dict())
	return {"id": id, "team": members, "wins": wins, "losses": losses, "memory": memory.duplicate(), "rivalry": rivalry}


## Arma el estado desde la partida. Si falta o está roto, arranca de cero con el equipo inicial.
static func from_dict(data: TrainerData, d: Dictionary) -> TrainerState:
	var s := TrainerState.create(data)
	var raw = d.get("team", null)
	if raw is Array and not raw.is_empty():
		var members: Array[CreatureInstance] = []
		for m in raw:
			if m is Dictionary:
				var inst := CreatureInstance.from_dict(m)
				if inst != null:
					members.append(inst)
		if not members.is_empty():
			s.team = members
	s.wins = int(d.get("wins", 0))
	s.losses = int(d.get("losses", 0))
	var mem = d.get("memory", {})
	s.memory = mem if mem is Dictionary else {}
	s.rivalry = clampf(float(d.get("rivalry", 0.0)), -1.0, 1.0)
	return s
