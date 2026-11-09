class_name UtilityCoach
extends RefCounted
## El entrenador de la IA nueva (Fase 3 de docs/IA_AUDITORIA.md): en vez de la cadena fija de `TrainerBattle.think`
## (retirar → cambiar por tipos → Superpoción, cada 0,4 s y con una sola tirada por cruce), cada 0,5-1 s (o enseguida si
## cambiaste vos o a su Pokémon le pegaron fuerte) le pone utilidad a **mantener**, **cambiar** a cada uno del banco y
## **usar una Superpoción**, y elige con softmax (más frío que el del Pokémon: un entrenador no cambia por capricho).
## Mantener tiene un plus (histéresis) para no ir y venir. Cambiar cuesta: no en plena carga o golpe, y nunca dos seguidos.
## Lee la pelea con lo que su Pokémon percibe (`Situation`, sin `knows_moves`: solo lo que te vio).

## Cada cuánto piensa (s, al azar) y lo mínimo si algo lo apura.
const THINK := Vector2(0.5, 1.0)
const THINK_URGENT := 0.15
## Plus de quedarse (no cambiar por poco) y temperatura respecto de la del Pokémon.
const HOLD_BONUS := 0.12
const TEMP_MULT := 0.6
## No cambia en estos estados de su Pokémon (está tirando algo).
const BUSY := ["cast", "channel", "step", "lunge", "dash", "ride", "recovery"]
## Superpoción: se piensa desde esta vida; con vos cerca y sin ventana es arriesgada.
const POTION_FROM := 0.45
const POTION_RISK_DIST := 80.0

var battle: TrainerBattle
var options: Array[Dictionary] = []
var chosen := {}
var _next := 0.0
var _hp_seen := 1.0


func _init(p_battle: TrainerBattle) -> void:
	battle = p_battle


## Algo pasó (cambiaste vos, salió otro): que piense pronto.
func poke() -> void:
	_next = minf(_next, battle._clock + THINK_URGENT)


## Lo llama TrainerBattle cada cuadro de pelea; piensa cuando le toca.
func tick() -> void:
	var foe: Creature = battle.foe
	if not is_instance_valid(foe) or foe.is_down():
		return
	var hp := foe.health.ratio()
	if _hp_seen - hp > 0.2:
		poke()  # le pegaron fuerte
	_hp_seen = hp
	if battle._clock < _next:
		return
	_next = battle._clock + randf_range(THINK.x, THINK.y)
	think()


func think() -> void:
	var foe: Creature = battle.foe
	var me: Creature = battle.world.companion
	if not is_instance_valid(foe) or not is_instance_valid(me) or me.is_down():
		return
	options = evaluate()
	if options.is_empty():
		return
	var temp := foe.brain.temperature() * TEMP_MULT if foe.uses_new_brain() else AIProfile.of(foe).temperature * TEMP_MULT
	var pick := UtilityBrain.softmax_pick(options, temp)
	chosen = pick
	if AiTrace.enabled():
		AiTrace.note(foe, "entrenador", {"elige": pick.name, "p": snappedf(float(pick.p), 0.01),
			"top": options.slice(0, 3).map(func(o): return "%s %.2f" % [o.name, o.u])})
	match pick.kind:
		"cambiar":
			battle.coach_switch(pick.inst)
		"pocion":
			battle.use_potion()


## Las opciones del entrenador con su utilidad, de mayor a menor.
func evaluate() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var foe: Creature = battle.foe
	var me: Creature = battle.world.companion
	var st: TrainerStyle = battle.style
	foe.perception.tick()
	var bench: Array = battle.foe_team.filter(func(i): return i != foe.instance and i.hp > 0.0)
	var sit := Situation.read(foe, foe.perception, bench)
	var hp := foe.health.ratio()
	out.append({"kind": "mantener", "name": "mantener", "u": 0.5 + HOLD_BONUS + 0.2 * clampf(sit.matchup - 1.0, -1.0, 1.0)})
	# Cambiar: si va perdiendo el cruce, a uno que le vaya bastante mejor; más si recién cambiaste vos o el suyo está golpeado.
	var can_switch: bool = st != null and st.switch_types > 0.0 and battle._switches < st.max_switches \
		and battle._clock - battle._last_switch >= TrainerBattle.SWITCH_GAP \
		and battle._clock - battle._entered_at >= TrainerBattle.SWITCH_REACT \
		and not foe.machine.current_name() in BUSY and not foe.statuses.flag("traps")
	if can_switch:
		var you_swapped: bool = battle._player_swapped_at > battle._entered_at and battle._clock - battle._player_swapped_at < 5.0
		for inst in bench:
			if inst.hp < inst.max_hp() * 0.4 or (battle.leader and inst == battle.foe_team[-1] and bench.size() > 1):
				continue  # (muy golpeado para entrar; el líder guarda a su último)
			var sc := TacticalMind.matchup_score(inst, me, foe.mind.memory)
			var gain := (sc - sit.matchup) / maxf(sit.matchup, 0.1)
			if gain <= 0.3:
				continue
			var u := 0.25 + 0.4 * clampf(gain / 1.5, 0.0, 1.5) * st.switch_types
			if hp < 0.3:
				u += 0.15  # salvar al golpeado
			if you_swapped:
				u += 0.15  # responder a tu cambio
			if sit.matchup >= Situation.SWITCH_STAY:
				u *= 0.4  # le viene ganando: cambiar es un lujo
			out.append({"kind": "cambiar", "name": "cambiar a " + inst.display_name(), "u": u, "inst": inst})
	# Superpoción.
	if battle.potions_left > 0 and not battle._potion_used.has(foe.instance) and hp < POTION_FROM:
		var u := 0.3 + 1.4 * (POTION_FROM - hp)
		if sit.dist < POTION_RISK_DIST and not sit.window and not sit.foe_exposed:
			u *= 0.55  # con vos encima se la come
		out.append({"kind": "pocion", "name": "Superpoción", "u": u})
	out.sort_custom(func(a, b): return float(a.u) > float(b.u))
	return out
