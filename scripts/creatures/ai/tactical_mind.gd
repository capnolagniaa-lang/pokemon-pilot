class_name TacticalMind
extends RefCounted
## "Mente" táctica de la IA (docs/PLAN_IA.md): *qué* hacer en la pelea. Puntúa los ataques según la situación
## (potencia, STAB, efectividad contra el rival, si el rival está vulnerable, no repetir siempre) y lee los tipos para
## saber si conviene cuidarse o presionar (IA-1). Tiene **memoria corta** de la pelea actual (IA-2): hacia qué lado
## esquivás (y te apunta ahí), si peleás de lejos o de cerca, cuándo tenés tus ataques fuertes en recarga (castiga esa
## ventana) y qué hacer con poca vida según su temperamento. Lee las **habilidades** (no tira lo que tu habilidad absorbe,
## evita el cuerpo a cuerpo si tu habilidad castiga el contacto, aprovecha las suyas) y el **entorno** (descarga eléctrica
## si estás en el agua o lo mojado, te moja primero si tiene con qué electrificarte, y no se para donde le harías eso
## vos) (IA-3). El *cómo* (apuntar, esquivar, moverse) sigue en
## CombatBody. Una por criatura (`Creature.mind`); la usan los salvajes y los Pokémon de los entrenadores.
## IA-7: calcula el daño de verdad de cada cruce (`hit_share`, `matchup_score`) y lee costumbres (`FoeMemory`).
## H-1: administra los PP: puede elegir no atacar (`saving`) para juntar lo que falta para un ataque mucho mejor.

## Ataques de estado / mejora (no tienen potencia): valor fijo; si CombatBody.fits los deja, son buena idea.
const STATUS_VALUE := 45.0
## El rival está vulnerable (stagger, cargando, recuperándose, dormido...): más ganas de pegarle fuerte.
const PUNISH := 1.4
## Repetir el último ataque vale menos (se lee igual, pero no es siempre lo mismo).
const REPEAT := 0.7
## Potencia desde la que un ataque sin carga se avisa antes (brillo + pausa corta).
const TELL_POWER := 60.0
## Estados del rival en los que está expuesto.
const EXPOSED_STATES := ["cast", "recovery", "channel", "stunned"]

## Cuántos eventos recuerda de cada cosa (la pelea actual; se borra al cambiar de rival).
const MEMORY := 10
## Esquives vistos para animarse a anticipar el próximo, y qué tan seguido tienen que ir al mismo lado.
const READ_MIN := 3
const READ_SURE := 0.75
## Cuánto corre el disparo hacia el lado al que vas a esquivar (px) y con qué probabilidad (× confianza × smarts).
const READ_OFFSET := 42.0
const READ_CHANCE := 0.6
## Ataques tuyos vistos para saber si peleás de lejos o de cerca.
const STYLE_MIN := 4
const STYLE_SURE := 0.7
## Vida por debajo de la cual cambia de plan (además del flee_below del temperamento).
const LOW_HP := 0.35
const RANGED_KINDS := [MoveData.Kind.PROJECTILE, MoveData.Kind.CHANNEL, MoveData.Kind.WHIP, MoveData.Kind.ZONE]
## Cruces: la suerte promedio del daño (0,85-1), el mínimo para no dividir por cero y la potencia que supone sin haber visto nada.
const AVERAGE_ROLL := 0.925
const MIN_SHARE := 0.01
const ASSUMED_POWER := 70.0
## Atacante contra defensor: hasta dónde pesa la diferencia de stats al elegir ataque.
const STAT_EDGE_MIN := 0.4
const STAT_EDGE_MAX := 2.5
## Repetís un ataque: esquiva antes, con esta parte de su tiempo de reacción, si estás a esta distancia.
const READ_REACT := 0.6
const READ_DODGE_DIST := 140.0

## Entorno: golpe que te deja un estado malo donde estás parado (descarga en lo mojado) y golpe que lo prepara.
const ENV_PUNISH := 1.6
const ENV_SETUP := 1.25
## Pegar cuerpo a cuerpo a uno cuya habilidad castiga el contacto (Electricidad Estática, Punto Tóxico...).
const CONTACT_RISK := 0.6
const MELEE_KINDS := [MoveData.Kind.MELEE, MoveData.Kind.LUNGE, MoveData.Kind.DASH, MoveData.Kind.WHIP]

## Juntar PP (H-1): espera por un ataque que esté a lo sumo a este tiempo, si lo que puede tirar ya vale menos que el
## valor de ese × SAVE_RATIO × paciencia (cuanto más lejos está, menos atrae: a SAVE_MAX_WAIT vale la mitad).
const SAVE_MAX_WAIT := 3.0
const SAVE_RATIO := 0.75
## Le falta más que esto: se aleja a juntar y lo muestra. Menos: se queda cerca (irse y volver le lleva más que esperar).
const SAVE_BACK_OFF := 1.0
## Tope por si algo le sigue sacando PP: deja de esperar y por un rato no vuelve a intentarlo.
const SAVE_GIVE_UP := 4.0
const SAVE_RETRY := 2.0
## Cada cuánto muestra que está juntando.
const SAVE_EMOTE_GAP := 3.0
## Daño por PP: los ataques caros pierden valor a medida que se vacía la barra (costo de referencia y cuánto pesa).
const THRIFT_COST := 66.0
const THRIFT_WEIGHT := 0.5
## Para rematar con el más barato: tiene que sacar la vida que le queda, con este margen por la suerte del daño.
const FINISH_MARGIN := 1.1

