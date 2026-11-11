class_name RogueRun
extends Node
## Modo Desafío (roguelike estilo Hades, docs/PROPUESTA_ROGUELIKE.md; R-0, la rebanada vertical): desde el título elegís
## un Pokémon entre 3 y bajás por una cadena de salas (data/rogue/desafio.json), cada una de un bioma al azar (plan_rooms). En cada sala salen oleadas de
## salvajes; al debilitar a todos se abre el portón de arriba y pasás caminando a la siguiente: **las salas están
## encadenadas** (pedido del usuario 2026-11-11: más grandes, encadenadas y con obstáculos), cargadas todas juntas una
## arriba de la otra, sin fundido entre ellas; al entrar a una, el portón se cierra detrás. Después de la última sala, la
## puerta del jefe (una pelea de entrenador de las de siempre: TrainerBattle).
##  · Un solo Pokémon, a nivel fijo: si cae, se termina la partida (decisiones del usuario 2026-11-11).
##  · No toca la partida de la historia y no se guarda nada (GameState.rogue, como el modo de prueba del torneo).
##  · Manejás siempre a tu Pokémon (CombatDirector.arena_lock); el entrenador lo sigue.
##  · Las salas son arenas pintadas (ArenaData + pintura de Qwen, con los obstáculos sacados de la pintura:
##    tools/paint_arenas.py, `auto_color`): `player_cell`/`player_mon_cell` = la entrada de la primera,
##    `foe_trainer_cell` = la puerta del jefe en la última, `field` = donde aparecen los enemigos. El paso de una sala a
##    otra es el hueco libre del medio de su primera y de su última fila (todas del mismo ancho).
## **El castillo de Mew** (pedido del usuario 2026-11-11): antes de la partida aparecés en un castillo pintado donde Mew
## te cuenta que Mewtwo corrompió el mundo; ahí elegís a tu Pokémon (de los desbloqueados) y el portal del fondo arranca
## la partida. `GameState.rogue["hub"]` = estás en el castillo (fase "castillo"); `enter_hub()` lo prepara desde el título.
## Todavía sin bendiciones ni recompensas (R-1 en adelante).

signal finished(result: String)

const FLOOR_PATH := "res://data/rogue/desafio.json"
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
const SELECT_SCENE := "res://scenes/ui/rogue_select.tscn"
const WORLD_SCENE := "res://scenes/world/world.tscn"
## Las salas se cargan acá: lejos del mundo y de las arenas de TrainerBattle (el jefe usa la suya).
const ROOM_ORIGIN := Vector2(-80000, -40000)
## Pausa entre que cae el último de una oleada y sale la siguiente.
const WAVE_DELAY := 1.3
## Los enemigos aparecen al menos a esta distancia de tu Pokémon.
const SPAWN_MIN_DIST := 96.0
## A esta distancia de la puerta abierta pasás a la sala siguiente.
const DOOR_RADIUS := 20.0
const ENEMY_COLOR := Color(1.0, 0.4, 0.35)
## Fila (desde arriba) del portón de salida de una sala, y fila (desde abajo) del que se cierra detrás tuyo al entrar.
const GATE_ROW := 1
const BACK_GATE_ROW := 2
## Entraste a una sala cuando tu Pokémon está a estas filas de su borde de abajo.
const ENTER_ROWS := 5
## Respiro entre que entrás a una sala y sale la primera oleada.
const ENTER_DELAY := 0.9
## El paso está en el medio: se buscan celdas libres hasta estas columnas del centro.
const OPENING_REACH := 6
## Si el entrenador quedó más lejos que esto de tu Pokémon (trabado en un obstáculo), aparece al lado.
const TRAINER_MAX_DIST := 300.0
## El castillo de Mew (ArenaData pintada; no se pelea: se camina).
const HUB_ARENA := "castillo_mew"
const HUB_ORIGIN := Vector2(-80000, -30000)
## Centro de la tarima redonda de abajo (px desde la esquina de la sala): ahí gira el portal. Se cruza pisándola.
const PORTAL_AT := Vector2(320, 362)
const PORTAL_STEP := Vector2(320, 364)
const PORTAL_RADIUS := 20.0
## Pie de la escalera a la planta alta (arriba, al medio): cerrada hasta avanzar en la historia del modo
## (RogueProgress, bandera STAIRS_FLAG; todavía no hay planta alta). Acercarse o apretar E ahí da el mensaje.
const STAIRS_AT := Vector2(320, 146)
const STAIRS_WIDTH := 76.0
const STAIRS_REACH := 22.0
const STAIRS_FLAG := "planta_alta"
const MEW_REACH := 34.0
const MEW_STORY: Array[String] = [
	"(Una voz suave te habla adentro de la cabeza.)",
	"Llegaste. Te estaba esperando.",
	"Soy Mew. Este castillo es el único lugar al que él todavía no llegó.",
	"Mewtwo, el Pokémon que crearon a partir de mí, se cansó de obedecer. Su mente cubrió el mundo entero y lo corrompió.",
	"Los Pokémon salvajes atacan a cualquiera que se les cruce. Y los entrenadores, hasta los líderes de gimnasio, pelean para él sin darse cuenta.",
	"Yo solo no puedo contra eso. Pero vos sí: del otro lado del portal está el mundo corrompido, y a cada entrenador que venzas lo vas a despertar.",
	"Si caés, te traigo de vuelta acá. Y a cada Pokémon que rescates con una Pokébola lo voy a cuidar en el castillo: la próxima vez vas a poder salir con él.",
	"Elegí a un compañero y pisá el portal de la tarima. El mundo te necesita.",
]

