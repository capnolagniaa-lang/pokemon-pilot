class_name RogueRewards
extends Node
## Las recompensas de sala del Modo Desafío (R-3 de docs/PROPUESTA_ROGUELIKE.md; hijo de RogueRun, `world.rogue.rewards`).
## Cada sala limpia da UNA recompensa, de un tipo: la de la primera sala es fija (`first`) y la de las siguientes la
## elegís vos entre dos puertas con ícono (RogueRewardDoor) antes de pasar. Tipos (`TYPES`; números y pesos en
## data/rogue/desafio.json → `rewards`):
##  · bendicion: un legendario te ofrece 3 (RogueBoons, R-2).      · caramelo: +1 nivel a una bendición que tengas.
##  · mt: cambiás un ataque por otro que tu Pokémon puede aprender. · proteina: más vida máxima por toda la partida.
##  · dinero: plata para la Tienda.                                 · tienda: gastarla (Poción, Poké Ball, cura, bendición).
##  · centro: cura buena parte de la vida y llena los PP.
##  · objeto: elegís 1 de 3 objetos equipables (RogueBoons: 3 ranuras; con las 3 llenas, reemplaza a uno o va a la Mochila).
## Lo que no es bendición ni objeto (Más PS, la MT) queda anotado en `GameState.rogue["upgrades"]` para que se vea en el
## menú de pausa (`upgrades()`).
## Para sumar un tipo: una fila en TYPES, su peso en el JSON, su rama en `grant` y su ícono en sprites/ui/premios/.

const ICONS := "res://sprites/ui/premios/%s.png"
## id -> [nombre, qué da (para el cartel de la puerta y la pantalla)]
const TYPES := {
	"bendicion": ["Bendición", "Un legendario te ofrece 3 bendiciones."],
	"caramelo": ["Caramelo Raro", "Sube un nivel a una de tus bendiciones."],
	"mt": ["MT", "Cambiás un ataque por otro que tu Pokémon puede aprender."],
	"proteina": ["Más PS", "Más vida máxima por el resto de la partida."],
	"dinero": ["Dinero", "Plata para gastar en la Tienda."],
	"tienda": ["Tienda", "Gastás tu dinero: Poción, Poké Ball, curarte o una bendición."],
	"centro": ["Centro Pokémon", "Recuperás buena parte de la vida y todos los PP."],
	"objeto": ["Objeto", "Elegís 1 de 3 objetos para equiparle a tu Pokémon."],
	"bola": ["Poké Ball", "Una Poké Ball más: un tiro para atrapar (y desbloquear) a un Pokémon."],
}

## Con menos vida que esto, una de las puertas es siempre el Centro Pokémon.
const LOW_HP := 0.4
## La MT no ofrece ataques más fuertes que esto (un Hiperrayo en la sala 2 gana la partida solo).
const TM_MAX_POWER := 100.0

var run: Node
var world: Node
var _rng := RandomNumberGenerator.new()
## Lo último que se dio (texto; tests y el cartel).
var last_text := ""


func _ready() -> void:
	run = get_parent()
	world = run.get_parent()
	_rng.randomize()


func cfg() -> Dictionary:
	return run.floor_data.get("rewards", {})


static func type_name(id: String) -> String:
	return TYPES[id][0] if TYPES.has(id) else id


static func icon_of(id: String) -> String:
	return ICONS % id


func _mine() -> CreatureInstance:
	return GameState.active()


# --- Qué se puede ofrecer -------------------------------------------------------------------------------------------

## ¿Tiene sentido ofrecer ese tipo ahora? (Caramelo Raro sin bendiciones, Tienda sin plata, MT sin nada que aprender...)
func available(id: String) -> bool:
	match id:
		"caramelo":
			return run.boons.owned().any(func(e): return int(e["level"]) < RogueBoons.MAX_LEVEL)
		"objeto":
			return not run.boons.item_pool().is_empty()
		"tienda":
			return GameState.money >= cheapest()
		"mt":  # (con kit fijo no se cambian ataques)
			return GameState.active() != null and GameState.active().rogue_kit == null and not tm_candidates().is_empty()
	return TYPES.has(id)


