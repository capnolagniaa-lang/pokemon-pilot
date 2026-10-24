class_name VfxTests
extends Node
## Autotest de los efectos de ataque con sprite (MoveData/ElementType.vfx, hojas en sprites/fx/, VfxSprite):
##   godot --headless --path . --quit-after 20000 -- --autotest-vfx
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
	r["Sin hoja ni SpriteFrames: %s no tiene efecto con sprite" % base.display_name] = DB.vfx_for(base) == null \
		and DB.vfx_for(base, true) == null

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
	plain.launch(HitInfo.from(me, base), me.global_position + Vector2(0, -40), Vector2.UP)
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
