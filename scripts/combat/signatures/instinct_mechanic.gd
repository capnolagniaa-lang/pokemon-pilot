extends SignatureMechanic
## Instinto (Rattata): detecta presas, enemigos con menos de `prey_hp` de vida o con cualquier estado
## alterado (las marca con una mira roja). Contra presas pega `prey_damage_mult` más y tiene
## `prey_crit_chance` de crítico. **Foco Energía** (estado `foco_energia`) guarda un crítico seguro para el
## próximo golpe. Rematar a un enemigo reinicia la recarga de la ranura `reset_slot` (Ataque Rápido).
## Sin barra: el estado muestra si el objetivo es presa. Pregunta del jugador: ¿está lo bastante débil?

var _marks: Node2D


func _setup() -> void:
	creature.killed.connect(_on_killed)
	_marks = PreyMarks.new()
	_marks.mechanic = self
	creature.add_child.call_deferred(_marks)


func is_prey(c: Creature) -> bool:
	return is_instance_valid(c) and not c.is_down() and c.team != creature.team \
		and (c.health.ratio() < param("prey_hp", 0.4) or not c.statuses.active.is_empty())


func damage_mult_against(_hit: HitInfo, target: Creature) -> float:
	var mult := 1.0
	var crit := false
	if creature.statuses.has_status("foco_energia"):
		creature.statuses.cure(DB.statuses.get("foco_energia"))
		crit = true
	if is_prey(target):
		mult *= param("prey_damage_mult", 1.3)
		crit = crit or randf() < param("prey_crit_chance", 0.25)
	if crit:
		mult *= param("crit_mult", 1.5)
		Events.signature_triggered.emit(target, "¡Crítico!", data.color)
	return mult


func _on_killed(_target: Creature) -> void:
	var slot := int(param("reset_slot", 1))
	if slot >= 0 and slot < creature.moves.slots.size():
		creature.moves.reset_cooldown(slot)
		Events.signature_triggered.emit(creature, "¡Instinto!", data.color)


func state_label() -> String:
	if creature.statuses.has_status("foco_energia"):
		return "CRÍTICO LISTO"
	if is_prey(creature.target):
		return "PRESA"
	return ""


## Mira roja sobre las presas cercanas (solo cuando lo controla el jugador).
class PreyMarks extends Node2D:
	var mechanic

	func _ready() -> void:
		top_level = true
		z_index = 30

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var me: Creature = mechanic.creature
		if not me.player_controlled:
			return
		var t := Time.get_ticks_msec() / 1000.0
		for c in me.get_tree().get_nodes_in_group("creatures"):
			if c == me or not mechanic.is_prey(c) or c.global_position.distance_to(me.global_position) > 220.0:
				continue
			var p: Vector2 = c.global_position + Vector2(0, -30)
			var r := 4.0 + sin(t * 8.0) * 0.8
			var col := Color(1.6, 0.25, 0.2, 0.9)
			draw_arc(p, r, 0.0, TAU, 16, col, 1.2)
			for k in 4:
				var d := Vector2.RIGHT.rotated(k * PI / 2.0)
				draw_line(p + d * (r - 1.5), p + d * (r + 2.5), col, 1.0)
