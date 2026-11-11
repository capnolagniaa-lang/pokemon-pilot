class_name RogueBalanceTests
extends Node
## Medición de la dificultad del Modo Desafío: un bot juega partidas enteras (salas al azar, puertas, recompensas y la
## pelea con el jefe **de verdad**) y se anota hasta dónde llega, con qué nivel y con cuánta vida. No es un test que
## pase o falle: es para ajustar data/rogue/desafio.json.
##   godot --headless --path . --fixed-fps 60 --quit-after 2000000 -- --autotest-rogue-balance --runs 4 --species squirtle
## El bot es el de --autotest-rogue-rooms (tira ataques de daño al azar, toma la Poción con poca vida): juega peor que
## una persona atenta, así que sus números son un piso. `--skill 0.6` le baja el daño recibido (alguien que esquiva).
## `--rogue-set=clave=valor,...` prueba otros números del piso sin tocar el archivo (RogueRun.load_floor).

var world: Node
var rows: Array = []


func run() -> void:
	var args := OS.get_cmdline_user_args()
	var runs := int(_arg(args, "--runs", "3"))
	var species := str(_arg(args, "--species", "squirtle"))
	for n in runs:
		var row: Dictionary = await _one(species)
		rows.append(row)
		print("[balance] %s #%d: %s · salas %d · Nv. %d (al jefe %s) · vida por sala %s · pociones %d · bendiciones %d · objetos %d · %d s" % [
			species, n + 1, row["result"], row["rooms"], row["level"], str(row["boss_level"]), str(row["hp"]), row["potions"], row["boons"], row["items"], row["time"]])
	var reached := rows.filter(func(x): return x["boss_level"] > 0)
	var won := rows.filter(func(x): return x["result"] == "win")
	var lv := 0.0
	for x in reached:
		lv += float(x["boss_level"])
	print("[balance] %s: %d partidas · llegó al jefe %d · le ganó %d · nivel medio al jefe %.1f" % [species, rows.size(), reached.size(),
		won.size(), lv / maxf(1.0, float(reached.size()))])
	get_tree().quit(0)


func _one(species: String) -> Dictionary:
	RogueRun.begin(DB.species[species])
	# --skill 0.6 = recibe 60 % del daño: aproxima a una persona que esquiva (el bot no esquiva a propósito).
	GameState.set_setting("taken_mult", float(_arg(OS.get_cmdline_user_args(), "--skill", "1.0")))
	var mine: CreatureInstance = GameState.active()
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 30.0)
	var run_: RogueRun = world.rogue
	world.evolutions.speed = 12.0
	_pump()
	var bot := RogueTests.RogueBot.new(world)
	bot.keep_distance = 70.0
	world.combat.input_source = bot
	var hp: Array = []
	var boss_level := 0
	var cleared := 0
	var t := 0.0
	while t < 1500.0 and run_.result == "":
		if is_instance_valid(world.companion) and world.companion.input_source != bot:
			world.companion.input_source = bot
		if run_.rooms_cleared != cleared:
			cleared = run_.rooms_cleared
			hp.append(roundi(100.0 * mine.hp / mine.max_hp()))
		if run_.phase == "jefe" and boss_level == 0:
			boss_level = mine.level
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	var row := {"result": run_.result if run_.result != "" else "tiempo", "rooms": run_.rooms_cleared, "boss_level": boss_level, "hp": hp,
		"potions": GameState.item_count("pocion"), "boons": run_.boons.owned().size(),
		"items": GameState.rogue.get("items", []).size(), "time": int(t), "level": mine.level}
	await _until(func(): return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("title_screen.tscn"), 40.0)
	return row


## Contesta todo lo que frena la partida: bendiciones (la primera), tarjetas (la última que se puede), ataques nuevos
## (reemplaza uno de estado si hay) y los diálogos ("Volver al título").
func _pump() -> void:
	var w := world
	while is_instance_valid(w) and w.is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(w) or not w.is_inside_tree():
			return
		var r: RogueRun = w.rogue
		if is_instance_valid(r.boon_screen):
			r.boon_screen.choose(0)
			continue
		if is_instance_valid(r.reward_screen):
			r.reward_screen.choose(r.reward_screen.last_enabled())
			continue
		var learn: MoveLearnDirector = w.evolutions.moves
		if learn.showing and is_instance_valid(learn.screen):
			var slot := -1
			for i in learn.screen.inst.equipped_moves.size():
				var m: MoveData = learn.screen.inst.equipped_moves[i]
				if m != null and (m.power <= 0.0 or m.category == MoveData.Category.STATUS) and learn.screen.move.power > 0.0:
					slot = i
			learn.screen.finished.emit(slot)
			continue
		var d: DialogBox = w.story.dialog
		if d.active:
			if d._choosing:
				d.choose(1)
			else:
				d.advance()


func _arg(args: PackedStringArray, key: String, def: String) -> String:
	var i := args.find(key)
	return args[i + 1] if i >= 0 and i + 1 < args.size() else def


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()
