class_name EvolutionScreen
extends Control
## Pantalla de evolución (la abre EvolutionDirector): "¿Eh? ¡X está evolucionando!", el Pokémon parpadea en blanco
## entre su forma vieja y la nueva cada vez más rápido y aparece la nueva. Si es cancelable (al subir de nivel, no con
## piedras), Esc la frena como el botón B de los juegos. Señal `finished(evolved)`.

signal finished(evolved: bool)

const SHADER := """
shader_type canvas_item;
uniform float white : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	COLOR = vec4(mix(c.rgb, vec3(1.0), white), c.a);
}
"""
## Duraciones (s): aviso, parpadeo y final. `speed` > 1 la acelera (los tests).
const INTRO := 1.1
const MORPH := 3.4
const OUTRO := 2.2

var speed := 1.0
var _from: SpeciesData
var _to: SpeciesData
var _name := ""
var _cancelable := true
var _old: TextureRect
var _new: TextureRect
var _text: Label
var _hint: Label
var _flash: ColorRect
var _cancel := false


func setup(from: SpeciesData, to: SpeciesData, mon_name: String, cancelable: bool) -> void:
	_from = from
	_to = to
	_name = mon_name
	_cancelable = cancelable


func _ready() -> void:
	theme = UiStyle.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.03, 0.06, 0.92)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var mat := ShaderMaterial.new()
	mat.shader = Shader.new()
	mat.shader.code = SHADER
	_old = _sprite(DB.idle_frame_of(_from), mat)
	_new = _sprite(DB.idle_frame_of(_to), mat.duplicate())
	_new.visible = false
	_text = UiStyle.label("", 24)
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.position = Vector2(140, 520)
	_text.size = Vector2(1000, 80)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_text)
	_hint = UiStyle.label("Esc: frenar la evolución" if _cancelable else "", 14, UiStyle.TEXT_DIM)
	_hint.position = Vector2(540, 620)
	add_child(_hint)
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)
	_run.call_deferred()


func _sprite(tex: Texture2D, mat: ShaderMaterial) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.material = mat
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.size = Vector2(320, 320)
	r.position = Vector2(480, 150)
	add_child(r)
	return r


func _input(event: InputEvent) -> void:
	if _cancelable and event.is_action_pressed("ui_cancel"):
		_cancel = true
		get_viewport().set_input_as_handled()


func cancel() -> void:
	if _cancelable:
		_cancel = true


func _wait(t: float) -> void:
	await get_tree().create_timer(t / speed).timeout


func _white(rect: TextureRect, k: float) -> void:
	(rect.material as ShaderMaterial).set_shader_parameter("white", k)


func _run() -> void:
	_text.text = "¿Eh? ¡%s está evolucionando!" % _name
	await _wait(INTRO)
	# Parpadeo: el blanco sube y la forma alterna cada vez más rápido.
	var t := 0.0
	var toggle := 0.0
	var period := 0.45
	while t < MORPH:
		if _cancel:
			_old.visible = true
			_new.visible = false
			_white(_old, 0.0)
			_hint.text = ""
			_text.text = "¿Eh? ¡%s dejó de evolucionar!" % _name
			await _wait(1.4)
			finished.emit(false)
			return
		var dt := get_process_delta_time() * speed
		t += dt
		toggle += dt
		var k := clampf(t / 0.8, 0.0, 1.0)
		_white(_old, k)
		_white(_new, k)
		if toggle >= period:
			toggle = 0.0
			period = maxf(0.05, period * 0.8)
			_old.visible = not _old.visible
			_new.visible = not _old.visible
		await get_tree().process_frame
	# Destello y la forma nueva.
	_hint.text = ""
	_old.visible = false
	_new.visible = true
	_flash.color.a = 1.0
	var tw := create_tween()
	tw.tween_property(_flash, "color:a", 0.0, 0.6 / speed)
	tw.parallel().tween_method(func(k): _white(_new, k), 1.0, 0.0, 0.9 / speed)
	_text.text = "¡Felicitaciones! ¡Tu %s evolucionó en %s!" % [_name, _to.display_name]
	await _wait(OUTRO)
	finished.emit(true)
