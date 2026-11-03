class_name MoveUser
extends Node
## Los 4 ataques de una criatura (kit propio o sus ataques sueltos) y sus recargas. Sin energía: lo único
## que limita es la recarga de cada ataque. El esquive (Espacio) tiene su propia recarga.

const SLOT_COUNT := 4
const DODGE_COOLDOWN := 0.9

## Teclas por rol, estilo League of Legends (pedido del usuario 2026-10-31; ajuste "slot_roles", APAGADO por defecto
## desde el 2026-11-03: "no debería haber diferencia entre las ranuras"; se puede prender en Ajustes): Clic izq. = ataque
## básico (recarga corta según la Velocidad, daño escalado para no superar el daño por segundo del ataque), Clic der.
## y Q = habilidades (como siempre), R = definitiva (recarga larga, pega más fuerte).
const BASIC_SLOT := 0
const ULT_SLOT := 3
const ULT_COOLDOWN := 1.6
const ULT_MIN_COOLDOWN := 8.0
const ULT_DAMAGE := 1.3
const BASIC_MIN_DAMAGE := 0.25
const ROLE_NAMES := ["Básico", "Habilidad", "Habilidad", "Definitiva"]

## PP como maná (pedido del usuario 2026-10-31: "los ataques tienen que costar por ejemplo 40 PP y mientras subís de
## nivel tenés más PP base", como Pokémon Reloaded; ajuste "pp_mode"): una barra por Pokémon que crece con el nivel;
## cada ataque gasta según su potencia y el básico (Clic izq.) es gratis y devuelve PP al pegar. Con PP las recargas
## quedan cortas (`PP_COOLDOWN`): lo que limita es la barra.
const PP_BASE := 100.0
const PP_PER_LEVEL := 4.0
## Costo según la potencia, medido en Pokemon Arena 2D (2026-11-01, cuadro por cuadro en un video: potencia 65 = 20 %
## de la barra, 85 = 43 %; los fuertes son una decisión, no algo que se tira seguido): [potencia, fracción de la barra
## de referencia], interpolado. La barra de referencia es la de Nv. 30 (220 PP): el costo en PP es fijo, así que a más
## nivel (barra más grande) rinde más.
const PP_COST_CURVE := [[20.0, 0.08], [65.0, 0.20], [85.0, 0.40], [120.0, 0.60], [150.0, 0.70]]
const PP_REFERENCE := 220.0
## Nerf del 2026-11-03 (pedido del usuario: "consumen muy poco y podés spamear mucho"): todo cuesta ×1,5 (la recarga no
## se tocó). Colmillo Ígneo 44 → 66, Lanzallamas 94 → 141, Hiperrayo 154 → 231; los de estado 33 → 50.
const PP_COST_MULT := 1.5
const PP_STATUS_COST := 50.0
## Curas (Descanso, Recuperación, Síntesis...): gastan una parte de la barra según cuánto curan (por su estado propio;
## crece con el nivel sola) y solo se usan con un rival cerca (`Creature.foe_near`): fuera de pelea no.
const HEAL_PP := {"descansando": 0.6, "recuperando": 0.4, "sintesis": 0.35, "arraigado": 0.25}
const HEAL_PP_DEFAULT := 0.3
## Canalizados (Lanzallamas...): pagan esto al empezar y el resto mientras sale el chorro; sin PP se cortan.
const PP_CHANNEL_UPFRONT := 0.3
## Recarga sola por segundo (fracción de la barra): en pelea y fuera de pelea. En pelea, de vacía a llena en ~7,5 s
## (en Pokemon Arena 2D, ~7 s; antes era 0,06: ~17 s).
const PP_REGEN_FIGHT := 0.16  # 2026-11-03: 0,13 → 0,16 (pedido del usuario: "un poco más rápida"; llena en ~6,3 s)
const PP_REGEN_CALM := 0.3
## Recarga de los ataques con PP: la de siempre × esto, entre estos valores.
const PP_COOLDOWN := 0.3
const PP_COOLDOWN_MIN := 0.35
const PP_COOLDOWN_MAX := 2.0

