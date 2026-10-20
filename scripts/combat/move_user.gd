class_name MoveUser
extends Node
## Recargas y energía de los ataques de una criatura.

const MAX_ENERGY := 100.0
const ENERGY_REGEN := 22.0
const DODGE_COST := 18.0
const DODGE_COOLDOWN := 0.7

var moves: Array[MoveData] = []
var cooldowns: Dictionary = {}  # id -> segundos restantes
var energy := MAX_ENERGY
var dodge_cooldown := 0.0


func setup(p_moves: Array[MoveData]) -> void:
	moves = p_moves
	for m in moves:
		cooldowns[m.id] = 0.0


func _physics_process(delta: float) -> void:
	energy = minf(MAX_ENERGY, energy + ENERGY_REGEN * delta)
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
	for id in cooldowns:
		cooldowns[id] = maxf(0.0, cooldowns[id] - delta)


func can_use(i: int) -> bool:
	if i < 0 or i >= moves.size():
		return false
	var m := moves[i]
	return cooldowns[m.id] <= 0.0 and energy >= m.energy_cost


## Gasta energía y arranca la recarga. Devuelve el ataque, o null si no se puede usar.
func consume(i: int) -> MoveData:
	if not can_use(i):
		return null
	var m := moves[i]
	energy -= m.energy_cost
	cooldowns[m.id] = m.cooldown
	return m


func can_dodge() -> bool:
	return dodge_cooldown <= 0.0 and energy >= DODGE_COST


func consume_dodge() -> bool:
	if not can_dodge():
		return false
	energy -= DODGE_COST
	dodge_cooldown = DODGE_COOLDOWN
	return true


func cooldown_ratio(i: int) -> float:
	var m := moves[i]
	return cooldowns[m.id] / m.cooldown if m.cooldown > 0.0 else 0.0
