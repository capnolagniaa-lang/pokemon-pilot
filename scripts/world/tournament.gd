class_name Tournament
extends Node
## Torneo de Ciudad Plateada (docs/PLAN_TORNEO.md, T-2): la recepcionista (acción "torneo") te deja elegir una copa
## (TournamentCup), inscribís a los primeros 3 o 6 Pokémon de tu equipo que no pasen el nivel de la copa (peleás con
## ellos tal cual), pagás la entrada y te dan 6 Pociones del torneo (tu Mochila queda guardada hasta que salís).
## Cuadro de 8 con eliminación directa: cuartos, semifinal y final en el estadio (arena_torneo). **No se cura entre
## rondas**: las 6 Pociones son para todo el torneo. Si ganás la final: el premio en dinero; si perdés una pelea,
## quedás afuera (la entrada no se devuelve). Al salir vuelven tu equipo completo y tu Mochila.
## Rivales: Brock y Azul (cuando ya los enfrentaste en la historia, o siempre en el modo libre) con su equipo, que
## crece y evoluciona según la copa, y entrenadores generados (pedido del usuario 2026-10-30: antes eran solo 20
## Pokémon de primera fase y era muy fácil): de Kanto y **visitantes de Johto y Hoenn**, cada clase con sus tipos
## (Karateka: Lucha; Nadador: Agua...), con Pokémon de su región **evolucionados según el nivel** (por nivel, piedra,
## intercambio o amistad, como harían los entrenadores de los juegos) y cerca del tope de la copa. Cada clase pelea con
## su estilo (TrainerStyle).

const ROUNDS := ["CUARTOS DE FINAL", "SEMIFINAL", "FINAL"]
const POTIONS := 6
## Regiones de donde vienen los entrenadores: [nombre, primer n.º de Pokédex, último].
const REGIONS := [["Kanto", 1, 151], ["Johto", 152, 251], ["Hoenn", 252, 386]]
## De los 7 rivales generados, cuántos son visitantes (de Johto o Hoenn).
const VISITORS := 3
## Los que nunca salen en el torneo (legendarios y los que casi no pelean).
const BANNED := ["articuno", "zapdos", "moltres", "mewtwo", "mew", "raikou", "entei", "suicune", "lugia", "ho_oh",
	"celebi", "regirock", "regice", "registeel", "latias", "latios", "kyogre", "groudon", "rayquaza", "jirachi", "deoxys",
	"unown", "wobbuffet", "wynaut", "smeargle", "ditto", "shedinja", "magikarp", "feebas"]
## Nivel desde el que un entrenador ya tiene la evolución que no es por nivel (piedra, intercambio, amistad...).
const EVO_LEVEL := {"piedra": 28, "intercambio": 36, "amistad": 22, "otro": 30}
## [clase, sprite (art/pret/characters), nombres, tipos que le gustan (vacío = cualquiera)]
const CLASSES := [
	["Cazabichos", "bug_catcher", ["Nico", "Bruno", "Tiago"], ["bicho"]],
	["Campista", "camper", ["Lucas", "Ramiro", "Gonzalo"], ["tierra", "roca", "normal"]],
	["Chica", "lass", ["Sofía", "Martina", "Lola"], ["normal", "hada", "planta"]],
	["Joven", "youngster", ["Facu", "Lautaro", "Joaco"], ["normal", "volador"]],
	["Entrenadora Guay", "cooltrainer_f", ["Valentina", "Camila", "Abril"], []],
	["Entrenador Guay", "cooltrainer_m", ["Mateo", "Santino", "Bauti"], []],
	["Karateka", "black_belt", ["Hernán", "Kenji", "Dante"], ["lucha"]],
	["Rockero", "rocker", ["Pity", "Rulo", "Chino"], ["electrico", "veneno"]],
	["Montañero", "hiker", ["Tano", "Beto", "Cacho"], ["roca", "tierra", "acero"]],
	["Nadador", "swimmer_m_land", ["Nahuel", "Thiago", "Ciro"], ["agua", "hielo"]],
	["Médium", "channeler", ["Ofelia", "Rosa", "Delia"], ["fantasma", "psiquico", "siniestro"]],
	["Pokemaníaco", "poke_maniac", ["Ezequiel", "Pipo", "Marcos"], ["dragon", "tierra", "normal"]],
	["Belleza", "beauty", ["Julieta", "Renata", "Mora"], ["planta", "hada", "agua"]],
	["Motorista", "biker", ["Toro", "Chancho", "Rata"], ["veneno", "fuego", "siniestro"]],
	["Científico", "scientist", ["Ulises", "Ernesto", "Iván"], ["electrico", "acero", "psiquico"]],
	["Caballero", "gentleman", ["Don Aníbal", "Don Ramón", "Don Julio"], ["fuego", "normal", "agua"]],
]

