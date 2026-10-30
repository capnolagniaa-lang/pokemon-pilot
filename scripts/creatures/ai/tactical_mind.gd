class_name TacticalMind
extends RefCounted
## "Mente" táctica de la IA (docs/PLAN_IA.md, IA-1): *qué* hacer en la pelea. Puntúa los ataques según la situación
## (potencia, STAB, efectividad contra el rival, si el rival está vulnerable, no repetir siempre) y lee los tipos para
## saber si conviene cuidarse o presionar. El *cómo* (apuntar, esquivar, moverse) sigue en CombatBody. Una por
## criatura (`Creature.mind`); la usan los salvajes y los Pokémon de los entrenadores (mismo estado "attack").

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

var actor: Creature
var last_slot := -1


func _init(p_actor: Creature) -> void:
	actor = p_actor


static func difficulty() -> AiDifficulty:
	return CombatBody.difficulty()


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
		value = m.power * m.power_mult * stab * eff
		if exposed(t):
			value *= PUNISH
	elif m.status != null and is_instance_valid(t) and t.statuses.has_status(m.status.id):
		return 0.0  # ya lo tiene
	if slot == last_slot:
		value *= REPEAT
	return value * randf_range(0.85, 1.15)


## Elige la ranura a usar (-1 = ninguna llega). Con `smarts` bajo (Fácil) piensa menos: mezcla el puntaje con azar.
func pick(dist: float) -> int:
	var shot: bool = actor.body.clear_shot(actor.target)
	var smarts := clampf(difficulty().smarts, 0.0, 1.0)
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
