class_name CreatureInstance
extends Resource
## Una criatura concreta (del equipo o salvaje): especie, nivel, experiencia, IVs/EVs y vida actual.
## Los stats salen de la fórmula oficial de los juegos (3ª gen en adelante).

const STATS := ["hp", "attack", "defense", "sp_attack", "sp_defense", "speed"]
const MAX_IV := 31
const MAX_LEVEL := 100
## Adaptación al tiempo real: la vida se multiplica para que un combate dure varios golpes.
const HP_SCALE := 3.0


## Escala de vida de esta partida (Ajustes del juego; por defecto HP_SCALE).
static func hp_scale() -> float:
	return float(GameState.setting("hp_scale"))

@export var species: SpeciesData
@export var level: int = 1
## Experiencia total acumulada (como en los juegos).
@export var experience: int = 0
## Valores individuales (0-31). Por ahora todos perfectos; más adelante saldrán al azar al capturar.
@export var ivs: Dictionary = {}
## Puntos de esfuerzo (0-252 por stat, 510 en total). Por ahora en 0.
@export var evs: Dictionary = {}
## Vida actual (en la escala del juego, ver HP_SCALE).
@export var hp: float = -1.0
## Los 4 movimientos equipados (Clic izq., Clic der., Q, R); puede haber huecos (null).
@export var equipped_moves: Array[MoveData] = []
## Movimientos enseñados con MT (se suman a los del learnset y se guardan con la partida).
@export var taught_moves: Array[MoveData] = []
## Para más adelante (Etapa 6): apodo y naturaleza. Vacíos por ahora.
@export var nickname: String = ""
@export var nature: String = ""

const SLOT_COUNT := 4


static func create(p_species: SpeciesData, p_level: int) -> CreatureInstance:
	var c := CreatureInstance.new()
	c.species = p_species
	c.level = clampi(p_level, 1, MAX_LEVEL)
	c.experience = exp_for_level(p_species.growth_rate, c.level)
	for s in STATS:
		c.ivs[s] = MAX_IV
		c.evs[s] = 0
	c.hp = c.max_hp()
	c.equipped_moves = c.default_equipment()
	return c


## IVs al azar 0-31 por stat (salvajes). Uno perfecto (31 en todo) sale 1 en ~10⁹. La vida queda al máximo.
func roll_ivs() -> void:
	for s in STATS:
		ivs[s] = randi_range(0, MAX_IV)
	hp = max_hp()


func display_name() -> String:
	return nickname if nickname != "" else species.display_name


# --- Movimientos -------------------------------------------------------------------

## Movimientos ya aprendidos (nivel del learnset ≤ nivel actual), en orden de aprendizaje.
func learned_moves() -> Array[MoveData]:
	var out: Array[MoveData] = []
	for e in species.learnset_entries():
		if e.level <= level and not out.has(e.move):
			out.append(e.move)
	for m in taught_moves:
		if m != null and not out.has(m):
			out.append(m)
	return out


func can_equip(m: MoveData) -> bool:
	return m != null and learned_moves().has(m)


## Equipa un movimiento en una ranura. No se repite (si ya estaba en otra ranura, se intercambian) y no
## se puede dejar al Pokémon sin movimientos (vaciar la única ranura ocupada).
func equip(slot: int, m: MoveData) -> bool:
	if slot < 0 or slot >= SLOT_COUNT:
		return false
	_pad_slots()
	if m == null:
		if equipped_moves[slot] != null and equipped_moves.filter(func(x): return x != null).size() <= 1:
			return false
		equipped_moves[slot] = null
		return true
	if not can_equip(m):
		return false
	var other := equipped_moves.find(m)
	if other >= 0:
		equipped_moves[other] = equipped_moves[slot]
	equipped_moves[slot] = m
	return true


