class_name CreatureInstance
extends Resource
## Una criatura concreta (del equipo o salvaje): especie + nivel + estado actual.

@export var species: SpeciesData
@export var level: int = 1
@export var xp: int = 0
@export var hp: float = -1.0


static func create(p_species: SpeciesData, p_level: int) -> CreatureInstance:
	var c := CreatureInstance.new()
	c.species = p_species
	c.level = p_level
	c.hp = c.max_hp()
	return c


func stat_mult() -> float:
	return 1.0 + 0.1 * (level - 1)


func max_hp() -> float:
	return species.base_hp * stat_mult()


func attack() -> float:
	return species.base_atk * stat_mult()


func xp_to_next() -> int:
	return 20 + level * 10


## Suma experiencia y devuelve cuántos niveles subió.
func add_xp(amount: int) -> int:
	var ups := 0
	xp += amount
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
		ups += 1
	return ups
