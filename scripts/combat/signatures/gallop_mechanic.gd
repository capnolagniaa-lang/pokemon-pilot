extends SignatureMechanic
## Galope (Ponyta, velocista; docs/PROPUESTA_KITS_PENDIENTES.md): correr en línea recta llena la barra (girar fuerte, más
## de `turn_deg`, o frenar la vacía). Con la barra llena va hasta ×`max_speed` y deja una estela de fuego
## (`Events.element_impact` de fuego cada `trail_every` px: prende el pasto como cualquier fuego). Sus embestidas pegan
## más con el galope (+`dash_bonus` con la barra llena). `trail_every` 0 = sin estela (la Carrera de Doduo).

var _last_dir := Vector2.ZERO
var _since_trail := 0.0
var _fire: ElementType


func _setup() -> void:
	_fire = load("res://data/types/fuego.tres")


func _can_decay() -> bool:
	return false


func _tick(delta: float) -> void:
	var v := creature.velocity
	if v.length() < 20.0:
		set_value(value - data.max_value * delta * 1.5)
		_last_dir = Vector2.ZERO
		return
	var dir := v.normalized()
	if _last_dir != Vector2.ZERO and rad_to_deg(abs(_last_dir.angle_to(dir))) > param("turn_deg", 35.0):
		set_value(value * 0.3)  # giro fuerte: pierde el galope
	else:
		set_value(value + data.max_value * delta / param("build_time", 1.5))
	_last_dir = dir
	if ratio() > 0.6 and param("trail_every", 18.0) > 0.0:  # 0 = sin estela de fuego (Doduo)
		_since_trail += v.length() * delta
		if _since_trail >= param("trail_every", 18.0):
			_since_trail = 0.0
			Events.element_impact.emit(_fire, creature.global_position, 6.0)


func speed_mult() -> float:
	return 1.0 + (param("max_speed", 1.4) - 1.0) * ratio()


func modify_hit(hit: HitInfo) -> void:
	if hit.move.kind in [MoveData.Kind.DASH, MoveData.Kind.LUNGE] and hit.move.power > 0.0:
		hit.damage_mult *= 1.0 + param("dash_bonus", 0.4) * ratio()


func state_label() -> String:
	return "GALOPE" if ratio() >= 0.99 else ""
