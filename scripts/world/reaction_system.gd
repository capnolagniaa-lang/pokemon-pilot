class_name ReactionSystem
extends Node
## Entorno reactivo (Etapa 3). Escucha los impactos de elementos en el mundo (Events.element_impact) y les
## aplica las reglas de data/environment/reactions a las celdas alcanzadas: el agua moja el suelo, el hielo
## congela el agua (puente) y lo mojado, el eléctrico corre por el agua y el suelo mojado. El fuego no
## interactúa con el entorno (decisión del usuario; más adelante solo prenderá las esporas de un ataque
## Espora). También:
##  · las criaturas paradas encima reciben el estado de la celda (Empapado); la descarga eléctrica
##    (`status_on_impact`) paraliza una sola vez, al impactar, a los que están en el agua o lo mojado alcanzado
##    (no a los que flotan ni al que pelea montado sobre su Pokémon de Surf);
##  · las rocas frágiles se rompen con embestidas.
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
	Events.ground_impact.connect(_on_ground_impact)


func state_by_id(id: String) -> EnvCellState:
	return states.get(id) if id != "" else null


## Zonas que no son del mundo pero tienen entorno (las arenas de TrainerBattle): zona -> rectángulo global.
var extra_zones: Dictionary = {}


func register_zone(zone: Zone) -> void:
	var used := zone.ground.get_used_rect()
	extra_zones[zone] = Rect2(zone.global_position + Vector2(used.position * EnvironmentGrid.TILE), Vector2(used.size * EnvironmentGrid.TILE))


func unregister_zone(zone: Zone) -> void:
	extra_zones.erase(zone)


## Si en esta posición rigen las reglas de arena (cráteres, superficies): en una arena, o en todos lados si
## GameConfig.arena_rules_everywhere.
func arena_rules_at(global_pos: Vector2) -> bool:
	if GameState.setting("arena_everywhere"):
		return true
	for z in extra_zones:
		if is_instance_valid(z) and extra_zones[z].has_point(global_pos):
			return true
	return false


## Grilla de la zona que contiene una posición (null si la zona no está cargada).
func grid_at(global_pos: Vector2) -> EnvironmentGrid:
	for z in extra_zones:
		if is_instance_valid(z) and extra_zones[z].has_point(global_pos):
			return _grid_of(z)
	var entry: ZoneEntry = world.streamer.world_data.zone_at(global_pos)
	if entry == null:
		return null
	var zone: Zone = world.streamer.zone_node(entry.id)
	if zone == null:
		return null
	return _grid_of(zone)


func _grid_of(zone: Zone) -> EnvironmentGrid:
	var g: EnvironmentGrid = zone.get_node_or_null("EnvironmentGrid")
	if g == null:
		g = EnvironmentGrid.new()
		g.setup(zone, self)
		zone.add_child(g)
	return g


## Cráteres vivos, del más viejo al más nuevo: [{source, grid, cells}]. Tope por fuente (MoveData.crater_max) y tope
## total de celdas (CRATER_CELLS_MAX), así nunca se llena la cancha.
var _craters: Array = []
const CRATER_CELLS_MAX := 40


## Golpe fuerte contra el suelo: deja un cráter (estado "crater") en las celdas de suelo dentro del radio. Por ahora
## solo con reglas de arena (docs/PLAN_IDENTIDAD_COMBATE.md "Combate de arena").
func _on_ground_impact(pos: Vector2, radius: float, source: String = "", max_count: int = 3) -> void:
	if not arena_rules_at(pos):
		return
	var g := grid_at(pos)
	var crater := state_by_id("crater")
	if g == null or crater == null:
		return
	var center := g.zone.cell_at(pos)
	var r := int(ceil(radius / EnvironmentGrid.TILE))
	var made: Array[Vector2i] = []
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var cell := center + Vector2i(dx, dy)
			if g.cell_center(cell).distance_to(pos) > radius + 4.0:
				continue
			var tags := g.zone.get_tags(cell)
			if tags.has("agua") or not MapRules.is_walkable(g.zone, cell):
				continue
			g.set_state(cell, crater)
			made.append(cell)
	if not made.is_empty():
		_craters.append({"source": source, "grid": g, "cells": made})
		_trim_craters(source, max_count)
	Fx.burst(world.entities, pos, Color(0.55, 0.45, 0.35), int(clampf(radius, 8.0, 30.0)), radius * 2.5)


