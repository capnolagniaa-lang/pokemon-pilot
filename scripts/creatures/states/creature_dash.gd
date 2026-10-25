extends State
## Desplazamiento rápido: embestida (con hitbox) o movilidad/esquive (sin hitbox). Puede dejar una estela
## de parches peligrosos (Embestida Ígnea). Si tiene recuperación, al terminar queda expuesto.

const TRAIL_SPACING := 9.0

var _dir := Vector2.RIGHT
var _time := 0.0
var _attack := false
var _recovery := 0.0
var _trail: MoveData
var _trail_hit: HitInfo
## Lo comparten los parches de esta estela: pega una vez por tick a cada rival (HazardPatch).
var _trail_shared: Dictionary = {}
var _since_patch := 0.0
## Potencia de la embestida (0 = esquive): la usa el entorno para romper rocas frágiles.
var _power := 0.0
## Velocidad propia (el salto de cráter va más lento que el esquive para que se vea el arco).
var _speed := Creature.DASH_SPEED


func enter(msg: Dictionary = {}) -> void:
	_dir = (msg["dir"] as Vector2).normalized()
	_time = msg["time"]
	_attack = msg["attack"]
	_recovery = msg.get("recovery", 0.0)
	_trail = msg.get("trail")
	_power = msg.get("power", 0.0)
	_speed = msg.get("speed", Creature.DASH_SPEED)
	_since_patch = TRAIL_SPACING
	if _trail != null:
		# Golpe de la estela: misma habilidad, con su potencia y estado de estela.
		var tm: MoveData = _trail.duplicate()
		tm.power = _trail.trail_power
		tm.power_mult = 1.0
		tm.status = _trail.trail_status
		tm.status_chance = _trail.trail_status_chance
		tm.knockback = 30.0
		_trail_hit = HitInfo.from(actor, tm)
		_trail_shared = {}
	actor.facing = _dir
	actor.dash_hitbox.monitoring = _attack
	actor.sprite.afterimages = true
	if not _attack:
		actor.sprite.play_dodge(actor.move_style(), _time)  # Hop / Rotate / Tumble


func exit() -> void:
	actor.dash_hitbox.set_deferred("monitoring", false)
	actor.sprite.afterimages = false


func physics_update(delta: float) -> void:
	_time -= delta
	actor.knockback = Vector2.ZERO
	var before: Vector2 = actor.global_position
	actor.velocity = _dir * _speed
	actor.move_and_slide()
	var dist: float = actor.global_position.distance_to(before)
	actor.moved.emit(dist)
	if _trail != null:
		_since_patch += dist
		if _since_patch >= TRAIL_SPACING:
			_since_patch = 0.0
			var patch := HazardPatch.new()
			actor.get_parent().add_child(patch)
			patch.lay(_trail_hit, actor.global_position, _trail.trail_duration, _trail_shared)
	if _power > 0.0:
		for i in actor.get_slide_collision_count():
			var obj = actor.get_slide_collision(i).get_collider()
			if obj is EnvObject:
				Events.env_object_struck.emit(obj, _power)  # roca frágil: se rompe con la embestida
	if _time <= 0.0 or actor.get_slide_collision_count() > 0:
		if _recovery > 0.0:
			transition("recovery", {"time": _recovery})
		else:
			transition(actor.default_state())
