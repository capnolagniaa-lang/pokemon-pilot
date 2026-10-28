class_name SunShadow
extends Node2D
## Sombra larga de un personaje o Pokémon según el sol (docs/PLAN_DIA_NOCHE.md parte B): su mismo cuadro, oscuro,
## acostado en el suelo hacia el lado contrario al sol (dirección, largo y opacidad de DayNight). Va como hermano
## del sprite (`source`: un Sprite2D, o un CreatureSprite con su `_current()`), con los pies en el origen.

## Cuánto se acuesta: la cabeza de un sprite de alto h cae a h × FLATTEN × largo del sol.
const FLATTEN := 0.42
const Z := -6  # sobre el suelo y las sombras del mapa (-7), debajo de los personajes

var source: Node2D
var _world: Node


static func attach_to(source: Node2D) -> SunShadow:
	var s := SunShadow.new()
	s.name = "SunShadow"
	s.source = source
	s.z_index = Z
	source.get_parent().add_child.call_deferred(s)
	return s


func _ready() -> void:
	_world = get_tree().get_first_node_in_group("world")


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var dn: DayNight = _world.get("day_night") if _world != null else null
	if dn == null or not dn.casts_shadows or dn.shadow_alpha <= 0.0 or source == null or not source.is_visible_in_tree():
		return
	var frame := _frame()
	if frame.is_empty():
		return
	var dst: Rect2 = frame[2]
	dst.position += source.position - position
	var lean := -dn.shadow_direction * FLATTEN * dn.shadow_length
	draw_set_transform_matrix(Transform2D(Vector2(1, 0), lean, Vector2.ZERO))
	draw_texture_rect_region(frame[0], dst, frame[1], Color(dn.shadow_color, dn.shadow_alpha * 0.75))


## [textura, rect de origen, rect de destino (local al sprite)] del cuadro actual, o [].
func _frame() -> Array:
	if source.has_method("_current"):
		return source._current()
	var spr := source as Sprite2D
	if spr == null or spr.texture == null:
		return []
	var src := spr.region_rect if spr.region_enabled else Rect2(Vector2.ZERO, spr.texture.get_size())
	var fs := src.size / Vector2(spr.hframes, spr.vframes)
	src = Rect2(src.position + fs * Vector2(spr.frame_coords), fs)
	var dst := spr.get_rect()
	if spr.flip_h:
		dst = Rect2(dst.position + Vector2(dst.size.x, 0), Vector2(-dst.size.x, dst.size.y))
	return [spr.texture, src, dst]
