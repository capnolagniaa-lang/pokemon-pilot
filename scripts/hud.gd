extends Control
## Interfaz: elección de inicial, barras de vida/energía/EXP, ataques con recarga, equipo y mensajes.

const KEY_LABELS := ["1 / Clic", "2 / Clic der.", "3", "4"]
const KIND_LABELS := {"projectile": "Disparo", "dash": "Embestida", "area": "Área", "shield": "Defensa"}

var main: Node2D
var font: Font


func _ready() -> void:
	font = ThemeDB.fallback_font
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	size = Vector2(1280, 720)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if main.choosing:
		_draw_choose()
		return
	_draw_message()
	_draw_wild_panel()
	_draw_player_panel()
	_draw_moves()
	_draw_party()


func _draw_choose() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color(0, 0, 0, 0.65))
	draw_string(font, Vector2(0, 170), "Elegí tu criatura inicial", HORIZONTAL_ALIGNMENT_CENTER, 1280, 40)
	draw_string(font, Vector2(0, 215), "Presioná 1, 2 o 3", HORIZONTAL_ALIGNMENT_CENTER, 1280, 20, Color(1, 1, 1, 0.7))
	for i in 3:
		var sp: String = Game.STARTERS[i]
		var data: Dictionary = Game.SPECIES[sp]
		var col: Color = Game.TYPE_COLORS[data["type"]]
		var r := Rect2(640 - 110 + (i - 1) * 260, 270, 220, 240)
		_panel(r)
		draw_rect(Rect2(r.position, Vector2(r.size.x, 6)), col)
		_portrait(sp, r.position + Vector2(110, 85), 100)
		draw_string(font, r.position + Vector2(0, 160), sp, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 24)
		draw_string(font, r.position + Vector2(0, 188), data["type"].to_upper(), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 15, col)
		draw_string(font, r.position + Vector2(0, 225), "[%d]" % (i + 1), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 20, Color(1, 1, 1, 0.8))
	draw_string(font, Vector2(0, 590), "Fuego > Planta > Agua > Fuego  ·  Hay 12 Pokémon salvajes para atrapar", HORIZONTAL_ALIGNMENT_CENTER, 1280, 16, Color(1, 1, 1, 0.6))


func _draw_message() -> void:
	var hint := "WASD mover · Mouse apuntar · 1-4 / Clic ataques · Espacio esquivar · E Poké Ball · Tab cambiar"
	draw_string(font, Vector2(20, 76), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1, 0.55))
	if main.message_time <= 0.0:
		return
	var a := clampf(main.message_time, 0.0, 1.0)
	var r := Rect2(16, 12, 820, 40)
	draw_rect(r, Color(0.05, 0.07, 0.1, 0.85 * a))
	draw_string(font, r.position + Vector2(14, 27), main.message, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 20, 17, Color(1, 1, 1, a))


func _draw_wild_panel() -> void:
	var w = main.wild
	if w == null or not is_instance_valid(w):
		return
	var r := Rect2(860, 12, 404, 64)
	_panel(r)
	var col: Color = Game.TYPE_COLORS[w.species["type"]]
	_portrait(w.species_name, r.position + Vector2(28, 32), 44)
	_text(r.position + Vector2(54, 26), "%s salvaje  Nv. %d" % [w.species_name, w.level], 17)
	_text(r.position + Vector2(330, 26), w.species["type"].to_upper(), 12, col)
	_bar(Rect2(r.position + Vector2(54, 36), Vector2(334, 12)), w.hp / w.max_hp, _hp_color(w.hp / w.max_hp))


func _draw_player_panel() -> void:
	var p = main.player
	if p == null or not is_instance_valid(p):
		return
	var r := Rect2(16, 622, 400, 88)
	_panel(r)
	var col: Color = Game.TYPE_COLORS[p.species["type"]]
	_portrait(p.species_name, r.position + Vector2(28, 26), 38)
	_text(r.position + Vector2(54, 24), "%s  Nv. %d" % [p.species_name, p.level], 18)
	_text(r.position + Vector2(330, 24), p.species["type"].to_upper(), 12, col)
	var ratio: float = p.hp / p.max_hp
	_bar(Rect2(r.position + Vector2(54, 32), Vector2(334, 14)), ratio, _hp_color(ratio))
	_text(r.position + Vector2(58, 44), "PS %d/%d" % [ceili(p.hp), ceili(p.max_hp)], 11)
	_bar(Rect2(r.position + Vector2(54, 52), Vector2(334, 8)), p.energy / p.MAX_ENERGY, Color(0.95, 0.85, 0.3))
	var entry: Dictionary = p.data
	_bar(Rect2(r.position + Vector2(54, 66), Vector2(334, 5)), float(entry["xp"]) / Game.xp_to_next(entry["level"]), Color(0.4, 0.7, 1.0))
	_text(r.position + Vector2(24, 60), "EN", 10, Color(0.95, 0.85, 0.3))
	_text(r.position + Vector2(20, 72), "EXP", 10, Color(0.4, 0.7, 1.0))


