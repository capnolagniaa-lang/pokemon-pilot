class_name RogueBoons
extends Node
## Las bendiciones de una partida del Modo Desafío (R-2 de docs/PROPUESTA_ROGUELIKE.md; hijo de RogueRun,
## `world.rogue.boons`). Los legendarios (Zapdos, Articuno, Moltres) te ofrecen 3 al limpiar una sala; la que elegís
## queda hasta el final de la partida. Datos: `BoonData` en data/boons (DB.boons) y data/rogue/bendiciones.json (dadores
## y rarezas), los dos de tools/build_boons.py.
##  · Lo que tenés vive en `GameState.rogue["boons"]` = [{id, rarity, level}] (se pierde con la partida).
##  · Los efectos se enganchan a las señales de tu Pokémon (`hit_dealt`, `dodged`, `damage_received`) y a
##    `Events.creature_fainted`: no tocan el combate central. El daño de más va aparte (`Health.apply_damage`), así una
##    bendición nunca dispara a otra en cadena.
##  · Valor de un número `scaled` = base × rareza × (1 + level_step × (nivel − 1)).
## Para sumar una bendición: una fila en tools/build_boons.py. Para un efecto nuevo: una función `_fx_<effect>` acá.

const CONFIG_PATH := "res://data/rogue/bendiciones.json"
## **Objetos equipables** (paso O-b de la sección 11 de la propuesta; decisiones del usuario 2026-11-11): son `BoonData`
## con `giver` = "objeto" (data/rogue_items, de tools/build_rogue_items.py) y usan este mismo motor. Hasta `ITEM_SLOTS`
## equipados en `GameState.rogue["items"]` (los que hacen efecto) y los demás guardados en `GameState.rogue["stash"]`
## (la Mochila de la partida: se equipan, desequipan, cambian de ranura o se venden desde el menú de pausa). Un
## repetido sube de nivel el que ya tenés, hasta `MAX_LEVEL` (también las bendiciones).
const ITEM_SLOTS := 3
const MAX_LEVEL := 3
const ITEM_COLOR := Color(1.0, 0.82, 0.3)
## Cada cuánto curan los de regeneración (Restos).
const REGEN_TICK := 1.0

var run: Node
var world: Node
var config: Dictionary = {}
var _creature: Creature
var _used: Dictionary = {}  # id -> ya se usó en esta sala (los de "una vez por sala")
var _thorns: Dictionary = {}  # id -> cuándo vuelve a estar
var _regen := 0.0
## Bendición de esquive -> cuándo vuelve a estar (las de `cooldown`: si no, esquivar seguido limpiaba la sala).
var _dodge_ready: Dictionary = {}
var _clock := 0.0
var _rng := RandomNumberGenerator.new()
## Cuántas veces se disparó cada bendición en esta partida (tests y, más adelante, el resumen del final).
var triggers: Dictionary = {}

## Cambió lo que tenés (una bendición nueva o un nivel más).
signal changed


static func load_config() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))


func _ready() -> void:
	run = get_parent()
	world = run.get_parent()
	config = load_config()
	_rng.randomize()
	Events.creature_fainted.connect(_on_fainted)


# --- Lo que tenés ---------------------------------------------------------------------------------------------------

func owned() -> Array:
	if not GameState.rogue.has("boons"):
		GameState.rogue["boons"] = []
	return GameState.rogue["boons"]


func has(id: String) -> bool:
	return not entry(id).is_empty()


## La entrada {id, rarity, level} de una bendición o de un objeto (equipado o guardado) que tenés.
func entry(id: String) -> Dictionary:
	for e: Dictionary in owned() + items() + stash():
		if e["id"] == id:
			return e
	return {}


## Los datos de una bendición o de un objeto.
static func data_of(id: String) -> BoonData:
	return DB.boons.get(id, DB.rogue_items.get(id))


static func icon_of(id: String) -> String:
	var d := data_of(id)
	return d.icon_path if d != null and d.icon_path != "" else "res://sprites/ui/bendiciones/iconos/%s.png" % id


# --- Objetos equipables ---------------------------------------------------------------------------------------------

