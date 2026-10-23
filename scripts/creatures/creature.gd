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
## Salvaje de agua (apareció en el agua): no choca con la capa de agua, así puede nadar.
var swims := false:
	set(v):
		swims = v
		collision_mask = (collision_mask & ~2) if v else (collision_mask | 2)
## Tu Pokémon mientras lo controlás en combate.
var player_controlled := false
## De dónde salen las órdenes cuando player_controlled (teclado/mouse, o un bot en el autotest).
var input_source: CombatInput
var facing := Vector2.DOWN
var knockback := Vector2.ZERO
## Segundos que quedan de resistencia a control.
var cc_resist_left := 0.0
## Mecánica de firma (si la especie tiene kit con una).
var signature: SignatureMechanic

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
	moves.setup(instance)
	var kit := instance.species.kit
	if kit != null and kit.signature != null and kit.signature.mechanic_script != null:
		signature = kit.signature.mechanic_script.new()
		add_child(signature)
		signature.setup(self, kit.signature)
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
	var m := statuses.speed_mult()
	if signature != null:
		m *= signature.speed_mult()
	return move_speed_for(instance.stat("speed")) * m


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


## Usa la habilidad de una ranura (Kit.Slot) apuntando a `aim`; `point` es el lugar del mundo apuntado
## (para ubicar zonas). Con cast_time pasa por el estado "cast" (telegrafiado).
func use_slot(slot: int, aim: Vector2, point: Vector2 = Vector2.INF) -> bool:
	if not can_act() or slot < 0 or slot >= moves.slots.size() or moves.slots[slot] == null:
		return false
	if moves.slots[slot].kind in [MoveData.Kind.DASH, MoveData.Kind.LUNGE] and not statuses.can_move():
		return false
	var used := moves.consume(slot)
	if used.is_empty():
		return false
	var m: MoveData = used[0]
	var step: int = used[1]
	var jitter := statuses.aim_jitter()
	if jitter > 0.0:
		aim = aim.rotated(randf_range(-jitter, jitter))
	if aim.length() > 0.01:
		facing = aim.normalized()
	var spent := 0.0
	if m.resource_cost != 0.0 and signature != null:
		spent = signature.consume(m.resource_cost)
	Events.move_used.emit(self, m)
	var msg := {"move": m, "aim": facing, "step": step, "point": point, "spent": spent}
	if m.cast_time > 0.0:
		machine.transition_to("cast", msg)
	else:
		release_move(msg)
	return true


## Compatibilidad: usar "el ataque i" = la ranura i.
func use_move(i: int, aim: Vector2) -> bool:
	return use_slot(i, aim)


## Lanza el efecto de la habilidad (después de la carga, si tenía). msg: move, aim, step (combo),
## point (zona), spent (recurso de firma consumido). Si tiene recuperación, queda expuesto (ventana de castigo).
func release_move(msg: Dictionary) -> void:
	var m: MoveData = msg["move"]
	var aim: Vector2 = msg.get("aim", facing)
	var step: int = msg.get("step", 0)
	sprite.play_once("Attack", 0.35)
	var hit := HitInfo.from(self, m)
	if m.resource_scaling > 0.0 and signature != null:
		hit.damage_mult *= 1.0 + m.resource_scaling * msg.get("spent", 0.0) / signature.data.max_value
	move_released.emit(m)
	var recovery := m.recovery
	match m.kind:
		MoveData.Kind.PROJECTILE:
			var n := maxi(1, m.projectile_count)
			for k in n:
				var ang := 0.0 if n == 1 else deg_to_rad(lerpf(-m.spread_deg / 2.0, m.spread_deg / 2.0, k / float(n - 1)))
				var d := aim.rotated(ang)
				var p := Projectile.new()
				get_parent().add_child(p)
				p.launch(hit, global_position + Vector2(0, -8) + d * 8.0, d)
		MoveData.Kind.AREA:
			var a := AreaEffect.new()
			get_parent().add_child(a)
			a.trigger(hit, global_position + Vector2(0, -6))
		MoveData.Kind.MELEE:
			var final := step == m.combo_steps - 1
			if final:
				hit.knockback = m.final_knockback
			else:
				recovery = 0.0
			var s := MeleeSwing.new()
			get_parent().add_child(s)
			s.swing(hit, global_position + Vector2(0, -8) + aim * m.melee_range, m.swing_radius * hit.area_mult, aim)
		MoveData.Kind.ZONE:
			var at := zone_point(m, msg.get("point", Vector2.INF), aim)
			if m.zone_traps:
				var z := ZoneTrap.new()
				get_parent().add_child(z)
				z.place(hit, at)
			else:
				var gz := GroundZone.new()
				get_parent().add_child(gz)
				gz.place(hit, at)
				_track_zone(m, gz)
		MoveData.Kind.DASH:
			if m.dash_hits:
				dash_hitbox.setup(hit)
				dash_hitbox.reset_targets()
			if m.invulnerable_time > 0.0:
				health.invulnerable_time = maxf(health.invulnerable_time, m.invulnerable_time)
			machine.transition_to("dash", {"dir": aim, "time": m.dash_time, "attack": m.dash_hits,
				"recovery": recovery, "trail": m if m.trail_power > 0.0 else null,
				"power": m.power * m.power_mult if m.dash_hits else 0.0})
			return
		MoveData.Kind.LUNGE:
			# Se lanza hacia el punto apuntado; si conecta, el estado "lunge" encadena el 2º golpe.
			var p: Vector2 = msg.get("point", Vector2.INF)
			if p == Vector2.INF:
				p = target.global_position if is_instance_valid(target) else global_position + aim * m.lunge_range
			var dist := minf(global_position.distance_to(p), m.lunge_range)
			dash_hitbox.setup(hit)
			dash_hitbox.reset_targets()
			machine.transition_to("lunge", {"move": m, "dir": aim, "distance": maxf(dist, 10.0)})
			return
		MoveData.Kind.WHIP:
			var w := WhipLash.new()
			get_parent().add_child(w)
			w.lash(hit, global_position + Vector2(0, -8), aim)
		MoveData.Kind.SELF_BUFF:
			if m.self_status != null:
				statuses.apply(m.self_status)
		MoveData.Kind.SHIELD:
			health.shield_time = m.duration
		MoveData.Kind.CHANNEL:
			machine.transition_to("channel", {"move": m, "aim": aim, "hit": hit})
			return
	if recovery > 0.0:
		machine.transition_to("recovery", {"time": recovery})


