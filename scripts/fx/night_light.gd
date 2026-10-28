class_name NightLight
extends RefCounted
## Día y noche, parte D (docs/PLAN_DIA_NOCHE.md): los efectos de combate y de fuego según la hora.
##  · `compensate(efecto)`: el CanvasModulate "Daylight" oscurece todo el mundo de noche; los efectos de ataque se
##    multiplican por su inversa (HDR 2D), así se ven igual de brillantes de día y de noche (no se apagan).
##  · `tune(luz)`: las PointLight2D de los efectos se agrandan y suben con la oscuridad (de noche el suelo está oscuro y
##    la luz se lee sin saturar a amarillo). De día quedan como estaban (≤ 0,35: la trampa del fuego amarillo); de
##    noche, hasta `NIGHT_MAX`.
##  · `apply(efecto)`: las dos cosas, para un efecto recién creado y sus luces hijas.
##  · `flash(...)`: un destello de luz corto en un impacto (solo con algo de oscuridad).
## Solo visual (decisión del usuario 2026-10-28): la hora no cambia reglas del combate.

## Energía máxima de noche (de día manda la de cada efecto, ≤ 0,35).
const NIGHT_MAX := 0.5
## Cuánto más grande y fuerte es una luz con oscuridad total.
const NIGHT_SCALE := 1.6
const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")


## Oscuridad actual (0 de día, en interiores y en las arenas; 1 de noche cerrada). 0 si no hay mundo.
static func darkness(from: Node) -> float:
	if from == null or not from.is_inside_tree():
		return 0.0
	var world := from.get_tree().get_first_node_in_group("world")
	var dn = world.get("day_night") if world != null else null
	return float(dn.darkness) if dn != null else 0.0


## Color del Daylight (lo que oscurece el mundo). Blanco si no hay.
static func ambient(from: Node) -> Color:
	if from == null or not from.is_inside_tree():
		return Color.WHITE
	var world := from.get_tree().get_first_node_in_group("world")
	var daylight := world.get_node_or_null("Daylight") as CanvasModulate if world != null else null
	return daylight.color if daylight != null else Color.WHITE


## Deshace la oscuridad del Daylight sobre un efecto (y sus hijos).
static func compensate(item: CanvasItem) -> void:
	var c := ambient(item)
	if c.is_equal_approx(Color.WHITE) or darkness(item) < 0.05:
		return  # de día el tinte cálido del sol también vale para los efectos
	var inv := Color(1.0 / maxf(0.3, c.r), 1.0 / maxf(0.3, c.g), 1.0 / maxf(0.3, c.b), 1.0)
	item.modulate *= inv


## Ajusta una luz de efecto a la oscuridad.
static func tune(light: PointLight2D, dark: float) -> void:
	if dark <= 0.01:
		return
	light.energy = minf(NIGHT_MAX, light.energy * lerpf(1.0, NIGHT_SCALE, dark))
	light.texture_scale *= lerpf(1.0, NIGHT_SCALE, dark)


## Para un efecto recién creado: compensa la oscuridad y ajusta sus luces.
static func apply(effect: CanvasItem) -> void:
	compensate(effect)
	var dark := darkness(effect)
	for c in effect.get_children():
		if c is PointLight2D:
			tune(c, dark)


## Un destello de luz corto (impactos de fuego, eléctricos...): solo con algo de oscuridad.
static func flash(parent: Node, at: Vector2, color: Color, radius: float = 24.0, life: float = 0.25) -> void:
	var dark := darkness(parent)
	if dark < 0.2 or parent == null:
		return
	var l := PointLight2D.new()
	l.texture = LIGHT_TEX
	l.color = color
	l.energy = minf(NIGHT_MAX, 0.45 * dark)
	l.texture_scale = radius / 32.0 * lerpf(1.0, NIGHT_SCALE, dark)
	parent.add_child(l)
	l.global_position = at
	var tw := l.create_tween()
	tw.tween_property(l, "energy", 0.0, life)
	tw.tween_callback(l.queue_free)
