class_name RogueBalanceTests
extends Node
## Batería de balance del Modo Desafío (pedido del usuario 2026-11-11: "un sistema para correr el modo desafío muchísimas
## veces... y en base a los datos ir nerfeando lo que esté roto"). Un bot juega partidas enteras (salas al azar, puertas,
## recompensas, Tienda y la pelea con el jefe **de verdad**) y deja una línea de datos por partida. No pasa ni falla:
## es para ajustar data/rogue/desafio.json, tools/build_boons.py y tools/build_rogue_items.py **midiendo**.
##   godot --headless --path . --fixed-fps 60 --quit-after 9000000 -- --autotest-rogue-balance --runs 40 --json out/a.jsonl
## Opciones:
##   --runs N              cuántas partidas.
##   --starter a,b,c       iniciales (se turnan). Por defecto charmander,squirtle,bulbasaur. (`--species x` = uno solo.)
##   --policy azar|rareza  cómo elige bendiciones y objetos: al azar, o la de mejor rareza.
##   --give id,id          arranca con esos objetos o bendiciones (para **aislar** el efecto de uno, o simular desbloqueos
##                         permanentes del futuro: "con X de entrada").
##   --dodge 0..1          qué parte de los golpes que ve venir esquiva (0,7 = "bot bueno"; 0 = el bot de antes).
##   --taken x             multiplica el daño que recibe (otra forma de simular habilidad; 1 = normal).
##   --tag texto           etiqueta de la tanda (por defecto, lo de --give).
##   --json ruta           agrega una línea JSON por partida a ese archivo (lo junta tools/rogue_balance_report.py).
##   --seed N              semilla del azar global (orientativa: la física no es exactamente repetible).
##   --rogue-set=k=v,...   prueba otros números del piso sin tocar el archivo (RogueRun.load_floor).
## Informe: python -I -B tools/rogue_balance_report.py <carpeta con los .jsonl> --out docs/ROGUE_BALANCE_INFORME.md
## Varias tandas en paralelo: tools/rogue_balance.py (lanza un proceso por tanda y arma el informe).

const RARITY_ORDER := ["comun", "rara", "epica", "legendaria"]
## Si en plena oleada nadie hace ni recibe daño por este tiempo, la partida se da por trabada (no cuenta).
const STUCK_TIME := 45.0
const RUN_LIMIT := 900.0
## Si el bot tarda más que esto en llegar a una puerta o al paso (se le traba el camino entre los obstáculos), se lo
## lleva ahí: lo que se mide es el combate, no su manera de caminar. Queda anotado en `helped` (qué sala y qué fase).
const WALK_HELP := 25.0

var world: Node
var rows: Array = []
var policy := "azar"
var dodge := 0.7
var taken := 1.0
## Cuántos tramos juega (1 = hasta Brock; 3 = hasta Lt. Surge).
var acts := 1
var give: Array = []
var tag := ""
var json_path := ""
var _dealt := 0.0
var _taken := 0.0
var _hooked: Creature
var _last_hit := 0.0
var _clock := 0.0


