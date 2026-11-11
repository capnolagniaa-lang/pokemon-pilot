class_name RogueRun
extends Node
## Modo Desafío (roguelike estilo Hades, docs/PROPUESTA_ROGUELIKE.md; R-0, la rebanada vertical): desde el título elegís
## un Pokémon entre 3 y bajás por una cadena de salas (un piso: data/rogue/<piso>.json). En cada sala salen oleadas de
## salvajes; al debilitar a todos se abre la puerta de arriba y, caminando hasta ella con tu Pokémon, pasás a la
## siguiente. Después de la última sala, el jefe (una pelea de entrenador de las de siempre: TrainerBattle).
##  · Un solo Pokémon, a nivel fijo: si cae, se termina la partida (decisiones del usuario 2026-11-11).
##  · No toca la partida de la historia y no se guarda nada (GameState.rogue, como el modo de prueba del torneo).
##  · Manejás siempre a tu Pokémon (CombatDirector.arena_lock): el entrenador se queda en la entrada.
##  · Las salas son arenas pintadas (ArenaData + pintura de Qwen): `player_cell`/`player_mon_cell` = la entrada,
##    `foe_trainer_cell` = la puerta de salida, `field` = donde aparecen los enemigos.
## Todavía sin bendiciones, recompensas ni hub (R-1 en adelante).

signal finished(result: String)

const FLOOR_PATH := "res://data/rogue/bosque_verde.json"
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
const SELECT_SCENE := "res://scenes/ui/rogue_select.tscn"
## Las salas se cargan acá: lejos del mundo y de las arenas de TrainerBattle (el jefe usa la suya).
const ROOM_ORIGIN := Vector2(-80000, -40000)
## Pausa entre que cae el último de una oleada y sale la siguiente.
const WAVE_DELAY := 1.3
## Los enemigos aparecen al menos a esta distancia de tu Pokémon.
const SPAWN_MIN_DIST := 96.0
## A esta distancia de la puerta abierta pasás a la sala siguiente.
const DOOR_RADIUS := 20.0
const ENEMY_COLOR := Color(1.0, 0.4, 0.35)

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
var room: Zone
var room_data: ArenaData
## Los enemigos vivos de la oleada.
var foes: Array[Creature] = []
var door: RogueDoor
## Salas limpiadas en esta partida (para el cartel del final y el test).
var rooms_cleared := 0
var _label: Label
var _engage_in := 0.0
var _rng := RandomNumberGenerator.new()


# --- Armar la partida (desde el título) ---------------------------------------------------------------------------

static func load_floor() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(FLOOR_PATH))


## Los Pokémon que te ofrecen al empezar (al azar entre los del piso).
static func offer() -> Array[SpeciesData]:
	var f := load_floor()
	var ids: Array = f["starters"].filter(func(id): return DB.species.has(id))
	ids.shuffle()
	var out: Array[SpeciesData] = []
	for id in ids.slice(0, int(f["offer"])):
		out.append(DB.species[id])
	return out


## Deja el estado del juego listo para una partida del modo con ese Pokémon (equipo temporal; no se guarda nada). Después
## hay que cambiar a la escena del mundo: RogueRun arranca solo.
static func begin(sp: SpeciesData) -> void:
	var f := load_floor()
	GameState.new_game(sp)
	GameState.party.clear()
	GameState.party.append(CreatureInstance.create(sp, int(f["level"])))
	GameState.active_index = 0
	GameState.bag = {"pocion": int(f["potions"])}
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
	_run.call_deferred()


func _run() -> void:
	active = true
	result = ""
	rooms_cleared = 0
	await get_tree().process_frame
	var rooms: Array = floor_data["rooms"]
	for i in rooms.size():
		await _play_room(i)
		if result != "":
			break
	if result == "":
		await _play_boss()
	await _finish()


## Una sala: entrar, las oleadas, la puerta.
func _play_room(index: int) -> void:
	room_index = index
	wave_index = -1
	phase = ""
	var cfg: Dictionary = floor_data["rooms"][index]
	var total: int = floor_data["rooms"].size()
	_load_room(str(cfg["arena"]))
	_refresh_label()
	await get_tree().process_frame
	await world.arena.fade_to(0.0)
	await world.arena.banner("%s  ·  Sala %d de %d" % [str(floor_data["name"]).to_upper(), index + 1, total], str(cfg.get("name", "")), 1.4)
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
	_room_cleared(index == total - 1)
	phase = "puerta"
	_refresh_label()
	while not _at_door():
		if _player_down():  # (veneno, quemadura o el fuego del pasto después de la última oleada)
			result = "lose"
			phase = "fin"
			return
		await get_tree().physics_frame
	phase = ""
	await world.arena.fade_to(1.0)
	_unload_room()


