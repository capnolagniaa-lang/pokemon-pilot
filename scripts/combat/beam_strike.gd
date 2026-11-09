class_name BeamStrike
extends Hitbox
## Rayo instantáneo (Rayo Solar): después de la carga sale de una vez todo el largo (`MoveData.beam_length`, cortado en
## la primera pared o roca) y golpea a todos los que estén en la línea, una vez. Queda un instante a la vista y se apaga.
## Lo usa un ataque PROJECTILE con `beam_length` > 0 (para la IA, el HUD y el online sigue siendo un disparo).

const HIT_TIME := 0.07  ## cuánto mira quién está adentro (un par de cuadros de física)
const SHOW_TIME := 0.38  ## cuánto se ve el rayo
const LIGHT_TEX := preload("res://art/fx/soft_shadow.tres")
const BEAM_PX := 11.0  ## alto del haz en la hoja `<id>_rayo` (cuadro de 64)

var direction := Vector2.RIGHT
var length := 160.0
var width := 10.0
var _time := 0.0
var _color := Color.WHITE
var _core := Color.WHITE
var _body: VfxSprite


func fire(p_hit: HitInfo, from: Vector2, dir: Vector2) -> void:
	setup(p_hit, false)
	var m := p_hit.move
	global_position = from
	direction = dir.normalized()
	rotation = direction.angle()
	width = m.size * 2.0
	length = reach_from(self, from, direction, m.beam_length * p_hit.area_mult)
	_color = m.element.hdr(m.element.color, 1.3)
	_core = m.element.hdr(m.element.core_color, 1.6)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(length, width)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(length / 2.0, 0.0)
	add_child(col)
	var light := PointLight2D.new()
	light.texture = LIGHT_TEX
	light.color = m.element.color
	light.energy = 0.35
	light.texture_scale = length / 40.0
	light.position = Vector2(length * 0.5, 0)
	add_child(light)
	z_index = 4
	NightLight.apply(self)
	# Hojas de Qwen si están (`<id>_rayo` estirada al largo, `<id>_impacto` donde termina); si no, se dibuja por código.
	var sheet := DB.vfx_part(m, "rayo")
	if sheet != null:
		var tex := sheet.get_frame_texture("default", 0)
		_body = VfxSprite.attach(self, sheet)
		_body.centered = false
		_body.offset = Vector2(0, -tex.get_height() / 2.0)
		_body.scale = Vector2(length / tex.get_width(), width / BEAM_PX)
	var boom := DB.vfx_part(m, "impacto")
	if boom != null:
		VfxSprite.burst(get_parent(), boom, from + direction * length, rotation, width * 4.0)
	Events.element_impact.emit(m.element, from + direction * length, width)


## Hasta dónde llega un rayo de `max_len` desde `from`: la primera pared o roca lo corta.
static func reach_from(node: Node2D, from: Vector2, dir: Vector2, max_len: float) -> float:
	var q := PhysicsRayQueryParameters2D.create(from, from + dir * max_len, CombatBody.SHOT_MASK)
	var r := node.get_world_2d().direct_space_state.intersect_ray(q)
	return from.distance_to(r["position"]) if not r.is_empty() else max_len


func _on_area_entered(area: Area2D) -> void:
	if hit != null:
		hit.origin = global_position
	super._on_area_entered(area)


func _physics_process(delta: float) -> void:
	_time += delta
	if _time > HIT_TIME and monitoring:
		set_deferred("monitoring", false)
	if _time >= SHOW_TIME:
		queue_free()
	if _body != null:
		var k := clampf(_time / SHOW_TIME, 0.0, 1.0)
		_body.modulate.a = 1.0 - k * k
		_body.scale.y = width / BEAM_PX * lerpf(1.1, 0.4, k)
	queue_redraw()


func _draw() -> void:
	if _body != null:
		return
	var k := clampf(_time / SHOW_TIME, 0.0, 1.0)
	var fade := 1.0 - k * k
	var w := width * (1.0 + 0.4 * sin(_time * 60.0) * (1.0 - k)) * lerpf(1.15, 0.35, k)
	var glow := Color(_color.r, _color.g, _color.b, 0.35 * fade)
	draw_rect(Rect2(0, -w, length, w * 2.0), glow)
	draw_rect(Rect2(0, -w / 2.0, length, w), Color(_color.r, _color.g, _color.b, 0.9 * fade))
	draw_rect(Rect2(0, -w / 5.0, length, w / 2.5), Color(_core.r, _core.g, _core.b, fade))
	draw_circle(Vector2.ZERO, w * 0.9, Color(_core.r, _core.g, _core.b, fade))
	draw_circle(Vector2(length, 0), w * 0.7 * (1.0 + k), Color(_color.r, _color.g, _color.b, 0.7 * fade))
	# Destellos que corren a lo largo del rayo.
	for i in 6:
		var x := fmod(_time * 900.0 + i * length / 6.0, length)
		draw_circle(Vector2(x, sin(i * 2.1 + _time * 40.0) * w * 0.3), w * 0.22, Color(1, 1, 0.9, 0.8 * fade))