func cheapest() -> int:
	var best := 999999
	for item: Dictionary in cfg().get("shop", []):
		best = mini(best, int(item["price"]))
	return best


## **Pesos por necesidad** (paso O-a de la sección 11 de la propuesta): el peso de un tipo en las puertas = su peso base
## × un factor según cómo venís. Con la vida casi entera el Centro casi no sale y bajo 40 % sale ×3; la Tienda pesa más
## si te alcanza para dos cosas; la MT, si hay un ataque claramente mejor que el más flojo tuyo; el Caramelo crece con
## las bendiciones que tenés; la Poké Ball, si te queda una o ninguna; el Objeto, con ranuras libres (y casi nada con
## las 3 al máximo). Nunca se ofrece algo inútil (`available`).
func weight_of(id: String) -> float:
	var base := float(cfg().get("weights", {}).get(id, 0.0))
	if base <= 0.0 or not available(id):
		return 0.0
	var inst := _mine()
	match id:
		"centro":
			var ratio: float = inst.hp / maxf(1.0, inst.max_hp()) if inst != null else 1.0
			return base * lerpf(3.0, 0.3, clampf((ratio - 0.4) / 0.5, 0.0, 1.0))
		"tienda":
			var prices: Array = cfg().get("shop", []).map(func(x): return int(x["price"]))
			prices.sort()
			return base * (1.5 if prices.size() >= 2 and GameState.money >= prices[0] + prices[1] else 1.0)
		"mt":
			var worst := 999.0
			for m in inst.equipped_moves:
				if m != null:
					worst = minf(worst, m.power if m.category != MoveData.Category.STATUS else 0.0)
			return base * (1.5 if tm_candidates().any(func(m): return m.power >= worst + 20.0) else 1.0)
		"caramelo":
			return base * minf(2.0, 0.5 + 0.25 * float(run.boons.owned().filter(func(e): return int(e["level"]) < RogueBoons.MAX_LEVEL).size()))
		"bola":
			var balls := GameState.item_count("poke_ball")
			return base * (2.0 if balls <= 1 else (0.3 if balls >= 3 else 1.0))
		"objeto":
			var items: Array = run.boons.items()
			if items.size() < RogueBoons.ITEM_SLOTS:
				return base * 1.5
			return base * (0.3 if items.all(func(e): return int(e["level"]) >= RogueBoons.MAX_LEVEL) else 1.0)
	return base


## Las recompensas de las puertas: `count` tipos distintos, al azar por peso (`weight_of`), de los que se pueden ofrecer.
func options(rng: RandomNumberGenerator = null, count: int = 2) -> Array[String]:
	if rng == null:
		rng = _rng
	var weights := {}
	for id: String in TYPES:
		if weight_of(id) > 0.0:
			weights[id] = weight_of(id)
	var pool: Array = weights.keys()
	var out: Array[String] = []
	var inst := _mine()
	if inst != null and inst.hp < inst.max_hp() * LOW_HP and pool.has("centro"):  # con poca vida, una puerta es el Centro seguro
		out.append("centro")
		pool.erase("centro")
	while out.size() < count and not pool.is_empty():
		var total := 0.0
		for id in pool:
			total += float(weights[id])
		var pick := rng.randf() * total
		for id: String in pool:
			pick -= float(weights[id])
			if pick <= 0.0:
				out.append(id)
				pool.erase(id)
				break
	return out


# --- Dar la recompensa ----------------------------------------------------------------------------------------------

