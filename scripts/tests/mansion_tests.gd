class_name MansionTests
extends Node
## ¿Se puede recorrer la Mansión Pokémon sin quedar trabado? Arma el grafo (piso, celda, interruptor) con la colisión real
## de las zonas: caminar, puertas (WarpSystem.arrival, como en el juego) y estatuas. Mira: 1) a qué objeto se llega desde
## la entrada, 2) que desde todo lugar al que se llega se pueda volver a salir.
## 3) que guardar y cargar adentro respete el interruptor (queja de un amigo 2026-11-04: "trabado en un piso"), 4) el
## recorrido a pie con las teclas: de la puerta a la Llave Secreta y de vuelta afuera.
##   godot --headless --path . --quit-after 200000 -- --autotest-mansion [--out <txt con los planos de cada piso>]

const FLOORS := ["mansion_pokemon_1p", "mansion_pokemon_2p", "mansion_pokemon_3p", "mansion_pokemon_s1"]
const DIRS: Array[Vector2i] = [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]
const OUTSIDE := "isla_canela"
## Lo que hay que poder agarrar (los objetos que están en el juego): zona -> celda.
const GOALS := {
	"Llave Secreta": ["mansion_pokemon_s1", Vector2i(5, 7)],
	"MT14": ["mansion_pokemon_s1", Vector2i(23, 4)],
	"MT22": ["mansion_pokemon_s1", Vector2i(6, 21)],
	"Restaurar Todo": ["mansion_pokemon_s1", Vector2i(2, 29)],
	"Poción Máxima": ["mansion_pokemon_3p", Vector2i(9, 19)],
}

var autotest: Node
var world: Node
var entries := {}  # zona -> ZoneEntry
var open := {}  # [zona, apretado] -> {celda: true} caminables
var trainers := {}  # zona -> {celda: true} personas paradas (las que no se mueven de ahí)


