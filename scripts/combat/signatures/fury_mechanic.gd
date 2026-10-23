extends SignatureMechanic
## Furia (Spearow, asesino): cada golpe seguido al mismo rival suma una marca (hasta `max_stacks`) y los golpes
## pegan `per_stack` más por marca. Si pasan `window` s sin pegarle, o cambia de rival, se pierde todo.

var _victim: Node = null
var _last := -100.0


func damage_mult_against(_hit: HitInfo, target: Creature) -> float:
	var mult: float = 1.0 + param("per_stack", 0.1) * _stacks()
	if target != _victim or creature.now() - _last > param("window", 2.0):
		set_value(0.0)
		mult = 1.0
	_victim = target
	_last = creature.now()
	set_value(value + data.max_value / float(param("max_stacks", 5)))
	return mult


func _stacks() -> int:
	return int(round(value / (data.max_value / float(param("max_stacks", 5)))))


func _tick(_delta: float) -> void:
	if value > 0.0 and creature.now() - _last > param("window", 2.0):
		set_value(0.0)


func state_label() -> String:
	return "FURIA ×%d" % _stacks() if _stacks() > 0 else ""