## Da la recompensa de ese tipo (las que hay que elegir abren su pantalla y esperan). Si ese tipo ya no se puede
## (p. ej. Caramelo Raro sin bendiciones), da una bendición.
func grant(id: String) -> void:
	if not available(id):
		id = "bendicion"
	last_text = ""
	match id:
		"bendicion":
			await _boon()
		"caramelo":
			await _candy()
		"mt":
			await _tm()
		"proteina":
			_protein()
		"dinero":
			_money()
		"tienda":
			await _shop()
		"centro":
			_center()
		"objeto":
			await _item()
		"bola":
			GameState.add_item("poke_ball")
			last_text = "Una Poké Ball más (tenés %d)." % GameState.item_count("poke_ball")
	if last_text != "":
		Events.message_requested.emit(last_text)


## **Reroll** (paso O-a; decisión del usuario 2026-11-11): en las pantallas de "elegí 1 de 3" (bendiciones y objetos)
## se pueden cambiar las opciones pagando con la plata de la partida. El costo se duplica con cada reroll seguido en la
## misma pantalla y sube con las salas limpiadas (`rewards.reroll`: base y room_step). En las puertas no hay.
func reroll_cost(times: int) -> int:
	var c: Dictionary = cfg().get("reroll", {})
	return roundi(float(c.get("base", 30)) * pow(2.0, float(times)) * (1.0 + float(run.rooms_cleared) * float(c.get("room_step", 0.25))))


## Un legendario te ofrece 3 bendiciones y elegís una (o pagás para que te ofrezcan otras).
func _boon() -> void:
	var rerolls := 0
	while true:
		var o: Dictionary = run.boons.offer()
		if o["options"].is_empty():
			return
		run.boon_screen = BoonScreen.open(run, run.boons, o, reroll_cost(rerolls))
		var i: int = await run.boon_screen.chosen
		run.boon_screen = null
		if i < 0:  # reroll
			GameState.money -= reroll_cost(rerolls)
			rerolls += 1
			continue
		run.boons.take(o["options"][i]["id"], o["options"][i]["rarity"])
		break
	last_text = ""  # (take ya lo anuncia)


## Caramelo Raro: +1 nivel a una de tus bendiciones (te muestra hasta 3).
func _candy() -> void:
	var boons: RogueBoons = run.boons
	var mine: Array = boons.owned().filter(func(e): return int(e["level"]) < RogueBoons.MAX_LEVEL)
	mine.shuffle()
	mine = mine.slice(0, 3)
	var cards: Array = []
	for e: Dictionary in mine:
		var b: BoonData = DB.boons[e["id"]]
		var rar: Dictionary = boons.rarity(e["rarity"])
		cards.append({"icon": BoonScreen.ICONS % b.id, "title": b.display_name,
			"tag": "Nv. %d → %d" % [int(e["level"]), int(e["level"]) + 1], "tag_color": Color(rar["color"][0], rar["color"][1], rar["color"][2]),
			"text": boons.describe(b, e["rarity"], int(e["level"]) + 1)})
	var i: int = await _ask("Caramelo Raro", "Elegí una de tus bendiciones: sube un nivel.", cards, Color(0.45, 0.7, 1.0))
	boons.level_up(mine[i]["id"])
	last_text = "%s subió a Nv. %d." % [DB.boons[mine[i]["id"]].display_name, int(mine[i]["level"])]


## Los ataques de daño que tu Pokémon puede aprender (por nivel, a cualquier nivel, o por MT) y no tiene puestos.
func tm_candidates() -> Array[MoveData]:
	var out: Array[MoveData] = []
	var inst := _mine()
	if inst == null:
		return out
	var known: Array = []
	for e in inst.species.learnset_entries():
		if e != null and e.move != null:
			known.append(e.move)
	known.append_array(inst.species.tm_moves)
	var names := {}
	for m in inst.equipped_moves:
		if m != null:
			names[m.display_name] = true
	for m: MoveData in known:
		if m != null and not names.has(m.display_name) and m.power > 0.0 and m.power <= TM_MAX_POWER \
				and m.category != MoveData.Category.STATUS and not m.does_nothing():
			names[m.display_name] = true
			out.append(m)
	return out


