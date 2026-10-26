extends SignatureMechanic
## Luz de Luna (Clefairy, caótico; docs/PROPUESTA_KITS_PENDIENTES.md): su ataque `metronome_move` (Metrónomo) lanza **un
## ataque al azar de cualquier kit del juego** (un Lanzallamas, una Tumba Rocas, una Salpicadura...). Cada Metrónomo
## suma una carga de luna (la barra, `charges` marcas); con la barra llena el próximo elige entre los `top` ataques más
## fuertes y la vacía. Quedan afuera los ataques sin recarga (los que lanza una firma: rugidos, descargas) y los de
## `exclude` (Autodestrucción).

var _pool: Array[MoveData] = []
var _strong: Array[MoveData] = []


func _setup() -> void:
	var excluded: Array = param("exclude", [])
	for key in DB.all_moves:
		var m: MoveData = DB.all_moves[key]
		if not "/" in key or m.power <= 0.0 or m.cooldown <= 0.0 or m.kind in [MoveData.Kind.SELF_BUFF, MoveData.Kind.SHIELD]:
			continue
		if m.id.begins_with(param("metronome_move", "metronomo")) or excluded.any(func(e): return m.id.begins_with(e)):
			continue
		_pool.append(m)
	_strong = _pool.duplicate()
	_strong.sort_custom(func(a, b): return a.power > b.power)
	_strong = _strong.slice(0, int(param("top", 5)))


func _on_move_released(m: MoveData) -> void:
	if not m.id.begins_with(param("metronome_move", "metronomo")) or _pool.is_empty():
		return
	var full := value >= data.max_value
	var pick: MoveData = (_strong if full else _pool).pick_random()
	set_value(0.0 if full else value + data.max_value / float(param("charges", 3)))
	Events.signature_triggered.emit(creature, "¡Metrónomo: %s!" % pick.display_name, data.color)
	_cast.call_deferred(pick)


func _cast(m: MoveData) -> void:
	if creature.is_down():
		return
	var point: Vector2 = creature.target.global_position if is_instance_valid(creature.target) \
		else creature.global_position + creature.facing.normalized() * 80.0
	var msg := {"move": m, "aim": creature.facing, "step": 0, "point": point, "spent": 0.0}
	if m.cast_time > 0.0:
		creature.machine.transition_to("cast", msg)
	else:
		creature.release_move(msg)


## Para los tests: los ataques posibles del Metrónomo.
func pool() -> Array[MoveData]:
	return _pool


func _can_decay() -> bool:
	return false


func state_label() -> String:
	return "LUNA LLENA" if value >= data.max_value else ""
