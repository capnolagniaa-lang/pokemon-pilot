extends Node
## Estado de la partida en curso (equipo, objetos, opciones). No conoce escenas ni archivos: el guardado lo
## hace SaveManager con to_dict() / from_dict().

## Máximo de Pokémon en el equipo (más adelante, lo que no entre irá a una caja).
const MAX_PARTY := 6

var party: Array[CreatureInstance] = []
var active_index := 0
var balls := 0
## Si es false no aparecen salvajes (lo usa el autotest de recorrido).
var wilds_enabled := true
## Modo práctica (se elige al iniciar): si tu Pokémon se debilita, vuelve al instante con la vida al máximo.
var practice_mode := true
## Salvajes de prueba (Opciones): en todo el mapa aparecen solo Pidgey, Bellsprout, Rattata y Vulpix, como en la
## fase de prueba del combate. Apagado: mandan las tablas de encuentros de cada zona (editor de mapas).
var wild_test_pool := false
## Entrenadores vivos (en prueba; docs/PLAN_ENTRENADORES.md): se elige al iniciar o en Opciones y se guarda.
## Apagado: no aparecen entrenadores ni se registra memoria (el juego queda como antes). Usar set_living_trainers.
var living_trainers := false
## Estado de cada entrenador vivo (equipo actual, récord, memoria): id -> TrainerState. Se crea al primer uso.
var trainers: Dictionary = {}
## Dificultad de la IA salvaje (se elige al iniciar). Por defecto Normal.
var difficulty: AiDifficulty
## Segundos jugados (los suma el mundo mientras corre).
var play_time := 0.0
## Dónde aparece el entrenador al cargar una partida (INF = el punto de inicio de la región). La escribe
## SaveManager al guardar (posición del entrenador) y la consume World al arrancar.
var trainer_position := Vector2.INF
## Zona en la que se guardó (para mostrarla en el resumen de la partida).
var zone_name := ""
## Pokédex: especies vistas (aparecieron en pantalla) y luchadas (peleaste contra ellas o las tuviste en el
## equipo). id de especie -> true. Solo las vistas se muestran en la Pokédex; el resto, como silueta.
var pokedex_seen: Dictionary = {}
var pokedex_fought: Dictionary = {}


func _ready() -> void:
	difficulty = DB.difficulties.get("normal")


func set_difficulty(id: String) -> void:
	if DB.difficulties.has(id):
		difficulty = DB.difficulties[id]


func difficulty_id() -> String:
	for id in DB.difficulties:
		if DB.difficulties[id] == difficulty:
			return id
	return "normal"


func new_game(starter: SpeciesData) -> void:
	party.clear()
	party.append(CreatureInstance.create(starter, DB.config.starting_level))
	active_index = 0
	balls = DB.config.starting_balls
	play_time = 0.0
	trainer_position = Vector2.INF
	zone_name = ""
	pokedex_seen.clear()
	pokedex_fought.clear()
	trainers.clear()
	mark_fought(starter)
	Events.party_changed.emit()
	Events.game_started.emit()


## Prende o apaga los entrenadores vivos (el mundo los saca o los guarda al momento).
func set_living_trainers(on: bool) -> void:
	if on == living_trainers:
		return
	living_trainers = on
	Events.living_trainers_changed.emit(on)


## Estado de un entrenador vivo (lo crea con su equipo inicial la primera vez).
func trainer_state(data: TrainerData) -> TrainerState:
	if not trainers.has(data.id):
		trainers[data.id] = TrainerState.create(data)
	return trainers[data.id]


func active() -> CreatureInstance:
	return party[active_index] if active_index < party.size() else null


## Le da experiencia a un Pokémon del equipo. Si sube de nivel y aprende movimientos, los equipa en una
## ranura libre (si hay; si no, quedan en la ficha) y emite move_learned. Devuelve el texto para el mensaje
## (" — ¡X subió a Nv. N! ¡Aprendió Y!") o "" si no subió.
func grant_exp(inst: CreatureInstance, amount: int) -> String:
	var before := inst.level
	if inst.add_exp(amount) == 0:
		return ""
	var text := " — ¡%s subió a Nv. %d!" % [inst.display_name(), inst.level]
	for m in inst.moves_learned_between(before, inst.level):
		var equipped := inst.auto_equip(m)
		text += " ¡Aprendió %s!" % m.display_name
		Events.move_learned.emit(inst, m)
		if equipped:
			Events.equipment_changed.emit(inst)
	return text


## Suma un Pokémon al equipo. Devuelve false si ya hay MAX_PARTY (lo usará la captura de la Etapa 6).
func add_to_party(inst: CreatureInstance) -> bool:
	if inst == null or party.size() >= MAX_PARTY:
		return false
	party.append(inst)
	mark_fought(inst.species)
	Events.party_changed.emit()
	return true