## El bot del test de salas, pero que **esquiva** lo que ve venir (disparos, zonas, cargas y golpes cuerpo a cuerpo que
## están saliendo), como una persona atenta: decide una vez por amenaza, con probabilidad `skill`.
class SkillBot extends RogueTests.RogueBot:
	var skill := 0.7
	var _seen: Dictionary = {}
	var _dodge_dir := Vector2.ZERO
	var _dodge_now := false

	func move_dir(actor: Creature) -> Vector2:
		_dodge_now = false
		if skill > 0.0 and not world.combat.enemies.is_empty():
			var th := _threat(actor)
			if not th.is_empty() and float(th["eta"]) <= 0.28:
				var key = th["key"]
				if not _seen.has(key):
					_seen[key] = randf() < skill
					if _seen.size() > 60:
						_seen.clear()
				if _seen.get(key, false) and actor.moves.dodge_cooldown <= 0.0:
					_dodge_now = true
					_dodge_dir = th["out"]
					return _dodge_dir
		return super(actor)

	func wants_dodge() -> bool:
		return _dodge_now

	## Lo que viene: lo que ve la mente (disparos, zonas, chorros) o el golpe de un enemigo que está saliendo al lado.
	func _threat(actor: Creature) -> Dictionary:
		var best: Dictionary = actor.mind.threat() if actor.mind != null else {}
		for e in world.combat.enemies:
			if not is_instance_valid(e) or e.is_down():
				continue
			var d: float = e.global_position.distance_to(actor.global_position)
			if d <= 46.0 and e.machine.current_name() in ["step", "lunge", "dash"]:
				var away: Vector2 = (actor.global_position - e.global_position).normalized().orthogonal()
				if best.is_empty() or float(best["eta"]) > 0.15:
					best = {"key": [e, e.machine.current_name(), int(Time.get_ticks_msec() / 600)], "eta": 0.15, "out": away}
		return best


func run() -> void:
	var args := OS.get_cmdline_user_args()
	var runs := int(_arg(args, "--runs", "3"))
	var starters: Array = Array(_arg(args, "--starter", _arg(args, "--species", "charmander,squirtle,bulbasaur")).split(","))
	policy = _arg(args, "--policy", "azar")
	dodge = float(_arg(args, "--dodge", "0.7"))
	taken = float(_arg(args, "--taken", _arg(args, "--skill", "1.0")))
	acts = int(_arg(args, "--acts", "1"))
	give = Array(_arg(args, "--give", "").split(",", false))
	tag = _arg(args, "--tag", ",".join(give))
	json_path = _arg(args, "--json", "")
	if args.has("--seed"):
		seed(int(_arg(args, "--seed", "0")))
	for n in runs:
		var sp: String = starters[n % starters.size()]
		var row: Dictionary = await _one(sp)
		rows.append(row)
		if json_path != "":
			var f := FileAccess.open(json_path, FileAccess.READ_WRITE if FileAccess.file_exists(json_path) else FileAccess.WRITE)
			if f != null:
				f.seek_end()
				f.store_line(JSON.stringify(row))
				f.close()
		print("[balance] %s #%d: %s · salas %d · Nv. %d (al jefe %s) · vida por sala %s · pociones %d · bendiciones %d · objetos %d · %d s" % [
			sp, n + 1, row["result"], row["rooms"], row["level"], str(row["boss_level"]), str(row["hp"]), row["potions"],
			row["boons"].size(), row["items"].size(), row["time"]])
	var ok := rows.filter(func(x): return x["result"] != "trabado")
	var reached := ok.filter(func(x): return x["boss_level"] > 0)
	var won := ok.filter(func(x): return x["result"] == "win")
	var lv := 0.0
	for x in reached:
		lv += float(x["boss_level"])
	print("[balance] %s%s: %d partidas · llegó al jefe %d · le ganó %d · nivel medio al jefe %.1f · trabadas %d" % [",".join(starters),
		" [" + tag + "]" if tag != "" else "", ok.size(), reached.size(), won.size(), lv / maxf(1.0, float(reached.size())), rows.size() - ok.size()])
	get_tree().quit(0)