## Ataque de cada tecla (Clic izq., Clic der., Q, R); puede haber huecos (null).
var slots: Array[MoveData] = []
var cooldowns: Array[float] = []
## Duración completa de la recarga en curso de cada ranura (para la interfaz).
var cooldown_total: Array[float] = []
var dodge_cooldown := 0.0
## Pausa entre un ataque y el siguiente, sea cual sea la tecla (ajuste "attack_gap": que no se encadenen los 4 de golpe).
var gap_left := 0.0

var _combo_step: Array[int] = []
var _combo_timer: Array[float] = []


## Las ranuras salen de los movimientos equipados de la criatura (CreatureInstance.equipped_moves).
func setup(instance: CreatureInstance) -> void:
	if instance.equipped_moves.is_empty():
		instance.equipped_moves = instance.default_equipment()
	var source: Array[MoveData] = instance.equipped_moves
	if instance.boss and instance.species.boss_kit != null:
		source = instance.species.boss_kit.moves  # el jefe pelea con su kit
	if roles_on() and not _player_owned():
		source = by_role(source)  # rivales y salvajes: el más flojo de básico, el más fuerte de definitiva
	slots.clear()
	for i in SLOT_COUNT:
		slots.append(source[i] if i < source.size() else null)
	cooldowns.resize(SLOT_COUNT)
	cooldowns.fill(0.0)
	cooldown_total.resize(SLOT_COUNT)
	cooldown_total.fill(1.0)
	_combo_step.resize(SLOT_COUNT)
	_combo_step.fill(0)
	_combo_timer.resize(SLOT_COUNT)
	_combo_timer.fill(0.0)


## Cambió el equipamiento en plena pelea (subió de nivel y aprendió algo, o lo equipaste desde la ficha del menú de
## combate): actualiza solo las ranuras que cambiaron. El ataque nuevo arranca con su recarga completa (así reequipar
## no sirve para saltear recargas); las demás conservan la suya.
func refresh(instance: CreatureInstance) -> void:
	var source: Array[MoveData] = instance.equipped_moves
	for i in SLOT_COUNT:
		var m: MoveData = source[i] if i < source.size() else null
		if i < slots.size() and slots[i] != m:
			slots[i] = m
			cooldowns[i] = slot_cooldown(i, m.cooldown) if m != null else 0.0
			cooldown_total[i] = maxf(0.01, cooldowns[i])
			_combo_step[i] = 0
			_combo_timer[i] = 0.0


static func roles_on() -> bool:
	return bool(GameState.setting("slot_roles"))


## Tu Pokémon (los ordenás vos desde la ficha): los demás se ordenan por rol.
## Los tuyos y los que maneja una persona (los de la pelea online, de los dos lados): sus teclas, como los ordenó.
func _player_owned() -> bool:
	var c := get_parent()
	return c != null and (c.get("team") == 0 or c.get("player_controlled") == true)


## Ordena ataques para las teclas por rol: el de menos potencia primero (básico), los de estado en el medio y el
## más fuerte al final (definitiva).
static func by_role(source: Array[MoveData]) -> Array[MoveData]:
	var hitting: Array[MoveData] = []
	var other: Array[MoveData] = []
	for m in source:
		if m == null:
			continue
		if m.power > 0.0 and m.category != MoveData.Category.STATUS:
			hitting.append(m)
		else:
			other.append(m)
	hitting.sort_custom(func(a: MoveData, b: MoveData): return a.power * a.power_mult < b.power * b.power_mult)
	var out: Array[MoveData] = []
	if not hitting.is_empty():
		out.append(hitting.pop_front())
	out.append_array(other)
	out.append_array(hitting)
	return out


## Cada cuánto sale el ataque básico: más rápido cuanto más Velocidad (0,9 s a 0,45 s).
func basic_interval() -> float:
	var c := get_parent()
	var spe := 50.0
	if c != null and c.get("instance") != null:
		spe = c.instance.stat("speed")
	return clampf(1.0 - spe / 250.0, 0.45, 0.9)


