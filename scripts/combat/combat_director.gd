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


## Recarga entre cambios de Pokémon (1-6), para que no sea gratis esquivar un golpe cambiando.
const SWITCH_COOLDOWN := 1.5
var _switch_cd := 0.0


func _process(delta: float) -> void:
	_switch_cd = maxf(0.0, _switch_cd - delta)
	for i in GameState.MAX_PARTY:
		if Input.is_action_just_pressed("switch_%d" % (i + 1)):
			switch_to(i)
	if Input.is_action_just_pressed("battle_toggle") and not arena_lock:
		if in_battle:
			end_battle()
		else:
			start_battle()
	if in_battle:
		_update_battle(delta)
	else:
		_regen(delta)


## Pelea contra un entrenador en su arena (TrainerBattle): la pelea no termina sola (ni con F) aunque tu Pokémon
## caiga o no haya rivales cerca, y no hay revivir de práctica; la cierra TrainerBattle.
var arena_lock := false


func start_battle() -> void:
	var c: Creature = world.companion
	if in_battle or not _usable(c):
		return
	in_battle = true
	_calm = 0.0
	_had_enemies = false
	take_control(c)
	Events.battle_started.emit()


## Tu Pokémon pasa a obedecerte (al empezar la pelea, o el que sale en la arena cuando cae el anterior).
func take_control(c: Creature) -> void:
	c.player_controlled = true
	c.input_source = input_source
	c.machine.transition_to("controlled")
	world.trainer.locked = true
	world.camera.target = c


func end_battle(force: bool = false) -> void:
	if not in_battle or (arena_lock and not force):
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
		if GameState.practice_mode and not arena_lock:
			get_tree().create_timer(0.8).timeout.connect(_practice_revive.bind(c.instance))
	elif enemies.has(c):
		enemies.erase(c)
		var gained := CreatureInstance.exp_yield(c.instance)
		var who := "de " + c.owner_name if c.owner_name != "" else "salvaje"
		var text := "¡%s %s se debilitó! +%d EXP" % [c.instance.species.display_name, who, gained]
		var mine: CreatureInstance = GameState.active()
		if mine != null:
			text += GameState.grant_exp(mine, gained)
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


## Modo práctica: el Pokémon debilitado vuelve enseguida con la vida al máximo.
func _practice_revive(inst: CreatureInstance) -> void:
	if inst != GameState.active():
		return
	inst.hp = inst.max_hp()
	world.respawn_companion()
	Events.message_requested.emit("Modo práctica: %s vuelve con la vida al máximo." % inst.species.display_name)


func _regen(delta: float) -> void:
	for inst in GameState.party:
		inst.hp = minf(inst.max_hp(), inst.hp + inst.max_hp() * regen_per_second * delta)
	var c: Creature = world.companion
	if is_instance_valid(c) and c.is_down() and c.instance.hp >= c.instance.max_hp() * revive_ratio:
		world.respawn_companion()


## Cambia al Pokémon del lugar `index` del equipo (teclas 1-6). En combate el nuevo sale donde estaba el
## anterior, sigue la pelea y los rivales lo pasan a atacar a él. Devuelve si cambió.
func switch_to(index: int) -> bool:
	if index >= GameState.party.size() or index == GameState.active_index or _switch_cd > 0.0:
		return false
	var story = world.get("story")
	if story != null and (story.busy or story.dialog.active):
		return false
	var inst: CreatureInstance = GameState.party[index]
	if inst.hp <= 0.0:
		Events.message_requested.emit("%s está debilitado." % inst.display_name())
		return false
	var old: Creature = world.companion
	var was_fighting := in_battle and (_usable(old) or arena_lock)
	var at: Vector2 = old.global_position if is_instance_valid(old) else Vector2.INF
	var old_name: String = old.instance.display_name() if is_instance_valid(old) else ""
	if not GameState.set_active(index):
		return false
	_switch_cd = SWITCH_COOLDOWN
	var c: Creature = world.companion
	if not is_instance_valid(c):
		return true
	if at != Vector2.INF:
		c.global_position = at
	if was_fighting:
		c.player_controlled = true
		c.input_source = input_source
		c.machine.transition_to.call_deferred("controlled")
		world.camera.target = c
		for e in enemies:
			if is_instance_valid(e) and not e.health.is_dead():
				e.target = c
	Fx.burst(c.get_parent(), c.global_position, Color(1.0, 0.4, 0.35), 14, 50.0)
	Events.message_requested.emit(("¡Volvé, %s! " % old_name if old_name != "" else "") + "¡Adelante, %s!" % inst.display_name())
	return true


func _usable(c: Creature) -> bool:
	return is_instance_valid(c) and not c.is_down()