var actor: Creature
var last_slot := -1
## Lo que vio de cómo jugás. Propia, o la de todo el equipo en una pelea de entrenador (TrainerBattle).
var memory := FoeMemory.new()
var _shared_memory := false
var dodge_sides: Array[int]:
	get:
		return memory.dodge_sides
var ranged_seen: Array[bool]:
	get:
		return memory.ranged_seen
var feints := 0
var _read_dodge_at := -1.0
## Ataca más seguido por un rato (momento del guion de un líder: multiplica el tiempo entre ataques).
var pace_boost := 1.0
var pace_boost_until := -1.0
## Ya avisó que se juega todo (con poca vida y temperamento valiente).
var all_in := false
var _watching: Creature
## No ataca a propósito: está juntando PP para `_save_slot` (creature_attack se aleja y esquiva mientras tanto).
var saving := false
var _save_slot := -1
var _save_since := 0.0
var _save_blocked_until := -1.0
var _save_emote_at := -100.0
## La última elección de ataque (lo leen el registro y el overlay, AiTrace): puntaje de cada ranura y por qué salió
## ("remate", "elige", "junta" o "nada").
var last_scores: Array[float] = [0.0, 0.0, 0.0, 0.0]
var last_reason := ""


## Bajo fuego (S-0, docs/PLAN_SPARRING_IA.md): con FRONT_HITS golpes del rival en FRONT_WINDOW s mientras venía de frente
## (acercándose, embistiendo), se cuida WARY_MIN-WARY_MAX s (`wary()`): no viene en línea recta hasta que se le abra una
## ventana de verdad.
const FRONT_HITS := 2
const FRONT_WINDOW := 3.0
const WARY_MIN := 2.5
const WARY_MAX := 4.5
## Estados del rival en los que sí conviene entrar aunque se esté cuidando (el respiro de después de un ataque no).
const REAL_OPENINGS := ["cast", "channel", "stunned"]

var _front_hits: Array[float] = []
var wary_until := -1.0
## Cuántas veces se puso a cubierto (lo leen el estado de ataque, el test y, después, el sparring).
var wary_count := 0


func _init(p_actor: Creature) -> void:
	actor = p_actor
	actor.damage_received.connect(_on_damaged)


## Le pegaron: si venía de frente (acercándose o embistiendo hacia el rival) lo anota; dos seguidos y se cuida.
func _on_damaged(amount: float, hit: HitInfo) -> void:
	if amount <= 0.0 or hit == null or not is_instance_valid(actor.target) or hit.attacker != actor.target:
		return
	var to: Vector2 = actor.target.global_position - actor.global_position
	var closing: bool = to.length() > 1.0 and actor.velocity.length() > 5.0 and actor.velocity.normalized().dot(to.normalized()) > 0.5
	if not closing:
		return
	var now: float = actor.now()
	_front_hits.append(now)
	while not _front_hits.is_empty() and now - _front_hits[0] >= FRONT_WINDOW:
		_front_hits.pop_front()
	if _front_hits.size() >= FRONT_HITS:
		_front_hits.clear()
		wary_until = now + randf_range(WARY_MIN, WARY_MAX)
		wary_count += 1


## Se está cuidando de los disparos del rival (y no hay ventana, ni se juega todo, ni el rival está expuesto de verdad:
## cargando, canalizando o aturdido). La ventana acá es solo sus fuertes en recarga.
func wary() -> bool:
	if actor.now() >= wary_until or all_in or strong_on_cooldown():
		return false
	var t: Creature = actor.target
	return not (is_instance_valid(t) and t.machine.current_name() in REAL_OPENINGS)


static func difficulty() -> AiDifficulty:
	return CombatBody.difficulty()


# --- La amenaza que viene (S-0, docs/PLAN_SPARRING_IA.md) ---

## Radio del cuerpo para saber si algo lo toca, y margen de seguridad al salir. El cuerpo (hurtbox) está a BODY_OFFSET
## de los pies, igual que de donde salen los disparos: lo que vuela se compara ahí; lo del piso (zonas), en los pies.
const BODY_RADIUS := 10.0
const BODY_OFFSET := Vector2(0, -8)
const THREAT_MARGIN := 6.0
## Hasta dónde ve venir un disparo.
const SEE_THREAT := 220.0
## Un golpe cuerpo a cuerpo que viene a esta distancia ya es amenaza.
const MELEE_THREAT := 70.0
const MELEE_STATES := ["step", "lunge"]


## La amenaza más urgente que viene hacia el actor, o {} si no hay. Lo que una persona ve: un disparo en línea
## ("shot"), una carga apuntada o marcada en el piso ("cast"), una zona que está por caer o en la que está parado
## ("zone"), un chorro barriendo ("beam") o un golpe cuerpo a cuerpo que está saliendo ("melee").
##   key: con qué se decide una sola vez (el nodo, o "cast"/"melee") · eta: segundos hasta que pega · out: hacia
##   dónde salir · clear: cuánto hay que correrse para quedar afuera · strong: tira o corta cargas (mejor esquivar).
func threat() -> Dictionary:
	var best := {}
	var feet: Vector2 = actor.global_position
	var me: Vector2 = feet + BODY_OFFSET
	var parent := actor.get_parent()
	if parent == null:
		return best
	for n in parent.get_children():
		var th := {}
		if n is Projectile:
			th = _shot_threat(n, me)
		elif n is SkyStrike:
			th = _sky_threat(n, feet)
		elif n is ChannelCone:
			th = _beam_threat(n, me)
		elif n is GroundZone:
			th = _ground_threat(n, feet)
		if not th.is_empty() and (best.is_empty() or th.eta < best.eta):
			best = th
	var t: Creature = actor.target
	if is_instance_valid(t) and not t.is_down():
		var mine: Array = [_cast_threat(t, me, feet), _melee_threat(t, me)]
		for n in t.get_children():  # (el chorro de un canalizado cuelga del que lo tira)
			if n is ChannelCone:
				mine.append(_beam_threat(n, me))
		for th in mine:
			if not th.is_empty() and (best.is_empty() or th.eta < best.eta):
				best = th
	return best


