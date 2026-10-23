extends State
## Salvaje persiguiendo a su objetivo hasta tenerlo a tiro. Abandona si se aleja demasiado de su lugar (correa
## del temperamento) o, si es territorial, cuando el objetivo sale de su territorio.


func physics_update(_delta: float) -> void:
	var t: Creature = actor.target
	if not is_instance_valid(t) or t.is_down() or _gives_up(t):
		transition("wander")
		return
	var diff: Vector2 = t.global_position - actor.global_position
	# Apertura: si tiene un ataque de acercamiento y ya te tiene a tiro, abre con ese (patrón reconocible).
	if not actor.fight_opened and diff.length() > 40.0:
		var opener: int = actor.body.gap_closer(diff.length())
		if opener >= 0:
			actor.fight_opened = true
			if actor.body.use(opener):
				return
	if diff.length() < _preferred_range() * 1.1:
		transition("attack")
		return
	actor.move(diff.normalized(), actor.speed())


## Correa: el agresivo persigue lejos; el territorial suelta apenas salís de su zona.
func _gives_up(t: Creature) -> bool:
	var temp: Temperament = actor.temperament
	if temp == null:
		return actor.global_position.distance_to(actor.home) > 360.0
	if actor.global_position.distance_to(actor.home) > temp.leash:
		return true
	return temp.on_notice == Temperament.OnNotice.TERRITORY \
		and t.global_position.distance_to(actor.home) > temp.territory_radius * 1.8


func _preferred_range() -> float:
	if actor.instance.species.kit != null:
		return actor.instance.species.kit.preferred_range
	var best := 30.0
	for m in actor.moves.moves:
		if m.kind == MoveData.Kind.PROJECTILE:
			best = maxf(best, m.reach() * 0.6)
	return best
