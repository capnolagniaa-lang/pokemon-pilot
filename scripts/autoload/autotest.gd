extends Node
## Prueba automática (solo con: godot --path . -- --autotest).
## Elige inicial, camina de la Pradera al Bosque y verifica zonas y seguimiento del Pokémon.

var enabled := false
var _time := 0.0
var _zones_seen: Array[String] = []
var _max_follow_gap := 0.0
var _world: Node


func _ready() -> void:
	enabled = "--autotest" in OS.get_cmdline_user_args()
	if not enabled:
		set_process(false)
		return
	Events.zone_entered.connect(func(z: ZoneEntry): _zones_seen.append(z.id); print("[zona] ", z.display_name))
	Engine.time_scale = 2.0
	_start.call_deferred()


func _start() -> void:
	GameState.new_game(DB.config.starters[1])
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")


func _process(delta: float) -> void:
	_time += delta
	_world = get_tree().current_scene
	if _world == null or not _world.has_method("_spawn_companion"):
		return
	var trainer: Trainer = _world.trainer
	var comp: Creature = _world.companion
	# Guión: arriba por el camino hasta el bosque, un rodeo y vuelta.
	if _time < 9.0:
		trainer.autopilot = Vector2.UP
	elif _time < 10.5:
		trainer.autopilot = Vector2.RIGHT
	elif _time < 12.0:
		trainer.autopilot = Vector2.LEFT
	elif _time < 14.0:
		trainer.autopilot = Vector2.ZERO
	else:
		_finish(trainer)
		return
	if comp != null and _time > 1.0:
		_max_follow_gap = maxf(_max_follow_gap, comp.global_position.distance_to(trainer.global_position))


func _finish(trainer: Trainer) -> void:
	var ok := _zones_seen.has("pradera") and _zones_seen.has("bosque") and _max_follow_gap < 80.0
	print("[autotest] zonas=", _zones_seen, " pos=", trainer.global_position.round(),
		" distancia_max_pokemon=", snappedf(_max_follow_gap, 0.1), " zonas_cargadas=", _world.streamer.loaded.keys(),
		" -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)