## MT: elegís uno de 3 ataques nuevos y después a cuál de los tuyos reemplaza.
func _tm() -> void:
	var inst := _mine()
	var pool := tm_candidates()
	pool.shuffle()
	var picks: Array[MoveData] = []
	picks.assign(pool.slice(0, 3))
	var i: int = await _ask("MT", "Elegí un ataque nuevo para %s." % inst.species.display_name, picks.map(_move_card), Color(1.0, 0.85, 0.3))
	var move: MoveData = picks[i]
	var cards: Array = []
	var slots: Array[int] = []
	for s in CreatureInstance.SLOT_COUNT:
		var cur: MoveData = inst.equipped_moves[s] if s < inst.equipped_moves.size() else null
		slots.append(s)
		if cur == null:
			cards.append({"icon": icon_of("mt"), "title": "Ranura libre", "tag": "Ataque %d" % (s + 1), "text": "Lo pone acá, sin sacar nada."})
		else:
			var card: Dictionary = _move_card(cur)
			card["text"] = "%s.\n%s" % [card["tag"], card["text"]]
			card["tag"] = "Ataque %d  ·  %s" % [s + 1, Controls.label(Controls.SLOT_ACTIONS[s])]
			card["tag_color"] = UiStyle.TEXT_DIM
			cards.append(card)
	var j: int = await _ask("¿A cuál reemplaza %s?" % move.display_name, "El ataque que elijas se pierde por esta partida.", cards, Color(1.0, 0.85, 0.3))
	var old: MoveData = inst.equipped_moves[slots[j]] if slots[j] < inst.equipped_moves.size() else null
	replace_move(slots[j], move)
	note_upgrade("mt", "MT: %s" % move.display_name, "Aprendió %s%s." % [move.display_name,
		" en lugar de %s" % old.display_name if old != null else ""], false)
	last_text = "%s aprendió %s." % [inst.species.display_name, move.display_name]


func _move_card(m: MoveData) -> Dictionary:
	return {"icon": icon_of("mt"), "title": m.display_name, "tag": "%s  ·  Potencia %d" % [m.element.display_name if m.element != null else "", roundi(m.power)],
		"tag_color": m.element.color if m.element != null else UiStyle.TEXT_DIM, "text": MoveInfo.what_it_does(m)}


## Pone ese ataque en la ranura de tu Pokémon (y en el que está peleando).
func replace_move(slot: int, move: MoveData) -> void:
	var inst := _mine()
	while inst.equipped_moves.size() < CreatureInstance.SLOT_COUNT:
		inst.equipped_moves.append(null)
	inst.equipped_moves[slot] = move
	var c: Creature = world.companion
	if is_instance_valid(c) and c.instance == inst:
		c.moves.setup(inst)
	Events.equipment_changed.emit(inst)


## Más PS: sube la vida máxima de tu Pokémon por toda la partida (y te da esa vida ahora).
func _protein() -> void:
	var inst := _mine()
	var pct := float(cfg().get("proteina", 0.15))
	var before := inst.max_hp()
	inst.hp_mult *= 1.0 + pct
	inst.hp = minf(inst.max_hp(), inst.hp + (inst.max_hp() - before))
	_refresh_health()
	var e := note_upgrade("proteina", "Más PS", "", true)
	e["text"] = "Vida máxima +%d %% (×%d)." % [roundi((pow(1.0 + pct, int(e["count"])) - 1.0) * 100.0), int(e["count"])]
	last_text = "¡Más PS! La vida máxima de %s subió %d %%." % [inst.species.display_name, roundi(pct * 100.0)]


