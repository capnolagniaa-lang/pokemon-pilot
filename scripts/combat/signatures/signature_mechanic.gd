class_name SignatureMechanic
extends Node
## Base de las mecánicas de firma (plan de identidad, capa 2). Maneja el recurso (sube con los eventos de
## combate de su criatura según SignatureData.gains y baja con el tiempo) y ofrece ganchos que cada
## mecánica sobreescribe. El código central nunca pregunta "¿es Charmander?": solo llama a estos ganchos.

signal changed(value: float)

var data: SignatureData
var creature: Creature
var value := 0.0
## La última habilidad lanzada consumió recurso (para no recuperarlo durante su canalización).
var _spending := false


func setup(p_creature: Creature, p_data: SignatureData) -> void:
	creature = p_creature
	data = p_data
	name = "Signature"
	creature.hit_dealt.connect(func(_t, _h, _d): gain("hit_dealt"))
	creature.damage_received.connect(func(amount, _h): if amount > 0.0: gain("damage_received"))
	creature.moved.connect(func(dist): gain("moved", dist))
	creature.dodged.connect(func(): gain("dodged"))
	creature.killed.connect(func(_t): gain("killed"))
	creature.status_inflicted.connect(func(_t, _s): gain("status_inflicted"))
	creature.move_released.connect(func(m):
		_spending = m.resource_cost != 0.0
		_on_move_released(m))
	_setup()


## Suma el recurso por un evento (multiplicado por `amount`, ej. píxeles recorridos).
## Mientras se canaliza una habilidad que consumió el recurso, no se gana (si no, gastarlo no costaría nada).
func gain(event: String, amount: float = 1.0) -> void:
	var g: float = data.gains.get(event, 0.0)
	if g == 0.0 or not _can_gain() or (_spending and creature.machine.current_name() == "channel"):
		return
	set_value(value + g * amount)


func set_value(v: float) -> void:
	var before := value
	value = clampf(v, 0.0, data.max_value)
	if value != before:
		changed.emit(value)
		_on_value_changed(before)


## Consume recurso (-1 = todo). Devuelve cuánto se consumió.
func consume(amount: float) -> float:
	var used := value if amount < 0.0 else minf(amount, value)
	set_value(value - used)
	return used


func ratio() -> float:
	return value / data.max_value if data.max_value > 0.0 else 0.0


func in_combat() -> bool:
	return creature.player_controlled or is_instance_valid(creature.target)


func param(key: String, default = null):
	return data.params.get(key, default)


func _physics_process(delta: float) -> void:
	if creature == null or creature.is_down():
		return
	var decay := data.decay_in_combat if in_combat() else data.decay_out_of_combat
	if decay > 0.0 and value > 0.0 and _can_decay():
		set_value(value - decay * delta)
	_tick(delta)


# --- Ganchos para las subclases ---------------------------------------------------------

func _setup() -> void:
	pass


func _tick(_delta: float) -> void:
	pass


func _can_gain() -> bool:
	return true


func _can_decay() -> bool:
	return true


func _on_value_changed(_before: float) -> void:
	pass


func _on_move_released(_m: MoveData) -> void:
	pass


## Modifica un golpe que sale de esta criatura (daño, estado extra, área).
func modify_hit(_hit: HitInfo) -> void:
	pass


## Multiplicador de velocidad de movimiento.
func speed_mult() -> float:
	return 1.0


## Texto de estado para la interfaz (ej: "MAR LLAMAS"); vacío si no hay nada especial.
func state_label() -> String:
	return ""
