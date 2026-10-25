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
## Estilo de combate de arena (movimiento y combos): data/estilos/<especie>.tres. Rige con las reglas de arena.
var fight_style: FightStyle
## Velocidad propia (sin empuje): los pesados la acercan de a poco a la que piden (inercia).
var _move_vel := Vector2.ZERO
## Cadena de golpes y último ataque que conectó (para los combos): a quién, con qué y cuándo.
var _chain := 0
var _chain_target: Node = null
var _chain_time := -100.0
var _last_move_id := ""
## El último golpe que conectó (el mismo HitInfo = el mismo ataque: abanico, zona, canalizado, varias piedras).
var _last_hit_ref: HitInfo
var _world_ref: Node
## Salvaje: temperamento (qué hace al verte, hasta dónde persigue, cuándo huye). Sale de la especie; se puede
## pisar después de crearla (los autotests fuerzan "agresivo").
var temperament: Temperament
## Nombre del entrenador dueño ("" = salvaje). No se puede atrapar y el HUD dice "X de <dueño>".
var owner_name := ""
## Salvaje: segundos que le quedan espantado por un golpe fuerte (retrocede sin atacar).
var spook_left := 0.0
## Salvaje: ya hizo su apertura en esta pelea (se reinicia al volver a deambular).
var fight_opened := false
## Último intercambio de golpes (reloj de la criatura): mientras pelea de verdad no suelta la pelea por salir de
## su territorio (si no, el combate se cortaba y volvía a empezar a cada rato).
var last_exchange := -100.0
## Hasta cuándo no vuelve a notar a nadie (después de soltar una pelea), salvo que le peguen.
var calm_until := 0.0

const ENGAGED_TIME := 5.0
const CALM_AFTER_GIVING_UP := 6.0
## "Cuerpo" de la IA (ejecución compartida por salvajes y entrenadores; ver CombatBody).
var body: CombatBody:
	get:
		if body == null:
			body = CombatBody.new(self)
		return body

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
	fight_style = DB.fight_style_of(instance.species)  # el propio o el de su preevolución
	health.instance = instance
	health.heal_mult_source = statuses
	moves.setup(instance)
	var kit := instance.species.kit
	if kit != null and kit.signature != null and kit.signature.mechanic_script != null:
		signature = kit.signature.mechanic_script.new()
		add_child(signature)
		signature.setup(self, kit.signature)
		var s := signature.body_scale()
		if s != 1.0:  # jefes (Onix): más grandes, también la hurtbox
			sprite.scale = Vector2(s, s)
			hurtbox.scale = Vector2(s, s)
	hurtbox.set_team(team)
	collision_layer = BODY_LAYER_ALLY if team == Team.ALLY else BODY_LAYER_WILD
	dash_hitbox.monitoring = false
	hurtbox.hit_received.connect(_on_hit)
	health.depleted.connect(_on_depleted)
	add_to_group("creatures")
	if team == Team.WILD:
		home = global_position
		if temperament == null:
			temperament = instance.species.temperament if instance.species.temperament != null else DB.temperaments.get("territorial")
		machine.initial_state = machine.get_node("Wander")


func _physics_process(delta: float) -> void:
	_clock += delta
	cc_resist_left = maxf(0.0, cc_resist_left - delta)
	spook_left = maxf(0.0, spook_left - delta)


## Adentro de una Pokébola (mientras tiembla): invisible, quieto y sin recibir golpes.
func set_captured(inside: bool) -> void:
	visible = not inside
	process_mode = Node.PROCESS_MODE_DISABLED if inside else Node.PROCESS_MODE_INHERIT
	hurtbox.set_deferred("monitorable", not inside)
	collision_layer = 0 if inside else (BODY_LAYER_ALLY if team == Team.ALLY else BODY_LAYER_WILD)


func now() -> float:
	return _clock


## Si está peleando de verdad (hubo golpes en los últimos ENGAGED_TIME segundos).
func engaged() -> bool:
	return _clock - last_exchange < ENGAGED_TIME


## Suelta la pelea (salvaje): vuelve a su lugar y no nota a nadie por un rato.
func give_up_fight() -> void:
	calm_until = _clock + CALM_AFTER_GIVING_UP
	machine.transition_to("wander")


## Aviso sobre la cabeza ("!" te vio, "?" curiosidad, gota de miedo...).
func emote(text: String, time: float = 1.2) -> void:
	sprite.emote = text
	sprite.emote_left = time


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
	if arena_rules():
		m *= surface_mult()
	return move_speed_for(instance.stat("speed")) * m


