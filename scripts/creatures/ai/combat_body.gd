class_name CombatBody
extends RefCounted
## "Cuerpo" de la IA (compartido por salvajes y, más adelante, entrenadores): *cómo* se ejecuta una acción de
## combate. Sabe si un ataque llega, adónde apuntarlo (dirección y punto para zonas y embestidas), cuándo
## esquivar un proyectil y salir de una celda peligrosa. La dificultad (Fácil/Normal/Difícil) actúa solo
## acá: error de puntería, frecuencia de ataque y de esquive. *Qué* hacer lo decide la "mente" (temperamento
## del salvaje o, más adelante, las órdenes del entrenador).

var actor: Creature
var _checked: Dictionary = {}


func _init(p_actor: Creature) -> void:
	actor = p_actor


static func difficulty() -> AiDifficulty:
	return GameState.difficulty if GameState.difficulty != null else AiDifficulty.new()


## Si el ataque de una ranura tiene sentido a esta distancia (mejoras propias: solo herido).
func fits(slot: int, dist: float) -> bool:
	var m: MoveData = actor.moves.slots[slot]
	if m == null or not actor.moves.can_use(slot):
		return false
	match m.kind:
		MoveData.Kind.SHIELD, MoveData.Kind.SELF_BUFF:
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


## Usa una ranura contra el objetivo, con el error de puntería de la dificultad.
func use(slot: int) -> bool:
	var t: Creature = actor.target
	if not is_instance_valid(t):
		return false
	var err := deg_to_rad(difficulty().aim_error_deg)
	var off: Vector2 = t.global_position - actor.global_position
	var dir := off.normalized().rotated(randf_range(-err, err))
	# Mismo error para lo que apunta a un punto (zonas, Arañazo).
	var point: Vector2 = actor.global_position + off.rotated(randf_range(-err, err)) * randf_range(1.0 - err, 1.0 + err)
	return actor.use_slot(slot, dir, point)


## Esquiva proyectiles enemigos que vienen hacia él (decide una vez por proyectil).
func try_dodge() -> bool:
	if not actor.moves.can_dodge():
		return false
	for p in actor.get_parent().get_children():
		if not p is Projectile or p.hit == null or p.hit.team == actor.team or _checked.has(p):
			continue
		var rel: Vector2 = actor.global_position - p.global_position
		if rel.length() < 70.0 and p.velocity.dot(rel) > 0.0:
			_checked[p] = true
			if randf() < difficulty().dodge_chance:
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
