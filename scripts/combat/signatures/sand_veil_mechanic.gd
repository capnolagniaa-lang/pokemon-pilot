extends SignatureMechanic
## Velo Arena (Sandshrew, control): al esquivar deja una nube de arena donde estaba (el ataque `cloud_move`, un
## parche que desorienta a los rivales que la pisan). Recarga propia: `cooldown` s.

var _cloud: MoveData
var _ready_at := 0.0


func _setup() -> void:
	_cloud = load(param("cloud_move", ""))
	creature.dodged.connect(_on_dodged)


func _on_dodged() -> void:
	if _cloud == null or creature.now() < _ready_at:
		return
	_ready_at = creature.now() + param("cooldown", 4.0)
	var gz := GroundZone.new()
	creature.get_parent().add_child(gz)
	gz.place(HitInfo.from(creature, _cloud), creature.global_position)
	Events.signature_triggered.emit(creature, "¡Velo Arena!", data.color)


func state_label() -> String:
	return "" if creature.now() < _ready_at else "VELO LISTO"