func _one(species: String) -> Dictionary:
	RogueRun.begin(DB.species[species])
	GameState.rogue["acts"] = acts  # (por defecto 1: la batería mide hasta Brock; `--acts 3` = la partida entera)
	GameState.set_setting("taken_mult", taken)
	var mine: CreatureInstance = GameState.active()
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada", 30.0)
	var run_: RogueRun = world.rogue
	for id: String in give:  # lo que trae de entrada (aislar un efecto, o "desbloqueos" del futuro)
		if DB.rogue_items.has(id):
			run_.boons.take_item(id)
		elif DB.boons.has(id):
			run_.boons.take(id)
	world.evolutions.speed = 12.0
	_pump(mine)
	var bot := SkillBot.new(world)
	bot.skill = dodge
	bot.keep_distance = 70.0
	world.combat.input_source = bot
	_dealt = 0.0
	_taken = 0.0
	_hooked = null
	_clock = 0.0
	_last_hit = 0.0
	var hp: Array = []
	var times: Array = []
	var room_start := 0.0
	var boss_level := 0
	var cleared := 0
	var stuck := false
	var helped: Array = []
	var walk_phase := ""
	var walk_since := 0.0
	while _clock < RUN_LIMIT * float(acts) and run_.result == "":
		if run_.phase != walk_phase or run_.phase not in ["eleccion", "puerta"]:
			walk_phase = run_.phase
			walk_since = _clock
		elif _clock - walk_since > WALK_HELP and is_instance_valid(world.companion):
			walk_since = _clock
			helped.append("%s:%s" % [run_.room_data.id if run_.room_data != null else "?", run_.phase])
			var goal := run_.exit_point()
			if run_.phase == "puerta" and not is_instance_valid(run_.door) and run_.room_index + 1 < run_.chain.size():
				var next: Zone = run_.chain[run_.room_index + 1]  # (el paso: aparece ya adentro de la sala siguiente)
				var used: Rect2i = next.ground.get_used_rect()
				goal = next.to_global(next.ground.map_to_local(Vector2i(used.end.x / 2, used.end.y - RogueRun.ENTER_ROWS - 3)))
			if goal != Vector2.INF:
				world.companion.global_position = goal
		var c: Creature = world.companion
		if is_instance_valid(c):
			if c.input_source != bot:
				c.input_source = bot
			if c != _hooked:
				_hooked = c
				c.hit_dealt.connect(func(_t, _h, d): _dealt += d; _last_hit = _clock)
				c.damage_received.connect(func(d, _h): _taken += d; _last_hit = _clock)
		if run_.rooms_cleared != cleared:
			cleared = run_.rooms_cleared
			hp.append(roundi(100.0 * mine.hp / mine.max_hp()))
			times.append(roundi(_clock - room_start))
			room_start = _clock
			_last_hit = _clock
		if run_.phase == "jefe" and boss_level == 0:
			boss_level = mine.level
			_last_hit = _clock
		if run_.phase != "oleada" and run_.phase != "jefe":
			_last_hit = maxf(_last_hit, _clock - STUCK_TIME * 0.5)  # (caminar a la puerta o elegir no es estar trabado)
		if _clock - _last_hit > STUCK_TIME * (2.0 if run_.phase == "jefe" else 1.0):
			stuck = true
			break
		await get_tree().physics_frame
		_clock += get_physics_process_delta_time()
	var rooms: Array = run_.floor_data.get("rooms", [])
	var row := {"starter": species, "tag": tag, "policy": policy, "dodge": dodge, "taken": taken,
		"result": "trabado" if stuck or run_.result == "" else run_.result, "rooms": run_.rooms_cleared, "boss_level": boss_level,
		"level": mine.level, "hp": hp, "times": times, "time": int(_clock), "dealt": roundi(_dealt), "taken_dmg": roundi(_taken),
		"hp_end": roundi(100.0 * mine.hp / maxf(1.0, mine.max_hp())), "potions": GameState.item_count("pocion"), "money": GameState.money,
		"boons": run_.boons.owned().duplicate(true), "items": run_.boons.items().duplicate(true), "stash": run_.boons.stash().duplicate(true),
		"upgrades": run_.rewards.upgrades().map(func(u): return [u["id"], u["count"]]),
		"rewards": range(mini(run_.rooms_cleared, rooms.size())).map(func(i): return run_.reward_of(i)),
		"arenas": rooms.map(func(x): return x["arena"]), "stuck_at": ("%s:%s" % [run_.room_data.id, run_.phase] if (stuck or run_.result == "") and run_.room_data != null else ""), "helped": helped}
	if run_.result == "":  # trabada o sin tiempo: se termina la partida para poder seguir con la próxima
		if is_instance_valid(world.companion):
			world.companion.health.invulnerable_time = 0.0
			world.companion.health.apply_damage(999999.0)
		mine.hp = 0.0
		await _until(func(): return run_.result != "", 20.0)
	await _until(func(): return get_tree().current_scene != null and get_tree().current_scene.scene_file_path.ends_with("title_screen.tscn"), 60.0)
	return row


