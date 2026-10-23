extends Node
## Estado de la partida en curso (equipo, objetos, opciones). No conoce escenas ni archivos: el guardado lo
## hace SaveManager con to_dict() / from_dict().

## Máximo de Pokémon en el equipo (más adelante, lo que no entre irá a una caja).
const MAX_PARTY := 6

var party: Array[CreatureInstance] = []
var active_index := 0
## Mochila (docs/PLAN_CAPTURA_MOCHILA.md): id de objeto (data/items) -> cantidad.
var bag: Dictionary = {}
## Bola que lanza E y objeto de la ranura rápida (C) en combate.
var selected_ball := "poke_ball"
var quick_item := "pocion"
## Compatibilidad: la cantidad de Poké Ball (antes había solo este contador).
var balls: int:
	get:
		return item_count("poke_ball")
	set(v):
		bag["poke_ball"] = maxi(0, v)
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
## Pokédex: especies atrapadas alguna vez (también cuentan como vistas y luchadas).
var pokedex_caught: Dictionary = {}
## Objetos del mapa ya recogidos: "zona:x,y" -> tiempo jugado cuando se recogió (vuelven a aparecer después).
var field_picked: Dictionary = {}
## Caja (como el PC): lo que atrapás con el equipo lleno. Sin límite por ahora.
var box: Array[CreatureInstance] = []


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
	bag = DB.config.starting_bag.duplicate()
	selected_ball = "poke_ball"
	quick_item = "pocion"
	play_time = 0.0
	trainer_position = Vector2.INF
	zone_name = ""
	pokedex_seen.clear()
	pokedex_fought.clear()
	pokedex_caught.clear()
	box.clear()
	trainers.clear()
	mark_fought(starter)
	pokedex_caught[starter.id] = true
	field_picked.clear()
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
	pokedex_caught[inst.species.id] = true  # lo que está en tu equipo cuenta como atrapado
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


# --- Mochila -------------------------------------------------------------------------

func item_count(id: String) -> int:
	return int(bag.get(id, 0))


func add_item(id: String, amount: int = 1) -> void:
	if not DB.items.has(id) or amount <= 0:
		return
	bag[id] = mini(item_count(id) + amount, 999)
	Events.bag_changed.emit()


## Saca objetos de la mochila. Devuelve false si no había suficientes.
func remove_item(id: String, amount: int = 1) -> bool:
	if item_count(id) < amount:
		return false
	bag[id] = item_count(id) - amount
	if bag[id] <= 0:
		bag.erase(id)
	Events.bag_changed.emit()
	return true


## Objetos de un bolsillo que tenés, en el orden de los juegos.
func pocket_items(pocket: int) -> Array[ItemData]:
	var out: Array[ItemData] = []
	for id in bag:
		var it: ItemData = DB.items.get(id)
		if it != null and it.pocket == pocket and item_count(id) > 0:
			out.append(it)
	out.sort_custom(func(a, b): return a.sort_order < b.sort_order)
	return out


## Usa un objeto sobre un Pokémon del equipo (cura, sana estados, revive) y lo gasta. `statuses` = el componente
## de estados de ese Pokémon si está afuera (los estados solo existen en el que está en el mundo). Devuelve un
## texto para el mensaje, o "" si no sirvió (no se gasta).
func use_item_on(id: String, inst: CreatureInstance, statuses: StatusEffects = null) -> String:
	var it: ItemData = DB.items.get(id)
	if it == null or item_count(id) <= 0:
		return ""
	var active_ids: Array = statuses.active.keys() if statuses != null else []
	if not it.can_use_on(inst, active_ids):
		return ""
	var parts: Array[String] = []
	if it.revive_ratio > 0.0:
		inst.hp = inst.max_hp() * it.revive_ratio
		parts.append("revivió")
	elif it.heal_full or it.heal_hp > 0.0:
		var before := inst.hp
		inst.hp = inst.max_hp() if it.heal_full else minf(inst.max_hp(), inst.hp + it.heal_hp * CreatureInstance.HP_SCALE)
		if inst.hp > before:
			parts.append("recuperó %d PS" % roundi(inst.hp - before))
	if statuses != null:
		for sid in active_ids:
			if it.cures_status(sid):
				var st: StatusEffect = statuses.active[sid]["status"]
				statuses.cure(st)
				parts.append("se curó de %s" % st.display_name.to_lower())
	remove_item(id)
	Events.item_used.emit(it, inst)
	if it.revive_ratio > 0.0:
		Events.equipment_changed.emit(inst)  # si es el activo, vuelve a salir
	return "%s: %s %s." % [it.display_name, inst.display_name(), ", ".join(parts)]


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