func _draw_moves() -> void:
	var p = main.player
	if p == null or not is_instance_valid(p):
		return
	for i in p.moves.size():
		var id: String = p.moves[i]
		var m: Dictionary = Game.MOVES[id]
		var r := Rect2(432 + i * 118, 622, 110, 88)
		_panel(r)
		var col: Color = Game.TYPE_COLORS[m["type"]]
		draw_rect(Rect2(r.position, Vector2(r.size.x, 5)), col)
		_text(r.position + Vector2(8, 24), KEY_LABELS[i], 12, Color(1, 1, 1, 0.6))
		_text(r.position + Vector2(8, 48), m["name"], 15)
		_text(r.position + Vector2(8, 72), "%s · %d EN" % [KIND_LABELS[m["kind"]], int(m["energy"])], 11, Color(1, 1, 1, 0.6))
		var cd: float = p.cooldowns[id]
		if cd > 0.0:
			var k: float = cd / m["cooldown"]
			draw_rect(Rect2(r.position.x, r.end.y - r.size.y * k, r.size.x, r.size.y * k), Color(0, 0, 0, 0.55))
			draw_string(font, r.position + Vector2(0, 24), "%.1f" % cd, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 8, 14)
		elif p.energy < m["energy"]:
			draw_rect(r, Color(0, 0, 0, 0.45))


func _draw_party() -> void:
	var r := Rect2(908, 622, 356, 88)
	_panel(r)
	_text(r.position + Vector2(12, 22), "Equipo", 14)
	_text(r.position + Vector2(250, 22), "Poké Balls: %d" % Game.balls, 14, Color(1, 0.6, 0.6))
	for i in Game.party.size():
		var e: Dictionary = Game.party[i]
		var c := r.position + Vector2(32 + i * 54, 54)
		var hp_ratio: float = e["hp"] / Game.max_hp_of(e)
		_portrait(e["species"], c, 36, hp_ratio <= 0.0)
		if i == Game.active:
			draw_rect(Rect2(c - Vector2(20, 20), Vector2(40, 40)), Color.WHITE, false, 2.0)
		_bar(Rect2(c + Vector2(-18, 22), Vector2(36, 4)), hp_ratio, _hp_color(hp_ratio))
		draw_string(font, c + Vector2(-18, 17), str(e["level"]), HORIZONTAL_ALIGNMENT_RIGHT, 36, 11)


func _portrait(species_name: String, center: Vector2, sz: float, dim: bool = false) -> void:
	var r := Rect2(center - Vector2(sz, sz) / 2.0, Vector2(sz, sz))
	var tex := Game.portrait_of(species_name)
	if tex == null:
		draw_circle(center, sz / 2.0, Game.TYPE_COLORS[Game.SPECIES[species_name]["type"]])
		return
	draw_texture_rect(tex, r, false, Color(0.3, 0.3, 0.3) if dim else Color.WHITE)
	draw_rect(r, Color(1, 1, 1, 0.25), false, 1.0)


func _panel(r: Rect2) -> void:
	draw_rect(r, Color(0.06, 0.08, 0.11, 0.88))
	draw_rect(r, Color(1, 1, 1, 0.12), false, 1.5)


func _bar(r: Rect2, ratio: float, col: Color) -> void:
	draw_rect(r, Color(0, 0, 0, 0.6))
	draw_rect(Rect2(r.position, Vector2(r.size.x * clampf(ratio, 0.0, 1.0), r.size.y)), col)


func _hp_color(ratio: float) -> Color:
	if ratio > 0.5:
		return Color(0.3, 0.85, 0.35)
	if ratio > 0.2:
		return Color(0.95, 0.8, 0.2)
	return Color(0.92, 0.25, 0.2)


func _text(pos: Vector2, s: String, font_size: int = 16, col: Color = Color.WHITE) -> void:
	draw_string(font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)