var world: Node
var floor_data: Dictionary = {}
## Jugando una partida del modo (de la primera sala al cartel del final).
var active := false
var room_index := -1
var wave_index := -1
## "" (cargando o entre salas), "oleada", "puerta", "jefe", "fin".
var phase := ""
## "" mientras se juega; al terminar "win" o "lose".
var result := ""
## La sala en la que estás (y su ArenaData).
var room: Zone
var room_data: ArenaData
## Todas las salas del piso, cargadas en fila (la primera abajo), y sus datos.
var chain: Array[Zone] = []
var chain_data: Array[ArenaData] = []
## Sala -> su portón de arriba (se abre al limpiarla).
var gates: Dictionary = {}
var _back_gate: RogueGate
var _boss_done := false
## Los enemigos vivos de la oleada.
var foes: Array[Creature] = []
var door: RogueDoor
## Salas limpiadas en esta partida (para el cartel del final y el test).
var rooms_cleared := 0
var _label: Label
var _engage_in := 0.0
## El castillo: la sala, Mew, el portal y la pantalla de elección (abierta o null).
var hub: Zone
var hub_data: ArenaData
var mew: PenPokemon
var portal: RoguePortal
var barrier: RogueBarrier
var select_layer: CanvasLayer
var _warned := 0.0
var _warned_stairs := 0.0
var _rng := RandomNumberGenerator.new()


# --- Armar la partida (desde el título) ---------------------------------------------------------------------------

static func load_floor() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(FLOOR_PATH))


## Los Pokémon que te ofrecen al empezar: de los desbloqueados (RogueProgress). Hasta `offer`, todos, en su orden; con
## más, esa cantidad al azar.
static func offer() -> Array[SpeciesData]:
	var f := load_floor()
	var ids: Array = RogueProgress.unlocked().filter(func(id): return DB.species.has(id))
	if ids.size() > int(f["offer"]):
		ids.shuffle()
	var out: Array[SpeciesData] = []
	for id in ids.slice(0, int(f["offer"])):
		out.append(DB.species[id])
	return out


## Las salas de una partida (pedido del usuario 2026-11-11: "cada sala que te toca tiene rng del bioma y los pokemon que
## aparecen ahí son característicos del bioma"): por cada casillero de `slots`, un bioma al azar (si se puede, distinto
## al de la sala anterior), una de sus arenas que no haya salido todavía y sus oleadas, con Pokémon de ese bioma y los
## niveles del casillero. `forced` = biomas elegidos a mano, uno por sala (tests). Devuelve, por sala:
## {arena, name, biome, biome_name, waves: [[[especie, nivel], ...], ...]}.
static func plan_rooms(f: Dictionary, rng: RandomNumberGenerator, forced: Array = []) -> Array:
	var out: Array = []
	var used := {}
	var last := ""
	var biomes: Dictionary = f["biomes"]
	for i in f["slots"].size():
		var slot: Dictionary = f["slots"][i]
		var free: Array = biomes.keys().filter(func(b): return biomes[b]["rooms"].any(func(a): return not used.has(a)))
		if free.is_empty():  # (más salas que arenas: se repite)
			used.clear()
			free = biomes.keys()
		var other: Array = free.filter(func(b): return b != last)
		var id: String = (other if not other.is_empty() else free)[rng.randi() % (other if not other.is_empty() else free).size()]
		if i < forced.size() and biomes.has(forced[i]):
			id = forced[i]
		var biome: Dictionary = biomes[id]
		var arenas: Array = biome["rooms"].filter(func(a): return not used.has(a))
		if arenas.is_empty():
			arenas = biome["rooms"]
		var arena: String = arenas[rng.randi() % arenas.size()]
		used[arena] = true
		last = id
		var data: ArenaData = load("res://data/arenas/%s.tres" % arena)
		var waves: Array = []
		var lo := int(slot["levels"][0])
		var hi := int(slot["levels"][1])
		for w in slot["waves"].size():
			var strong: bool = slot.get("strong_last", false) and w == slot["waves"].size() - 1
			var pool: Array = (biome["strong"] if strong else biome["common"]).filter(func(sp): return DB.species.has(sp))
			var wave: Array = []
			for n in int(slot["waves"][w]):
				wave.append([pool[rng.randi() % pool.size()], hi if strong else rng.randi_range(lo, hi)])
			waves.append(wave)
		out.append({"arena": arena, "name": data.display_name, "biome": id, "biome_name": str(biome["name"]), "waves": waves})
	return out


