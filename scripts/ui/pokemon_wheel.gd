class_name PokemonWheel
extends Control
## Ruleta de Pokémon con joystick (pedido del usuario 2026-11-05, como la de armas de Red Dead Redemption 2): mientras
## mantenés R3 se ve el equipo en 6 gajos fijos (los libres, vacíos) y el stick izquierdo marca uno; al soltar, sale ese. Queda marcado aunque sueltes
## el stick; si no marcaste ninguno, o con Círculo/B, no cambia nada. Mientras está abierta el stick no te mueve, no se
## ataca y el tiempo va en cámara lenta (`SLOW`); online no, porque la pelea corre en el servidor y frenaría también al
## rival. Sirve en combate (el cambio de siempre, con su recarga) y fuera (cambia al activo).

const ACTION := "pokemon_wheel"
const SLOTS := 6
const SLOW := 0.2
## Cuánto hay que empujar el stick para marcar un gajo.
const STICK_MARK := 0.5
## Medidas de la pintura (sprites/ui/ruleta.png, tools/make_wheel_art.py): borde de afuera, aro dorado y agujero del centro.
const OUTER := 250.0
const RIM := 212.0
const HOLE := 97.0
const RING := preload("res://sprites/ui/ruleta.png")
const OPEN_TIME := 110.0  # ms, en reloj real (el tiempo del juego va lento)
const SECTOR_STEPS := 20

var world: Node
var is_open := false
## Gajo marcado (-1 = ninguno).
var marked := -1
## Lugar del equipo de cada gajo (-1 = vacío).
var slots: Array[int] = []
var _opened_at := 0
var _slowed := false
var _ring: TextureRect
var _top: Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS  # para cerrarse si se pausa el juego
	_ring = TextureRect.new()  # la pintura suave, entre los gajos y los retratos, que van pixelados
	_ring.texture = RING
	_ring.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ring.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ring)
	_top = Control.new()
	_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top.draw.connect(_draw_top)
	add_child(_top)
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
	_redraw()


func can_open() -> bool:
	return not get_tree().paused and _can_use() and _slots_now().filter(func(i): return i >= 0).size() >= 2


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
	_redraw()


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
	var team: Array = world.online.battle.my_team if _online() else range(GameState.party.size())
	var out: Array[int] = []
	for i in SLOTS:
		out.append(team[i] if i < team.size() else -1)
	return out


func _online() -> bool:
	return world.online != null and world.online.battle != null and world.online.battle.active


func _fighting() -> bool:
	return world.combat.in_battle or _online() or (world.arena != null and world.arena.active)


func _mark_from_stick(stick: Vector2) -> void:
	if stick.length() < STICK_MARK:
		return
	var i: int = posmod(roundi((stick.angle() - _middle(0)) / (TAU / SLOTS)), SLOTS)
	if slots[i] >= 0 and GameState.party[slots[i]].hp > 0.0:  # un vacío o un debilitado no se marcan
		marked = i


## Ángulo del centro del gajo `i`: el primero arriba a la derecha, como los rayos de la pintura.
func _middle(i: int) -> float:
	return -PI / 3.0 + i * TAU / SLOTS


func _choose(index: int) -> void:
	if index == GameState.active_index:
		return
	if _fighting():
		world.combat.switch_to(switch_index(index))  # con su recarga, y online lo decide el servidor
	elif GameState.set_active(index):
		Events.message_requested.emit("¡Adelante, %s!" % GameState.active().display_name())


## Lo que hay que pedirle a CombatDirector.switch_to para sacar a ese Pokémon: su lugar en tu equipo, salvo online, donde
## se pide por el lugar en el equipo de la pelea (los gajos guardan el lugar en tu equipo).
func switch_index(party_index: int) -> int:
	return world.online.battle.my_team.find(party_index) if _online() else party_index


func _redraw() -> void:
	queue_redraw()
	_top.queue_redraw()
	var side := OUTER * 2.0 * _grow()
	_ring.size = Vector2(side, side)
	_ring.position = get_viewport_rect().size / 2.0 - _ring.size / 2.0


