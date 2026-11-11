class_name RogueRewardDoor
extends Node2D
## Una de las puertas con ícono del Modo Desafío (R-3): con la sala limpia aparecen dos frente al paso de arriba, cada
## una con el ícono de la recompensa que va a dar la sala siguiente. Elegís pisando una con tu Pokémon (lo mira RogueRun).
## El arco y los íconos son pinturas de Qwen (sprites/ui/premios/).

const ARCH := "res://sprites/ui/premios/puerta.png"
const ARCH_SIZE := 44.0
const ICON_SIZE := 22.0

var reward := ""
var text := ""
var icon_path := ""
var _time := 0.0
var _icon: Sprite2D
var _glow: Sprite2D


func _ready() -> void:
	NightLight.apply(self)
	if ResourceLoader.exists(ARCH):
		var arch := Sprite2D.new()
		arch.texture = load(ARCH)
		arch.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		arch.scale = Vector2.ONE * ARCH_SIZE / float(arch.texture.get_width())
		arch.offset = Vector2(0, -float(arch.texture.get_height()) * 0.42)  # (los pies del arco en el origen: y-sort)
		add_child(arch)
	if ResourceLoader.exists(icon_path):
		var tex: Texture2D = load(icon_path)
		_glow = Sprite2D.new()
		_glow.texture = tex
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_glow.material = m
		add_child(_glow)
		_icon = Sprite2D.new()
		_icon.texture = tex
		add_child(_icon)
		for s: Sprite2D in [_glow, _icon]:
			s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			s.scale = Vector2.ONE * ICON_SIZE / float(tex.get_width())
			s.z_index = 30
	var label := UiStyle.label(text, 9, Color(1.0, 0.95, 0.7))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-80, 6)
	label.size = Vector2(160, 12)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 3)
	label.z_index = 30
	add_child(label)


func _process(delta: float) -> void:
	_time += delta
	if _icon == null:
		return
	var k := 0.5 + 0.5 * sin(_time * 3.2)
	var at := Vector2(0, -52.0 - 3.0 * k)
	_icon.position = at
	_glow.position = at
	_glow.scale = _icon.scale * (1.25 + 0.15 * k)
	_glow.modulate = Color(1, 1, 1, 0.25 + 0.25 * k)
