class_name CreatureInstance
extends Resource
## Una criatura concreta (del equipo o salvaje): especie, nivel, experiencia, IVs/EVs y vida actual.
## Los stats salen de la fórmula oficial de los juegos (3ª gen en adelante).

const STATS := ["hp", "attack", "defense", "sp_attack", "sp_defense", "speed"]
const MAX_IV := 31
const MAX_LEVEL := 100
## Adaptación al tiempo real: la vida se multiplica para que un combate dure varios golpes.
const HP_SCALE := 3.0

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


static func create(p_species: SpeciesData, p_level: int) -> CreatureInstance:
	var c := CreatureInstance.new()
	c.species = p_species
	c.level = clampi(p_level, 1, MAX_LEVEL)
	c.experience = exp_for_level(p_species.growth_rate, c.level)
	for s in STATS:
		c.ivs[s] = MAX_IV
		c.evs[s] = 0
	c.hp = c.max_hp()
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
	return stat("hp") * HP_SCALE


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
static func exp_yield(defeated: CreatureInstance) -> int:
	return maxi(1, int(defeated.species.base_experience * defeated.level / 7.0))


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
