class_name RogueKitView
extends RefCounted
## Lo que llevás en una partida del Modo Desafío, para los menús (pedido del usuario 2026-11-11: "los objetos que agarro
## no aparecen en la mochila ni puedo equiparlos"): objetos equipados (3 ranuras), objetos guardados, bendiciones y
## mejoras (Más PS, MT). Arma las filas y el detalle para el bolsillo "De la partida" de la Mochila (BagScreen: equipar,
## desequipar, cambiar de ranura, vender) y la pestaña "Partida" de la ficha del Pokémon (SummaryScreen: solo lectura).
## Los datos y las operaciones están en RogueBoons / RogueRewards; acá solo se muestran.

## Una fila seleccionable: {kind: "item" | "stash" | "empty" | "boon" | "upgrade", index}.


static func run_of(tree: SceneTree) -> RogueRun:
	var world := tree.get_first_node_in_group("world")
	var run = world.get("rogue") if world != null else null
	return run if run != null and not GameState.rogue.is_empty() and run.boons != null else null


static func _rarity_color(boons: RogueBoons, e: Dictionary) -> Color:
	var c: Array = boons.rarity(e["rarity"])["color"]
	return Color(c[0], c[1], c[2])


static func _icon(path: String, size: float, pixel: bool) -> TextureRect:
	var pic := TextureRect.new()
	pic.custom_minimum_size = Vector2(size, size)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if pixel:
		pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if path != "" and ResourceLoader.exists(path):
		pic.texture = load(path)
	return pic


## Título, etiqueta (rareza y nivel), color, ícono y texto de una fila.
static func info(run: RogueRun, sel: Dictionary) -> Dictionary:
	var boons: RogueBoons = run.boons
	match str(sel.get("kind", "")):
		"item", "stash", "boon":
			var list: Array = boons.items() if sel["kind"] == "item" else (boons.stash() if sel["kind"] == "stash" else boons.owned())
			if int(sel["index"]) >= list.size():
				return {}
			var e: Dictionary = list[int(sel["index"])]
			var d := RogueBoons.data_of(e["id"])
			var tag := "%s  ·  Nv. %d%s" % [boons.rarity(e["rarity"])["name"], int(e["level"]), " (máximo)" if int(e["level"]) >= RogueBoons.MAX_LEVEL else ""]
			if sel["kind"] == "boon":
				tag += "  ·  %s  ·  %s" % [str(boons.config["givers"][d.giver]["name"]), d.slot_label()]
			return {"entry": e, "title": d.display_name, "tag": tag, "color": _rarity_color(boons, e), "icon": RogueBoons.icon_of(e["id"]),
				"pixel": d.is_item(), "text": boons.describe(d, e["rarity"], int(e["level"]))}
		"upgrade":
			var ups: Array = run.rewards.upgrades()
			if int(sel["index"]) >= ups.size():
				return {}
			var u: Dictionary = ups[int(sel["index"])]
			return {"title": str(u["title"]), "tag": "Mejora de la partida", "color": UiStyle.TEXT_DIM, "icon": str(u["icon"]), "pixel": false, "text": str(u["text"])}
		"empty":
			return {"title": "Ranura %d libre" % (int(sel["index"]) + 1), "tag": "", "color": UiStyle.TEXT_DIM, "icon": "", "pixel": true,
				"text": "Acá va un objeto. Se consiguen en las puertas con el ícono de Objeto y en la Tienda; si tenés alguno guardado, equipalo desde la lista."}
	return {}


## Todas las filas, en orden: [{kind, index, section}] (section = título de su grupo si es la primera de ese grupo).
static func rows(run: RogueRun) -> Array:
	var boons: RogueBoons = run.boons
	var out: Array = []
	for i in RogueBoons.ITEM_SLOTS:
		out.append({"kind": "item" if i < boons.items().size() else "empty", "index": i,
			"section": "OBJETOS EQUIPADOS  (%d de %d)" % [boons.items().size(), RogueBoons.ITEM_SLOTS] if i == 0 else ""})
	for i in boons.stash().size():
		out.append({"kind": "stash", "index": i, "section": "GUARDADOS (no hacen efecto)" if i == 0 else ""})
	for i in boons.owned().size():
		out.append({"kind": "boon", "index": i, "section": "BENDICIONES" if i == 0 else ""})
	for i in run.rewards.upgrades().size():
		out.append({"kind": "upgrade", "index": i, "section": "MEJORAS" if i == 0 else ""})
	return out


## Llena la lista de la izquierda con botones (los devuelve). `on_select(fila, con_foco_en_acciones)`.
static func fill_list(list: VBoxContainer, run: RogueRun, on_select: Callable) -> Array[Button]:
	var buttons: Array[Button] = []
	for row: Dictionary in rows(run):
		if row["section"] != "":
			list.add_child(UiStyle.label(str(row["section"]), 13, UiStyle.ACCENT))
		var data := info(run, row)
		var b := Button.new()
		b.custom_minimum_size = Vector2(500, 44)
		b.focus_mode = Control.FOCUS_ALL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 32)
		if str(data.get("icon", "")) != "" and ResourceLoader.exists(data["icon"]):
			b.icon = load(data["icon"])
		b.text = "  %s" % data.get("title", "")
		b.set_meta("row", row)
		if row["kind"] == "empty":
			b.add_theme_color_override("font_color", UiStyle.TEXT_DIM)
		elif row["kind"] != "upgrade":
			var e: Dictionary = data["entry"]
			var tag := UiStyle.label("Nv. %d" % int(e["level"]), 14, data["color"])
			tag.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
			tag.position = Vector2(-64, -10)
			b.add_child(tag)
		b.focus_entered.connect(on_select.bind(row, false))
		b.pressed.connect(on_select.bind(row, true))
		list.add_child(b)
		buttons.append(b)
	return buttons