var world: Node
var cups: Array[TournamentCup] = []
## Registro del torneo en curso: ganador de cada ronda (para la prueba y la interfaz).
var bracket: Array = []
var active := false


func _ready() -> void:
	world = get_parent()
	for f in DirAccess.get_files_at("res://data/tournament"):
		var c = load("res://data/tournament/" + f.trim_suffix(".remap"))
		if c is TournamentCup:
			cups.append(c)
	cups.sort_custom(func(a, b): return a.order < b.order)
	world.story.register_action("torneo", desk)
	if not GameState.test_tournament.is_empty():
		_test_mode.call_deferred()


## Modo de prueba del torneo (desde el título, sin guardar): juega la copa elegida con el equipo armado, y al terminar
## ofrece repetir o volver al título.
func _test_mode() -> void:
	await get_tree().create_timer(0.6).timeout
	var cup: TournamentCup = null
	for c in cups:
		if c.id == GameState.test_tournament.get("cup", ""):
			cup = c
	if cup == null:
		return
	while true:
		for inst in GameState.party:
			inst.hp = inst.max_hp()
		await play(cup, eligible(cup))
		var again: int = await world.story.dialog.ask("Modo de prueba", "¿Otra vez?", PackedStringArray(["Jugar otra vez", "Volver al título"]))
		if again != 0:
			GameState.test_tournament = {}
			get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
			return


## Los Pokémon que se inscribirían en una copa: los primeros `team_size` del equipo con nivel <= tope.
func eligible(cup: TournamentCup) -> Array[CreatureInstance]:
	var out: Array[CreatureInstance] = []
	for inst in GameState.party:
		if cup.level_cap <= 0 or inst.level <= cup.level_cap:
			out.append(inst)
		if out.size() == cup.team_size:
			break
	return out


## La recepción: elegir copa, confirmar y jugar el torneo.
func desk() -> void:
	var d: DialogBox = world.story.dialog
	var options := PackedStringArray()
	for c in cups:
		options.append("%s · $%d" % [c.display_name, c.entry_fee])
	options.append("Ahora no")
	var pick := await d.ask("Recepcionista", "¿En qué copa te querés anotar? (Tenés $%d)" % GameState.money, options)
	if pick >= cups.size():
		await d.say("Recepcionista", PackedStringArray(["¡Te esperamos cuando quieras!"]))
		return
	var cup := cups[pick]
	var team := eligible(cup)
	if team.size() < cup.team_size:
		await d.say("Recepcionista", PackedStringArray(["Para la %s necesitás %d Pokémon%s." % [cup.display_name,
			cup.team_size, " de Nv. %d o menos" % cup.level_cap if cup.level_cap > 0 else ""],
			"Se inscriben los primeros de tu equipo que cumplan. Podés cambiar el orden en Esc → Equipo."]))
		return
	if GameState.money < cup.entry_fee:
		await d.say("Recepcionista", PackedStringArray(["La entrada cuesta $%d y tenés $%d. ¡Volvé cuando juntes más!" % [
			cup.entry_fee, GameState.money]]))
		return
	var names := ", ".join(team.map(func(i): return "%s (Nv. %d)" % [i.display_name(), i.level]))
	await d.say("Recepcionista", PackedStringArray(["Inscribís a: %s." % names,
		"La entrada es $%d e incluye %d Pociones. Si ganás la final, te llevás $%d." % [cup.entry_fee, POTIONS, cup.prize],
		"Ojo: entre ronda y ronda no se cura a nadie. ¡Administrá las Pociones!"]))
	if await d.ask("Recepcionista", "¿Confirmás la inscripción?", PackedStringArray(["Sí", "No"])) != 0:
		return
	GameState.spend_money(cup.entry_fee)
	await play(cup, team)


