class_name CombatWeather
extends Node
## Clima de pelea (Danza Lluvia, Día Soleado, Granizo, Tormenta de Arena: `MoveData.weather`). Dura `DURATION` s y el
## último que se tiró pisa al anterior.
##  · Lluvia: Agua pega ×1,5 y Fuego ×0,5; moja a los que pelean (Empapado, salvo los tipo Agua).
##  · Sol: Fuego pega ×1,5 y Agua ×0,5; cuenta como de día para Clorofila.
##  · Granizo: saca `STORM_DAMAGE` de vida por segundo a los que pelean, salvo tipo Hielo.
##  · Arena: lo mismo, salvo tipos Roca, Tierra y Acero.
## Se guarda en estáticas para que `Damage` y las habilidades lo lean sin conocer el mundo; el nodo (hijo de la raíz, uno
## solo) hace correr el tiempo y dibuja el efecto en pantalla.
## **Un clima por ámbito** (2026-11-08): el juego del jugador es el ámbito 0 (`current`); en el servidor online cada pelea
## (`NetMatch`) es el suyo, así dos peleas a la vez no se pisan el clima (`scope_of`, `kind_for`).

const DURATION := 20.0
const BOOST := 1.5
const NERF := 0.5
const STORM_DAMAGE := 0.02
const SOAK_EVERY := 2.0
const NODE_NAME := "CombatWeather"
const INFO := {
	"lluvia": {"text": "¡Empezó a llover!", "color": Color(0.45, 0.65, 1.0), "boost": "agua", "nerf": "fuego",
		"tint": Color(0.2, 0.3, 0.55, 0.16)},
	"sol": {"text": "¡El sol pega fuerte!", "color": Color(1.0, 0.8, 0.35), "boost": "fuego", "nerf": "agua",
		"tint": Color(1.0, 0.8, 0.4, 0.1)},
	"granizo": {"text": "¡Empezó a granizar!", "color": Color(0.8, 0.95, 1.0), "immune": ["hielo"],
		"tint": Color(0.45, 0.62, 0.9, 0.22)},
	"arena": {"text": "¡Se levantó una tormenta de arena!", "color": Color(0.9, 0.75, 0.45), "immune": ["roca", "tierra", "acero"],
		"tint": Color(0.75, 0.6, 0.3, 0.2)},
}

## El clima del ámbito 0 (el juego del jugador; lo leen los tests y lo que no tiene criatura a mano).
static var current := ""
static var time_left := 0.0
## Ámbito → {"kind", "time_left", "source"}.
static var scopes: Dictionary = {}

var _tick := 0.0
var _soak := 0.0
var _layer: CanvasLayer
var _source: Creature


## Lo larga `by` (ver Creature.use_slot).
static func start(kind: String, by: Creature) -> void:
	if not INFO.has(kind):
		return
	var root := by.get_tree().root
	var node := root.get_node_or_null(NODE_NAME) as CombatWeather
	if node == null:
		node = CombatWeather.new()
		node.name = NODE_NAME
		root.add_child(node)
	var scope := scope_of(by)
	scopes[scope] = {"kind": kind, "time_left": DURATION, "source": by}
	if scope == 0:
		current = kind
		time_left = DURATION
		node._source = by
		node._show(kind)
	Events.signature_triggered.emit(by, INFO[kind]["text"], INFO[kind]["color"])


## Corta el clima del juego del jugador (ámbito 0).
static func stop(tree: SceneTree) -> void:
	scopes.erase(0)
	current = ""
	time_left = 0.0
	var node := tree.root.get_node_or_null(NODE_NAME) as CombatWeather
	if node != null:
		node._clear_fx()


## Corta el clima del ámbito de ese nodo (una pelea del servidor al terminar).
static func stop_for(n: Node) -> void:
	var scope := scope_of(n)
	if scope == 0:
		if n.is_inside_tree():
			stop(n.get_tree())
		return
	scopes.erase(scope)


## El ámbito de un nodo: la pelea del servidor (NetMatch) que lo contiene, o 0 (el juego del jugador).
static func scope_of(n: Node) -> int:
	var p := n
	while p != null:
		if p is NetMatch:
			return p.get_instance_id()
		p = p.get_parent()
	return 0


## El clima que le toca a esa criatura ("" = ninguno).
static func kind_for(n: Node) -> String:
	if n == null or not is_instance_valid(n):
		return current
	return str(scopes.get(scope_of(n), {}).get("kind", ""))


## Cuánto cambia el clima el daño de un ataque de ese tipo. `by` = quién lo tira (su ámbito); sin él, el del jugador.
static func damage_mult(element: ElementType, by: Node = null) -> float:
	var kind := kind_for(by) if by != null else current
	if kind == "" or element == null:
		return 1.0
	var info: Dictionary = INFO[kind]
	if info.get("boost", "") == element.id:
		return BOOST
	if info.get("nerf", "") == element.id:
		return NERF
	return 1.0