func run() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	var r := {}
	for z in world.streamer.world_data.zones:
		if z.id in FLOORS:
			entries[z.id] = z
	for id: String in FLOORS:
		await _read_floor(id)
	var start := _state("mansion_pokemon_1p", _arrive("mansion_pokemon_1p", Vector2i(8, 33), false), false)
	r["Entrada: se aparece en un lugar libre"] = open[["mansion_pokemon_1p", false]].has(start[1])
	for blocked: bool in [false, true]:
		var seen := _reach(start, blocked)
		var tag := " (con las personas tapando)" if blocked else ""
		for g: String in GOALS:
			r["Se llega a: %s%s" % [g, tag]] = _reaches_goal(seen, GOALS[g][0], GOALS[g][1])
		for id: String in FLOORS:
			r["Se llega a %s%s" % [id, tag]] = seen.keys().any(func(s): return s[0] == id)
		var stuck := _stuck_states(seen, blocked)
		r["Sin lugares de los que no se vuelve%s" % tag] = stuck.is_empty()
		if not stuck.is_empty():
			print("[mansion] trabados%s: %d estados, ej. %s" % [tag, stuck.size(), str(stuck.slice(0, 12))])
	await _saved_inside(r, "Encerrado con la Llave", "mansion_pokemon_s1", Vector2i(5, 9), true, true)
	await _saved_inside(r, "Guardado en el sótano sin apretar", "mansion_pokemon_s1", Vector2i(30, 12), false, true)
	await _saved_inside(r, "Sala que se cierra con el interruptor", "mansion_pokemon_3p", Vector2i(25, 7), true, false)
	await _saved_inside(r, "Arriba de una barrera", "mansion_pokemon_1p", Vector2i(32, 18), true, false)
	var out := ""
	var args := OS.get_cmdline_user_args()
	if "--out" in args:
		out = args[args.find("--out") + 1]
		_write_plans(out, _reach(start, false))
	await _saved_gym(r)
	GameState.wilds_enabled = false
	await _walk_it(r)
	var ok := true
	for k: String in r:
		print("[mansion] %s: %s" % [k, "OK" if r[k] else "FALLO"])
		ok = ok and r[k]
	print("[autotest-mansion] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)


## Lo mismo en el gimnasio de Carmín: guardar con la barrera abierta y cargar adentro la tiene que dejar abierta.
func _saved_gym(r: Dictionary) -> void:
	var zone_id := VermilionGymPuzzle.ZONE
	GameState.set_flag(VermilionGymPuzzle.FLAG)
	await world.story.teleport(zone_id, Vector2i(5, 12))
	await get_tree().create_timer(0.3).timeout
	GameState.trainer_position = world.trainer.global_position
	GameState.from_dict(JSON.parse_string(JSON.stringify(GameState.to_dict())))
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().create_timer(0.3).timeout
	world = get_tree().current_scene
	await get_tree().create_timer(1.0).timeout
	var zone: Zone = world.streamer.zone_node(zone_id)
	r["Gimnasio de Carmín: al cargar adentro la barrera sigue abierta"] = zone != null and MapRules.is_walkable(zone, Vector2i(5, 6))
	GameState.set_flag(VermilionGymPuzzle.FLAG, false)


## El recorrido entero a pie, con las teclas y la colisión de verdad: de la puerta a la Llave Secreta (estatuas con la E),
## agarrarla, y salir de la Mansión.
func _walk_it(r: Dictionary) -> void:
	GameState.set_flag(MansionSwitches.FLAG, false)
	GameState.trainer_position = Vector2.INF
	await world.story.teleport("mansion_pokemon_1p", Vector2i(8, 32))
	await get_tree().create_timer(0.3).timeout
	var walker := RoomWalkTests.new()
	walker.autotest = autotest
	add_child(walker)
	Engine.time_scale = 2.0
	var start := _state("mansion_pokemon_1p", Vector2i(8, 32), false)
	var key: Vector2i = GOALS["Llave Secreta"][1]
	var there := await _walk(walker, start, func(s: Array) -> bool:
		return s[0] == "mansion_pokemon_s1" and (s[1] as Vector2i - key).length_squared() == 1)
	r["A pie: llega al lado de la Llave Secreta"] = not there.is_empty()
	if not there.is_empty():
		world.trainer.facing = Vector2(key - (there[1] as Vector2i))
		world.story.try_interact()
		await _settle()
		r["A pie: agarra la Llave Secreta"] = GameState.has_flag("objeto_mansion_pokemon_s1_itemsecretkey")
		var out := await _walk(walker, there, func(s: Array) -> bool: return s[0] == "AFUERA")
		r["A pie: sale de la Mansión"] = not out.is_empty()
	Engine.time_scale = 1.0
	GameState.set_flag(MansionSwitches.FLAG, false)


## Camina del estado `from` al primero que cumpla `done`. Devuelve dónde quedó ([] si algo real no dejó pasar).
func _walk(walker: RoomWalkTests, from: Array, done: Callable) -> Array:
	var path := _path(from, done)
	var here := from
	var t: Trainer = world.trainer
	for s: Array in path:
		var id: String = here[0]
		var entry: ZoneEntry = entries[id]
		var cell: Vector2i = here[1]
		var ok := true
		if s[2] != here[2]:  # estatua, de frente con la E
			ok = await _press_statue(id, cell)
		elif s[0] != id:  # puerta: caminar hasta que te lleve
			ok = await _through_door(entry, cell, s)
		else:
			var center := func(c: Vector2i) -> Vector2:
				return Vector2(entry.origin + c) * 16.0 + Vector2.ONE * 8.0
			ok = await walker._step(t, cell, s[1], center)
		if not ok:
			print("[mansion] a pie: no pudo pasar de %s a %s" % [str(here), str(s)])
			return []
		here = s
	return here


func _press_statue(id: String, cell: Vector2i) -> bool:
	for d: Vector2i in DIRS:
		if MansionSwitches.STATUES[id].has(cell + d) or MansionSwitches.STATUES[id].has(cell + d + Vector2i(0, 1)):
			var before := GameState.has_flag(MansionSwitches.FLAG)
			world.trainer.facing = Vector2(d)
			world.story.try_interact()
			await get_tree().process_frame
			world.story.dialog.choose(0)
			await _settle()
			return GameState.has_flag(MansionSwitches.FLAG) != before
	return false


func _through_door(entry: ZoneEntry, cell: Vector2i, to: Array) -> bool:
	var t: Trainer = world.trainer
	var want: String = OUTSIDE if to[0] == "AFUERA" else to[0]
	for d: Vector2i in DIRS:
		if entry.warps.has(cell + d) and entry.warps[cell + d]["to"] == want:
			t.autopilot = Vector2(d)
			var time := 0.0
			while not world.warps.busy and time < 3.0:
				await get_tree().physics_frame
				time += get_physics_process_delta_time() * Engine.time_scale
			t.autopilot = Vector2.ZERO
			while world.warps.busy:
				await get_tree().physics_frame
			await get_tree().create_timer(0.1).timeout
			var now: ZoneEntry = world.streamer.world_data.zone_at(t.global_position)
			return now != null and now.id == want
	return false


## Espera que termine la charla (pasando los textos).
func _settle() -> void:
	var time := 0.0
	while (world.story.busy or world.story.dialog.active) and time < 8.0:
		world.story.dialog.advance()
		await get_tree().create_timer(0.05).timeout
		time += 0.05


## Camino más corto entre estados, con las personas tapando.
func _path(from: Array, done: Callable) -> Array:
	var prev := {from: from}
	var queue := [from]
	while not queue.is_empty():
		var s: Array = queue.pop_front()
		if done.call(s):
			var out := []
			var c := s
			while c != from:
				out.push_front(c)
				c = prev[c]
			return out
		if s[0] == "AFUERA":
			continue
		for n: Array in _next(s, true):
			if not prev.has(n):
				prev[n] = s
				queue.append(n)
	return []


## Guarda adentro de la Mansión y carga de verdad: las barreras tienen que quedar según el interruptor y tenés que poder
## salir. `same_place`: sigue donde guardó (si no, lo saca a la entrada: quedó en un lugar sin salida).
func _saved_inside(r: Dictionary, what: String, id: String, cell: Vector2i, pressed: bool, same_place: bool) -> void:
	var entry: ZoneEntry = entries[id]
	GameState.set_flag(MansionSwitches.FLAG, pressed)
	var ts: int = world.streamer.world_data.tile_size
	var at := Vector2((entry.origin + cell) * ts) + Vector2.ONE * ts / 2.0
	GameState.trainer_position = at
	var saved: Dictionary = JSON.parse_string(JSON.stringify(GameState.to_dict()))
	GameState.from_dict(saved)
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().create_timer(0.3).timeout
	world = get_tree().current_scene
	await get_tree().create_timer(1.0).timeout
	var t: Trainer = world.trainer
	var now: ZoneEntry = world.streamer.world_data.zone_at(t.global_position)
	var zone: Zone = world.streamer.zone_node(now.id)
	var here := zone.cell_at(t.global_position)
	var same := true
	for c: Vector2i in open[[now.id, pressed]]:
		same = same and MapRules.is_walkable(zone, c)
	r["%s: al cargar las barreras siguen como estaban" % what] = same and GameState.has_flag(MansionSwitches.FLAG) == pressed
	r["%s: %s" % [what, "sigue en su lugar" if same_place else "aparece en la entrada"]] = 		(now.id == id and here == cell) if same_place else now.id == "mansion_pokemon_1p"
	var all := _reach(_state(now.id, here, pressed), false)
	r["%s: se puede salir" % what] = all.keys().any(func(s): return s[0] == "AFUERA")


## Lee la colisión del piso con el interruptor de las dos maneras (y lo deja como estaba).
func _read_floor(id: String) -> void:
	var entry: ZoneEntry = entries[id]
	await world.story.teleport(id, entry.hub)
	await get_tree().create_timer(0.3).timeout
	var zone: Zone = world.streamer.zone_node(id)
	var objects := MapRules.objects_by_cell(zone)
	for pressed: bool in [false, true]:
		world.mansion_switches.apply(zone, id, pressed)
		var cells := {}
		for y in entry.size.y:
			for x in entry.size.x:
				if MapRules.is_walkable(zone, Vector2i(x, y), objects):
					cells[Vector2i(x, y)] = true
		open[[id, pressed]] = cells
	world.mansion_switches.apply(zone, id, false)
	var people := {}
	for npc: StoryNPC in world.story.npcs.values():
		if is_instance_valid(npc) and npc.data.zone_id == id and npc.data.visible_now():
			people[zone.cell_at(npc.global_position)] = true
			GameState.set_flag(npc.data.defeated_flag())  # (el recorrido a pie no se frena a pelear)
	trainers[id] = people


func _state(id: String, cell: Vector2i, pressed: bool) -> Array:
	return [id, cell, pressed]


func _arrive(id: String, cell: Vector2i, pressed: bool) -> Vector2i:
	var cells: Dictionary = open[[id, pressed]]
	return WarpSystem.arrival(func(c: Vector2i) -> bool: return cells.has(c), entries[id], cell)[0]


## Adónde se puede ir en un paso desde un estado.
func _next(s: Array, blocked: bool) -> Array:
	var out := []
	var id: String = s[0]
	var cell: Vector2i = s[1]
	var pressed: bool = s[2]
	var entry: ZoneEntry = entries[id]
	var cells: Dictionary = open[[id, pressed]]
	var people: Dictionary = trainers[id] if blocked else {}
	for d: Vector2i in DIRS:
		var n := cell + d
		if entry.warps.has(n):  # transitable: pisarla; sólida: caminar contra ella. Las dos llevan al mismo lado.
			var to: String = entry.warps[n]["to"]
			if to == OUTSIDE:
				out.append(["AFUERA", Vector2i.ZERO, pressed])
			elif entries.has(to):
				out.append(_state(to, _arrive(to, entry.warps[n]["cell"], pressed), pressed))
		elif cells.has(n) and not people.has(n):
			out.append(_state(id, n, pressed))
		if MansionSwitches.STATUES[id].has(n) or MansionSwitches.STATUES[id].has(n + Vector2i(0, 1)):
			out.append(_state(id, cell, not pressed))  # la estatua
	return out


func _reach(start: Array, blocked: bool) -> Dictionary:
	var seen := {start: true}
	var queue := [start]
	while not queue.is_empty():
		var s: Array = queue.pop_back()
		if s[0] == "AFUERA":
			continue
		for n: Array in _next(s, blocked):
			if not seen.has(n):
				seen[n] = true
				queue.append(n)
	return seen


func _reaches_goal(seen: Dictionary, id: String, cell: Vector2i) -> bool:
	for s: Array in seen:
		if s[0] == id and (s[1] as Vector2i - cell).length_squared() <= 1:
			return true
	return false


## Estados a los que se llega y desde los que ya no se puede salir de la Mansión.
func _stuck_states(seen: Dictionary, blocked: bool) -> Array:
	var back := {}
	var can_exit := {}
	var queue := []
	for s: Array in seen:
		if s[0] == "AFUERA":
			can_exit[s] = true
			queue.append(s)
			continue
		for n: Array in _next(s, blocked):
			if not back.has(n):
				back[n] = []
			back[n].append(s)
	while not queue.is_empty():
		var s: Array = queue.pop_back()
		for p: Array in back.get(s, []):
			if not can_exit.has(p):
				can_exit[p] = true
				queue.append(p)
	return seen.keys().filter(func(s): return not can_exit.has(s))


## Planos: # pared, . se llega, o caminable pero no se llega, P puerta, E estatua, G objeto, T persona.
func _write_plans(path: String, seen: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	for id: String in FLOORS:
		for pressed: bool in [false, true]:
			f.store_line("== %s, interruptor %s" % [id, "apretado" if pressed else "sin apretar"])
			var entry: ZoneEntry = entries[id]
			var cells: Dictionary = open[[id, pressed]]
			f.store_line("    " + "".join(range(entry.size.x).map(func(x): return str(x % 10))))
			for y in entry.size.y:
				var line := "%3d " % y
				for x in entry.size.x:
					var c := Vector2i(x, y)
					var ch := "#"
					if cells.has(c):
						ch = "." if seen.has(_state(id, c, pressed)) else "o"
					if entry.warps.has(c):
						ch = "P"
					if MansionSwitches.STATUES[id].has(c):
						ch = "E"
					if trainers[id].has(c):
						ch = "T"
					for g: String in GOALS:
						if GOALS[g][0] == id and GOALS[g][1] == c:
							ch = "G"
					line += ch
				f.store_line(line)
	f.close()
