class_name RogueTests
extends Node
## Autotest del Modo Desafío (roguelike, docs/PROPUESTA_ROGUELIKE.md): desbloqueos, las 2 Pokébolas, y un bot completa
## las salas y llega a Brock.   godot --headless --path . --quit-after 400000 -- --autotest-rogue-rooms
## Vitrina (la elección y las 3 salas con el bot peleando):
##   godot --path . --quit-after 1500 --write-movie out/f.png --fixed-fps 30 -- --showcase-rogue

var autotest: Node
var world: Node
var answers: Array = []
## El bot juega al azar: si cae, prueba de nuevo (hasta estos intentos).
const ATTEMPTS := 4


## El bot de siempre, que además elige ataques de daño, toma la Poción con poca vida y, con la sala limpia, camina
## hasta el paso de arriba (o la puerta del jefe) rodeando los obstáculos, y sigue hasta entrar a la sala siguiente.
class RogueBot extends BotCombatInput:
	var _grid: AStarGrid2D
	var _grid_room: Zone

	func move_dir(actor: Creature) -> Vector2:
		var run: RogueRun = world.rogue
		var goal: Vector2 = run.exit_point()
		if world.combat.enemies.is_empty() and goal != Vector2.INF:
			return _walk(actor, run.room, goal, not is_instance_valid(run.door))
		if actor.health.ratio() < 0.45 and GameState.item_count("pocion") > 0:
			world.items.use_quick_item()
		return super(actor)

	## Un paso del camino por celdas hasta `goal`; con `through`, al llegar sigue derecho para arriba (el paso a la otra sala).
	func _walk(actor: Creature, zone: Zone, goal: Vector2, through: bool) -> Vector2:
		if zone != _grid_room:
			_grid_room = zone
			_grid = AStarGrid2D.new()
			_grid.region = zone.ground.get_used_rect()
			_grid.cell_size = Vector2(Zone.TILE, Zone.TILE)
			_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
			_grid.update()
			for cell in zone.ground.get_used_cells():
				if MapRules.cell_physics(zone, cell) != -1:
					_grid.set_point_solid(cell, true)
		var from: Vector2i = zone.ground.local_to_map(zone.to_local(actor.global_position))
		var to: Vector2i = zone.ground.local_to_map(zone.to_local(goal))
		if through and (from.y <= to.y + 1 or not _grid.is_in_boundsv(from)):
			return Vector2.UP
		if not _grid.is_in_boundsv(from) or from == to:
			return (goal - actor.global_position).normalized()
		var path := _grid.get_id_path(from, to)
		if path.size() < 2:
			return (goal - actor.global_position).normalized()
		var next: Vector2 = zone.to_global(zone.ground.map_to_local(path[1]))
		return (next - actor.global_position).normalized()

	## Como una persona: tira los ataques que hacen daño (no gasta la barra en Látigo o Refugio) y que puede pagar.
	func wants_slot(slot: int) -> bool:
		var now := Time.get_ticks_msec() / 1000.0
		if now - _choice_time > 0.35:
			_choice_time = now
			_choice = -1
			var c: Creature = world.companion
			if is_instance_valid(c):
				var good: Array[int] = []
				for i in c.moves.moves.size():
					var m: MoveData = c.moves.moves[i]
					if m != null and m.category != MoveData.Category.STATUS and m.power > 0.0 and c.moves.has_pp(i):
						good.append(i)
				if not good.is_empty():
					_choice = good[randi() % good.size()]
		return slot == _choice


