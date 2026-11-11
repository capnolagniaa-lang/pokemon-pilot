class_name RoguePortal
extends Node2D
## El portal del castillo de Mew (Modo Desafío, RogueRun): un remolino pintado con Qwen (sprites/props/portal_mew.png)
## que gira y late acostado sobre la tarima redonda de abajo. Es solo el dibujo: RogueRun mira si llegaste.

const TEXTURE := "res://sprites/props/portal_mew.png"
## Tamaño en pantalla (px del juego): entra en la tarima de la pintura.
const SIZE := 84.0
## Acostado en el piso (la sala se ve desde arriba en 3/4).
const FLAT := 0.58

## Apagado (todavía no elegiste Pokémon): más chico y oscuro.
var lit := false
var _time := 0.0
var _swirl: Sprite2D
var _glow: Sprite2D


func _ready() -> void:
	z_index = -5  # sobre el piso pintado, debajo de personas y Pokémon
	NightLight.apply(self)
	var tex: Texture2D = load(TEXTURE)
	_glow = _layer(tex, true)
	_swirl = _layer(tex, false)


func _layer(tex: Texture2D, additive: bool) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	s.scale = Vector2.ONE * SIZE / float(tex.get_width())
	if additive:
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		s.material = m
	var tilt := Node2D.new()  # (el giro va adentro, el aplastado afuera: gira como un disco acostado)
	tilt.scale = Vector2(1.0, FLAT)
	add_child(tilt)
	tilt.add_child(s)
	return s


func _process(delta: float) -> void:
	_time += delta
	var k := 0.5 + 0.5 * sin(_time * 3.0)
	var base := SIZE / float(_swirl.texture.get_width()) * (1.0 if lit else 0.8)
	_swirl.rotation = -_time * (1.6 if lit else 0.5)
	_swirl.scale = Vector2.ONE * base * (1.0 + 0.04 * k)
	_swirl.modulate = Color(1, 1, 1, 1) if lit else Color(0.45, 0.4, 0.6, 0.85)
	_glow.rotation = _time * 0.9
	_glow.scale = Vector2.ONE * base * (1.25 + 0.1 * k)
	_glow.modulate = Color(1, 1, 1, (0.35 + 0.25 * k) if lit else 0.08)