## Desde el título: deja el juego listo para aparecer en el castillo de Mew, sin Pokémon todavía (se elige ahí). Después
## hay que cambiar a la escena del mundo.
static func enter_hub() -> void:
	GameState.new_game(DB.species[RogueProgress.BASE[0]])
	GameState.party.clear()
	GameState.active_index = 0
	GameState.bag = {}
	GameState.money = 0
	GameState.wilds_enabled = false
	GameState.set_flag("tutorial_visto")
	GameState.rogue = {"hub": true}
	Events.party_changed.emit()


## Deja el estado del juego listo para una partida del modo con ese Pokémon (equipo temporal; no se guarda nada). Después
## hay que cambiar a la escena del mundo: RogueRun arranca solo.
static func begin(sp: SpeciesData) -> void:
	GameState.new_game(sp)
	equip(sp)


## El equipo y los ajustes de una partida del modo con ese Pokémon (sin reiniciar el juego: en el castillo ya está limpio).
static func equip(sp: SpeciesData) -> void:
	var f := load_floor()
	GameState.party.clear()
	GameState.party.append(CreatureInstance.create(sp, int(f["level"])))
	GameState.active_index = 0
	GameState.bag = {"pocion": int(f["potions"])}
	if int(f.get("balls", 0)) > 0:
		GameState.bag["poke_ball"] = int(f["balls"])
	GameState.selected_ball = "poke_ball"
	GameState.quick_item = "pocion"
	GameState.money = 0
	GameState.wilds_enabled = false
	GameState.set_flag("tutorial_visto")
	GameState.set_setting("exp_mult", float(DB.config.exp_multiplier) * float(f.get("exp_mult", 1.0)))  # (new_game dejó los ajustes de fábrica)
	for key: String in f.get("settings", {}):
		GameState.set_setting(key, f["settings"][key])
	GameState.rogue = {"species": sp.id}
	Events.party_changed.emit()


# --- La partida -----------------------------------------------------------------------------------------------

func _ready() -> void:
	world = get_parent()
	_rng.randomize()
	if GameState.rogue.is_empty():
		set_physics_process(false)
		return
	floor_data = load_floor()
	_build_label()
	world.arena.set_black(true)
	if GameState.rogue.get("hub", false):
		_hub.call_deferred()
	else:
		_run.call_deferred()


# --- El castillo de Mew ---------------------------------------------------------------------------------------------

## Aparecés en el castillo: caminás vos (sin pelea), Mew flota en el medio y el portal espera en el arco del fondo.
func _hub() -> void:
	phase = "castillo"
	await get_tree().process_frame
	hub_data = load("res://data/arenas/%s.tres" % HUB_ARENA)
	hub = load(hub_data.scene_path).instantiate()
	hub.position = HUB_ORIGIN
	world.get_node("YSort/Zones").add_child(hub)
	var decor := ArenaDecor.new()
	hub.add_child(decor)
	decor.setup(hub_data)
	world.arena.host_room(hub, hub_data)  # luz de arena pintada, sin minimapa
	_limit_camera(true, [hub])
	var t: Trainer = world.trainer
	t.autopilot = Vector2.ZERO
	t.follow_target = null
	t.locked = false
	t.global_position = _hub_pos(hub_data.player_cell)
	t.trail = [t.global_position]
	t.facing = Vector2.UP
	var spot := _hub_pos(hub_data.foe_mon_cell)
	mew = PenPokemon.make(DB.species["mew"], Rect2(spot - Vector2(14, 5), Vector2(28, 10)))
	mew.position = spot
	world.entities.add_child(mew)
	portal = RoguePortal.new()
	portal.position = hub.global_position + PORTAL_AT
	portal.lit = not GameState.party.is_empty()
	world.entities.add_child(portal)
	if not stairs_open():
		barrier = RogueBarrier.new()
		barrier.width = STAIRS_WIDTH
		barrier.position = hub.global_position + STAIRS_AT
		world.entities.add_child(barrier)
	world.camera.snap()
	_refresh_label()
	await get_tree().process_frame
	await world.arena.fade_to(0.0)
	if not RogueProgress.has_flag("intro") and phase == "castillo":
		await talk_to_mew()  # la primera vez te recibe él