func _shot_threat(p: Projectile, me: Vector2) -> Dictionary:
	if p.hit == null or p.hit.team == actor.team or p.hit.move == null or p.velocity.length() < 1.0:
		return {}
	var rel := me - p.global_position
	var v := p.velocity.normalized()
	var along := rel.dot(v)
	if along <= 0.0 or rel.length() > SEE_THREAT:
		return {}
	var side := rel.cross(v)  # distancia (con signo) a la línea del disparo
	var hitw := p.radius + BODY_RADIUS + THREAT_MARGIN
	if absf(side) > hitw:
		return {}
	var perp := v.orthogonal()
	var out := perp if rel.dot(perp) >= 0.0 else -perp  # hacia el lado al que ya está corrido
	return {"kind": "shot", "key": p, "source": p, "dir": v, "out": out, "eta": along / p.velocity.length(),
		"clear": hitw - absf(side) + 2.0, "strong": p.hit.move.knockback >= Creature.STAGGER_KNOCKBACK}


func _sky_threat(s: SkyStrike, me: Vector2) -> Dictionary:
	if s.hit == null or s.hit.team == actor.team or s.time_left() <= 0.0:
		return {}
	var d := me.distance_to(s.global_position)
	if d > s.radius + BODY_RADIUS:
		return {}
	var out := (me - s.global_position).normalized() if d > 1.0 else Vector2.RIGHT.rotated(randf() * TAU)
	return {"kind": "zone", "key": s, "source": s, "dir": -out, "out": out, "eta": s.time_left(),
		"clear": s.radius + BODY_RADIUS - d + 4.0, "strong": s.hit.move != null and s.hit.move.knockback >= Creature.STAGGER_KNOCKBACK}


func _ground_threat(g: GroundZone, me: Vector2) -> Dictionary:
	if g.hit == null or g.hit.team == actor.team:
		return {}
	var d := me.distance_to(g.global_position)
	if d > g.radius + BODY_RADIUS * 0.5:
		return {}
	var out := (me - g.global_position).normalized() if d > 1.0 else Vector2.RIGHT.rotated(randf() * TAU)
	return {"kind": "zone", "key": g, "source": g, "dir": -out, "out": out, "eta": 0.1,
		"clear": g.radius + BODY_RADIUS - d + 4.0, "strong": false}


func _beam_threat(c: ChannelCone, me: Vector2) -> Dictionary:
	if c.hit == null or c.hit.team == actor.team or c.hit.move == null:
		return {}
	var rel := me - (c.global_position if c.position != Vector2.ZERO else c.global_position + BODY_OFFSET)
	var d := rel.length()
	var m: MoveData = c.hit.move
	var length := m.cone_length * c.hit.area_mult
	if d < 1.0 or d > length + BODY_RADIUS:
		return {}
	var half := deg_to_rad(m.cone_angle_deg * 0.5)
	var ang := absf(c.direction.angle_to(rel))
	var body_ang := atan2(BODY_RADIUS, d)
	if ang > half + body_ang + 0.25:
		return {}
	var side := rel.cross(c.direction)
	var out := c.direction.orthogonal() * (1.0 if side >= 0.0 else -1.0)
	return {"kind": "beam", "key": c, "source": c, "dir": c.direction, "out": out, "eta": 0.05,
		"clear": maxf(10.0, d * sin(half + body_ang) - absf(side) + 6.0), "strong": false}


## El rival carga algo (estado "cast"): su telegrafiado dice adónde va. En línea: estoy en la franja; en círculo: adentro.
func _cast_threat(t: Creature, me: Vector2, feet: Vector2) -> Dictionary:
	if t.machine.current_name() != "cast" or t.last_move == null or t.telegraph == null:
		return {}
	var tg: Telegraph = t.telegraph
	var m: MoveData = t.last_move
	var left: float = maxf(0.0, 1.0 - tg.progress) * m.cast_time
	var strong: bool = m.knockback >= Creature.STAGGER_KNOCKBACK or m.power >= 80.0
	if tg.shape == Telegraph.Shape.LINE:
		var rel := me - (t.global_position + BODY_OFFSET)
		var along := rel.dot(tg.direction)
		if along < 0.0 or along > tg.length + BODY_RADIUS:
			return {}
		var side := rel.cross(tg.direction)
		var hitw := tg.width * 0.5 + BODY_RADIUS + THREAT_MARGIN
		if absf(side) > hitw:
			return {}
		var perp := tg.direction.orthogonal()
		var out := perp if rel.dot(perp) >= 0.0 else -perp
		var fly := along / (m.speed * Projectile.SPEED_MULT) if m.kind == MoveData.Kind.PROJECTILE and m.speed > 0.0 else 0.0
		return {"kind": "cast", "key": "cast", "source": t, "dir": tg.direction, "out": out, "eta": left + fly,
			"clear": hitw - absf(side) + 2.0, "strong": strong}
	if tg.shape == Telegraph.Shape.CIRCLE:
		var center: Vector2 = t.global_position + tg.position
		var d := feet.distance_to(center)
		if d > tg.radius + BODY_RADIUS:
			return {}
		var out := (feet - center).normalized() if d > 1.0 else (feet - t.global_position).normalized()
		return {"kind": "cast", "key": "cast", "source": t, "dir": -out, "out": out, "eta": left,
			"clear": tg.radius + BODY_RADIUS - d + 4.0, "strong": strong}
	return {}


