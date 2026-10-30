class_name CombatBody
extends RefCounted
## "Cuerpo" de la IA (compartido por salvajes y, más adelante, entrenadores): *cómo* se ejecuta una acción de
## combate. Sabe si un ataque llega, adónde apuntarlo (dirección y punto para zonas y embestidas), cuándo
## esquivar un proyectil y salir de una celda peligrosa. La dificultad (Fácil/Normal/Difícil) actúa solo
## acá: error de puntería, frecuencia de ataque y de esquive. *Qué* hacer lo decide la "mente" (temperamento
## del salvaje o, más adelante, las órdenes del entrenador).

var actor: Creature
## Disparos vistos: proyectil -> [cuándo lo vio (s), si decidió esquivarlo]. Esquiva recién pasado el tiempo de
## reacción de la dificultad (docs/PLAN_IA.md, IA-1).
var _checked: Dictionary = {}
## Ataques que necesitan línea libre hasta el objetivo (los frena una pared).
const NEEDS_SHOT := [MoveData.Kind.PROJECTILE, MoveData.Kind.CHANNEL, MoveData.Kind.WHIP]
## A qué distancia ve venir un disparo y a cuál ya es tarde para pensarlo.
const SEE_SHOT := 200.0
const DODGE_SHOT := 100.0

# --- Moverse sin trabarse (steer) ---
## Distancia que se mira hacia adelante para ver si hay algo sólido.
const PROBE := 12.0
## Ángulos (grados) que prueba para esquivar un obstáculo, del más directo al más desviado.
const DETOUR_ANGLES := [0.0, 35.0, 70.0, 105.0, 140.0]
## Segundos casi sin avanzar (queriendo moverse) para considerarse trabado y buscar camino por celdas.
const STUCK_TIME := 0.35
## Radio (en celdas) del camino que busca alrededor (AStarGrid2D).
const PATH_RADIUS := 14
## Lado hacia el que rodea (1/-1): se mantiene un rato para no zigzaguear frente a un árbol.
var _side := 1.0
var _side_hold := 0.0
var _stuck := 0.0
var _last_pos := Vector2.INF
## Camino por celdas (posiciones globales) cuando está trabado; se abandona al llegar o si cambia mucho el destino.
var path: PackedVector2Array = []
var _path_goal := Vector2.INF
var _path_time := 0.0


func _init(p_actor: Creature) -> void:
	actor = p_actor


static func difficulty() -> AiDifficulty:
	return GameState.difficulty if GameState.difficulty != null else AiDifficulty.new()


## Si el ataque de una ranura tiene sentido a esta distancia. Mejoras propias (balance 2026-10-28: antes solo herido,
## y Danza Espada o el Metrónomo de Clefairy casi no salían): las ofensivas (más ataque o velocidad) y las que maneja la
## firma (sin estado: Metrónomo) en cuanto pelea cerca; las defensivas (escudo, curarse, Fortaleza) cuando está herido.
func fits(slot: int, dist: float) -> bool:
	var m: MoveData = actor.moves.slots[slot]
	if m == null or not actor.moves.can_use(slot):
		return false
	match m.kind:
		MoveData.Kind.SHIELD:
			return actor.health.ratio() < 0.6
		MoveData.Kind.SELF_BUFF:
			var s: StatusEffect = m.self_status
			if s == null or s.attack_mult > 1.0 or s.speed_mult > 1.0:
				return dist < 160.0 and (s == null or not actor.statuses.has_status(s.id))
			return actor.health.ratio() < 0.6
		MoveData.Kind.DASH:
			return m.dash_hits and dist < m.reach()
	return dist < m.reach()


## Ataque para acercarse (embestida que golpea o salto): el que un salvaje usa para abrir si está lejos.
func gap_closer(dist: float) -> int:
	for slot in MoveUser.SLOT_COUNT:
		var m: MoveData = actor.moves.slots[slot]
		if m != null and m.kind in [MoveData.Kind.DASH, MoveData.Kind.LUNGE] and fits(slot, dist):
			return slot
	return -1


