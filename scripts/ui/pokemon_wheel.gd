class_name PokemonWheel
extends Control
## Ruleta de Pokémon con joystick (pedido del usuario 2026-11-05, como la de armas de Red Dead Redemption 2): mientras
## mantenés R3 se ve el equipo en gajos y el stick izquierdo marca uno; al soltar, sale ese. Queda marcado aunque sueltes
## el stick; si no marcaste ninguno, o con Círculo/B, no cambia nada. Mientras está abierta el stick no te mueve, no se
## ataca y el tiempo va en cámara lenta (`SLOW`); online no, porque la pelea corre en el servidor y frenaría también al
## rival. Sirve en combate (el cambio de siempre, con su recarga) y fuera (cambia al activo).

const ACTION := "pokemon_wheel"
const SLOW := 0.2
## Cuánto hay que empujar el stick para marcar un gajo.
const STICK_MARK := 0.5
const RADIUS := 230.0
const HOLE := 92.0
const OPEN_TIME := 110.0  # ms, en reloj real (el tiempo del juego va lento)
const SECTOR_STEPS := 28

var world: Node
var is_open := false
## Lugar en `slots` del gajo marcado (-1 = ninguno).
var marked := -1
## Lugares del equipo que muestra la ruleta.
var slots: Array[int] = []
var _opened_at := 0
var _slowed := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS  # para cerrarse si se pausa el juego
	hide()


func _exit_tree() -> void:
	if is_open:
		close(false)


