class_name Fishing
extends Node
## Pesca (pedido del usuario 2026-11-06): en los puntos de pesca (data/world/pesca_puntos.json, burbujas en el agua y un
## cartel) se usa la E frente al agua. Se tira la línea, a los pocos segundos pica ("¡!": hay que apretar a tiempo) y sale
## el minijuego: frenar la aguja en la zona verde, más chica y rápida con los raros. Si sale bien, el Pokémon salta del agua
## y es una pelea normal contra un salvaje. Qué se pesca sale de FireRed (data/world/pesca.json, tools/build_fishing.py),
## según la mejor caña que tengas (las dan los tres Pescadores, como en FireRed).

## Objeto de cada caña → tabla, de la mejor a la peor.
const RODS := [["cana_super", "super"], ["cana_buena", "buena"], ["cana_vieja", "vieja"]]
const TABLES_PATH := "res://data/world/pesca.json"
const SPOTS_PATH := "res://data/world/pesca_puntos.json"
const WAIT_MIN := 1.5
const WAIT_MAX := 4.0
## Segundos para reaccionar cuando pica.
const BITE_WINDOW := 0.8
## Cuánto hay que apretar: los de menos del `RARE_PCT` % de esa caña son raros.
const RARE_PCT := 15
const ZONE_COMMON := 0.30
const ZONE_RARE := 0.14
const NEEDLE_COMMON := 1.1  # idas y vueltas enteras por segundo... la mitad
const NEEDLE_RARE := 1.9
const SIGN := preload("res://sprites/props/cartel_pesca.png")

enum Phase { IDLE, WAITING, BITE, GAME }

var world: Node
var phase := Phase.IDLE
## Minijuego (0-1): dónde está la aguja y dónde la zona verde.
var needle := 0.0
var zone_start := 0.0
var zone_width := 0.0
## Para los tests: segundos fijos hasta que pique (< 0 = al azar).
var fixed_wait := -1.0
var tables: Dictionary = {}
## zona → [{water, stand, sign}], en celdas locales.
var spots: Dictionary = {}
var _timer := 0.0
var _needle_time := 0.0
var _needle_speed := 1.0
var _hooked: Dictionary = {}
var _rod_table := ""
var _spot: Dictionary = {}
var _line: FishingLine
var _ui: FishingBar
signal finished(result: String)


func _ready() -> void:
	world = get_parent()
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(TABLES_PATH))
	tables = parsed if parsed is Dictionary else {}
	parsed = JSON.parse_string(FileAccess.get_file_as_string(SPOTS_PATH))
	if parsed is Array:
		for s: Dictionary in parsed:
			var spot := {"water": _cell(s["water"]), "stand": _cell(s["stand"]), "sign": _cell(s["sign"]) if s.has("sign") else null}
			if not spots.has(s["zone"]):
				spots[s["zone"]] = []
			spots[s["zone"]].append(spot)
	world.story.interactions.insert(0, _on_interact)  # antes que Surf: en un punto de pesca, la E pesca
	_place_marks.call_deferred()
	_ui = FishingBar.new()
	_ui.fishing = self
	world.get_node("UI").add_child.call_deferred(_ui)


static func _cell(a: Array) -> Vector2i:
	return Vector2i(int(a[0]), int(a[1]))


## Las burbujas y los carteles, en el mundo (son decorado: no chocan).
func _place_marks() -> void:
	var data: WorldData = world.streamer.world_data
	var ts := data.tile_size
	for z in data.zones:
		for s: Dictionary in spots.get(z.id, []):
			var mark := FishingMark.new()
			mark.position = Vector2((z.origin + s["water"]) * ts) + Vector2.ONE * ts / 2.0
			world.entities.get_parent().add_child(mark)
			if s["sign"] != null:
				var sign_post := Sprite2D.new()
				sign_post.texture = SIGN
				sign_post.centered = false
				sign_post.position = Vector2((z.origin + s["sign"]) * ts) + Vector2((ts - SIGN.get_width()) / 2.0, ts - SIGN.get_height())
				sign_post.z_index = -1
				world.entities.get_parent().add_child(sign_post)


## La mejor caña que tenés: su tabla, o "" si no tenés ninguna.
func best_rod() -> String:
	for r: Array in RODS:
		if GameState.item_count(r[0]) > 0:
			return r[1]
	return ""


## Elige qué pica, según los % de FireRed para esa caña.
func roll(zone_id: String, rod: String) -> Dictionary:
	var rows: Array = tables.get(zone_id, {}).get(rod, [])
	var dice := randi() % 100
	for row: Dictionary in rows:
		dice -= int(row["pct"])
		if dice < 0:
			return row
	return rows[0] if not rows.is_empty() else {}