## Los equipados (hacen efecto), en orden de ranura.
func items() -> Array:
	if not GameState.rogue.has("items"):
		GameState.rogue["items"] = []
	return GameState.rogue["items"]


## Los guardados en la Mochila de la partida (no hacen efecto hasta equiparlos).
func stash() -> Array:
	if not GameState.rogue.has("stash"):
		GameState.rogue["stash"] = []
	return GameState.rogue["stash"]


func slots_full() -> bool:
	return items().size() >= ITEM_SLOTS


## Te quedás con un objeto. Devuelve qué pasó: "nivel" (ya lo tenías: sube uno), "equipado" (fue a una ranura libre) o
## "guardado" (las 3 llenas: quedó en la Mochila; RogueRewards pregunta antes si querés reemplazar uno).
func take_item(id: String, rarity: String = "comun", to_stash := false) -> String:
	if not DB.rogue_items.has(id):
		return ""
	var e := entry(id)
	var what := "nivel"
	if not e.is_empty():
		e["level"] = mini(MAX_LEVEL, int(e["level"]) + 1)
		if rarity_index(rarity) > rarity_index(e["rarity"]):
			e["rarity"] = rarity
	elif slots_full() or to_stash:
		stash().append({"id": id, "rarity": rarity, "level": 1})
		what = "guardado"
	else:
		items().append({"id": id, "rarity": rarity, "level": 1})
		what = "equipado"
	Events.message_requested.emit("Objeto: %s%s" % [DB.rogue_items[id].display_name, " (subió de nivel)" if what == "nivel" else (
		" (en la Mochila)" if what == "guardado" else "")])
	_items_changed()
	return what


## Pasa un objeto guardado a una ranura libre.
func equip_item(stash_index: int) -> bool:
	if stash_index < 0 or stash_index >= stash().size() or slots_full():
		return false
	items().append(stash().pop_at(stash_index))
	_items_changed()
	return true


## Saca un objeto equipado y lo guarda en la Mochila.
func unequip_item(slot: int) -> bool:
	if slot < 0 or slot >= items().size():
		return false
	stash().append(items().pop_at(slot))
	_items_changed()
	return true


## Cambia un objeto equipado de ranura (dir = -1 o +1).
func move_item(slot: int, dir: int) -> bool:
	var to := slot + dir
	if slot < 0 or slot >= items().size() or to < 0 or to >= items().size():
		return false
	var e = items()[slot]
	items()[slot] = items()[to]
	items()[to] = e
	_items_changed()
	return true


## Cambia un objeto equipado por uno guardado.
func swap_item(slot: int, stash_index: int) -> bool:
	if slot < 0 or slot >= items().size() or stash_index < 0 or stash_index >= stash().size():
		return false
	var e = items()[slot]
	items()[slot] = stash()[stash_index]
	stash()[stash_index] = e
	_items_changed()
	return true


## Lo que te dan por un objeto al venderlo o reemplazarlo (crece con la rareza y el nivel).
func sell_value(e: Dictionary) -> int:
	return int(run.floor_data.get("rewards", {}).get("item_sell", 20)) * (1 + rarity_index(e["rarity"])) * int(e["level"])


## Vende un objeto (equipado o guardado): se va y te da plata.
func sell_item(e: Dictionary) -> int:
	var value := sell_value(e)
	items().erase(e)
	stash().erase(e)
	GameState.money += value
	_items_changed()
	return value


func _items_changed() -> void:
	_apply_stats()
	changed.emit()


## Lo que suman tus objetos y bendiciones de ese efecto de "número" (speed, exp, money, dodge_cd): la suma de sus `pct`.
func stat(effect: String) -> float:
	var total := 0.0
	for b: BoonData in _mine(effect):
		total += value(b, "pct")
	return total


## Los que cambian un número del juego (velocidad de tu Pokémon, EXP de la partida) se aplican al cambiar lo que llevás.
func _apply_stats() -> void:
	if is_instance_valid(_creature):
		_creature.speed_bonus = 1.0 + stat("speed")
	if run != null and not run.floor_data.is_empty():
		GameState.set_setting("exp_mult", float(DB.config.exp_multiplier) * float(run.floor_data.get("exp_mult", 1.0)) * (1.0 + stat("exp")))


