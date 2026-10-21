extends Control
## Interfaz dibujada: panel de tu Pokémon (siempre), ataques y rival (en combate), mensajes y ayuda.

const KIND := {MoveData.Kind.PROJECTILE: "Disparo", MoveData.Kind.DASH: "Embestida", MoveData.Kind.AREA: "Área",
	MoveData.Kind.SHIELD: "Defensa", MoveData.Kind.MELEE: "Golpe", MoveData.Kind.ZONE: "Zona", MoveData.Kind.CHANNEL: "Canalizado",
	MoveData.Kind.LUNGE: "Embestida", MoveData.Kind.WHIP: "Látigo", MoveData.Kind.SELF_BUFF: "Defensa"}
const ARCHETYPES := {"bruiser": "Bruiser", "tanque": "Tanque", "control": "Control", "velocista": "Velocista",
	"hostigador": "Hostigador", "desgaste": "Desgaste", "espaciador": "Espaciador", "asesino": "Asesino"}

var font: Font
var _message := ""
var _message_time := 0.0
var _world: Node


func _ready() -> void:
	font = ThemeDB.fallback_font
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	Events.message_requested.connect(func(t: String): _message = t; _message_time = 3.5)


func _process(delta: float) -> void:
	_message_time = maxf(0.0, _message_time - delta)
	if _world == null:
		_world = get_tree().get_first_node_in_group("world")
	queue_redraw()


func _draw() -> void:
	if _world == null:
		return
	var in_battle: bool = _world.combat.in_battle
	var c: Creature = _world.companion
	_draw_party(c, in_battle)
	if is_instance_valid(c) and c.signature != null:
		_draw_signature(c)
	if in_battle and is_instance_valid(c):
		_draw_moves(c)
		_draw_enemy()
	_draw_message()
	var hint := "WASD mover · Mouse apuntar · Clic / Clic der. / Q / R ataques · Espacio esquivar · F volver" if in_battle \
		else "WASD mover · Shift correr · F sacar a tu Pokémon a pelear"
	draw_string(font, Vector2(0, size.y - 14), hint, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 16, 13, Color(1, 1, 1, 0.75))