func _hub_pos(cell: Vector2i) -> Vector2:
	return hub.to_global(hub.ground.map_to_local(cell))


func in_hub() -> bool:
	return phase == "castillo"


## ¿Estás al lado de Mew? (la E le habla)
func near_mew() -> bool:
	return in_hub() and is_instance_valid(mew) and world.trainer.global_position.distance_to(mew.global_position) <= MEW_REACH


## La escalera a la planta alta se abre al avanzar en la historia del modo (todavía no hay forma: queda la condición).
static func stairs_open() -> bool:
	return RogueProgress.has_flag(STAIRS_FLAG)


## ¿Estás al pie de la escalera?
func near_stairs() -> bool:
	if not in_hub() or not is_instance_valid(hub):
		return false
	var d: Vector2 = world.trainer.global_position - (hub.global_position + STAIRS_AT)
	return absf(d.x) <= STAIRS_WIDTH / 2.0 and d.y >= -8.0 and d.y <= STAIRS_REACH


func stairs_message() -> String:
	if stairs_open():
		return "La escalera está abierta, pero arriba todavía no hay nada."
	return "Mew: «Todavía no podés subir. La planta alta se va a abrir cuando avances del otro lado del portal.»"


## La E en el castillo (la llama PlayerItems): hablar con Mew si está cerca, o mirar la escalera.
func hub_interact() -> void:
	if world.story.busy or world.story.dialog.active or select_layer != null:
		return
	if near_mew():
		talk_to_mew()
	elif near_stairs():
		_warned_stairs = 3.0
		Events.message_requested.emit(stairs_message())


## Mew: la primera vez cuenta la historia entera; después, una línea (y la historia de nuevo si la pedís). Al final abre
## la elección del Pokémon.
func talk_to_mew() -> void:
	var story: StoryDirector = world.story
	story.lock()
	var d: DialogBox = story.dialog
	var first := not RogueProgress.has_flag("intro")
	var tell := first
	if not first:
		var pick: int = await d.ask("Mew", "¿Listo para cruzar? El portal te espera.", PackedStringArray(
			["Elegir a mi Pokémon", "Contame de nuevo qué pasó", "Nada"]))
		if pick == 2 or not in_hub():
			story.unlock()
			return
		tell = pick == 1
	if tell:
		await d.say("Mew", PackedStringArray(MEW_STORY))
		RogueProgress.set_flag("intro")
	if not in_hub():
		story.unlock()
		return
	open_select()


## La pantalla de elección (la misma de siempre, encima del castillo). Queda trabado el entrenador hasta cerrarla.
func open_select() -> void:
	close_select(false)
	world.story.lock()
	select_layer = CanvasLayer.new()
	select_layer.layer = 11
	add_child(select_layer)
	var screen: Control = load(SELECT_SCENE).instantiate()
	screen.hub = self
	select_layer.add_child(screen)


func close_select(unlock := true) -> void:
	if is_instance_valid(select_layer):
		select_layer.queue_free()
	select_layer = null
	if unlock:
		world.story.unlock()


## Elegiste (o cambiaste) a tu Pokémon: queda armada la partida y te sigue por el castillo; falta cruzar el portal.
func choose(sp: SpeciesData) -> void:
	var forced: Array = GameState.rogue.get("biomes", [])
	equip(sp)
	GameState.rogue["hub"] = true
	if not forced.is_empty():
		GameState.rogue["biomes"] = forced
	close_select()
	world.respawn_companion()
	if is_instance_valid(portal):
		portal.lit = true
	if is_instance_valid(world.companion):
		Fx.burst(world.entities, world.companion.global_position + Vector2(0, -8), Color(1.5, 1.0, 1.5), 14, 40.0)
	Events.message_requested.emit("%s va con vos. Cruzá el portal cuando quieras." % sp.display_name)
	_refresh_label()


## Pisaste delante del arco: con un Pokémon elegido, el portal te lleva a la primera sala; sin uno, Mew te frena.
func _hub_process(delta: float) -> void:
	_warned = maxf(0.0, _warned - delta)
	_warned_stairs = maxf(0.0, _warned_stairs - delta)
	if world.story.busy or world.story.dialog.active or select_layer != null or not is_instance_valid(hub):
		return
	var t: Trainer = world.trainer
	if near_stairs() and _warned_stairs <= 0.0 and t.global_position.y <= hub.global_position.y + STAIRS_AT.y + 10.0:
		_warned_stairs = 4.0  # (chocaste contra la barrera)
		Events.message_requested.emit(stairs_message())
	if t.global_position.distance_to(hub.global_position + PORTAL_STEP) > PORTAL_RADIUS:
		return
	if GameState.party.is_empty():
		if _warned <= 0.0:
			_warned = 3.0
			Events.message_requested.emit("Mew: «Solo no. Primero elegí a un compañero.»")
		return
	_depart()