## Juega el torneo entero con este equipo (también lo usa el autotest). Devuelve true si ganaste la copa.
func play(cup: TournamentCup, team: Array[CreatureInstance]) -> bool:
	active = true
	_enter(team)
	var field := _field(cup, team)
	bracket = [field]
	var won := true
	for r in ROUNDS.size():
		var me_index := field.find("jugador")
		var rival: Dictionary = field[me_index ^ 1]
		var from: String = (" ¡Viene desde %s!" % rival["origen"]) if rival.has("origen") else ""
		await world.story.dialog.say("Locutor", PackedStringArray(["¡%s! Te toca contra %s %s.%s" % [
			ROUNDS[r].capitalize(), rival["title"], rival["name"], from]]))
		var result: String = await world.arena.start({"name": rival["name"], "title": rival["title"],
			"team": _team_of(rival), "arena_id": "arena_torneo", "texture": _texture(rival["gfx"]),
			"leader": r == ROUNDS.size() - 1, "no_blackout": true, "banner": ROUNDS[r],
			"defeat_lines": PackedStringArray([rival.get("pierde", "¡Bien jugado!")])})
		if result != "win":
			won = false
			break
		field = _next_round(field)
		bracket.append(field)
	if won:
		GameState.add_prize(cup.prize)
		GameState.set_flag("campeon_" + cup.id)
		await world.story.dialog.say("Locutor", PackedStringArray(["¡Y TENEMOS CAMPEÓN! ¡Ganaste la %s!" % cup.display_name,
			"¡Te llevás $%d!" % cup.prize]))
	else:
		await world.story.dialog.say("Locutor", PackedStringArray(["¡Quedaste afuera del torneo! Mejor suerte la próxima."]))
	_leave()
	active = false
	return won


# --- Equipo y mochila del torneo ----------------------------------------------------------------------------

## Guarda tu equipo completo y tu Mochila; quedan solo los inscriptos (curados) y las 6 Pociones del torneo.
func _enter(team: Array[CreatureInstance]) -> void:
	GameState.tournament = {"party_before": GameState.party.duplicate(), "bag_before": GameState.bag.duplicate(),
		"quick_before": GameState.quick_item}
	for inst in team:
		inst.hp = inst.max_hp()
	GameState.party.assign(team)
	GameState.active_index = 0
	GameState.bag = {"pocion": POTIONS}
	GameState.quick_item = "pocion"
	Events.party_changed.emit()


## Devuelve tu equipo completo y tu Mochila (las Pociones del torneo que sobraron se pierden).
func _leave() -> void:
	var t := GameState.tournament
	if t.is_empty():
		return
	GameState.party.assign(t["party_before"])
	GameState.bag = t["bag_before"]
	GameState.quick_item = t["quick_before"]
	GameState.tournament = {}
	GameState.active_index = 0
	for i in GameState.party.size():
		if GameState.party[i].hp > 0.0:
			GameState.active_index = i
			break
	Events.party_changed.emit()


# --- Cuadro y rivales ---------------------------------------------------------------------------------------

## Los 8 del cuadro (mezclados): vos + Brock/Azul si corresponde + generados.
func _field(cup: TournamentCup, team: Array[CreatureInstance]) -> Array:
	var cap: int = cup.level_cap
	if cap <= 0:  # copa libre: al nivel de tu Pokémon más alto
		for inst in team:
			cap = maxi(cap, inst.level)
	var out: Array = ["jugador"]
	var story := GameState.has_flag("historia")
	if not story or GameState.has_flag("medalla_roca"):
		out.append(_brock(cup, cap))
	if not story or GameState.has_flag("rival_ruta22_peleado"):
		out.append(_rival(cup, cap))
	var used := {}
	var visitors := 0
	while out.size() < 8:
		var cls: Array = CLASSES[randi() % CLASSES.size()]
		var nm: String = cls[2][randi() % cls[2].size()]
		if used.has(nm):
			continue
		used[nm] = true
		var region: Array = REGIONS[0]
		if visitors < VISITORS:
			region = REGIONS[1 + randi() % 2]
			visitors += 1
		out.append(generated_trainer(cls, nm, region, cup.team_size, cap))
	var rest := out.slice(1)
	rest.shuffle()
	var me_at := randi() % 8
	rest.insert(me_at, "jugador")
	return rest


## Un entrenador generado: Pokémon de su región (de primera fase, evolucionados según el nivel), de los tipos de su
## clase si hay suficientes, a 0-2 niveles del tope. Los visitantes avisan de dónde vienen.
func generated_trainer(cls: Array, nm: String, region: Array, size: int, cap: int) -> Dictionary:
	var pool := pool_for(region, cls[3])
	if pool.size() < size * 2:
		pool = pool_for(region, [])
	pool.shuffle()
	var mons := []
	for k in size:
		var lvl := clampi(cap - randi_range(0, 2), 2, 100)
		mons.append([evolve_for(DB.species[pool[k % pool.size()]], lvl).id, lvl])
	var entry := {"name": nm, "title": cls[0], "gfx": cls[1], "team": mons, "pierde": "¡Uh, me ganaste!"}
	if region[0] != "Kanto":
		entry["origen"] = region[0]
		entry["pierde"] = "¡Qué nivel tienen en Kanto! Me vuelvo a %s a entrenar." % region[0]
	return entry


