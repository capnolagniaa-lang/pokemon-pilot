class_name StampTests
extends Node
## Sellos del editor de mapas (edificios y piezas del mundo de FireRed):
##   godot --headless --path . --quit-after 20000 -- --autotest-stamps
##   godot --path . --write-movie out/f.png --fixed-fps 30 -- --showcase-stamps   (todos pegados en grilla)
## La coincidencia con los mapas reales y la referencia la verifica python tools/match_reference.py . --check.

const STAMPS_JSON := "res://data/world/stamps.json"
const ROW_W := 120

var autotest: Node


func run() -> void:
	var r := {}
	var roles := ZoneBuilder.load_roles()
	var cat := roles.catalog
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(STAMPS_JSON))
	r["El catálogo del juego tiene todos los sellos curados"] = cat.stamps.size() == data["stamps"].size() and cat.stamps.size() > 50
	var holes := []
	var keys := {}
	var dup := 0
	for st in cat.stamps:
		for v in st["variants"]:
			if not _holes(st["size"], v["cells"]).is_empty():
				holes.append(st["name"])
			var key := str(st["size"]) + str(v["cells"])
			dup += int(keys.has(key))
			keys[key] = true
	r["Ningún sello tiene celdas vacías adentro del contorno"] = holes.is_empty()
	r["No hay sellos repetidos"] = dup == 0
	r["Todos los sellos tienen nombre, grupo y lugar"] = cat.stamps.all(func(s: Dictionary) -> bool:
		return s["name"] != "" and s["group"] != "" and not (s["name"] as String).contains("_"))

	# Todos pegados en una zona temporal (no se guarda).
	var world := MapDocument.load_world_copy()
	var layout := _layout(cat.stamps)
	var e := ZoneEntry.new()
	e.id = "prueba_sellos"
	e.size = layout["size"]
	e.origin = Vector2i(-100000, -100000)
	var tileset: TileSet = load(ZoneBuilder.TILESET_PATH)
	var doc := MapDocument.create(world, e, roles, tileset, false)
	add_child(doc.zone)
	var before := _snapshot(doc)
	var bad_tiles := 0
	var bad_solid := 0
	var bad_door := 0
	var bad_above := 0
	var cells_n := 0
	for item in layout["items"]:
		var st: Dictionary = item[0]
		doc.place_stamp(st, item[1], item[2])
	doc.commit("Todos los sellos")
	var objects := MapRules.objects_by_cell(doc.zone)
	for item in layout["items"]:
		var st: Dictionary = item[0]
		var v: Dictionary = st["variants"][item[2]]
		var size: Vector2i = st["size"]
		var cells: PackedInt32Array = v["cells"]
		for i in cells.size():
			if cells[i] < 0:
				continue
			cells_n += 1
			var c: Vector2i = item[1] + Vector2i(i % size.x, i / size.x)
			if doc.metatile(MapDocument.GROUND, c) != cells[i]:
				bad_tiles += 1
			var solid := MapRules.cell_physics(doc.zone, c, objects) == MapRules.SOLID
			if solid != (v["solid"][i] == 1):
				bad_solid += 1
			if ZoneBuilder.has_above(cells[i]) and doc.layer(MapDocument.OVERHEAD).get_cell_source_id(c) < 0:
				bad_above += 1
		# En FireRed la celda de la puerta es sólida (el warp salta al intentar entrar); lo que tiene que poder
		# caminarse es el frente: la celda de abajo.
		for d in v["doors"]:
			var front: Vector2i = item[1] + Vector2i(d % size.x, d / size.x) + _front_dir(ZoneBuilder.behavior_of(cells[d]))
			if MapRules.cell_physics(doc.zone, front, objects) == MapRules.SOLID:
				bad_door += 1
				print("  frente de puerta sólido: ", st["name"], " celda ", d, " behavior 0x%x" % ZoneBuilder.behavior_of(cells[d]))
	print("[sellos] %d sellos (%d variantes), %d celdas pegadas" % [cat.stamps.size(), layout["items"].size(), cells_n])
	r["Pegados: cada celda con su metatile"] = bad_tiles == 0
	r["Pegados: colisión igual a la del mapa real (paredes y techos sólidos)"] = bad_solid == 0
	r["Pegados: se puede caminar frente a cada puerta"] = bad_door == 0
	r["Pegados: techos y copas en Overhead"] = bad_above == 0
	doc.do_undo()
	r["Deshacer: la zona queda igual que antes"] = _snapshot(doc) == before
	doc.do_redo()
	r["Rehacer: vuelven los sellos"] = doc.metatile(MapDocument.GROUND, layout["items"][0][1] + _first_cell(layout["items"][0])) >= 0
	doc.dispose()

	var ok := r.values().all(func(x): return x)
	for k in r:
		print("[sellos] %s %s" % ["OK   " if r[k] else "FALLO", k])
	print("[autotest-stamps] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina: todos los sellos pegados en grilla en el editor, con y sin la superposición de colisión.
func showcase() -> void:
	get_tree().change_scene_to_file("res://scenes/tools/map_editor.tscn")
	await _frames(4)
	var ed: Node = get_tree().current_scene
	var roles: TileRoleSet = ed.roles
	var layout := _layout(roles.catalog.stamps)
	var e := ZoneEntry.new()
	e.id = "vitrina_sellos"
	e.display_name = "Vitrina de sellos"
	e.size = layout["size"]
	e.origin = Vector2i(-100000, -100000)
	ed._close_doc()
	ed.world.zones.append(e)
	ed._set_doc(MapDocument.create(ed.world, e, roles, ed.tileset, false))
	for item in layout["items"]:
		ed.doc.place_stamp(item[0], item[1], item[2])
	ed.doc.commit("Vitrina")
	ed._view_menu.set_item_checked(0, false)
	ed._on_view(0)
	await _frames(20)
	ed._toggle_view(1)  # colisión
	await _frames(20)
	ed._toggle_view(1)
	for zoom_at in [Vector2i(0, 0), Vector2i(40, 0), Vector2i(80, 0), Vector2i(0, 40)]:
		ed.cam.zoom = Vector2(1.6, 1.6)
		ed._center_on(Vector2((zoom_at + Vector2i(20, 12)) * 16))
		await _frames(12)
		ed._toggle_view(1)
		await _frames(12)
		ed._toggle_view(1)
	get_tree().quit()


## Hojas de contacto (con ventana: godot --path . --quit-after 3000 -- --showcase-stamp-sheets <carpeta>):
## cada sello renderizado al lado de su recorte de la referencia, con nombre, grupo, lugar y diferencia de
## píxeles; y la paleta "como en la hoja" al lado de la hoja del mundo. Guarda PNG en la carpeta.
func contact_sheets() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[args.find("--showcase-stamp-sheets") + 1]
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(STAMPS_JSON))
	var roles := ZoneBuilder.load_roles()
	var sheets := {"edificios": _ref_image("res://art_src/referencia/frlg_edificios.png"),
		"mundo": _ref_image("res://art_src/referencia/frlg_tiles_mundo.png")}
	var phases := {"edificios": Vector2i(0, 7), "mundo": Vector2i(1, 1)}
	var entries := []
	for i in data["stamps"].size():
		var js: Dictionary = data["stamps"][i]
		for vi in js["variants"].size():
			entries.append([roles.catalog.stamps[i], vi, js["variants"][vi]])
	var root := Control.new()
	root.theme = UiStyle.theme()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(root)
	var page := 0
	var k := 0
	while k < entries.size():
		for c in root.get_children():
			c.free()
		var bg := ColorRect.new()
		bg.color = Color(0.1, 0.11, 0.14)
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		root.add_child(bg)
		var flow := HFlowContainer.new()
		flow.position = Vector2(8, 8)
		flow.size = Vector2(1264, 704)
		flow.add_theme_constant_override("h_separation", 14)
		flow.add_theme_constant_override("v_separation", 10)
		root.add_child(flow)
		var used := 0.0
		var row_h := 0.0
		var x := 0.0
		while k < entries.size():
			var st: Dictionary = entries[k][0]
			var js: Dictionary = entries[k][2]
			var size: Vector2i = st["size"]
			var scale := 1.0 if size.x * size.y > 60 else 2.0
			var w := size.x * 16 * scale * 2 + 12
			var h := size.y * 16 * scale + 34
			if x + w > 1264:
				x = 0
				used += row_h + 10
				row_h = 0
			if used + h > 700 and flow.get_child_count() > 0:
				break
			x += w + 14
			row_h = maxf(row_h, h)
			var box := VBoxContainer.new()
			box.add_theme_constant_override("separation", 1)
			var name := UiStyle.label("%s · %s" % [st["name"], js["name"]] if st["variants"].size() > 1 else st["name"], 11, UiStyle.ACCENT)
			box.add_child(name)
			var pics := HBoxContainer.new()
			var ref: Array = js["ref"]["rect"]
			var ph: Vector2i = phases[js["ref"]["sheet"]]
			var crop: Image = sheets[js["ref"]["sheet"]].get_region(Rect2i(ph.x + ref[0] * 17, ph.y + ref[1] * 17, ref[2] * 17 - 1, ref[3] * 17 - 1))
			pics.add_child(_pic(ImageTexture.create_from_image(crop), Vector2(ref[2] * 17 - 1, ref[3] * 17 - 1) * scale))
			pics.add_child(_pic(MapIcons.stamp(st, entries[k][1]), Vector2(size * 16) * scale))
			box.add_child(pics)
			var d: int = js["ref_diff"]
			box.add_child(UiStyle.label("%s · %s · dif: %d px" % [st["group"], st["place"], d], 10, UiStyle.TEXT_DIM if d == 0 else Color(1, 0.6, 0.4)))
			flow.add_child(box)
			k += 1
		await _frames(3)
		get_viewport().get_texture().get_image().save_png("%s/sellos_%02d.png" % [out, page])
		page += 1
	# Paleta como en la hoja, al lado de la hoja del mundo.
	for c in root.get_children():
		c.free()
	var bg2 := ColorRect.new()
	bg2.color = Color(0.1, 0.11, 0.14)
	bg2.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg2)
	var view := MapSheetView.new()
	view.setup(roles.catalog, roles)
	view.position = Vector2(8, 8)
	view.size = view.custom_minimum_size
	root.add_child(view)
	var ref_pic := _pic(ImageTexture.create_from_image(sheets["mundo"]), Vector2(sheets["mundo"].get_size()))
	ref_pic.position = Vector2(view.size.x + 30, 8)
	root.add_child(ref_pic)
	await _frames(3)
	get_viewport().get_texture().get_image().save_png("%s/paleta_vs_hoja.png" % out)
	print("hojas de contacto: ", page, " páginas en ", out)
	get_tree().quit()