func _depart() -> void:
	phase = ""
	var t: Trainer = world.trainer
	t.locked = true
	t.autopilot = Vector2.ZERO
	Events.camera_shake.emit(3.0)
	Fx.burst(world.entities, portal.global_position, Color(1.6, 0.9, 1.8), 26, 80.0)
	await world.arena.fade_to(1.0)
	_unload_hub()
	GameState.rogue.erase("hub")
	_run()


func _unload_hub() -> void:
	close_select(false)
	if is_instance_valid(mew):
		mew.queue_free()
	if is_instance_valid(portal):
		portal.queue_free()
	if is_instance_valid(barrier):
		barrier.queue_free()
	barrier = null
	mew = null
	portal = null
	world.arena.release_room()
	_limit_camera(false)
	if is_instance_valid(hub):
		hub.queue_free()
	hub = null


func _run() -> void:
	floor_data["rooms"] = plan_rooms(floor_data, _rng, GameState.rogue.get("biomes", []))
	active = true
	result = ""
	rooms_cleared = 0
	await get_tree().process_frame
	_load_chain()
	_enter_room(0)
	_place_at_start()
	_refresh_label()
	await get_tree().process_frame
	await world.arena.fade_to(0.0)
	var rooms: Array = floor_data["rooms"]
	for i in rooms.size():
		await _play_room(i)
		if result != "":
			break
	if result == "":
		await _play_boss()
	await _finish()


## Una sala: el cartel, las oleadas y, limpia, el paso a la siguiente (caminando) o la puerta del jefe (la última).
func _play_room(index: int) -> void:
	wave_index = -1
	phase = ""
	var cfg: Dictionary = floor_data["rooms"][index]
	var total: int = floor_data["rooms"].size()
	var last := index == total - 1
	_enter_room(index)
	_refresh_label()
	var title := "%s  ·  Sala %d de %d" % [str(cfg["biome_name"]).to_upper(), index + 1, total]
	if index == 0:
		await world.arena.banner(title, str(cfg.get("name", "")), 1.4)
	else:  # (venís caminando: el cartel no frena nada)
		world.arena.banner(title, str(cfg.get("name", "")), 1.2)
		await get_tree().create_timer(ENTER_DELAY).timeout
	var waves: Array = cfg["waves"]
	for w in waves.size():
		wave_index = w
		_spawn_wave(waves[w])
		phase = "oleada"
		_refresh_label()
		Events.message_requested.emit("¡Oleada %d de %d!" % [w + 1, waves.size()])
		while not _player_down() and not foes.is_empty():
			await get_tree().physics_frame
		if _player_down():
			result = "lose"
			phase = "fin"
			return
		phase = ""
		_refresh_label()
		await get_tree().create_timer(WAVE_DELAY).timeout
	rooms_cleared += 1
	_room_cleared(last)
	phase = "puerta"
	_refresh_label()
	while not (_at_door() if last else entered(index + 1)):
		if _player_down():  # (veneno, quemadura o el fuego del pasto después de la última oleada)
			result = "lose"
			phase = "fin"
			return
		await get_tree().physics_frame
	phase = ""
	if last:
		await world.arena.fade_to(1.0)
		world.arena.release_room()  # (el jefe arma su propia arena)
		_limit_camera(false)  # (su arena está en otro lado: con el límite de las salas la cámara se quedaba en el bosque)


## Sala limpia: recupera algo de vida y se abre el portón de arriba (en la última, la puerta al jefe).
func _room_cleared(last: bool) -> void:
	var c: Creature = world.companion
	var part := float(floor_data.get("heal_on_clear", 0.0))
	if is_instance_valid(c) and part > 0.0:
		c.health.heal(c.instance.max_hp() * part)
		Fx.burst(world.entities, c.global_position + Vector2(0, -8), Color(0.6, 1.4, 0.7), 12, 34.0)
	Events.camera_shake.emit(3.0)
	Events.message_requested.emit("¡Sala limpia! Se abrió el paso%s." % (" al " + str(floor_data["boss"]["door"]) if last else ""))
	if last:
		door = RogueDoor.new()
		door.position = _cell_pos(room_data.foe_trainer_cell)
		door.text = str(floor_data["boss"]["door"])
		world.entities.add_child(door)
	elif is_instance_valid(gates.get(room_index)):
		gates[room_index].open()


