class_name OnlineBuildingTests
extends Node
## Autotest del Centro de Combate Online (docs/PLAN_ONLINE.md, O-1): el edificio agregado en Ciudad Verde (sin tocar
## la zona ni kanto.tres), su puerta, el interior, la enfermera, la tienda y la recepcionista que conecta a la sala.
##   godot --headless --path . --quit-after 90000 -- --autotest-online-building
## Vitrina (afuera y adentro):
##   godot --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-online-building

const PORT := 24783

var autotest: Node
var world: Node
var answers: Array = []
var r := {}


func run() -> void:
	var data: WorldData = DB.config.world
	var inside: ZoneEntry = _entry(data, "centro_online")
	var verde: ZoneEntry = _entry(data, "ciudad_verde")
	var b: ExtraBuilding = null
	for x in ExtraContent.buildings:
		if x.id == "centro_online":
			b = x
	r["Agregados: el interior y el edificio están en la región"] = inside != null and b != null and inside.interior
	r["La puerta del edificio lleva al interior (y está marcada como agregada)"] = verde.warps.has(b.door) \
		and verde.warps[b.door].to == "centro_online" and verde.warps[b.door].get(ExtraContent.EXTRA_KEY, false)
	r["El interior vuelve a Ciudad Verde, frente a la puerta"] = inside.warps.values().all(func(w): return w.to == "ciudad_verde" and w.cell == b.door)
	var overlap := data.zones.filter(func(z): return z != inside and Rect2i(z.origin, z.size).intersects(Rect2i(inside.origin, inside.size)))
	r["El interior no se encima con ninguna zona"] = overlap.is_empty()
	var clean := ExtraContent.without_extras(data)
	r["Al guardar la región (editor) no quedan los agregados"] = _entry(clean, "centro_online") == null \
		and not _entry(clean, "ciudad_verde").warps.has(b.door) and verde.warps.has(b.door)
	var on_disk: WorldData = ResourceLoader.load(ZoneBuilder.WORLD_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	r["kanto.tres no tiene el edificio"] = _entry(on_disk, "centro_online") == null and not _entry(on_disk, "ciudad_verde").warps.has(b.door)
	r["El sprite del edificio está (sprites/props/centro_online.png)"] = b.texture != null \
		and b.texture.get_size() == Vector2(b.size * data.tile_size)

	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await get_tree().physics_frame
	_dialogs()

	# Afuera: el lugar estaba libre y queda sólido; se llega a la puerta desde el Centro Pokémon.
	await _go("ciudad_verde", b.door + Vector2i(0, 1))
	var zone: Zone = world.streamer.zone_node("ciudad_verde")
	var solid: Dictionary = zone.get_meta(ExtraContent.SOLID_META, {})
	zone.remove_meta(ExtraContent.SOLID_META)
	var was_free := b.cells().all(func(c): return MapRules.is_walkable(zone, c))
	zone.set_meta(ExtraContent.SOLID_META, solid)
	r["El edificio va en un lugar que estaba libre"] = was_free
	r["Sus celdas quedan sólidas (MapRules) y tiene colisión"] = b.cells().all(func(c): return not MapRules.is_walkable(zone, c)) \
		and zone.has_node("Extra_centro_online/Body")
	r["Se llega caminando desde la puerta del Centro Pokémon"] = MapRules.has_path(zone, verde, Vector2i(58, 47), b.door + Vector2i(0, 1))
	var t: Trainer = world.trainer
	var start_y := t.global_position.y
	await _walk("move_up", 1.6)
	r["No se atraviesa: caminando contra la puerta se entra"] = _here() == "centro_online"
	r["Adentro: frente a la puerta, sin salvajes"] = _here() == "centro_online" and world.streamer.world_data.zone_at(t.global_position).interior
	await get_tree().create_timer(0.5).timeout
	var nurse: StoryNPC = world.story.npcs.get("centro_online_nurse")
	var clerk: StoryNPC = world.story.npcs.get("centro_online_clerk")
	var desk: StoryNPC = world.story.npcs.get("centro_online_recepcionista")
	r["Están la enfermera, el vendedor y la recepcionista"] = nurse != null and clerk != null and desk != null
	r["El vendedor abre la tienda del edificio"] = world.mart.shops.has("online") and world.story.actions.has("tienda_online") \
		and DB.npcs["centro_online_clerk"].talk_now().action == "tienda_online"
	r["La recepcionista tiene la acción online"] = world.story.actions.has("online") \
		and DB.npcs["centro_online_recepcionista"].talk_now().action == "online"

	# Enfermera: cura y marca el lugar al que volvés si perdés.
	GameState.party[0].hp = 1.0
	GameState.last_heal_position = Vector2.INF
	world.story.talk_to(nurse)
	await get_tree().create_timer(0.3).timeout
	await _until(func(): return not world.story.busy, 10.0)
	r["La enfermera cura"] = is_equal_approx(GameState.party[0].hp, GameState.party[0].max_hp())
	r["...y es el lugar al que volvés si perdés"] = world.streamer.world_data.zone_at(GameState.last_heal_position) == inside

	# Recepcionista: sin servidor avisa; con servidor conecta y dice quién está.
	Net.address = "127.0.0.1"
	Net.port = PORT
	answers = [2]
	world.story.talk_to(desk)
	await get_tree().create_timer(0.3).timeout
	await _until(func(): return not world.story.busy, 20.0)
	r["Recepcionista sin servidor: avisa y no queda conectado"] = not Net.is_online()
	var server := NetPeer.new()
	server.name = "TestServer"
	add_child(server)
	server.host(PORT, Net.game_version())
	answers = []
	world.story.talk_to(desk)
	await _until(func(): return is_instance_valid(world.online.screen), 15.0)
	var lobby: OnlineLobbyScreen = world.online.screen
	r["Recepcionista con servidor: te conecta y abre la sala"] = Net.is_online() and server.players.size() == 1 and lobby != null
	r["Lista de quién está, con su equipo"] = world.online.who_is_here().contains("(vos)") and world.online.who_is_here().contains("Charmander")
	if lobby != null:
		await _lobby_tests(server, lobby, desk)
	answers = [1]
	world.story.talk_to(desk)
	await get_tree().create_timer(0.3).timeout
	await _until(func(): return not world.story.busy, 20.0)
	r["Desconectarme: queda offline"] = not Net.is_online()
	server.close()

	# Volver afuera por la alfombra.
	t.facing = Vector2.DOWN
	await _walk("move_down", 2.5, "ciudad_verde")
	zone = world.streamer.zone_node("ciudad_verde")
	r["Por la alfombra se vuelve a Ciudad Verde, frente al edificio"] = _here() == "ciudad_verde" and zone != null \
		and zone.cell_at(t.global_position).distance_to(b.door) <= 2.0
	_results()


## O-2: la sala con otro jugador de prueba (Gary): desafiar, aceptar, elegir equipo, desafíos que llegan.
func _lobby_tests(server: NetPeer, lobby: OnlineLobbyScreen, desk: StoryNPC) -> void:
	var gary := NetPeer.new()
	gary.name = "Gary"
	add_child(gary)
	var glog := []
	gary.challenged.connect(func(id, _n, c): glog.append(["desafio", id, c]))
	gary.challenge_answered.connect(func(_id, ok, _m): glog.append(["respuesta", ok]))
	gary.match_choose.connect(func(mid, _o, _c, _t): glog.append(["elegir", mid]))
	gary.match_cancelled.connect(func(_mid, _w): glog.append(["cancelada"]))
	var has := func(kind: String): return glog.filter(func(e): return e[0] == kind)
	gary.join("127.0.0.1", PORT, {"version": Net.game_version(), "name": "Gary", "team": [{"species": "eevee", "level": 10}]})
	await _until(func(): return Net.players.size() == 2, 10.0)
	await get_tree().process_frame
	r["Sala: aparece el otro con su equipo y libre"] = _text_in(lobby).contains("Gary") and _text_in(lobby).contains("Libre")

	lobby.count = 3
	lobby.challenge(gary.my_id)
	await _until(func(): return not has.call("desafio").is_empty())
	r["Desafiar desde la sala: le llega (3 contra 3)"] = not has.call("desafio").is_empty() and has.call("desafio")[0][2] == 3 \
		and _text_in(lobby).contains("Esperando")
	gary.send_answer(Net.client.my_id, true)
	await _until(func(): return lobby.step == "elegir" and not has.call("elegir").is_empty())
	r["Acepta: a elegir equipo, con tiempo (con 1 Pokémon se elige 1)"] = lobby.step == "elegir" and lobby.pick_size() == 1 \
		and _text_in(lobby).contains("CONTRA GARY")
	lobby.toggle_pick(0)
	lobby.confirm_pick()
	gary.send_choice(has.call("elegir")[0][1], [CreatureInstance.create(DB.species["eevee"], 10)])
	await _until(func(): return lobby.step == "listo")
	r["Los dos eligieron: muestra contra qué vas"] = lobby.step == "listo" and lobby.match_info.opponent_team[0].species_id == "eevee"
	lobby.step = "sala"
	lobby.refresh()
	await _until(func(): return server.matches.is_empty() and Net.players.all(func(p): return p.status == "libre"))

	# Desafío que llega con la sala abierta: aparece arriba; se rechaza.
	glog.clear()
	gary.send_challenge(Net.client.my_id, 1)
	await _until(func(): return not lobby.incoming.is_empty())
	await get_tree().process_frame
	r["Desafío entrante en la sala: Aceptar / Rechazar"] = lobby.incoming.get("name") == "Gary" and _text_in(lobby).contains("te desafía")
	lobby.decline_incoming()
	await _until(func(): return not has.call("respuesta").is_empty())
	r["Rechazar: le llega al otro"] = not has.call("respuesta").is_empty() and not has.call("respuesta")[0][1]
	lobby.close()
	await _until(func(): return not world.story.busy, 10.0)

	# Con la sala cerrada: te pregunta; si aceptás, se abre la elección de equipo.
	glog.clear()
	answers = [0]
	gary.send_challenge(Net.client.my_id, 1)
	await _until(func(): return is_instance_valid(world.online.screen) and world.online.screen.step == "elegir", 10.0)
	r["Desafío con la sala cerrada: pregunta y abre la elección"] = is_instance_valid(world.online.screen) \
		and world.online.screen.step == "elegir" and world.trainer.locked
	gary.close()
	await _until(func(): return is_instance_valid(world.online.screen) and world.online.screen.step == "sala", 12.0)
	r["Si el otro se va mientras eligen: vuelve a la sala con aviso"] = is_instance_valid(world.online.screen) \
		and world.online.screen._status.text.contains("desconectó")
	world.online.screen.close()
	await _until(func(): return not world.story.busy and not world.trainer.locked, 10.0)
	r["Al cerrar la sala se puede caminar"] = not world.trainer.locked
	gary.queue_free()


## Todo el texto visible de una pantalla (labels y botones).
func _text_in(n: Node) -> String:
	var out := ""
	for c in n.get_children():
		if c is Label or c is Button:
			out += c.text + "\n"
		out += _text_in(c)
	return out


func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.set_setting("time_lock", 12.0)
	var b: ExtraBuilding = ExtraContent.buildings[0]
	await _go("ciudad_verde", b.door + Vector2i(0, 3))
	await get_tree().create_timer(2.5).timeout
	await _go("centro_online", Vector2i(7, 5))
	await get_tree().create_timer(2.5).timeout
	# La sala con dos jugadores de prueba; después, la elección de equipo.
	var server := NetPeer.new()
	add_child(server)
	server.host(PORT, Net.game_version())
	var friends := []
	for f in [["Gary", [{"species": "eevee", "level": 14}, {"species": "pidgeotto", "level": 18}]],
			["Misty", [{"species": "staryu", "level": 18}, {"species": "starmie", "level": 21}, {"species": "goldeen", "level": 16}]]]:
		var p := NetPeer.new()
		add_child(p)
		p.join("127.0.0.1", PORT, {"version": Net.game_version(), "name": f[0], "team": f[1]})
		friends.append(p)
	GameState.party.append(CreatureInstance.create(DB.species["pidgey"], 9))
	GameState.party.append(CreatureInstance.create(DB.species["rattata"], 8))
	Net.address = "127.0.0.1"
	Net.port = PORT
	Net.go_online()
	await _until(func(): return Net.players.size() == 3, 10.0)
	world.online.open_lobby()
	var lobby: OnlineLobbyScreen = world.online.screen
	await get_tree().create_timer(1.5).timeout
	friends[1].send_challenge(Net.client.my_id, 3)
	await get_tree().create_timer(1.5).timeout
	lobby.accept_incoming()
	await _until(func(): return lobby.step == "elegir")
	lobby.toggle_pick(0)
	lobby.toggle_pick(2)
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()


func _entry(data: WorldData, id: String) -> ZoneEntry:
	for z in data.zones:
		if z.id == id:
			return z
	return null


func _here() -> String:
	var e: ZoneEntry = world.streamer.world_data.zone_at(world.trainer.global_position)
	return e.id if e != null else ""


func _go(zone_id: String, cell: Vector2i) -> void:
	await world.story.teleport(zone_id, cell)
	await get_tree().create_timer(0.3).timeout


## Camina `time` segundos (o hasta llegar a la zona `until`, si se da).
func _walk(action: String, time: float, until: String = "") -> void:
	await get_tree().physics_frame
	Input.action_press(action)
	var t := 0.0
	while t < time and (until == "" or _here() != until):
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	Input.action_release(action)
	await get_tree().create_timer(0.8).timeout  # el fundido de la puerta


## Avanza los diálogos y contesta las preguntas con `answers` (en orden).
func _dialogs() -> void:
	while is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		var d: DialogBox = world.story.dialog
		if d.active:
			if d._choosing:
				d.choose(answers.pop_front() if not answers.is_empty() else 0)
			else:
				d.advance()


func _until(cond: Callable, timeout: float = 5.0) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()


func _results() -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[online-building] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-online-building] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