## Lo que equipa por defecto: los primeros 4 aprendidos (los del kit, en su orden, van primero).
func default_equipment() -> Array[MoveData]:
	var out: Array[MoveData] = []
	var learned := learned_moves()
	# Primero los del kit (su estilo de pelea), aunque el learnset completo de FRLG tenga otros al mismo nivel
	# (Charmander aprende Gruñido en Nv. 1: no tiene que desplazar a Giro Fuego).
	if species.kit != null:
		for m in species.kit.moves:
			if m != null and learned.has(m) and out.size() < SLOT_COUNT:
				out.append(m)
	for m in learned:
		if out.size() < SLOT_COUNT and not out.has(m):
			out.append(m)
	while out.size() < SLOT_COUNT:
		out.append(null)
	return out


func _pad_slots() -> void:
	while equipped_moves.size() < SLOT_COUNT:
		equipped_moves.append(null)
	if equipped_moves.size() > SLOT_COUNT:
		equipped_moves.resize(SLOT_COUNT)


## Movimientos del learnset con nivel en (desde, hasta]: los que aprendió al subir de nivel.
func moves_learned_between(from_level: int, to_level: int) -> Array[MoveData]:
	var out: Array[MoveData] = []
	for e in species.learnset_entries():
		if e.level > from_level and e.level <= to_level and not out.has(e.move):
			out.append(e.move)
	return out


## Al aprender un movimiento: si hay una ranura vacía se equipa solo; si no, queda disponible en la ficha.
func auto_equip(m: MoveData) -> bool:
	_pad_slots()
	if equipped_moves.has(m):
		return true
	var free := equipped_moves.find(null)
	if free < 0:
		return false
	equipped_moves[free] = m
	return true


# --- Guardado (JSON con ids, ver SaveManager) -----------------------------------------

func to_dict() -> Dictionary:
	_pad_slots()
	var eq := []
	for m in equipped_moves:
		eq.append(DB.move_key(m) if m != null else "")
	return {"species_id": species.id, "level": level, "experience": experience, "ivs": ivs.duplicate(),
		"evs": evs.duplicate(), "hp": hp, "equipped_moves": eq, "nickname": nickname, "nature": nature,
		"taught_moves": taught_moves.filter(func(m): return m != null).map(func(m): return DB.move_key(m))}


## Arma una criatura desde un diccionario guardado. Devuelve null si la especie ya no existe; los
## movimientos que falten (o que ya no pueda equipar) se sacan de lo equipado. Avisos en `warnings`.
static func from_dict(d: Dictionary, warnings: Array = []) -> CreatureInstance:
	var sp: SpeciesData = DB.species.get(str(d.get("species_id", "")))
	if sp == null:
		warnings.append("Especie desconocida: %s" % d.get("species_id", "?"))
		return null
	var c := CreatureInstance.create(sp, int(d.get("level", 1)))
	c.experience = maxi(int(d.get("experience", 0)), exp_for_level(sp.growth_rate, c.level))
	var ivs_in = d.get("ivs", {})
	var evs_in = d.get("evs", {})
	for s in STATS:
		c.ivs[s] = clampi(int(ivs_in.get(s, MAX_IV)) if ivs_in is Dictionary else MAX_IV, 0, MAX_IV)
		c.evs[s] = clampi(int(evs_in.get(s, 0)) if evs_in is Dictionary else 0, 0, 252)
	c.hp = clampf(float(d.get("hp", c.max_hp())), 0.0, c.max_hp())
	c.nickname = str(d.get("nickname", ""))
	c.nature = str(d.get("nature", ""))
	var taught = d.get("taught_moves", [])
	if taught is Array:
		for key in taught:
			var tm: MoveData = DB.move_by_id(str(key))
			if tm != null and not c.taught_moves.has(tm):
				c.taught_moves.append(tm)
	var saved = d.get("equipped_moves", null)
	if saved is Array:
		var eq: Array[MoveData] = []
		for key in saved:
			var m: MoveData = null
			if str(key) != "":
				m = DB.move_by_id(str(key))
				if m == null or not c.can_equip(m) or eq.has(m):
					warnings.append("Movimiento no disponible para %s: %s" % [sp.display_name, key])
					m = null
			eq.append(m)
		c.equipped_moves = eq
		c._pad_slots()
		if c.equipped_moves.all(func(x): return x == null):
			c.equipped_moves = c.default_equipment()
	return c


