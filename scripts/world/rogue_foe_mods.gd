class_name RogueFoeMods
extends Node
## Mejoras de los enemigos del Modo Desafío (paso O-d de docs/PROPUESTA_ROGUELIKE.md, sección 11; pedido del usuario
## 2026-11-11: "se siente relativamente fácil"). Hijo de RogueRun (`world.rogue.foe_mods`). Los élite de la oleada
## fuerte, algún esbirro "campeón" por oleada y los Pokémon del jefe llevan **modificadores visibles** (ícono sobre la
## cabeza, `RogueFoeBadge`, y el nombre en el cartel del rival), que crecen con las salas:
##  · furioso: pega más fuerte.            · blindado: más vida.
##  · ardiente / electrico: al golpear puede quemar / paralizar.   · regenerador: se cura solo.
## Datos en data/rogue/desafio.json → `foe_mods` (lista con peso y números, `level_step`) y, por sala (`slots`):
## `champions` = cuántos esbirros de cada oleada común llevan uno, `mods` = cuántos lleva cada élite, `mod_level` = su
## nivel (valor × (1 + level_step × (nivel − 1))). El jefe: `boss.mods` (uno por Pokémon de su equipo) y `boss.mod_level`.
## Lo que lleva cada uno va en su CreatureInstance (meta "rogue_mods" = [{id, level}]); los efectos se enganchan a las
## señales de la criatura (`hit_dealt`) sin tocar el combate central. Para sumar uno: una fila en el JSON, su rama acá y
## su ícono en sprites/ui/mejoras_enemigas/ (tools/make_foe_mod_icons.py).

const ICONS := "res://sprites/ui/mejoras_enemigas/%s.png"
const META := "rogue_mods"
## Cada cuánto cura el regenerador (s).
const REGEN_TICK := 1.0

var run: Node
var world: Node
var _rng := RandomNumberGenerator.new()
var _hooked: Dictionary = {}  # criatura -> true
var _tick := 0.0
## Cuántas veces se disparó cada uno (tests).
var triggers: Dictionary = {}


func _ready() -> void:
	run = get_parent()
	world = run.get_parent()
	_rng.randomize()


func cfg() -> Dictionary:
	return run.floor_data.get("foe_mods", {})


func list() -> Dictionary:
	return cfg().get("list", {})


## Lo que lleva esa criatura (o ese CreatureInstance): [{id, level}].
static func of(who) -> Array:
	var inst: CreatureInstance = who.instance if who is Creature else who
	return inst.get_meta(META, []) if inst != null else []


static func icon_of(id: String) -> String:
	return ICONS % id


func mod_name(id: String) -> String:
	return str(list().get(id, {}).get("name", id))


func color_of(id: String) -> Color:
	var c: Array = list().get(id, {}).get("color", [1, 1, 1])
	return Color(c[0], c[1], c[2])


## El número de un modificador a ese nivel.
func value(id: String, level: int, key: String = "value") -> float:
	return float(list().get(id, {}).get(key, 0.0)) * (1.0 + float(cfg().get("level_step", 0.5)) * float(level - 1))


## Qué hace, en palabras (cartel del rival y tests).
func describe(id: String, level: int) -> String:
	var v := value(id, level)
	return str(list().get(id, {}).get("text", "")).replace("{v%}", "%d %%" % roundi(v * 100.0)).replace("{v}", str(snappedf(v * 100.0, 0.1)))


## Sortea `count` modificadores distintos, por peso.
func roll(count: int, level: int, rng: RandomNumberGenerator = null) -> Array:
	if rng == null:
		rng = _rng
	if count > 0 and GameState.rogue.has("force_mods"):  # (tests: estos, tal cual)
		return GameState.rogue["force_mods"].duplicate(true)
	var pool: Array = list().keys()
	var out: Array = []
	while out.size() < count and not pool.is_empty():
		var total := 0.0
		for id in pool:
			total += float(list()[id].get("weight", 1.0))
		var pick := rng.randf() * total
		for id: String in pool:
			pick -= float(list()[id].get("weight", 1.0))
			if pick <= 0.0:
				out.append({"id": id, "level": level})
				pool.erase(id)
				break
	return out


## Cuántos modificadores le tocan a un enemigo de esa sala: los élite, `mods`; de los esbirros, los primeros
## `champions` de cada oleada, uno.
func count_for(room_index: int, elite: bool, order: int) -> int:
	var slots: Array = run.floor_data.get("slots", [])
	if room_index < 0 or room_index >= slots.size():
		return 0
	var slot: Dictionary = slots[room_index]
	if elite:
		return int(slot.get("mods", 0))
	return 1 if order < int(slot.get("champions", 0)) else 0


func level_for(room_index: int) -> int:
	var slots: Array = run.floor_data.get("slots", [])
	return int(slots[room_index].get("mod_level", 1)) if room_index >= 0 and room_index < slots.size() else 1


## Le pone esos modificadores a un Pokémon (antes de que salga). Blindado se aplica acá: más vida propia.
func assign(inst: CreatureInstance, mods: Array) -> void:
	if mods.is_empty():
		return
	inst.set_meta(META, mods)
	for m: Dictionary in mods:
		if m["id"] == "blindado":
			inst.hp_mult *= 1.0 + value("blindado", int(m["level"]))
			inst.hp = inst.max_hp()


## Los del jefe: `boss.mods` = cuántos lleva cada Pokémon de su equipo, en orden.
func assign_boss(team: Array) -> void:
	var boss: Dictionary = run.floor_data.get("boss", {})
	var counts: Array = boss.get("mods", [])
	for i in mini(team.size(), counts.size()):
		assign(team[i], roll(int(counts[i]), int(boss.get("mod_level", 1))))


func _physics_process(delta: float) -> void:
	if not run.active:
		return
	_tick += delta
	var heal := _tick >= REGEN_TICK
	if heal:
		_tick = 0.0
	for c in get_tree().get_nodes_in_group("creatures"):
		if not (c is Creature) or c.team == Creature.Team.ALLY or c.instance == null or not c.instance.has_meta(META):
			continue
		if not _hooked.has(c):
			_hook(c)
		if heal and not c.is_down() and c.visible:
			for m: Dictionary in of(c):
				if m["id"] == "regenerador" and c.health.ratio() < 1.0:
					c.health.heal(c.instance.max_hp() * value("regenerador", int(m["level"])) * REGEN_TICK)
					_note("regenerador")
	for k in _hooked.keys():
		if not is_instance_valid(k):
			_hooked.erase(k)


func _hook(c: Creature) -> void:
	_hooked[c] = true
	c.hit_dealt.connect(_on_hit.bind(c))
	var badge := RogueFoeBadge.new()
	badge.setup(self, c)
	c.add_child(badge)


func _on_hit(target: Creature, hit: HitInfo, damage: float, c: Creature) -> void:
	if not is_instance_valid(target) or target.is_down() or hit == null or damage <= 0.0:
		return
	for m: Dictionary in of(c):
		var level := int(m["level"])
		match str(m["id"]):
			"furioso":
				target.health.apply_damage(damage * value("furioso", level))
				_note("furioso")
			"ardiente", "electrico":
				var status := str(list()[m["id"]].get("status", ""))
				if DB.statuses.has(status) and _rng.randf() <= value(m["id"], level):
					target.statuses.apply(DB.statuses[status], 1.0, c)
					_note(m["id"])


func _note(id: String) -> void:
	triggers[id] = int(triggers.get(id, 0)) + 1
