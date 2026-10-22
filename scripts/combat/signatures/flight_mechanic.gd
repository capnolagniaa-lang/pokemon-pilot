extends SignatureMechanic
## Vuelo (Pidgey): el recurso es el **Aliento**. Al esquivar (Espacio) con al menos `lift_cost` de Aliento,
## Pidgey se eleva: mientras está en el aire es inmune a los golpes terrestres cortos (cuerpo a cuerpo,
## embestidas, látigos) pero gasta Aliento; aterriza al quedarse sin Aliento, a los `max_air_time` s o al
## atacar. El primer ataque desde el aire es un **Picado** (más daño). En el suelo el Aliento se recupera.
## Pregunta del jugador: ¿subo (y me salvo) o ataco (y bajo)?

const GROUND_KINDS := [MoveData.Kind.MELEE, MoveData.Kind.DASH, MoveData.Kind.LUNGE, MoveData.Kind.WHIP]

var air_left := 0.0
## Picado listo: el próximo ataque que salga desde el aire pega más.
var _dive := false


func _setup() -> void:
	value = data.max_value
	creature.dodged.connect(_on_dodged)


func is_airborne() -> bool:
	return air_left > 0.0


func _on_dodged() -> void:
	if is_airborne() or value < param("lift_cost", 30.0):
		return
	set_value(value - param("lift_cost", 30.0))
	air_left = param("max_air_time", 1.6)
	_dive = true
	Events.signature_triggered.emit(creature, "¡Vuelo!", data.color)


func _land() -> void:
	air_left = 0.0
	_dive = false


func _tick(delta: float) -> void:
	if is_airborne():
		air_left -= delta
		set_value(value - param("drain_per_second", 40.0) * delta)
		if value <= 0.0 or air_left <= 0.0 or not creature.statuses.can_act():
			_land()
	else:
		set_value(value + param("regen_per_second", 30.0) * delta)
	var target_lift: float = param("height", 12.0) if is_airborne() else 0.0
	creature.sprite.lift = move_toward(creature.sprite.lift, target_lift, 90.0 * delta)


func modify_hit(hit: HitInfo) -> void:
	if _dive and hit.move.power > 0.0:
		hit.damage_mult *= param("dive_damage_mult", 1.4)


## Atacar desde el aire = Picado: pega más y aterriza.
func _on_move_released(m: MoveData) -> void:
	if is_airborne() and m.power > 0.0:
		Events.signature_triggered.emit(creature, "¡Picado!", data.color)
		_land()


func ignores_hit(hit: HitInfo) -> bool:
	return is_airborne() and hit.move.kind in GROUND_KINDS


func state_label() -> String:
	if is_airborne():
		return "EN EL AIRE"
	if value >= param("lift_cost", 30.0):
		return "PUEDE VOLAR"
	return ""
