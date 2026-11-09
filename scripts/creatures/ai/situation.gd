class_name Situation
extends RefCounted
## En qué situación está el Pokémon de la IA nueva (Fase 2 de docs/IA_AUDITORIA.md), leída **solo** de lo que percibe
## (`Perception`: con retraso, sin mirar tus recargas ni tus PP) y de lo suyo propio. Es lo que va a mirar el cerebro de
## utilidad (Fase 3) para puntuar cada acción.
##
## **Táctica** (pueden valer varias a la vez; `primary` es la que manda): neutral cerca / media / lejos, ventana de castigo
## (estás expuesto y tiene con qué pegarte), ataque entrante, acorralado contra una pared, poca vida propia, rival para
## rematar. **Estratégica**: cómo viene el cruce (daño de verdad, `TacticalMind.matchup_score`, con lo que te vio), el mejor
## del banco, si conviene cambiar, sus ataques listos, tus PP estimados.

enum Tactic { NEUTRAL_CLOSE, NEUTRAL_MID, NEUTRAL_FAR, PUNISH, INCOMING, CORNERED, LOW_HP, FINISH }
const NAMES := ["neutral cerca", "neutral media", "neutral lejos", "castigar", "le viene un ataque", "acorralado",
	"poca vida", "rematar"]
## Orden en que mandan (la primera que valga es `primary`; si no vale ninguna, la banda neutral).
const PRIORITY := [Tactic.INCOMING, Tactic.FINISH, Tactic.PUNISH, Tactic.CORNERED, Tactic.LOW_HP]

## Cerca: hasta acá (px). Lejos: más allá del alcance de sus ataques con daño (o de FAR_MIN si no tiene).
const CLOSE := 60.0
const FAR_MIN := 160.0
## Un ataque que pega antes de esto (s) es "entrante".
const INCOMING_ETA := 0.6
## Acorralado: cuántas de las 8 direcciones están tapadas a CORNER_PROBE px.
const CORNER_PROBE := 28.0
const CORNER_BLOCKED := 3
## Poca vida propia.
const LOW_HP := 0.35
## Remate: un ataque listo que saca la vida que te queda, con este margen por la suerte del daño.
const FINISH_MARGIN := 1.1
## Cambio: los mismos criterios que TrainerBattle (no cambia si gana el cruce; el otro tiene que ser mucho mejor).
const SWITCH_STAY := TrainerBattle.SWITCH_STAY
const SWITCH_EDGE := TrainerBattle.SWITCH_EDGE

var flags: Array[int] = []
var primary: int = Tactic.NEUTRAL_MID
var dist := -1.0
var threat := {}
var foe_exposed := false
var window := false
var cornered := false
var low_hp := false
var can_finish := false
## Sus ataques con daño listos (fracción) y si alguno llega desde acá.
var my_ready := 0.0
var my_reach_now := false
## Estratégico.
var matchup := 1.0
var bench_best := 0.0
var bench_name := ""
var should_switch := false
var foe_pp := 1.0
var foe_seen := false


