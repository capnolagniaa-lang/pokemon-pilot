class_name Tournament
extends Node
## Torneo de Ciudad Plateada (docs/PLAN_TORNEO.md, T-2): la recepcionista (acción "torneo") te deja elegir una copa
## (TournamentCup), inscribís a los primeros 3 o 6 Pokémon de tu equipo que no pasen el nivel de la copa (peleás con
## ellos tal cual), pagás la entrada y te dan 6 Pociones del torneo (tu Mochila queda guardada hasta que salís).
## Cuadro de 8 con eliminación directa: cuartos, semifinal y final en el estadio (arena_torneo). **No se cura entre
## rondas**: las 6 Pociones son para todo el torneo. Si ganás la final: el premio en dinero; si perdés una pelea,
## quedás afuera (la entrada no se devuelve). Al salir vuelven tu equipo completo y tu Mochila.
## Rivales: Brock y Azul (cuando ya los enfrentaste en la historia, o siempre en el modo libre) con su equipo, que
## crece según la copa, y entrenadores del torneo generados con Pokémon de la zona (cada uno con su kit).

const ROUNDS := ["CUARTOS DE FINAL", "SEMIFINAL", "FINAL"]
const POTIONS := 6
## Especies para los rivales generados (todas con kit: cada uno pelea distinto).
const POOL := ["pidgey", "rattata", "spearow", "caterpie", "weedle", "metapod", "kakuna", "mankey", "sandshrew",
	"pikachu", "oddish", "bellsprout", "paras", "psyduck", "poliwag", "growlithe", "vulpix", "eevee", "seel", "geodude"]
## [clase, sprite (art/pret/characters), nombres]
const CLASSES := [
	["Cazabichos", "bug_catcher", ["Nico", "Bruno", "Tiago"]],
	["Campista", "camper", ["Lucas", "Ramiro", "Gonzalo"]],
	["Chica", "lass", ["Sofía", "Martina", "Lola"]],
	["Joven", "youngster", ["Facu", "Lautaro", "Joaco"]],
	["Entrenadora Guay", "cooltrainer_f", ["Valentina", "Camila", "Abril"]],
	["Entrenador Guay", "cooltrainer_m", ["Mateo", "Santino", "Bauti"]],
	["Karateka", "black_belt", ["Hernán", "Kenji", "Dante"]],
	["Rockero", "rocker", ["Pity", "Rulo", "Chino"]],
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
		await world.story.dialog.say("Locutor", PackedStringArray(["¡%s! Te toca contra %s %s." % [
			ROUNDS[r].capitalize(), rival["title"], rival["name"]]]))
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
	while out.size() < 8:
		var cls: Array = CLASSES[randi() % CLASSES.size()]
		var nm: String = cls[2][randi() % cls[2].size()]
		if used.has(nm):
			continue
		used[nm] = true
		var mons := []
		for k in cup.team_size:
			mons.append([POOL[randi() % POOL.size()], clampi(cap - randi_range(0, 4), 2, 100)])
		out.append({"name": nm, "title": cls[0], "gfx": cls[1], "team": mons, "pierde": "¡Uh, me ganaste!"})
	var rest := out.slice(1)
	rest.shuffle()
	var me_at := randi() % 8
	rest.insert(me_at, "jugador")
	return rest


## Brock: su equipo de roca, que crece con la copa (más Pokémon y más nivel).
func _brock(cup: TournamentCup, cap: int) -> Dictionary:
	var rocks := ["geodude", "onix", "sandshrew", "rhyhorn", "omanyte", "kabuto"]
	if cap >= 25:
		rocks[0] = "graveler"
	var mons := []
	for k in cup.team_size:
		mons.append([rocks[k], cap if rocks[k] == "onix" else maxi(2, cap - 1)])
	return {"name": "Brock", "title": "Líder", "gfx": "brock", "team": mons,
		"pierde": "¡Tus Pokémon están cada vez más fuertes! Me voy a acordar de esta pelea."}


## Azul: su inicial (el que le gana al tuyo) y lo que atrapó.
func _rival(cup: TournamentCup, cap: int) -> Dictionary:
	var starter := "charmander"
	for sp in ["charmander", "squirtle", "bulbasaur"]:
		if GameState.has_flag("rival_" + sp):
			starter = sp
	var others := ["pidgey", "rattata", "spearow", "mankey", "pikachu"]
	var mons := []
	for k in cup.team_size:
		mons.append([starter if k == cup.team_size - 1 else others[k], cap])
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
