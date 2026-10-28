extends SceneTree
## Genera docs/POKEMON_HABILIDADES_Y_ATAQUES.md (pedido del usuario 2026-10-28): los 386 Pokémon con sus habilidades (y el kit
## de jefe de los líderes) y todos los ataques que pueden aprender (learnset de FireRed y sus MT/MO), con tipo,
## categoría, forma en tiempo real, potencia y recarga. Marca cuáles aparecen hoy en el juego (salvajes o entrenadores).
## Volver a correrlo después de tocar habilidades o learnsets (el .md es generado, no editarlo a mano).
## Uso: godot --headless --path . --quit-after 20000 --script res://tools/build_pokemon_docs.gd

const OUT := "res://docs/POKEMON_HABILIDADES_Y_ATAQUES.md"
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

	var L: Array[String] = ["# Pokémon: habilidades y ataques que aprenden", "",
		"> **Generado** por `tools/build_pokemon_docs.gd` (%s). No editar a mano: cambiar las habilidades/learnsets y volver" % Time.get_date_string_from_system(),
		"> a correr la herramienta. Habilidades: `tools/apply_abilities.gd` · salvajes por zona: `docs/SALVAJES_LISTADO.md`.", "",
		"**%d especies** · aparecen hoy en el juego: %d. Cada Pokémon nace con una de sus habilidades (al azar). Los ataques" % [
			species.size(), seen.size()],
		"se comportan igual para todos; viene con los últimos 4 que aprendió por nivel y desde la ficha (Esc → Equipo) se",
		"elige entre todo lo de nivel y MT: el estilo de pelea lo arma el jugador. Los Pokémon de los líderes de gimnasio con",
		"\"kit de jefe\" pelean con él (firma + 4 ataques propios).", "", "## Índice", "",
		"| N.º | Pokémon | Tipos | Habilidades | Kit de jefe | ¿En el juego? |", "|---|---|---|---|---|---|"]
	for sp in species:
		L.append("| %03d | [%s](#%s) | %s | %s | %s | %s |" % [sp.dex, sp.display_name, _anchor(sp), _types(sp),
			" / ".join(sp.abilities.map(func(a): return a.display_name)),
			sp.boss_kit.signature.display_name if sp.boss_kit and sp.boss_kit.signature else "", "sí" if seen.has(sp.id) else ""])
	L.append("")
	L.append("## Fichas")
	L.append("")
	for sp in species:
		L.append("### %03d %s" % [sp.dex, sp.display_name])
		L.append("")
		L.append("%s · %s%s" % [_types(sp), sp.genus if sp.genus != "" else "", " · **aparece en el juego**" if seen.has(sp.id) else ""])
		L.append("")
		for ab in sp.abilities:
			L.append("**Habilidad — %s**: %s" % [ab.display_name, ab.description])
			L.append("")
		var kit := sp.boss_kit
		if kit != null:
			L.append("**Kit de jefe** (solo con un líder de gimnasio), firma **%s**: %s" % [kit.signature.display_name,
				kit.signature.description.replace("\n", " ")])
			L.append("")
			L.append("| Tecla | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |")
			L.append("|---|---|---|---|---|---|---|")
			for i in kit.moves.size():
				var m: MoveData = kit.moves[i]
				L.append("| %s | %s | %s |" % [KEYS[i] if i < KEYS.size() else "", m.display_name, _move_cols(m)])
		L.append("")
		L.append("**Ataques que puede aprender (%d)**:" % sp.learnset.size())
		L.append("")
		L.append("| Nv. | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |")
		L.append("|---|---|---|---|---|---|---|")
		for e in sp.learnset:
			if e.move != null:
				L.append("| %d | %s | %s |" % [e.level, e.move.display_name, _move_cols(e.move)])
		L.append("")
		if not sp.tm_moves.is_empty():
			L.append("**Por MT/MO (%d)**:" % sp.tm_moves.size())
			L.append("")
			L.append("| | Ataque | Tipo | Categoría | Forma | Potencia | Recarga |")
			L.append("|---|---|---|---|---|---|---|")
			for m in sp.tm_moves:
				L.append("| MT | %s | %s |" % [m.display_name, _move_cols(m)])
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
