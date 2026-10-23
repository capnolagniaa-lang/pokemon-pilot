class_name TrainerBattle
extends Node
## Combate contra un entrenador en su arena (docs/PLAN_ENTRENADORES.md, E-1; decisiones del usuario 2026-10-23):
##  · fundido a negro y aparecés en una arena aparte (ArenaData: zona de tiles de FireRed + ArenaDecor), lejos del
##    mundo; al terminar volvés exactamente adonde estabas;
##  · 1 contra 1 con cambios: un Pokémon de cada lado; cuando uno cae sale el siguiente (vos también cambiás con
##    1-6 cuando querés); el entrenador a veces retira al suyo si está muy golpeado y tiene otro sano;
##  · ganar: EXP por cada Pokémon que debilitás y la frase de derrota del rival; perder (sin Pokémon en pie): volvés
##    al último lugar donde te curaron (Centro Pokémon o casa) con el equipo curado.
## Lo usan StoryDirector (entrenadores de la historia) y los entrenadores vivos. `await start(...)` devuelve
## "win" o "lose".

signal finished(result: String)

## Las arenas se cargan acá, lejos de toda zona del mundo.
const ARENA_ORIGIN := Vector2(-40000, -40000)
const FADE := 0.35
## Espera entre que cae un Pokémon y sale el siguiente.
const NEXT_DELAY := 1.2
## El entrenador piensa en retirar a su Pokémon cuando le queda menos de esto de vida.
const RETREAT_BELOW := 0.25
const RETREAT_CHANCE := 0.35

var world: Node
var active := false
var arena: Zone
var arena_data: ArenaData
var decor: ArenaDecor
var foe: Creature
var foe_team: Array[CreatureInstance] = []
var foe_name := ""
var foe_figure: Sprite2D
var leader := false
var result := ""
var _return_pos := Vector2.ZERO
var _retreat_checked := {}  # instancia -> ya pensó en retirarla
var _waiting := false
## La pelea empezó (ya salieron los dos Pokémon): recién ahí se vigila quién cae.
var _fighting := false
## Perder no te manda al último Centro (la 1ª pelea contra el rival): la historia sigue ahí con el equipo curado.
var _no_blackout := false
var _fade: ColorRect
var _banner: Label
var _sub: Label


func _ready() -> void:
	world = get_parent()
	var layer := CanvasLayer.new()
	layer.layer = 9
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade)
	_banner = UiStyle.label("", 40, UiStyle.ACCENT)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.position = Vector2(0, 250)
	_banner.size = Vector2(1280, 60)
	_banner.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_banner.add_theme_constant_override("outline_size", 10)
	_banner.modulate.a = 0.0
	layer.add_child(_banner)
	_sub = UiStyle.label("", 22)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.position = Vector2(0, 310)
	_sub.size = Vector2(1280, 40)
	_sub.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_sub.add_theme_constant_override("outline_size", 8)
	_sub.modulate.a = 0.0
	layer.add_child(_sub)


## Arranca la pelea. `opts`: name, title, team (Array[CreatureInstance]), arena_id, texture (sprite del entrenador,
## hoja de FireRed), leader (líder de gimnasio: presentación de jefe), defeat_lines (lo que dice al perder).
func start(opts: Dictionary) -> String:
	if active:
		return ""
	active = true
	_fighting = false
	result = ""
	foe_name = opts.get("name", "Entrenador")
	_no_blackout = opts.get("no_blackout", false)
	leader = opts.get("leader", false)
	foe_team.assign(opts.get("team", []))
	_retreat_checked.clear()
	arena_data = load("res://data/arenas/%s.tres" % opts.get("arena_id", "arena_campo"))
	var t: Trainer = world.trainer
	t.locked = true
	t.autopilot = Vector2.ZERO
	if world.combat.in_battle:
		world.combat.end_battle(true)
	await _fade_to(1.0)
	_return_pos = t.global_position
	_enter_arena(opts.get("texture", null))
	await get_tree().process_frame
	await _fade_to(0.0)
	var title: String = opts.get("title", "")
	var who := ("%s %s" % [title, foe_name]).strip_edges()
	if arena_data.epic:
		Events.camera_shake.emit(6.0)
		await _show_banner(arena_data.display_name.to_upper(), "¡%s te desafía!" % who, 2.2)
	else:
		await _show_banner("¡%s te desafía!" % who, "", 1.4)
	_bring_player_mon()
	_send_next()
	_fighting = true
	await finished
	var lines: PackedStringArray = opts.get("defeat_lines", PackedStringArray())
	if result == "win":
		await get_tree().create_timer(0.8).timeout
		await _show_banner("¡GANASTE!", "Le ganaste a %s" % who, 1.6)
		if not lines.is_empty():
			await world.story.dialog.say(foe_name, lines)
	else:
		await _show_banner("Te quedaste sin Pokémon...", "", 1.6)
	await _fade_to(1.0)
	_leave_arena()
	await get_tree().process_frame
	await _fade_to(0.0)
	if result == "lose" and not _no_blackout:
		await world.story.dialog.say("", PackedStringArray(["Volviste corriendo a curar a tus Pokémon..."]))
	t.locked = false
	active = false
	return result


