class_name Creature
extends CharacterBody2D
## Una criatura en el mundo (tu Pokémon o un salvaje). Los comportamientos viven en los estados de su
## StateMachine; acá están las acciones que esos estados usan (moverse, atacar, esquivar, recibir daño).
## Emite eventos de combate propios (hit_dealt, damage_received, moved...) que escuchan las mecánicas de
## firma (docs/PLAN_IDENTIDAD_COMBATE.md), así ningún Pokémon necesita un `if` en el código central.

enum Team { ALLY, WILD }

const BODY_LAYER_ALLY := 1 << 3
const BODY_LAYER_WILD := 1 << 4
const DASH_SPEED := 520.0
const DODGE_TIME := 0.16
## Un golpe con este empuje o más interrumpe la carga de un ataque.
const STAGGER_KNOCKBACK := 200.0
## Resistencia a control: después de un aturdimiento/sueño, los controles siguientes duran menos.
const CC_RESIST_TIME := 2.5
const CC_RESIST_FACTOR := 0.3

# Eventos de combate de esta criatura (para mecánicas de firma)
signal hit_dealt(target: Creature, hit: HitInfo, damage: float)
signal damage_received(amount: float, hit: HitInfo)
signal moved(distance: float)
signal dodged()
signal killed(target: Creature)
signal status_inflicted(target: Creature, status: StatusEffect)
signal move_released(move: MoveData)

## Datos de la criatura (especie, nivel, vida). Se asigna antes de agregarla al árbol.
var instance: CreatureInstance
var team: int = Team.ALLY
## Entrenador al que sigue (null si es salvaje).
var leader: Trainer
## Enemigo actual en combate.
var target: Creature
## Salvaje: punto alrededor del que deambula.
var home := Vector2.ZERO
## Tu Pokémon mientras lo controlás en combate.
var player_controlled := false
## De dónde salen las órdenes cuando player_controlled (teclado/mouse, o un bot en el autotest).
var input_source: CombatInput
var facing := Vector2.DOWN
var knockback := Vector2.ZERO
## Segundos que quedan de resistencia a control.
var cc_resist_left := 0.0

var _clock := 0.0

@onready var sprite: CreatureSprite = $Sprite
@onready var machine: StateMachine = $StateMachine
@onready var health: Health = $Health
@onready var statuses: StatusEffects = $StatusEffects
@onready var moves: MoveUser = $MoveUser
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var dash_hitbox: Hitbox = $DashHitbox
@onready var telegraph: Telegraph = $Telegraph


func _ready() -> void:
	sprite.species = instance.species
	health.instance = instance
	health.heal_mult_source = statuses
	moves.setup(instance.species.moves)
	hurtbox.set_team(team)
	collision_layer = BODY_LAYER_ALLY if team == Team.ALLY else BODY_LAYER_WILD
	dash_hitbox.monitoring = false
	hurtbox.hit_received.connect(_on_hit)
	health.depleted.connect(_on_depleted)
	add_to_group("creatures")
	if team == Team.WILD:
		home = global_position
		machine.initial_state = machine.get_node("Wander")


func _physics_process(delta: float) -> void:
	_clock += delta
	cc_resist_left = maxf(0.0, cc_resist_left - delta)


## Estado al que vuelve después de atacar, esquivar o recuperarse de un golpe.
func default_state() -> String:
	if health.is_dead():
		return "fainted"
	if player_controlled:
		return "controlled"
	if team == Team.WILD:
		return "attack" if is_instance_valid(target) else "wander"
	return "idle"


## Fuera de combate: debilitado (aunque ya haya recuperado algo de vida y esté por volver).
func is_down() -> bool:
	return health.is_dead() or machine.current_name() == "fainted"


## Velocidad de movimiento (píxeles/seg) a partir del stat oficial de Velocidad, con rendimiento
## decreciente: a nivel 5 Pikachu (15) ~80 px/s y Oddish (9) ~68; a nivel 50 Pikachu (110) ~140.
static func move_speed_for(speed_stat: float) -> float:
	return 40.0 + 26.0 * log(1.0 + speed_stat / 8.0) / log(2.0)


func speed() -> float:
	return move_speed_for(instance.stat("speed")) * statuses.speed_mult()


## Ataque (físico) o At. Esp. (especial) según la categoría; la quemadura baja solo el físico.
func attack_stat_for(category: MoveData.Category) -> float:
	if category == MoveData.Category.SPECIAL:
		return instance.stat("sp_attack")
	return instance.stat("attack") * statuses.attack_mult()


func move(dir: Vector2, spd: float) -> void:
	if not statuses.can_move():
		dir = Vector2.ZERO  # enraizado: puede atacar, no moverse
	var jitter := statuses.aim_jitter()
	if jitter > 0.0 and dir != Vector2.ZERO:
		dir = dir.rotated(sin(_clock * 3.1 + get_instance_id()) * jitter * 0.6)  # desorientado
	var before := global_position
	velocity = dir * spd + knockback
	move_and_slide()
	knockback = knockback.move_toward(Vector2.ZERO, 900.0 * get_physics_process_delta_time())
	if dir.length() > 0.1:
		facing = dir.normalized()
	var dist := global_position.distance_to(before)
	if dist > 0.01:
		moved.emit(dist)