## Borra los cráteres más viejos: los de esta fuente que pasen su tope y, después, los que pasen el tope total de
## celdas. (Los que ya se taparon solos por tiempo no cuentan.)
func _trim_craters(source: String, max_count: int) -> void:
	_craters = _craters.filter(func(c): return is_instance_valid(c["grid"]) and c["cells"].any(
		func(cell): return c["grid"].state_at(cell) != null and c["grid"].state_at(cell).id == "crater"))
	var mine := _craters.filter(func(c): return c["source"] == source)
	while mine.size() > maxi(1, max_count):
		_erase_crater(mine.pop_front())
	var total := 0
	for c in _craters:
		total += c["cells"].size()
	while total > CRATER_CELLS_MAX and _craters.size() > 1:
		var old: Dictionary = _craters[0]
		total -= old["cells"].size()
		_erase_crater(old)


func _erase_crater(c: Dictionary) -> void:
	_craters.erase(c)
	if not is_instance_valid(c["grid"]):
		return
	for cell in c["cells"]:
		var st: EnvCellState = c["grid"].state_at(cell)
		if st != null and st.id == "crater":
			c["grid"].set_state(cell, null)


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
		var hit := {cell: true}
		if rule.flood_limit > 0:
			_flood(g, cell, rule, new_state, hit)
		if new_state != null and new_state.status_on_impact and new_state.creature_status != null:
			_shock(g, hit, new_state.creature_status)
		_feedback(rule, g.cell_center(cell))
		return


## Qué regla aplicaría un elemento en esa posición, sin aplicarla (null = ninguna). Lo usa la IA (TacticalMind, IA-3).
func rule_for(element: ElementType, global_pos: Vector2) -> ReactionRule:
	var g := grid_at(global_pos)
	if g == null or element == null:
		return null
	var cell := g.zone.cell_at(global_pos)
	return _first_rule(element, g.tags_of(cell), g.state_at(cell))


func _first_rule(element: ElementType, tags: PackedStringArray, st: EnvCellState) -> ReactionRule:
	for rule in rules:
		if rule.element == element and _matches(rule, tags, st):
			return rule
	return null


## Un golpe de ese elemento ahí le haría mal al que está parado (deja un estado que pone un problema: la descarga
## eléctrica en el agua o lo mojado).
func harms_at(element: ElementType, global_pos: Vector2) -> bool:
	var rule := rule_for(element, global_pos)
	var st := state_by_id(rule.set_state) if rule != null else null
	return st != null and st.creature_status != null


## Un golpe de `first` ahí prepara la celda para que uno de `then` le haga mal (mojar el suelo y después la descarga).
func sets_up(first: ElementType, global_pos: Vector2, then: ElementType) -> bool:
	var g := grid_at(global_pos)
	var rule := rule_for(first, global_pos)
	if g == null or rule == null or then == null:
		return false
	var cell := g.zone.cell_at(global_pos)
	var mid := state_by_id(rule.set_state)
	if mid == null or mid == g.state_at(cell):
		return false
	var follow := _first_rule(then, g.tags_of(cell), mid)
	var bad := state_by_id(follow.set_state) if follow != null else null
	return bad != null and bad.creature_status != null


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
func _flood(g: EnvironmentGrid, start: Vector2i, rule: ReactionRule, st: EnvCellState, hit: Dictionary) -> void:
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
				hit[n] = true
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

## Una embestida chocó contra un objeto: las rocas frágiles se rompen con golpes fuertes.
func _on_object_struck(obj: Node, power: float) -> void:
	if is_instance_valid(obj) and obj.has_tag("fragil") and power >= obj.break_power:
		obj.shatter()


## Descarga de una vez: el estado le llega a cada criatura que está en las celdas alcanzadas (salvo las que flotan),
## con la mitad de su duración (es de rebote: el golpe directo pega más).
const SHOCK_DURATION := 0.5
func _shock(g: EnvironmentGrid, cells: Dictionary, status: StatusEffect) -> void:
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.is_down() or c.health.is_invulnerable() or not grounded(c) or grid_at(c.global_position) != g:
			continue
		if cells.has(g.zone.cell_at(c.global_position)):
			c.statuses.apply(status, SHOCK_DURATION)


## Si toca el suelo o el agua (los Voladores, Fantasma y los que levitan flotan; el que pelea montado va arriba de
## su Pokémon de Surf).
func grounded(c: Creature) -> bool:
	if FieldMoves.water_mode_of(c.instance.species) == "flota":
		return false
	var fm = world.get("field_moves")
	return not (fm != null and fm.water_mode == "montado" and c == world.get("companion"))


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
		if st != null and st.status_on_impact:
			continue  # (ya la recibió al impactar)
		# Los que acumulan (Paralizado) se aplican en cada tick; el resto, si no lo tiene ya.
		if st != null and st.creature_status != null and (st.creature_status.buildup or not c.statuses.has_status(st.creature_status.id)):
			c.statuses.apply(st.creature_status)