## Multiplicador de daño por el rol de la tecla donde está el ataque.
func role_damage(m: MoveData) -> float:
	if m == null or not roles_on():
		return 1.0
	var slot := slots.find(m)
	if slot == BASIC_SLOT:
		return clampf(basic_interval() / maxf(m.cooldown, 0.01), BASIC_MIN_DAMAGE, 1.0)
	if slot == ULT_SLOT:
		return ULT_DAMAGE
	return 1.0


## Recarga completa del ataque de una ranura, con su rol y el ajuste de ritmo (para la interfaz y la IA).
func slot_cooldown(slot: int, base: float) -> float:
	if roles_on() and slot == BASIC_SLOT:
		base = minf(base, basic_interval())
	elif pp_on():
		base = clampf(base * PP_COOLDOWN, PP_COOLDOWN_MIN, PP_COOLDOWN_MAX)  # con PP limita la barra, no el reloj
	elif roles_on() and slot == ULT_SLOT:
		base = maxf(base * ULT_COOLDOWN, ULT_MIN_COOLDOWN)
	return base * float(GameState.setting("cooldown_mult"))


## Ataques no vacíos (para la IA y el autotest).
var moves: Array[MoveData]:
	get:
		var out: Array[MoveData] = []
		for s in slots:
			if s != null:
				out.append(s)
		return out


func _physics_process(delta: float) -> void:
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
	gap_left = maxf(0.0, gap_left - delta)
	if pp_on() and pp() < max_pp():
		var c := get_parent()
		var fighting: bool = c != null and c.has_method("engaged") and c.engaged()
		set_pp(pp() + max_pp() * (PP_REGEN_FIGHT if fighting else PP_REGEN_CALM) * delta * float(GameState.setting("pp_regen")))
	for i in cooldowns.size():
		cooldowns[i] = maxf(0.0, cooldowns[i] - delta)
		if _combo_timer[i] > 0.0:
			_combo_timer[i] -= delta
			if _combo_timer[i] <= 0.0 and _combo_step[i] > 0:
				_combo_step[i] = 0
				_start_cooldown(i, slots[i].cooldown)


func slot_of(m: MoveData) -> int:
	return slots.find(m)


func can_use(slot: int) -> bool:
	return slot >= 0 and slot < slots.size() and slots[slot] != null and cooldowns[slot] <= 0.0 and gap_left <= 0.0 \
		and has_pp(slot) and not heal_blocked(slot)


## ¿Es una cura? (un ataque propio cuyo estado cura vida: Descanso, Recuperación, Síntesis, Arraigo...)
static func is_heal(m: MoveData) -> bool:
	return m != null and m.self_status != null and m.self_status.heal_per_second > 0.0


## Una cura sin rival cerca no sale (que no se cure gratis paseando o con la F sin nadie).
func heal_blocked(slot: int) -> bool:
	var c := get_parent()
	return is_heal(slots[slot]) and c != null and c.has_method("foe_near") and not c.foe_near()


static func pp_on() -> bool:
	return bool(GameState.setting("pp_mode"))


func _instance() -> CreatureInstance:
	var c := get_parent()
	return c.instance if c != null and c.get("instance") != null else null


## PP máximos: crecen con el nivel (Nv. 5 = 120, Nv. 50 = 300).
func max_pp() -> float:
	var inst := _instance()
	return PP_BASE + PP_PER_LEVEL * (inst.level if inst != null else 5)


func pp() -> float:
	var inst := _instance()
	if inst == null or inst.pp < 0.0:
		return max_pp()
	return minf(inst.pp, max_pp())


func set_pp(value: float) -> void:
	var inst := _instance()
	if inst != null:
		inst.pp = clampf(value, 0.0, max_pp())


## Lo que gasta un ataque, según su potencia (`PP_COST_CURVE` × `PP_COST_MULT`: Placaje 40 ~44, Colmillo Ígneo 65 ~66,
## Pulso Dragón 85 ~132, Lanzallamas 90 ~141, Hiperrayo 150 ~231; los de estado 50). Las curas: `pp_cost`.
static func pp_cost_of(m: MoveData) -> float:
	if m == null:
		return 0.0
	if m.power <= 0.0 or m.category == MoveData.Category.STATUS:
		return PP_STATUS_COST
	return roundf(cost_fraction(m.power) * PP_REFERENCE * PP_COST_MULT)


