extends Node2D
## Feedback de combate: números de daño, textos de estado, chispas, hitstop y temblor de cámara.
## Solo escucha el bus de eventos.

const HITSTOP_NORMAL := 0.045
const HITSTOP_STRONG := 0.09
## Choque de proyectiles: hojas en grises de Qwen (docs/COMFYUI.md), teñidas con el color de cada ataque.
const CLASH_FLASH := "res://sprites/fx/clash/destello.png"
const CLASH_RING := "res://sprites/fx/clash/anillo.png"
const CLASH_SHADER := preload("res://shaders/clash_tint.gdshader")
const CLASH_SMALL := 40.0
const CLASH_HITSTOP := 0.05

var _base_time_scale := 1.0
var _hitstop_until := 0  # msec (reloj real)
var _slowdown := 1.0  # cámara lenta de la ruleta de Pokémon
## Lo último que se cantó en pantalla (kits del Modo Desafío): el cartelito de una habilidad y el cartel de una definitiva.
var last_callout := ""
var last_banner := ""
var _banner_layer: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Events.creature_damaged.connect(_on_damaged)
	Events.projectiles_clashed.connect(_on_clash)
	Events.status_applied.connect(_on_status)
	Events.interaction_triggered.connect(_on_interaction)
	Events.signature_triggered.connect(func(c, text, col): _float_text(c.global_position + Vector2(-12, -48), text, col, 11))
	Events.creature_fainted.connect(_on_fainted)
	Events.move_used.connect(_on_move_used)
	Events.hitstop.connect(_hitstop)
	Events.env_reaction.connect(func(at, text): _float_text(at + Vector2(-14, -26), text, Color(0.95, 0.95, 1.0), 10))


func _process(_delta: float) -> void:
	# Se mide con el reloj real (el delta está escalado por el propio hitstop).
	if _hitstop_until > 0 and Time.get_ticks_msec() >= _hitstop_until:
		_hitstop_until = 0
		Engine.time_scale = _base_time_scale


## Cámara lenta (× la velocidad normal; 1 = sacarla). Un hitstop en curso vuelve a la velocidad nueva, no a la de antes.
func set_slowdown(mult: float) -> void:
	var stopped := _hitstop_until > 0
	var base := (_base_time_scale if stopped else Engine.time_scale) / _slowdown * mult
	_slowdown = mult
	if stopped:
		_base_time_scale = base
		Engine.time_scale = base * 0.05
	else:
		Engine.time_scale = base


## Choque de proyectiles: destello (y anillo atrás en los grandes), cada mitad con el color de su ataque.
func _on_clash(parent: Node, at: Vector2, a: ElementType, b: ElementType, axis: Vector2, strong: bool) -> void:
	if not is_instance_valid(parent):
		return
	if strong:
		_clash_sprite(parent, CLASH_RING, at, a, b, axis, 64.0, 4)
	_clash_sprite(parent, CLASH_FLASH, at, a, b, axis, 64.0 if strong else CLASH_SMALL, 5)
	Sound.sfx("golpe", -2.0 if strong else -6.0, 1.25 if strong else 1.5)
	Events.camera_shake.emit(3.0 if strong else 1.0)
	if strong:
		Events.hitstop.emit(CLASH_HITSTOP)


func _clash_sprite(parent: Node, path: String, at: Vector2, a: ElementType, b: ElementType, axis: Vector2, size: float, z: int) -> void:
	var frames: SpriteFrames = DB.vfx_sheet(path)
	if frames == null:
		Fx.burst(parent, at, a.color, 12, 70.0)
		return
	var s: VfxSprite = VfxSprite.burst(parent, frames, at, 0.0, size, z)
	var mat := ShaderMaterial.new()
	mat.shader = CLASH_SHADER
	mat.set_shader_parameter("color_a", Vector3(a.color.r, a.color.g, a.color.b))
	mat.set_shader_parameter("color_b", Vector3(b.color.r, b.color.g, b.color.b))
	mat.set_shader_parameter("axis", axis)
	s.material = mat


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
	var impact := DB.vfx_for(hit.move, true)
	if impact != null:  # efecto de impacto con sprite (llamarada, chispa...)
		VfxSprite.burst(c.get_parent(), impact, c.global_position + Vector2(0, -8))
	if el.glow > 1.0:  # de noche los impactos que brillan (fuego, eléctrico...) iluminan alrededor un instante
		NightLight.flash(c.get_parent(), c.global_position + Vector2(0, -8), el.color, 26.0 if strong_hit(hit) else 18.0)
	var strong := eff > 1.0 or hit.move.knockback >= Creature.STAGGER_KNOCKBACK
	Events.hitstop.emit(HITSTOP_STRONG if strong else HITSTOP_NORMAL)
	Events.camera_shake.emit((4.0 if c.team == Creature.Team.ALLY else 2.0) + (2.0 if strong else 0.0))


## Golpe fuerte (súper eficaz o que tambalea).
func strong_hit(hit: HitInfo) -> bool:
	return hit.effectiveness > 1.0 or hit.move.knockback >= Creature.STAGGER_KNOCKBACK


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


## Kits del Modo Desafío: todo se canta en pantalla (pedido del usuario 2026-11-13, como en Pokémon Arena 2D). Una
## habilidad o la movilidad, con un cartelito sobre el que la tira; la definitiva, con el nombre cruzando la pantalla.
## El básico no (sale dos veces por segundo).
func _on_move_used(user: Node, m: MoveData) -> void:
	var c := user as Creature
	if c == null or m == null or c.moves == null or c.moves.kit == null or c.moves.slots.size() <= MoveUser.ULT_SLOT:
		return
	if m == c.moves.slots[0]:
		return
	var col := m.element.color.lightened(0.35) if m.element != null else Color.WHITE
	if m == c.moves.slots[MoveUser.ULT_SLOT]:
		_ult_banner(m.display_name, col)
		Events.camera_shake.emit(2.5)
		return
	last_callout = m.display_name
	_float_text(c.global_position + Vector2(-14, -46), "¡%s!" % m.display_name, col, 8)


func _ult_banner(text: String, col: Color) -> void:
	last_banner = text
	if is_instance_valid(_banner_layer):
		_banner_layer.queue_free()
	var layer := CanvasLayer.new()
	layer.layer = 9
	add_child(layer)
	_banner_layer = layer
	var flash := ColorRect.new()
	flash.color = Color(col.r, col.g, col.b, 0.22)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(flash)
	var view := get_viewport().get_visible_rect().size
	var l := Label.new()
	l.text = "¡%s!" % text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", maxi(18, int(view.y * 0.085)))
	l.add_theme_color_override("font_color", col.lightened(0.3))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	l.add_theme_constant_override("outline_size", maxi(4, int(view.y * 0.014)))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.size = Vector2(view.x, view.y * 0.14)
	l.position = Vector2(0.0, view.y * 0.2)
	l.pivot_offset = l.size * 0.5
	l.scale = Vector2.ONE * 1.5
	layer.add_child(l)
	var tw := layer.create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "scale", Vector2.ONE, 0.16).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(flash, "color:a", 0.0, 0.35)
	tw.tween_property(l, "modulate:a", 0.0, 0.3).set_delay(0.85)
	tw.chain().tween_callback(layer.queue_free)


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