## Cambia el Pokémon activo (el que te sigue). No se puede elegir uno debilitado.
func set_active(index: int) -> bool:
	if index < 0 or index >= party.size() or party[index].hp <= 0.0:
		return false
	active_index = index
	Events.party_changed.emit()
	return true


## Mueve un Pokémon del equipo de lugar (el activo sigue siendo el mismo Pokémon).
func move_in_party(from: int, to: int) -> bool:
	if from < 0 or from >= party.size() or to < 0 or to >= party.size() or from == to:
		return false
	var current := active()
	var inst := party[from]
	party.remove_at(from)
	party.insert(to, inst)
	active_index = party.find(current)
	Events.party_changed.emit()
	return true


# --- Pokédex -------------------------------------------------------------------------

## Registra una especie como vista. Devuelve true si es la primera vez (emite pokedex_registered).
func mark_seen(sp: SpeciesData) -> bool:
	if sp == null or pokedex_seen.has(sp.id):
		return false
	pokedex_seen[sp.id] = true
	Events.pokedex_registered.emit(sp)
	return true


## Registra una especie como luchada (también queda vista).
func mark_fought(sp: SpeciesData) -> void:
	if sp == null:
		return
	mark_seen(sp)
	pokedex_fought[sp.id] = true


func has_seen(sp: SpeciesData) -> bool:
	return pokedex_seen.has(sp.id)


func has_fought(sp: SpeciesData) -> bool:
	return pokedex_fought.has(sp.id)


# --- Guardado ------------------------------------------------------------------------

func to_dict() -> Dictionary:
	var members := []
	for inst in party:
		members.append(inst.to_dict())
	return {"party": members, "active_index": active_index, "balls": balls, "practice_mode": practice_mode,
		"wild_test_pool": wild_test_pool, "difficulty": difficulty_id(), "play_time": play_time,
		"trainer_position": [trainer_position.x, trainer_position.y] if trainer_position != Vector2.INF else null,
		"zone_name": zone_name, "pokedex": {"seen": pokedex_seen.keys(), "fought": pokedex_fought.keys()},
		"living_trainers": living_trainers, "trainers": _trainers_dict()}


func _trainers_dict() -> Dictionary:
	var out := {}
	for id in trainers:
		out[id] = trainers[id].to_dict()
	return out


## Carga una partida. Devuelve false si no queda ningún Pokémon válido (y no toca el estado actual).
## Los avisos (especies o movimientos que ya no existen) quedan en `warnings`.
func from_dict(d: Dictionary, warnings: Array = []) -> bool:
	var members: Array[CreatureInstance] = []
	var raw = d.get("party", [])
	if raw is Array:
		for m in raw:
			if m is Dictionary and members.size() < MAX_PARTY:
				var inst := CreatureInstance.from_dict(m, warnings)
				if inst != null:
					members.append(inst)
	if members.is_empty():
		warnings.append("La partida no tiene ningún Pokémon válido.")
		return false
	party = members
	active_index = clampi(int(d.get("active_index", 0)), 0, party.size() - 1)
	balls = int(d.get("balls", DB.config.starting_balls))
	practice_mode = bool(d.get("practice_mode", true))
	wild_test_pool = bool(d.get("wild_test_pool", false))
	living_trainers = bool(d.get("living_trainers", false))
	trainers.clear()
	var saved_trainers = d.get("trainers", {})
	if saved_trainers is Dictionary:
		for id in saved_trainers:
			if DB.trainers.has(id) and saved_trainers[id] is Dictionary:
				trainers[id] = TrainerState.from_dict(DB.trainers[id], saved_trainers[id])
	set_difficulty(str(d.get("difficulty", "normal")))
	play_time = maxf(0.0, float(d.get("play_time", 0.0)))
	var pos = d.get("trainer_position", null)
	trainer_position = Vector2(float(pos[0]), float(pos[1])) if pos is Array and pos.size() == 2 else Vector2.INF
	zone_name = str(d.get("zone_name", ""))
	pokedex_seen.clear()
	pokedex_fought.clear()
	var dex = d.get("pokedex", {})
	if dex is Dictionary:
		for key in ["seen", "fought"]:
			var ids = dex.get(key, [])
			if ids is Array:
				for id in ids:
					if DB.species.has(str(id)):
						(pokedex_seen if key == "seen" else pokedex_fought)[str(id)] = true
	for inst in party:  # guardados viejos (sin Pokédex): al menos el equipo
		pokedex_seen[inst.species.id] = true
		pokedex_fought[inst.species.id] = true
	Events.party_changed.emit()
	return true
