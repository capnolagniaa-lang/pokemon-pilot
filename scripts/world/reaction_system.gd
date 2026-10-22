class_name ReactionSystem
extends Node
## Entorno reactivo (Etapa 3). Escucha los impactos de elementos en el mundo (Events.element_impact) y les
## aplica las reglas de data/environment/reactions a las celdas alcanzadas: el fuego prende el pasto alto,
## las flores y los árboles (y se contagia), el agua apaga y moja, el hielo congela el agua (puente), el
## eléctrico corre por el agua y el suelo mojado, el fuego sobre lo mojado hace vapor. También:
##  · las criaturas paradas encima reciben el estado de la celda (Quemado, Empapado, Paralizado);
##  · los objetos inflamables (árbol cortable) se queman y las rocas frágiles se rompen con embestidas.
## Cada zona tiene su EnvironmentGrid (se crea al primer uso y se va con la zona).

const CREATURE_TICK := 0.5
## Hasta qué distancia del borde de un impacto se considera alcanzada una celda.
const CELL_REACH := 6.0

var world: Node
var rules: Array[ReactionRule] = []
var states: Dictionary = {}  # id -> EnvCellState
var _creature_timer := 0.0


func _ready() -> void:
	world = get_parent()
	states = DB.env_states
	rules.assign(DB.reactions.values())
	rules.sort_custom(func(a, b): return a.priority > b.priority)
	Events.element_impact.connect(_on_element_impact)
	Events.env_object_struck.connect(_on_object_struck)


func state_by_id(id: String) -> EnvCellState:
	return states.get(id) if id != "" else null


## Grilla de la zona que contiene una posición (null si la zona no está cargada).
func grid_at(global_pos: Vector2) -> EnvironmentGrid:
	var entry: ZoneEntry = world.streamer.world_data.zone_at(global_pos)
	if entry == null:
		return null
	var zone: Zone = world.streamer.zone_node(entry.id)
	if zone == null:
		return null
	var g: EnvironmentGrid = zone.get_node_or_null("EnvironmentGrid")
	if g == null:
		g = EnvironmentGrid.new()
		g.setup(zone, self)
		zone.add_child(g)
	return g


## Estado de la celda en una posición del mundo (o null).
func state_at(global_pos: Vector2) -> EnvCellState:
	var g := grid_at(global_pos)
	return g.state_at(g.zone.cell_at(global_pos)) if g != null else null


## Tags de la celda con el estado dinámico aplicado.
func tags_at(global_pos: Vector2) -> PackedStringArray:
	var g := grid_at(global_pos)
	return g.tags_of(g.zone.cell_at(global_pos)) if g != null else PackedStringArray()


func _on_element_impact(element: ElementType, pos: Vector2, radius: float) -> void:
	apply_element(element, pos, radius)


## Aplica un elemento en un área del mundo (celdas alcanzadas + objetos del entorno).
func apply_element(element: ElementType, pos: Vector2, radius: float) -> void:
	var g := grid_at(pos)
	if g == null or element == null:
		return
	var center := g.zone.cell_at(pos)
	var r := int(ceil((radius + CELL_REACH) / EnvironmentGrid.TILE))
	for dx in range(-r, r + 1):
		for dy in range(-r, r + 1):
			var cell := center + Vector2i(dx, dy)
			if cell == center or g.cell_center(cell).distance_to(pos) <= radius + CELL_REACH:
				apply_element_cell(g, cell, element)
	_affect_objects(element, pos, radius + CELL_REACH)


## Aplica un elemento a una celda: la primera regla (por prioridad) que coincide cambia su estado.
func apply_element_cell(g: EnvironmentGrid, cell: Vector2i, element: ElementType) -> void:
	var tags := g.tags_of(cell)
	var st := g.state_at(cell)
	for rule in rules:
		if rule.element != element or not _matches(rule, tags, st):
			continue
		var new_state := state_by_id(rule.set_state)
		if new_state == st and new_state != null:
			return  # ya está así (no reiniciar el fuego infinitamente)
		g.set_state(cell, new_state)
		if rule.flood_limit > 0:
			_flood(g, cell, rule, new_state)
		_feedback(rule, g.cell_center(cell))
		return


func _matches(rule: ReactionRule, tags: PackedStringArray, st: EnvCellState) -> bool:
	var sid := st.id if st != null else "none"
	if rule.state_required != "" and rule.state_required != sid:
		return false
	if rule.states_blocked.has(sid):
		return false
	if rule.tags_any.is_empty():
		return true
	for t in rule.tags_any:
		if tags.has(t):
			return true
	return false


## Propaga el estado por las celdas conectadas que conducen (eléctrico por agua y suelo mojado).
func _flood(g: EnvironmentGrid, start: Vector2i, rule: ReactionRule, st: EnvCellState) -> void:
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	var count := 0
	while not queue.is_empty() and count < rule.flood_limit:
		var c: Vector2i = queue.pop_front()
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if seen.has(n):
				continue
			seen[n] = true
			var ns := g.state_at(n)
			var conducts := ns != null and rule.flood_states.has(ns.id)
			if not conducts:
				var tags := g.tags_of(n)
				for t in rule.flood_tags:
					if tags.has(t):
						conducts = true
						break
			if conducts and ns != st:
				g.set_state(n, st)
				queue.append(n)
				count += 1


func _feedback(rule: ReactionRule, at: Vector2) -> void:
	var parent: Node = world.entities
	match rule.effect:
		ReactionRule.Effect.STEAM:
			Fx.burst(parent, at + Vector2(0, -6), Color(0.9, 0.92, 0.95, 0.8), 10, 30.0)
		ReactionRule.Effect.SPARKS:
			Fx.burst(parent, at, Color(1.6, 1.4, 0.5), 6, 50.0)
		ReactionRule.Effect.ICE:
			Fx.burst(parent, at, Color(0.8, 0.95, 1.3), 5, 30.0)
		ReactionRule.Effect.FIRE:
			Fx.burst(parent, at, Color(0.85, 0.28, 0.08), 4, 25.0)
		ReactionRule.Effect.SPLASH:
			Fx.burst(parent, at, Color(0.5, 0.75, 1.2), 4, 30.0)
	if rule.text != "" and randf() < 0.35:  # no llenar la pantalla de textos en un área grande
		Events.env_reaction.emit(at, rule.text)


# --- Objetos del entorno ---------------------------------------------------------------------

func _affect_objects(element: ElementType, pos: Vector2, radius: float) -> void:
	for obj in get_tree().get_nodes_in_group("env_objects"):
		if obj.global_position.distance_to(pos) > radius + 8.0:
			continue
		if element.id == "fuego" and obj.has_tag("inflamable"):
			obj.burn_away()


## Una embestida chocó contra un objeto: las rocas frágiles se rompen con golpes fuertes.
func _on_object_struck(obj: Node, power: float) -> void:
	if is_instance_valid(obj) and obj.has_tag("fragil") and power >= obj.break_power:
		obj.shatter()


# --- Criaturas sobre celdas con estado -------------------------------------------------------

func _physics_process(delta: float) -> void:
	_creature_timer -= delta
	if _creature_timer > 0.0:
		return
	_creature_timer = CREATURE_TICK
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.is_down() or c.health.is_invulnerable():
			continue
		var st := state_at(c.global_position)
		# Los que acumulan (Paralizado) se aplican en cada tick; el resto, si no lo tiene ya.
		if st != null and st.creature_status != null and (st.creature_status.buildup or not c.statuses.has_status(st.creature_status.id)):
			c.statuses.apply(st.creature_status)
