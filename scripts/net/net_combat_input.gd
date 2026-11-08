class_name NetCombatInput
extends CombatInput
## Órdenes que llegan por red (docs/PLAN_ONLINE.md, O-3): el servidor mueve con esto al Pokémon de cada jugador y cada
## cliente imita con esto al del rival. Paquete (`pack`): [mover, apuntar, punto apuntado (relativo a la arena), bits de
## los 4 ataques, cuántas veces esquivó, contadores de toques de los 4 ataques]. El esquive y los toques van como
## contadores para no perder el "recién apretado": los paquetes van sin garantía, y un toque de un solo cuadro que viajaba
## en un paquete perdido antes no llegaba nunca (tu pantalla lo mostraba y el servidor no; protocolo 7).

## Toques por ranura: 8 bits cada uno, los 4 en un entero.
const PRESS_BITS := 8
const PRESS_MASK := (1 << PRESS_BITS) - 1
## Un toque que llegó como contador cuenta como apretado este tiempo (dos paquetes pueden llegar en el mismo cuadro: si el
## segundo lo apagara, el Pokémon no llegaría a leerlo).
const PRESS_HOLD_MS := 100
## Un vector del paquete más largo que esto es basura (el punto apuntado va relativo a la arena).
const MAX_POINT := 4096.0

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
## ¿Ataca con las teclas del paquete? El servidor sí; la copia del rival en un cliente no: ataca cuando el servidor
## avisa que atacó (evento "use", OnlineBattle), así no depende de las recargas y los PP de esta copia.
var attacks := true
var _dodge_used := 0
## Contadores de toques vistos por ranura y hasta cuándo vale cada toque que llegó como contador.
var _press_seen := [0, 0, 0, 0]
var _press_until := [0, 0, 0, 0]


## (El apuntado de los ataques de zona con joystick pasa en el juego del jugador: acá llega el ataque ya soltado.)
func tick(_actor_now: Creature, _delta: float) -> void:
	pass


## Aplica un paquete. Lo que no tenga sentido (tipos raros, NaN, infinitos, vectores enormes) se ignora: un cliente
## roto o malicioso no puede mandar al Pokémon al infinito.
func set_packet(p: Array) -> void:
	if p.size() < 5:
		return
	move = (p[0] as Vector2).limit_length(1.0) if _ok_vec(p[0], INF) else Vector2.ZERO
	if _ok_vec(p[1], MAX_POINT):
		aim_vec = p[1]
	if _ok_vec(p[2], MAX_POINT):
		point = p[2]
	slots = (int(p[3]) & 0b1111) if _ok_num(p[3]) else 0
	dodge_seq = int(p[4]) if _ok_num(p[4]) else dodge_seq
	var presses: int = int(p[5]) if p.size() > 5 and _ok_num(p[5]) else -1
	if presses < 0:
		return
	for s in MoveUser.SLOT_COUNT:
		var n: int = (presses >> (s * PRESS_BITS)) & PRESS_MASK
		if n != _press_seen[s]:
			_press_until[s] = Time.get_ticks_msec() + PRESS_HOLD_MS
		_press_seen[s] = n


static func _ok_vec(v, max_len: float) -> bool:
	return v is Vector2 and v.is_finite() and v.length() <= max_len


static func _ok_num(v) -> bool:
	return v is int or (v is float and is_finite(v))


func move_dir(_actor: Creature) -> Vector2:
	return move if enabled else Vector2.ZERO


func aim(_actor: Creature) -> Vector2:
	return aim_vec


func aim_point(_actor: Creature) -> Vector2:
	return origin + point


## Apretado ahora, o un toque que llegó solo como contador (el paquete con el bit se perdió).
func wants_slot(slot: int) -> bool:
	return enabled and attacks and ((slots >> slot) & 1 == 1 or Time.get_ticks_msec() < _press_until[slot])


func wants_dodge() -> bool:
	if enabled and dodge_seq != _dodge_used:
		_dodge_used = dodge_seq
		return true
	return false


## Arma el paquete con lo que pide `input` (teclado o bot) para `actor`. `dodge_seq` y `press_seq` (contadores por ranura,
## ver `count_presses`) los lleva quien llama.
static func pack(input: CombatInput, actor: Creature, arena_origin: Vector2, dodge_seq: int, press_seq: Array = []) -> Array:
	var bits := 0
	for i in MoveUser.SLOT_COUNT:
		if input.wants_slot(i):
			bits |= 1 << i
	return [input.move_dir(actor), input.aim(actor), input.aim_point(actor) - arena_origin, bits, dodge_seq, pack_presses(press_seq)]


## Suma un toque a cada ranura que pasó de suelta a apretada entre `prev_bits` y `bits`. Devuelve los bits nuevos.
static func count_presses(prev_bits: int, bits: int, press_seq: Array) -> int:
	while press_seq.size() < MoveUser.SLOT_COUNT:
		press_seq.append(0)
	for i in MoveUser.SLOT_COUNT:
		if (bits >> i) & 1 == 1 and (prev_bits >> i) & 1 == 0:
			press_seq[i] = (press_seq[i] + 1) & PRESS_MASK
	return bits


static func pack_presses(press_seq: Array) -> int:
	var out := 0
	for i in mini(press_seq.size(), MoveUser.SLOT_COUNT):
		out |= (int(press_seq[i]) & PRESS_MASK) << (i * PRESS_BITS)
	return out