func _money() -> void:
	var span: Array = cfg().get("dinero", [80, 120])
	var amount := roundi(float(_rng.randi_range(int(span[0]), int(span[1]))) * (1.0 + run.boons.stat("money")))
	GameState.money += amount
	last_text = "Encontraste $%d (tenés $%d)." % [amount, GameState.money]


## Centro Pokémon: cura parte de la vida y llena los PP.
func _center() -> void:
	var inst := _mine()
	var pct := float(cfg().get("centro", 0.6))
	inst.hp = minf(inst.max_hp(), inst.hp + inst.max_hp() * pct)
	var c: Creature = world.companion
	if is_instance_valid(c):
		c.moves.set_pp(c.moves.max_pp())
		c.statuses.clear()
		Fx.burst(world.entities, c.global_position + Vector2(0, -8), Color(1.5, 0.8, 1.2), 18, 46.0)
	_refresh_health()
	last_text = "Centro Pokémon: %s recuperó %d %% de la vida y todos los PP." % [inst.species.display_name, roundi(pct * 100.0)]


## La Tienda: comprás lo que quieras mientras te alcance; "Salir" cierra.
func _shop() -> void:
	var bought: Array[String] = []
	while true:
		var items: Array = cfg().get("shop", [])
		var cards: Array = []
		for item: Dictionary in items:
			cards.append({"icon": _shop_icon(item), "title": str(item["name"]), "tag": "$%d" % int(item["price"]),
				"tag_color": UiStyle.ACCENT, "text": str(item["text"]), "disabled": GameState.money < int(item["price"])})
		cards.append({"icon": icon_of("dinero"), "title": "Salir", "tag": "Te quedan $%d" % GameState.money, "text": "Seguir con la partida."})
		var i: int = await _ask("Tienda", "Tenés $%d. Comprá lo que quieras." % GameState.money, cards, Color(0.5, 0.75, 1.0))
		if i >= items.size():
			break
		buy(items[i])
		bought.append(str(items[i]["name"]))
		if str(items[i]["id"]) == "bendicion":
			await _boon()
		elif str(items[i]["id"]) == "objeto":
			await _item()
	last_text = "Compraste: %s." % ", ".join(bought) if not bought.is_empty() else ""


## Objeto: te ofrecen 3 con rareza y elegís uno. Repetido = sube de nivel. Con las 3 ranuras llenas elegís cuál sale
## (te dan plata por él) o lo guardás en la Mochila sin equipar.
func _item() -> void:
	var boons: RogueBoons = run.boons
	var opts: Array = []
	var i := -1
	var rerolls := 0
	while i < 0:
		opts = boons.offer_items()
		if opts.is_empty():
			return
		var cards: Array = []
		for o: Dictionary in opts:
			var mine: Dictionary = boons.entry(o["id"])
			cards.append(item_card(o["id"], o["rarity"], int(mine.get("level", 0)) + 1, not mine.is_empty()))
		run.reward_screen = RewardScreen.open(run, "Objeto", "Elegí uno. Tu Pokémon lleva hasta %d; los repetidos suben de nivel.%s" % [
			RogueBoons.ITEM_SLOTS, "  ·  Suerte %d" % boons.luck() if boons.luck() > 0 else ""], cards, RogueBoons.ITEM_COLOR, reroll_cost(rerolls))
		i = await run.reward_screen.chosen
		run.reward_screen = null
		if i < 0:
			GameState.money -= reroll_cost(rerolls)
			rerolls += 1
	var pick: Dictionary = opts[i]
	var to_stash := false
	if boons.entry(pick["id"]).is_empty() and boons.slots_full():
		var slots: Array = boons.items().duplicate()
		var swap: Array = []
		for e: Dictionary in slots:
			var card := item_card(e["id"], e["rarity"], int(e["level"]), false)
			card["tag"] = "Sale  ·  te dan $%d" % boons.sell_value(e)
			swap.append(card)
		swap.append({"icon": icon_of("objeto"), "title": "Guardarlo en la Mochila", "tag": "Sin equipar", "text": "No reemplaza a ninguno. Lo podés equipar después desde la Mochila del menú de pausa."})
		var j: int = await _ask("¿A cuál reemplaza %s?" % DB.rogue_items[pick["id"]].display_name, "Tus %d ranuras están llenas." % RogueBoons.ITEM_SLOTS, swap, RogueBoons.ITEM_COLOR)
		if j < slots.size():
			var at: int = boons.items().find(slots[j])
			boons.sell_item(slots[j])
			boons.items().insert(clampi(at, 0, boons.items().size()), {"id": pick["id"], "rarity": pick["rarity"], "level": 1})
			boons._items_changed()
			last_text = "%s reemplazó a %s." % [DB.rogue_items[pick["id"]].display_name, DB.rogue_items[slots[j]["id"]].display_name]
			return
		to_stash = true
	boons.take_item(pick["id"], pick["rarity"], to_stash)
	last_text = ""  # (take_item ya lo anuncia)