func _on_interact(zone_id: String, cell: Vector2i, front: Vector2) -> bool:
	if not spots.has(zone_id) or phase != Phase.IDLE or (world.field_moves != null and world.field_moves.surfing):
		return false
	if not world.tags_at(front).has("agua"):
		return false
	if best_rod() == "" and world.field_moves != null and world.field_moves.can_use(FieldMoves.SURF_ITEM):
		return false  # sin caña, un punto de pesca no le saca la E a Surf
	for s: Dictionary in spots[zone_id]:
		var water: Vector2i = s["water"]
		if absi(cell.x - water.x) + absi(cell.y - water.y) <= 1:
			_cast(zone_id, s)
			return true
	return false


func _cast(zone_id: String, spot: Dictionary) -> void:
	var story: StoryDirector = world.story
	_rod_table = best_rod()
	if _rod_table == "":
		story.lock()
		await story._say("", PackedStringArray(["Algo se mueve en el agua... Con una caña se podría pescar.", "Dicen que en Ciudad Carmín vive un Gurú de la Pesca."]))
		story.unlock()
		return
	if GameState.party.all(func(p): return p.hp <= 0.0):
		story.lock()
		await story._say("", PackedStringArray(["Tus Pokémon no están para pelear con lo que salga del agua."]))
		story.unlock()
		return
	story.lock()
	_spot = spot
	_spot["zone"] = zone_id
	var entry: ZoneEntry = _entry(zone_id)
	var ts: int = world.streamer.world_data.tile_size
	var bobber := Vector2((entry.origin + spot["water"]) * ts) + Vector2.ONE * ts / 2.0
	world.trainer.facing = (bobber - world.trainer.global_position).normalized()
	_line = FishingLine.new()
	_line.from = world.trainer.global_position + Vector2(0, -10)
	_line.to = bobber
	world.entities.get_parent().add_child(_line)
	Sound.sfx("bola_lanzar")
	_timer = fixed_wait if fixed_wait >= 0.0 else randf_range(WAIT_MIN, WAIT_MAX)
	phase = Phase.WAITING
	_ui.refresh()


func _process(delta: float) -> void:
	if phase == Phase.IDLE:
		return
	var press := Input.is_action_just_pressed("capture") or Input.is_action_just_pressed("ui_accept")
	if phase == Phase.WAITING:
		_timer -= delta
		if press or Input.is_action_just_pressed("ui_cancel"):
			_end("recogida", "Recogiste la línea.")
		elif _timer <= 0.0:
			phase = Phase.BITE
			_timer = BITE_WINDOW
			_line.biting = true
			Sound.sfx("firma")
			_ui.refresh()
	elif phase == Phase.BITE:
		_timer -= delta
		if press:
			_start_game()
		elif _timer <= 0.0:
			_end("tarde", "Se escapó... Había que apretar más rápido.")
	elif phase == Phase.GAME:
		_needle_time += delta * _needle_speed
		needle = 1.0 - absf(fmod(_needle_time, 2.0) - 1.0)  # va y viene
		_ui.queue_redraw()
		if press:
			if needle >= zone_start and needle <= zone_start + zone_width:
				_land()
			else:
				_end("errado", "¡Se soltó!")


func _start_game() -> void:
	_hooked = roll(_spot["zone"], _rod_table)
	if _hooked.is_empty():
		_end("nada", "No pica nada acá.")
		return
	var rare: bool = int(_hooked["pct"]) < RARE_PCT
	zone_width = ZONE_RARE if rare else ZONE_COMMON
	zone_start = randf_range(0.05, 0.95 - zone_width)
	_needle_speed = NEEDLE_RARE if rare else NEEDLE_COMMON
	_needle_time = 0.0
	needle = 0.0
	phase = Phase.GAME
	_ui.refresh()


func _land() -> void:
	var sp: SpeciesData = DB.species.get(str(_hooked["species"]))
	var level := randi_range(int(_hooked["min"]), int(_hooked["max"]))
	var bobber: Vector2 = _line.to
	_end("pescado", "¡Picó un %s!" % sp.display_name)
	Sound.sfx("golpe_agua")
	Fx.burst(world.entities.get_parent(), bobber, Color(0.7, 0.9, 1.0), 16, 60.0)
	var wild: Creature = world.spawner.spawn(sp, level, _land_near())
	if is_instance_valid(wild) and is_instance_valid(world.companion):
		wild.target = world.companion
		if not world.combat.in_battle:
			world.combat.start_battle()


## Al lado tuyo, en tierra (salta del agua y pelea de este lado).
func _land_near() -> Vector2:
	var t: Trainer = world.trainer
	var side := Vector2(-t.facing.y, t.facing.x)
	var entry: ZoneEntry = _entry(_spot["zone"])
	var zone: Zone = world.streamer.zone_node(entry.id)
	var ts: int = world.streamer.world_data.tile_size
	for offset: Vector2 in [side * 40.0, -side * 40.0, -t.facing * 40.0, side * 20.0, -side * 20.0]:
		var at: Vector2 = t.global_position + offset
		if zone != null and MapRules.is_walkable(zone, zone.cell_at(at)):
			return at
	return t.global_position + Vector2.ONE * ts / 2.0


