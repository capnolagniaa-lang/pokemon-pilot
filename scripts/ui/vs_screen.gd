class_name VsScreen
extends CanvasLayer
## Pantalla VS antes de las peleas importantes (líderes, Alto Mando, rival, Giovanni; pedido del usuario 2026-10-28).
## TrainerBattle la muestra si hay retrato para ese entrenador: sprites/vs/<gfx>.png (el gfx de su NpcData; así el rival
## usa el mismo en todas sus peleas). El tuyo es sprites/vs/jugador.png. Los retratos son las ilustraciones de batalla
## de FireRed redibujadas con Qwen Edit (art_src/vs/, docs/COMFYUI.md). Dura ~2,5 s; E, Espacio o clic la saltean.

const DIR := "res://sprites/vs/"
const PLAYER := "jugador"
const LEFT_COLOR := Color(0.12, 0.32, 0.85)
const PORTRAIT_H := 420.0
const SHADER := preload("res://shaders/vs_background.gdshader")

signal done

var _skip := false


## ¿Hay retrato VS para ese gfx?
static func has_portrait(gfx: String) -> bool:
	return gfx != "" and ResourceLoader.exists(DIR + gfx + ".png")


## Muestra la pantalla y vuelve cuando termina (o la salteás). `color` = el del rival (tipo de su primer Pokémon).
static func play(parent: Node, gfx: String, foe_name: String, title: String, color: Color) -> void:
	var vs := VsScreen.new()
	parent.add_child(vs)
	await vs._run(gfx, foe_name, title, color)
	vs.queue_free()


func _run(gfx: String, foe_name: String, title: String, color: Color) -> void:
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	var size := Vector2(1280, 720)
	var bg := ColorRect.new()
	bg.size = size
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("left_color", Vector3(LEFT_COLOR.r, LEFT_COLOR.g, LEFT_COLOR.b))
	mat.set_shader_parameter("right_color", Vector3(color.r, color.g, color.b))
	mat.set_shader_parameter("reveal", 0.0)
	bg.material = mat
	add_child(bg)
	var me := _portrait(PLAYER, false)
	var foe := _portrait(gfx, true)
	var my_name := _name_label(SaveManager.current_name, "", false)
	var foe_label := _name_label(foe_name, title, true)
	var vs_text := UiStyle.label("VS", 150, Color(1, 0.92, 0.35))
	vs_text.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.0))
	vs_text.add_theme_constant_override("outline_size", 24)
	vs_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs_text.size = Vector2(400, 200)
	vs_text.position = size / 2.0 - vs_text.size / 2.0
	vs_text.pivot_offset = vs_text.size / 2.0
	vs_text.scale = Vector2(3, 3)
	vs_text.modulate.a = 0.0
	add_child(vs_text)
	var flash := ColorRect.new()
	flash.size = size
	flash.color = Color(1, 1, 1, 0)
	add_child(flash)
	# Entrada: el fondo aparece y los retratos entran desde los costados.
	var tw := create_tween().set_parallel()
	tw.tween_method(func(v: float): mat.set_shader_parameter("reveal", v), 0.0, 1.0, 0.25)
	if me:
		var to := me.position
		me.position.x -= 700
		tw.tween_property(me, "position", to, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if foe:
		var to2 := foe.position
		foe.position.x += 700
		tw.tween_property(foe, "position", to2, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for l in [my_name, foe_label]:
		l.modulate.a = 0.0
		tw.tween_property(l, "modulate:a", 1.0, 0.3).set_delay(0.35)
	await _wait(0.45)
	# Golpe del VS: aparece grande, cae, destello y temblor.
	var hit := create_tween().set_parallel()
	hit.tween_property(vs_text, "modulate:a", 1.0, 0.08)
	hit.tween_property(vs_text, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await _wait(0.18)
	flash.color.a = 0.8
	create_tween().tween_property(flash, "color:a", 0.0, 0.3)
	Events.camera_shake.emit(8.0)
	_shake(vs_text)
	await _wait(1.6)
	# Salida.
	var out := create_tween().set_parallel()
	out.tween_method(func(v: float): mat.set_shader_parameter("reveal", v), 1.0, 0.0, 0.25)
	for n in [me, foe, vs_text, my_name, foe_label]:
		if n:
			out.tween_property(n, "modulate:a", 0.0, 0.2)
	await out.finished


func _portrait(gfx: String, right: bool) -> TextureRect:
	if not has_portrait(gfx):
		return null
	var tex: Texture2D = load(DIR + gfx + ".png")
	var r := TextureRect.new()
	r.texture = tex
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	var w := PORTRAIT_H * tex.get_width() / tex.get_height()
	r.size = Vector2(w, PORTRAIT_H)
	r.position = Vector2(1280 - 140 - w if right else 140, 720 - PORTRAIT_H - 90)
	r.flip_h = not right  # las ilustraciones de FireRed miran a la izquierda: la tuya se da vuelta y se miran
	add_child(r)
	return r


## Nombre grande abajo y, arriba de él, el título chico ("Líder", "Rival"...).
func _name_label(text: String, title: String, right: bool) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", -4)
	box.size = Vector2(520, 96)
	box.position = Vector2(1280 - 60 - 520 if right else 60, 720 - 112)
	box.alignment = BoxContainer.ALIGNMENT_END
	for part in [[title, 22, UiStyle.ACCENT], [text, 40, Color.WHITE]]:
		if part[0] == "":
			continue
		var l := UiStyle.label(part[0], part[1], part[2])
		l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		l.add_theme_constant_override("outline_size", 10)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if right else HORIZONTAL_ALIGNMENT_LEFT
		box.add_child(l)
	add_child(box)
	return box


func _shake(n: Control) -> void:
	var base := n.position
	var tw := create_tween()
	for i in 6:
		tw.tween_property(n, "position", base + Vector2(randf_range(-10, 10), randf_range(-10, 10)), 0.03)
	tw.tween_property(n, "position", base, 0.03)


## Espera, pero E / Espacio / clic la saltean.
func _wait(t: float) -> void:
	var left := t
	while left > 0.0 and not _skip:
		await get_tree().process_frame
		left -= get_process_delta_time()
		if Input.is_action_just_pressed("capture") or Input.is_action_just_pressed("dodge") \
				or Input.is_action_just_pressed("ui_accept"):
			_skip = true
