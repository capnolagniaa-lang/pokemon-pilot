extends SceneTree
## Genera docs/POKEMON_KITS_Y_ATAQUES.md (pedido del usuario 2026-10-28): los 386 Pokémon con su kit (estilo, firma,
## los 4 ataques con su tecla) y todos los ataques que pueden aprender (learnset: kit + FireRed + extras), con tipo,
## categoría, forma en tiempo real, potencia y recarga. Marca cuáles aparecen hoy en el juego (salvajes o entrenadores).
## Volver a correrlo después de tocar kits o learnsets (el .md es generado, no editarlo a mano).
## Uso: godot --headless --path . --quit-after 20000 --script res://tools/build_pokemon_docs.gd

const OUT := "res://docs/POKEMON_KITS_Y_ATAQUES.md"
const KIND := ["Disparo", "Embestida", "Área", "Defensa", "Golpe", "Zona", "Canalizado", "Embestida+combo", "Látigo", "Mejora propia"]
const CAT := ["Físico", "Especial", "Estado"]
const KEYS := ["Clic izq.", "Clic der.", "Q", "R"]


func _init() -> void:
	var species: Array[SpeciesData] = []
	for f in DirAccess.get_files_at("res://data/species"):
		if f.ends_with(".tres"):
			species.append(load("res://data/species/" + f))
	species.sort_custom(func(a, b): return a.dex < b.dex)
	var by_id := {}
	for sp in species:
		by_id[sp.id] = sp
	var seen := _in_game()
	var own := species.filter(func(sp): return sp.kit != null and not sp.kit_inherited).size()
	var inh := species.filter(func(sp): return sp.kit != null and sp.kit_inherited).size()

	var L: Array[String] = ["# Pokémon: kits y ataques que aprenden", "",
		"> **Generado** por `tools/build_pokemon_docs.gd` (%s). No editar a mano: cambiar los kits/learnsets y volver a" % Time.get_date_string_from_system(),
		"> correr la herramienta. Kits: `docs/PLAN_IDENTIDAD_COMBATE.md` · salvajes por zona: `docs/SALVAJES_LISTADO.md`.", "",
		"**%d especies** · kit propio: %d · kit heredado de su preevolución: %d · sin kit: %d · aparecen hoy en el juego: %d." % [
			species.size(), own, inh, species.size() - own - inh, seen.size()], "",
		"Teclas del kit: Clic izq. · Clic der. · Q · R (el de más recarga) + Espacio (esquive, igual para todos). Los ataques",
		"del learnset se equipan desde la ficha del Pokémon (Esc → Equipo). \"Sin kit\" = pelea con 4 ataques de su learnset y",
		"sin mecánica de firma.", "", "## Índice", "",
		"| N.º | Pokémon | Tipos | Kit | Estilo | Firma | ¿En el juego? |", "|---|---|---|---|---|---|---|"]
	for sp in species:
		L.append("| %03d | [%s](#%s) | %s | %s | %s | %s | %s |" % [sp.dex, sp.display_name, _anchor(sp), _types(sp),
			_origin(sp, by_id), sp.kit.archetype if sp.kit else "—",
			sp.kit.signature.display_name if sp.kit and sp.kit.signature else "—", "sí" if seen.has(sp.id) else ""])
	L.append("")
	L.append("## Fichas")
	L.append("")
	for sp in species:
		L.append("### %03d %s" % [sp.dex, sp.display_name])
		L.append("")
		L.append("%s · %s%s" % [_types(sp), sp.genus if sp.genus != "" else "", " · **aparece en el juego**" if seen.has(sp.id) else ""])
		L.append("")
		if sp.kit != null:
			L.append("**Kit**: %s, estilo *%s* (distancia preferida %d px)." % [_origin(sp, by_id), sp.kit.archetype, int(sp.kit.preferred_range)])
			if sp.kit.signature != null:
				L.append("")
				L.append("**Firma — %s**: %s" % [sp.kit.signature.display_name, sp.kit.signature.description.replace("\n", " ")])
			L.append("")
			L.append("| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |")
			L.append("|---|---|---|---|---|---|---|")
			for i in sp.kit.moves.size():
				var m: MoveData = sp.kit.moves[i]
				L.append("| %s | %s | %s |" % [KEYS[i] if i < KEYS.size() else "", m.display_name, _move_cols(m)])
		else:
			L.append("**Sin kit**: pelea con su learnset (equipa los 4 primeros que aprende a su nivel).")
		L.append("")
		L.append("**Ataques que puede aprender (%d)**:" % sp.learnset.size())
		L.append("")
		L.append("| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |")
		L.append("|---|---|---|---|---|---|---|")
		for e in sp.learnset:
			if e.move != null:
				var kit_mark := " (kit)" if sp.kit != null and e.move in sp.kit.moves else ""
				L.append("| %d | %s%s | %s |" % [e.level, e.move.display_name, kit_mark, _move_cols(e.move)])
		L.append("")
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_string("\n".join(L) + "\n")
	f.close()
	print("Listo: %s (%d especies, %d líneas)" % [OUT, species.size(), L.size()])
	quit()


## Especies que aparecen hoy: tablas de salvajes, entrenadores de FireRed y personas de la historia. Se leen como texto
## (en modo --script las tablas no cargan: sus clases dependen de los autoloads).
func _in_game() -> Dictionary:
	var out := {}
	var ids := RegEx.create_from_string('species_id = "([a-z0-9_]+)"')
	var paths := RegEx.create_from_string("res://data/species/([a-z0-9_]+)[.]tres")
	for dir in ["res://data/world/encounters", "res://data/world/encounters/biomas", "res://data/story/npcs"]:
		for f in DirAccess.get_files_at(dir):
			if f.ends_with(".tres"):
				var text := FileAccess.get_file_as_string(dir + "/" + f)
				for m in ids.search_all(text) + paths.search_all(text):
					out[m.get_string(1)] = true
	var trainers: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/source/trainers_frlg.json"))
	for zone in trainers.values():
		for t in zone.values():
			for row in t["team"]:
				out[row[0]] = true
	for id in ["articuno", "zapdos", "snorlax", "lapras", "eevee", "hitmonlee", "hitmonchan", "omanyte", "kabuto", "aerodactyl"]:
		out[id] = true  # legendarios, regalos y fósiles de la historia
	return out


func _origin(sp: SpeciesData, by_id: Dictionary) -> String:
	if sp.kit == null:
		return "sin kit"
	if not sp.kit_inherited:
		return "propio"
	var from: SpeciesData = by_id.get(sp.evolves_from)
	while from != null and from.kit_inherited and by_id.has(from.evolves_from):
		from = by_id[from.evolves_from]
	return "heredado de %s" % (from.display_name if from != null else "su preevolución")


func _types(sp: SpeciesData) -> String:
	return "/".join(sp.types.map(func(t): return t.display_name))


func _move_cols(m: MoveData) -> String:
	return "%s | %s | %s | %s | %s s" % [m.element.display_name if m.element else "—", CAT[m.category], KIND[m.kind],
		str(int(m.power)) if m.power > 0.0 else "—", str(snappedf(m.cooldown, 0.1))]


## Ancla de GitHub para el título "### 001 Bulbasaur".
func _anchor(sp: SpeciesData) -> String:
	var t := ("%03d %s" % [sp.dex, sp.display_name]).to_lower()
	var out := ""
	for ch in t:
		if ch == " ":
			out += "-"
		elif ch.is_valid_identifier() or ch.is_valid_int() or ch in "áéíóúñü":
			out += ch
	return out
