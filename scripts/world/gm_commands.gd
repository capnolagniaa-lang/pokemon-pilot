class_name GmCommands
extends RefCounted
## Comandos de la consola de Game Master (GmConsole, pedido del usuario 2026-10-29). `run(línea)` devuelve el texto
## que muestra la consola. Nada de esto toca la historia (banderas), las zonas visitadas (salvo llegar con «ir» a una
## zona: estás ahí) ni dónde volvés al perder.

## «ir pruebas»: la zona de pruebas (tools/build_test_zone.gd).
const TEST_ZONE := "pruebas_pueblo"

const HELP := [
	["ayuda", "esta lista"],
	["exp <cantidad> [lugar]", "EXP a un Pokémon (lugar 1-6 del equipo; sin lugar, el que está afuera)"],
	["nivel <n> [lugar]", "lo sube hasta ese nivel (aprende ataques y evoluciona como siempre)"],
	["curar", "cura a todo el equipo"],
	["dinero <cantidad>", "suma dinero (negativo: resta)"],
	["objeto <nombre> [cantidad]", "a la Mochila (con parte del nombre te muestra cuáles hay)"],
	["pokemon <especie> <nivel>", "al equipo (o a la Caja si está lleno)"],
	["hora <0-23>", "cambia la hora del día"],
	["ir <zona> [x,y]", "te lleva a una zona (a su plaza o a esa celda); ir pruebas = la zona de pruebas"],
	["volar", "cámara libre para mirar el mapa: WASD, Shift = rápido, rueda = zoom, Esc vuelve. No descubre nada"],
	["limpiar", "borra la consola"],
]

var world: Node


func _init(p_world: Node) -> void:
	world = p_world


## Ejecuta una línea. Devuelve el texto de respuesta.
func run(line: String) -> String:
	var parts := line.strip_edges().split(" ", false)
	if parts.is_empty():
		return ""
	var cmd := norm(parts[0])
	var args := parts.slice(1)
	match cmd:
		"ayuda", "help", "?":
			return help_text()
		"exp", "experiencia":
			return _exp(args)
		"nivel", "lvl", "level":
			return _level(args)
		"curar", "heal":
			return _heal()
		"dinero", "plata", "money":
			return _money(args)
		"objeto", "item":
			return _item(args)
		"pokemon":
			return _pokemon(args)
		"hora":
			return _hour(args)
		"volar", "fly":
			return _fly()
		"ir", "tp", "teleport":
			return _go(args)
	return "No conozco «%s». Escribí ayuda." % parts[0]


static func help_text() -> String:
	var out := PackedStringArray(["Comandos:"])
	for h in HELP:
		out.append("  %s — %s" % h)
	return "\n".join(out)


## Minúsculas, sin tildes y con _ en vez de espacios (para comparar con ids y nombres).
static func norm(s: String) -> String:
	s = s.strip_edges().to_lower()
	for pair in [["á", "a"], ["é", "e"], ["í", "i"], ["ó", "o"], ["ú", "u"], ["ü", "u"], ["ñ", "n"], [" ", "_"],
			["-", "_"], ["♀", "_h"], ["♂", "_m"], [".", ""], ["'", ""]]:
		s = s.replace(pair[0], pair[1])
	return s


## Busca en un diccionario de recursos (id → recurso con display_name). Devuelve el recurso o un Array con los
## candidatos si no hay uno solo.
static func find_named(table: Dictionary, query: String) -> Variant:
	var q := norm(query)
	if q == "":
		return []
	var partial: Array = []
	for id in table:
		var res = table[id]
		var name := norm(str(res.display_name))
		if norm(id) == q or name == q:
			return res
		if norm(id).contains(q) or name.contains(q):
			partial.append(res)
	if partial.size() == 1:
		return partial[0]
	return partial


func _target(args: Array, index: int) -> CreatureInstance:
	if args.size() > index:
		var slot := int(args[index]) - 1
		return GameState.party[slot] if slot >= 0 and slot < GameState.party.size() else null
	return GameState.active()


func _exp(args: Array) -> String:
	if args.is_empty() or not str(args[0]).is_valid_int() or int(args[0]) <= 0:
		return "Uso: exp <cantidad> [lugar]"
	var inst := _target(args, 1)
	if inst == null:
		return "No hay Pokémon en ese lugar."
	var text := GameState.grant_exp(inst, int(args[0]))
	return "%s ganó %d EXP%s" % [inst.display_name(), int(args[0]), text]


func _level(args: Array) -> String:
	if args.is_empty() or not str(args[0]).is_valid_int():
		return "Uso: nivel <n> [lugar]"
	var inst := _target(args, 1)
	if inst == null:
		return "No hay Pokémon en ese lugar."
	var to := clampi(int(args[0]), 1, CreatureInstance.MAX_LEVEL)
	if to <= inst.level:
		return "%s ya es Nv. %d (bajar de nivel no se puede)." % [inst.display_name(), inst.level]
	var need := CreatureInstance.exp_for_level(inst.species.growth_rate, to) - inst.experience
	var text := GameState.grant_exp(inst, need)
	return "%s ganó %d EXP%s" % [inst.display_name(), need, text]


