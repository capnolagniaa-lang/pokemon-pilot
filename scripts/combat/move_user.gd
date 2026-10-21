class_name MoveUser
extends Node
## Ranuras de habilidades (Kit.Slot: básico, habilidad 1, habilidad 2, movilidad, definitiva), recargas,
## energía y combos. Los Pokémon sin kit propio usan sus 4 ataques: 1-3 en básico/hab.1/hab.2, el 4º como
## definitiva y el esquive genérico como movilidad.

const MAX_ENERGY := 100.0
## Energía por segundo: con 12/s se puede tirar un ataque fuerte cada ~3 s y uno chico cada ~1,4 s.
const ENERGY_REGEN := 12.0
const DODGE_COST := 22.0
const DODGE_COOLDOWN := 0.9

## Habilidad de cada ranura (null en movilidad = esquive genérico).
var slots: Array[MoveData] = []
var cooldowns: Array[float] = []
## Duración completa de la recarga en curso de cada ranura (para la interfaz).
var cooldown_total: Array[float] = []
var energy := MAX_ENERGY
var dodge_cooldown := 0.0

var _combo_step: Array[int] = []
var _combo_timer: Array[float] = []


func setup(species: SpeciesData) -> void:
	if species.kit != null:
		slots = species.kit.slots()
	else:
		var m := species.moves
		slots = [m[0] if m.size() > 0 else null, m[1] if m.size() > 1 else null,
			m[2] if m.size() > 2 else null, null, m[3] if m.size() > 3 else null]
	cooldowns.resize(Kit.SLOT_COUNT)
	cooldowns.fill(0.0)
	cooldown_total.resize(Kit.SLOT_COUNT)
	cooldown_total.fill(1.0)
	_combo_step.resize(Kit.SLOT_COUNT)
	_combo_step.fill(0)
	_combo_timer.resize(Kit.SLOT_COUNT)
	_combo_timer.fill(0.0)


## Lista de habilidades no vacías (para la IA y el autotest).
var moves: Array[MoveData]:
	get:
		var out: Array[MoveData] = []
		for s in slots:
			if s != null:
				out.append(s)
		return out


func _physics_process(delta: float) -> void:
	energy = minf(MAX_ENERGY, energy + ENERGY_REGEN * delta)
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
	for i in cooldowns.size():
		cooldowns[i] = maxf(0.0, cooldowns[i] - delta)
		if _combo_timer[i] > 0.0:
			_combo_timer[i] -= delta
			if _combo_timer[i] <= 0.0 and _combo_step[i] > 0:
				# Se cortó el combo: arranca la recarga completa.
				_combo_step[i] = 0
				_start_cooldown(i, slots[i].cooldown)


func slot_of(m: MoveData) -> int:
	return slots.find(m)


func can_use(slot: int) -> bool:
	if slot < 0 or slot >= slots.size() or slots[slot] == null:
		return false
	return cooldowns[slot] <= 0.0 and energy >= slots[slot].energy_cost


## Gasta energía y arranca la recarga (o avanza el combo). Devuelve [habilidad, paso del combo] o [].
func consume(slot: int) -> Array:
	if not can_use(slot):
		return []
	var m := slots[slot]
	energy -= m.energy_cost
	var step := 0
	if m.combo_steps > 1:
		step = _combo_step[slot]
		_combo_step[slot] = (step + 1) % m.combo_steps
		if _combo_step[slot] == 0:
			_combo_timer[slot] = 0.0
			_start_cooldown(slot, m.cooldown)
		else:
			_combo_timer[slot] = m.combo_window
			_start_cooldown(slot, m.combo_step_cooldown)
	else:
		_start_cooldown(slot, m.cooldown)
	return [m, step]


## Reduce la recarga de una ranura (lo usan mecánicas como el Ritmo de Bellsprout).
func reduce_cooldown(slot: int, seconds: float) -> void:
	cooldowns[slot] = maxf(0.0, cooldowns[slot] - seconds)


func reset_cooldown(slot: int) -> void:
	cooldowns[slot] = 0.0


func _start_cooldown(slot: int, t: float) -> void:
	cooldowns[slot] = t
	cooldown_total[slot] = maxf(t, 0.01)


func can_dodge() -> bool:
	if slots.size() > Kit.Slot.MOBILITY and slots[Kit.Slot.MOBILITY] != null:
		return can_use(Kit.Slot.MOBILITY)
	return dodge_cooldown <= 0.0 and energy >= DODGE_COST


func consume_dodge() -> bool:
	if dodge_cooldown > 0.0 or energy < DODGE_COST:
		return false
	energy -= DODGE_COST
	dodge_cooldown = DODGE_COOLDOWN
	return true


func cooldown_ratio(slot: int) -> float:
	if slot == Kit.Slot.MOBILITY and slots[slot] == null:
		return dodge_cooldown / DODGE_COOLDOWN
	return cooldowns[slot] / cooldown_total[slot]


func combo_step(slot: int) -> int:
	return _combo_step[slot]
