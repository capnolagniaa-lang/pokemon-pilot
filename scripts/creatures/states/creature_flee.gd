extends State
## Salvaje huyendo. Dos casos:
##  · tranquilo (tímido o curioso nervioso que te vio): se aleja sin pelear; si lo acorralás, se da vuelta
##    y pelea;
##  · en combate (poca vida): se aleja de su objetivo; si lo acorralan, sigue peleando.
## Al alejarse lo suficiente, se calma y deambula en el lugar nuevo.
## Se desparraman (pedido del usuario 2026-10-28: si un grupo huía, todos corrían para el mismo lado y no se podía
## atrapar al que querías): cada uno toma un ángulo propio según de qué lado del grupo está, y se separan entre sí.

@export var safe_distance := 200.0
@export var max_time := 4.0
## Segundos trabado contra algo con la amenaza encima para considerarse acorralado.
@export var cornered_time := 0.6

var _time := 0.0
var _threat: Creature
var _calm := false
var _stuck := 0.0
## Rumbo propio, elegido al empezar a huir: "justo en contra de la amenaza" girado un ángulo distinto para cada uno.
## Fijo (no se recalcula cada cuadro: si no, al irse de costado terminaba dando vueltas alrededor de la amenaza).
var _heading := Vector2.ZERO

## Hasta cuánto se aparta (grados) y a qué distancia se separa de los otros salvajes.
const SCATTER_DEG := 75.0
const SEPARATION := 40.0


func enter(msg: Dictionary = {}) -> void:
	_time = 0.0
	_stuck = 0.0
	_calm = msg.get("calm", false)
	_threat = msg.get("from", actor.target)
	if is_instance_valid(_threat):
		_heading = (actor.global_position - _threat.global_position).normalized().rotated(_scatter_angle())


func physics_update(delta: float) -> void:
	_time += delta
	if not is_instance_valid(_threat) or _threat.is_down() or _time > max_time \
			or actor.global_position.distance_to(_threat.global_position) > safe_distance:
		actor.home = actor.global_position
		transition("wander")
		return
	var pure: Vector2 = (actor.global_position - _threat.global_position).normalized()
	var away: Vector2 = (_heading + _separation()).normalized()
	if away.dot(pure) < 0.1:  # nunca hacia la amenaza: como mucho, de costado
		away = pure.rotated(signf(pure.cross(away)) * deg_to_rad(84.0))
	var before: Vector2 = actor.global_position
	actor.move(actor.body.steer(away), actor.speed() * 1.1)
	var progressed: bool = actor.global_position.distance_to(before) > actor.speed() * delta * 0.3
	var close: bool = actor.global_position.distance_to(_threat.global_position) < 34.0
	_stuck = _stuck + delta if (close and not progressed) else 0.0
	if _stuck >= cornered_time and _threat.team == actor.team:
		transition("wander")  # (huía de un cazador salvaje: no se pelean entre ellos)
		return
	if _stuck >= cornered_time:
		# Acorralado: se da vuelta y pelea.
		actor.emote("!", 1.0)
		if _calm:
			actor.target = _threat
			Events.wild_aggro.emit(actor, _threat)
		transition("attack")


## De qué lado del grupo (salvajes a menos de 80 px) está, mirado desde la amenaza: el de la izquierda huye hacia la
## izquierda y el de la derecha hacia la derecha; solo, un lado al azar. Con un poco de azar para que no salgan en fila.
func _scatter_angle() -> float:
	if not is_instance_valid(_threat):
		return 0.0
	var center := Vector2.ZERO
	var n := 0
	for c in actor.get_tree().get_nodes_in_group("creatures"):
		if c != actor and c.team == actor.team and not c.is_down() 				and c.global_position.distance_to(actor.global_position) < 80.0:
			center += c.global_position
			n += 1
	var side := 1.0 if randf() < 0.5 else -1.0
	if n > 0:
		center /= n
		var axis: Vector2 = actor.global_position - _threat.global_position
		var cross: float = axis.cross(center - _threat.global_position)
		if absf(cross) > 1.0:
			side = -signf(cross)  # el grupo queda de un lado: él se abre hacia el otro
	return side * deg_to_rad(randf_range(SCATTER_DEG * 0.4, SCATTER_DEG))


## Empuje para no pegarse a los otros salvajes que huyen cerca.
func _separation() -> Vector2:
	var push := Vector2.ZERO
	for c in actor.get_tree().get_nodes_in_group("creatures"):
		if c == actor or c.team != actor.team or c.is_down():
			continue
		var d: Vector2 = actor.global_position - c.global_position
		var dist := d.length()
		if dist > 0.01 and dist < SEPARATION:
			push += d / dist * (1.0 - dist / SEPARATION)
	return push
