class_name RogueFoeBadge
extends Node2D
## Los íconos de las mejoras de un enemigo del Modo Desafío (RogueFoeMods), flotando sobre su cabeza, arriba de la barra
## de vida. Hijo de la criatura: se va con ella.

const SIZE := 10.0
const HEIGHT := -38.0

var mods: RogueFoeMods
var creature: Creature
var textures: Array[Texture2D] = []
var colors: Array[Color] = []


func setup(p_mods: RogueFoeMods, c: Creature) -> void:
	mods = p_mods
	creature = c
	z_index = 30
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for m: Dictionary in RogueFoeMods.of(c):
		var path: String = m.get("icon", RogueFoeMods.icon_of(m["id"]))  # (un élite de duelo muestra su objeto)
		textures.append(load(path) if ResourceLoader.exists(path) else null)
		colors.append(mods.color_of(m["id"]))


func _process(_delta: float) -> void:
	visible = is_instance_valid(creature) and not creature.is_down()
	queue_redraw()


func _draw() -> void:
	var n := textures.size()
	var bob := sin(Time.get_ticks_msec() / 260.0) * 1.0
	for i in n:
		var at := Vector2((float(i) - float(n - 1) / 2.0) * (SIZE + 2.0) - SIZE / 2.0, HEIGHT + bob)
		draw_rect(Rect2(at - Vector2.ONE, Vector2(SIZE + 2.0, SIZE + 2.0)), Color(0, 0, 0, 0.55))
		draw_rect(Rect2(at - Vector2.ONE, Vector2(SIZE + 2.0, SIZE + 2.0)), Color(colors[i], 0.9), false, 1.0)
		if textures[i] != null:
			draw_texture_rect(textures[i], Rect2(at, Vector2(SIZE, SIZE)), false)