## Contesta todo lo que frena la partida, según la política: bendiciones y objetos (al azar o la de mejor rareza), la
## Tienda (se cura si le falta vida y compra lo que le alcance), la MT (saca un ataque de estado o el más flojo), ataques
## nuevos (reemplaza uno de estado si hay) y los diálogos ("Volver al título").
func _pump(mine: CreatureInstance) -> void:
	var w := world
	while is_instance_valid(w) and w.is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(w) or not w.is_inside_tree():
			return
		var r: RogueRun = w.rogue
		if is_instance_valid(r.boon_screen):
			r.boon_screen.choose(_best(r.boon_screen.offer["options"].map(func(o): return str(o["rarity"]))))
			continue
		if is_instance_valid(r.reward_screen):
			var s: RewardScreen = r.reward_screen
			s.choose(_card(s, mine))
			continue
		var learn: MoveLearnDirector = w.evolutions.moves
		if learn.showing and is_instance_valid(learn.screen):
			learn.screen.finished.emit(_weak_slot(learn.screen.inst, learn.screen.move))
			continue
		var d: DialogBox = w.story.dialog
		if d.active:
			if d._choosing:
				d.choose(1)
			else:
				d.advance()


## Qué tarjeta elige en una pantalla de recompensa.
func _card(s: RewardScreen, mine: CreatureInstance) -> int:
	var titles: Array = s.cards_data.map(func(c): return str(c.get("title", "")))
	var open: Array = range(s.cards.size()).filter(func(i): return not s.cards[i].disabled)
	if open.is_empty():
		return -1
	if s.title == "Tienda":
		var want: Array = ["Objeto", "Bendición", "Poción"]
		if mine.hp < mine.max_hp() * 0.6:
			want.push_front("Curación")
		for name: String in want:
			var i := titles.find(name)
			if i >= 0 and open.has(i):
				return i
		return s.last_enabled()
	if s.title.begins_with("¿A cuál reemplaza"):
		if s.subtitle.begins_with("El ataque"):  # MT: saca el de estado, o el más flojo
			return _weak_slot(mine, null)
		return s.last_enabled()  # objeto con las 3 ranuras llenas: lo guarda
	if s.title == "Objeto":
		var rar: Array = s.cards_data.map(func(c): return str(c.get("tag", "")).split("  ·  ")[0])
		var names := {"Común": "comun", "Rara": "rara", "Épica": "epica", "Legendaria": "legendaria"}
		return _best(rar.map(func(x): return names.get(x, "comun")))
	return open[randi() % open.size()]


## Índice elegido entre opciones con esas rarezas: al azar, o la de mejor rareza (empate: al azar entre ellas).
func _best(rarities: Array) -> int:
	if rarities.is_empty():
		return 0
	if policy != "rareza":
		return randi() % rarities.size()
	var top := -1
	var picks: Array = []
	for i in rarities.size():
		var v := RARITY_ORDER.find(rarities[i])
		if v > top:
			top = v
			picks = [i]
		elif v == top:
			picks.append(i)
	return picks[randi() % picks.size()]


## La ranura del ataque que conviene sacar: uno de estado si hay; si no, el de menos potencia. -1 si el nuevo no es de daño.
func _weak_slot(inst: CreatureInstance, new_move: MoveData) -> int:
	if new_move != null and new_move.power <= 0.0:
		return -1
	var slot := 0
	var worst := 99999.0
	for i in inst.equipped_moves.size():
		var m: MoveData = inst.equipped_moves[i]
		var p: float = 0.0 if m == null or m.category == MoveData.Category.STATUS else m.power
		if p < worst:
			worst = p
			slot = i
	return slot


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