## Los objetos que te pueden ofrecer: los que no tenés al máximo; de los potenciadores de tipo, solo los del tipo de
## alguno de tus ataques de daño.
func item_pool() -> Array:
	var types := {}
	var inst := GameState.active()
	if inst != null:
		for m in inst.equipped_moves:
			if m != null and m.power > 0.0 and m.element != null:
				types[m.element.id] = true
	var out: Array = []
	for d: BoonData in DB.rogue_items.values():
		if int(entry(d.id).get("level", 0)) >= MAX_LEVEL:
			continue
		if d.effect == "bonus_type" and not types.has(str(d.params.get("type", ""))):
			continue
		out.append(d)
	out.sort_custom(func(a, b): return a.id < b.id)
	return out


## Una oferta de objetos: hasta `options`, distintos, cada uno con su rareza.
func offer_items(rng: RandomNumberGenerator = null) -> Array:
	if rng == null:
		rng = _rng
	var pool := item_pool()
	var out: Array = []
	for n in mini(int(config["options"]), pool.size()):
		var d: BoonData = pool.pop_at(rng.randi() % pool.size())
		out.append({"id": d.id, "rarity": roll_rarity(rng)})
	return out


## Te quedás con una bendición (o, si ya la tenías, sube un nivel y se queda con la mejor rareza).
func take(id: String, rarity: String = "comun") -> void:
	if not DB.boons.has(id):
		return
	var e := entry(id)
	if e.is_empty():
		owned().append({"id": id, "rarity": rarity, "level": 1})
	else:
		e["level"] = mini(MAX_LEVEL, int(e["level"]) + 1)
		if rarity_index(rarity) > rarity_index(e["rarity"]):
			e["rarity"] = rarity
	Events.message_requested.emit("Bendición: %s" % DB.boons[id].display_name)
	changed.emit()


func level_up(id: String) -> bool:
	var e := entry(id)
	if e.is_empty() or int(e["level"]) >= MAX_LEVEL:
		return false
	e["level"] = int(e["level"]) + 1
	changed.emit()
	return true


# --- Rarezas y números ----------------------------------------------------------------------------------------------

func rarity_index(id: String) -> int:
	for i in config["rarities"].size():
		if config["rarities"][i]["id"] == id:
			return i
	return 0


func rarity(id: String) -> Dictionary:
	return config["rarities"][rarity_index(id)]


## El valor de un parámetro de una bendición con esa rareza y nivel.
func value_of(boon: BoonData, key: String, rarity_id: String = "comun", level: int = 1) -> float:
	var raw = boon.params.get(key, 0.0)
	if not (raw is float or raw is int):
		return 0.0
	var v := float(raw)
	if key in boon.scaled:
		v *= float(rarity(rarity_id)["mult"]) * (1.0 + float(config["level_step"]) * float(level - 1))
	return v


## El valor que tiene ahora (con la rareza y el nivel de la que tenés).
func value(boon: BoonData, key: String) -> float:
	var e := entry(boon.id)
	return value_of(boon, key, str(e.get("rarity", "comun")), int(e.get("level", 1)))


## El texto de la tarjeta, con los números de esa rareza y nivel.
func describe(boon: BoonData, rarity_id: String = "comun", level: int = 1) -> String:
	var out := boon.text
	for key: String in boon.params:
		if not (boon.params[key] is float or boon.params[key] is int):
			continue
		var v := value_of(boon, key, rarity_id, level)
		out = out.replace("{%s%%1}" % key, ("%.1f %%" % (v * 100.0)).replace(".", ","))
		out = out.replace("{%s%%}" % key, "%d %%" % roundi(v * 100.0))
		out = out.replace("{%s}" % key, str(roundi(_power(v))) if key == "power" else str(snappedf(v, 0.1)))
	var action := ""
	if boon.slot == "esquive":
		action = "dodge"
	elif boon.slot_index() >= 0:
		action = str(Controls.SLOT_ACTIONS[boon.slot_index()])
	return out.replace("{tecla}", Controls.label(action) if action != "" else "")


