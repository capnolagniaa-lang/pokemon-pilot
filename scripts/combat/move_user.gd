class_name MoveUser
extends Node
## Los 4 ataques de una criatura (kit propio o sus ataques sueltos) y sus recargas. Sin energía: lo único
## que limita es la recarga de cada ataque. El esquive (Espacio) tiene su propia recarga.

const SLOT_COUNT := 4
const DODGE_COOLDOWN := 0.9

## Ataque de cada tecla (Clic izq., Clic der., Q, R); puede haber huecos (null).
var slots: Array[MoveData] = []
var cooldowns: Array[float] = []
## Duración completa de la recarga en curso de cada ranura (para la interfaz).
var cooldown_total: Array[float] = []
var dodge_cooldown := 0.0

var _combo_step: Array[int] = []
var _combo_timer: Array[float] = []


func setup(species: SpeciesData) -> void:
	var source: Array[MoveData] = species.kit.moves if species.kit != null else species.moves
	slots.clear()
	for i in SLOT_COUNT:
		slots.append(source[i] if i < source.size() else null)
	cooldowns.resize(SLOT_COUNT)
	cooldowns.fill(0.0)
	cooldown_total.resize(SLOT_COUNT)
	cooldown_total.fill(1.0)
	_combo_step.resize(SLOT_COUNT)
	_combo_step.fill(0)
	_combo_timer.resize(SLOT_COUNT)
	_combo_timer.fill(0.0)


## Ataques no vacíos (para la IA y el autotest).
var moves: Array[MoveData]:
	get:
		var out: Array[MoveData] = []
		for s in slots:
			if s != null:
				out.append(s)
		return out


func _physics_process(delta: float) -> void:
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
	for i in cooldowns.size():
		cooldowns[i] = maxf(0.0, cooldowns[i] - delta)
		if _combo_timer[i] > 0.0:
			_combo_timer[i] -= delta
			if _combo_timer[i] <= 0.0 and _combo_step[i] > 0:
				_combo_step[i] = 0
				_start_cooldown(i, slots[i].cooldown)


func slot_of(m: MoveData) -> int:
	return slots.find(m)


func can_use(slot: int) -> bool:
	return slot >= 0 and slot < slots.size() and slots[slot] != null and cooldowns[slot] <= 0.0


## Arranca la recarga (o avanza el combo). Devuelve [ataque, paso del combo] o [] si no se puede.
func consume(slot: int) -> Array:
	if not can_use(slot):
		return []
	var m := slots[slot]
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


## Reduce la recarga de una ranura (para mecánicas futuras, ej. el Ritmo de Bellsprout).
func reduce_cooldown(slot: int, seconds: float) -> void:
	cooldowns[slot] = maxf(0.0, cooldowns[slot] - seconds)


func reset_cooldown(slot: int) -> void:
	cooldowns[slot] = 0.0


func _start_cooldown(slot: int, t: float) -> void:
	cooldowns[slot] = t
	cooldown_total[slot] = maxf(t, 0.01)


func can_dodge() -> bool:
	return dodge_cooldown <= 0.0


func consume_dodge() -> bool:
	if dodge_cooldown > 0.0:
		return false
	dodge_cooldown = DODGE_COOLDOWN
	return true


func cooldown_ratio(slot: int) -> float:
	return cooldowns[slot] / cooldown_total[slot]


func combo_step(slot: int) -> int:
	return _combo_step[slot]
