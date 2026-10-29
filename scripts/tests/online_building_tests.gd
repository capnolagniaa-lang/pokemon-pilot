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
	answers = [0, 2]
	world.story.talk_to(desk)
	await get_tree().create_timer(0.3).timeout
	await _until(func(): return not world.story.busy, 20.0)
	r["Recepcionista con servidor: te conecta"] = Net.is_online() and server.players.size() == 1
	r["Lista de quién está, con su equipo"] = world.online.who_is_here().contains("(vos)") and world.online.who_is_here().contains("Charmander")
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


func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.set_setting("time_lock", 12.0)
	var b: ExtraBuilding = ExtraContent.buildings[0]
	await _go("ciudad_verde", b.door + Vector2i(0, 3))
	await get_tree().create_timer(2.5).timeout
	await _go("centro_online", Vector2i(7, 5))
	await get_tree().create_timer(2.5).timeout
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


func _until(cond: Callable, timeout: float) -> void:
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
