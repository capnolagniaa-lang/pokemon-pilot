class_name DayNightTests
extends Node
## Autotest del día y la noche (DayNight, docs/PLAN_DIA_NOCHE.md, parte A):
##   godot --headless --path . --quit-after 30000 -- --autotest-daynight
## Vitrina (Ruta 1, Ciudad Verde y Ciudad Plateada a las 12, 18:30, 23 y 6:30; compararla con
## docs/referencias/iluminacion/):
##   godot --path . --quit-after 700 --write-movie out/f.png --fixed-fps 30 -- --showcase-daynight

const SHOW_ZONES := [["pueblo_paleta", Vector2i(20, 22)], ["ruta1", Vector2i(48, 35)], ["ciudad_verde", Vector2i(48, 35)], ["ciudad_plateada", Vector2i(48, 35)],
	["ciudad_celeste", Vector2i(48, 35)], ["ciudad_carmin", Vector2i(48, 35)],
	["ciudad_azulona", Vector2i(48, 35)], ["ciudad_azafran", Vector2i(48, 35)]]
const SHOW_HOURS := [12.0, 18.5, 23.0, 6.5]
const SHOW_FRAMES := 14

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	# --- Reglas (sin mundo) ---
	r["Fases: 3 noche, 6 amanecer, 12 día, 18 atardecer, 21 noche"] = DayNight.phase_of(3.0) == "noche" \
		and DayNight.phase_of(6.0) == "amanecer" and DayNight.phase_of(12.0) == "dia" \
		and DayNight.phase_of(18.0) == "atardecer" and DayNight.phase_of(21.0) == "noche"
	r["A las 24 se ve igual que a las 0"] = DayNight.look_at(24.0)[1] == DayNight.look_at(0.0)[1]
	r["Al mediodía, el color de siempre (sin oscurecer)"] = DayNight.look_at(12.0)[1].is_equal_approx(DayNight.INDOOR[1])
	r["De noche, luz de luna (más oscuro y azulado)"] = DayNight.look_at(23.0)[1].get_luminance() < 0.7 and DayNight.look_at(23.0)[1].b > DayNight.look_at(23.0)[1].r
	r["Al atardecer, dorado (más rojo que azul) y sombras largas"] = DayNight.look_at(18.5)[1].r > DayNight.look_at(18.5)[1].b + 0.1 \
		and DayNight.sun_at(18.5)[2] > 2.0
	# El sol hace un arco (sale por la derecha, pasa por arriba, se pone por la izquierda): las sombras giran y se
	# estiran solas a lo largo del día (pedido del usuario 2026-10-30).
	var m7: Array = DayNight.sun_at(7.0)
	var m12: Array = DayNight.sun_at(12.5)
	var m18: Array = DayNight.sun_at(18.0)
	r["Sombras: a la mañana a la izquierda (%.2f), al mediodía abajo (%.2f), a la tarde a la derecha (%.2f)" % [
		m7[1].x, m12[1].x, m18[1].x]] = m7[1].x < -0.5 and absf(m12[1].x) < 0.3 and m12[1].y > 0.8 and m18[1].x > 0.5
	r["Sombras cortas al mediodía (×%.2f) y largas a la mañana (×%.2f)" % [m12[2], m7[2]]] = m12[2] <= 1.0 and m7[2] > 1.6
	r["Las sombras se mueven de a poco (12:00 → 12:06 gira %.2f°)" % rad_to_deg(DayNight.sun_at(12.0)[1].angle_to(
		DayNight.sun_at(12.1)[1]))] = absf(DayNight.sun_at(12.0)[1].angle_to(DayNight.sun_at(12.1)[1])) > 0.003
	r["Al ponerse el sol la sombra se desvanece (sin saltos de lado)"] = DayNight.sun_at(19.45)[3] < 0.05 		and DayNight.sun_at(19.55)[3] < 0.05
	r["De noche, sombras de luna más suaves"] = DayNight.sun_at(0.5)[3] > 0.2 and DayNight.sun_at(0.5)[3] < DayNight.sun_at(12.0)[3]
	r["Ajuste 'time_lock' por defecto: el tiempo corre (-1)"] = float(GameState.default_settings().get("time_lock", 0)) < 0.0
	var in_screen := false
	for section in GameSettingsScreen.SECTIONS:
		for row in section[1]:
			in_screen = in_screen or row[0] == "time_lock"
	r["'Hora fija' está en Ajustes del juego"] = in_screen

	# --- Guardado ---
	GameState.new_game(DB.species["charmander"])
	# La luz de los tiles (sol, luna, sombras del mapa) se prueba con la skin clásica: sobre una zona pintada se apagan a
	# propósito (la pintura trae su luz; eso lo prueba --autotest-repaint).
	GameState.set_setting("skin", PaintedZone.CLASSIC)
	r["Partida nueva: arranca a las %.0f" % GameState.START_HOUR] = GameState.time_of_day == GameState.START_HOUR
	GameState.time_of_day = 19.25
	var d := GameState.to_dict()
	GameState.time_of_day = 3.0
	GameState.from_dict(d)
	r["La hora se guarda con la partida"] = is_equal_approx(GameState.time_of_day, 19.25)
	d.erase("time_of_day")
	GameState.from_dict(d)
	r["Partida vieja sin hora: arranca a las %.0f" % GameState.START_HOUR] = GameState.time_of_day == GameState.START_HOUR

	# --- En el mundo: corre la hora ---
	await _start("ruta1", Vector2i(48, 35))
	var dn: DayNight = world.day_night
	r["El mundo tiene su DayNight"] = dn != null and not dn.indoor
	var phases := []
	Events.time_changed.connect(func(_h: float, p: String): phases.append(p))
	GameState.time_of_day = 10.0
	var t0 := Time.get_ticks_msec()
	await get_tree().create_timer(1.5).timeout
	var real := (Time.get_ticks_msec() - t0) / 1000.0
	var advanced := GameState.time_of_day - 10.0
	r["1 hora = 1 minuto: en %.1f s avanzó %.3f h" % [real, advanced]] = absf(advanced - real / 60.0) < 0.01
	var daylight: CanvasModulate = world.get_node("Daylight")
	var mat: ShaderMaterial = world.get_node("PostProcess/Screen").material
	GameState.set_setting("time_lock", 23.0)
	await get_tree().process_frame
	await get_tree().process_frame
	r["Hora fija a las 23: noche (oscuridad %.2f)" % dn.darkness] = is_equal_approx(GameState.time_of_day, 23.0) \
		and dn.darkness > 0.85 and daylight.color.get_luminance() < 0.7
	r["Se avisó la noche (Events.time_changed)"] = "noche" in phases
	r["De noche, la luna apenas brilla desde una esquina (%.2f)" % float(mat.get_shader_parameter("sun_strength"))] = 		float(mat.get_shader_parameter("sun_strength")) > 0.0 and float(mat.get_shader_parameter("sun_strength")) < 0.08
	# Las nubes multiplican: con la intensidad en 0 no tocan nada (antes, con modulate.a bajo, oscurecían toda la
	# pantalla entre las 20 y las 21:30) y no les pega el Daylight (unshaded: si no, la noche se aplicaba dos veces).
	var clouds: CanvasItem = world.get_node("CloudShadows")
	r["De noche las nubes no oscurecen nada (intensidad %.2f, opacidad %.2f)" % [
		float((clouds.material as ShaderMaterial).get_shader_parameter("amount")), clouds.modulate.a]] = 		float((clouds.material as ShaderMaterial).get_shader_parameter("amount")) == 0.0 and clouds.modulate.a == 1.0 		and "unshaded" in (clouds.material as ShaderMaterial).shader.code
	var clock: HudClock = world.get_node_or_null("UI/HUD/Clock")
	r["Reloj arriba a la izquierda (%s): 21:36 = %s, 7:05 = %s" % [clock != null, HudClock.text_for(21.6),
		HudClock.text_for(7.0834)]] = clock != null and clock.visible and clock.position.x < 40 and clock.position.y < 40 		and HudClock.text_for(21.6) == "21:36" and HudClock.text_for(7.0834) == "07:05" and HudClock.text_for(24.0) == "00:00"
	await get_tree().create_timer(2.5).timeout
	var fx: Node = world.get_node("AmbientFX")
	r["De noche, afuera, titilan estrellitas (%.2f)" % fx._star_fade] = fx._star_fade > 0.5
	GameState.set_setting("time_lock", 12.0)
	await get_tree().process_frame
	await get_tree().process_frame
	r["Al mediodía: sin oscuridad, con sol de esquina (%.2f)" % float(mat.get_shader_parameter("sun_strength"))] = \
		dn.darkness < 0.05 and float(mat.get_shader_parameter("sun_strength")) > 0.1 		and float(mat.get_shader_parameter("sun_strength")) < 0.25 and "dia" in phases
	r["Sombras del mediodía hacia abajo (%.2f, %.2f)" % [dn.shadow_direction.x, dn.shadow_direction.y]] = dn.shadow_direction.y > 0.5
	GameState.set_setting("time_lock", 18.5)
	await get_tree().process_frame
	await get_tree().process_frame
	r["Al atardecer las sombras se estiran (×%.1f) y caen a la derecha" % dn.shadow_length] = dn.shadow_length > 2.0 \
		and dn.shadow_direction.x > 0.5 and "atardecer" in phases

	# --- Sombras largas (parte B) ---
	var zone: Node2D = world.streamer.loaded.get("ruta1")
	var zs: ZoneShadows = zone.get_node_or_null("SunShadows") if zone != null else null
	var casters := 0
	if zs != null:
		var img: Image = (zs.material as ShaderMaterial).get_shader_parameter("mask").get_image()
		for y in range(0, img.get_height(), ZoneShadows.MASK_PX):
			for x in range(0, img.get_width(), ZoneShadows.MASK_PX):
				if img.get_pixel(x, y).b > 0.5:
					casters += 1
	r["La zona exterior tiene su máscara de sombras (%d celdas proyectan)" % casters] = zs != null and casters > 50 \
		and zs.visible
	var trainer_shadow: SunShadow = world.trainer.get_node_or_null("SunShadow")
	r["El entrenador tiene sombra larga"] = trainer_shadow != null and trainer_shadow.source == world.trainer.get_node("Sprite")
	r["Tu Pokémon tiene sombra larga"] = world.companion != null and world.companion.get_node_or_null("SunShadow") is SunShadow

	# --- Ventanas prendidas (parte C) --- (con la skin clásica: con una skin repintada las ventanas vienen pintadas)
	GameState.set_setting("skin", PaintedZone.CLASSIC)
	r["Hay ventanas detectadas (%d metatiles con vidrio)" % ZoneLights.windows().size()] = ZoneLights.windows().size() > 100
	GameState.set_setting("time_lock", 23.0)
	await _start("pueblo_paleta", Vector2i(20, 22))
	var lights: ZoneLights = world.streamer.loaded["pueblo_paleta"].get_node_or_null("NightLights")
	await get_tree().process_frame
	r["Pueblo Paleta tiene ventanas (%d celdas, %d tiras)" % [lights.cells.size() if lights else 0,
		lights.strips.size() if lights else 0]] = lights != null and lights.cells.size() >= 8 and lights.strips.size() >= 4
	r["De noche las ventanas están prendidas"] = lights != null and lights.visible
	GameState.set_setting("time_lock", 12.0)
	await get_tree().process_frame
	await get_tree().process_frame
	r["Al mediodía están apagadas"] = lights != null and not lights.visible
	var lamps: StreetLamps = world.streamer.loaded["pueblo_paleta"].get_node_or_null("StreetLamps")
	r["Pueblo Paleta tiene faroles en los caminos (%d)" % (lamps.spots.size() if lamps else 0)] = lamps != null 		and lamps.spots.size() >= 2
	r["Al mediodía los faroles están apagados"] = lamps != null and lamps._lights.all(func(l): return not l.visible)
	r["La Ruta 1 (sin casas) no tiene luces"] = world.streamer.loaded.get("ruta1") == null \
		or world.streamer.loaded["ruta1"].get_node_or_null("NightLights") == null

	# --- Interior: luz pareja aunque sea de noche ---
	GameState.set_setting("time_lock", 23.0)
	await _start("ciudad_verde_centro", Vector2i(7, 8))
	dn = world.day_night
	daylight = world.get_node("Daylight")
	mat = world.get_node("PostProcess/Screen").material
	await get_tree().process_frame
	r["En un interior de noche: luz pareja, sin sol (oscuridad %.2f)" % dn.darkness] = dn.indoor and dn.darkness == 0.0 \
		and daylight.color.is_equal_approx(DayNight.INDOOR[1]) and float(mat.get_shader_parameter("sun_strength")) == 0.0
	await get_tree().process_frame
	r["En un interior de noche no hay estrellitas"] = world.get_node("AmbientFX")._star_fade == 0.0
	r["En un interior no hay ventanas prendidas"] = \
		world.streamer.loaded["ciudad_verde_centro"].get_node_or_null("NightLights") == null
	r["En un interior no hay sombras largas"] = not dn.casts_shadows and world.streamer.loaded.values().all(
		func(z): return z.get_node_or_null("SunShadows") == null or not z.get_node("SunShadows").visible)
	# --- Cuevas: oscuras y frías, con antorchas y cristales (de día también) ---
	GameState.set_setting("time_lock", 12.0)
	await _start("mt_moon", Vector2i(42, 35))
	dn = world.day_night
	daylight = world.get_node("Daylight")
	await get_tree().process_frame
	var cave_lights: CaveLights = world.streamer.loaded["mt_moon"].get_node_or_null("CaveLights")
	r["En Mt. Moon al mediodía: oscuro y frío (oscuridad %.2f)" % dn.darkness] = dn.in_cave and dn.darkness > 0.9 		and daylight.color.b > daylight.color.r + 0.1
	r["Mt. Moon tiene antorchas y cristales (%d luces)" % (cave_lights.spots.size() if cave_lights else 0)] = 		cave_lights != null and cave_lights.spots.size() >= 5 		and cave_lights.spots.any(func(s): return s[1] == "antorcha") and cave_lights.spots.any(func(s): return s[1] == "cristales")
	var lamp: PointLight2D = world.trainer.get_node_or_null("CaveLight")
	r["En la cueva el entrenador lleva una luz chica"] = lamp != null and lamp.visible
	r["Una ciudad no tiene luces de cueva"] = world.streamer.loaded.values().all(
		func(z): return z.name == "mt_moon" or z.get_node_or_null("CaveLights") == null or z.zone_id.begins_with("mt_moon"))

	GameState.set_setting("time_lock", -1.0)
	await get_tree().process_frame
	r["Sin hora fija, el tiempo vuelve a correr"] = not GameState.settings.has("time_lock")

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[daynight] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-daynight] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina: cada zona a cada hora, SHOW_FRAMES cuadros (imprime qué cuadros son cada una).
func showcase() -> void:
	GameState.new_game(DB.species["charmander"])
	for z in SHOW_ZONES:
		await _start(z[0], z[1])
		world.get_node("UI").visible = false
		# Si la zona tiene ventanas, la cámara va frente a las casas.
		var zone: Node2D = world.streamer.loaded.get(z[0])
		var lights: ZoneLights = zone.get_node_or_null("NightLights") if zone != null else null
		if lights != null and not lights.strips.is_empty():
			var s: Rect2i = lights.strips[lights.strips.size() / 2]
			world.trainer.global_position = zone.to_global(Vector2(s.position.x + s.size.x / 2.0, s.position.y + 3.0) * Zone.TILE)
			if world.companion != null:
				world.companion.global_position = world.trainer.global_position + Vector2(24, 0)
			await get_tree().create_timer(0.3).timeout
		for h in SHOW_HOURS:
			GameState.set_setting("time_lock", h)
			var first := Engine.get_frames_drawn()
			for i in SHOW_FRAMES:
				await get_tree().process_frame
			print("[showcase-daynight] %s %.1f h: cuadros %d-%d" % [z[0], h, first, Engine.get_frames_drawn()])
	get_tree().quit()


