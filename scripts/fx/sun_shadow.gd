class_name SunShadow
extends Node2D
## Sombra larga de un personaje o Pokémon según el sol (docs/PLAN_DIA_NOCHE.md parte B): su mismo cuadro, oscuro,
## acostado en el suelo hacia el lado contrario al sol (dirección, largo y opacidad de DayNight). Va como hermano
## del sprite (`source`: un Sprite2D, o un CreatureSprite con su `_current()`), con los pies en el origen.

## Cuánto se acuesta: la cabeza de un sprite de alto h cae a h × FLATTEN × largo del sol.
const FLATTEN := 0.42
## Suavizado: la sombra se dibuja varias veces corrida de a SOFT_STEP px (más borrosa cuanto más larga).
const SOFT_TAPS := 5
const SOFT_STEP := 2.0
const Z := -6  # sobre el suelo y las sombras del mapa (-7), debajo de los personajes

var source: Node2D
## Sombra suave (varios dibujos corridos): para los objetos grandes del terreno propio (StyleOverlay).
var soft := false
## Modo "desplazada" (objetos con volumen: casas, árboles): en vez de acostar el cuadro, la silueta se corre hacia
## donde caen las sombras según la altura del objeto (como en los juegos HD-2D), un poco inclinada.
var offset_mode := false
## Cuánto se acuesta este sprite (FLATTEN por defecto; los objetos del terreno propio, más largo).
var flatten_k := FLATTEN
## Cuánto se corre: fracción del alto del sprite por unidad de largo de sombra.
const OFFSET_K := 0.3
const OFFSET_FLATTEN := 0.12
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
	var flatten := OFFSET_FLATTEN if offset_mode else flatten_k
	var lean := -dn.shadow_direction * flatten * dn.shadow_length
	var shift := Vector2.ZERO
	if offset_mode:
		shift = dn.shadow_direction * absf(dst.size.y) * OFFSET_K * dn.shadow_length
	var taps := SOFT_TAPS if soft else 1
	var side := Vector2(-dn.shadow_direction.y, dn.shadow_direction.x)
	var spread := SOFT_STEP * dn.shadow_length
	if OS.get_cmdline_user_args().has("--no-sun-shadow"):
		return
	if soft and OS.get_cmdline_user_args().has("--shadow-debug") and Engine.get_frames_drawn() == 30:
		print("[shdbg] src=", source.name, " tex=", frame[0], " dst=", dst, " lean=", lean, " vis=", is_visible_in_tree(),
			" gpos=", global_position, " z=", z_index, " zrel=", z_as_relative, " parent=", get_parent().name,
			" alpha=", dn.shadow_alpha, " srcrect=", frame[1])
	if OS.get_cmdline_user_args().has("--shadow-debug"):  # dónde cae cada sombra: roja y opaca
		draw_set_transform_matrix(Transform2D(Vector2(1, 0), Vector2(0, 1) + lean if offset_mode else lean, shift))
		draw_texture_rect_region(frame[0], dst, frame[1], Color(1, 0, 0, 0.9))
		return
	for i in taps:
		var k := (i - (taps - 1) / 2.0) * spread
		var y_axis := Vector2(0, 1) + lean if offset_mode else lean  # acostada: el eje Y entero cae sobre lean
		draw_set_transform_matrix(Transform2D(Vector2(1, 0), y_axis, shift + side * k))
		draw_texture_rect_region(frame[0], dst, frame[1], Color(dn.shadow_color, dn.shadow_alpha * (1.0 if soft else 0.75) / taps))


## [textura, rect de origen, rect de destino (local al sprite)] del cuadro actual, o [].
func _frame() -> Array:
	if source.has_method("_current"):
		return source._current()
	var spr := source as Sprite2D
	if spr == null or spr.texture == null:
		return []
	var tex: Texture2D = spr.texture
	if tex is CanvasTexture:  # con mapa de relieve (terreno propio HD): la sombra usa el dibujo liso, si no sale clara
		tex = (tex as CanvasTexture).diffuse_texture
	var src := spr.region_rect if spr.region_enabled else Rect2(Vector2.ZERO, tex.get_size())
	var fs := src.size / Vector2(spr.hframes, spr.vframes)
	src = Rect2(src.position + fs * Vector2(spr.frame_coords), fs)
	var dst := spr.get_rect()
	dst = Rect2(dst.position * spr.scale, dst.size * spr.scale)  # sprites achicados (paquetes HD del terreno propio)
	if spr.flip_h:
		dst = Rect2(dst.position + Vector2(dst.size.x, 0), Vector2(-dst.size.x, dst.size.y))
	return [tex, src, dst]