func _at_door() -> bool:
	var c: Creature = world.companion
	return is_instance_valid(door) and is_instance_valid(c) and not c.is_down() \
		and c.global_position.distance_to(door.global_position) <= DOOR_RADIUS


## Tu Pokémon ya pasó a la sala `index` (cruzó el paso y está unas celdas adentro).
func entered(index: int) -> bool:
	var c: Creature = world.companion
	if index >= chain.size() or not is_instance_valid(c) or c.is_down():
		return false
	return c.global_position.y < _row_y(chain[index], _rows(chain[index]) - ENTER_ROWS)


## Hacia dónde hay que ir con la sala limpia: el paso de arriba (o la puerta del jefe en la última). INF si no toca.
func exit_point() -> Vector2:
	if phase != "puerta" or not is_instance_valid(room):
		return Vector2.INF
	if is_instance_valid(door):
		return door.global_position
	var xs := _opening(room, 0)
	if xs.is_empty():
		return Vector2.INF
	return room.to_global(room.ground.map_to_local(Vector2i(xs[xs.size() / 2], 0)))


## El jefe del piso: una pelea de entrenador de las de siempre, en su arena (con su kit de jefe y su guion).
func _play_boss() -> void:
	phase = "jefe"
	_refresh_label()
	var boss: Dictionary = floor_data["boss"]
	var team: Array[CreatureInstance] = []
	for m in boss["team"]:
		if DB.species.has(m[0]):
			team.append(CreatureInstance.create_rival(DB.species[m[0]], int(m[1])))
	TrainerMovesets.equip_team(team, str(boss["name"]))
	var gfx := "res://art/pret/characters/%s.png" % boss["gfx"]
	var r: String = await world.arena.start({"name": boss["name"], "title": boss["title"], "team": team,
		"arena_id": boss["arena"], "texture": load(gfx) if ResourceLoader.exists(gfx) else null, "leader": true,
		"no_blackout": true, "trainer_ids": [str(boss.get("trainer_id", ""))], "vs": boss["gfx"],
		"vs_color": team[0].species.primary_type().color if not team.is_empty() else ENEMY_COLOR,
		"defeat_lines": PackedStringArray([str(boss.get("defeat", "¡Me ganaste!"))])})
	world.arena.set_black(true)  # (volvió a la última sala, ya vacía: no hay nada que mostrar)
	_boss_done = true
	result = "win" if r == "win" else "lose"
	phase = "fin"


## Cartel del final y de vuelta: otra partida o el título.
func _finish() -> void:
	phase = "fin"
	active = false
	_label.visible = false
	if not _boss_done:
		await world.arena.fade_to(1.0)
	_unload_chain()
	world.trainer.locked = true
	var total: int = floor_data["rooms"].size()
	if result == "win":
		await world.arena.banner("¡DESAFÍO SUPERADO!", "%d salas y %s" % [total, floor_data["boss"]["name"]], 2.4)
	else:
		await world.arena.banner("Tu Pokémon se debilitó...", "Llegaste hasta %s" % (
			str(floor_data["boss"]["name"]) if rooms_cleared >= total else "la sala %d de %d" % [mini(rooms_cleared + 1, total), total]), 2.4)
	finished.emit(result)
	var again: int = await world.story.dialog.ask("Modo Desafío", "¿Y ahora?", PackedStringArray(["Volver al castillo", "Volver al título"]))
	GameState.rogue = {}
	if again == 0:
		enter_hub()
		get_tree().change_scene_to_file(WORLD_SCENE)
	else:
		get_tree().change_scene_to_file(TITLE_SCENE)


# --- Salas encadenadas ----------------------------------------------------------------------------------------------

## Carga todas las salas del piso pegadas una arriba de la otra (la primera, abajo): el paso de arriba de cada una
## empalma con el de abajo de la siguiente. Cada paso arranca cerrado con un portón; los dos extremos, con una pared.
func _load_chain() -> void:
	var at := ROOM_ORIGIN
	var rooms: Array = floor_data["rooms"]
	for i in rooms.size():
		var data: ArenaData = load("res://data/arenas/%s.tres" % rooms[i]["arena"])
		var zone: Zone = load(data.scene_path).instantiate()
		var size := Vector2(zone.get_node("Ground").get_used_rect().end * Zone.TILE)
		at.y -= size.y
		zone.position = at
		world.get_node("YSort/Zones").add_child(zone)
		var decor := ArenaDecor.new()
		zone.add_child(decor)
		decor.setup(data)
		world.reactions.register_zone(zone)  # entorno reactivo y reglas de arena
		chain.append(zone)
		chain_data.append(data)
		if i < rooms.size() - 1:
			gates[i] = _gate(zone, GATE_ROW, true)
	_gate(chain[0], _rows(chain[0]) - 1, false)  # por la entrada no se sale
	_gate(chain[-1], 0, false)  # ni por arriba de la última (ahí está la puerta del jefe)
	_limit_camera(true)