# --- El sorteo ------------------------------------------------------------------------------------------------------

## Una oferta: un dador al azar (o `giver_id`) y hasta `options` de sus bendiciones, cada una con su rareza. Primero las
## que no tenés; si ya tenés todas las de ese dador, te ofrece subir de nivel las que tenés.
func offer(rng: RandomNumberGenerator = null, giver_id: String = "") -> Dictionary:
	if rng == null:
		rng = _rng
	var givers: Array = config["givers"].keys()
	if giver_id == "":
		# (un dador al que todavía le queda algo nuevo, si hay)
		var fresh: Array = givers.filter(func(g): return DB.boons.values().any(func(b): return b.giver == g and not has(b.id)))
		var from: Array = fresh if not fresh.is_empty() else givers
		giver_id = from[rng.randi() % from.size()]
	var mine: Array = DB.boons.values().filter(func(b): return b.giver == giver_id)
	mine.sort_custom(func(a, b): return a.id < b.id)
	var pool: Array = mine.filter(func(b): return not has(b.id))
	if pool.is_empty():
		pool = mine.filter(func(b): return int(entry(b.id).get("level", 0)) < MAX_LEVEL)
	var options: Array = []
	for n in mini(int(config["options"]), pool.size()):
		var b: BoonData = pool.pop_at(rng.randi() % pool.size())
		options.append({"id": b.id, "rarity": roll_rarity(rng)})
	var lines: Array = config["givers"][giver_id]["lines"]
	return {"giver": giver_id, "options": options, "line": lines[rng.randi() % lines.size()]}


## La suerte de esta partida (RogueProgress.luck: especies atrapadas + inicial shiny). `GameState.rogue["luck"]` la fija (tests).
func luck() -> int:
	if GameState.rogue.has("luck"):
		return int(GameState.rogue["luck"])
	var inst := GameState.active()
	return RogueProgress.luck(inst != null and inst.shiny)


## Sortea una rareza por peso; con suerte, cada punto da `LUCK_STEP` de subir un escalón (con 0 no cambia nada).
func roll_rarity(rng: RandomNumberGenerator = null, p_luck: int = -1) -> String:
	if rng == null:
		rng = _rng
	if p_luck < 0:
		p_luck = luck()
	var total := 0.0
	for r: Dictionary in config["rarities"]:
		total += float(r["weight"])
	var pick := rng.randf() * total
	var index := 0
	for i in config["rarities"].size():
		pick -= float(config["rarities"][i]["weight"])
		if pick <= 0.0:
			index = i
			break
	if p_luck > 0 and index < config["rarities"].size() - 1 and rng.randf() < float(p_luck) * RogueProgress.LUCK_STEP:
		index += 1
	return config["rarities"][index]["id"]


# --- Los efectos ----------------------------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_clock += delta
	var c: Creature = world.companion if world != null else null
	if c != _creature:
		_attach(c)
	_regen += delta
	if _regen >= REGEN_TICK:
		_regen = 0.0
		if is_instance_valid(_creature) and not _creature.is_down() and run.phase in ["oleada", "jefe"] and _creature.health.ratio() < 1.0:
			for b: BoonData in _mine("regen"):
				_note(b)
				_creature.health.heal(_creature.instance.max_hp() * value(b, "pct") * REGEN_TICK)


func _attach(c: Creature) -> void:
	if is_instance_valid(_creature):
		if _creature.hit_dealt.is_connected(_on_hit):
			_creature.hit_dealt.disconnect(_on_hit)
			_creature.dodged.disconnect(_on_dodged)
			_creature.damage_received.disconnect(_on_damaged)
	_creature = c
	if is_instance_valid(c):
		c.hit_dealt.connect(_on_hit)
		c.dodged.connect(_on_dodged)
		c.damage_received.connect(_on_damaged)
	_apply_stats()


## Empieza una sala: lo que es "una vez por sala" vuelve a estar.
func room_started() -> void:
	_used.clear()