## Sala limpia: recupera algo de vida y se abre la puerta de arriba.
func _room_cleared(last: bool) -> void:
	var c: Creature = world.companion
	var part := float(floor_data.get("heal_on_clear", 0.0))
	if is_instance_valid(c) and part > 0.0:
		c.health.heal(c.instance.max_hp() * part)
		Fx.burst(world.entities, c.global_position + Vector2(0, -8), Color(0.6, 1.4, 0.7), 12, 34.0)
	Events.camera_shake.emit(3.0)
	Events.message_requested.emit("¡Sala limpia! Se abrió el paso%s." % (" al " + str(floor_data["boss"]["door"]) if last else ""))
	door = RogueDoor.new()
	door.position = _cell_pos(room_data.foe_trainer_cell)
	door.text = str(floor_data["boss"]["door"]) if last else "Siguiente sala"
	world.entities.add_child(door)


func _at_door() -> bool:
	var c: Creature = world.companion
	return is_instance_valid(door) and is_instance_valid(c) and not c.is_down() \
		and c.global_position.distance_to(door.global_position) <= DOOR_RADIUS


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
	world.arena.set_black(true)  # (volvió al vacío donde estaba la última sala: no hay nada que mostrar)
	result = "win" if r == "win" else "lose"
	phase = "fin"


## Cartel del final y de vuelta: otra partida o el título.
func _finish() -> void:
	phase = "fin"
	active = false
	_label.visible = false
	if is_instance_valid(room):
		await world.arena.fade_to(1.0)
		_unload_room()
	world.trainer.locked = true
	var total: int = floor_data["rooms"].size()
	if result == "win":
		await world.arena.banner("¡DESAFÍO SUPERADO!", "%s: %d salas y %s" % [floor_data["name"], total, floor_data["boss"]["name"]], 2.4)
	else:
		await world.arena.banner("Tu Pokémon se debilitó...", "Llegaste hasta %s" % (
			str(floor_data["boss"]["name"]) if rooms_cleared >= total else "la sala %d de %d" % [mini(rooms_cleared + 1, total), total]), 2.4)
	finished.emit(result)
	var again: int = await world.story.dialog.ask("Modo Desafío", "¿Y ahora?", PackedStringArray(["Jugar otra vez", "Volver al título"]))
	GameState.rogue = {}
	get_tree().change_scene_to_file(SELECT_SCENE if again == 0 else TITLE_SCENE)


# --- Salas --------------------------------------------------------------------------------------------------------

func _load_room(arena_id: String) -> void:
	room_data = load("res://data/arenas/%s.tres" % arena_id)
	room = load(room_data.scene_path).instantiate()
	room.position = ROOM_ORIGIN
	world.get_node("YSort/Zones").add_child(room)
	ZoneBounds.seal(room)  # de la sala no se sale
	var decor := ArenaDecor.new()
	room.add_child(decor)
	decor.setup(room_data)
	world.reactions.register_zone(room)  # entorno reactivo y reglas de arena
	world.arena.host_room(room, room_data)
	_limit_camera(true)
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
	world.camera.snap()


func _unload_room() -> void:
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
	if is_instance_valid(room):
		world.reactions.unregister_zone(room)
		room.queue_free()
	room = null


## La cámara no muestra más allá de la pintura de la sala (la entrada y la puerta están pegadas al borde).
func _limit_camera(on: bool) -> void:
	var cam: Camera2D = world.camera
	var rect := Rect2(Vector2(-10000000, -10000000), Vector2(20000000, 20000000))
	if on and is_instance_valid(room):
		var used := room.ground.get_used_rect()
		rect = Rect2(room.global_position + Vector2(used.position * Zone.TILE), Vector2(used.size * Zone.TILE))
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
	if not active or phase != "oleada":
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
	if _label == null or room_index < 0:
		return
	var rooms: Array = floor_data["rooms"]
	var text := "%s  ·  Sala %d/%d" % [floor_data["name"], room_index + 1, rooms.size()]
	match phase:
		"oleada":
			text += "  ·  Oleada %d/%d  ·  Quedan %d" % [wave_index + 1, rooms[room_index]["waves"].size(), foes.size()]
		"puerta":
			text += "  ·  ¡Sala limpia! Andá a la puerta de arriba"
		"jefe":
			text = "%s  ·  %s %s" % [floor_data["name"], floor_data["boss"]["title"], floor_data["boss"]["name"]]
	_label.text = text