## El rival está soltando un golpe cuerpo a cuerpo hacia acá (dio el paso o embiste).
func _melee_threat(t: Creature, me: Vector2) -> Dictionary:
	if t.machine.current_name() not in MELEE_STATES or t.last_move == null:
		return {}
	var rel := me - t.global_position
	var d := rel.length()
	if d > MELEE_THREAT or d < 1.0 or t.facing.dot(rel / d) < 0.6:
		return {}
	var perp := t.facing.orthogonal()
	var side := rel.cross(t.facing)
	var out := ((perp if side >= 0.0 else -perp) - t.facing * 0.6).normalized()  # al costado y un poco para atrás
	return {"kind": "melee", "key": "melee", "source": t, "dir": t.facing, "out": out, "eta": 0.12,
		"clear": 22.0, "strong": t.last_move.knockback >= Creature.STAGGER_KNOCKBACK}


# --- Memoria corta (IA-2) ---

## Mira al rival actual: si cambió, olvida lo anterior y empieza a observar al nuevo. Llamarlo cada cuadro de pelea.
func share_memory(shared: FoeMemory) -> void:
	memory = shared
	_shared_memory = true


func observe() -> void:
	var t: Creature = actor.target
	if t == _watching:
		return
	forget()
	if is_instance_valid(t):
		_watching = t
		t.dodged.connect(_on_dodged)
		t.move_released.connect(_on_move)


func forget() -> void:
	if is_instance_valid(_watching):
		if _watching.dodged.is_connected(_on_dodged):
			_watching.dodged.disconnect(_on_dodged)
		if _watching.move_released.is_connected(_on_move):
			_watching.move_released.disconnect(_on_move)
	_watching = null
	if not _shared_memory:
		memory.clear()
	_read_dodge_at = -1.0
	feints = 0
	all_in = false


## Esquivó: ¿a qué lado de la línea entre los dos? (+1 / -1; si fue para atrás o adelante no cuenta).
func _on_dodged() -> void:
	if not is_instance_valid(_watching) or not is_instance_valid(actor):
		return
	var line := (_watching.global_position - actor.global_position).normalized()
	var side := line.cross(_watching.last_dodge_dir.normalized())
	if absf(side) < 0.35:
		return
	memory.note_dodge(1 if side > 0.0 else -1)


func _on_move(m: MoveData) -> void:
	if m == null or m.category == MoveData.Category.STATUS and m.power <= 0.0:
		return
	memory.note_move(_watching.instance, m, m.kind in RANGED_KINDS)
	# Otra vez el de siempre: se lo veía venir, esquiva antes (según cuánto lee su entrenador).
	if m == memory.habit() and randf() < reads():
		_read_dodge_at = actor.now() + difficulty().reaction * READ_REACT


## Cuánto lee tus costumbres su entrenador (0..1). Los salvajes no estudian qué ataque repetís.
func reads() -> float:
	return actor.trainer_style.reads if actor.trainer_style != null else 0.0


## Hay que esquivar ya el ataque que repetís (una vez por ataque). Lo pregunta CombatBody.
func read_dodge_due() -> bool:
	if _read_dodge_at < 0.0 or actor.now() < _read_dodge_at:
		return false
	_read_dodge_at = -1.0
	var t: Creature = actor.target
	return difficulty().dodge_chance > 0.0 and is_instance_valid(t) \
		and t.global_position.distance_to(actor.global_position) < READ_DODGE_DIST


## Hacia qué lado suele esquivar (+1/-1) y qué tan seguro (0..1); 0 si todavía no se sabe.
func dodge_read() -> Array:
	if dodge_sides.size() < READ_MIN:
		return [0, 0.0]
	var right := dodge_sides.count(1)
	var share := float(maxi(right, dodge_sides.size() - right)) / dodge_sides.size()
	if share < READ_SURE:
		return [0, 0.0]
	return [1 if right * 2 > dodge_sides.size() else -1, share]


## Corrimiento del disparo hacia donde vas a esquivar (ZERO si no te tiene leído o esta vez no lo intenta). `off` =
## del actor al objetivo.
func aim_read(off: Vector2) -> Vector2:
	var read := dodge_read()
	var how_much: float = actor.trainer_style.reads if actor.trainer_style != null else 1.0
	if read[0] == 0 or randf() >= READ_CHANCE * float(read[1]) * clampf(difficulty().smarts, 0.0, 1.0) * how_much:
		return Vector2.ZERO
	# (lado +1 en _on_dodged = cross(línea, esquive) > 0 = hacia -línea.orthogonal())
	var perp := off.normalized().orthogonal() * -1.0
	return perp * float(read[0]) * READ_OFFSET


