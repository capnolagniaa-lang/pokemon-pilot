class_name CreatureGlow
extends PointLight2D
## La llama de los Pokémon de tipo fuego (Charmander, Vulpix, Growlithe, Ponyta...) alumbra de noche (día y noche,
## parte D; docs/PLAN_DIA_NOCHE.md). Por tipo, nunca por especie. Titila suave y sigue la oscuridad del momento
## (Events.time_changed y al entrar a un interior); de día no se nota. Solo visual.

## Tipos que tienen llama propia.
const TYPES := ["fuego"]
const MAX_ENERGY := 0.4

var _base := 0.0


## Le pone la llama a una criatura si es de un tipo con llama. Devuelve la luz (o null).
static func attach_if_needed(c: Node2D, types: Array) -> CreatureGlow:
	if not types.any(func(t): return t != null and t.id in TYPES):
		return null
	var g := CreatureGlow.new()
	g.texture = NightLight.LIGHT_TEX
	g.color = Color(1.0, 0.5, 0.2)
	g.texture_scale = 0.9
	g.position = Vector2(0, -10)
	g.energy = 0.0
	c.add_child(g)
	return g


func _ready() -> void:
	Events.time_changed.connect(func(_h, _p): _update())
	Events.zone_entered.connect(func(_z): _update.call_deferred())
	_update()
	var tw := create_tween().set_loops()
	tw.tween_method(func(k: float): energy = _base * k, 1.0, 0.75, 0.18)
	tw.tween_method(func(k: float): energy = _base * k, 0.75, 1.0, 0.22)


func _update() -> void:
	_base = MAX_ENERGY * NightLight.darkness(self)