func _process(_delta: float) -> void:
	if not is_open:
		if Input.is_action_just_pressed(ACTION) and can_open():
			open()
		return
	if get_tree().paused or not _can_use():
		close(false)
		return
	if Input.is_action_just_pressed("ui_cancel"):
		close(false)
		return
	if not Input.is_action_pressed(ACTION):
		close(true)
		return
	_mark_from_stick(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	queue_redraw()


func can_open() -> bool:
	return not get_tree().paused and _can_use() and _slots_now().size() >= 2


func open() -> void:
	slots = _slots_now()
	marked = -1
	is_open = true
	Controls.wheel_open = true
	_opened_at = Time.get_ticks_msec()
	_slowed = not _online()
	if _slowed:
		world.get_node("CombatFeedback").set_slowdown(SLOW)
	show()
	queue_redraw()


## `choose` = hacer el cambio del gajo marcado.
func close(choose: bool) -> void:
	is_open = false
	Controls.wheel_open = false
	if _slowed:
		world.get_node("CombatFeedback").set_slowdown(1.0)
		_slowed = false
	hide()
	if choose and marked >= 0:
		_choose(slots[marked])


## Lo mismo que pide un cambio de Pokémon: nada de charlas, ni pantallas de evolución, ni fundidos de puerta.
func _can_use() -> bool:
	var story: StoryDirector = world.story
	if story != null and (story.dialog.active or (story.busy and not _fighting())):
		return false
	if world.evolutions != null and (world.evolutions.showing or world.evolutions.moves.showing):
		return false
	return not (world.warps != null and world.warps.busy) and not (world.balloon != null and world.balloon.flying)


func _slots_now() -> Array[int]:
	var out: Array[int] = []
	if _online():
		out.assign(world.online.battle.my_team)
	else:
		out.assign(range(GameState.party.size()))
	return out


func _online() -> bool:
	return world.online != null and world.online.battle != null and world.online.battle.active


func _fighting() -> bool:
	return world.combat.in_battle or _online() or (world.arena != null and world.arena.active)


func _mark_from_stick(stick: Vector2) -> void:
	if stick.length() < STICK_MARK:
		return
	var step := TAU / slots.size()
	var i: int = posmod(roundi((stick.angle() + PI / 2.0) / step), slots.size())
	if GameState.party[slots[i]].hp > 0.0:  # un debilitado no se puede marcar
		marked = i


func _choose(index: int) -> void:
	if index == GameState.active_index:
		return
	if _fighting():
		world.combat.switch_to(index)  # con su recarga, y online lo decide el servidor
	elif GameState.set_active(index):
		Events.message_requested.emit("¡Adelante, %s!" % GameState.active().display_name())


func _draw() -> void:
	var font := get_theme_default_font()
	var view := get_viewport_rect().size
	var c := view / 2.0
	draw_rect(Rect2(Vector2.ZERO, view), Color(0.02, 0.03, 0.06, 0.5))
	var grow := clampf((Time.get_ticks_msec() - _opened_at) / OPEN_TIME, 0.0, 1.0)
	draw_set_transform(c, 0.0, Vector2.ONE * lerpf(0.82, 1.0, grow))
	var step := TAU / maxi(slots.size(), 1)
	for i in slots.size():
		_draw_slice(i, -PI / 2.0 + i * step, step, font)
	draw_circle(Vector2.ZERO, HOLE - 4.0, Color(UiStyle.BG, 0.96))
	draw_arc(Vector2.ZERO, HOLE - 4.0, 0.0, TAU, 64, UiStyle.BORDER, 2.0, true)
	_draw_center(font)
	draw_set_transform(Vector2.ZERO)


func _draw_slice(i: int, mid: float, step: float, font: Font) -> void:
	var inst: CreatureInstance = GameState.party[slots[i]]
	var down := inst.hp <= 0.0
	var fill := Color(UiStyle.BG_SOFT, 0.9)
	if i == marked:
		fill = Color(0.42, 0.33, 0.1, 0.96)
	elif down:
		fill = Color(0.1, 0.1, 0.11, 0.86)
	var gap := 0.012 * TAU
	var points := PackedVector2Array()
	for k in SECTOR_STEPS + 1:
		points.append(Vector2.RIGHT.rotated(mid - step / 2.0 + gap / 2.0 + (step - gap) * k / SECTOR_STEPS) * RADIUS)
	for k in SECTOR_STEPS + 1:
		points.append(Vector2.RIGHT.rotated(mid + step / 2.0 - gap / 2.0 - (step - gap) * k / SECTOR_STEPS) * HOLE)
	draw_colored_polygon(points, fill)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, UiStyle.ACCENT if i == marked else UiStyle.BORDER, 3.0 if i == marked else 1.5, true)
	var at := Vector2.RIGHT.rotated(mid) * (HOLE + RADIUS) / 2.0
	var pic := DB.portrait_of(inst.species, inst.shiny)
	var look := Color(0.42, 0.42, 0.42) if down else Color.WHITE
	if pic != null:
		var side := 64.0
		draw_texture_rect(pic, Rect2(at - Vector2(side, side + 12.0) / 2.0, Vector2(side, side)), false, look)
	if slots[i] == GameState.active_index:
		draw_arc(at + Vector2(0, -6), 42.0, 0.0, TAU, 40, UiStyle.ACCENT, 2.0, true)
	var bar := Rect2(at + Vector2(-34, 28), Vector2(68, 6))
	draw_rect(bar, Color(0, 0, 0, 0.7))
	var ratio := clampf(inst.hp / maxf(inst.max_hp(), 1.0), 0.0, 1.0)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), UiStyle.GOOD if ratio > 0.3 else UiStyle.BAD)


func _draw_center(font: Font) -> void:
	var lines: Array = []  # [texto, tamaño, color]
	if marked >= 0:
		var inst: CreatureInstance = GameState.party[slots[marked]]
		lines.append([inst.label(), 18, UiStyle.ACCENT])
		lines.append(["Nv. %d" % inst.level, 15, UiStyle.TEXT])
		lines.append(["PS %d/%d" % [ceili(inst.hp), ceili(inst.max_hp())], 15, UiStyle.TEXT])
		if slots[marked] == GameState.active_index:
			lines.append(["Ya está afuera", 13, UiStyle.TEXT_DIM])
		else:
			lines.append(["Soltá para cambiar", 13, UiStyle.TEXT_DIM])
	else:
		lines.append(["Mové el stick", 15, UiStyle.TEXT])
		lines.append(["Soltá %s para elegir" % Controls.pad_label(ACTION), 13, UiStyle.TEXT_DIM])
	var y := -11.0 * (lines.size() - 1) + 5.0
	for line: Array in lines:
		draw_string(font, Vector2(-HOLE, y), line[0], HORIZONTAL_ALIGNMENT_CENTER, HOLE * 2.0, line[1], line[2])
		y += 22.0
