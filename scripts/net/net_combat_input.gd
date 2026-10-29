class_name NetCombatInput
extends CombatInput
## Órdenes que llegan por red (docs/PLAN_ONLINE.md, O-3): el servidor mueve con esto al Pokémon de cada jugador y cada
## cliente imita con esto al del rival. Paquete (`pack`): [mover, apuntar, punto apuntado (relativo a la arena), bits de
## los 4 ataques, cuántas veces esquivó]. El esquive va como contador para no perder el "recién apretado".

var move := Vector2.ZERO
var aim_vec := Vector2.DOWN
## Punto apuntado, relativo al origen de la arena.
var point := Vector2.ZERO
var slots := 0
var dodge_seq := 0
## Posición global de la arena (los paquetes vienen relativos a ella).
var origin := Vector2.ZERO
## Apagado (cuenta regresiva, pelea terminada): no se mueve ni ataca.
var enabled := true
var _dodge_used := 0


func set_packet(p: Array) -> void:
	if p.size() < 5:
		return
	move = (p[0] as Vector2).limit_length(1.0) if p[0] is Vector2 else Vector2.ZERO
	aim_vec = p[1] if p[1] is Vector2 else aim_vec
	point = p[2] if p[2] is Vector2 else point
	slots = int(p[3]) & 0b1111
	dodge_seq = int(p[4])


func move_dir(_actor: Creature) -> Vector2:
	return move if enabled else Vector2.ZERO


func aim(_actor: Creature) -> Vector2:
	return aim_vec


func aim_point(_actor: Creature) -> Vector2:
	return origin + point


func wants_slot(slot: int) -> bool:
	return enabled and (slots >> slot) & 1 == 1


func wants_dodge() -> bool:
	if enabled and dodge_seq != _dodge_used:
		_dodge_used = dodge_seq
		return true
	return false


## Arma el paquete con lo que pide `input` (teclado o bot) para `actor`. `dodge_seq` lo lleva quien llama.
static func pack(input: CombatInput, actor: Creature, arena_origin: Vector2, dodge_seq: int) -> Array:
	var bits := 0
	for i in MoveUser.SLOT_COUNT:
		if input.wants_slot(i):
			bits |= 1 << i
	return [input.move_dir(actor), input.aim(actor), input.aim_point(actor) - arena_origin, bits, dodge_seq]
