extends State
## Salvaje deambulando cerca de su lugar. Cuando nota a tu Pokémon (o al entrenador), reacciona según su
## temperamento (Creature.temperament): agresivo → te ataca; territorial → solo si entrás a su territorio;
## tímido → huye sin pelear; curioso → se acerca a mirarte. También sale de las celdas peligrosas.

@export var wander_radius := 56.0
## Distancia a la que detecta. -1 = la del temperamento; 0 = nunca detecta (muñecos de los autotests).
@export var aggro_radius := -1.0

var _goal := Vector2.ZERO
var _pause := 0.0
var _scan := 0.0
## Ya se fijó en alguien que no le interesó (territorial afuera de su zona): no repetir el aviso.
var _ignored: Creature


func enter(_msg: Dictionary = {}) -> void:
	actor.target = null
	actor.fight_opened = false
	_pick_goal()


func physics_update(delta: float) -> void:
	_scan -= delta
	if _scan <= 0.0:
		_scan = 0.25
		if _react():
			return
	var escape: Vector2 = actor.body.hazard_escape()
	if escape != Vector2.ZERO:
		actor.move(escape, actor.speed())
		return
	if _pause > 0.0:
		_pause -= delta
		actor.move(Vector2.ZERO, 0.0)
		return
	var diff: Vector2 = _goal - actor.global_position
	if diff.length() < 3.0 or actor.get_slide_collision_count() > 0:
		_pause = randf_range(0.8, 2.5)
		_pick_goal()
		return
	actor.move(diff.normalized(), actor.speed() * 0.35)


## Si nota a alguien, reacciona según el temperamento. Devuelve true si cambió de estado.
func _react() -> bool:
	var temp: Temperament = actor.temperament
	var seen := _spot_target(temp.detect_radius if aggro_radius < 0.0 else aggro_radius)
	if seen == null:
		_ignored = null
		return false
	match temp.on_notice:
		Temperament.OnNotice.ATTACK:
			_aggro(seen, temp)
			return true
		Temperament.OnNotice.TERRITORY:
			if seen.global_position.distance_to(actor.home) <= temp.territory_radius:
				_aggro(seen, temp)
				return true
			if _ignored != seen:
				_ignored = seen
				actor.facing = (seen.global_position - actor.global_position).normalized()
				actor.emote("...", 0.8)  # te vio, pero mientras no entres a su zona no le importa
			return false
		Temperament.OnNotice.FLEE:
			actor.emote("gota", 1.0)
			transition("flee", {"from": seen, "calm": true})
			return true
		Temperament.OnNotice.APPROACH:
			actor.emote(temp.notice_emote, 1.0)
			transition("watch", {"target": seen})
			return true
	return false


func _aggro(seen: Creature, temp: Temperament) -> void:
	actor.target = seen
	actor.emote(temp.notice_emote, 1.0)
	Events.wild_aggro.emit(actor, seen)
	transition("chase")


func _pick_goal() -> void:
	_goal = actor.home + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(8.0, wander_radius)


## El objetivo es tu Pokémon (si está afuera y en pie); si no hay, el entrenador.
func _spot_target(radius: float) -> Creature:
	if radius <= 0.0:
		return null
	for c in actor.get_tree().get_nodes_in_group("ally_creatures"):
		if c.is_down() or not c.visible:
			continue
		if actor.global_position.distance_to(c.global_position) < radius:
			return c
		if is_instance_valid(c.leader) and actor.global_position.distance_to(c.leader.global_position) < radius * 0.8:
			return c
	return null