func _end(result: String, text: String) -> void:
	phase = Phase.IDLE
	if is_instance_valid(_line):
		_line.queue_free()
	_ui.refresh()
	world.story.unlock()
	Events.message_requested.emit(text)
	finished.emit(result)


func _entry(zone_id: String) -> ZoneEntry:
	for z in world.streamer.world_data.zones:
		if z.id == zone_id:
			return z
	return null


## El lugar del minijuego en pantalla: la barra y el aviso.
class FishingBar extends Control:
	const BAR := Vector2(420, 26)
	var fishing: Fishing

	func _ready() -> void:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		hide()

	func refresh() -> void:
		visible = fishing.phase != Fishing.Phase.IDLE
		queue_redraw()

	func _draw() -> void:
		var font := get_theme_default_font()
		var view := get_viewport_rect().size
		var key := Controls.label("capture")
		var top := view.y * 0.2
		match fishing.phase:
			Fishing.Phase.WAITING:
				_text(font, view, top, "Esperando que pique...   (%s: recoger)" % key, 18, UiStyle.TEXT)
			Fishing.Phase.BITE:
				_text(font, view, top, "¡¡PICÓ!!  ¡Apretá %s!" % key, 28, UiStyle.ACCENT)
			Fishing.Phase.GAME:
				_text(font, view, top, "¡Frená la aguja en lo verde con %s!" % key, 18, UiStyle.ACCENT)
				var rect := Rect2(Vector2((view.x - BAR.x) / 2.0, top + 12.0), BAR)
				draw_rect(rect.grow(4.0), Color(UiStyle.BG, 0.95))
				draw_rect(rect, Color(0.3, 0.12, 0.12))
				draw_rect(Rect2(rect.position + Vector2(rect.size.x * fishing.zone_start, 0), Vector2(rect.size.x * fishing.zone_width, rect.size.y)), UiStyle.GOOD)
				var x := rect.position.x + rect.size.x * fishing.needle
				draw_rect(Rect2(x - 2.0, rect.position.y - 6.0, 4.0, rect.size.y + 12.0), Color.WHITE)
				draw_rect(rect.grow(4.0), UiStyle.ACCENT, false, 2.0)

	func _text(font: Font, view: Vector2, y: float, text: String, size_px: int, color: Color) -> void:
		var w := view.x
		var wide := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x + 28.0
		draw_rect(Rect2((w - wide) / 2.0, y - size_px - 4.0, wide, size_px + 12.0), Color(UiStyle.BG, 0.92))
		draw_string(font, Vector2(0, y), text, HORIZONTAL_ALIGNMENT_CENTER, w, size_px, color)


## La línea y el corcho.
class FishingLine extends Node2D:
	var from := Vector2.ZERO
	var to := Vector2.ZERO
	var biting := false
	var _time := 0.0

	func _ready() -> void:
		z_index = 3

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		var dip := (sin(_time * 24.0) * 3.0 + 2.0) if biting else sin(_time * 3.0) * 0.8
		var end := to + Vector2(0, dip)
		draw_line(from, end, Color(0.95, 0.95, 0.9, 0.85), 1.0)
		draw_circle(end, 2.5, Color(0.9, 0.15, 0.1))
		draw_circle(end + Vector2(0, 1.5), 2.0, Color.WHITE)
		if biting:
			draw_arc(end, 5.0 + fmod(_time * 12.0, 5.0), 0.0, TAU, 16, Color(1, 1, 1, 0.8), 1.0)


## Las burbujas del punto de pesca.
class FishingMark extends Node2D:
	var _time := randf() * 3.0

	func _ready() -> void:
		z_index = -5  # sobre el agua y debajo de todos

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		for i in 3:
			var t := fmod(_time * 0.5 + i / 3.0, 1.0)
			var offset := Vector2(sin(i * 2.4) * 4.0, cos(i * 1.7) * 3.0)
			draw_arc(offset, 2.0 + t * 7.0, 0.0, TAU, 20, Color(0.92, 0.98, 1.0, (1.0 - t) * 0.75), 1.0)
		var b := fmod(_time * 0.9, 1.0)
		draw_circle(Vector2(-3, 2 - b * 6.0), 1.2, Color(1, 1, 1, 1.0 - b))
		draw_circle(Vector2(3, 3 - fmod(b + 0.4, 1.0) * 6.0), 1.0, Color(1, 1, 1, 1.0 - fmod(b + 0.4, 1.0)))
