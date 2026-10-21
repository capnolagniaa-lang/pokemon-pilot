class_name Health
extends Node
## Vida de una criatura (guardada en su CreatureInstance), escudo e invulnerabilidad temporal.

signal changed(hp: float, max_hp: float)
signal depleted

const SHIELD_FACTOR := 0.2

var instance: CreatureInstance
## De dónde sale el multiplicador de curación (StatusEffects: Herido la reduce).
var heal_mult_source: Node
var shield_time := 0.0
var invulnerable_time := 0.0


func _physics_process(delta: float) -> void:
	shield_time = maxf(0.0, shield_time - delta)
	invulnerable_time = maxf(0.0, invulnerable_time - delta)


func hp() -> float:
	return instance.hp


func max_hp() -> float:
	return instance.max_hp()


func ratio() -> float:
	return clampf(instance.hp / instance.max_hp(), 0.0, 1.0)


func is_dead() -> bool:
	return instance.hp <= 0.0


func is_invulnerable() -> bool:
	return invulnerable_time > 0.0 or is_dead()


## Aplica daño (reducido por el escudo) y devuelve el daño real.
func apply_damage(amount: float) -> float:
	if is_dead():
		return 0.0
	if shield_time > 0.0:
		amount *= SHIELD_FACTOR
	var before := instance.hp
	instance.hp = maxf(0.0, instance.hp - amount)
	changed.emit(instance.hp, max_hp())
	if instance.hp <= 0.0:
		depleted.emit()
	return before - instance.hp


## Cura (afectado por estados como Herido). Devuelve lo curado.
func heal(amount: float) -> float:
	if heal_mult_source != null:
		amount *= heal_mult_source.heal_mult()
	var before := instance.hp
	instance.hp = minf(max_hp(), instance.hp + amount)
	changed.emit(instance.hp, max_hp())
	return instance.hp - before