func run() -> void:
	var r := {}
	var saves_before := _save_times()
	var slot_before := SaveManager.slot_path
	var f := RogueRun.load_floor()
	var rooms: Array = f["slots"]  # (después, las salas que le tocaron a la partida)
	# El progreso del modo (desbloqueos) va a un archivo de prueba: el de verdad no se toca.
	var real_before := FileAccess.get_file_as_string(RogueProgress.DEFAULT_PATH) if FileAccess.file_exists(RogueProgress.DEFAULT_PATH) else ""
	DirAccess.remove_absolute(RogueProgress.TEST_PATH)
	r["La partida tiene 5 salas antes del jefe"] = rooms.size() == 5
	_check_plans(f, r)
	await _check_arenas(f, r)

	# --- El título y la elección ---
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var title: Control = load("res://scenes/ui/title_screen.tscn").instantiate()
	layer.add_child(title)
	await get_tree().process_frame
	r["El título tiene el botón \"Modo Desafío\""] = title.find_children("*", "Button", true, false).any(func(b): return b.text == "Modo Desafío")
	title.queue_free()
	var select: Control = load("res://scenes/ui/rogue_select.tscn").instantiate()
	layer.add_child(select)
	await get_tree().process_frame
	var ids: Array = select.options.map(func(s): return s.id)
	var distinct := {}
	for id in ids:
		distinct[id] = true
	r["De entrada te ofrece a Charmander, Squirtle y Bulbasaur (%s)" % ", ".join(ids)] = select.cards.size() == 3 \
		and ids == ["charmander", "squirtle", "bulbasaur"]
	r["Con solo 3 desbloqueados no hay \"Otros tres\""] = not select.find_children("*", "Button", true, false).any(func(b): return b.text == "Otros tres")
	layer.queue_free()

	# --- Empezar: equipo temporal, nada de la historia ---
	RogueRun.begin(DB.species["squirtle"])
	GameState.rogue["biomes"] = BOT_BIOMES
	var mine: CreatureInstance = GameState.active()
	r["Arrancás con un solo Pokémon de Nv. %d, %d Pociones y 2 Pokébolas" % [f["level"], f["potions"]]] = GameState.party.size() == 1 \
		and mine.level == int(f["level"]) and GameState.bag == {"pocion": int(f["potions"]), "poke_ball": 2} and not GameState.rogue.is_empty()
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	var run: RogueRun = world.rogue
	rooms = run.floor_data["rooms"]
	r["Las salas le tocaron de los biomas pedidos (%s)" % ", ".join(rooms.map(func(x): return x["arena"]))] = \
		rooms.map(func(x): return x["biome"]) == BOT_BIOMES
	_dialogs()
	var bot := RogueBot.new(world)
	bot.keep_distance = 70.0
	world.combat.input_source = bot
	world.companion.input_source = bot
	SaveManager.slot_path = "user://saves/autotest_desafio.json"
	r["En el Modo Desafío no se guarda"] = not SaveManager.save_game() and not FileAccess.file_exists("user://saves/autotest_desafio.json")
	SaveManager.slot_path = slot_before
	r["Sin tutorial ni salvajes del mundo"] = not world.pause_menu.is_open() and not GameState.wilds_enabled
	var stacked := true
	for i in range(1, run.chain.size()):
		if run.chain[i].global_position.y >= run.chain[i - 1].global_position.y:
			stacked = false
	r["Las %d salas están cargadas en cadena, una arriba de la otra, con sus portones cerrados" % rooms.size()] = run.chain.size() == rooms.size() \
		and stacked \
		and run.gates.size() == rooms.size() - 1 and run.gates.values().all(func(g): return is_instance_valid(g))
	r["La sala 1 es una arena pintada (%d × %d celdas)" % [run.room.ground.get_used_rect().size.x, run.room.ground.get_used_rect().size.y]] = \
		run.room_data.id == rooms[0]["arena"] and run.room_data.painting != null and world.arena.active and world.combat.arena_lock \
		and run.room.ground.get_used_rect().size.x >= 60
	var solid_inside := 0
	var fr: Rect2i = run.room_data.field
	for y in range(fr.position.y, fr.end.y):
		for x in range(fr.position.x, fr.end.x):
			if MapRules.cell_physics(run.room, Vector2i(x, y)) != -1:
				solid_inside += 1
	r["Hay obstáculos adentro de la sala (%d celdas que chocan)" % solid_inside] = solid_inside >= 30
	r["Manejás a tu Pokémon y el entrenador lo sigue"] = world.companion.player_controlled and world.trainer.locked \
		and world.camera.target == world.companion and world.trainer.follow_target == world.companion
	r["La primera oleada sale entera, lejos tuyo y ya peleando"] = run.foes.size() == rooms[0]["waves"][0].size() \
		and run.foes.all(_spawned_ok.bind(run))
	r["Con enemigos vivos el portón está cerrado"] = is_instance_valid(run.gates[0])

	# --- Las 2 Pokébolas: cada una es un tiro; atrapar desbloquea la especie como inicial ---
	var waves_seen := {"0:0": run.foes.size()}  # "sala:oleada" -> cuántos salieron
	var tr: Trainer = world.trainer
	var b1: BallThrow = world.items.throw_ball(tr.global_position + Vector2(40, -30))
	await _until(func(): return not is_instance_valid(b1) or b1.result != "", 5.0)
	await get_tree().create_timer(0.6).timeout
	r["Una bola errada se pierde: no queda en el piso y te queda 1"] = get_tree().get_nodes_in_group("field_items").is_empty() \
		and GameState.item_count("poke_ball") == 1
	await _until(func(): return not run.foes.is_empty(), 10.0)
	var prey: Creature = run.foes[0]
	var prey_id: String = prey.instance.species.id
	var foes_before := run.foes.size()
	GameState.set_setting("catch_mult", 100000.0)  # (para el test: que esta entre seguro; la fórmula es la de siempre)
	world.items._cooldown = 0.0
	prey.global_position = tr.global_position + Vector2(36, 0)
	var b2: BallThrow = world.items.throw_ball(prey.global_position)
	var caught := [false]
	if b2 != null:
		b2.finished.connect(func(res: String): caught[0] = res == "caught")
	var spot: Vector2 = prey.global_position
	var wait := 0.0
	while wait < 8.0 and is_instance_valid(b2) and b2.result == "":
		if is_instance_valid(prey) and prey.visible:
			prey.global_position = spot  # (que no se corra mientras vuela la bola)
			prey.health.heal(9999.0)
		await get_tree().physics_frame
		wait += get_physics_process_delta_time()
	GameState.set_setting("catch_mult", 1.0)
	await get_tree().create_timer(0.3).timeout
	r["Atrapar a un salvaje (%s) lo desbloquea como inicial y se guarda aparte" % prey_id] = RogueProgress.is_unlocked(prey_id) \
		and FileAccess.file_exists(RogueProgress.TEST_PATH) and RogueProgress.path() == RogueProgress.TEST_PATH
	r["En esa partida seguís con tu único Pokémon y el atrapado ya no está en la sala"] = GameState.party.size() == 1 and GameState.box.is_empty() \
		and (not is_instance_valid(prey) or prey.is_queued_for_deletion()) and foes_before >= 1
	world.items._cooldown = 0.0
	r["Sin bolas no hay tercer tiro"] = GameState.item_count("poke_ball") == 0 and world.items.throw_ball(tr.global_position + Vector2(30, 0)) == null
	var offered: Array = RogueRun.offer().map(func(s): return s.id)
	r["El progreso se lee del archivo: ahora hay 4 y te ofrece 3 de ellos"] = RogueProgress.unlocked() == ["charmander", "squirtle", "bulbasaur", prey_id] \
		and offered.size() == 3 and offered.all(func(id): return RogueProgress.is_unlocked(id))

	# --- El bot juega las salas ---
	var door_early := false
	var faded := false
	var closed_behind := 0
	var seen_room := 0
	var healed := false
	var hp_low := 0.0
	var last_phase := ""
	var level0 := mine.level
	var t := 0.0
	var attempt := 1
	while true:
		t = 0.0
		while t < 600.0 and run.result == "" and run.phase != "jefe":
			await _bot_frame(run, mine, bot, waves_seen)
			if run.phase == "oleada":
				if is_instance_valid(run.door) or (run.gates.has(run.room_index) and not is_instance_valid(run.gates[run.room_index])):
					door_early = true
				hp_low = mine.hp
			if run.rooms_cleared < rooms.size() and world.arena._fade.color.a > 0.05:
				if not faded:
					print("[desafio]       (fundido en la sala %d, fase '%s')" % [run.room_index + 1, run.phase])
				faded = true  # (entre sala y sala no hay fundido: solo al ir al jefe, con las 3 limpias)
			if run.room_index != seen_room:
				seen_room = run.room_index
				if is_instance_valid(run._back_gate) and world.companion.global_position.y < run._back_gate.global_position.y:
					closed_behind += 1
			if run.phase == "puerta" and last_phase != "puerta" and mine.hp > hp_low:
				healed = true
			last_phase = run.phase
			t += get_physics_process_delta_time()
		if run.result != "lose" or attempt >= ATTEMPTS:
			break
		# El bot juega al azar y a veces cae (como cualquiera): prueba de nuevo desde el principio, como haría una persona.
		print("[desafio]       (intento %d: el bot cayó en la sala %d; va de nuevo)" % [attempt, run.room_index + 1])
		attempt += 1
		answers = [0]  # "Jugar otra vez"
		await _until(func(): return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("rogue_select.tscn"), 30.0)
		RogueRun.begin(DB.species["squirtle"])
		GameState.rogue["biomes"] = BOT_BIOMES
		mine = GameState.active()
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")
		await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
		run = world.rogue
		rooms = run.floor_data["rooms"]
		_dialogs()
		bot = RogueBot.new(world)
		bot.keep_distance = 70.0
		world.combat.input_source = bot
		waves_seen.clear()
		last_phase = ""
		faded = false
		closed_behind = 0
		seen_room = 0
	var all_waves := true
	for i in rooms.size():
		for w in rooms[i]["waves"].size():
			if waves_seen.get("%d:%d" % [i, w], 0) != rooms[i]["waves"][w].size():
				all_waves = false
	r["El bot limpia las salas (%d de %d en %d s; vida %d %%; intento %d de %d)" % [run.rooms_cleared, rooms.size(), int(t),
		int(100.0 * mine.hp / mine.max_hp()), attempt, ATTEMPTS]] = run.rooms_cleared == rooms.size() and run.result == ""
	r["Salieron todas las oleadas de cada sala, completas"] = all_waves
	r["El portón (y la puerta del jefe) se abren recién con la sala limpia"] = not door_early
	r["Se pasa de una sala a la otra caminando, sin fundido"] = not faded
	r["Al entrar a una sala el portón se cierra detrás (%d de %d)" % [closed_behind, rooms.size() - 1]] = closed_behind == rooms.size() - 1
	r["Limpiar una sala cura un poco"] = healed
	r["Los salvajes dan EXP (Nv. %d → %d)" % [level0, mine.level]] = mine.level > level0

	# --- El jefe: Brock, en su gimnasio, con Onix de jefe ---
	await _until(func(): return world.arena._fighting or run.result != "", 25.0)
	r["Después de la última sala: el Líder Brock en su gimnasio"] = world.arena._fighting and world.arena.foe_name == f["boss"]["name"] \
		and world.arena.arena_data.id == f["boss"]["arena"] and world.arena.leader
	await get_tree().create_timer(0.5).timeout
	world.camera.force_update_scroll()
	var cam_off: float = world.camera.get_screen_center_position().distance_to(world.companion.global_position)
	r["La cámara está en el gimnasio, sobre tu Pokémon (a %d px)" % int(cam_off)] = cam_off < 220.0
	var boss_onix := false
	var guard := 0.0
	while world.arena.active and world.arena.result == "" and guard < 60.0:
		await _until(func(): return not world.arena.active or (is_instance_valid(world.arena.foe) and not world.arena.foe.is_down()), 6.0)
		if is_instance_valid(world.arena.foe):
			if world.arena.foe.instance.species.id == "onix" and world.arena.foe.instance.boss:
				boss_onix = true
			world.arena.foe.health.apply_damage(99999.0)
		await get_tree().create_timer(0.3).timeout
		guard += 0.3
	r["Su Onix sale como jefe"] = boss_onix
	answers = [1]  # "Volver al título"
	await _until(func(): return run.result != "", 30.0)
	r["Ganarle a Brock = desafío superado"] = run.result == "win"
	await _until(func(): return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("title_screen.tscn"), 30.0)
	r["Al terminar volvés al título y el modo queda apagado"] = get_tree().current_scene != null \
		and get_tree().current_scene.scene_file_path.ends_with("title_screen.tscn") and GameState.rogue.is_empty()

	# --- Perder: si tu Pokémon cae, se termina ---
	RogueRun.begin(DB.species["pidgey"])
	var mixed := ["cementerio", "hielo", "costa", "volcan", "cueva"]
	GameState.rogue["biomes"] = mixed
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	run = world.rogue
	var pool: Array = f["biomes"]["cementerio"]["common"]
	r["Una partida con 5 biomas distintos: se cargan en cadena y la primera oleada es del Cementerio (%s)" % ", ".join(
		run.foes.map(func(e): return e.instance.species.id))] = run.chain.size() == 5 \
		and run.floor_data["rooms"].map(func(x): return x["biome"]) == mixed \
		and run.foes.all(func(e): return e.instance.species.id in pool) and "Cementerio" in run._label.text
	_dialogs()
	answers = [0]  # "Jugar otra vez"
	world.companion.health.apply_damage(99999.0)
	await _until(func(): return run.result != "", 10.0)
	r["Si tu Pokémon se debilita, se termina la partida"] = run.result == "lose" and run.rooms_cleared == 0
	await _until(func(): return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("rogue_select.tscn"), 30.0)
	r["\"Jugar otra vez\" te lleva a elegir de nuevo"] = get_tree().current_scene != null \
		and get_tree().current_scene.scene_file_path.ends_with("rogue_select.tscn")
	await get_tree().process_frame
	r["Con más de 3 desbloqueados aparece \"Otros tres\""] = get_tree().current_scene.find_children("*", "Button", true, false).any(
		func(b): return b.text == "Otros tres")
	DirAccess.remove_absolute(RogueProgress.TEST_PATH)
	r["El progreso de verdad del modo no se tocó"] = real_before == (FileAccess.get_file_as_string(RogueProgress.DEFAULT_PATH) if FileAccess.file_exists(RogueProgress.DEFAULT_PATH) else "")
	var saves_after := _save_times()
	var untouched := SaveManager.slot_path == slot_before
	for file: String in saves_before:  # (otras pruebas corriendo a la vez crean y borran las suyas: se miran las que ya estaban)
		if saves_after.has(file) and saves_after[file] != saves_before[file]:
			untouched = false
	r["No se tocó ninguna partida guardada"] = untouched

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[desafio] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-rooms] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Los biomas de la partida del bot (fijos, para que el test sea parejo): mezcla salas de biomas distintos en la cadena.
const BOT_BIOMES := ["bosque", "volcan", "cueva", "volcan", "cueva"]


