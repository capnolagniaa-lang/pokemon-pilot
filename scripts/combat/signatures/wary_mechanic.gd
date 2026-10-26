extends SignatureMechanic
## Sueño Vigilante (Abra; docs/PROPUESTA_KITS_PENDIENTES.md): cuando le pegan se teletransporta solo `blink_distance`
## px lejos del atacante (un instante invulnerable), cada `cooldown` s. Así atraparlo es un desafío, como en el juego:
## hay que dormirlo o paralizarlo primero (dormido o paralizado no se escapa). La barra muestra cuándo puede volver a
## teletransportarse.

var _ready_in := 0.0


func _setup() -> void:
	creature.damage_received.connect(_on_hit)
	set_value(data.max_value)


func _can_decay() -> bool:
	return false


func _tick(delta: float) -> void:
	if _ready_in > 0.0:
		_ready_in -= delta
		set_value(data.max_value * (1.0 - maxf(0.0, _ready_in) / param("cooldown", 6.0)))


func _on_hit(amount: float, hit: HitInfo) -> void:
	if _ready_in > 0.0 or amount <= 0.0 or creature.is_down():
		return
	for st in param("pinned_by", ["dormido", "paralizado"]):
		if creature.statuses.has_status(st):
			return
	var away := Vector2.RIGHT.rotated(randf() * TAU)
	if hit != null and is_instance_valid(hit.attacker):
		away = (creature.global_position - hit.attacker.global_position).normalized().rotated(randf_range(-0.6, 0.6))
	var dist: float = param("blink_distance", 90.0)
	# El lugar libre más lejos posible en esa dirección (no se mete en paredes).
	for k in 4:
		var off := away * dist * (1.0 - k * 0.25)
		if not creature.test_move(creature.global_transform, off):
			Fx.burst(creature.get_parent(), creature.global_position, data.color, 10, 40.0)
			creature.global_position += off
			creature.health.invulnerable_time = maxf(creature.health.invulnerable_time, 0.3)
			_ready_in = param("cooldown", 6.0)
			set_value(0.0)
			Events.signature_triggered.emit(creature, "¡Teletransporte!", data.color)
			return


func state_label() -> String:
	return "ALERTA" if _ready_in <= 0.0 else ""