static func cost_fraction(power: float) -> float:
	var c: Array = PP_COST_CURVE
	if power <= c[0][0]:
		return c[0][1]
	for i in range(1, c.size()):
		if power <= c[i][0]:
			return lerpf(c[i - 1][1], c[i][1], (power - c[i - 1][0]) / (c[i][0] - c[i - 1][0]))
	return c[c.size() - 1][1]


## Lo que gasta la ranura. El básico paga como los demás, en proporción a lo que pega (pedido del usuario 2026-11-03:
## antes era gratis y devolvía PP al pegar, y el combate se sentía muy rápido).
func pp_cost(slot: int) -> float:
	if not pp_on() or slot < 0 or slot >= slots.size() or slots[slot] == null:
		return 0.0
	var m := slots[slot]
	if roles_on() and slot == BASIC_SLOT:
		return roundf(pp_cost_of(m) * role_damage(m))
	if is_heal(m):
		return roundf(max_pp() * HEAL_PP.get(m.self_status.id, HEAL_PP_DEFAULT))
	return pp_cost_of(m)


func has_pp(slot: int) -> bool:
	return pp() >= pp_cost(slot)


## Lo que gasta por segundo un canalizado mientras sale (0 si es gratis o no hay PP).
func channel_drain(m: MoveData) -> float:
	if not pp_on() or m == null or m.kind != MoveData.Kind.CHANNEL or m.channel_time <= 0.0:
		return 0.0
	return pp_cost(slots.find(m)) * (1.0 - PP_CHANNEL_UPFRONT) / m.channel_time



## Arranca la recarga (o avanza el combo). Devuelve [ataque, paso del combo] o [] si no se puede.
func consume(slot: int) -> Array:
	if not can_use(slot):
		return []
	var m := slots[slot]
	var step := 0
	gap_left = float(GameState.setting("attack_gap"))
	if m.combo_steps <= 1 or _combo_step[slot] == 0:
		# (un combo gasta una vez, al empezar; un canalizado, una parte: el resto mientras dura, `channel_drain`)
		set_pp(pp() - pp_cost(slot) * (PP_CHANNEL_UPFRONT if m.kind == MoveData.Kind.CHANNEL else 1.0))
	if m.combo_steps > 1:
		step = _combo_step[slot]
		_combo_step[slot] = (step + 1) % m.combo_steps
		if _combo_step[slot] == 0:
			_combo_timer[slot] = 0.0
			_start_cooldown(slot, m.cooldown)
		else:
			_combo_timer[slot] = m.combo_window
			_start_cooldown(slot, m.combo_step_cooldown)
	else:
		_start_cooldown(slot, m.cooldown)
	return [m, step]


## Reduce la recarga de una ranura (para mecánicas futuras, ej. el Ritmo de Bellsprout).
func reduce_cooldown(slot: int, seconds: float) -> void:
	cooldowns[slot] = maxf(0.0, cooldowns[slot] - seconds)


func reset_cooldown(slot: int) -> void:
	cooldowns[slot] = 0.0
	gap_left = 0.0


## Las recargas se estiran con el ajuste "cooldown_mult" (ritmo del combate, pedido del usuario 2026-10-31).
func _start_cooldown(slot: int, t: float) -> void:
	t = slot_cooldown(slot, t)
	cooldowns[slot] = t
	cooldown_total[slot] = maxf(t, 0.01)


func can_dodge() -> bool:
	return dodge_cooldown <= 0.0


func consume_dodge() -> bool:
	if dodge_cooldown > 0.0:
		return false
	dodge_cooldown = DODGE_COOLDOWN * float(GameState.setting("cooldown_mult"))
	return true


func cooldown_ratio(slot: int) -> float:
	return cooldowns[slot] / cooldown_total[slot]


## Lo que falta para poder usar la ranura (su recarga o la pausa entre ataques, lo que sea más largo).
func wait_left(slot: int) -> float:
	return maxf(cooldowns[slot], gap_left)


func combo_step(slot: int) -> int:
	return _combo_step[slot]