## Cómo pelea el rival: "lejos", "cerca" o "" (todavía no se sabe).
func foe_style() -> String:
	if ranged_seen.size() < STYLE_MIN:
		return ""
	var share := float(ranged_seen.count(true)) / ranged_seen.size()
	if share >= STYLE_SURE:
		return "lejos"
	if share <= 1.0 - STYLE_SURE:
		return "cerca"
	return ""


## Más ganas de esquivar si el rival tira mucho de lejos (lo vio venir).
func dodge_bonus() -> float:
	if difficulty().dodge_chance <= 0.0:
		return 0.0  # (en Fácil no esquiva nunca)
	return 0.15 * clampf(difficulty().smarts, 0.0, 1.0) if foe_style() == "lejos" else 0.0


## El rival tiene sus ataques fuertes en recarga (o se está recuperando): ventana para atacar.
func window_open() -> bool:
	var t: Creature = actor.target
	if not is_instance_valid(t) or t.moves == null:
		return false
	if t.machine.current_name() == "recovery":
		return true
	return strong_on_cooldown()


## El rival tiene todos sus ataques fuertes en recarga (sin contar el respiro de después de cada ataque).
func strong_on_cooldown() -> bool:
	var t: Creature = actor.target
	if not is_instance_valid(t) or t.moves == null:
		return false
	var strong := 0
	for slot in MoveUser.SLOT_COUNT:
		var m: MoveData = t.moves.slots[slot]
		if m == null or m.power * m.power_mult < TELL_POWER or m.category == MoveData.Category.STATUS:
			continue
		strong += 1
		if t.moves.can_use(slot):
			return false
	return strong > 0


## Plan con poca vida según el temperamento: "" (todo normal), "huye", "todo" (se juega todo) o "cuidado".
func low_hp_plan() -> String:
	var temp: Temperament = actor.temperament
	if temp == null or actor.health.ratio() >= maxf(LOW_HP, temp.flee_below):
		return ""
	var plan: Temperament.LowHp = actor.trainer_style.low_hp if actor.trainer_style != null else temp.low_hp
	match plan:
		Temperament.LowHp.ALL_IN:
			return "todo"
		Temperament.LowHp.CAREFUL:
			return "cuidado"
	return "huye"


## Efectividad de un tipo de ataque contra una criatura (1 si falta algo).
static func effectiveness(element: ElementType, against: Creature) -> float:
	if element == null or not is_instance_valid(against) or against.instance == null or DB.type_chart == null:
		return 1.0
	return DB.type_chart.get_multiplier(element, against.instance.types())


## La mejor efectividad de los ataques con daño de `from` contra `to`.
static func best_effectiveness(from: Creature, to: Creature) -> float:
	var best := 0.0
	var any := false
	if not is_instance_valid(from) or from.moves == null:
		return 1.0
	for m in from.moves.moves:
		if m == null or m.power <= 0.0 or m.category == MoveData.Category.STATUS:
			continue
		any = true
		best = maxf(best, effectiveness(m.element, to))
	return best if any else 1.0


## Cómo viene el cruce de tipos: "presiona" (él te pega súper efectivo y vos a él no), "cuidate" (al revés) o "".
func matchup() -> String:
	var t: Creature = actor.target
	if not is_instance_valid(t):
		return ""
	var edge := best_effectiveness(actor, t)
	var danger := best_effectiveness(t, actor)
	if danger >= 2.0 and edge < 2.0:
		return "cuidate"
	if edge >= 2.0 and danger < 2.0:
		return "presiona"
	return ""


## El rival está expuesto: en stagger, cargando, recuperándose o sin poder actuar.
static func exposed(t: Creature) -> bool:
	if not is_instance_valid(t):
		return false
	return t.hitstun_left > 0.0 or t.machine.current_name() in EXPOSED_STATES or not t.statuses.can_act()


## Puntaje de una ranura a esta distancia (0 = no sirve). `shot` = hay tiro limpio.
## Con los PP por debajo de esto (fracción de la barra) los ataques que gastan valen menos.
const PP_RESERVE := 0.3
const PP_THRIFT := 0.5


func score(slot: int, dist: float, shot: bool) -> float:
	var value := move_value(slot, dist, shot)
	if value <= 0.0:
		return 0.0
	var cost: float = actor.moves.pp_cost(slot)
	if cost > 0.0 and not all_in:
		if actor.moves.pp() - cost < actor.moves.max_pp() * PP_RESERVE:
			value *= PP_THRIFT  # pocos PP: guarda para lo importante y usa más el básico
		# Con la barra llena abre con lo fuerte; a medida que se vacía mira cuánto daño da por PP.
		var used := 1.0 - actor.moves.pp() / actor.moves.max_pp()
		value *= pow(THRIFT_COST / maxf(cost, 1.0), THRIFT_WEIGHT * used * patience())
	return value * randf_range(0.85, 1.15)


