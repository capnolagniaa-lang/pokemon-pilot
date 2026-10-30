extends State
## Salvaje cazando (docs/PLAN_IA.md IA-5, WildSociety): persigue a su presa un rato (ella huye). No se pegan: es para
## que el mapa se sienta vivo. Si tu Pokémon aparece cerca, reacciona como siempre (vuelve a deambular y te nota).

@export var max_time := 4.0

var _prey: Creature
var _time := 0.0


func enter(msg: Dictionary = {}) -> void:
	_prey = msg.get("prey")
	_time = 0.0
	actor.emote("!", 0.8)


func physics_update(delta: float) -> void:
	_time += delta
	var temp: Temperament = actor.temperament
	var leash: float = temp.leash if temp != null else 300.0
	if not is_instance_valid(_prey) or _prey.is_down() or _time > max_time \
			or actor.global_position.distance_to(actor.home) > leash \
			or is_instance_valid(actor.target):
		actor.calm_until = actor.now() + 3.0
		transition("wander")
		return
	var to: Vector2 = _prey.global_position - actor.global_position
	if to.length() < 14.0:
		actor.calm_until = actor.now() + 3.0  # la alcanzó: la presa se escapa y él se queda tranquilo
		transition("wander")
		return
	actor.facing = to.normalized()
	actor.move(actor.body.steer(to.normalized(), _prey.global_position), actor.speed() * 0.85)
