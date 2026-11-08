class_name TrainerMovesets
extends RefCounted
## Los ataques de los Pokémon de los entrenadores (decisión del usuario 2026-11-08):
## · **FireRed mejorado**: los 118 equipos que FireRed arma a mano (líderes, Alto Mando, rival, Giovanni, Rocket y
##   Entrenadores Guay importantes; `data/source/trainer_movesets.json`, de `tools/fetch_frlg_movesets.py`) llevan sus
##   ataques de FireRed, MT incluidas, pero lo que en tiempo real casi no cambia la pelea (`FILLER`: bajar un poco una
##   stat, evasión, precisión, Teletransporte) o un ataque de daño muy flojo al lado de lo que podría tener se cambia por
##   lo mejor que puede aprender (nivel + MT de su especie). A lo sumo `MAX_SWAPS` por Pokémon, para no perder la
##   identidad del líder; los huecos (Brock: Geodude con 2) se llenan aparte. Los reemplazos salen de lo que sabe por
##   nivel y, desde `TM_LEVEL`, también de las MT de su especie (lo que FireRed ya trae, como el Terremoto de Giovanni,
##   se respeta a cualquier nivel): así Brock no aparece con Terremoto.
## · Los **comunes** (FireRed: los últimos 4 por nivel): lo mejor que saben por nivel (`create_rival`) y, desde
##   `TM_LEVEL`, también entre las MT de su especie.
## Lo usan StoryDirector.fight, los entrenadores vivos (TrainerState), el torneo y la arena de prueba de la consola GM.
## Los Pokémon con kit de jefe (Onix, Starmie, Raichu de los líderes) siguen peleando con su kit (MoveUser.setup).

const PATH := "res://data/source/trainer_movesets.json"
## Desde este nivel los entrenadores comunes también eligen entre las MT de su especie.
const TM_LEVEL := 30
## Cuántos ataques de FireRed se pueden cambiar por Pokémon (sin contar los huecos).
const MAX_SWAPS := 2
## Un ataque de daño de FireRed con menos que esto del mejor que podría tener se considera flojo.
const WEAK_RATIO := 0.5
## Ataques de estado de FireRed que en tiempo real casi no cambian la pelea: se cambian primero.
const FILLER := ["agitacola", "malicioso", "grunido", "ataque_arena", "doble_equipo", "rizo_defensa", "fortaleza",
	"refugio", "teletransporte", "dulce_aroma", "rastreo", "pantalla_de_humo", "encanto", "afilar", "foco_energia",
	"cosquillas", "destello", "llanto_falso", "tragar", "reserva", "escupir"]

static var _parties: Array = []
static var _loaded := false


## Los equipos de FireRed con ataques propios: [{party, mons: [[especie, nivel, [ids]]]}].
static func parties() -> Array:
	if not _loaded:
		_loaded = true
		if FileAccess.file_exists(PATH):
			var data = JSON.parse_string(FileAccess.get_file_as_string(PATH))
			if data is Array:
				_parties = data
	return _parties


## Equipa a todo un equipo de entrenador: si es uno de los que FireRed arma a mano, "FireRed mejorado"; si no, lo
## mejor que sabe (con MT desde TM_LEVEL). `trainer_name` desempata equipos iguales (los de FireRed se llaman clase +
## nombre: "BikerLao"). Devuelve el nombre del equipo de FireRed que usó ("" si ninguno).
static func equip_team(team: Array, trainer_name: String = "") -> String:
	var party := find_party(team, trainer_name)
	var left: Array = party.get("mons", []).duplicate()  # (cada Pokémon de FireRed se usa una vez: hay equipos con 3 Koffing distintos)
	for inst: CreatureInstance in team:
		if inst == null:
			continue
		var fr: Array = _take_moves(left, inst)
		inst.equipped_moves = improved(inst, fr) if not fr.is_empty() else trainer_best(inst)
	return str(party.get("party", ""))


## El equipo de FireRed con la misma gente (especie y nivel): primero uno igual (y, entre iguales, el del mismo
## nombre); si no, el que más coincide (por lo menos la mitad). {} si ninguno.
static func find_party(team: Array, trainer_name: String = "") -> Dictionary:
	var want := _keys(team.map(func(i): return [i.species.id, i.level] if i != null else ["", 0]))
	var hint := trainer_name.to_lower().replace(" ", "").replace(".", "")
	var exact := {}
	var best := {}
	var best_hits := 0
	for p in parties():
		var have := _keys(p.mons)
		if have == want:
			if hint != "" and str(p.party).to_lower().ends_with(hint):
				return p
			if exact.is_empty():
				exact = p
			continue
		var hits := 0
		var left := have.duplicate()
		for k in want:
			if left.has(k):
				left.erase(k)
				hits += 1
		if hits > best_hits:
			best_hits = hits
			best = p
	if not exact.is_empty():
		return exact
	return best if best_hits * 2 >= want.size() and best_hits > 0 else {}


