class_name WildSociety
extends RefCounted
## Salvajes vivos (docs/PLAN_IA.md, IA-5): rutinas de día y noche (duermen en su hora; si los despertás, salen furiosos o
## huyen), respeto (no atacan a un Pokémon mucho más fuerte), manadas (los de la misma familia se suman a la pelea; si
## atacás a una cría, el grande viene enfurecido) y presas y depredadores (el cazador persigue, la presa huye; no se
## pegan). Reglas en datos: WildLife (data/ai/wild_life.tres). Lo usan WildSpawner y los estados de los salvajes.

const DAY_START := 6.0
const NIGHT_START := 19.5


static func rules() -> WildLife:
	return DB.wild_life if DB.wild_life != null else WildLife.new()


static func is_night(hour: float, cave: bool) -> bool:
	return cave or hour < DAY_START or hour >= NIGHT_START


## "noche" (nocturno), "dia" (diurno) o "" (le da igual).
static func activity(sp: SpeciesData) -> String:
	var w := rules()
	if sp.id in w.nocturnal_species:
		return "noche"
	if sp.id in w.diurnal_species:
		return "dia"
	for t in sp.types:
		if t.id in w.nocturnal_types:
			return "noche"
	return ""


## Es su hora de dormir.
static func sleepy(sp: SpeciesData, hour: float, cave: bool) -> bool:
	match activity(sp):
		"noche":
			return not is_night(hour, cave)
		"dia":
			return is_night(hour, cave)
	return false


## Se echa a dormir (estado Dormido muy largo; lo despierta un golpe, que pases al lado o que llegue su hora).
static func nap(c: Creature) -> void:
	var st: StatusEffect = DB.statuses.get("dormido")
	if st == null or c.napping:
		return
	c.napping = true
	c.statuses.apply(st, 1000.0)


## Durmiendo en su hora: si vos o tu Pokémon pasan muy cerca, puede despertarse (con mal humor).
static func sleep_tick(c: Creature, delta: float) -> void:
	var w := rules()
	var wander = c.machine.get_node_or_null("Wander")
	if wander != null and wander.aggro_radius == 0.0:
		return  # (muñecos de los autotests)
	var near := CreatureWander.spot_target(c, w.wake_radius)
	if near != null and randf() < w.wake_chance * delta:
		wake(c, near)


## Se despierta. `rude` = lo despertaste vos: los tímidos y curiosos huyen; los demás te atacan enfurecidos.
static func wake(c: Creature, by: Creature = null) -> void:
	if not c.napping:
		return
	c.napping = false
	var st: StatusEffect = DB.statuses.get("dormido")
	if st != null:
		c.statuses.cure(st)
	if by == null:
		return
	var temp: Temperament = c.temperament
	if temp != null and temp.on_notice in [Temperament.OnNotice.FLEE, Temperament.OnNotice.APPROACH]:
		c.emote("gota", 1.0)
		c.machine.transition_to("flee", {"from": by, "calm": true})
		return
	var angry: StatusEffect = DB.statuses.get("enfurecido")
	if angry != null:
		c.statuses.apply(angry, 2.0)
	c.emote("!", 1.2)
	Events.signature_triggered.emit(c, "¡Lo despertaste!", Color(1.0, 0.45, 0.35))
	if not is_instance_valid(c.target):
		c.target = by
		Events.wild_aggro.emit(c, by)
		c.machine.transition_to("chase")


## Tu Pokémon le lleva tantos niveles que no se le anima (salvo que le pegues).
static func outclassed(c: Creature, seen: Creature) -> bool:
	return is_instance_valid(seen) and seen.instance != null and not c.instance.boss and c.owner_name == "" \
		and seen.instance.level >= c.instance.level + rules().outclass_gap


## Primera especie de su línea evolutiva (para reconocer a los de su familia).
static func family(sp: SpeciesData) -> SpeciesData:
	var s := sp
	for i in 4:
		if s.evolves_from == "" or not DB.species.has(s.evolves_from):
			break
		s = DB.species[s.evolves_from]
	return s


## Los de la misma familia cerca se suman a la pelea contra `target`. El que le lleva varios niveles al atacado (su
## cría) viene enfurecido.
static func call_pack(c: Creature, target: Creature) -> void:
	var w := rules()
	if c.temperament == null or not c.temperament.calls_group or not is_instance_valid(target):
		return
	var fam := family(c.instance.species)
	for o in c.get_tree().get_nodes_in_group("creatures"):
		if o == c or not o is Creature or o.team != c.team or o.is_down() or o.owner_name != "" \
				or o.global_position.distance_to(c.global_position) > w.pack_radius \
				or family(o.instance.species) != fam or is_instance_valid(o.target):
			continue
		if o.napping:
			o.napping = false
			o.statuses.cure(DB.statuses.get("dormido"))
		if o.machine.current_name() not in ["wander", "watch", "idle"]:
			continue
		o.target = target
		o.emote("!", 1.0)
		if o.instance.level >= c.instance.level + w.young_gap:
			var angry: StatusEffect = DB.statuses.get("enfurecido")
			if angry != null:
				o.statuses.apply(angry, 2.0)
			Events.signature_triggered.emit(o, "¡Defiende a su cría!", Color(1.0, 0.45, 0.35))
		Events.wild_aggro.emit(o, target)
		o.machine.transition_to("chase")


## `a` caza a `b` (por especie o por tipo, según WildLife.predators) y no es mucho más chico.
static func preys_on(a: Creature, b: Creature) -> bool:
	if a == b or a.instance == null or b.instance == null or b.instance.level > a.instance.level + 3:
		return false
	var w := rules()
	var keys := [a.instance.species.id]
	for t in a.instance.species.types:
		keys.append(t.id)
	var prey := [b.instance.species.id]
	for t in b.instance.species.types:
		prey.append(t.id)
	if family(a.instance.species) == family(b.instance.species):
		return false
	for k in keys:
		var list = w.predators.get(k)
		if list == null:
			continue
		for p in list:
			if p in prey:
				return true
	return false


## Cazador cerca (para la presa) o presa cerca (para el cazador), entre los salvajes tranquilos.
static func nearby(c: Creature, radius: float, want_predator: bool) -> Creature:
	for o in c.get_tree().get_nodes_in_group("creatures"):
		if o == c or not o is Creature or o.team != c.team or o.is_down() or o.napping or o.owner_name != "" \
				or o.global_position.distance_to(c.global_position) > radius:
			continue
		if (want_predator and preys_on(o, c)) or (not want_predator and preys_on(c, o)):
			return o
	return null


## Algo para mirar (los curiosos): una Pokébola tirada o un objeto del piso cerca.
static func curiosity(c: Creature) -> Node2D:
	var r := rules().curious_radius
	for n in c.get_tree().get_nodes_in_group("field_items"):
		if n is Node2D and n.global_position.distance_to(c.global_position) < r:
			return n
	return null
