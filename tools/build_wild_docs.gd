extends SceneTree
## Genera docs/SALVAJES_LISTADO.md: qué Pokémon aparecen en cada zona (tabla propia o de bioma, pesos, niveles,
## dónde, áreas pintadas), y para cada especie que aparece: si tiene kit (estilo, mecánica de firma, 4 ataques),
## temperamento, los 4 movimientos con los que aparece a su nivel y su learnset completo.
## Volver a correrlo después de tocar tablas de encuentros, kits o learnsets (el .md es generado, no editarlo a mano).
## Uso: godot --headless --path . --quit-after 5000 --script res://tools/build_wild_docs.gd

const OUT := "res://docs/SALVAJES_LISTADO.md"
const KIND := ["Disparo", "Embestida", "Área", "Defensa", "Golpe", "Zona", "Canalizado", "Embestida+combo", "Látigo", "Mejora propia"]
const TEST_POOL := ["pidgey", "bellsprout", "rattata", "vulpix"]


func _init() -> void:
	var world: WorldData = load("res://data/world/kanto.tres")
	var lines: Array[String] = ["# Pokémon salvajes: listado por zona y por especie", "",
		"> **Generado** por `tools/build_wild_docs.gd` (%s). No editar a mano: cambiar las tablas en el editor de mapas" % Time.get_date_string_from_system(),
		"> (pestaña Salvajes) o los datos, y volver a correr la herramienta. Cómo funciona todo: `docs/SALVAJES_Y_MOVIMIENTOS.md`.", ""]
	var species_levels := {}  # id -> [min, max, [zonas]]
	lines.append("## Zonas")
	lines.append("")
	for z in world.zones:
		var own := "res://data/world/encounters/%s.tres" % z.id
		var biome := "res://data/world/encounters/biomas/%s.tres" % z.biome
		var path := own if ResourceLoader.exists(own) else (biome if ResourceLoader.exists(biome) else "")
		lines.append("### %s (`%s`, bioma `%s`)" % [z.display_name, z.id, z.biome])
		if path == "":
			lines.append("Sin tabla de encuentros: no aparece nada (salvo con \"Salvajes de prueba\").")
			lines.append("")
			continue
		var t: EncounterTable = load(path)
		lines.append("Tabla: `%s` (%s) · máx. %d vivos · reaparecen cada %d s" % [path.trim_prefix("res://"),
			"propia de la zona" if path == own else "la de su bioma", t.max_alive, int(t.respawn_time)])
		lines.append("")
		lines.append("| Especie | Dónde | Peso | % en ese lugar | Niveles | Kit | Temperamento |")
		lines.append("|---|---|---|---|---|---|---|")
		var totals := {}
		for e in t.entries:
			totals[e.where] = totals.get(e.where, 0) + e.weight
		for e in t.entries:
			var sp: SpeciesData = _species(e.species_id)
			var name := sp.display_name if sp != null else "¿%s?" % e.species_id
			var pct := 100.0 * e.weight / maxf(1, totals[e.where])
			lines.append("| %s | %s | %d | %.0f%% | %d-%d | %s | %s |" % [name, EncounterTable.WHERE.get(e.where, e.where), e.weight, pct,
				e.min_level, e.max_level, _kit_label(sp), _temp(sp)])
			_note(species_levels, e.species_id, e.min_level, e.max_level, z.display_name)
		for a in t.areas:
			lines.append("")
			lines.append("Área pintada **%s** (%d celdas): %s" % [a.name if "name" in a and a.name != "" else "sin nombre", a.cells.size(),
				", ".join(a.adjustments.map(func(adj): return "%s %s peso %d Nv. %d-%d" % [adj.species_id, adj.where, adj.weight, adj.min_level, adj.max_level]))])
			for adj in a.adjustments:
				_note(species_levels, adj.species_id, adj.min_level, adj.max_level, z.display_name + " (área)")
		lines.append("")
	lines.append("### Opción \"Salvajes de prueba\" (Esc → Opciones)")
	lines.append("En todo el mapa, en el pasto alto, al nivel de tu Pokémon (−2 a +1): %s." % ", ".join(TEST_POOL.map(func(id): return _species(id).display_name)))
	for id in TEST_POOL:  # su nivel depende del de tu Pokémon: no cambia el rango de las tablas
		var cur: Array = species_levels.get(id, [5, 5, []])
		cur[2].append("\"Salvajes de prueba\"")
		species_levels[id] = cur
	lines.append("")

	lines.append("## Especies que aparecen")
	lines.append("")
	lines.append("Movimientos \"con los que aparece\" = los 4 primeros que aprendió a ese nivel, en el orden del learnset (para los")
	lines.append("que tienen kit, son los 4 del kit). Cambiarlos: ver `docs/SALVAJES_Y_MOVIMIENTOS.md`.")
	lines.append("")
	var ids := species_levels.keys()
	ids.sort_custom(func(a, b): return _species(a).dex < _species(b).dex)
	for id in ids:
		var sp: SpeciesData = _species(id)
		if sp == null:
			continue
		var info: Array = species_levels[id]
		var lvl: int = info[0]
		lines.append("### N.º %03d %s — %s" % [sp.dex, sp.display_name, _kit_label(sp)])
		lines.append("- Tipos: %s · Temperamento: %s · Aparece en: %s (Nv. %d-%d)" % [" / ".join(sp.types.map(func(t): return t.display_name)),
			_temp(sp), ", ".join(info[2]), info[0], mini(info[1], 100)])
		if sp.kit != null:
			lines.append("- Kit: `data/kits/%s/kit.tres` · estilo **%s** · rango preferido %d px · mecánica de firma: %s" % [sp.id, sp.kit.archetype,
				int(sp.kit.preferred_range), sp.kit.signature.display_name if sp.kit.signature != null else "ninguna"])
		# Lo mismo que CreatureInstance.default_equipment (acá no hay autoloads): los 4 primeros aprendidos.
		var eq: Array[MoveData] = []
		for e in sp.learnset_entries():
			if e.level <= lvl and not eq.has(e.move) and eq.size() < 4:
				eq.append(e.move)
		lines.append("- Aparece (Nv. %d) con: %s" % [lvl, ", ".join(eq.map(func(m): return "%s (%s)" % [m.display_name, KIND[m.kind]]))])
		var ls: Array[String] = []
		for e in sp.learnset_entries():
			ls.append("Nv.%d %s" % [e.level, e.move.display_name])
		lines.append("- Learnset: %s" % ", ".join(ls))
		lines.append("")
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	f.close()
	print("Listo: ", OUT, " (", ids.size(), " especies)")
	quit()


func _species(id: String) -> SpeciesData:
	var p := "res://data/species/%s.tres" % id
	return load(p) if ResourceLoader.exists(p) else null


func _kit_label(sp: SpeciesData) -> String:
	if sp == null:
		return "—"
	return "**kit: %s**" % sp.kit.archetype if sp.kit != null else "sin kit"


func _temp(sp: SpeciesData) -> String:
	return sp.temperament.display_name if sp != null and sp.temperament != null else "—"


func _note(acc: Dictionary, id: String, lo: int, hi: int, where: String) -> void:
	var cur: Array = acc.get(id, [lo, hi, []])
	cur[0] = mini(cur[0], lo)
	cur[1] = maxi(cur[1], hi)
	if not cur[2].has(where):
		cur[2].append(where)
	acc[id] = cur
