extends Node
## Guardado de partida: un único slot en JSON con ids (no .tres), así un cambio en los datos no rompe los
## guardados. Escritura atómica (archivo temporal + renombrar) y lectura tolerante a errores: un JSON roto
## o una especie/movimiento que ya no existe avisa y no crashea.
## GameState no conoce archivos: acá se arma el diccionario con GameState.to_dict() / from_dict().

const VERSION := 1
const DIR := "user://saves"
const SLOT := "user://saves/slot_1.json"

## Ruta del slot (el autotest la cambia para no pisar la partida real).
var slot_path := SLOT
## Avisos de la última carga (movimientos o especies que faltaban).
var last_warnings: Array = []


func has_save() -> bool:
	return FileAccess.file_exists(slot_path)


## Se puede guardar si hay partida y no se está peleando.
func can_save() -> bool:
	var world := get_tree().get_first_node_in_group("world")
	return not GameState.party.is_empty() and not (world != null and world.combat.in_battle)


## Guarda la partida. Devuelve false (y avisa) si no se puede (en combate, sin partida o error de disco).
func save_game() -> bool:
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
func read_save() -> Dictionary:
	if not has_save():
		return {}
	var text := FileAccess.get_file_as_string(slot_path)
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_warning("Guardado ilegible: %s" % slot_path)
		return {}
	return _migrate(parsed)


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
	for w in last_warnings:
		push_warning(w)
	Events.game_loaded.emit()
	return true


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(slot_path)


## Resumen para la pantalla de título: {"species": [SpeciesData...], "leader_level", "play_time", "saved_at",
## "zone"}. Vacío si no hay guardado legible.
func summary() -> Dictionary:
	var data := read_save()
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
	if species.is_empty():
		return {}
	return {"species": species, "leader_level": leader_level, "play_time": float(data.get("play_time", 0.0)),
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
