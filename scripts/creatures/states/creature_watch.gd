extends State
## Salvaje curioso mirándote: se acerca hasta su distancia de observación y te sigue con la vista. Si te le
## venís encima se pone nervioso (ataca o huye según su temperamento); si te alejás o pasa un rato, pierde
## el interés. Si le pegan, pelea (lo maneja Creature._on_hit).

@export var max_time := 7.0

var _who: Creature
var _time := 0.0


func enter(msg: Dictionary = {}) -> void:
	_who = msg.get("target")
	_time = 0.0


func physics_update(delta: float) -> void:
	_time += delta
	var temp: Temperament = actor.temperament
	if not is_instance_valid(_who) or _who.is_down() or _time > max_time \
			or actor.global_position.distance_to(_who.global_position) > temp.detect_radius * 1.6 \
			or actor.global_position.distance_to(actor.home) > temp.leash:
		transition("wander")
		return
	var to: Vector2 = _who.global_position - actor.global_position
	var dist := to.length()
	actor.facing = to.normalized()
	if dist < temp.nervous_distance:
		if randf() < temp.nervous_attack_chance:
			actor.target = _who
			actor.emote("!", 1.0)
			Events.wild_aggro.emit(actor, _who)
			transition("chase")
		else:
			actor.emote("gota", 1.0)
			transition("flee", {"from": _who, "calm": true})
		return
	if dist > temp.approach_distance + 6.0:
		actor.move(to.normalized(), actor.speed() * 0.45)
	elif dist < temp.approach_distance - 10.0:
		actor.move(-to.normalized(), actor.speed() * 0.3)
	else:
		actor.move(Vector2.ZERO, 0.0)
		actor.facing = to.normalized()