# --- Entrar y salir de la arena -------------------------------------------------------------------------------

func _enter_arena(texture: Texture2D) -> void:
	arena = load(arena_data.scene_path).instantiate()
	arena.position = ARENA_ORIGIN
	world.get_node("YSort/Zones").add_child(arena)
	decor = ArenaDecor.new()
	arena.add_child(decor)
	decor.setup(arena_data)
	world.trainer.global_position = cell_pos(arena_data.player_cell)
	if texture != null:
		foe_figure = Sprite2D.new()
		foe_figure.texture = texture
		foe_figure.hframes = maxi(1, texture.get_width() / 16)
		foe_figure.frame = 0
		foe_figure.offset = Vector2(0, -16)
		foe_figure.global_position = cell_pos(arena_data.foe_trainer_cell)
		world.entities.add_child(foe_figure)
	world.camera.target = world.trainer
	world.camera.snap()


func _leave_arena() -> void:
	world.combat.arena_lock = false
	world.combat.end_battle(true)
	if is_instance_valid(foe):
		foe.queue_free()
	foe = null
	if is_instance_valid(foe_figure):
		foe_figure.queue_free()
	if is_instance_valid(arena):
		arena.queue_free()
	arena = null
	var t: Trainer = world.trainer
	var back := _return_pos
	if result == "lose":
		GameState.heal_party()
		if GameState.last_heal_position != Vector2.INF and not _no_blackout:
			back = GameState.last_heal_position
	world.streamer.load_around_now(back)
	t.global_position = back
	t.trail = [back]
	world.camera.target = t
	world.camera.snap()
	if not is_instance_valid(world.companion) or world.companion.is_down():
		world.respawn_companion()
	if is_instance_valid(world.companion):
		world.companion.global_position = back + Vector2(0, -12)
		world.companion.statuses.clear()
		world.companion.machine.transition_to("follow")


func cell_pos(cell: Vector2i) -> Vector2:
	return arena.to_global(arena.ground.map_to_local(cell))


# --- La pelea ------------------------------------------------------------------------------------------------

## Saca al siguiente Pokémon del rival (el primero que no esté debilitado). Sin ninguno: ganaste.
func _send_next(skip: CreatureInstance = null) -> void:
	var next: CreatureInstance = null
	for inst in foe_team:
		if inst.hp > 0.0 and inst != skip:
			next = inst
			break
	if next == null:
		_end("win")
		return
	var c: Creature = WildSpawner.CreatureScene.instantiate()
	c.instance = next
	c.team = Creature.Team.WILD
	c.owner_name = foe_name
	c.temperament = DB.temperaments.get("entrenador")
	c.position = cell_pos(arena_data.foe_mon_cell)
	world.entities.add_child(c)
	c.home = c.global_position
	foe = c
	Fx.burst(world.entities, c.global_position, Color(1.0, 0.4, 0.35), 18, 60.0)
	Events.message_requested.emit("¡%s saca a %s!" % [foe_name, next.display_name()])
	if leader and next == foe_team[-1]:
		Events.camera_shake.emit(5.0)  # el último del líder entra con todo
	_engage()