## Dónde cae una zona: en el punto apuntado (limitado al alcance), en el objetivo, o delante.
func zone_point(m: MoveData, point: Vector2, aim: Vector2) -> Vector2:
	if point == Vector2.INF:
		point = target.global_position if is_instance_valid(target) else global_position + aim * m.placement_range * 0.6
	var d := point - global_position
	return global_position + d.limit_length(m.placement_range)


## Zonas activas por ataque (para respetar zone_max_count: se borra la más vieja).
var _zones: Dictionary = {}


func _track_zone(m: MoveData, zone: Node) -> void:
	if m.zone_max_count <= 0:
		return
	var list: Array = _zones.get(m, []).filter(func(z): return is_instance_valid(z))
	list.append(zone)
	while list.size() > m.zone_max_count:
		list.pop_front().expire()
	_zones[m] = list


## Esquive (Espacio): igual para todos. Breve invulnerabilidad.
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
	if health.is_invulnerable() or (signature != null and signature.ignores_hit(hit)):
		return
	var attacker: Creature = hit.attacker if is_instance_valid(hit.attacker) else null
	var interactions := DB.interactions_for(hit.move.element, statuses)
	var mult := 1.0
	for it in interactions:
		mult *= it.damage_mult
	if attacker and attacker.signature != null and hit.move.power > 0.0:
		mult *= attacker.signature.damage_mult_against(hit, self)
	var amount := Damage.resolve(hit, instance) * mult
	if hit.move.execute_below > 0.0 and health.ratio() <= hit.move.execute_below and hit.effectiveness > 0.0:
		amount = INF  # ejecución: lo remata aunque le quede vida
		Events.signature_triggered.emit(self, "¡Remate!", Color(1.5, 0.35, 0.3))
	var dealt := health.apply_damage(amount)
	if dealt > 0.0:
		statuses.on_damaged()
		sprite.flash()
		sprite.play_once("Hurt", 0.25)
	if hit.knockback != 0.0:
		knockback = (global_position - hit.origin).normalized() * hit.knockback * statuses.knockback_mult()
	damage_received.emit(dealt, hit)
	if attacker:
		attacker.hit_dealt.emit(self, hit, dealt)
	Events.creature_damaged.emit(self, dealt, hit)
	if health.is_dead():
		if attacker:
			attacker.killed.emit(self)
		return
	var state := machine.current_name()
	var to_apply := [[hit.move.status, hit.move.status_chance], [hit.extra_status, hit.extra_status_chance]]
	for s in hit.move.statuses_on_hit:
		to_apply.append([s, 1.0])
	for pair in to_apply:
		if pair[0] != null and randf() < pair[1]:
			statuses.apply(pair[0])
			if attacker:
				attacker.status_inflicted.emit(self, pair[0])
	for it in interactions:
		_apply_interaction(it)
	if (hit.knockback >= STAGGER_KNOCKBACK or state in ["cast", "channel"]) and machine.current_name() != "stunned":
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
