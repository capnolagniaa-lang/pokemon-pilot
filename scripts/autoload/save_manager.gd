extends Node
## Guardado de partida en JSON con ids (no .tres), así un cambio en los datos no rompe los guardados.
## **Varias partidas con nombre** (pedido del usuario 2026-10-23): cada una es un archivo user://saves/<nombre>.json
## con su "save_name" adentro; `slot_path` es la partida actual (la que se carga/guarda), `current_name` su nombre.
## La pantalla de título las lista (list_saves) para cargar o borrar. El guardado viejo (slot_1.json) sigue
## apareciendo como "Partida 1". Escritura atómica (archivo temporal + renombrar) y lectura tolerante a errores: un JSON roto
## o una especie/movimiento que ya no existe avisa y no crashea.
## GameState no conoce archivos: acá se arma el diccionario con GameState.to_dict() / from_dict().

const VERSION := 1
const DIR := "user://saves"
const SLOT := "user://saves/slot_1.json"

## Archivos que no son partidas del jugador (prueba del editor de mapas, autotests).
const HIDDEN := ["map_editor_test.json"]

## Ruta del slot (el autotest la cambia para no pisar la partida real).
var slot_path := SLOT
## Nombre de la partida actual (se guarda adentro del archivo).
var current_name := "Partida 1"
## Avisos de la última carga (movimientos o especies que faltaban).
var last_warnings: Array = []


func has_save() -> bool:
	return FileAccess.file_exists(slot_path)


## Se puede guardar si hay partida y no se está peleando.
func can_save() -> bool:
	var world := get_tree().get_first_node_in_group("world")
	var has_game := not GameState.party.is_empty() or GameState.has_flag("historia")  # (en la historia, antes del laboratorio)
	return has_game and not (world != null and world.combat.in_battle)


## Guarda la partida. Devuelve false (y avisa) si no se puede (en combate, sin partida o error de disco).
func save_game() -> bool:
	if not GameState.test_tournament.is_empty():
		Events.message_requested.emit("En el modo de prueba del torneo no se guarda.")
		return false
	if not can_save():
		Events.message_requested.emit("No se puede guardar durante un combate.")
		return false
	var world := get_tree().get_first_node_in_group("world")
	if world != null:
		GameState.trainer_position = world.trainer.global_position
		var zone: ZoneEntry = world.trainer_zone()
		GameState.zone_name = zone.display_name if zone != null else ""
	var data := GameState.to_dict()
	data["version"] = VERSION
	data["save_name"] = current_name
	data["saved_at"] = Time.get_datetime_string_from_system(false, true)
	DirAccess.make_dir_recursive_absolute(slot_path.get_base_dir())
	var tmp := slot_path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		Events.message_requested.emit("No se pudo guardar (error %d)." % FileAccess.get_open_error())
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	var err := DirAccess.rename_absolute(tmp, slot_path)  # reemplaza el anterior de una sola vez
	if err != OK:
		Events.message_requested.emit("No se pudo guardar (error %d)." % err)
		return false
	Events.message_requested.emit("Partida guardada.")
	Events.game_saved.emit()
	return true


## Lee el guardado sin aplicarlo. Devuelve {} si no hay o está roto.
func read_save(path: String = "") -> Dictionary:
	if path == "":
		path = slot_path
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_warning("Guardado ilegible: %s" % path)
		return {}
	return _migrate(parsed)


## Todas las partidas guardadas (las más recientes primero): [{path, name, summary...}].
func list_saves() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not DirAccess.dir_exists_absolute(DIR):
		return out
	for f in DirAccess.get_files_at(DIR):
		if not f.ends_with(".json") or f in HIDDEN:
			continue
		var path := DIR.path_join(f)
		var s := summary(path)
		if s.is_empty():
			continue
		s["path"] = path
		out.append(s)
	out.sort_custom(func(a, b): return str(a["saved_at"]) > str(b["saved_at"]))
	return out


## Archivo para una partida con este nombre (letras y números; el resto, guiones bajos).
static func path_for_name(save_name: String) -> String:
	var slug := ""
	for ch in save_name.to_lower().strip_edges():
		slug += ch if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") else "_"
	slug = slug.strip_edges().replace("__", "_")
	return DIR.path_join(("partida" if slug.replace("_", "") == "" else slug) + ".json")


## Elige la partida actual por nombre (la nueva partida guarda ahí).
func use_name(save_name: String) -> void:
	current_name = save_name.strip_edges() if save_name.strip_edges() != "" else "Partida"
	slot_path = path_for_name(current_name)


## Carga una partida de la lista (y la deja como la actual).
func load_from(path: String) -> bool:
	var before := slot_path
	slot_path = path
	if not load_game():
		slot_path = before
		return false
	return true


## Carga la partida en GameState. Devuelve false si el archivo no existe, está roto o no tiene Pokémon
## válidos (en ese caso GameState no cambia).
func load_game() -> bool:
	last_warnings.clear()
	var data := read_save()
	if data.is_empty():
		last_warnings.append("El guardado no existe o está dañado.")
		return false
	if not GameState.from_dict(data, last_warnings):
		return false
	current_name = str(data.get("save_name", "Partida 1"))
	for w in last_warnings:
		push_warning(w)
	Events.game_loaded.emit()
	return true


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(slot_path)


## Resumen para la pantalla de título: {"species": [SpeciesData...], "leader_level", "play_time", "saved_at",
## "zone"}. Vacío si no hay guardado legible.
func summary(path: String = "") -> Dictionary:
	var data := read_save(path)
	if data.is_empty():
		return {}
	var species: Array[SpeciesData] = []
	var leader_level := 0
	var party = data.get("party", [])
	if party is Array:
		for m in party:
			if m is Dictionary and DB.species.has(str(m.get("species_id", ""))):
				species.append(DB.species[str(m["species_id"])])
				if leader_level == 0:
					leader_level = int(m.get("level", 1))
	var story_start: bool = data.get("story_flags", []) is Array and data["story_flags"].has("historia")
	if species.is_empty() and not story_start:  # (en la historia, antes del laboratorio no hay Pokémon)
		return {}
	return {"name": str(data.get("save_name", "Partida 1")), "species": species, "leader_level": leader_level, "play_time": float(data.get("play_time", 0.0)),
		"saved_at": str(data.get("saved_at", "")), "zone": str(data.get("zone_name", ""))}


## "1 h 05 min" / "12 min".
static func format_time(seconds: float) -> String:
	var mins := int(seconds / 60.0)
	if mins < 60:
		return "%d min" % mins
	return "%d h %02d min" % [mins / 60, mins % 60]


## Migraciones entre versiones del formato (por ahora solo la 1).
func _migrate(data: Dictionary) -> Dictionary:
	var v := int(data.get("version", 1))
	if v > VERSION:
		push_warning("Guardado de una versión más nueva (%d); se intenta cargar igual." % v)
	return data