## Lee la situación de `actor` contra su rival. `bench` = los otros Pokémon sanos de su entrenador (para pensar un cambio).
static func read(actor: Creature, p: Perception, bench: Array = []) -> Situation:
	var s := Situation.new()
	var t: Creature = actor.target if is_instance_valid(actor.target) else null
	var snap := p.foe()
	s.foe_seen = not snap.is_empty() and t != null
	if not s.foe_seen:
		s.primary = Tactic.NEUTRAL_FAR
		s.flags.append(Tactic.NEUTRAL_FAR)
		return s
	s.dist = actor.global_position.distance_to(snap.pos)
	s.threat = p.threat()
	s.foe_exposed = p.foe_exposed()
	s.window = p.window_est()
	s.cornered = is_cornered(actor)
	s.low_hp = actor.health.ratio() < LOW_HP
	s.foe_pp = p.est_pp() / maxf(1.0, p.foe_max_pp())
	# Lo suyo (eso lo sabe sin retraso).
	var damaging := 0
	var ready := 0
	var best_share := 0.0
	var reach := 0.0
	for slot in MoveUser.SLOT_COUNT:
		var m: MoveData = actor.moves.slots[slot]
		if m == null or m.power <= 0.0 or m.category == MoveData.Category.STATUS:
			continue
		damaging += 1
		reach = maxf(reach, m.reach())
		if actor.moves.can_use(slot):
			ready += 1
			if actor.body.fits(slot, s.dist):
				s.my_reach_now = true
				best_share = maxf(best_share, TacticalMind.hit_share(m, actor.instance, t.instance))
	s.my_ready = float(ready) / damaging if damaging > 0 else 0.0
	s.can_finish = best_share > 0.0 and float(snap.hp) * FINISH_MARGIN <= best_share
	# Táctica.
	if not s.threat.is_empty() and float(s.threat.eta) <= INCOMING_ETA:
		s.flags.append(Tactic.INCOMING)
	if s.can_finish:
		s.flags.append(Tactic.FINISH)
	if s.foe_exposed and s.my_reach_now:
		s.flags.append(Tactic.PUNISH)
	if s.cornered:
		s.flags.append(Tactic.CORNERED)
	if s.low_hp:
		s.flags.append(Tactic.LOW_HP)
	var band: int = Tactic.NEUTRAL_MID
	if s.dist <= CLOSE:
		band = Tactic.NEUTRAL_CLOSE
	elif s.dist > maxf(FAR_MIN, reach):
		band = Tactic.NEUTRAL_FAR
	s.primary = band
	for tac in PRIORITY:
		if tac in s.flags:
			s.primary = tac
			break
	s.flags.append(band)
	# Estratégico (con lo que te vio: sin `knows_moves`).
	s.matchup = TacticalMind.matchup_score(actor.instance, t, actor.mind.memory)
	for inst in bench:
		if inst == actor.instance or inst.hp <= 0.0:
			continue
		var sc := TacticalMind.matchup_score(inst, t, actor.mind.memory)
		if sc > s.bench_best:
			s.bench_best = sc
			s.bench_name = inst.display_name()
	s.should_switch = s.bench_best > 0.0 and s.matchup < SWITCH_STAY and s.bench_best >= s.matchup * SWITCH_EDGE
	return s


## Paredes cerca en varias direcciones (contra un borde de la arena o en un rincón).
static func is_cornered(actor: Creature) -> bool:
	if not actor.is_inside_tree():
		return false
	var blocked := 0
	for k in 8:
		if actor.test_move(actor.global_transform, Vector2.RIGHT.rotated(k * TAU / 8.0) * CORNER_PROBE):
			blocked += 1
	return blocked >= CORNER_BLOCKED


func has(tac: int) -> bool:
	return tac in flags


static func name_of(tac: int) -> String:
	return NAMES[tac] if tac >= 0 and tac < NAMES.size() else "?"


## En una línea (overlay y registro).
func to_text() -> String:
	if not foe_seen:
		return "todavía no te ve"
	var others: PackedStringArray = []
	for f in flags:
		if f != primary:
			others.append(name_of(f))
	var txt := "%s%s · cruce %.2f" % [name_of(primary), (" (+ " + ", ".join(others) + ")") if not others.is_empty() else "", matchup]
	if bench_name != "":
		txt += " · banco: %s %.2f%s" % [bench_name, bench_best, " → conviene cambiar" if should_switch else ""]
	txt += " · listos %d%% · tus PP ~%d%%%s" % [roundi(my_ready * 100.0), roundi(foe_pp * 100.0), " · ventana" if window else ""]
	return txt


func to_dict() -> Dictionary:
	return {"tactica": name_of(primary), "flags": flags.map(func(f): return name_of(f)), "dist": roundi(dist), "cruce": snappedf(matchup, 0.01),
		"cambiar": should_switch, "ventana": window, "pp_rival": snappedf(foe_pp, 0.01)}