## Pasás a la sala `index`: es la que cuenta para la luz y las reglas de arena, y el paso por el que viniste se cierra.
func _enter_room(index: int) -> void:
	if room_index == index and is_instance_valid(room):
		return
	room_index = index
	room = chain[index]
	room_data = chain_data[index]
	world.arena.host_room(room, room_data)
	if index == 0:
		return
	_back_gate = _gate(room, _rows(room) - BACK_GATE_ROW, true)
	Events.camera_shake.emit(2.0)
	var t: Trainer = world.trainer
	if is_instance_valid(world.companion) and t.global_position.y > _back_gate.global_position.y - 10.0:
		_bring_trainer()  # (venía atrás: que no quede del otro lado del portón)


## Vos y tu Pokémon en la entrada de la primera sala; desde ahí lo manejás a él y el entrenador lo sigue.
func _place_at_start() -> void:
	var t: Trainer = world.trainer
	t.autopilot = Vector2.ZERO
	t.global_position = _cell_pos(room_data.player_cell)
	t.trail = [t.global_position]
	if not is_instance_valid(world.companion) or world.companion.is_down():
		world.respawn_companion()
	var c: Creature = world.companion
	if not is_instance_valid(c):
		return
	c.global_position = _cell_pos(room_data.player_mon_cell)
	c.statuses.clear()
	world.combat.arena_lock = true
	if world.combat.in_battle:
		world.combat.take_control(c)
	else:
		world.combat.start_battle()
	t.follow_target = c  # (salas largas: te sigue, como fuera de las arenas)
	world.camera.snap()


func _bring_trainer() -> void:
	var t: Trainer = world.trainer
	t.global_position = world.companion.global_position + Vector2(0, 14)
	t.trail = [t.global_position]


func _unload_chain() -> void:
	for f in foes:
		if is_instance_valid(f):
			f.queue_free()
	foes.clear()
	world.combat.enemies.clear()
	if is_instance_valid(door):
		door.queue_free()
	door = null
	world.arena.release_room()
	_limit_camera(false)
	for zone in chain:
		if is_instance_valid(zone):
			world.reactions.unregister_zone(zone)
			zone.queue_free()  # (los portones son hijos de su sala)
	chain.clear()
	chain_data.clear()
	gates.clear()
	room = null


## Un portón (o una pared invisible) que tapa el paso de esa fila de la sala.
func _gate(zone: Zone, row: int, shown: bool) -> RogueGate:
	var xs := _opening(zone, row)
	var g := RogueGate.new()
	g.shown = shown
	if xs.is_empty():
		xs = [zone.ground.get_used_rect().end.x / 2]
	g.width = float(xs[-1] - xs[0] + 3) * Zone.TILE
	g.position = zone.ground.map_to_local(Vector2i(xs[0], row)) + Vector2(float(xs[-1] - xs[0]) * Zone.TILE / 2.0, 0)
	zone.add_child(g)
	return g


## Columnas libres de una fila de la sala (el paso, en las filas de arriba y de abajo).
func _opening(zone: Zone, row: int) -> Array[int]:
	var out: Array[int] = []
	var used := zone.ground.get_used_rect()
	var mid := used.end.x / 2
	for x in range(used.position.x, used.end.x):
		if MapRules.cell_physics(zone, Vector2i(x, row)) == -1 and absi(x - mid) <= OPENING_REACH:
			out.append(x)
	return out


func _rows(zone: Zone) -> int:
	return zone.ground.get_used_rect().end.y


## Altura (global) del centro de una fila de la sala.
func _row_y(zone: Zone, row: int) -> float:
	return zone.to_global(zone.ground.map_to_local(Vector2i(0, row))).y


## La cámara no muestra más allá de las pinturas de las salas.
func _limit_camera(on: bool, zones: Array = chain) -> void:
	var cam: Camera2D = world.camera
	var rect := Rect2(Vector2(-10000000, -10000000), Vector2(20000000, 20000000))
	if on and not zones.is_empty():
		rect = Rect2()
		for zone: Zone in zones:
			var used := zone.ground.get_used_rect()
			var r := Rect2(zone.global_position + Vector2(used.position * Zone.TILE), Vector2(used.size * Zone.TILE))
			rect = r if rect.size == Vector2.ZERO else rect.merge(r)
	cam.limit_left = int(rect.position.x)
	cam.limit_top = int(rect.position.y)
	cam.limit_right = int(rect.end.x)
	cam.limit_bottom = int(rect.end.y)