static func hurts(c: Creature) -> bool:
	var kind := kind_for(c)
	return kind != "" and INFO[kind].has("immune") and not _has_type(c, INFO[kind]["immune"])


static func _has_type(c: Creature, ids: Array) -> bool:
	for t: ElementType in c.instance.types():
		if t != null and t.id in ids:
			return true
	return false


## Cuánto le conviene a `actor` largar ese clima (0 = no le conviene; lo usa TacticalMind).
static func value_for(kind: String, actor: Creature, foe: Creature) -> float:
	if kind_for(actor) == kind or not INFO.has(kind):
		return 0.0
	var info: Dictionary = INFO[kind]
	if info.has("immune"):
		return 1.0 if _has_type(actor, info["immune"]) and is_instance_valid(foe) and not _has_type(foe, info["immune"]) else 0.0
	for m: MoveData in actor.moves.slots:
		if m != null and m.power > 0.0 and m.element != null and m.element.id == info["boost"]:
			return 1.3
	return 0.0


func _process(delta: float) -> void:
	if scopes.is_empty():
		return
	for scope in scopes.keys():
		scopes[scope]["time_left"] -= delta
		if scopes[scope]["time_left"] <= 0.0:
			if scope == 0:
				stop(get_tree())
			else:
				scopes.erase(scope)
	time_left = float(scopes.get(0, {}).get("time_left", 0.0))
	if scopes.is_empty():
		return
	_tick += delta
	_soak += delta
	var hit_now := _tick >= 1.0
	var soak_now := _soak >= SOAK_EVERY
	if hit_now:
		_tick = 0.0
	if soak_now:
		_soak = 0.0
	if not hit_now and not soak_now:
		return
	for n in get_tree().get_nodes_in_group("creatures"):
		var c := n as Creature
		if c == null or c.is_down():
			continue
		var kind := kind_for(c)
		if kind == "" or not _fighting(c, scopes.get(scope_of(c), {}).get("source")):
			continue
		if hit_now and hurts(c):
			c.take_status_damage(c.health.max_hp() * STORM_DAMAGE)
		if soak_now and kind == "lluvia" and DB.statuses.has("empapado") and not _has_type(c, ["agua"]):
			c.statuses.apply(DB.statuses["empapado"])


## Los que están peleando, no todos los salvajes del mapa (el que lo tiró y su rival cuentan desde el primer momento).
func _fighting(c: Creature, source) -> bool:
	if c.engaged():
		return true
	if not is_instance_valid(source):
		return false
	return c == source or c == source.target


func _show(kind: String) -> void:
	_clear_fx()
	if DisplayServer.get_name() == "headless":
		return
	_layer = CanvasLayer.new()
	_layer.layer = 3
	add_child(_layer)
	var size := get_viewport().get_visible_rect().size
	var tint := ColorRect.new()
	tint.color = INFO[kind]["tint"]
	tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(tint)
	if kind == "sol":
		return
	var p := CPUParticles2D.new()
	p.position = Vector2(size.x * 0.5, -10.0)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(size.x * 0.7, 4.0)
	p.spread = 4.0
	match kind:
		"lluvia":
			p.amount = 220
			p.lifetime = 0.7
			p.direction = Vector2(-0.2, 1.0)
			p.initial_velocity_min = size.y * 1.4
			p.initial_velocity_max = size.y * 1.7
			p.color = Color(0.25, 0.42, 0.9, 0.7)
			p.scale_amount_min = 1.0
			p.scale_amount_max = 1.0
			p.texture = _streak(2, 16)
			p.particle_flag_align_y = true
		"granizo":
			p.amount = 110
			p.texture = _streak(5, 5)
			p.lifetime = 0.9
			p.direction = Vector2(-0.1, 1.0)
			p.initial_velocity_min = size.y * 1.0
			p.initial_velocity_max = size.y * 1.2
			p.color = Color(1.0, 1.0, 1.0, 0.95)
			p.scale_amount_min = 0.8
			p.scale_amount_max = 1.5
		"arena":
			p.amount = 300
			p.lifetime = 1.1
			p.texture = _streak(8, 3)
			p.position = Vector2(size.x + 10.0, size.y * 0.5)
			p.emission_rect_extents = Vector2(4.0, size.y * 0.6)
			p.direction = Vector2(-1.0, 0.1)
			p.initial_velocity_min = size.x * 0.9
			p.initial_velocity_max = size.x * 1.2
			p.color = Color(0.68, 0.48, 0.2, 0.7)
			p.scale_amount_min = 1.0
			p.scale_amount_max = 2.0
	_layer.add_child(p)


func _clear_fx() -> void:
	if is_instance_valid(_layer):
		_layer.queue_free()
	_layer = null


static func _streak(w: int, h: int) -> Texture2D:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	return ImageTexture.create_from_image(img)