func has_caught(sp: SpeciesData) -> bool:
	return pokedex_caught.has(sp.id)


## Suma un Pokémon atrapado: al equipo si hay lugar, si no a la Caja. Devuelve "equipo" o "caja".
func add_caught(inst: CreatureInstance) -> String:
	mark_fought(inst.species)
	pokedex_caught[inst.species.id] = true
	if add_to_party(inst):
		return "equipo"
	box.append(inst)
	Events.box_changed.emit()
	return "caja"


## Caja: pasa un Pokémon al equipo (si hay lugar).
func box_to_party(index: int) -> bool:
	if index < 0 or index >= box.size() or party.size() >= MAX_PARTY:
		return false
	var inst := box[index]
	box.remove_at(index)
	party.append(inst)
	Events.box_changed.emit()
	Events.party_changed.emit()
	return true


## Caja: deja un Pokémon del equipo (no el último).
func party_to_box(index: int) -> bool:
	if index < 0 or index >= party.size() or party.size() <= 1:
		return false
	var current := active()
	var inst := party[index]
	party.remove_at(index)
	box.append(inst)
	active_index = maxi(0, party.find(current)) if current != inst else 0
	if party[active_index].hp <= 0.0:
		for i in party.size():
			if party[i].hp > 0.0:
				active_index = i
				break
	Events.box_changed.emit()
	Events.party_changed.emit()
	return true


func has_fought(sp: SpeciesData) -> bool:
	return pokedex_fought.has(sp.id)


# --- Guardado ------------------------------------------------------------------------

func to_dict() -> Dictionary:
	var members := []
	for inst in party:
		members.append(inst.to_dict())
	return {"party": members, "active_index": active_index, "bag": bag.duplicate(), "selected_ball": selected_ball,
		"quick_item": quick_item, "practice_mode": practice_mode,
		"wild_test_pool": wild_test_pool, "difficulty": difficulty_id(), "play_time": play_time,
		"trainer_position": [trainer_position.x, trainer_position.y] if trainer_position != Vector2.INF else null,
		"zone_name": zone_name, "pokedex": {"seen": pokedex_seen.keys(), "fought": pokedex_fought.keys(),
		"caught": pokedex_caught.keys()}, "box": _box_list(), "field_picked": field_picked.duplicate(),
		"living_trainers": living_trainers, "trainers": _trainers_dict()}


func _box_list() -> Array:
	var out := []
	for inst in box:
		out.append(inst.to_dict())
	return out


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
	bag.clear()
	var saved_bag = d.get("bag", null)
	if saved_bag is Dictionary:
		for id in saved_bag:
			if DB.items.has(str(id)) and int(saved_bag[id]) > 0:
				bag[str(id)] = int(saved_bag[id])
	else:  # partidas de antes de la mochila: solo tenían Poké Balls
		bag = DB.config.starting_bag.duplicate()
		bag["poke_ball"] = int(d.get("balls", DB.config.starting_balls))
	selected_ball = str(d.get("selected_ball", "poke_ball"))
	quick_item = str(d.get("quick_item", "pocion"))
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
	pokedex_caught.clear()
	var dex = d.get("pokedex", {})
	if dex is Dictionary:
		var sets := {"seen": pokedex_seen, "fought": pokedex_fought, "caught": pokedex_caught}
		for key in sets:
			var ids = dex.get(key, [])
			if ids is Array:
				for id in ids:
					if DB.species.has(str(id)):
						sets[key][str(id)] = true
	box.clear()
	var saved_box = d.get("box", [])
	if saved_box is Array:
		for m in saved_box:
			if m is Dictionary:
				var inst := CreatureInstance.from_dict(m, warnings)
				if inst != null:
					box.append(inst)
	for inst in party:  # guardados viejos (sin Pokédex): al menos el equipo
		pokedex_seen[inst.species.id] = true
		pokedex_fought[inst.species.id] = true
		pokedex_caught[inst.species.id] = true
	field_picked.clear()
	var picked = d.get("field_picked", {})
	if picked is Dictionary:
		for key in picked:
			field_picked[str(key)] = float(picked[key])
	Events.party_changed.emit()
	return true
