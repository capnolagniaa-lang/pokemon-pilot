extends State
## Salvaje huyendo. Dos casos:
##  · tranquilo (tímido o curioso nervioso que te vio): se aleja sin pelear; si lo acorralás, se da vuelta
##    y pelea;
##  · en combate (poca vida): se aleja de su objetivo; si lo acorralan, sigue peleando.
## Al alejarse lo suficiente, se calma y deambula en el lugar nuevo.

@export var safe_distance := 200.0
@export var max_time := 4.0
## Segundos trabado contra algo con la amenaza encima para considerarse acorralado.
@export var cornered_time := 0.6

var _time := 0.0
var _threat: Creature
var _calm := false
var _stuck := 0.0


func enter(msg: Dictionary = {}) -> void:
	_time = 0.0
	_stuck = 0.0
	_calm = msg.get("calm", false)
	_threat = msg.get("from", actor.target)


func physics_update(delta: float) -> void:
	_time += delta
	if not is_instance_valid(_threat) or _threat.is_down() or _time > max_time \
			or actor.global_position.distance_to(_threat.global_position) > safe_distance:
		actor.home = actor.global_position
		transition("wander")
		return
	var away: Vector2 = (actor.global_position - _threat.global_position).normalized()
	var before: Vector2 = actor.global_position
	actor.move(actor.body.steer(away), actor.speed() * 1.1)
	var progressed: bool = actor.global_position.distance_to(before) > actor.speed() * delta * 0.3
	var close: bool = actor.global_position.distance_to(_threat.global_position) < 34.0
	_stuck = _stuck + delta if (close and not progressed) else 0.0
	if _stuck >= cornered_time:
		# Acorralado: se da vuelta y pelea.
		actor.emote("!", 1.0)
		if _calm:
			actor.target = _threat
			Events.wild_aggro.emit(actor, _threat)
		transition("attack")