## Lo que hace efecto ahora: tus bendiciones y tus objetos equipados (los guardados, no).
func active_entries() -> Array:
	return owned() + items()


func _mine(effect: String) -> Array:
	var out: Array = []
	for e: Dictionary in active_entries():
		var b: BoonData = data_of(e["id"])
		if b != null and b.effect == effect:
			out.append(b)
	return out


## Los enemigos en pie (los de la oleada o el Pokémon del jefe).
func enemies() -> Array[Creature]:
	var out: Array[Creature] = []
	for c in get_tree().get_nodes_in_group("creatures"):
		if c is Creature and c.team != Creature.Team.ALLY and not c.is_down() and c.visible and is_instance_valid(c.health):
			out.append(c)
	return out


## Daño de una bendición que no sale de un golpe: crece con el nivel de tu Pokémon.
func _power(k: float) -> float:
	var level: int = _creature.instance.level if is_instance_valid(_creature) else int(GameState.active().level if GameState.active() != null else 10)
	return k * (4.0 + float(level))


func _hurt(target: Creature, amount: float) -> void:
	if is_instance_valid(target) and not target.is_down() and amount > 0.0:
		target.health.apply_damage(amount)


func _status(target: Creature, id: String, chance: float = 1.0) -> void:
	if id == "" or not DB.statuses.has(id) or not is_instance_valid(target) or target.is_down():
		return
	if _rng.randf() <= chance:
		target.statuses.apply(DB.statuses[id], 1.0, _creature)


func _note(boon: BoonData) -> void:
	triggers[boon.id] = int(triggers.get(boon.id, 0)) + 1


func _color(boon: BoonData) -> Color:
	if not config["givers"].has(boon.giver):
		return ITEM_COLOR
	var c: Array = config["givers"][boon.giver]["color"]
	return Color(c[0], c[1], c[2])


## Un estallido en un punto: daño a los enemigos de ese radio (menos `skip`), con su estado, su cartel y el entorno.
func _blast(boon: BoonData, at: Vector2, amount: float, skip: Creature = null) -> int:
	var hit := 0
	var radius := float(boon.params.get("radius", 36.0))
	for e in enemies():
		if e != skip and e.global_position.distance_to(at) <= radius:
			_hurt(e, amount)
			_status(e, str(boon.params.get("status", "")), float(boon.params.get("status_chance", 1.0)))
			hit += 1
	var col := _color(boon)
	Fx.burst(world.entities, at + Vector2(0, -6), Color(col.r * 1.5, col.g * 1.5, col.b * 1.5), 18, radius * 1.6)
	var element := str(boon.params.get("element", ""))
	if DB.types.has(element):
		Events.element_impact.emit(DB.types[element], at, radius * 0.5)
	if boon.params.has("word") and is_instance_valid(_creature):
		Events.signature_triggered.emit(_creature, str(boon.params["word"]), col)
	return hit


