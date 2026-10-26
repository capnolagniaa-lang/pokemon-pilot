extends SignatureMechanic
## Toma de Tierra (Raichu, jefe de Lt. Surge; docs/PROPUESTA_KITS_PENDIENTES.md): la barra sube al pegar y al recibir.
## Llena → **planta la cola** (`plant_status`: quieto y sin atacar `plant_time` s, se ve venir) y suelta una descarga en
## anillo (`discharge_move`); las celdas alrededor (`ground_radius`) quedan con el estado `ground_state` (chamuscadas y
## electrificadas: un tirón de parálisis al que las pisa). Jefe: cuerpo `scale`, empuje `knockback_mult`; a mitad de
## vida (`phase_at`) entra en `phase_status` (Sobrecarga) hasta el final. Lección del anime: es lento, esquivalo.

var _discharge: MoveData
var _phased := false
var _planting := 0.0


func _setup() -> void:
	_discharge = load(param("discharge_move", "")) if param("discharge_move", "") != "" else null
	if param("phase_at", 0.0) > 0.0:
		creature.health.changed.connect(func(_hp, _max): _check_phase())


func _can_gain() -> bool:
	return _planting <= 0.0


func _on_value_changed(_before: float) -> void:
	if value < data.max_value or _planting > 0.0 or creature.is_down():
		return
	_planting = param("plant_time", 1.0)
	var s: StatusEffect = DB.statuses.get(param("plant_status", ""))
	if s != null:
		creature.statuses.apply(s)
	Events.signature_triggered.emit(creature, "¡Planta la cola!", data.color)


func _tick(delta: float) -> void:
	if _planting > 0.0:
		_planting -= delta
		if _planting <= 0.0:
			_release()
	if _phased and not creature.statuses.has_status(param("phase_status", "")) and not creature.is_down():
		var s: StatusEffect = DB.statuses.get(param("phase_status", ""))
		if s != null:
			creature.statuses.apply(s)  # la Sobrecarga dura toda la pelea


func _release() -> void:
	set_value(0.0)
	if creature.is_down():
		return
	if _discharge != null:
		var a := AreaEffect.new()
		creature.get_parent().add_child(a)
		a.trigger(HitInfo.from(creature, _discharge), creature.global_position + Vector2(0, -6))
	_mark_ground()
	Events.camera_shake.emit(6.0)


## Deja las celdas alrededor con el estado de celda `ground_state` (si hay grilla de entorno acá).
func _mark_ground() -> void:
	var world := creature.get_tree().get_first_node_in_group("world")
	if world == null or world.get("reactions") == null:
		return
	var st: EnvCellState = world.reactions.state_by_id(param("ground_state", ""))
	var g: EnvironmentGrid = world.reactions.grid_at(creature.global_position)
	if st == null or g == null:
		return
	var radius: float = param("ground_radius", 48.0)
	var center := g.zone.cell_at(creature.global_position)
	var r := int(ceil(radius / EnvironmentGrid.TILE))
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var cell := center + Vector2i(dx, dy)
			if g.cell_center(cell).distance_to(creature.global_position) <= radius and MapRules.is_walkable(g.zone, cell):
				g.set_state(cell, st)


func _check_phase() -> void:
	if _phased or creature.is_down() or creature.health.ratio() > param("phase_at", 0.5):
		return
	_phased = true
	var s: StatusEffect = DB.statuses.get(param("phase_status", ""))
	if s != null:
		creature.statuses.apply(s)
	Events.camera_shake.emit(7.0)
	Events.signature_triggered.emit(creature, "¡SOBRECARGA!", data.color)


func knockback_taken_mult() -> float:
	return param("knockback_mult", 1.0)


func body_scale() -> float:
	return param("scale", 1.0)


func state_label() -> String:
	if _planting > 0.0:
		return "TOMA DE TIERRA"
	return "SOBRECARGA" if _phased else ""