func can_act() -> bool:
	return not health.is_dead() and statuses.can_act() and machine.current_name() in ["controlled", "attack", "chase", "flee", "wander", "idle", "follow"]


## Intenta usar el ataque i apuntando a aim. Con cast_time pasa por el estado "cast".
func use_move(i: int, aim: Vector2) -> bool:
	if not can_act() or i >= moves.moves.size():
		return false
	if moves.moves[i].kind == MoveData.Kind.DASH and not statuses.can_move():
		return false
	var m := moves.consume(i)
	if m == null:
		return false
	var jitter := statuses.aim_jitter()
	if jitter > 0.0:
		aim = aim.rotated(randf_range(-jitter, jitter))
	if aim.length() > 0.01:
		facing = aim.normalized()
	Events.move_used.emit(self, m)
	if m.cast_time > 0.0:
		machine.transition_to("cast", {"move": m, "aim": facing})
	else:
		release_move(m, facing)
	return true


## Lanza el efecto del ataque (después de la carga, si tenía). Si el ataque tiene recuperación, la
## criatura queda expuesta ese tiempo (ventana de castigo).
func release_move(m: MoveData, aim: Vector2) -> void:
	sprite.play_once("Attack", 0.35)
	var hit := HitInfo.from(self, m)
	move_released.emit(m)
	match m.kind:
		MoveData.Kind.PROJECTILE:
			var p := Projectile.new()
			get_parent().add_child(p)
			p.launch(hit, global_position + Vector2(0, -8) + aim * 8.0, aim)
		MoveData.Kind.AREA:
			var a := AreaEffect.new()
			get_parent().add_child(a)
			a.trigger(hit, global_position + Vector2(0, -6))
		MoveData.Kind.DASH:
			dash_hitbox.setup(hit)
			dash_hitbox.reset_targets()
			machine.transition_to("dash", {"dir": aim, "time": m.dash_time, "attack": true, "recovery": m.recovery})
			return
		MoveData.Kind.SHIELD:
			health.shield_time = m.duration
	if m.recovery > 0.0:
		machine.transition_to("recovery", {"time": m.recovery})


func dodge(dir: Vector2) -> bool:
	if not can_act() or not statuses.can_move() or not moves.consume_dodge():
		return false
	health.invulnerable_time = DODGE_TIME + 0.12
	machine.transition_to("dash", {"dir": dir if dir.length() > 0.1 else facing, "time": DODGE_TIME, "attack": false})
	dodged.emit()
	return true


## Queda inmovilizado un rato. `cc` = es un control (aturdimiento, sueño, congelamiento): respeta la
## resistencia a control y la activa al terminar. Los tambaleos por golpes fuertes no son control.
func stun(time: float, cc: bool = false) -> void:
	if health.is_dead():
		return
	if cc and cc_resist_left > 0.0:
		time *= CC_RESIST_FACTOR
	machine.transition_to("stunned", {"time": time, "cc": cc})


func take_status_damage(amount: float) -> void:
	var dealt := health.apply_damage(amount)
	statuses.on_damaged()
	damage_received.emit(dealt, null)
	Events.creature_damaged.emit(self, dealt, null)


func _on_hit(hit: HitInfo) -> void:
	if health.is_invulnerable():
		return
	var interactions := DB.interactions_for(hit.move.element, statuses)
	var mult := 1.0
	for it in interactions:
		mult *= it.damage_mult
	var dealt := health.apply_damage(Damage.resolve(hit, instance) * mult)
	statuses.on_damaged()
	knockback = (global_position - hit.origin).normalized() * hit.move.knockback
	sprite.flash()
	sprite.play_once("Hurt", 0.25)
	var attacker: Creature = hit.attacker if is_instance_valid(hit.attacker) else null
	damage_received.emit(dealt, hit)
	if attacker:
		attacker.hit_dealt.emit(self, hit, dealt)
	Events.creature_damaged.emit(self, dealt, hit)
	if health.is_dead():
		if attacker:
			attacker.killed.emit(self)
		return
	var state := machine.current_name()
	if hit.move.status != null and randf() < hit.move.status_chance:
		statuses.apply(hit.move.status)
		if attacker:
			attacker.status_inflicted.emit(self, hit.move.status)
	for it in interactions:
		_apply_interaction(it)
	if (hit.move.knockback >= STAGGER_KNOCKBACK or state == "cast") and machine.current_name() != "stunned":
		stun(0.25)
	if team == Team.WILD and not is_instance_valid(target) and attacker:
		target = attacker
		Events.wild_aggro.emit(self, attacker)
		if state == "wander":
			machine.transition_to("chase")


func _apply_interaction(it: StatusInteraction) -> void:
	if it.spread_radius > 0.0:
		for c in get_tree().get_nodes_in_group("creatures"):
			if c != self and c.team == team and not c.is_down() and c.global_position.distance_to(global_position) <= it.spread_radius:
				c.statuses.apply(it.requires)
	if it.consume:
		statuses.cure(it.requires)
	if it.apply != null:
		statuses.apply(it.apply)
	if it.extend != null:
		statuses.extend(it.extend, it.extend_mult)
	if it.stun_time > 0.0:
		stun(it.stun_time, true)
	Events.interaction_triggered.emit(self, it)


func _on_depleted() -> void:
	statuses.clear()
	machine.transition_to("fainted")
	Events.creature_fainted.emit(self)
