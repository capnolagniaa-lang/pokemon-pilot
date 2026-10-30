class_name CreatureWander
extends State
## Salvaje deambulando cerca de su lugar. Cuando nota a tu Pokémon (o al entrenador), reacciona según su
## temperamento (Creature.temperament): agresivo → te ataca; territorial → solo si entrás a su territorio;
## tímido → huye sin pelear; curioso → se acerca a mirarte. También sale de las celdas peligrosas.
## Salvajes vivos (docs/PLAN_IA.md IA-5, WildSociety): si duerme, solo se despierta si pasás al lado; si tu Pokémon le
## lleva muchos niveles, no se anima y se va; la presa huye del cazador, el cazador sale a perseguirla, y los curiosos
## se acercan a mirar una Pokébola tirada o un objeto del piso.

@export var wander_radius := 56.0
## Distancia a la que detecta. -1 = la del temperamento; 0 = nunca detecta (muñecos de los autotests).
@export var aggro_radius := -1.0

var _goal := Vector2.ZERO
var _pause := 0.0
var _scan := 0.0
## Ya se fijó en alguien que no le interesó (territorial afuera de su zona): no repetir el aviso.
var _ignored: Creature
## Cada cuánto mira a los otros salvajes (cazador/presa) y lo que hay en el piso.
var _life := 0.0


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
	_life -= delta
	if _life <= 0.0:
		_life = randf_range(0.8, 1.4)
		if _live():
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
	if actor.now() < actor.calm_until:
		return false  # acaba de soltar una pelea: un rato tranquilo (si le pegan, igual pelea)
	var temp: Temperament = actor.temperament
	var seen := _spot_target(temp.detect_radius if aggro_radius < 0.0 else aggro_radius)
	if seen == null:
		_ignored = null
		return false
	if WildSociety.outclassed(actor, seen) and temp.on_notice != Temperament.OnNotice.FLEE:
		# Tu Pokémon le lleva muchos niveles: no se anima (si le pegás, pelea igual).
		if _ignored != seen:
			_ignored = seen
			actor.emote("gota", 1.0)
			transition("flee", {"from": seen, "calm": true})
			return true
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


## Vida entre salvajes: la presa huye del cazador, el cazador sale a cazar, el curioso va a mirar algo del piso.
func _live() -> bool:
	if aggro_radius == 0.0 or actor.owner_name != "":
		return false  # (muñecos de los autotests; el Pokémon de un entrenador no se distrae)
	var w := WildSociety.rules()
	var hunter := WildSociety.nearby(actor, w.prey_alert, true)
	if hunter != null:
		actor.emote("gota", 0.8)
		transition("flee", {"from": hunter, "calm": true})
		return true
	var prey := WildSociety.nearby(actor, w.hunt_radius, false)
	if prey != null and randf() < w.hunt_chance:
		transition("hunt", {"prey": prey})
		return true
	if actor.temperament != null and actor.temperament.on_notice == Temperament.OnNotice.APPROACH:
		var thing := WildSociety.curiosity(actor)
		if thing != null:
			actor.emote("?", 1.0)
			transition("watch", {"target": thing})
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
	return spot_target(actor, radius)


static func spot_target(actor: Creature, radius: float) -> Creature:
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