## Lo que vale esa ranura a esa distancia, sin mirar los PP (0 = no sirve). `soon` = aunque todavía no se pueda pagar.
func move_value(slot: int, dist: float, shot: bool, soon: bool = false) -> float:
	var m: MoveData = actor.moves.slots[slot]
	if m == null or m.does_nothing() or actor.moves.status_locked(slot) or not actor.body.fits(slot, dist, soon):
		return 0.0  # (los que todavía no hacen nada en combate, ni los intenta)
	if m.kind in CombatBody.NEEDS_SHOT and not shot:
		return 0.0
	var t: Creature = actor.target
	var value := STATUS_VALUE
	if m.power > 0.0 and m.category != MoveData.Category.STATUS:
		var eff := effectiveness(m.element, t)
		if eff <= 0.0:
			return 0.0  # no le hace nada: ni lo intenta
		var stab := Damage.STAB if m.element in actor.instance.types() else 1.0
		value = m.power * m.power_mult * hits_of(m) * stab * eff * stat_edge(m, t) * ability_mult(m, t) * env_mult(m, t) * actor.moves.role_damage(m)
		if value <= 0.0:
			return 0.0  # su habilidad lo absorbe
		if exposed(t):
			value *= PUNISH
	elif m.status != null and is_instance_valid(t) and t.statuses.has_status(m.status.id):
		return 0.0  # ya lo tiene
	elif not m.statuses_on_hit.is_empty() and is_instance_valid(t) \
			and m.statuses_on_hit.all(func(st: StatusEffect): return t.statuses.has_status(st.id)):
		return 0.0  # ya tiene todo lo que deja (Gruñido sobre uno intimidado)
	elif is_instance_valid(t) and m.statuses_on_hit.any(func(st: StatusEffect): return st.only_while != "" and not t.statuses.has_status(st.only_while)):
		return 0.0  # Pesadilla sobre uno despierto: no prende
	elif m.special != "":
		value *= SpecialMoves.ai_value(m, actor, t)
		if value <= 0.0:
			return 0.0
	elif m.weather != "":
		value *= CombatWeather.value_for(m.weather, actor, t)  # solo si le conviene (y no si ya está ese clima)
		if value <= 0.0:
			return 0.0
	elif m.pain_split and is_instance_valid(t):
		value *= 3.0 * (t.instance.hp - actor.instance.hp) / actor.health.max_hp()  # conviene si él tiene más vida
		if value <= 0.0:
			return 0.0
	elif m.kind in [MoveData.Kind.SHIELD, MoveData.Kind.SELF_BUFF] and low_hp_plan() == "cuidado":
		value *= 2.5  # con poca vida y cauteloso: se cubre o se cura
	if slot == last_slot:
		value *= REPEAT
	return value


## Golpes de un uso: su potencia es por golpe (Lanzallamas 6 × 0,2, Doble Bofetón 4 × 20): sin contarlos parecían flojísimos.
static func hits_of(m: MoveData) -> int:
	var hits := maxi(m.combo_steps, m.projectile_count)
	if m.kind == MoveData.Kind.CHANNEL and m.tick_interval > 0.0:
		hits = maxi(hits, ceili(m.channel_time / m.tick_interval))
	return maxi(1, hits)


# --- Juntar PP (H-1) ---

## Cuánto administra sus PP (0..1): lo que dice su entrenador o su temperamento, por lo que piensa en esta dificultad.
func patience() -> float:
	var base := 0.5
	if actor.trainer_style != null:
		base = actor.trainer_style.patience
	elif actor.temperament != null:
		base = actor.temperament.patience
	return base * clampf(difficulty().smarts, 0.0, 1.0)


## Cuánto le falta para el ataque que está esperando.
func save_left() -> float:
	return actor.moves.seconds_until_ready(_save_slot) if saving or _save_slot >= 0 else 0.0


## Un ataque que te remata: el más barato (no gasta el caro de más). -1 si no hay o esta vez no se fija.
func _finisher(scores: Array[float]) -> int:
	var t: Creature = actor.target
	if not is_instance_valid(t) or t.instance == null or randf() >= patience():
		return -1
	var left := t.instance.hp / maxf(t.instance.max_hp(), 1.0) * FINISH_MARGIN
	var best := -1
	var best_cost := INF
	for slot in MoveUser.SLOT_COUNT:
		if scores[slot] > 0.0 and hit_share(actor.moves.slots[slot], actor.instance, t.instance) >= left \
				and actor.moves.pp_cost(slot) < best_cost:
			best = slot
			best_cost = actor.moves.pp_cost(slot)
	return best


## ¿Conviene no atacar y juntar? No si te tiene expuesto o se juega todo. Una vez que decidió, sigue hasta poder usarlo.
func _wants_to_save(dist: float, shot: bool, scores: Array[float]) -> bool:
	var t: Creature = actor.target
	var now := actor.now()
	if all_in or now < _save_blocked_until or exposed(t):
		return false
	if saving and _save_slot >= 0:
		if actor.moves.can_use(_save_slot, true) and not actor.moves.can_use(_save_slot):
			if now - _save_since < SAVE_GIVE_UP:
				return true
			_save_blocked_until = now + SAVE_RETRY
		return false
	var best_now := 0.0
	var later := -1
	var later_value := 0.0
	for slot in MoveUser.SLOT_COUNT:
		var m: MoveData = actor.moves.slots[slot]
		if m == null:
			continue
		if scores[slot] > 0.0:
			best_now = maxf(best_now, move_value(slot, dist, shot))
		elif m.power > 0.0 and m.category != MoveData.Category.STATUS and not actor.moves.can_use(slot):
			var wait: float = actor.moves.seconds_until_ready(slot)
			# (el cuerpo a cuerpo se aleja mientras junta: vale lo mismo aunque ahora no llegue)
			var v := move_value(slot, minf(dist, m.reach() * 0.9), shot, true) * (1.0 - wait / (SAVE_MAX_WAIT * 2.0))
			if wait <= SAVE_MAX_WAIT and v > later_value:
				later = slot
				later_value = v
	if later < 0 or best_now >= later_value * SAVE_RATIO * patience():
		return false
	_save_slot = later
	_save_since = now
	if save_left() >= SAVE_BACK_OFF and now - _save_emote_at > SAVE_EMOTE_GAP:
		_save_emote_at = now
		actor.emote("...", 0.8)
	return true