func _draw_party(c: Creature, in_battle: bool) -> void:
	var inst := GameState.active()
	if inst == null:
		return
	var r := Rect2(16, size.y - 104, 380, 88)
	_panel(r)
	var tex := DB.portrait_of(inst.species)
	if tex:
		draw_texture_rect(tex, Rect2(r.position + Vector2(10, 10), Vector2(52, 52)), false)
	var x := r.position.x + 74
	draw_string(font, Vector2(x, r.position.y + 26), "%s  Nv. %d" % [inst.species.display_name, inst.level], HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	var t := inst.species.primary_type()
	var tag := t.display_name.to_upper()
	if inst.species.kit != null:
		tag = "%s · %s" % [ARCHETYPES.get(inst.species.kit.archetype, inst.species.kit.archetype), tag]
	draw_string(font, Vector2(x, r.position.y + 26), tag, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 84, 12, t.color.lightened(0.2))
	var ratio := clampf(inst.hp / inst.max_hp(), 0.0, 1.0)
	_bar(Rect2(x, r.position.y + 34, 290, 12), ratio, _hp_color(ratio))
	draw_string(font, Vector2(x + 4, r.position.y + 45), "PS %d/%d" % [ceili(inst.hp), ceili(inst.max_hp())], HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
	_bar(Rect2(x, r.position.y + 62, 290, 4), inst.exp_progress(), Color(0.4, 0.7, 1.0))
	if is_instance_valid(c) and not c.statuses.active.is_empty():
		var s: StatusEffect = c.statuses.active.values()[-1]["status"]
		draw_string(font, Vector2(x, r.position.y + 82), s.display_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, s.color)
	elif is_instance_valid(c) and c.is_down() or inst.hp <= 0.0:
		draw_string(font, Vector2(x, r.position.y + 82), "DEBILITADO — se está recuperando", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 0.5, 0.5))


## Barra de la mecánica de firma (ej. Calor), con marcas en sus umbrales y el estado especial.
func _draw_signature(c: Creature) -> void:
	var sig := c.signature
	var r := Rect2(16, size.y - 134, 380, 26)
	_panel(r)
	draw_string(font, r.position + Vector2(10, 18), sig.data.display_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, sig.data.color)
	var bar := Rect2(r.position.x + 74, r.position.y + 8, 210, 10)
	var col := sig.data.color
	var label := sig.state_label()
	if label != "":
		col = Color(col.r * 1.5, col.g * 1.5, col.b * 1.5)  # brilla cuando está activa
	_bar(bar, sig.ratio(), col)
	for th in sig.data.thresholds:
		var x := bar.position.x + bar.size.x * th / sig.data.max_value
		draw_line(Vector2(x, bar.position.y - 2), Vector2(x, bar.end.y + 2), Color(1, 1, 1, 0.7), 1.0)
	draw_string(font, Vector2(bar.end.x + 8, r.position.y + 18), label, HORIZONTAL_ALIGNMENT_LEFT, r.end.x - bar.end.x - 12, 11, col)


func _draw_moves(c: Creature) -> void:
	var slots: Array[MoveData] = c.moves.slots
	for i in slots.size():
		var m: MoveData = slots[i]
		var r := Rect2(412 + i * 112, size.y - 104, 106, 88)
		_panel(r)
		if m == null:
			continue
		draw_rect(Rect2(r.position, Vector2(r.size.x, 5)), m.element.color)
		draw_string(font, r.position + Vector2(6, 22), Controls.SLOT_KEYS[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 0.75))
		draw_string(font, r.position + Vector2(6, 46), m.display_name, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 8, 14 if m.display_name.length() <= 11 else 12)
		var info := "%s · %ss" % [KIND.get(m.kind, ""), _secs(m.cooldown)]
		draw_string(font, r.position + Vector2(6, 68), info, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 8, 10, Color(1, 1, 1, 0.6))
		if m.cast_time > 0.0:  # ícono de carga
			draw_arc(r.position + Vector2(r.size.x - 12, 36), 4.5, -PI / 2.0, PI, 12, Color(1, 1, 1, 0.8), 1.5)
		var cd: float = c.moves.cooldown_ratio(i)
		if cd > 0.0:
			draw_rect(Rect2(r.position.x, r.end.y - r.size.y * cd, r.size.x, r.size.y * cd), Color(0, 0, 0, 0.55))
			draw_string(font, r.position + Vector2(0, 30), _secs(c.moves.cooldowns[i]), HORIZONTAL_ALIGNMENT_RIGHT, r.size.x - 8, 13)
	# Esquive (Espacio)
	var d := Rect2(412 + 4 * 112, size.y - 104, 62, 88)
	_panel(d)
	draw_string(font, d.position + Vector2(0, 30), "Espacio", HORIZONTAL_ALIGNMENT_CENTER, d.size.x, 11, Color(1, 1, 1, 0.75))
	draw_string(font, d.position + Vector2(0, 54), "Esquive", HORIZONTAL_ALIGNMENT_CENTER, d.size.x, 12)
	var dk := c.moves.dodge_cooldown / MoveUser.DODGE_COOLDOWN
	if dk > 0.0:
		draw_rect(Rect2(d.position.x, d.end.y - d.size.y * dk, d.size.x, d.size.y * dk), Color(0, 0, 0, 0.55))


func _secs(t: float) -> String:
	return ("%.1f" % t) if t < 10.0 else str(roundi(t))


func _draw_enemy() -> void:
	var enemies: Array = _world.combat.enemies
	if enemies.is_empty():
		return
	var e: Creature = enemies[0]
	if not is_instance_valid(e):
		return
	var r := Rect2(size.x - 396, 16, 380, 64)
	_panel(r)
	var tex := DB.portrait_of(e.instance.species)
	if tex:
		draw_texture_rect(tex, Rect2(r.position + Vector2(8, 8), Vector2(48, 48)), false)
	var x := r.position.x + 66
	draw_string(font, Vector2(x, r.position.y + 24), "%s salvaje  Nv. %d" % [e.instance.species.display_name, e.instance.level], HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	var ratio := e.health.ratio()
	_bar(Rect2(x, r.position.y + 34, 300, 10), ratio, _hp_color(ratio))
	if not e.statuses.active.is_empty():
		var s: StatusEffect = e.statuses.active.values()[-1]["status"]
		draw_string(font, Vector2(x, r.position.y + 58), s.display_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, s.color)
	if enemies.size() > 1:
		draw_string(font, Vector2(x, r.position.y + 58), "+%d" % (enemies.size() - 1), HORIZONTAL_ALIGNMENT_RIGHT, 300, 12)


func _draw_message() -> void:
	if _message_time <= 0.0:
		return
	var a := clampf(_message_time, 0.0, 1.0)
	var w := minf(760.0, font.get_string_size(_message, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x + 40.0)
	var r := Rect2((size.x - w) / 2.0, 70, w, 38)
	draw_rect(r, Color(0.05, 0.07, 0.1, 0.85 * a))
	draw_string(font, r.position + Vector2(0, 25), _message, HORIZONTAL_ALIGNMENT_CENTER, w, 17, Color(1, 1, 1, a))


func _panel(r: Rect2) -> void:
	draw_rect(r, Color(0.06, 0.08, 0.11, 0.85))
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