## Stat oficial al nivel actual (naturaleza neutra por ahora).
func stat(name: String) -> int:
	var base := species.base_stat(name)
	var iv: int = ivs.get(name, MAX_IV)
	var ev: int = evs.get(name, 0)
	var core := int((2 * base + iv + ev / 4) * level / 100)
	if name == "hp":
		return core + level + 10
	return core + 5


func max_hp() -> float:
	return stat("hp") * hp_scale()


# --- Experiencia ---------------------------------------------------------------

## Experiencia total necesaria para un nivel según la curva oficial.
static func exp_for_level(growth: String, n: int) -> int:
	if n <= 1:
		return 0
	var n3 := float(n * n * n)
	match growth:
		"fast":
			return int(4.0 * n3 / 5.0)
		"medium-slow":
			return maxi(0, int(1.2 * n3 - 15.0 * n * n + 100.0 * n - 140.0))
		"slow":
			return int(5.0 * n3 / 4.0)
		"slow-then-very-fast":  # errática
			if n < 50:
				return int(n3 * (100 - n) / 50.0)
			if n < 68:
				return int(n3 * (150 - n) / 100.0)
			if n < 98:
				return int(n3 * floori((1911 - 10 * n) / 3.0) / 500.0)
			return int(n3 * (160 - n) / 100.0)
		"fast-then-very-slow":  # fluctuante
			if n < 15:
				return int(n3 * (floori((n + 1) / 3.0) + 24) / 50.0)
			if n < 36:
				return int(n3 * (n + 14) / 50.0)
			return int(n3 * (floori(n / 2.0) + 32) / 50.0)
	return int(n3)  # medium (medium-fast)


func exp_to_next() -> int:
	return exp_for_level(species.growth_rate, level + 1) - experience


## Progreso dentro del nivel actual (0..1), para la barra de EXP.
func exp_progress() -> float:
	var lo := exp_for_level(species.growth_rate, level)
	var hi := exp_for_level(species.growth_rate, level + 1)
	return clampf(float(experience - lo) / maxf(1.0, hi - lo), 0.0, 1.0)


## Experiencia oficial por derrotar a un salvaje (fórmula de la 1ª-4ª gen).
## EXP por debilitarlo: fórmula oficial de 1ª-4ª gen (base × nivel / 7) × GameConfig.exp_multiplier.
static func exp_yield(defeated: CreatureInstance) -> int:
	var mult: float = float(GameState.setting("exp_mult")) if DB.config != null else 1.0
	return maxi(1, int(defeated.species.base_experience * defeated.level / 7.0 * mult))


## Suma experiencia y devuelve cuántos niveles subió. Al subir, la vida sube lo mismo que la máxima.
func add_exp(amount: int) -> int:
	var ups := 0
	experience += amount
	while level < MAX_LEVEL and experience >= exp_for_level(species.growth_rate, level + 1):
		var before := max_hp()
		level += 1
		ups += 1
		hp = minf(max_hp(), hp + (max_hp() - before))
	return ups


## Evoluciona a otra especie (EvolutionDirector): conserva el nivel, la EXP, los IVs, el daño recibido y los
## movimientos que ya sabía (los que la nueva especie no aprende quedan en taught_moves, como en los juegos).
## Devuelve los movimientos nuevos que aprende al evolucionar (los de su nivel en el learnset nuevo).
func evolve_into(to: SpeciesData) -> Array[MoveData]:
	var known := learned_moves()
	var lost := max_hp() - hp
	species = to
	for m in known:
		if not learned_moves().has(m):
			taught_moves.append(m)
	hp = maxf(0.0 if hp <= 0.0 else 1.0, max_hp() - lost)
	var fresh: Array[MoveData] = []
	for e in species.learnset_entries():
		if e.level == level and e.move != null and not known.has(e.move) and not fresh.has(e.move):
			fresh.append(e.move)
	return fresh