## Usa una ranura contra el objetivo, con el error de puntería de la dificultad. A los disparos les suma la
## anticipación (`AiDifficulty.lead`): apunta adonde vas a estar cuando llegue.
func use(slot: int) -> bool:
	var t: Creature = actor.target
	if not is_instance_valid(t):
		return false
	var err := deg_to_rad(difficulty().aim_error_deg)
	var off: Vector2 = t.global_position - actor.global_position
	var m: MoveData = actor.moves.slots[slot]
	if m != null and m.kind == MoveData.Kind.PROJECTILE and m.speed > 0.0:
		off += t.velocity * (off.length() / (m.speed * Projectile.SPEED_MULT)) * difficulty().lead
	if m != null and m.kind in [MoveData.Kind.PROJECTILE, MoveData.Kind.ZONE, MoveData.Kind.AREA]:
		off += actor.mind.aim_read(off)  # te tiene leído hacia qué lado esquivás (TacticalMind, IA-2)
	var dir := off.normalized().rotated(randf_range(-err, err))
	# Mismo error para lo que apunta a un punto (zonas, Arañazo).
	var point: Vector2 = actor.global_position + off.rotated(randf_range(-err, err)) * randf_range(1.0 - err, 1.0 + err)
	return actor.use_slot(slot, dir, point)


## Esquiva proyectiles enemigos que vienen hacia él: decide una vez por proyectil (dodge_chance) al verlo venir, y
## esquiva recién pasado su tiempo de reacción (`AiDifficulty.reaction`, ±30 %), si sigue viniendo.
func try_dodge() -> bool:
	var now := actor.now()
	for p in _checked.keys():
		if not is_instance_valid(p):
			_checked.erase(p)
	for p in actor.get_parent().get_children():
		if not p is Projectile or p.hit == null or p.hit.team == actor.team:
			continue
		var rel: Vector2 = actor.global_position - p.global_position
		if p.velocity.dot(rel) <= 0.0:
			continue
		if not _checked.has(p):
			if rel.length() < SEE_SHOT:
				var react := difficulty().reaction * randf_range(0.7, 1.3)
				_checked[p] = [now + react, randf() < difficulty().dodge_chance + actor.mind.dodge_bonus()]
			continue
		var seen: Array = _checked[p]
		if seen[1] and now >= seen[0] and rel.length() < DODGE_SHOT and actor.moves.can_dodge():
			seen[1] = false
			var perp: Vector2 = p.velocity.orthogonal().normalized()
			return actor.dodge(perp if randf() < 0.5 else -perp)
	return false


## Si está parado en una celda peligrosa (electrificada, mojada...), hacia dónde salir; ZERO si está bien.
func hazard_escape() -> Vector2:
	var world := actor.get_tree().get_first_node_in_group("world")
	if world == null or world.reactions == null:
		return Vector2.ZERO
	var here: EnvCellState = world.reactions.state_at(actor.global_position)
	if here == null or here.creature_status == null:
		return Vector2.ZERO
	# La primera dirección sin estado peligroso y sin nada que lo frene (empieza por un lado distinto cada
	# criatura, así no salen todas para el mismo lado).
	var start := get_instance_id() % 8
	for k in 8:
		var d := Vector2.RIGHT.rotated((start + k) * TAU / 8.0)
		if world.reactions.state_at(actor.global_position + d * 18.0) == null \
				and not actor.test_move(actor.global_transform, d * 18.0):
			return d
	return Vector2.ZERO


## Hay tiro limpio hasta el objetivo (nada sólido en el medio: paredes, árboles, rocas).
func clear_shot(t: Node2D) -> bool:
	if not is_instance_valid(t) or not actor.is_inside_tree():
		return false
	var from := actor.global_position + Vector2(0, -6)
	var q := PhysicsRayQueryParameters2D.create(from, t.global_position + Vector2(0, -6), SHOT_MASK)
	return actor.get_world_2d().direct_space_state.intersect_ray(q).is_empty()