## Saca a tu Pokémon a la cancha (el activo o, si está debilitado, el primero sano).
func _bring_player_mon() -> void:
	if GameState.active() == null or GameState.active().hp <= 0.0:
		var i := _first_healthy()
		if i < 0:
			_end("lose")
			return
		GameState.set_active(i)
	if not is_instance_valid(world.companion) or world.companion.is_down():
		world.respawn_companion()
	var c: Creature = world.companion
	if not is_instance_valid(c):
		_end("lose")
		return
	c.global_position = cell_pos(arena_data.player_mon_cell)
	world.combat.arena_lock = true
	if world.combat.in_battle:
		world.combat.take_control(c)
	else:
		world.combat.start_battle()
	_engage()


## Los dos se apuntan (el rival entra en la lista de enemigos del combate).
func _engage() -> void:
	var c: Creature = world.companion
	if not is_instance_valid(foe) or not is_instance_valid(c):
		return
	foe.target = c
	if not world.combat.enemies.has(foe):
		world.combat.enemies.append(foe)
	if foe.machine.current_name() != "chase":
		foe.machine.transition_to("chase")


func _first_healthy() -> int:
	for i in GameState.party.size():
		if GameState.party[i].hp > 0.0:
			return i
	return -1


func _physics_process(_delta: float) -> void:
	if not active or not _fighting or result != "" or _waiting or arena == null:
		return
	var c: Creature = world.companion
	# Tu Pokémon cayó: sale el siguiente sano (o perdiste).
	if not is_instance_valid(c) or c.is_down():
		_waiting = true
		await get_tree().create_timer(NEXT_DELAY).timeout
		_waiting = false
		if result != "":
			return
		var i := _first_healthy()
		if i < 0:
			_end("lose")
			return
		GameState.set_active(i)  # sale el siguiente sano (sin la recarga del cambio a mano)
		_bring_player_mon()
		return
	if is_instance_valid(foe) and foe.target != c:
		_engage()  # cambiaste de Pokémon con 1-6
	# El del rival cayó: sale el siguiente.
	if not is_instance_valid(foe) or foe.is_down():
		_waiting = true
		await get_tree().create_timer(NEXT_DELAY).timeout
		_waiting = false
		if result == "":
			if is_instance_valid(foe):
				foe.queue_free()
			_send_next()
		return
	_maybe_retreat()


## El entrenador retira a su Pokémon muy golpeado si tiene otro sano (una vez por Pokémon, con probabilidad).
func _maybe_retreat() -> void:
	var inst := foe.instance
	if _retreat_checked.has(inst) or foe.health.ratio() > RETREAT_BELOW:
		return
	_retreat_checked[inst] = true
	var other := foe_team.any(func(m): return m != inst and m.hp > m.max_hp() * 0.5)
	if not other or randf() >= RETREAT_CHANCE:
		return
	Events.message_requested.emit("¡%s retira a %s!" % [foe_name, inst.display_name()])
	world.combat.enemies.erase(foe)
	Fx.burst(world.entities, foe.global_position, Color(1.0, 0.4, 0.35), 12, 40.0)
	foe.queue_free()
	foe = null
	_send_next(inst)


func _end(r: String) -> void:
	if result != "":
		return
	result = r
	_fighting = false
	world.combat.arena_lock = false
	world.combat.end_battle(true)
	finished.emit(r)


# --- Presentación --------------------------------------------------------------------------------------------

## Fundido a negro (también lo usa StoryDirector.teleport).
func fade_to(a: float) -> void:
	await _fade_to(a)


func _fade_to(a: float) -> void:
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", a, FADE)
	await tw.finished


func _show_banner(text: String, sub: String, time: float) -> void:
	_banner.text = text
	_sub.text = sub
	_banner.scale = Vector2(1.15, 1.15)
	_banner.pivot_offset = _banner.size / 2.0
	var tw := create_tween().set_parallel()
	tw.tween_property(_banner, "modulate:a", 1.0, 0.2)
	tw.tween_property(_banner, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_sub, "modulate:a", 1.0, 0.3)
	await get_tree().create_timer(time).timeout
	var out := create_tween().set_parallel()
	out.tween_property(_banner, "modulate:a", 0.0, 0.25)
	out.tween_property(_sub, "modulate:a", 0.0, 0.25)
	await out.finished
