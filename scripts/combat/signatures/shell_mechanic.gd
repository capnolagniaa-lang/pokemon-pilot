extends SignatureMechanic
## Caparazón (Squirtle, tanque): con **Refugio** (estado `refugio`) se mete en el caparazón: recibe menos y no lo
## empujan (lo hace el estado). Si le pegan en los primeros `parry_window` s del Refugio es un **parry**: el golpe
## no entra y el atacante queda aturdido. El daño bloqueado y los parry cargan la **Presión**, que el próximo
## golpe gasta para pegar más (hasta ×(1 + `max_bonus`)).

var _shell_since := -100.0


func _setup() -> void:
	creature.damage_received.connect(_on_damage)


func _in_shell() -> bool:
	return creature.statuses.has_status("refugio")


func _tick(_delta: float) -> void:
	if _in_shell() and _shell_since < 0.0:
		_shell_since = creature.now()
	elif not _in_shell():
		_shell_since = -100.0


## Parry: en la ventana justa del Refugio, el golpe no entra.
func ignores_hit(hit: HitInfo) -> bool:
	if not _in_shell() or creature.now() - _shell_since > param("parry_window", 0.3):
		return false
	var attacker: Creature = hit.attacker if is_instance_valid(hit.attacker) else null
	if attacker != null and hit.move.power > 0.0:
		attacker.stun(param("parry_stun", 0.6), true)
	set_value(value + param("parry_gain", 40.0))
	Events.signature_triggered.emit(creature, "¡Parry!", data.color)
	return true


## Lo que entra con el caparazón puesto carga Presión (proporcional al daño).
func _on_damage(amount: float, _hit: HitInfo) -> void:
	if _in_shell() and amount > 0.0:
		set_value(value + amount / creature.health.max_hp() * param("block_gain", 300.0))


func modify_hit(hit: HitInfo) -> void:
	if value > 0.0 and hit.move.power > 0.0:
		hit.damage_mult *= 1.0 + param("max_bonus", 1.0) * ratio()
		set_value(0.0)


func state_label() -> String:
	if _in_shell():
		return "REFUGIO"
	return "PRESIÓN LISTA" if value >= data.max_value * 0.5 else ""