func _ref_image(path: String) -> Image:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	return img


func _pic(tex: Texture2D, size: Vector2) -> TextureRect:
	var t := TextureRect.new()
	t.texture = tex
	t.custom_minimum_size = size
	t.size = size
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return t


## Acomoda los sellos (cada variante) en filas de ROW_W celdas, con 1 de separación.
func _layout(stamps: Array) -> Dictionary:
	var items := []
	var x := 1
	var y := 1
	var row_h := 0
	for st in stamps:
		for vi in st["variants"].size():
			var size: Vector2i = st["size"]
			if x + size.x + 1 > ROW_W:
				x = 1
				y += row_h + 1
				row_h = 0
			items.append([st, Vector2i(x, y), vi])
			x += size.x + 1
			row_h = maxi(row_h, size.y)
	return {"items": items, "size": Vector2i(ROW_W, y + row_h + 2)}


## De qué lado se entra a una puerta según su behavior de FireRed (puerta y cueva: desde abajo; flechas de
## garita: desde el lado contrario a la flecha).
static func _front_dir(behavior: int) -> Vector2i:
	match behavior:
		0x62: return Vector2i.LEFT   # flecha al este: se entra caminando hacia la derecha
		0x63: return Vector2i.RIGHT
		0x64: return Vector2i.DOWN
		0x65: return Vector2i.UP
	return Vector2i.DOWN


