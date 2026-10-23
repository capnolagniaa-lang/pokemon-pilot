extends Node
## Base de datos de contenido: carga todos los .tres de data/ al arrancar.
## Para agregar una especie o un ataque alcanza con crear el .tres en su carpeta.

const SpriteData = preload("res://scripts/generated/sprite_data.gd")

var types: Dictionary = {}    # id -> ElementType
var moves: Dictionary = {}    # id -> MoveData (solo data/moves)
## Todos los movimientos, incluidos los de los kits: clave -> MoveData. La clave es el nombre de archivo
## en data/moves ("ascuas") y "<pokémon>/<archivo>" en los kits ("bulbasaur/latigo_cepa"), porque varios
## kits comparten ids. Es lo que se guarda en las partidas (move_key / move_by_id).
var all_moves: Dictionary = {}
var species: Dictionary = {}  # id -> SpeciesData
var statuses: Dictionary = {}  # id -> StatusEffect
var interactions: Dictionary = {}  # nombre de archivo -> StatusInteraction
var difficulties: Dictionary = {}  # id -> AiDifficulty (facil, normal, dificil)
var env_states: Dictionary = {}  # id -> EnvCellState (entorno reactivo: ardiendo, mojado...)
var reactions: Dictionary = {}  # id -> ReactionRule
var temperaments: Dictionary = {}  # id -> Temperament (agresivo, territorial, timido, curioso)
var trainers: Dictionary = {}  # id -> TrainerData (entrenadores vivos, data/trainers)
var type_chart: TypeChart
var config: GameConfig

var _textures: Dictionary = {}


func _ready() -> void:
	types = _load_dir("res://data/types", "ElementType")
	moves = _load_dir("res://data/moves", "MoveData")
	species = _load_dir("res://data/species", "SpeciesData")
	statuses = _load_dir("res://data/status", "StatusEffect")
	interactions = _load_dir("res://data/status/interactions", "StatusInteraction")
	difficulties = _load_dir("res://data/config/difficulty", "AiDifficulty")
	env_states = _load_dir("res://data/environment/states", "EnvCellState")
	reactions = _load_dir("res://data/environment/reactions", "ReactionRule")
	temperaments = _load_dir("res://data/ai/temperaments", "Temperament")
	trainers = _load_dir("res://data/trainers", "TrainerData")
	type_chart = load("res://data/types/type_chart.tres")
	config = load("res://data/config/game_config.tres")
	_index_moves()


func _index_moves() -> void:
	all_moves.clear()
	for f in DirAccess.get_files_at("res://data/moves"):
		_index_move("res://data/moves/" + f.trim_suffix(".remap"), "")
	for dir in DirAccess.get_directories_at("res://data/kits"):
		for f in DirAccess.get_files_at("res://data/kits/" + dir):
			_index_move("res://data/kits/%s/%s" % [dir, f.trim_suffix(".remap")], dir + "/")
	# Por si algún learnset usa un movimiento guardado en otro lado.
	for sp: SpeciesData in species.values():
		for e in sp.learnset_entries():
			if not all_moves.values().has(e.move):
				all_moves[move_key(e.move)] = e.move


func _index_move(path: String, prefix: String) -> void:
	if not path.ends_with(".tres"):
		return
	var res = load(path)
	if res is MoveData:  # en las carpetas de kits también están kit.tres y las firmas
		all_moves[prefix + path.get_file().get_basename()] = res


## Clave estable de un movimiento para guardar partidas.
func move_key(m: MoveData) -> String:
	var p := m.resource_path
	if p.begins_with("res://data/moves/"):
		return p.get_file().get_basename()
	if p.begins_with("res://data/kits/"):
		return p.trim_prefix("res://data/kits/").get_basename()
	return m.id


## Busca cualquier movimiento por su clave (o, si no la encuentra, por su id).
func move_by_id(key: String) -> MoveData:
	if all_moves.has(key):
		return all_moves[key]
	for m: MoveData in all_moves.values():
		if m.id == key:
			return m
	return null


func _load_dir(path: String, class_hint: String) -> Dictionary:
	var out := {}
	if not DirAccess.dir_exists_absolute(path):
		return out
	for f in DirAccess.get_files_at(path):
		f = f.trim_suffix(".remap")  # en exportaciones los .tres vienen remapeados
		if not f.ends_with(".tres"):
			continue
		var res = load(path.path_join(f))
		if res != null and res.get_script() != null and res.get_script().get_global_name() == class_hint:
			var key = res.get("id")
			out[key if key != null and key != "" else f.get_basename()] = res
	return out


## Interacciones que se disparan cuando un golpe de `element` le pega a alguien con estos estados.
func interactions_for(element: ElementType, statuses_node: StatusEffects) -> Array[StatusInteraction]:
	var out: Array[StatusInteraction] = []
	for it: StatusInteraction in interactions.values():
		if it.element == element and it.requires != null and statuses_node.has_status(it.requires.id):
			out.append(it)
	return out


## Animaciones de sprite (PMD) de una especie: {"Idle": {...}, "Walk": {...}, "portrait": path}.
func anims_of(sp: SpeciesData) -> Dictionary:
	return SpriteData.ANIMS.get(sp.dex, {})


## Primer cuadro de la animación Idle mirando hacia abajo (miniaturas de la Pokédex). Si no hay, el retrato.
func idle_frame_of(sp: SpeciesData) -> Texture2D:
	var key := "idle_frame_%d" % sp.dex
	if _textures.has(key):
		return _textures[key]
	var a := anims_of(sp)
	var tex: Texture2D = portrait_of(sp)
	if a.has("Idle"):
		var at := AtlasTexture.new()
		at.atlas = texture(a["Idle"]["file"])
		at.region = Rect2(0, 0, a["Idle"]["w"], a["Idle"]["h"])
		tex = at
	_textures[key] = tex
	return tex


## Especies ordenadas por número de Pokédex.
func species_by_dex() -> Array[SpeciesData]:
	var out: Array[SpeciesData] = []
	out.assign(species.values())
	out.sort_custom(func(a, b): return a.dex < b.dex)
	return out


func portrait_of(sp: SpeciesData) -> Texture2D:
	var a := anims_of(sp)
	return texture(a["portrait"]) if a.has("portrait") else null


## Carga una textura; si el proyecto no se importó todavía, la lee directo del PNG.
func texture(path: String) -> Texture2D:
	if _textures.has(path):
		return _textures[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	else:
		var img := Image.load_from_file(path)
		if img != null:
			tex = ImageTexture.create_from_image(img)
	_textures[path] = tex
	return tex
