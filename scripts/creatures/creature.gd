class_name Creature
extends CharacterBody2D
## Una criatura en el mundo (tu Pokémon o un salvaje). Los comportamientos viven en los estados de su
## StateMachine; acá están las acciones que esos estados usan (moverse, atacar, esquivar, recibir daño).

enum Team { ALLY, WILD }

const BODY_LAYER_ALLY := 1 << 3
const BODY_LAYER_WILD := 1 << 4
const DASH_SPEED := 520.0
const DODGE_TIME := 0.16
## Un golpe con este empuje o más interrumpe la carga de un ataque.
const STAGGER_KNOCKBACK := 200.0

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

@onready var sprite: CreatureSprite = $Sprite
@onready var machine: StateMachine = $StateMachine
@onready var health: Health = $Health
@onready var statuses: StatusEffects = $StatusEffects
@onready var moves: MoveUser = $MoveUser
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var dash_hitbox: Hitbox = $DashHitbox


func _ready() -> void:
	sprite.species = instance.species
	health.instance = instance
	moves.setup(instance.species.moves)
	hurtbox.set_team(team)
	collision_layer = BODY_LAYER_ALLY if team == Team.ALLY else BODY_LAYER_WILD
	dash_hitbox.monitoring = false
	hurtbox.hit_received.connect(_on_hit)
	health.depleted.connect(_on_depleted)
	if team == Team.WILD:
		home = global_position
		machine.initial_state = machine.get_node("Wander")


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


func speed() -> float:
	return instance.species.move_speed * statuses.speed_mult()


func attack_stat() -> float:
	return instance.attack() * statuses.attack_mult()


func move(dir: Vector2, spd: float) -> void:
	velocity = dir * spd + knockback
	move_and_slide()
	knockback = knockback.move_toward(Vector2.ZERO, 900.0 * get_physics_process_delta_time())
	if dir.length() > 0.1:
		facing = dir.normalized()


func can_act() -> bool:
	return not health.is_dead() and statuses.can_act() and machine.current_name() in ["controlled", "attack", "chase", "flee", "wander", "idle", "follow"]


## Intenta usar el ataque i apuntando a aim. Con cast_time pasa por el estado "cast".
func use_move(i: int, aim: Vector2) -> bool:
	if not can_act():
		return false
	var m := moves.consume(i)
	if m == null:
		return false
	if aim.length() > 0.01:
		facing = aim.normalized()
	Events.move_used.emit(self, m)
	if m.cast_time > 0.0:
		machine.transition_to("cast", {"move": m, "aim": facing})
	else:
		release_move(m, facing)
	return true


## Lanza el efecto del ataque (después de la carga, si tenía).
func release_move(m: MoveData, aim: Vector2) -> void:
	sprite.play_once("Attack", 0.35)
	var hit := HitInfo.from(self, m)
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
			machine.transition_to("dash", {"dir": aim, "time": m.dash_time, "attack": true})
		MoveData.Kind.SHIELD:
			health.shield_time = m.duration


func dodge(dir: Vector2) -> bool:
	if not can_act() or not moves.consume_dodge():
		return false
	health.invulnerable_time = DODGE_TIME + 0.12
	machine.transition_to("dash", {"dir": dir if dir.length() > 0.1 else facing, "time": DODGE_TIME, "attack": false})
	return true


## Queda inmovilizado un rato (golpe fuerte, parálisis, congelamiento).
func stun(time: float) -> void:
	if health.is_dead():
		return
	machine.transition_to("stunned", {"time": time})


func take_status_damage(amount: float) -> void:
	var dealt := health.apply_damage(amount)
	Events.creature_damaged.emit(self, dealt, null)


func _on_hit(hit: HitInfo) -> void:
	if health.is_invulnerable():
		return
	var dmg := Damage.resolve(hit, instance.species.types)
	var dealt := health.apply_damage(dmg)
	statuses.on_hit(hit)
	knockback = (global_position - hit.origin).normalized() * hit.move.knockback
	sprite.flash()
	sprite.play_once("Hurt", 0.25)
	Events.creature_damaged.emit(self, dealt, hit)
	if health.is_dead():
		return
	if hit.move.status != null and randf() < hit.move.status_chance:
		statuses.apply(hit.move.status)
	var state := machine.current_name()
	if hit.move.knockback >= STAGGER_KNOCKBACK or state == "cast":
		stun(0.25)
	if team == Team.WILD and not is_instance_valid(target) and is_instance_valid(hit.attacker):
		target = hit.attacker
		Events.wild_aggro.emit(self, hit.attacker)
		if state == "wander":
			machine.transition_to("chase")


func _on_depleted() -> void:
	statuses.clear()
	machine.transition_to("fainted")
	Events.creature_fainted.emit(self)