## Especies de primera fase de una región (sin los prohibidos), de esos tipos si se piden.
static func pool_for(region: Array, types: Array) -> Array:
	var out := []
	for sp: SpeciesData in DB.species.values():
		if sp.dex < region[1] or sp.dex > region[2] or sp.id in BANNED:
			continue
		if sp.evolves_from != "" and DB.species.has(sp.evolves_from) \
				and DB.species[sp.evolves_from].dex >= region[1] and DB.species[sp.evolves_from].dex <= region[2]:
			continue  # (solo la primera fase de la región: la evolución sale por nivel)
		if not types.is_empty() and not sp.types.any(func(t): return t.id in types):
			continue
		out.append(sp.id)
	return out


## La especie que tendría un entrenador con ese Pokémon a ese nivel: evoluciona por nivel como siempre, y por piedra,
## intercambio o amistad desde EVO_LEVEL (como los entrenadores de los juegos). Si hay varias, una al azar.
static func evolve_for(sp: SpeciesData, level: int) -> SpeciesData:
	for step in 3:
		var options: Array[SpeciesData] = []
		for e: EvolutionData in sp.evolutions:
			if not DB.species.has(e.to_id) or DB.species[e.to_id].id in BANNED:
				continue
			var need: int = e.level if e.method == "nivel" else int(EVO_LEVEL.get(e.method, 30))
			if need > 0 and level >= need:
				options.append(DB.species[e.to_id])
		if options.is_empty():
			break
		sp = options[randi() % options.size()]
	return sp


## Brock: su equipo de roca, que crece y evoluciona con la copa (más Pokémon y más nivel).
func _brock(cup: TournamentCup, cap: int) -> Dictionary:
	var rocks := ["geodude", "onix", "sandshrew", "rhyhorn", "omanyte", "kabuto"]
	var mons := []
	for k in cup.team_size:
		var lvl := cap if rocks[k] == "onix" else maxi(2, cap - 1)
		mons.append([rocks[k] if rocks[k] == "onix" else evolve_for(DB.species[rocks[k]], lvl).id, lvl])
	return {"name": "Brock", "title": "Líder", "gfx": "brock", "team": mons,
		"pierde": "¡Tus Pokémon están cada vez más fuertes! Me voy a acordar de esta pelea."}


## Azul: su inicial (el que le gana al tuyo) y lo que atrapó.
func _rival(cup: TournamentCup, cap: int) -> Dictionary:
	var starter := "charmander"
	for sp in ["charmander", "squirtle", "bulbasaur"]:
		if GameState.has_flag("rival_" + sp):
			starter = sp
	var others := ["pidgey", "abra", "rhyhorn", "exeggcute", "growlithe"]  # (su equipo de FireRed)
	var mons := []
	for k in cup.team_size:
		var sp: String = starter if k == cup.team_size - 1 else others[k]
		mons.append([evolve_for(DB.species[sp], cap).id, cap])
	return {"name": "Azul", "title": "Rival", "gfx": "blue", "team": mons, "pierde": "¡¿Otra vez?! ¡La próxima no te escapás!"}


## La ronda siguiente: tu pelea ya la ganaste; las demás se definen por fuerza (nivel total) con algo de suerte.
func _next_round(field: Array) -> Array:
	var out: Array = []
	for i in range(0, field.size(), 2):
		var a = field[i]
		var b = field[i + 1]
		if str(a) == "jugador" or str(b) == "jugador":
			out.append("jugador")
			continue
		var pa := _power(a)
		var pb := _power(b)
		out.append(a if randf() < pa / (pa + pb) else b)
	return out


func _power(entry: Dictionary) -> float:
	var p := 0.0
	for m in entry["team"]:
		p += float(m[1])
	return p * (1.3 if entry["name"] in ["Brock", "Azul"] else 1.0)


func _team_of(entry: Dictionary) -> Array[CreatureInstance]:
	var out: Array[CreatureInstance] = []
	for m in entry["team"]:
		if DB.species.has(m[0]):
			out.append(CreatureInstance.create(DB.species[m[0]], m[1]))
	return out


func _texture(gfx: String) -> Texture2D:
	var path := "res://art/pret/characters/%s.png" % gfx
	return load(path) if ResourceLoader.exists(path) else null
