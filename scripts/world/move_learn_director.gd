class_name MoveLearnDirector
extends Node
## Ataques nuevos (pedido del usuario 2026-10-28): si un Pokémon de tu equipo aprende un ataque y tiene una ranura
## libre, se equipa solo (GameState.grant_exp / auto_equip). Si las 4 están llenas, en el próximo momento tranquilo (sin
## combate ni charla, como las evoluciones) aparece MoveLearnScreen: "¿reemplazar uno?". Lo crea EvolutionDirector
## (world.evolutions.moves) para no tocar world.gd.

signal done(inst: CreatureInstance, move: MoveData, replaced: int)

## [CreatureInstance, MoveData]
var queue: Array = []
var showing := false
var screen: MoveLearnScreen
var _evolutions: EvolutionDirector
var _layer: CanvasLayer


func _ready() -> void:
	_evolutions = get_parent()
	_layer = CanvasLayer.new()
	_layer.layer = 12
	add_child(_layer)
	Events.move_learned.connect(_on_learned)


func _on_learned(inst: CreatureInstance, m: MoveData) -> void:
	if m == null or not GameState.party.has(inst) or inst.equipped_moves.has(m) or inst.equipped_moves.has(null):
		return
	if not queue.any(func(q): return q[0] == inst and q[1] == m):
		queue.append([inst, m])


func _process(_delta: float) -> void:
	if showing or queue.is_empty() or _evolutions.showing or not _evolutions.can_show():
		return
	_show(queue.pop_front())


func _show(entry: Array) -> void:
	var inst: CreatureInstance = entry[0]
	var m: MoveData = entry[1]
	if not GameState.party.has(inst) or inst.equipped_moves.has(m):
		return
	if inst.auto_equip(m):  # se liberó una ranura mientras esperaba
		Events.equipment_changed.emit(inst)
		return
	showing = true
	var world: Node = _evolutions.world
	world.trainer.locked = true
	screen = MoveLearnScreen.new()
	screen.setup(inst, m)
	_layer.add_child(screen)
	var slot: int = await screen.finished
	screen.queue_free()
	if slot >= 0:
		var old: MoveData = inst.equipped_moves[slot]
		inst.equip(slot, m)
		Events.equipment_changed.emit(inst)
		Events.message_requested.emit("¡%s dejó de usar %s y equipó %s!" % [inst.display_name(), old.display_name, m.display_name])
	world.trainer.locked = false
	showing = false
	done.emit(inst, m, slot)
