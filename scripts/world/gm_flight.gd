class_name GmFlight
extends Node
## "volar" de la consola de Game Master (pedido del usuario 2026-10-29): una cámara libre para mirar el mapa. El
## juego queda en pausa (nadie se mueve, no salen salvajes ni te ven entrenadores, no corre la hora) y el entrenador
## se queda donde estaba: al volver, todo sigue igual. Lo que la cámara cruza NO cuenta como visitado (ni para el
## Mapa ni para los globos): al volver se restauran las zonas visitadas de antes.

const SPEED := 260.0
const FAST := 3.0
const ZOOM_MIN := 1.0
const ZOOM_STEP := 1.15
## Con la cámara alejada se ve más: las zonas se cargan más lejos mientras volás.
const LOAD_MARGIN := 46
const UNLOAD_MARGIN := 58

var world: Node
var active := false

var _eye: Node2D
var _visited_before: Dictionary = {}
var _zoom_before := Vector2.ONE
var _margins := Vector2i.ZERO
var _was_paused := false


func _ready() -> void:
	world = get_parent()
	process_mode = Node.PROCESS_MODE_ALWAYS


## Por qué no se puede volar ahora ("" = se puede).
func why_not() -> String:
	if active:
		return "Ya estás volando."
	if world.combat.in_battle or world.arena.active:
		return "En plena pelea no se puede volar."
	if world.balloon.flying or world.warps.busy:
		return "Esperá a llegar."
	if world.online.battle != null and world.online.battle.active:
		return "En la pelea online no se puede volar."
	return ""


func start() -> void:
	if why_not() != "":
		return
	active = true
	_visited_before = GameState.visited_zones.duplicate()
	_was_paused = get_tree().paused
	get_tree().paused = true
	var cam: CameraRig = world.camera
	_zoom_before = cam.zoom
	_eye = Node2D.new()
	_eye.name = "GmEye"
	world.add_child(_eye)
	_eye.global_position = cam.global_position
	cam.target = _eye
	cam.process_mode = Node.PROCESS_MODE_ALWAYS
	var st: ZoneStreamer = world.streamer
	st.process_mode = Node.PROCESS_MODE_ALWAYS
	_margins = Vector2i(st.load_margin, st.unload_margin)
	st.load_margin = LOAD_MARGIN
	st.unload_margin = UNLOAD_MARGIN
	st.target = _eye
	world.get_node("CloudShadows").visible = false
	Events.message_requested.emit("Modo vuelo (Game Master): Esc para volver.")


## Vuelve al entrenador: todo como estaba (las zonas que cruzaste no quedan visitadas).
func stop() -> void:
	if not active:
		return
	active = false
	var cam: CameraRig = world.camera
	var st: ZoneStreamer = world.streamer
	var t: Trainer = world.trainer
	st.load_margin = _margins.x
	st.unload_margin = _margins.y
	st.load_around_now(t.global_position)  # (el suelo del entrenador, antes de que se mueva nada)
	st.target = cam
	cam.target = t
	cam.zoom = _zoom_before
	cam.snap()
	cam.process_mode = Node.PROCESS_MODE_INHERIT
	st.process_mode = Node.PROCESS_MODE_INHERIT
	_eye.queue_free()
	# Que el streamer vuelva a "entrar" a la zona del entrenador (música, luz, nombre) y deshacer lo visitado volando.
	st.current = null
	st._timer = 0.0
	st._process(0.0)
	GameState.visited_zones = _visited_before
	world.get_node("CloudShadows").visible = not (st.current != null and st.current.interior)
	get_tree().paused = _was_paused


func _process(delta: float) -> void:
	if not active:
		return
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed := SPEED * (FAST if Input.is_action_pressed("run") else 1.0)
	# (más rápido con la cámara alejada: a zoom 1 se ve 3 veces más mapa)
	_eye.global_position += dir * speed * delta * (3.0 / world.camera.zoom.x)
	world.camera.snap()


func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		stop()
	elif event is InputEventMouseButton and event.pressed:
		var cam: CameraRig = world.camera
		var z := cam.zoom.x
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			z = minf(_zoom_before.x, z * ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			z = maxf(ZOOM_MIN, z / ZOOM_STEP)
		else:
			return
		cam.zoom = Vector2(z, z)
		get_viewport().set_input_as_handled()