func _first_cell(item: Array) -> Vector2i:
	var st: Dictionary = item[0]
	var cells: PackedInt32Array = st["variants"][item[2]]["cells"]
	for i in cells.size():
		if cells[i] >= 0:
			return Vector2i(i % st["size"].x, i / st["size"].x)
	return Vector2i.ZERO


static func _holes(size: Vector2i, cells: PackedInt32Array) -> Array:
	var seen := {}
	var stack := []
	for x in size.x:
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, size.y - 1))
	for y in size.y:
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(size.x - 1, y))
	while not stack.is_empty():
		var c: Vector2i = stack.pop_back()
		if seen.has(c) or c.x < 0 or c.y < 0 or c.x >= size.x or c.y >= size.y or cells[c.y * size.x + c.x] >= 0:
			continue
		seen[c] = true
		stack.append_array([c + Vector2i.RIGHT, c + Vector2i.LEFT, c + Vector2i.DOWN, c + Vector2i.UP])
	var out := []
	for i in cells.size():
		if cells[i] < 0 and not seen.has(Vector2i(i % size.x, i / size.x)):
			out.append(i)
	return out


func _snapshot(doc: MapDocument) -> Dictionary:
	var out := {}
	for li in ZoneBuilder.LAYERS.size():
		var l := doc.layer(li)
		for c in l.get_used_cells():
			out["%d:%s" % [li, c]] = [l.get_cell_source_id(c), l.get_cell_atlas_coords(c), l.get_cell_alternative_tile(c)]
	return out


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