## Como la enfermera, pero sin cambiar adónde volvés si perdés (StoryDirector.heal_party lo cambia).
func _heal() -> String:
	if GameState.party.is_empty():
		return "No tenés Pokémon."
	GameState.heal_party()
	Events.party_healed.emit()
	var c: Creature = world.companion
	if is_instance_valid(c) and c.instance == GameState.active():
		c.statuses.clear()
		c.health.changed.emit(c.instance.hp, c.instance.max_hp())
	elif not world.combat.in_battle:
		world.respawn_companion()
	return "Equipo curado."


func _money(args: Array) -> String:
	if args.is_empty() or not str(args[0]).is_valid_int():
		return "Uso: dinero <cantidad>"
	GameState.add_money(int(args[0]))
	return "Ahora tenés ₽%d." % GameState.money


func _item(args: Array) -> String:
	if args.is_empty():
		return "Uso: objeto <nombre> [cantidad]  (ej.: objeto caramelo raro 5, objeto mt26)"
	var amount := 1
	var words := args.duplicate()
	if words.size() > 1 and str(words[-1]).is_valid_int():
		amount = maxi(1, int(words.pop_back()))
	var found = find_named(DB.items, " ".join(words))
	if found is Array:
		return _choices("objeto", found)
	var it: ItemData = found
	GameState.add_item(it.id, amount)
	return "%d × %s a la Mochila (tenés %d)." % [amount, it.display_name, GameState.item_count(it.id)]


func _pokemon(args: Array) -> String:
	if args.size() < 2 or not str(args[-1]).is_valid_int():
		return "Uso: pokemon <especie> <nivel>  (ej.: pokemon pikachu 25)"
	var lvl := clampi(int(args[-1]), 1, CreatureInstance.MAX_LEVEL)
	var found = find_named(DB.species, " ".join(args.slice(0, args.size() - 1)))
	if found is Array:
		return _choices("especie", found)
	var sp: SpeciesData = found
	var where := GameState.add_caught(CreatureInstance.create(sp, lvl))
	return "%s Nv. %d %s." % [sp.display_name, lvl, "se sumó al equipo" if where == "equipo" else "fue a la Caja"]


func _hour(args: Array) -> String:
	if args.is_empty() or not str(args[0]).is_valid_float():
		return "Uso: hora <0-23>"
	GameState.time_of_day = fposmod(float(args[0]), 24.0)
	if world.get("day_night") != null:
		world.day_night.apply()
	var text := "Son las %02d:00." % int(GameState.time_of_day)
	if float(GameState.setting("time_lock")) >= 0.0:
		text += " Ojo: tenés la hora fija en los Ajustes del juego, así que vuelve a esa."
	return text


## Te lleva a una zona: a la celda pedida o a la caminable más cercana a su plaza. La consola se cierra y el viaje
## (StoryDirector.teleport, con fundido) arranca al cerrarla.
func _go(args: Array) -> String:
	if args.is_empty():
		return "Uso: ir <zona> [x,y]  (ej.: ir pruebas, ir ciudad celeste, ir ruta4 180,13)"
	if world.combat.in_battle or world.arena.active:
		return "No en plena pelea."
	var words := args.duplicate()
	var at := ""
	if words.size() > 1 and str(words[-1]).contains(","):
		at = words.pop_back()
	var query := " ".join(words)
	if norm(query) == "pruebas":
		query = TEST_ZONE
	var data: WorldData = world.streamer.world_data
	var table := {}
	for z in data.zones:
		table[z.id] = z
	var found = find_named(table, query)
	if found is Array:
		return _choices("zona", found)
	var entry: ZoneEntry = found
	var cell := entry.hub
	if at != "":
		var p := at.split(",")
		if p.size() != 2 or not p[0].strip_edges().is_valid_int() or not p[1].strip_edges().is_valid_int():
			return "La celda va como x,y (ej.: 20,12)."
		cell = Vector2i(int(p[0]), int(p[1]))
		if not Rect2i(Vector2i.ZERO, entry.size).has_point(cell):
			return "%s mide %d×%d: esa celda queda afuera." % [entry.display_name, entry.size.x, entry.size.y]
	else:
		world.streamer.load_around_now(Vector2((entry.origin + cell) * data.tile_size))
		var zone: Node = world.streamer.zone_node(entry.id)
		if zone != null:
			cell = MapRules.nearest_walkable(zone, entry, cell)
	world.story.teleport.call_deferred(entry.id, cell)
	return "Yendo a %s (%d, %d)." % [entry.display_name, cell.x, cell.y]


func _fly() -> String:
	var why: String = world.gm_flight.why_not()
	if why != "":
		return why
	world.gm_flight.start.call_deferred()
	return "Volando. WASD para moverte, Shift = rápido, rueda = zoom, Esc (o volar) para volver."


static func _choices(kind: String, found: Array) -> String:
	if found.is_empty():
		return "No encontré ese %s." % kind
	var names := PackedStringArray()
	for res in found.slice(0, 12):
		names.append(str(res.display_name))
	return "¿Cuál? %s%s" % [", ".join(names), " …" if found.size() > 12 else ""]