## Cuánto rinde ese ataque por los stats: su Ataque contra tu Defensa si es físico, At. Esp. contra Def. Esp. si es especial.
func stat_edge(m: MoveData, t: Creature) -> float:
	if not is_instance_valid(t) or t.instance == null:
		return 1.0
	var special := m.category == MoveData.Category.SPECIAL
	var a := float(actor.instance.stat("sp_attack" if special else "attack"))
	var d := float(maxi(1, t.instance.stat("sp_defense" if special else "defense")))
	return clampf(a / d, STAT_EDGE_MIN, STAT_EDGE_MAX)


## Elige la ranura a usar (-1 = ninguna llega). Con `smarts` bajo (Fácil) piensa menos: mezcla el puntaje con azar.
func pick(dist: float) -> int:
	var shot: bool = actor.body.clear_shot(actor.target)
	var smarts := clampf(difficulty().smarts * (actor.trainer_style.smarts_mult if actor.trainer_style != null else 1.0), 0.0, 1.0)
	var best := -1
	var best_value := 0.0
	var top := 0.0
	var scores: Array[float] = []
	for slot in MoveUser.SLOT_COUNT:
		var s := score(slot, dist, shot)
		scores.append(s)
		top = maxf(top, s)
	last_scores = scores
	var finisher := _finisher(scores)
	if finisher >= 0:
		saving = false
		last_reason = "remate"
		return finisher
	saving = _wants_to_save(dist, shot, scores)
	if saving:
		last_reason = "junta"
		return -1
	for slot in MoveUser.SLOT_COUNT:
		if scores[slot] <= 0.0:
			continue
		# (el azar se mide en la escala del mejor, así un Fácil puede elegir cualquiera de los que llegan)
		var v := lerpf(randf() * top, scores[slot], smarts)
		if v > best_value:
			best_value = v
			best = slot
	last_reason = "elige" if best >= 0 else "nada"
	return best


## Se avisa antes de usarlo (fuerte y sin carga: los que cargan ya se marcan en el suelo).
static func needs_tell(m: MoveData) -> bool:
	return m != null and m.cast_time <= 0.0 and m.power * m.power_mult >= TELL_POWER \
		and m.category != MoveData.Category.STATUS


# --- Habilidades y entorno (IA-3) ---

static func _params(c: Creature) -> Dictionary:
	if not is_instance_valid(c) or c.signature == null or c.signature.data == null:
		return {}
	return c.signature.data.params


## Cuánto vale un ataque según las habilidades: la del rival (lo absorbe = 0, recibe menos de ese tipo, castiga el
## contacto) y la propia (Torrente y compañía con poca vida, más daño con esa forma o contra esos tipos).
func ability_mult(m: MoveData, t: Creature) -> float:
	var mult := 1.0
	var el: String = m.element.id if m.element != null else ""
	var foe := _params(t)
	if foe.get("absorb", {}).has(el):
		return 0.0
	var taken: Dictionary = foe.get("element_taken", {})
	if taken.has(el):
		mult *= float(taken[el])
	if m.kind in MELEE_KINDS and (foe.has("contact_status") or float(foe.get("thorns", 0.0)) > 0.0):
		mult *= CONTACT_RISK
	var own := _params(actor)
	if el != "" and own.get("pinch", "") == el and actor.health.ratio() < 1.0 / 3.0:
		mult *= 1.5
	var kinds: Dictionary = own.get("kind_mult", {})
	var kname: String = MoveData.Kind.keys()[m.kind]
	if kinds.has(kname):
		mult *= float(kinds[kname])
	var bonus: Dictionary = own.get("type_bonus", {})
	if is_instance_valid(t):
		for ty in t.instance.types():
			if bonus.has(ty.id):
				mult *= float(bonus[ty.id])
	return mult


func _reactions() -> ReactionSystem:
	var world := actor.get_tree().get_first_node_in_group("world") if actor.is_inside_tree() else null
	return world.get("reactions") if world != null else null


## Cuánto vale un ataque según dónde estás parado: si te deja un estado malo ahí (descarga en el agua o lo mojado)
## ×1,6; si prepara la celda para otro ataque suyo que lo haga (mojar y después electrificar) ×1,25.
func env_mult(m: MoveData, t: Creature) -> float:
	var rs := _reactions()
	if rs == null or m.element == null or not is_instance_valid(t) or not rs.grounded(t):
		return 1.0
	if rs.harms_at(m.element, t.global_position):
		return ENV_PUNISH
	for other in actor.moves.moves:
		if other != null and other != m and other.element != null and other.element != m.element and other.power > 0.0 				and rs.sets_up(m.element, t.global_position, other.element):
			return ENV_SETUP
	return 1.0


## Lugar peligroso para pararse: la celda ya le pone un estado, o el rival tiene un ataque que ahí se lo pondría
## (no se queda en el agua frente a uno con ataques eléctricos).
func danger_at(pos: Vector2) -> bool:
	var rs := _reactions()
	if rs == null:
		return false
	var st := rs.state_at(pos)
	if st != null and st.creature_status != null:
		return true
	var t: Creature = actor.target
	if not is_instance_valid(t) or not rs.grounded(actor):
		return false
	for m in t.moves.moves:
		if m != null and m.power > 0.0 and m.element != null and rs.harms_at(m.element, pos):
			return true
	return false


