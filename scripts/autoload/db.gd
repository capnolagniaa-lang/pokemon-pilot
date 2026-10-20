extends Node
## Base de datos de contenido: carga todos los .tres de data/ al arrancar.
## Para agregar una especie o un ataque alcanza con crear el .tres en su carpeta.

const SpriteData = preload("res://scripts/generated/sprite_data.gd")

var types: Dictionary = {}    # id -> ElementType
var moves: Dictionary = {}    # id -> MoveData
var species: Dictionary = {}  # id -> SpeciesData
var type_chart: TypeChart
var config: GameConfig

var _textures: Dictionary = {}


func _ready() -> void:
	types = _load_dir("res://data/types", "ElementType")
	moves = _load_dir("res://data/moves", "MoveData")
	species = _load_dir("res://data/species", "SpeciesData")
	type_chart = load("res://data/types/type_chart.tres")
	config = load("res://data/config/game_config.tres")


func _load_dir(path: String, class_hint: String) -> Dictionary:
	var out := {}
	for f in DirAccess.get_files_at(path):
		f = f.trim_suffix(".remap")  # en exportaciones los .tres vienen remapeados
		if not f.ends_with(".tres"):
			continue
		var res = load(path.path_join(f))
		if res != null and res.get_script() != null and res.get_script().get_global_name() == class_hint:
			out[res.id] = res
	return out


## Animaciones de sprite (PMD) de una especie: {"Idle": {...}, "Walk": {...}, "portrait": path}.
func anims_of(sp: SpeciesData) -> Dictionary:
	return SpriteData.ANIMS.get(sp.dex, {})


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
