class_name CreatureSprite
extends Node2D
## Dibuja una criatura con las hojas de animación PMD (8 direcciones) y su feedback de combate:
## destello al ser golpeada, aro de carga, estelas al esquivar, color de estado alterado y barra de vida.
## Lee facing, velocity y componentes de su padre (Creature).

## Las hojas PMD centran el cuerpo en el frame; subimos el dibujo para que los pies queden en el origen.
@export var foot_offset := 8.0

var species: SpeciesData:
	set(value):
		species = value
		_anims = DB.anims_of(value) if value != null else {}

## Progreso de carga de un ataque (0..1); -1 = sin carga.
var charge := -1.0
var charge_color := Color.WHITE
var afterimages := false

var _anims: Dictionary = {}
var _anim := "Idle"
var _time := 0.0
var _forced := ""
var _forced_left := 0.0
var _flash := 0.0
var _ghosts: Array = []  # [posición global, frame src, rect, alpha]
var _ghost_timer := 0.0


func _process(delta: float) -> void:
	_time += delta
	_forced_left = maxf(0.0, _forced_left - delta)
	_flash = maxf(0.0, _flash - delta)
	var parent := get_parent() as CharacterBody2D
	var want := "Idle"
	if _forced_left > 0.0:
		want = _forced
	elif parent != null and parent.velocity.length() > 5.0:
		want = "Walk"
	if want != _anim and _anims.has(want):
		_anim = want
		_time = 0.0
	_update_ghosts(delta)
	queue_redraw()


## Reproduce una animación (Attack, Hurt...) una vez, durante como mucho max_time segundos.
func play_once(anim_name: String, max_time: float = 0.5) -> void:
	if not _anims.has(anim_name):
		return
	_forced = anim_name
	_forced_left = minf(_total(anim_name) / 60.0, max_time)
	_anim = anim_name
	_time = 0.0


func flash() -> void:
	_flash = 0.1


func _total(anim_name: String) -> int:
	var total := 0
	for d in _anims[anim_name]["durations"]:
		total += d
	return total


func _frame(durations: Array, loop: bool) -> int:
	var total := 0
	for d in durations:
		total += d
	var t := int(_time * 60.0)
	t = t % total if loop else mini(t, total - 1)
	var acc := 0
	for i in durations.size():
		acc += durations[i]
		if t < acc:
			return i
	return durations.size() - 1


## Fila PMD según la dirección: abajo, abajo-der, der, arriba-der, arriba, arriba-izq, izq, abajo-izq.
func _row(facing: Vector2) -> int:
	return posmod(int(round((PI / 2.0 - facing.angle()) / (PI / 4.0))), 8)


func _current() -> Array:
	## [textura, rect origen, rect destino] del frame actual, o [] si no hay hoja.
	if not _anims.has(_anim):
		return []
	var anim: Dictionary = _anims[_anim]
	var fw: float = anim["w"]
	var fh: float = anim["h"]
	var facing: Vector2 = get_parent().get("facing") if get_parent() != null else Vector2.DOWN
	var frozen := _status_frozen()
	var frame := 0 if frozen else _frame(anim["durations"], _anim == "Idle" or _anim == "Walk")
	return [DB.texture(anim["file"]), Rect2(frame * fw, _row(facing) * fh, fw, fh), Rect2(-fw / 2.0, -fh / 2.0 - foot_offset, fw, fh)]


func _status_frozen() -> bool:
	var c := get_parent()
	return c is Creature and c.statuses != null and not c.statuses.can_act()


func _update_ghosts(delta: float) -> void:
	for g in _ghosts:
		g[3] -= delta * 4.0
	_ghosts = _ghosts.filter(func(g): return g[3] > 0.0)
	if afterimages:
		_ghost_timer -= delta
		if _ghost_timer <= 0.0:
			_ghost_timer = 0.03
			var cur := _current()
			if not cur.is_empty():
				_ghosts.append([global_position, cur[1], cur[2], 0.5])


func _draw() -> void:
	var c := get_parent()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 7.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var cur := _current()
	if cur.is_empty():
		draw_circle(Vector2(0, -6), 6.0, Color.MAGENTA)
		return
	for g in _ghosts:
		draw_set_transform(g[0] - global_position, 0.0, Vector2.ONE)
		draw_texture_rect_region(cur[0], g[2], g[1], Color(0.7, 0.85, 1.6, g[3]))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var tint := Color.WHITE
	if c is Creature and c.statuses != null and not c.statuses.active.is_empty():
		var st: Color = c.statuses.tint()
		var pulse := 0.35 + 0.15 * sin(_time * 8.0)
		tint = Color.WHITE.lerp(st, 0.75 if _status_frozen() else pulse)
	if c is Creature and c.health != null and c.health.invulnerable_time > 0.0 and not c.health.is_dead():
		tint.a = 0.55
	if _flash > 0.0:
		tint = Color(3.0, 3.0, 3.0, tint.a)  # HDR: el glow hace brillar el golpe
	draw_texture_rect_region(cur[0], cur[2], cur[1], tint)

	if c is Creature:
		_draw_combat_ui(c, cur[2])


func _draw_combat_ui(c: Creature, dst: Rect2) -> void:
	if charge >= 0.0:
		var r := 11.0
		var col := Color(charge_color.r * 1.6, charge_color.g * 1.6, charge_color.b * 1.6)
		draw_arc(Vector2(0, -8), r, -PI / 2.0, -PI / 2.0 + TAU * charge, 24, col, 1.5)
	if c.health != null and c.health.shield_time > 0.0:
		draw_arc(Vector2(0, -8), 13.0, 0.0, TAU, 32, Color(0.7, 1.0, 1.6, 0.8), 1.5)
		draw_circle(Vector2(0, -8), 13.0, Color(0.5, 0.85, 1.0, 0.18))
	# Barra de vida sobre los salvajes heridos o en combate
	if c.team == Creature.Team.WILD and c.health != null and not c.health.is_dead() \
			and (c.health.ratio() < 1.0 or is_instance_valid(c.target)):
		var w := 22.0
		var y := dst.position.y + 2.0
		draw_rect(Rect2(-w / 2.0 - 1, y - 1, w + 2, 4), Color(0, 0, 0, 0.7))
		var ratio := c.health.ratio()
		var col := Color(0.35, 0.9, 0.4) if ratio > 0.5 else (Color(0.95, 0.8, 0.2) if ratio > 0.2 else Color(0.95, 0.3, 0.25))
		draw_rect(Rect2(-w / 2.0, y, w * ratio, 2), col)
		if not c.statuses.active.is_empty():
			draw_circle(Vector2(w / 2.0 + 4.0, y + 1.0), 2.0, c.statuses.tint())