static func _keys(mons: Array) -> Array:
	var out := mons.map(func(m): return "%s:%d" % [m[0], int(m[1])])
	out.sort()
	return out


## Los ataques del primer Pokémon de FireRed que todavía no se usó con la misma especie y nivel (y lo saca de `left`).
static func _take_moves(left: Array, inst: CreatureInstance) -> Array:
	for i in left.size():
		var m: Array = left[i]
		if m[0] == inst.species.id and int(m[1]) == inst.level:
			left.remove_at(i)
			return m[2]
	return []


## Los ataques de FireRed de este Pokémon, mejorados (ver arriba). `fr` = ids de data/moves.
static func improved(inst: CreatureInstance, fr: Array) -> Array[MoveData]:
	var out: Array[MoveData] = []
	for id in fr:
		if DB.moves.has(id) and not out.has(DB.moves[id]):
			out.append(DB.moves[id])
	var pool := _pool(inst, out)
	var best_dmg := 0.0
	for m: MoveData in pool:
		best_dmg = maxf(best_dmg, inst.move_damage_score(m))
	# Qué se puede cambiar: primero el relleno, después los de daño muy flojos (el más flojo antes).
	var weak: Array = []
	for i in out.size():
		var m := out[i]
		if m.does_nothing() or FILLER.has(m.id):
			weak.append([i, -1.0])
		elif m.power * m.power_mult > 0.0 and inst.move_damage_score(m) < best_dmg * WEAK_RATIO:
			weak.append([i, inst.move_damage_score(m)])
	weak.sort_custom(func(a, b): return a[1] < b[1])
	var swaps := 0
	for w in weak:
		if swaps >= MAX_SWAPS:
			break
		var rest: Array[MoveData] = out.duplicate()
		rest.remove_at(w[0])
		# Un ataque de daño flojo se cambia por otro de daño (no por Atracción); el relleno, por lo que más falte.
		var pick := _pick(inst, pool, rest, w[1] >= 0.0)
		if pick != null and (w[1] < 0.0 or inst.move_damage_score(pick) > w[1]):
			out[w[0]] = pick
			swaps += 1
	while out.size() < CreatureInstance.SLOT_COUNT:
		var pick := _pick(inst, pool, out)
		if pick == null:
			break
		out.append(pick)
	while out.size() < CreatureInstance.SLOT_COUNT:
		out.append(null)
	return out


## Lo mejor que sabe un Pokémon de entrenador común: por nivel y, desde TM_LEVEL, también las MT de su especie.
static func trainer_best(inst: CreatureInstance) -> Array[MoveData]:
	return inst.best_equipment(inst.species.tm_moves if inst.level >= TM_LEVEL else [])


## De dónde puede sacar un reemplazo: lo que sabe por nivel, lo que ya trae de FireRed y, desde TM_LEVEL, las MT de su
## especie.
static func _pool(inst: CreatureInstance, fr: Array[MoveData]) -> Array[MoveData]:
	var pool: Array[MoveData] = inst.learned_moves()
	var extra: Array = fr.duplicate()
	if inst.level >= TM_LEVEL:
		extra.append_array(inst.species.tm_moves)
	for m in extra:
		if m != null and not pool.has(m):
			pool.append(m)
	return pool


## El mejor para sumar a `current`: si tiene menos de RIVAL_ATTACKS de daño (o `damage_only`), un ataque de daño (mejor
## si es de un tipo que no tiene); si no, uno de estado que valga la pena (utility_rank ≥ 2) y, si no hay, otro de daño.
static func _pick(inst: CreatureInstance, pool: Array[MoveData], current: Array[MoveData], damage_only: bool = false) -> MoveData:
	var types := {}
	var damage := 0
	for m in current:
		if m != null and m.power * m.power_mult > 0.0:
			damage += 1
			if m.element != null:
				types[m.element.id] = true
	var best_dmg: MoveData = null
	var best_dmg_v := 0.0
	var best_st: MoveData = null
	var best_st_v := 1
	for m in pool:
		if m == null or current.has(m) or m.does_nothing() or FILLER.has(m.id):
			continue
		if m.power * m.power_mult > 0.0:
			var v := inst.move_damage_score(m) * (0.85 if m.element != null and types.has(m.element.id) else 1.0)
			if v > best_dmg_v:
				best_dmg_v = v
				best_dmg = m
		else:
			var rank := CreatureInstance.utility_rank(m)
			if rank > best_st_v:
				best_st_v = rank
				best_st = m
	if damage_only:
		return best_dmg
	if damage < CreatureInstance.RIVAL_ATTACKS:
		return best_dmg if best_dmg != null else best_st
	return best_st if best_st != null else best_dmg