func _on_hit(target: Creature, hit: HitInfo, damage: float) -> void:
	if not is_instance_valid(target) or hit == null or hit.move == null or damage <= 0.0 or active_entries().is_empty():
		return
	var slot: int = _creature.moves.slots.find(hit.move)
	var was_full: bool = target.instance.hp + damage >= target.instance.max_hp() - 0.5
	for b: BoonData in _mine("hit_status"):
		if int(b.params["slot"]) in [-1, slot]:
			_note(b)
			_status(target, b.params["status"], value(b, "chance"))
	var bonus := 0.0
	for b: BoonData in _mine("bonus_vs_status"):
		if b.params["statuses"].any(func(s): return target.statuses.has_status(s)):
			_note(b)
			bonus += damage * value(b, "pct")
	for b: BoonData in _mine("bonus_type"):
		if hit.move.element != null and hit.move.element.id == str(b.params["type"]):
			_note(b)
			bonus += damage * value(b, "pct")
	for b: BoonData in _mine("crit"):
		if _rng.randf() <= value(b, "chance"):
			_note(b)
			bonus += damage * float(b.params["pct"])
			Events.signature_triggered.emit(_creature, "¡Crítico!", _color(b))
	for b: BoonData in _mine("lifesteal"):
		_note(b)
		_creature.health.heal(damage * value(b, "pct"))
	for b: BoonData in _mine("first_strike"):
		if was_full:
			_note(b)
			bonus += damage * value(b, "pct")
			Events.signature_triggered.emit(_creature, "¡Aliento Polar!", _color(b))
	for b: BoonData in _mine("chain"):
		if target.statuses.has_status(b.params["status"]):
			var best: Creature = null
			var best_d := float(b.params["range"])
			for e in enemies():
				var d := e.global_position.distance_to(target.global_position)
				if e != target and d < best_d:
					best_d = d
					best = e
			if best != null:
				_note(b)
				_hurt(best, damage * value(b, "pct"))
				Fx.burst(world.entities, best.global_position + Vector2(0, -8), Color(1.6, 1.5, 0.5), 10, 50.0)
	for b: BoonData in _mine("hit_blast"):
		if int(b.params["slot"]) in [-1, slot]:
			_note(b)
			_blast(b, target.global_position, damage * value(b, "pct"))
	_hurt(target, bonus)


func _on_dodged() -> void:
	if not is_instance_valid(_creature):
		return
	for b: BoonData in _mine("dodge_cd"):
		_note(b)
		_creature.moves.dodge_cooldown *= maxf(0.2, 1.0 - value(b, "pct"))
	for b: BoonData in _mine("dodge_blast"):
		if _clock < float(_dodge_ready.get(b.id, 0.0)):
			continue
		_dodge_ready[b.id] = _clock + float(b.params.get("cooldown", 0.0))
		_note(b)
		_blast(b, _creature.global_position, _power(value(b, "power")))


func _on_damaged(amount: float, hit: HitInfo) -> void:
	if not is_instance_valid(_creature) or amount <= 0.0:
		return
	if hit != null and hit.attacker is Creature:
		for b: BoonData in _mine("thorns"):
			if _clock < float(_thorns.get(b.id, 0.0)):
				continue
			_thorns[b.id] = _clock + float(b.params["cooldown"])
			_note(b)
			_status(hit.attacker, b.params["status"])
			_hurt(hit.attacker, _power(value(b, "power")))
			Events.signature_triggered.emit(_creature, "¡Casco Dentado!" if b.is_item() else "¡Coraza!", _color(b))
	if _creature.is_down():
		return
	for b: BoonData in _mine("phoenix"):
		if not _used.has(b.id) and _creature.health.ratio() < float(b.params["below"]):
			_used[b.id] = true
			_note(b)
			_creature.health.heal(_creature.instance.max_hp() * value(b, "heal"))
			Fx.burst(world.entities, _creature.global_position + Vector2(0, -8), Color(1.8, 1.0, 0.4), 26, 70.0)
			Events.signature_triggered.emit(_creature, str(b.params.get("word", "¡Ave Fénix!")), _color(b))
	for b: BoonData in _mine("guard"):
		if not _used.has(b.id) and _creature.health.ratio() < float(b.params["below"]):
			_used[b.id] = true
			_note(b)
			_creature.health.invulnerable_time = maxf(_creature.health.invulnerable_time, value(b, "time"))
			Fx.burst(world.entities, _creature.global_position + Vector2(0, -8), Color(1.6, 1.5, 1.0), 20, 60.0)
			Events.signature_triggered.emit(_creature, "¡Cinta Focus!", _color(b))


func _on_fainted(c: Node) -> void:
	if not (c is Creature) or c.team == Creature.Team.ALLY or not is_instance_valid(_creature) or active_entries().is_empty():
		return
	for b: BoonData in _mine("kill_pp"):
		_note(b)
		_creature.moves.set_pp(_creature.moves.pp() + _creature.moves.max_pp() * value(b, "pct"))
	for b: BoonData in _mine("kill_blast"):
		var need := str(b.params.get("need", ""))
		if need == "" or c.statuses.has_status(need):
			_note(b)
			_blast(b, c.global_position, _power(value(b, "power")), c)