func _cell_pos(cell: Vector2i) -> Vector2:
	return room.to_global(room.ground.map_to_local(cell))


# --- Oleadas ------------------------------------------------------------------------------------------------------

## Saca una oleada: cada [especie, nivel] aparece en una celda libre de la sala, lejos de tu Pokémon, ya peleando.
func _spawn_wave(list: Array) -> void:
	var cells := spawn_cells()
	for m in list:
		if not DB.species.has(m[0]) or cells.is_empty():
			continue
		var cell: Vector2i = cells.pop_at(_rng.randi() % cells.size())
		var c: Creature = WildSpawner.CreatureScene.instantiate()
		c.instance = CreatureInstance.create_rival(DB.species[m[0]], int(m[1]))
		c.instance.roll_ivs()
		c.team = Creature.Team.WILD
		c.temperament = DB.temperaments.get("entrenador")  # pelean hasta el final: ni huyen ni sueltan la pelea
		c.position = _cell_pos(cell)
		world.entities.add_child(c)
		c.home = c.global_position
		foes.append(c)
		Fx.burst(world.entities, c.global_position, ENEMY_COLOR, 16, 55.0)
	_engage()


## Celdas donde puede aparecer un enemigo: piso libre de la cancha de la sala, lejos de tu Pokémon y separadas entre sí.
func spawn_cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var me: Vector2 = world.companion.global_position if is_instance_valid(world.companion) else Vector2.INF
	var f := room_data.field
	for y in range(f.position.y, f.end.y, 2):
		for x in range(f.position.x, f.end.x, 2):
			var cell := Vector2i(x, y)
			if MapRules.cell_physics(room, cell) == -1 and _cell_pos(cell).distance_to(me) >= SPAWN_MIN_DIST:
				out.append(cell)
	return out


## Los de la oleada apuntan a tu Pokémon y entran en la lista de enemigos del combate (también si alguno la soltó).
func _engage() -> void:
	var c: Creature = world.companion
	if not is_instance_valid(c) or c.is_down():
		return
	for f in foes:
		if not is_instance_valid(f) or f.is_down():
			continue
		if f.target != c:
			f.target = c
		if not world.combat.enemies.has(f):
			world.combat.enemies.append(f)
		if f.machine.current_name() in ["wander", "watch", "idle"]:
			f.machine.transition_to("chase")


func _physics_process(delta: float) -> void:
	if phase == "castillo":
		_hub_process(delta)
	if not active:
		return
	var c: Creature = world.companion
	if phase in ["oleada", "puerta", ""] and is_instance_valid(c) and not c.is_down() and not chain.is_empty() \
			and world.trainer.global_position.distance_to(c.global_position) > TRAINER_MAX_DIST:
		_bring_trainer()
	if phase != "oleada":
		return
	foes = foes.filter(func(f): return is_instance_valid(f) and not f.is_down())
	_engage_in -= delta
	if _engage_in <= 0.0:
		_engage_in = 0.5
		_engage()
		_refresh_label()


func _player_down() -> bool:
	return not is_instance_valid(world.companion) or world.companion.is_down()


# --- Cartel de arriba ---------------------------------------------------------------------------------------------

func _build_label() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 8  # debajo del fundido de TrainerBattle (9)
	add_child(layer)
	_label = UiStyle.label("", 18, UiStyle.ACCENT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(0, 10)
	_label.size = Vector2(1280, 26)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("outline_size", 6)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_label)


func _refresh_label() -> void:
	if _label != null and phase == "castillo":
		_label.visible = true
		_label.text = "Castillo de Mew  ·  %s" % ("Hablá con Mew (%s) para elegir a tu Pokémon" % Controls.label("capture")
			if GameState.party.is_empty() else "Pisá el portal de la tarima para empezar")
		return
	if _label == null or room_index < 0:
		return
	var rooms: Array = floor_data["rooms"]
	var text := "%s  ·  Sala %d/%d  ·  Bolas: %d" % [rooms[room_index]["biome_name"], room_index + 1, rooms.size(), GameState.item_count("poke_ball")]
	match phase:
		"oleada":
			text += "  ·  Oleada %d/%d  ·  Quedan %d" % [wave_index + 1, rooms[room_index]["waves"].size(), foes.size()]
		"puerta":
			text += "  ·  ¡Sala limpia! Seguí por el camino de arriba"
		"jefe":
			text = "%s  ·  %s %s" % [floor_data["name"], floor_data["boss"]["title"], floor_data["boss"]["name"]]
	_label.text = text
