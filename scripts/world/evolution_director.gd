class_name EvolutionDirector
extends Node
## Evoluciones (pedido del usuario 2026-10-25; datos: SpeciesData.evolutions, reglas: Evolution). Escucha
## Events.evolution_ready (al subir de nivel o al usar una piedra) y, cuando no hay combate, diálogo, puerta ni menú
## abierto, muestra EvolutionScreen. Si no la frenaste, la criatura evoluciona (CreatureInstance.evolve_into),
## aprende lo de su nivel, queda en la Pokédex y, si estaba afuera, sale con su forma nueva. Nodo del mundo
## (world.evolutions).

signal done(inst: CreatureInstance, evolved: bool)

var world: Node
## [CreatureInstance, SpeciesData destino, cancelable]
var queue: Array = []
var showing := false
## Acelera la pantalla (los tests).
var speed := 1.0
var _layer: CanvasLayer
var screen: EvolutionScreen
## Ataques nuevos con las 4 ranuras llenas (MoveLearnDirector).
var moves: MoveLearnDirector


func _ready() -> void:
	world = get_parent()
	_layer = CanvasLayer.new()
	_layer.layer = 12  # encima del HUD, el menú y la tienda
	add_child(_layer)
	Events.evolution_ready.connect(_on_ready)
	moves = MoveLearnDirector.new()  # cartel de "quiere aprender un ataque" (mismo momento tranquilo)
	moves.name = "MoveLearnDirector"
	add_child(moves)


func _on_ready(inst: CreatureInstance, to: SpeciesData, cancelable: bool) -> void:
	if to == null or queue.any(func(q): return q[0] == inst):
		return
	queue.append([inst, to, cancelable])


func _process(_delta: float) -> void:
	if showing or queue.is_empty() or not can_show():
		return
	_show(queue.pop_front())


## Momento tranquilo: sin combate ni arena, sin diálogo ni puerta, sin menú (árbol en pausa).
func can_show() -> bool:
	return not get_tree().paused and not world.combat.in_battle and not world.arena.active and not world.story.busy \
		and not world.story.dialog.active and not world.warps.busy


func _show(entry: Array) -> void:
	var inst: CreatureInstance = entry[0]
	var to: SpeciesData = entry[1]
	if not GameState.party.has(inst) or to.evolves_from != inst.species.id:
		return  # ya evolucionó o no está en el equipo
	showing = true
	world.trainer.locked = true
	screen = EvolutionScreen.new()
	screen.speed = speed
	screen.setup(inst.species, to, inst.display_name(), entry[2])
	_layer.add_child(screen)
	var evolved: bool = await screen.finished
	screen.queue_free()
	if evolved:
		var from := inst.species
		var learned := inst.evolve_into(to)
		for m in learned:
			if inst.auto_equip(m):
				Events.equipment_changed.emit(inst)
			Events.move_learned.emit(inst, m)
			Events.message_requested.emit("¡%s aprendió %s!" % [inst.display_name(), m.display_name])
		GameState.mark_fought(to)
		GameState.pokedex_caught[to.id] = true
		Events.evolved.emit(inst, from, to)
		if is_instance_valid(world.companion) and world.companion.instance == inst:
			world.respawn_companion()  # sale con la forma nueva (sprite, kit y stats)
	world.trainer.locked = false
	showing = false
	done.emit(inst, evolved)
