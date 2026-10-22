extends Node2D
## Feedback de combate: números de daño, textos de estado, chispas, hitstop y temblor de cámara.
## Solo escucha el bus de eventos.

const HITSTOP_NORMAL := 0.045
const HITSTOP_STRONG := 0.09

var _base_time_scale := 1.0
var _hitstop_until := 0  # msec (reloj real)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Events.creature_damaged.connect(_on_damaged)
	Events.status_applied.connect(_on_status)
	Events.interaction_triggered.connect(_on_interaction)
	Events.signature_triggered.connect(func(c, text, col): _float_text(c.global_position + Vector2(-12, -48), text, col, 11))
	Events.creature_fainted.connect(_on_fainted)
	Events.hitstop.connect(_hitstop)


func _process(_delta: float) -> void:
	# Se mide con el reloj real (el delta está escalado por el propio hitstop).
	if _hitstop_until > 0 and Time.get_ticks_msec() >= _hitstop_until:
		_hitstop_until = 0
		Engine.time_scale = _base_time_scale


func _on_damaged(c: Creature, amount: float, hit: HitInfo) -> void:
	if amount <= 0.0:
		return
	var eff := hit.effectiveness if hit != null else 1.0
	var col := Color.WHITE
	var size := 9
	var text := str(maxi(1, roundi(amount)))
	if hit == null:
		col = c.statuses.tint() if not c.statuses.active.is_empty() else Color(0.8, 0.8, 0.8)
		size = 7
	elif eff > 1.0:
		col = Color(1.8, 1.3, 0.3)
		size = 12
		text += "!"
	elif eff < 1.0:
		col = Color(0.65, 0.65, 0.7)
		size = 7
	_float_text(c.global_position + Vector2(randf_range(-6, 6), -26), text, col, size)
	if hit == null:
		return
	var el := hit.move.element
	Fx.burst(c.get_parent(), c.global_position + Vector2(0, -8), el.hdr(el.color), 8, 70.0)
	var strong := eff > 1.0 or hit.move.knockback >= Creature.STAGGER_KNOCKBACK
	Events.hitstop.emit(HITSTOP_STRONG if strong else HITSTOP_NORMAL)
	Events.camera_shake.emit((4.0 if c.team == Creature.Team.ALLY else 2.0) + (2.0 if strong else 0.0))


func _on_status(c: Creature, s: StatusEffect) -> void:
	var g := s.element.glow if s.element != null else 1.0
	var text := "¡%s!" % s.display_name
	var stacks := c.statuses.stacks(s.id)
	if s.max_stacks > 1 and stacks > 1:
		text = "%s x%d" % [s.display_name, stacks]
	_float_text(c.global_position + Vector2(0, -36), text, Color(s.color.r * g, s.color.g * g, s.color.b * g), 8)


func _on_interaction(c: Creature, it: StatusInteraction) -> void:
	if it.label == "":
		return
	var col := it.element.hdr(it.element.color, 1.2) if it.element != null else Color.WHITE
	_float_text(c.global_position + Vector2(-8, -46), it.label, col, 10)
	Events.camera_shake.emit(3.0)


func _on_fainted(c: Creature) -> void:
	Fx.burst(c.get_parent(), c.global_position + Vector2(0, -8), Color(1.5, 1.5, 1.5), 18, 50.0)
	Events.camera_shake.emit(3.0)


func _hitstop(duration: float) -> void:
	if Engine.get_write_movie_path() != "":
		return  # grabando frames (--write-movie): con el reloj real congelaría casi toda la vitrina
	if _hitstop_until == 0:
		_base_time_scale = Engine.time_scale
	_hitstop_until = maxi(_hitstop_until, Time.get_ticks_msec() + int(duration * 1000.0))
	Engine.time_scale = _base_time_scale * 0.05


func _float_text(at: Vector2, text: String, col: Color, size: int) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 3)
	l.z_index = 60
	l.position = at - Vector2(10, 0)
	l.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(l)
	var tw := l.create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 14.0, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(l, "modulate:a", 0.0, 0.7).set_delay(0.25)
	tw.chain().tween_callback(l.queue_free)