# --- Combate de arena (docs/PLAN_IDENTIDAD_COMBATE.md "Combate de arena") ----------------------------------

## Constantes de las reglas de arena.
const CHAIN_WINDOW := 1.3  # segundos entre golpes para seguir la cadena
const CHAIN_STEP := 0.05  # +5% de daño por golpe encadenado
const CHAIN_MAX := 5  # hasta +25%
const HEAVY_ACCEL := 420.0  # px/s² de los pesados (inercia)
const HEAVY_KNOCKBACK := 0.6  # los pesados reciben este empuje
const AGILE_DODGE := 0.75  # los ágiles esquivan más seguido
## Cuánto frena cada superficie (tags de la celda, con el estado del entorno: cráter, mojado...).
const SURFACES := {"crater": 0.65, "pasto_alto": 0.85, "arena": 0.85, "mojado": 0.92}


## Si rigen las reglas de arena acá (en una arena, o en todos lados con GameConfig.arena_rules_everywhere).
func arena_rules() -> bool:
	if _world_ref == null or not is_instance_valid(_world_ref):
		_world_ref = get_tree().get_first_node_in_group("world") if is_inside_tree() else null
	return _world_ref != null and _world_ref.get("reactions") != null and _world_ref.reactions.arena_rules_at(global_position)


func move_style() -> String:
	return fight_style.move_style if fight_style != null else "normal"


## Multiplicador de velocidad por la superficie que pisa (los voladores no lo sienten).
func surface_mult() -> float:
	if move_style() == "volador" or swims or _world_ref == null:
		return 1.0
	var m := 1.0
	for tag in _world_ref.tags_at(global_position):
		m = minf(m, SURFACES.get(tag, 1.0))
	return m


## Salto de cráter: máximo de px que se puede cruzar y paso con que se revisa el camino.
const JUMP_MAX := 160.0
const JUMP_STEP := 6.0
const JUMP_LOOK := 32.0  # el cráter tiene que estar a esta distancia (o menos) adelante


