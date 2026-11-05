class_name Burrow
extends Node2D
## Excavar en dos tiempos (MoveData.burrow_time; pedido del usuario 2026-11-04): el primer toque mete al Pokémon bajo tierra
## (no se ve, no lo pegan, pasa por debajo de los demás y va un 10 % más rápido) y el segundo lo saca golpeando alrededor,
## donde esté. Si no lo apretás, sale solo al terminar el tiempo. Hijo de la criatura (Creature.burrow) mientras dura.

const SPEED_MULT := 1.1
const DUST_EVERY := 0.2
## Las capas de colisión de las otras criaturas y el jugador (3, 4, 5): bajo tierra no chocan.
const BODIES_MASK := (1 << 2) | (1 << 3) | (1 << 4)
## En la copia del rival de la pelea online sale cuando avisa el servidor; esto es por si el aviso no llega.
const REMOTE_MARGIN := 1.5
## Cada cuánto deja tierra removida atrás, en píxeles.
const TRAIL_EVERY := 16.0
## Cuando le queda poco, el montículo se agita (va a salir solo).
const HURRY_TIME := 1.0

var creature: Creature
var move: MoveData
var slot := -1
var time_left := 0.0
## Soltaste la tecla: el juego lee si está apretada y, sin esto, mantenerla te sacaría enseguida.
var armed := false
## Copia del rival en la pelea online: no sale sola.
var remote := false
var _layer := 0
var _mask := 0
var _dust := 0.0
var _mound: AnimatedSprite2D
var _last_trail := Vector2.ZERO


static func start(c: Creature, m: MoveData, p_slot: int) -> Burrow:
	var b := Burrow.new()
	b.creature = c
	b.move = m
	b.slot = p_slot
	b.time_left = m.burrow_time
	c.burrow = b
	c.add_child(b)
	return b


func _ready() -> void:
	z_index = -5
	_layer = creature.collision_layer
	_mask = creature.collision_mask
	creature.collision_layer = 0
	creature.collision_mask = _mask & ~BODIES_MASK
	creature.hurtbox.set_deferred("monitorable", false)  # los disparos pasan por arriba
	DigFx.dive(creature)
	creature.sprite.visible = false
	_mound = DigFx.mound(self)
	_last_trail = creature.global_position
	creature.health.depleted.connect(finish, CONNECT_ONE_SHOT)
	Fx.burst(creature.get_parent(), creature.global_position, Color(0.55, 0.45, 0.35), 16, 60.0)
	Events.camera_shake.emit(2.0)


func _physics_process(delta: float) -> void:
	time_left -= delta
	if creature.machine.current_name() in ["follow", "fainted"]:
		finish()  # terminó la pelea: vuelve sin golpear
		return
	if time_left <= (-REMOTE_MARGIN if remote else 0.0):
		emerge()
		return
	creature.health.invulnerable_time = maxf(creature.health.invulnerable_time, 0.1)
	_dust -= delta
	if _dust <= 0.0:
		_dust = DUST_EVERY
		Fx.burst(creature.get_parent(), creature.global_position, Color(0.55, 0.45, 0.35), 3, 18.0)  # se ve por dónde va
	if creature.global_position.distance_to(_last_trail) >= TRAIL_EVERY:
		_last_trail = creature.global_position
		DigFx.trail(creature.get_parent(), _last_trail)
	if _mound != null and time_left < HURRY_TIME:
		_mound.speed_scale = 1.4


## Sale golpeando alrededor (el golpe es el de SkyStrike, sin espera). La recarga arranca recién acá.
func emerge() -> void:
	var c := creature
	var m := move
	finish()
	var sk := SkyStrike.new()
	c.get_parent().add_child(sk)
	sk.strike(HitInfo.from(c, m), c.global_position, -m.strike_delay)
	sk.burrower = c
	c.health.invulnerable_time = maxf(c.health.invulnerable_time, 0.15)
	if slot >= 0:
		c.moves._start_cooldown(slot, m.cooldown)
		c.slot_used.emit(slot, c.facing, Vector2.INF)  # (la pelea online avisa con esto)
	if m.recovery > 0.0:
		c.machine.transition_to("recovery", {"time": m.recovery})


## Vuelve a la superficie sin golpear.
func finish() -> void:
	if creature.burrow != self:
		return
	creature.burrow = null
	creature.collision_layer = _layer
	creature.collision_mask = _mask
	creature.hurtbox.set_deferred("monitorable", true)
	creature.sprite.visible = true
	queue_free()
