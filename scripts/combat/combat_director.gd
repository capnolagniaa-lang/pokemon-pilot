class_name CombatDirector
extends Node
## Modo combate: cuando un salvaje te detecta (o apretás F), tomás control directo de tu Pokémon y la
## cámara lo sigue. Termina cuando no quedan enemigos cerca, tu Pokémon se debilita o apretás F de nuevo.

## Si no hay enemigos a esta distancia del Pokémon durante calm_time, termina el combate.
@export var engage_distance := 240.0
@export var calm_time := 1.5
## Regeneración fuera de combate (fracción de vida por segundo) hasta la Etapa 6 (Centros Pokémon).
@export var regen_per_second := 0.02
## Tu Pokémon debilitado vuelve a salir cuando recupera esta fracción de vida.
@export var revive_ratio := 0.3

var in_battle := false
var enemies: Array[Creature] = []
## Fuente de órdenes del Pokémon en combate (el autotest la reemplaza por un bot).
var input_source: CombatInput = CombatInput.new()

var _calm := 0.0
## Si el combate tuvo enemigos (si lo sacaste con F sin enemigos, no termina solo).
var _had_enemies := false

@onready var world: Node = get_parent()


func _ready() -> void:
	Events.wild_aggro.connect(_on_wild_aggro)
	Events.creature_fainted.connect(_on_creature_fainted)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("battle_toggle"):
		if in_battle:
			end_battle()
		else:
			start_battle()
	if in_battle:
		_update_battle(delta)
	else:
		_regen(delta)


func start_battle() -> void:
	var c: Creature = world.companion
	if in_battle or not _usable(c):
		return
	in_battle = true
	_calm = 0.0
	_had_enemies = false
	c.player_controlled = true
	c.input_source = input_source
	c.machine.transition_to("controlled")
	world.trainer.locked = true
	world.camera.target = c
	Events.battle_started.emit()


func end_battle() -> void:
	if not in_battle:
		return
	in_battle = false
	var c: Creature = world.companion
	if is_instance_valid(c):
		c.player_controlled = false
		if not c.is_down():
			c.machine.transition_to("follow")
	for e in enemies:
		if is_instance_valid(e) and not e.health.is_dead():
			e.target = null
			e.machine.transition_to("wander")
	enemies.clear()
	world.trainer.locked = false
	world.camera.target = world.trainer
	Events.battle_ended.emit()


func _on_wild_aggro(wild: Creature, _target: Node) -> void:
	var c: Creature = world.companion
	if not _usable(c):
		# Sin Pokémon en condiciones, el salvaje pierde el interés.
		wild.target = null
		return
	wild.target = c
	if not enemies.has(wild):
		enemies.append(wild)
	start_battle()


func _on_creature_fainted(c: Creature) -> void:
	if c == world.companion:
		Events.message_requested.emit("¡%s se debilitó!" % c.instance.species.display_name)
		end_battle()
	elif enemies.has(c):
		enemies.erase(c)
		var gained := 10 + c.instance.level * 5
		var mine: CreatureInstance = GameState.active()
		var ups := mine.add_xp(gained) if mine != null else 0
		var text := "¡%s salvaje se debilitó! +%d EXP" % [c.instance.species.display_name, gained]
		if ups > 0:
			text += " — ¡%s subió a Nv. %d!" % [mine.species.display_name, mine.level]
		Events.message_requested.emit(text)
		Events.party_changed.emit()


func _update_battle(delta: float) -> void:
	var c: Creature = world.companion
	if not _usable(c):
		end_battle()
		return
	enemies = enemies.filter(func(e): return is_instance_valid(e) and not e.health.is_dead() and e.target == c)
	if not enemies.is_empty():
		_had_enemies = true
	if not _had_enemies:
		return
	var near := enemies.any(func(e): return e.global_position.distance_to(c.global_position) < engage_distance)
	_calm = 0.0 if near else _calm + delta
	if _calm >= calm_time:
		end_battle()


func _regen(delta: float) -> void:
	for inst in GameState.party:
		inst.hp = minf(inst.max_hp(), inst.hp + inst.max_hp() * regen_per_second * delta)
	var c: Creature = world.companion
	if is_instance_valid(c) and c.is_down() and c.instance.hp >= c.instance.max_hp() * revive_ratio:
		world.respawn_companion()


func _usable(c: Creature) -> bool:
	return is_instance_valid(c) and not c.is_down()
