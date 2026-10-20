class_name CreatureSprite
extends Node2D
## Dibuja una criatura con las hojas de animación PMD (8 direcciones).
## Lee facing y velocity de su padre; otros sistemas pueden forzar animaciones con play_once().

## Las hojas PMD centran el cuerpo en el frame; subimos el dibujo para que los pies queden en el origen.
@export var foot_offset := 8.0

var species: SpeciesData:
	set(value):
		species = value
		_anims = DB.anims_of(value) if value != null else {}

var tint := Color.WHITE

var _anims: Dictionary = {}
var _anim := "Idle"
var _time := 0.0
var _forced := ""
var _forced_left := 0.0


func _process(delta: float) -> void:
	_time += delta
	_forced_left = maxf(0.0, _forced_left - delta)
	var parent := get_parent() as CharacterBody2D
	var want := "Idle"
	if _forced_left > 0.0:
		want = _forced
	elif parent != null and parent.velocity.length() > 5.0:
		want = "Walk"
	if want != _anim and _anims.has(want):
		_anim = want
		_time = 0.0
	queue_redraw()


## Reproduce una animación (Attack, Hurt...) una vez, durante como mucho max_time segundos.
func play_once(anim_name: String, max_time: float = 0.5) -> void:
	if not _anims.has(anim_name):
		return
	_forced = anim_name
	_forced_left = minf(_total(anim_name) / 60.0, max_time)
	_anim = anim_name
	_time = 0.0


func _total(anim_name: String) -> int:
	var total := 0
	for d in _anims[anim_name]["durations"]:
		total += d
	return total


func _frame(durations: Array, loop: bool) -> int:
	var total := 0
	for d in durations:
		total += d
	var t := int(_time * 60.0)
	t = t % total if loop else mini(t, total - 1)
	var acc := 0
	for i in durations.size():
		acc += durations[i]
		if t < acc:
			return i
	return durations.size() - 1


## Fila PMD según la dirección: abajo, abajo-der, der, arriba-der, arriba, arriba-izq, izq, abajo-izq.
func _row(facing: Vector2) -> int:
	return posmod(int(round((PI / 2.0 - facing.angle()) / (PI / 4.0))), 8)


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2.ZERO, 7.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not _anims.has(_anim):
		draw_circle(Vector2(0, -6), 6.0, Color.MAGENTA)
		return
	var anim: Dictionary = _anims[_anim]
	var tex := DB.texture(anim["file"])
	var fw: float = anim["w"]
	var fh: float = anim["h"]
	var facing: Vector2 = get_parent().get("facing") if get_parent() != null else Vector2.DOWN
	var frame := _frame(anim["durations"], _anim == "Idle" or _anim == "Walk")
	var src := Rect2(frame * fw, _row(facing) * fh, fw, fh)
	draw_texture_rect_region(tex, Rect2(-fw / 2.0, -fh / 2.0 - foot_offset, fw, fh), src, tint)
