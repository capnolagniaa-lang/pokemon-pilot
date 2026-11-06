class_name PenPokemon
extends CharacterBody2D
## Pokémon de adorno de un corral (`ExtraPen`): camina un rato, se queda quieto, vuelve a caminar, siempre adentro de `area`.
## No choca con nada y no es una criatura del combate.

const SPEED_MIN := 16.0
const SPEED_MAX := 26.0
const REST_MIN := 0.8
const REST_MAX := 3.5

## Lo lee CreatureSprite para elegir la fila de la hoja.
var facing := Vector2.DOWN
var area := Rect2()
var _goal := Vector2.ZERO
var _speed := SPEED_MIN
var _rest := 0.0


## `p_area` en píxeles, en las mismas coordenadas que `position`.
static func make(sp: SpeciesData, p_area: Rect2) -> PenPokemon:
	var p := PenPokemon.new()
	p.area = p_area
	p.collision_layer = 0
	p.collision_mask = 0
	p.position = p._random_point()
	p._rest = randf_range(0.0, REST_MAX)
	var spr := CreatureSprite.new()
	spr.name = "Sprite"
	p.add_child(spr)
	spr.species = sp
	return p


func _physics_process(delta: float) -> void:
	if _rest > 0.0:
		_rest -= delta
		velocity = Vector2.ZERO
		if _rest <= 0.0:
			_goal = _random_point()
			_speed = randf_range(SPEED_MIN, SPEED_MAX)
		return
	var to := _goal - position
	if to.length() < 2.0:
		_rest = randf_range(REST_MIN, REST_MAX)
		velocity = Vector2.ZERO
		return
	velocity = to.normalized() * _speed
	facing = velocity.normalized()
	position += velocity * delta


func _random_point() -> Vector2:
	return Vector2(randf_range(area.position.x, area.end.x), randf_range(area.position.y, area.end.y))
