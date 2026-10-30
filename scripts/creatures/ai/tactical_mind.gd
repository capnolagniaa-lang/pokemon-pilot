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

## Entorno: golpe que te deja un estado malo donde estás parado (descarga en lo mojado) y golpe que lo prepara.
const ENV_PUNISH := 1.6
const ENV_SETUP := 1.25
## Pegar cuerpo a cuerpo a uno cuya habilidad castiga el contacto (Electricidad Estática, Punto Tóxico...).
const CONTACT_RISK := 0.6
const MELEE_KINDS := [MoveData.Kind.MELEE, MoveData.Kind.LUNGE, MoveData.Kind.DASH, MoveData.Kind.WHIP]

var actor: Creature
var last_slot := -1
## Memoria de la pelea actual (contra `_watching`): lado de cada esquive (+1/-1) y forma de cada ataque tuyo.
var dodge_sides: Array[int] = []
var ranged_seen: Array[bool] = []
var feints := 0
## Ataca más seguido por un rato (momento del guion de un líder: multiplica el tiempo entre ataques).
var pace_boost := 1.0
var pace_boost_until := -1.0
## Ya avisó que se juega todo (con poca vida y temperamento valiente).
var all_in := false
var _watching: Creature


func _init(p_actor: Creature) -> void:
	actor = p_actor


static func difficulty() -> AiDifficulty:
	return CombatBody.difficulty()


# --- Memoria corta (IA-2) ---

## Mira al rival actual: si cambió, olvida lo anterior y empieza a observar al nuevo. Llamarlo cada cuadro de pelea.
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
	dodge_sides.clear()
	ranged_seen.clear()
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
	dodge_sides.append(1 if side > 0.0 else -1)
	if dodge_sides.size() > MEMORY:
		dodge_sides.pop_front()


func _on_move(m: MoveData) -> void:
	if m == null or m.category == MoveData.Category.STATUS and m.power <= 0.0:
		return
	ranged_seen.append(m.kind in RANGED_KINDS)
	if ranged_seen.size() > MEMORY:
		ranged_seen.pop_front()


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
	if read[0] == 0 or randf() >= READ_CHANCE * float(read[1]) * clampf(difficulty().smarts, 0.0, 1.0):
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
	return DB.type_chart.get_multiplier(element, against.instance.species.types)


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
func score(slot: int, dist: float, shot: bool) -> float:
	var m: MoveData = actor.moves.slots[slot]
	if m == null or not actor.body.fits(slot, dist):
		return 0.0
	if m.kind in CombatBody.NEEDS_SHOT and not shot:
		return 0.0
	var t: Creature = actor.target
	var value := STATUS_VALUE
	if m.power > 0.0 and m.category != MoveData.Category.STATUS:
		var eff := effectiveness(m.element, t)
		if eff <= 0.0:
			return 0.0  # no le hace nada: ni lo intenta
		var stab := Damage.STAB if m.element in actor.instance.species.types else 1.0
		value = m.power * m.power_mult * stab * eff * ability_mult(m, t) * env_mult(m, t)
		if value <= 0.0:
			return 0.0  # su habilidad lo absorbe
		if exposed(t):
			value *= PUNISH
	elif m.status != null and is_instance_valid(t) and t.statuses.has_status(m.status.id):
		return 0.0  # ya lo tiene
	elif m.kind in [MoveData.Kind.SHIELD, MoveData.Kind.SELF_BUFF] and low_hp_plan() == "cuidado":
		value *= 2.5  # con poca vida y cauteloso: se cubre o se cura
	if slot == last_slot:
		value *= REPEAT
	return value * randf_range(0.85, 1.15)


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
	for slot in MoveUser.SLOT_COUNT:
		if scores[slot] <= 0.0:
			continue
		# (el azar se mide en la escala del mejor, así un Fácil puede elegir cualquiera de los que llegan)
		var v := lerpf(randf() * top, scores[slot], smarts)
		if v > best_value:
			best_value = v
			best = slot
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
		for ty in t.instance.species.types:
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


## Qué tan bien le va a un Pokémon (instancia, con sus ataques equipados) contra `against`: su mejor efectividad
## contra él dividida la de él contra este, por la vida que le queda. Para elegir a quién sacar.
static func matchup_score(inst: CreatureInstance, against: Creature) -> float:
	var edge := 0.0
	var any := false
	for m in inst.equipped_moves:
		if m == null or m.power <= 0.0 or m.category == MoveData.Category.STATUS:
			continue
		any = true
		edge = maxf(edge, DB.type_chart.get_multiplier(m.element, against.instance.species.types))
	if not any:
		edge = 1.0
	var danger := 0.0
	any = false
	for m in against.moves.moves:
		if m == null or m.power <= 0.0 or m.category == MoveData.Category.STATUS:
			continue
		any = true
		danger = maxf(danger, DB.type_chart.get_multiplier(m.element, inst.species.types))
	if not any:
		danger = 1.0
	return edge / maxf(danger, 0.25) * (inst.hp / inst.max_hp())


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
