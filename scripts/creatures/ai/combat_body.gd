class_name CombatBody
extends RefCounted
## "Cuerpo" de la IA (compartido por salvajes y, más adelante, entrenadores): *cómo* se ejecuta una acción de
## combate. Sabe si un ataque llega, adónde apuntarlo (dirección y punto para zonas y embestidas), cuándo
## esquivar un proyectil y salir de una celda peligrosa. La dificultad (Fácil/Normal/Difícil) actúa solo
## acá: error de puntería, frecuencia de ataque y de esquive. *Qué* hacer lo decide la "mente" (temperamento
## del salvaje o, más adelante, las órdenes del entrenador).

var actor: Creature
## Amenazas vistas (TacticalMind.threat): clave -> [cuándo reacciona (s), si va a esquivar, si va a dar el paso].
## Decide una vez por amenaza al verla y reacciona recién pasado el tiempo de reacción de la dificultad (IA-1).
var _checked: Dictionary = {}
## Paso al costado en curso (S-0, docs/PLAN_SPARRING_IA.md): hacia dónde y cuánto le falta.
var _step_dir := Vector2.ZERO
var _step_left := 0.0
## Velocidad del paso (× la de caminar) y cuánto se corre como mínimo y como máximo.
const SIDESTEP_SPEED := 1.1
const SIDESTEP_MIN := 16.0
## Esquiva (rueda) recién cuando falta esto para que pegue: la invulnerabilidad del esquive dura poco, antes se
## desperdicia (y una persona tampoco rueda medio segundo antes).
const DODGE_WINDOW := 0.26
## Un ataque fuerte que llega antes de este múltiplo del tiempo del paso se rueda en vez de caminar (con más tiempo, el paso).
const STRONG_STEP_MARGIN := 3.0
const SIDESTEP_MAX := 40.0
## Probabilidad de dar el paso al costado: base + la de esquivar × 1,5 (es barato: una persona lo hace casi siempre).
const SIDESTEP_BASE := 0.25
## (Tests: imprime cada decisión.)
static var debug_threats := false
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
func fits(slot: int, dist: float, soon: bool = false) -> bool:
	var m: MoveData = actor.moves.slots[slot]
	if m == null or not actor.moves.can_use(slot, soon):
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


## Reacciona a la amenaza que viene (TacticalMind.threat: disparo, carga apuntada, zona, chorro, golpe): decide una
## vez por amenaza al verla (esquivar con `dodge_chance` + bonus; dar el paso con SIDESTEP_BASE + eso × 1,5) y actúa
## recién pasado su tiempo de reacción (`AiDifficulty.reaction`, ±30 %). Si alcanza con caminar, da un **paso al
## costado** (lo que hace una persona casi siempre, sin gastar el esquive); si es fuerte o ya no hay tiempo, **esquiva**.
## Devuelve si hizo algo este cuadro. (Nombre histórico: antes solo esquivaba proyectiles.)
func try_dodge() -> bool:
	var now := actor.now()
	if actor.mind.read_dodge_due() and actor.moves.can_dodge():  # el ataque que repetís: se lo veía venir (IA-7)
		var line: Vector2 = actor.target.global_position - actor.global_position
		var read_ok: bool = actor.dodge(line.orthogonal().normalized() * (1.0 if randf() < 0.5 else -1.0))
		if read_ok:
			AiTrace.note(actor, "lectura", {"amenaza": "lo que repetís"})
		return read_ok
	var th: Dictionary = actor.mind.threat()
	for k in _checked.keys():
		if k is String:
			if not th.get("key") is String or th.key != k:
				_checked.erase(k)  # (una carga o un golpe que ya pasó: la próxima se decide de nuevo)
		elif not is_instance_valid(k):
			_checked.erase(k)
	if th.is_empty():
		return false
	var key = th.key
	if not _checked.has(key):
		var react := difficulty().reaction * randf_range(0.7, 1.3)
		var chance: float = difficulty().dodge_chance + actor.mind.dodge_bonus()
		var step_chance: float = clampf(SIDESTEP_BASE + chance * 1.5, 0.0, 0.95) if difficulty().dodge_chance > 0.0 else SIDESTEP_BASE * 0.6
		_checked[key] = [now + react, randf() < chance, randf() < step_chance]
		if AiTrace.enabled():
			AiTrace.note(actor, "ve", {"amenaza": th.kind, "eta": snappedf(float(th.eta), 0.01), "reaccion": snappedf(react, 0.01),
				"esquivaria": _checked[key][1], "paso": _checked[key][2], "fuerte": th.strong})
		return false
	var seen: Array = _checked[key]
	if now < seen[0] or (not seen[1] and not seen[2]):
		return false
	var will_dodge: bool = seen[1]
	var will_step: bool = seen[2]
	var eta := float(th.eta)
	var step_time: float = clampf(float(th.clear), SIDESTEP_MIN, SIDESTEP_MAX) / maxf(1.0, actor.speed() * SIDESTEP_SPEED)
	var can_step_out: bool = eta > step_time * 1.3
	var dodge_ok: bool = will_dodge and actor.moves.can_dodge()
	if debug_threats and (eta <= DODGE_WINDOW or can_step_out):
		print("[cuerpo] %s: amenaza %s (%s) eta %.2f paso %.2f s (clear %.0f) sale caminando %s esquiva %s paso? %s fuerte %s" % [actor.name,
			th.kind, str(key), eta, step_time, th.clear, can_step_out, dodge_ok, will_step, th.strong])
	# Con tiempo de sobra, un paso al costado (lo normal). Lo fuerte (tira, corta cargas) que viene justo, o lo que no se
	# alcanza caminando, se esquiva rodando, recién cuando está por pegar; si no puede rodar (recarga, tambaleando), el
	# paso igual (mejor tarde que de frente).
	var roll_it: bool = dodge_ok and (not can_step_out or (bool(th.strong) and eta < step_time * STRONG_STEP_MARGIN))
	if will_step and can_step_out and not roll_it:
		if sidestep(th.out, float(th.clear)):
			seen[1] = false
			seen[2] = false
			AiTrace.note(actor, "paso", {"amenaza": th.kind, "eta": snappedf(eta, 0.01)})
			return true
		if not dodge_ok:
			seen[1] = false
			seen[2] = false
			return false
		roll_it = true  # no hay lugar para el paso (arrinconado): rueda
	if roll_it:
		if eta > DODGE_WINDOW:
			return false  # todavía no: espera a que esté por pegar (sigue decidido)
		if actor.dodge(th.out):
			seen[1] = false
			seen[2] = false
			AiTrace.note(actor, "esquive", {"amenaza": th.kind, "eta": snappedf(eta, 0.01)})
			return true
	seen[1] = false
	seen[2] = false
	var late: bool = (will_step or will_dodge) and sidestep(th.out, float(th.clear))
	if late:
		AiTrace.note(actor, "paso", {"amenaza": th.kind, "eta": snappedf(eta, 0.01), "por": "tarde"})
	return late


