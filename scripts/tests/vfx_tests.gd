class_name VfxTests
extends Node
## Autotest de los efectos de ataque con sprite (MoveData/ElementType.vfx, hojas en sprites/fx/, VfxSprite):
##   godot --headless --path . --quit-after 20000 -- --autotest-vfx
## Vitrina (cámara de cerca: el impacto de cada tipo y los proyectiles con hoja de tools/make_vfx.py):
##   godot --path . --quit-after 500 --write-movie out/f.png --fixed-fps 30 -- --showcase-vfx
## Hojas de prueba hechas acá (no hay arte de efectos todavía): que se corten bien, el orden de prioridad, y que
## proyectil, área, golpe e impacto las muestren (rotadas hacia donde va el ataque) y se borren solas.

var autotest: Node


func run() -> void:
	var r := {}
	var img := Image.create(64, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 0.4, 0.1))
	img.save_png("user://vfx_prueba.png")
	var sheet := DB.vfx_sheet("user://vfx_prueba.png")
	r["Hoja de 64×16 → 4 cuadros de 16×16"] = sheet != null and sheet.get_frame_count("default") == 4 \
		and sheet.get_frame_texture("default", 3).get_size() == Vector2(16, 16)
	r["Hoja que no existe → null (se dibuja por código)"] = DB.vfx_sheet("res://sprites/fx/moves/no_existe.png") == null

	var world: Node = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	var base: MoveData = null
	for m: MoveData in me.moves.slots:
		if m.kind == MoveData.Kind.PROJECTILE:
			base = m
	var bare := base.duplicate() as MoveData  # ataque y tipo sin hojas: se dibuja por código
	bare.id = "sin_hoja"
	bare.display_name = "Sin hoja"
	bare.element = base.element.duplicate()
	bare.element.id = "sin_tipo"
	r["Sin hoja ni SpriteFrames: no tiene efecto con sprite"] = DB.vfx_for(bare) == null and DB.vfx_for(bare, true) == null
	r["Hojas de tools/make_vfx.py: Ascuas y el impacto de Fuego"] = DB.vfx_for(DB.moves["ascuas"]) != null and DB.vfx_for(DB.moves["ascuas"], true) != null and DB.vfx_for(DB.moves["ascuas"], true).get_frame_count("default") == 7
	r["%s (%s, del kit) usa la hoja de ascuas.png" % [base.display_name, base.id]] = DB.vfx_for(base) == DB.vfx_for(DB.moves["ascuas"])

	var body := DB.vfx_sheet("user://vfx_prueba.png")
	var hit_fx := _frames(3)
	var m := base.duplicate() as MoveData
	m.id = "prueba_vfx"
	m.vfx = body
	var el := m.element.duplicate() as ElementType
	el.impact_vfx = hit_fx
	m.element = el
	r["Prioridad: el del ataque, si no el del tipo"] = DB.vfx_for(m) == body and DB.vfx_for(m, true) == hit_fx

	var dummy: Creature = autotest._dummy(world, "bulbasaur", me.global_position + Vector2(60, 0))
	await get_tree().physics_frame
	var parent: Node = me.get_parent()
	var p := Projectile.new()
	parent.add_child(p)
	p.launch(HitInfo.from(me, m), me.global_position + Vector2(0, 40), Vector2.DOWN)
	var spr := _vfx_in(p)
	r["Proyectil con sprite, rotado hacia donde va"] = spr.size() == 1 and absf(spr[0].rotation - PI / 2.0) < 0.01 \
		and spr[0].is_playing()
	var plain := Projectile.new()
	parent.add_child(plain)
	plain.launch(HitInfo.from(me, bare), me.global_position + Vector2(0, -40), Vector2.UP)
	r["Proyectil sin hoja: igual que antes (sin sprite)"] = _vfx_in(plain).is_empty()

	var before := _vfx_in(parent).size()
	var area_move := m.duplicate() as MoveData
	area_move.kind = MoveData.Kind.AREA
	var a := AreaEffect.new()
	parent.add_child(a)
	a.trigger(HitInfo.from(me, area_move), me.global_position + Vector2(-80, 0))
	var swing := MeleeSwing.new()
	parent.add_child(swing)
	swing.swing(HitInfo.from(me, m), me.global_position + Vector2(-80, 40), 11.0, Vector2.LEFT)
	var bursts := _vfx_in(parent)
	r["Área y golpe: efecto suelto en el mundo (%d)" % (bursts.size() - before)] = bursts.size() - before == 2 \
		and bursts.any(func(s): return absf(absf(s.rotation) - PI) < 0.01)
	var area_spr: VfxSprite = bursts.filter(func(s): return is_zero_approx(s.rotation))[0]
	r["El área se escala a su radio"] = absf(area_spr.scale.x * 16.0 - area_move.radius * 2.0) < 0.5

	var n := _vfx_in(dummy.get_parent()).size()
	dummy.hurtbox.receive(HitInfo.from(me, m))
	await get_tree().process_frame
	var after := _vfx_in(dummy.get_parent())
	r["Impacto: aparece sobre el golpeado"] = after.size() > n \
		and after.any(func(s): return s.sprite_frames == hit_fx and s.global_position.distance_to(dummy.global_position) < 20.0)

	await get_tree().create_timer(1.2).timeout
	r["Los efectos sueltos se borran solos al terminar"] = _vfx_in(parent).filter(func(s): return s.get_parent() == parent).size() == before

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[vfx] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-vfx] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	var world: Node = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	var dummy: Creature = autotest._dummy(world, "snorlax", me.global_position + Vector2(56, 0))
	var cam: CameraRig = world.camera
	cam.target = null
	cam.global_position = (me.global_position + dummy.global_position) / 2.0
	cam.zoom = Vector2(4, 4)
	await get_tree().physics_frame
	var base: MoveData = me.moves.slots[0]
	for tid in DB.types:
		var m := base.duplicate() as MoveData
		m.element = DB.types[tid]
		m.power = 1.0
		dummy.hurtbox.receive(HitInfo.from(me, m))
		dummy.health.heal(9999.0)
		dummy.statuses.clear()  # que el quemado no lo tiña de naranja para el siguiente
		print("[showcase-vfx] impacto ", tid, " cuadro ", Engine.get_frames_drawn())
		await get_tree().create_timer(0.5).timeout
	# Los 5 de código y los 15 hechos con IA (docs/COMFYUI.md).
	for id in ["ascuas", "impactrueno", "pistola_agua", "burbuja", "hoja_afilada", "lanzallamas", "confusion", "hiperrayo",
			"poder_pasado", "rayo_hielo", "psiquico", "rayo_burbuja", "llamarada", "electrocanon", "dragoaliento",
			"furia_dragon", "acido", "gigadrenado", "pin_misil", "rapidez", "bomba_lodo", "disparo_lodo", "bola_sombra", "hidrobomba", "lanzarrocas", "hoja_magica"]:
		if not DB.moves.has(id):
			continue
		var p := Projectile.new()
		me.get_parent().add_child(p)
		p.launch(HitInfo.from(me, DB.moves[id]), me.global_position + Vector2(0, -8), Vector2.RIGHT)
		dummy.health.heal(9999.0)
		print("[showcase-vfx] proyectil ", id, " cuadro ", Engine.get_frames_drawn())
		await get_tree().create_timer(0.7).timeout
	for id in ["trueno", "giro_fuego", "surf"]:  # áreas con hoja hecha con IA (docs/COMFYUI.md)
		if not DB.moves.has(id):
			continue
		var a := AreaEffect.new()
		me.get_parent().add_child(a)
		a.trigger(HitInfo.from(me, DB.moves[id]), dummy.global_position + Vector2(0, -6))
		dummy.health.heal(9999.0)
		print("[showcase-vfx] área ", id, " cuadro ", Engine.get_frames_drawn())
		await get_tree().create_timer(1.0).timeout
	get_tree().quit()


func _frames(n: int) -> SpriteFrames:
	var f := SpriteFrames.new()
	f.set_animation_loop("default", true)
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	for i in n:
		f.add_frame("default", ImageTexture.create_from_image(img))
	return f


func _vfx_in(node: Node) -> Array:
	return node.get_children().filter(func(c): return c is VfxSprite)