# --- Entrenadores (IA-4) ---

## Multiplica el tiempo entre ataques por un rato (momento del guion de un líder).
func boost(mult: float, time: float) -> void:
	pace_boost = mult
	pace_boost_until = actor.now() + time


## Ritmo propio del entrenador: su estilo (impaciente, aguante...) y el envión de un momento del guion.
func trainer_pace() -> float:
	var k := 1.0
	var st: TrainerStyle = actor.trainer_style
	if st != null:
		k *= st.pace
		if st.counter:
			k *= 0.6 if window_open() or exposed(actor.target) else 1.3  # aguanta y contragolpea
	if actor.now() < pace_boost_until:
		k *= pace_boost
	return k


## Qué tan bien le va a un Pokémon contra `against` (IA-7): cuántos golpes aguanta dividido cuántos necesita, con el daño
## de verdad (potencia, stats, STAB, tipos, habilidades) y la vida que le queda a cada uno. Más de 1 = gana el cruce. Sin
## `memory` conoce todos los ataques del rival; con ella, solo los que le vio, y si repite uno espera ese.
static func matchup_score(inst: CreatureInstance, against: Creature, memory: FoeMemory = null) -> float:
	var foe_inst: CreatureInstance = against.instance
	var mine := maxf(best_share(inst.equipped_moves, inst, foe_inst), MIN_SHARE)
	var theirs := MIN_SHARE
	if memory == null:
		theirs = best_share(against.moves.moves, foe_inst, inst)
	else:
		var habit := memory.habit()
		if habit != null and against.moves.moves.has(habit):
			theirs = maxf(hit_share(habit, foe_inst, inst), assumed_share(foe_inst, inst) * 0.5)
		else:
			theirs = maxf(best_share(memory.seen_moves(foe_inst), foe_inst, inst), assumed_share(foe_inst, inst))
	theirs = maxf(theirs, MIN_SHARE)
	var my_hp := inst.hp / maxf(inst.max_hp(), 1.0)
	var foe_hp := maxf(foe_inst.hp / maxf(foe_inst.max_hp(), 1.0), 0.05)
	return (my_hp / theirs) / (foe_hp / mine)


## Qué parte de la vida de `def` saca un uso de ese ataque de `atk`, en promedio (la fórmula de Damage, sin la suerte).
static func hit_share(m: MoveData, atk: CreatureInstance, def: CreatureInstance) -> float:
	if m == null or m.power <= 0.0 or m.category == MoveData.Category.STATUS or m.element == null:
		return 0.0
	return _share(m.power * m.power_mult, m.element, m.category == MoveData.Category.SPECIAL, atk, def) * hits_of(m)


static func best_share(moves: Array, atk: CreatureInstance, def: CreatureInstance) -> float:
	var best := 0.0
	for m in moves:
		best = maxf(best, hit_share(m, atk, def))
	return best


## Lo que se puede suponer sin haberle visto nada: un ataque común de su tipo, con su mejor stat de ataque.
static func assumed_share(atk: CreatureInstance, def: CreatureInstance) -> float:
	var best := 0.0
	var special: bool = atk.stat("sp_attack") > atk.stat("attack")
	for ty in atk.types():
		best = maxf(best, _share(ASSUMED_POWER, ty, special, atk, def))
	return best


static func _share(power: float, element: ElementType, special: bool, atk: CreatureInstance, def: CreatureInstance) -> float:
	var a := float(atk.stat("sp_attack" if special else "attack"))
	var d := float(maxi(1, def.stat("sp_defense" if special else "defense")))
	var base := (2.0 * atk.level / 5.0 + 2.0) * power * a / d / 50.0 + 2.0
	var stab := Damage.STAB if element in atk.types() else 1.0
	var value := base * stab * DB.type_chart.get_multiplier(element, def.types()) * AVERAGE_ROLL
	var ability := def.ability_data()
	if ability != null:
		if ability.params.get("absorb", {}).has(element.id):
			return 0.0
		value *= float(ability.params.get("element_taken", {}).get(element.id, 1.0))
	return value / maxf(def.max_hp(), 1.0)


# --- Manada (IA-5) ---

## Peleando con otro salvaje contra el mismo rival: el lugar del otro lado del rival (para rodearlo). INF si está solo
## o es el que se queda de frente (el de menor id).
func flank_point(ideal: float) -> Vector2:
	var t: Creature = actor.target
	if actor.team != Creature.Team.WILD or actor.owner_name != "" or not is_instance_valid(t):
		return Vector2.INF
	var mate: Creature = null
	for o in actor.get_tree().get_nodes_in_group("creatures"):
		if o != actor and o is Creature and o.team == actor.team and not o.is_down() and o.target == t \
				and o.owner_name == "" and o.global_position.distance_to(t.global_position) < 160.0:
			if mate == null or o.global_position.distance_to(actor.global_position) < mate.global_position.distance_to(actor.global_position):
				mate = o
	if mate == null or actor.get_instance_id() < mate.get_instance_id():
		return Vector2.INF
	var side: Vector2 = (t.global_position - mate.global_position).normalized()
	return t.global_position + side * maxf(ideal, 24.0)