## La tarjeta de un objeto (también la usa el menú de pausa).
func item_card(id: String, rarity: String, level: int, upgrade: bool) -> Dictionary:
	var boons: RogueBoons = run.boons
	var d: BoonData = DB.rogue_items[id]
	var rar: Dictionary = boons.rarity(rarity)
	level = mini(level, RogueBoons.MAX_LEVEL)
	return {"icon": d.icon_path, "title": d.display_name, "tag": str(rar["name"]) + ("  ·  sube a Nv. %d" % level if upgrade else ""),
		"tag_color": Color(rar["color"][0], rar["color"][1], rar["color"][2]), "text": boons.describe(d, rarity, level)}


## Lo que conseguiste en la partida que no es bendición ni objeto (Más PS, MT): [{id, title, text, icon, count}].
func upgrades() -> Array:
	if not GameState.rogue.has("upgrades"):
		GameState.rogue["upgrades"] = []
	return GameState.rogue["upgrades"]


## Anota una mejora de la partida. Con `stack`, las del mismo tipo se juntan en una sola (con su cuenta).
func note_upgrade(id: String, title: String, text: String, stack: bool) -> Dictionary:
	if stack:
		for e: Dictionary in upgrades():
			if e["id"] == id:
				e["count"] = int(e["count"]) + 1
				run.boons.changed.emit()
				return e
	var fresh := {"id": id, "title": title, "text": text, "icon": icon_of(id), "count": 1}
	upgrades().append(fresh)
	run.boons.changed.emit()
	return fresh


## Compra un artículo de la Tienda (si alcanza la plata). La bendición la ofrece `_shop` después.
func buy(item: Dictionary) -> bool:
	var price := int(item["price"])
	if GameState.money < price:
		return false
	GameState.money -= price
	match str(item["id"]):
		"cura":
			var inst := _mine()
			inst.hp = minf(inst.max_hp(), inst.hp + inst.max_hp() * float(item.get("heal", 0.4)))
			_refresh_health()
		"bendicion", "objeto":
			pass
		_:
			GameState.add_item(str(item["id"]))
	return true


func _shop_icon(item: Dictionary):
	var id := str(item["id"])
	if DB.items.has(id) and DB.items[id].icon != null:
		return DB.items[id].icon
	return icon_of("centro" if id == "cura" else id)  # (bendicion y objeto tienen el suyo en sprites/ui/premios)


func _refresh_health() -> void:
	var c: Creature = world.companion
	if is_instance_valid(c):
		c.health.changed.emit(c.instance.hp, c.health.max_hp())


## Abre la pantalla de tarjetas y espera la elección (queda en `run.reward_screen` para los tests y el bot).
func _ask(title: String, subtitle: String, cards: Array, tint: Color) -> int:
	run.reward_screen = RewardScreen.open(run, title, subtitle, cards, tint)
	var i: int = await run.reward_screen.chosen
	run.reward_screen = null
	return i