## Paso al costado: se corre `clear` px hacia `dir` caminando (sin gastar el esquive). Si de ese lado hay algo sólido,
## prueba el otro. El estado lo ejecuta con `sidestep_dir()` mientras dura.
func sidestep(dir: Vector2, clear: float) -> bool:
	# (tambaleando por un golpe también se puede caminar, despacio: Creature.move lo frena solo)
	if dir.length() < 0.1 or actor.health.is_dead() or actor.is_burrowed() or not actor.statuses.can_move() 			or actor.machine.current_name() not in ["controlled", "attack", "chase", "wander", "idle"]:
		return false
	var d := dir.normalized()
	if actor.test_move(actor.global_transform, d * PROBE):
		d = -d
		if actor.test_move(actor.global_transform, d * PROBE):
			return false
	_step_dir = d
	_step_left = clampf(clear, SIDESTEP_MIN, SIDESTEP_MAX) / maxf(1.0, actor.speed() * SIDESTEP_SPEED)
	return true


## Hacia dónde va el paso al costado en curso (ZERO si no hay). Llamarlo una vez por cuadro de física.
func sidestep_dir() -> Vector2:
	if _step_left <= 0.0:
		return Vector2.ZERO
	_step_left -= actor.get_physics_process_delta_time()
	return _step_dir


func sidestepping() -> bool:
	return _step_left > 0.0


## Si está parado en una celda peligrosa, hacia dónde salir; ZERO si está bien. Peligrosa (TacticalMind.danger_at):
## la celda ya le pone un estado (electrificada), o el rival tiene un ataque que ahí se lo pondría (el agua o lo mojado
## frente a uno con ataques eléctricos; IA-3).
func hazard_escape() -> Vector2:
	var world := actor.get_tree().get_first_node_in_group("world")
	if world == null or world.reactions == null:
		return Vector2.ZERO
	if not actor.mind.danger_at(actor.global_position):
		return Vector2.ZERO
	# La primera dirección sin estado peligroso y sin nada que lo frene (empieza por un lado distinto cada
	# criatura, así no salen todas para el mismo lado).
	var start := get_instance_id() % 8
	for k in 8:
		var d := Vector2.RIGHT.rotated((start + k) * TAU / 8.0)
		if not actor.mind.danger_at(actor.global_position + d * 18.0) \
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