## Dónde aterrizaría un salto de cráter hacia `dir` (Vector2.INF si no corresponde: no salta, no hay cráter
## adelante o la otra punta no es transitable).
func crater_jump_target(dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO or fight_style == null or not fight_style.can_jump or not arena_rules():
		return Vector2.INF
	var found := false
	var d := JUMP_STEP
	while d <= JUMP_MAX:
		var p := global_position + dir * d
		var crater: bool = _world_ref.tags_at(p).has("crater")
		if not found:
			if crater:
				found = true
			elif d >= JUMP_LOOK:
				return Vector2.INF  # no hay cráter justo adelante: esquive común
		elif not crater:
			var g: EnvironmentGrid = _world_ref.reactions.grid_at(p)
			if g == null or not MapRules.is_walkable(g.zone, g.zone.cell_at(p)) or g.zone.get_tags(g.zone.cell_at(p)).has("agua"):
				return Vector2.INF  # del otro lado hay una roca, pared o agua
			return p + dir * JUMP_STEP  # un pasito más allá del borde
		d += JUMP_STEP
	return Vector2.INF


## Salta por el aire hasta `landing` (invulnerable, como un esquive largo, con el sprite en arco).
func _jump_to(landing: Vector2) -> void:
	var dir := (landing - global_position).normalized()
	var dist := global_position.distance_to(landing)
	var time := maxf(dist / DASH_SPEED, DODGE_TIME) * 1.6  # más lento que el esquive: se ve el arco
	health.invulnerable_time = time + 0.12
	if signature != null:
		moves.dodge_cooldown *= signature.dodge_cooldown_mult()
	machine.transition_to("dash", {"dir": dir, "time": time, "attack": false, "speed": dist / time})
	var tw := create_tween()
	tw.tween_property(sprite, "lift", clampf(dist * 0.18, 10.0, 26.0), time * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(sprite, "lift", 0.0, time * 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	Events.signature_triggered.emit(self, "¡Salto!", Color(0.9, 0.95, 1.0))
	dodged.emit()


## Registra un golpe que conectó contra `target` y devuelve su bonus: cadena de golpes seguidos (+5% c/u, hasta
## +25%) y combo con nombre del estilo (`first` y enseguida `second`). {mult, knockback, status, name, chain}
## Un ataque de varios golpes cuenta UNA vez (pedido del usuario 2026-10-24: si no, se desbalancea): solo su primer
## golpe suma a la cadena, puede armar un combo y aplica el estado del combo; los demás no suman nada.
func register_hit(target: Node, hit: HitInfo) -> Dictionary:
	var t := now()
	if is_same_attack(target, hit, t):
		return {"mult": 1.0, "knockback": 1.0, "status": null, "name": "", "chain": _chain}
	if target == _chain_target and t - _chain_time <= CHAIN_WINDOW:
		_chain += 1
	else:
		_chain = 1
	var out := {"mult": 1.0 + CHAIN_STEP * mini(_chain - 1, CHAIN_MAX), "knockback": 1.0, "status": null, "name": "",
		"chain": _chain}
	if fight_style != null and target == _chain_target:
		for c in fight_style.combos:
			if c.second == hit.move.id and c.first == _last_move_id and c.first != c.second and t - _chain_time <= c.window:
				out["mult"] *= c.damage_mult
				out["knockback"] = c.knockback_mult
				out["status"] = c.status
				out["name"] = c.display_name
				break
	_chain_target = target
	_chain_time = t
	_last_move_id = hit.move.id
	_last_hit_ref = hit
	return out


## Si este golpe es otro golpe del mismo ataque que el anterior contra ese rival: el mismo HitInfo (abanico de
## proyectiles, ticks de una zona o un canalizado, varias piedras del cielo) o el mismo ataque enseguida si es un
## golpe con combo de varios pasos o una embestida con 2º golpe.
func is_same_attack(target: Node, hit: HitInfo, t: float) -> bool:
	if target != _chain_target:
		return false
	if hit == _last_hit_ref:
		return true
	var m := hit.move
	if m.id != _last_move_id:
		return false
	if m.kind == MoveData.Kind.MELEE and m.combo_steps > 1:
		return t - _chain_time <= m.combo_window
	if m.kind == MoveData.Kind.LUNGE:
		return t - _chain_time <= m.followup_delay + 0.4
	return false


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
	var want := dir * spd
	if move_style() == "pesado" and arena_rules():
		_move_vel = _move_vel.move_toward(want, HEAVY_ACCEL * get_physics_process_delta_time())  # inercia
	else:
		_move_vel = want
	velocity = _move_vel + knockback
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
	sprite.play_move(m, step)  # Shoot, Strike, Swing, LeapForth... según la forma (cae a Attack)
	var hit := HitInfo.from(self, m)
	if m.resource_scaling > 0.0 and signature != null:
		hit.damage_mult *= 1.0 + m.resource_scaling * msg.get("spent", 0.0) / signature.data.max_value
	move_released.emit(m)
	if m.cleanse_self:  # Giro Rápido: se saca de encima los problemas de estado
		for sid in statuses.active.keys():
			if ItemData.BAD_STATUSES.has(sid):
				statuses.cure(statuses.active[sid]["status"])
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
			if m.zone_strike:
				for k in maxi(1, m.strike_count):
					var sk := SkyStrike.new()
					get_parent().add_child(sk)
					var off := Vector2.ZERO if k == 0 else Vector2.from_angle(randf() * TAU) * randf_range(0.5, 1.0) * m.strike_spread
					sk.strike(hit, at + off, k * 0.15, self if m.strike_burrow else null)
			elif m.zone_traps:
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
## Esquive (Espacio). Con reglas de arena, si el estilo puede saltar y hay un cráter adelante (hacia `aim`, donde
## apuntás; si no, hacia `dir`), salta: cruza todos los cráteres seguidos hasta la otra punta, por el aire.
func dodge(dir: Vector2, aim: Vector2 = Vector2.ZERO) -> bool:
	if not can_act() or not statuses.can_move():
		return false
	# Salto de cráter: hacia donde apunta el mouse y, si ahí no hay pozo, hacia donde camina (WASD).
	var landing := crater_jump_target(aim.normalized()) if aim.length() > 4.0 else Vector2.INF
	if landing == Vector2.INF and dir.length() > 0.1:
		landing = crater_jump_target(dir.normalized())
	if landing != Vector2.INF and moves.consume_dodge():
		_jump_to(landing)
		return true
	if not moves.consume_dodge():
		return false
	health.invulnerable_time = DODGE_TIME + 0.12
	if signature != null:
		moves.dodge_cooldown *= signature.dodge_cooldown_mult()
	if move_style() == "agil" and arena_rules():
		moves.dodge_cooldown *= AGILE_DODGE
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


## Daño de un estado (veneno, quemado...): no despierta al dormido (pedido del usuario 2026-10-24).
func take_status_damage(amount: float) -> void:
	var dealt := health.apply_damage(amount)
	damage_received.emit(dealt, null)
	Events.creature_damaged.emit(self, dealt, null)


func _on_hit(hit: HitInfo) -> void:
	if health.is_invulnerable() or (signature != null and signature.ignores_hit(hit)):
		return
	var attacker: Creature = hit.attacker if is_instance_valid(hit.attacker) else null
	if attacker != null:
		last_exchange = _clock
		attacker.last_exchange = attacker.now()
	var interactions := DB.interactions_for(hit.move.element, statuses)
	var mult := 1.0
	for it in interactions:
		mult *= it.damage_mult
	if attacker and attacker.signature != null and hit.move.power > 0.0:
		mult *= attacker.signature.damage_mult_against(hit, self)
	if signature != null:
		mult *= signature.damage_taken_mult(hit)
	var combo := {}
	if DB.config.combos_enabled and attacker != null and hit.move.power > 0.0 and attacker.arena_rules():
		combo = attacker.register_hit(self, hit)  # cadena de golpes y combos con nombre
		mult *= combo["mult"]
		if combo["name"] != "":
			Events.signature_triggered.emit(attacker, "¡%s!" % combo["name"], Color(1.0, 0.85, 0.3))
			Events.camera_shake.emit(3.0)
		elif combo["chain"] >= 3:
			Events.signature_triggered.emit(attacker, "COMBO ×%d" % combo["chain"], Color(1.0, 0.95, 0.75))
		Events.combo_landed.emit(attacker, combo["name"], combo["chain"])
	var amount := Damage.resolve(hit, instance) * mult
	if hit.move.execute_below > 0.0 and health.ratio() <= hit.move.execute_below and hit.effectiveness > 0.0:
		amount = INF  # ejecución: lo remata aunque le quede vida
		Events.signature_triggered.emit(self, "¡Remate!", Color(1.5, 0.35, 0.3))
	var dealt := health.apply_damage(amount)
	if dealt > 0.0:
		statuses.on_damaged()
		sprite.flash()
		sprite.play_once("Hurt", 0.25)
	var push := statuses.knockback_mult() * (signature.knockback_taken_mult() if signature != null else 1.0)
	if move_style() == "pesado" and arena_rules():
		push *= HEAVY_KNOCKBACK
	push *= combo.get("knockback", 1.0)
	if hit.knockback != 0.0:
		knockback = (global_position - hit.origin).normalized() * hit.knockback * push
	damage_received.emit(dealt, hit)
	if attacker:
		if hit.move.drain > 0.0 and dealt > 0.0:
			attacker.health.heal(dealt * hit.move.drain)  # Absorber, Chupavidas
		attacker.hit_dealt.emit(self, hit, dealt)
	if hit.move.cooldown_lock > 0.0:
		for i in moves.cooldowns.size():  # Anulación: tarda más en recargar todo
			moves.cooldowns[i] += hit.move.cooldown_lock
			moves.cooldown_total[i] = maxf(moves.cooldown_total[i], moves.cooldowns[i])
		Events.signature_triggered.emit(self, "¡Anulado!", Color(0.9, 0.5, 0.9))
	Events.creature_damaged.emit(self, dealt, hit)
	if health.is_dead():
		if attacker:
			attacker.killed.emit(self)
		return
	var state := machine.current_name()
	var to_apply := [[hit.move.status, hit.move.status_chance], [hit.extra_status, hit.extra_status_chance],
		[DB.statuses.get(hit.move.element.hit_status_id),
			0.0 if hit.move.skip_element_status else hit.move.element.hit_status_chance]]  # el agua empapa al pegar
	for s in hit.move.statuses_on_hit:
		to_apply.append([s, 1.0])
	if combo.get("status") != null:
		to_apply.append([combo["status"], 1.0])  # el estado del combo con nombre
	for pair in to_apply:
		if pair[0] != null and randf() < pair[1]:
			statuses.apply(pair[0])
			if attacker:
				attacker.status_inflicted.emit(self, pair[0])
	for it in interactions:
		_apply_interaction(it)
	if (hit.knockback * push >= STAGGER_KNOCKBACK or state in ["cast", "channel"]) and machine.current_name() != "stunned":
		stun(0.25)
	if team == Team.WILD and not is_instance_valid(target) and attacker:
		# Si le pegan, pelea (también el tímido que huía tranquilo o el curioso que miraba).
		target = attacker
		Events.wild_aggro.emit(self, attacker)
		emote("!")
		if state in ["wander", "watch", "flee"]:
			machine.transition_to("chase")
	elif team == Team.WILD and temperament != null and hit.knockback >= STAGGER_KNOCKBACK and randf() < temperament.spook_chance:
		spook_left = 0.8  # se espanta: retrocede un momento
		emote("gota", 0.8)


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