## Llena el panel de la derecha con el detalle de una fila y, con `actions`, sus botones (equipar, desequipar, mover,
## vender). `changed(texto)` avisa que cambió algo (para refrescar la lista y el estado). Devuelve los botones.
static func fill_detail(detail: VBoxContainer, run: RogueRun, sel: Dictionary, actions: bool, changed: Callable) -> Array[Button]:
	var out: Array[Button] = []
	var data := info(run, sel)
	if data.is_empty():
		detail.add_child(UiStyle.label("Todavía no conseguiste nada en esta partida.", 16, UiStyle.TEXT_DIM))
		return out
	var boons: RogueBoons = run.boons
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	head.add_child(_icon(str(data["icon"]), 72, bool(data["pixel"])))
	var names := VBoxContainer.new()
	names.add_child(UiStyle.label(str(data["title"]), 24))
	if str(data["tag"]) != "":
		names.add_child(UiStyle.label(str(data["tag"]), 15, data["color"]))
	head.add_child(names)
	detail.add_child(head)
	var desc := UiStyle.label(str(data["text"]), 16)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = 560
	detail.add_child(desc)
	if not actions:
		return out
	var kind := str(sel["kind"])
	var i := int(sel["index"])
	if kind == "item":
		detail.add_child(UiStyle.label("Equipado en la ranura %d: está haciendo efecto." % (i + 1), 14, UiStyle.GOOD))
		var off := UiStyle.button("Desequipar (a Guardados)", 320)
		off.pressed.connect(func(): boons.unequip_item(i); changed.call("%s quedó guardado." % data["title"]))
		out.append(off)
		if i > 0:
			var up := UiStyle.button("Pasar a la ranura %d" % i, 320)
			up.pressed.connect(func(): boons.move_item(i, -1); changed.call("%s pasó a la ranura %d." % [data["title"], i]))
			out.append(up)
		if i < boons.items().size() - 1:
			var down := UiStyle.button("Pasar a la ranura %d" % (i + 2), 320)
			down.pressed.connect(func(): boons.move_item(i, 1); changed.call("%s pasó a la ranura %d." % [data["title"], i + 2]))
			out.append(down)
	elif kind == "stash":
		detail.add_child(UiStyle.label("Guardado: no hace efecto hasta que lo equipes.", 14, UiStyle.TEXT_DIM))
		if not boons.slots_full():
			var on := UiStyle.button("Equipar", 320)
			on.pressed.connect(func(): boons.equip_item(i); changed.call("%s equipado." % data["title"]))
			out.append(on)
		else:
			for s in boons.items().size():
				var other := RogueBoons.data_of(boons.items()[s]["id"])
				var sw := UiStyle.button("Cambiar por %s (ranura %d)" % [other.display_name, s + 1], 320)
				sw.pressed.connect(func(): boons.swap_item(s, i); changed.call("%s equipado en la ranura %d." % [data["title"], s + 1]))
				out.append(sw)
	if kind in ["item", "stash"]:
		var e: Dictionary = data["entry"]
		var sell := UiStyle.button("Vender por $%d" % boons.sell_value(e), 320)
		sell.pressed.connect(func(): var v := boons.sell_item(e); changed.call("Vendiste %s por $%d." % [data["title"], v]))
		out.append(sell)
	elif kind == "boon":
		detail.add_child(UiStyle.label("Las bendiciones no se sacan: duran toda la partida.", 14, UiStyle.TEXT_DIM))
	for b in out:
		detail.add_child(b)
	return out


## La pestaña "Partida" de la ficha: todo lo que lleva, con su descripción (solo lectura).
static func summary_tab(run: RogueRun) -> Control:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	for row: Dictionary in rows(run):
		if row["section"] != "":
			if box.get_child_count() > 0:
				box.add_child(HSeparator.new())
			box.add_child(UiStyle.label(str(row["section"]), 14, UiStyle.ACCENT))
		var data := info(run, row)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 10)
		line.add_child(_icon(str(data["icon"]), 40, bool(data["pixel"])))
		var texts := VBoxContainer.new()
		texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var title := str(data["title"]) + ("   ·   " + str(data["tag"]) if str(data["tag"]) != "" and row["kind"] != "upgrade" else "")
		texts.add_child(UiStyle.label(title, 16, data["color"] if row["kind"] != "empty" else UiStyle.TEXT_DIM))
		if row["kind"] != "empty":
			var desc := UiStyle.label(str(data["text"]), 14, UiStyle.TEXT_DIM if row["kind"] == "stash" else UiStyle.TEXT)
			desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			desc.custom_minimum_size.x = 760
			texts.add_child(desc)
		line.add_child(texts)
		box.add_child(line)
	box.add_child(UiStyle.label("Para equipar, desequipar o vender objetos: Mochila → De la partida.", 13, UiStyle.TEXT_DIM))
	return scroll