## Vitrina de una cueva: Mt. Moon frente a varias luces (imprime los cuadros).
##   godot --path . --quit-after 160 --write-movie out/f.png --fixed-fps 30 -- --showcase-cave
func showcase_cave() -> void:
	GameState.new_game(DB.species["charmander"])
	for zone_id in ["mt_moon", "tunel_roca", "islas_espuma"]:
		await _start(zone_id, Vector2i(10, 10))
		world.get_node("UI").visible = false
		var zone: Node2D = world.streamer.loaded.get(zone_id)
		var cl: CaveLights = zone.get_node_or_null("CaveLights") if zone != null else null
		if cl != null and not cl.spots.is_empty():
			var c: Vector2i = cl.spots[cl.spots.size() / 2][0]
			world.trainer.global_position = zone.to_global(Vector2(c.x + 1.5, c.y + 3.0) * Zone.TILE)
			if world.companion != null:
				world.companion.global_position = world.trainer.global_position + Vector2(24, 0)
		var first := Engine.get_frames_drawn()
		for i in 30:
			await get_tree().process_frame
		print("[showcase-cave] %s (%d luces): cuadros %d-%d" % [zone_id, cl.spots.size() if cl else 0, first,
			Engine.get_frames_drawn()])
	get_tree().quit()


func _start(zone_id: String, cell: Vector2i) -> void:
	var wd: WorldData = DB.config.world
	for z in wd.zones:
		if z.id == zone_id:
			GameState.trainer_position = Vector2((z.origin + cell) * wd.tile_size) + Vector2.ONE * wd.tile_size / 2.0
	GameState.wilds_enabled = false
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	world = get_tree().current_scene
	await get_tree().create_timer(0.5).timeout
