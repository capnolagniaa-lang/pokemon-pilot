class_name HitInfo
extends RefCounted
## Datos de un golpe: se calcula al lanzar el ataque, así no depende de que el atacante siga vivo.

var move: MoveData
var attacker: Node
var attacker_level: int = 1
## Ataque o At. Esp. del atacante según la categoría del ataque (con la quemadura ya aplicada).
var attack: float = 10.0
var attacker_types: Array[ElementType] = []
var origin: Vector2 = Vector2.ZERO
var team: int = 0
## Lo completa Damage.resolve al aplicarse sobre un objetivo.
var effectiveness: float = 1.0


static func from(user: Node, p_move: MoveData) -> HitInfo:
	var h := HitInfo.new()
	h.move = p_move
	h.attacker = user
	h.attacker_level = user.instance.level
	h.attack = user.attack_stat_for(p_move.category)
	h.attacker_types = user.instance.species.types
	h.origin = user.global_position
	h.team = user.team
	return h