func _grow() -> float:
	return lerpf(0.82, 1.0, clampf((Time.get_ticks_msec() - _opened_at) / OPEN_TIME, 0.0, 1.0))


func _draw() -> void:
	var view := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, view), Color(0.02, 0.03, 0.06, 0.55))
	draw_set_transform(view / 2.0, 0.0, Vector2.ONE * _grow())
	for i in SLOTS:
		_draw_slice(i)
	draw_circle(Vector2.ZERO, HOLE, Color(UiStyle.BG, 0.97))
	draw_set_transform(Vector2.ZERO)


func _draw_slice(i: int) -> void:
	var fill := Color(0.04, 0.06, 0.1, 0.86)
	if i == marked:
		fill = Color(0.78, 0.55, 0.12, 0.92)
	elif slots[i] < 0 or GameState.party[slots[i]].hp <= 0.0:
		fill = Color(0.03, 0.03, 0.04, 0.72)
	var half := PI / SLOTS
	var points := PackedVector2Array()
	for k in SECTOR_STEPS + 1:
		points.append(Vector2.RIGHT.rotated(_middle(i) - half + 2.0 * half * k / SECTOR_STEPS) * RIM)
	for k in SECTOR_STEPS + 1:
		points.append(Vector2.RIGHT.rotated(_middle(i) + half - 2.0 * half * k / SECTOR_STEPS) * HOLE)
	draw_colored_polygon(points, fill)


func _draw_top() -> void:
	var font := get_theme_default_font()
	_top.draw_set_transform(get_viewport_rect().size / 2.0, 0.0, Vector2.ONE * _grow())
	for i in SLOTS:
		if slots[i] >= 0:
			_draw_member(i)
	_draw_center(font)
	_top.draw_set_transform(Vector2.ZERO)


func _draw_member(i: int) -> void:
	var inst: CreatureInstance = GameState.party[slots[i]]
	var at := Vector2.RIGHT.rotated(_middle(i)) * (HOLE + RIM) / 2.0
	var pic := DB.portrait_of(inst.species, inst.shiny)
	var side := 72.0
	if pic != null:
		var look := Color(0.4, 0.4, 0.4) if inst.hp <= 0.0 else Color.WHITE
		_top.draw_texture_rect(pic, Rect2(at - Vector2(side, side + 14.0) / 2.0, Vector2(side, side)), false, look)
	if slots[i] == GameState.active_index:  # el que está afuera
		_top.draw_rect(Rect2(at - Vector2(side, side + 14.0) / 2.0, Vector2(side, side)), UiStyle.ACCENT, false, 2.0)
	var bar := Rect2(at + Vector2(-36, 32), Vector2(72, 7))
	_top.draw_rect(bar, Color(0, 0, 0, 0.8))
	var ratio := clampf(inst.hp / maxf(inst.max_hp(), 1.0), 0.0, 1.0)
	_top.draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), UiStyle.GOOD if ratio > 0.3 else UiStyle.BAD)


func _draw_center(font: Font) -> void:
	var lines: Array = []  # [texto, tamaño, color]
	if marked >= 0:
		var inst: CreatureInstance = GameState.party[slots[marked]]
		lines.append([inst.label(), 18, UiStyle.ACCENT])
		lines.append(["Nv. %d" % inst.level, 15, UiStyle.TEXT])
		lines.append(["PS %d/%d" % [ceili(inst.hp), ceili(inst.max_hp())], 15, UiStyle.TEXT])
		lines.append(["Ya está afuera" if slots[marked] == GameState.active_index else "Soltá para cambiar", 13, UiStyle.TEXT_DIM])
	else:
		lines.append(["Mové el stick", 15, UiStyle.TEXT])
		lines.append(["Soltá %s para elegir" % Controls.pad_label(ACTION), 13, UiStyle.TEXT_DIM])
	var y := -11.0 * (lines.size() - 1) + 5.0
	for line: Array in lines:
		_top.draw_string(font, Vector2(-HOLE, y), line[0], HORIZONTAL_ALIGNMENT_CENTER, HOLE * 2.0, line[1], line[2])
		y += 22.0