## Capas que frenan un disparo: mundo (1) y entorno (8).
const SHOT_MASK := 1 | (1 << 7)


## Dirección para ir hacia `want` sin trabarse: si adelante hay algo sólido prueba girando (hacia el mismo lado un
## rato, así rodea en vez de zigzaguear); si igual no avanza, busca un camino por celdas hasta `goal` y lo sigue.
## Llamarlo una vez por cuadro de física con la dirección deseada.
func steer(want: Vector2, goal: Vector2 = Vector2.INF) -> Vector2:
	var delta := actor.get_physics_process_delta_time()
	_side_hold -= delta
	_path_time -= delta
	if want == Vector2.ZERO:
		_last_pos = actor.global_position
		_stuck = 0.0
		return want
	# ¿Trabado? (quiere moverse y casi no avanzó desde el cuadro anterior)
	if _last_pos != Vector2.INF and actor.global_position.distance_to(_last_pos) < 0.25 and actor.statuses.can_move():
		_stuck += delta
	else:
		_stuck = maxf(0.0, _stuck - delta * 0.5)
	_last_pos = actor.global_position
	if _stuck > STUCK_TIME:
		_stuck = 0.0
		_side = -_side
		_side_hold = 0.8
		if goal != Vector2.INF:
			find_path(goal)
	# Siguiendo un camino.
	if not path.is_empty():
		if _path_time <= 0.0 or (goal != Vector2.INF and goal.distance_to(_path_goal) > 48.0):
			path = PackedVector2Array()
		else:
			while not path.is_empty() and actor.global_position.distance_to(path[0]) < 6.0:
				path.remove_at(0)
			if not path.is_empty():
				return (path[0] - actor.global_position).normalized()
	return _free_dir(want.normalized())


func _free_dir(want: Vector2) -> Vector2:
	for a in DETOUR_ANGLES:
		for s in ([_side, -_side] if a > 0.0 and _side_hold <= 0.0 else [_side]):
			var d := want.rotated(deg_to_rad(a) * s)
			if not actor.test_move(actor.global_transform, d * PROBE):
				if a > 0.0:
					_side = s
					_side_hold = maxf(_side_hold, 0.5)
				return d
	return want


## Busca un camino por celdas (AStarGrid2D, celdas transitables de la zona) hasta `goal`. Deja `path` vacío si no hay.
func find_path(goal: Vector2) -> bool:
	path = PackedVector2Array()
	var world := actor.get_tree().get_first_node_in_group("world")
	if world == null or world.get("reactions") == null:
		return false
	var grid: EnvironmentGrid = world.reactions.grid_at(actor.global_position)
	if grid == null or grid.zone == null:
		return false
	var zone: Zone = grid.zone
	var from := zone.cell_at(actor.global_position)
	var to := zone.cell_at(goal)
	if from.distance_to(to) > PATH_RADIUS * 2:
		to = from + Vector2i((Vector2(to - from).normalized() * PATH_RADIUS * 1.5).round())
	var region := Rect2i(from, Vector2i.ONE).expand(to).grow(PATH_RADIUS / 2)
	var astar := AStarGrid2D.new()
	astar.region = region
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	var objects := MapRules.objects_by_cell(zone)
	for x in range(region.position.x, region.end.x):
		for y in range(region.position.y, region.end.y):
			var c := Vector2i(x, y)
			var phys := MapRules.cell_physics(zone, c, objects)
			if phys == MapRules.SOLID or (phys == MapRules.WATER and not actor.swims):
				astar.set_point_solid(c)
	if astar.is_point_solid(to):
		astar.set_point_solid(to, false)  # el destino puede estar al lado de algo sólido
	if astar.is_point_solid(from):
		astar.set_point_solid(from, false)
	var cells := astar.get_id_path(from, to, true)
	if cells.size() < 2:
		return false
	for i in range(1, cells.size()):
		path.append(zone.to_global(zone.ground.map_to_local(cells[i])))
	_path_goal = goal
	_path_time = 3.0
	return true

