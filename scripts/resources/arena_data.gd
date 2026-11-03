class_name ArenaData
extends Resource
## Una arena de combate contra entrenadores (docs/PLAN_ENTRENADORES.md, E-1): la escena (una zona de tiles de
## FireRed, editable con el editor de mapas) y su ambientación (líneas de la cancha, partículas, braseros, luz).
## Datos en data/arenas/<id>.tres; las escenas las arma tools/build_arenas.gd en scenes/world/arenas/.

@export var id: String = ""
@export var display_name: String = ""
@export_file("*.tscn") var scene_path: String = ""
## Celdas locales: dónde se para el entrenador rival, dónde se para el jugador y dónde salen los Pokémon.
@export var foe_trainer_cell: Vector2i = Vector2i.ZERO
@export var player_cell: Vector2i = Vector2i.ZERO
@export var foe_mon_cell: Vector2i = Vector2i.ZERO
@export var player_mon_cell: Vector2i = Vector2i.ZERO
## Rectángulo de la cancha (celdas): ahí se dibujan las líneas.
@export var field: Rect2i = Rect2i()

## Pintura de la arena entera (Qwen, sprites/arenas/<id>.png; tools/paint_arenas.py): se dibuja encima de los tiles,
## que quedan para la colisión y el entorno. Con pintura no se dibujan las líneas, el emblema ni los braseros por código.
@export var painting: Texture2D

@export_group("Ambientación")
## Tipo que ambienta la arena (los gimnasios: el de su líder). Vacío = arena común.
@export var element_id: String = ""
@export var line_color: Color = Color(1, 1, 1, 0.35)
## Partículas que flotan: vacío (nada), "polvo", "hojas", "confeti", "burbujas" (suben; el gimnasio de agua).
@export var particles: String = ""
@export var particle_color: Color = Color(1, 1, 1, 0.5)
## Braseros con fuego en las esquinas de la cancha.
@export var braziers: bool = false
## Tinte de ambiente (se multiplica sobre la arena).
@export var ambient: Color = Color(1, 1, 1, 1)
## Arena de gimnasio: cartel de entrada épico, temblor y presentación del líder.
@export var epic: bool = false
## Estadio: tribunas con público sobre la pared de arriba y a los costados (el torneo).
@export var crowd: bool = false


const DEFAULT_ID := "arena_campo"
const PLACES_PATH := "res://data/arenas/por_lugar.json"
static var _places: Dictionary = {}


## La arena de una pelea (pedido del usuario 2026-11-03): si el entrenador tiene la de siempre (el campo), la de su
## lugar según data/arenas/por_lugar.json (Torre, Silph, cuevas, el S.S. Anne...), si ya existe; si no, la suya.
static func for_zone(arena_id: String, zone_id: String) -> String:
	if arena_id != DEFAULT_ID or zone_id == "":
		return arena_id
	if _places.is_empty() and FileAccess.file_exists(PLACES_PATH):
		_places = JSON.parse_string(FileAccess.get_file_as_string(PLACES_PATH))
	var pick: String = _places.get("rutas", {}).get(zone_id, "")
	if pick == "":
		for row in _places.get("prefijos", []):
			if zone_id.begins_with(str(row[0])):
				pick = str(row[1])
				break
	return pick if pick != "" and ResourceLoader.exists("res://data/arenas/%s.tres" % pick) else arena_id