## Las salas de una partida salen al azar por bioma: 300 partidas armadas.
func _check_plans(f: Dictionary, r: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var ok_size := true
	var ok_unique := true
	var ok_change := true
	var ok_species := true
	var ok_levels := true
	var ok_strong := true
	var seen := {}
	for n in 300:
		var plan: Array = RogueRun.plan_rooms(f, rng)
		ok_size = ok_size and plan.size() == f["slots"].size()
		var arenas := {}
		for i in plan.size():
			var room: Dictionary = plan[i]
			var biome: Dictionary = f["biomes"][room["biome"]]
			var slot: Dictionary = f["slots"][i]
			seen[room["biome"]] = true
			arenas[room["arena"]] = true
			ok_unique = ok_unique and room["arena"] in biome["rooms"]
			if i > 0 and plan[i - 1]["biome"] == room["biome"]:
				ok_change = false
			ok_size = ok_size and room["waves"].size() == slot["waves"].size()
			for w in room["waves"].size():
				var strong: bool = slot.get("strong_last", false) and w == room["waves"].size() - 1
				ok_size = ok_size and room["waves"][w].size() == int(slot["waves"][w])
				for m in room["waves"][w]:
					if not (m[0] in (biome["strong"] if strong else biome["common"])) or not DB.species.has(m[0]):
						ok_species = false
					if int(m[1]) < int(slot["levels"][0]) or int(m[1]) > int(slot["levels"][1]):
						ok_levels = false
					if strong and int(m[1]) != int(slot["levels"][1]):
						ok_strong = false
		ok_unique = ok_unique and arenas.size() == plan.size()
	r["Hay %d biomas y en 300 partidas salen todos (%s)" % [f["biomes"].size(), ", ".join(seen.keys())]] = f["biomes"].size() >= 6 \
		and seen.size() == f["biomes"].size()
	r["Cada partida: 5 salas con las oleadas de su casillero"] = ok_size
	r["No se repite una sala en la misma partida y cada una es de su bioma"] = ok_unique
	r["Dos salas seguidas no son del mismo bioma"] = ok_change
	r["Los Pokémon de cada sala son los de su bioma"] = ok_species
	r["Los niveles suben con la posición de la sala"] = ok_levels
	r["La última oleada de las salas finales es de los fuertes del bioma"] = ok_strong
	var all_species := true
	for b: String in f["biomes"]:
		for id in f["biomes"][b]["common"] + f["biomes"][b]["strong"]:
			if not DB.species.has(id):
				all_species = false
	r["Todas las especies de los biomas existen"] = all_species


## Cada arena de cada bioma sirve para encadenar: mismo ancho, pintada, con el paso en el medio de arriba y de abajo,
## camino de un paso al otro y lugar para que salgan los enemigos.
func _check_arenas(f: Dictionary, r: Dictionary) -> void:
	var bad: Array[String] = []
	var count := 0
	var width := -1
	for b: String in f["biomes"]:
		for id: String in f["biomes"][b]["rooms"]:
			count += 1
			var data: ArenaData = load("res://data/arenas/%s.tres" % id)
			var zone: Zone = load(data.scene_path).instantiate()
			zone.position = Vector2(-300000, -300000)
			add_child(zone)
			await get_tree().physics_frame
			var used: Rect2i = zone.ground.get_used_rect()
			if width < 0:
				width = used.size.x
			var top: Array[int] = []
			var bottom: Array[int] = []
			var grid := AStarGrid2D.new()
			grid.region = used
			grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
			grid.update()
			var mid := used.end.x / 2
			for cell in zone.ground.get_used_cells():
				var free := MapRules.cell_physics(zone, cell) == -1
				grid.set_point_solid(cell, not free)
				if free and absi(cell.x - mid) <= RogueRun.OPENING_REACH:
					if cell.y == 0:
						top.append(cell.x)
					elif cell.y == used.end.y - 1:
						bottom.append(cell.x)
			var spawn := 0
			var fr: Rect2i = data.field
			for y in range(fr.position.y, fr.end.y, 2):
				for x in range(fr.position.x, fr.end.x, 2):
					if MapRules.cell_physics(zone, Vector2i(x, y)) == -1:
						spawn += 1
			var why := ""
			if used.size.x != width:
				why = "ancho %d" % used.size.x
			elif data.painting == null:
				why = "sin pintura"
			elif top.size() < 2 or bottom.size() < 2:
				why = "sin paso (arriba %d, abajo %d)" % [top.size(), bottom.size()]
			elif not top.has(mid) or not bottom.has(mid):
				why = "el paso no está en el medio"
			elif grid.get_id_path(Vector2i(mid, used.end.y - 1), Vector2i(mid, 0)).is_empty():
				why = "no hay camino de abajo a arriba"
			elif MapRules.cell_physics(zone, data.player_mon_cell) != -1 or MapRules.cell_physics(zone, data.player_cell) != -1 \
					or MapRules.cell_physics(zone, data.foe_trainer_cell) != -1:
				why = "la entrada o la puerta del jefe caen en algo sólido"
			elif spawn < 60:
				why = "poco lugar para los enemigos (%d)" % spawn
			if why != "":
				bad.append("%s: %s" % [id, why])
			zone.queue_free()
	r["Las %d arenas de los biomas sirven para encadenar (mismo ancho, paso en el medio, camino, lugar)%s" % [count,
		"" if bad.is_empty() else " — " + "; ".join(bad)]] = bad.is_empty() and count >= 18


## Un cuadro del bot en las salas: anota cuántos salieron en cada oleada y le devuelve el control si cambió de cuerpo.
func _bot_frame(run: RogueRun, mine: CreatureInstance, bot: BotCombatInput, waves_seen: Dictionary) -> void:
	if run.phase == "oleada":
		var key := "%d:%d" % [run.room_index, run.wave_index]
		waves_seen[key] = maxi(waves_seen.get(key, 0), run.foes.size())
	if "--rogue-log" in OS.get_cmdline_user_args() and Engine.get_physics_frames() % 300 == 0 and is_instance_valid(world.companion):
		print("  sala %d oleada %d %s · yo %d%% PP %d · %s" % [run.room_index + 1, run.wave_index + 1, run.phase,
			int(100.0 * mine.hp / mine.max_hp()), int(world.companion.moves.pp()), ", ".join(run.foes.map(func(e): return "%s %d%%" % [
			e.instance.species.id, int(100.0 * e.health.ratio())]))])
	if is_instance_valid(world.companion) and world.companion.input_source != bot:
		world.companion.input_source = bot
	await get_tree().physics_frame


## Las partidas guardadas de esta PC: archivo -> cuándo se modificó.
func _save_times() -> Dictionary:
	var out := {}
	for file in DirAccess.get_files_at("user://saves"):
		out[file] = FileAccess.get_modified_time("user://saves/" + file)
	return out


func _spawned_ok(e: Creature, run: RogueRun) -> bool:
	var entrance := run._cell_pos(run.room_data.player_mon_cell)
	return e.target == world.companion and world.combat.enemies.has(e) 		and e.global_position.distance_to(entrance) >= RogueRun.SPAWN_MIN_DIST - 1.0


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


## Avanza los diálogos y contesta las preguntas con `answers` (en orden) mientras exista este mundo.
func _dialogs() -> void:
	var w := world
	while is_instance_valid(w) and w.is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(w) or not w.is_inside_tree():
			return
		var d: DialogBox = w.story.dialog
		if d.active:
			if d._choosing:
				d.choose(answers.pop_front() if not answers.is_empty() else 0)
			else:
				d.advance()


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


## Vitrina: la pantalla de elección y después el bot jugando las salas.
func showcase() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/rogue_select.tscn")
	await get_tree().create_timer(2.0).timeout
	RogueRun.begin(DB.species["squirtle"])
	var args := OS.get_cmdline_user_args()
	if args.has("--biomes") and args.find("--biomes") + 1 < args.size():  # p. ej. --biomes volcan,costa,cueva,hielo,cementerio
		GameState.rogue["biomes"] = Array(args[args.find("--biomes") + 1].split(","))
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 20.0)
	_dialogs()
	var bot := RogueBot.new(world)
	bot.keep_distance = 70.0
	world.combat.input_source = bot
	while is_instance_valid(world) and world.rogue.result == "":
		if is_instance_valid(world.companion):
			world.companion.input_source = bot
			world.companion.instance.hp = maxf(world.companion.instance.hp, world.companion.instance.max_hp() * 0.5)  # (que llegue a mostrar todo)
		await get_tree().physics_frame
