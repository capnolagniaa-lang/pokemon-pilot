class_name TileRoleSet
extends Resource
## Roles de tile del mundo + ajustes por metatile hechos en el panel de tiles del editor de mapas.
## Es la fuente de verdad de los tags y la colisión del TileSet: build_world.gd lo arma desde acá, así
## regenerarlo con --force no pierde lo editado.

@export var roles: Array[TileRole] = []
## Rol base: el suelo que queda al borrar y el que va debajo por defecto.
@export var base_role: String = "grass"
## Ajustes por metatile (editor de mapas): metatile (int) -> {"tags": PackedStringArray, "physics": int}.
## Pisan lo que diga el rol.
@export var overrides: Dictionary = {}
## Sugerencias a partir del "behavior" de FireRed (manifest.json): behavior (int) -> {"name", "tags", "physics"}.
@export var behavior_hints: Dictionary = {}

var _by_metatile: Dictionary = {}


func get_role(role_id: String) -> TileRole:
	for r in roles:
		if r.id == role_id:
			return r
	return null


func by_symbol(ch: String) -> TileRole:
	for r in roles:
		if r.symbol == ch:
			return r
	return null


## Rol al que pertenece un metatile (null si no tiene).
func role_of(metatile: int) -> TileRole:
	if _by_metatile.is_empty():
		for r in roles:
			for m in r.metatiles:
				_by_metatile[m] = r
	return _by_metatile.get(metatile)


func tags_for(metatile: int) -> PackedStringArray:
	if overrides.has(metatile):
		return PackedStringArray(overrides[metatile].get("tags", PackedStringArray()))
	var r := role_of(metatile)
	return r.tags if r != null else PackedStringArray()


## -1 sin colisión, 0 sólido (capa "mundo"), 1 agua.
func physics_for(metatile: int) -> int:
	if overrides.has(metatile):
		return int(overrides[metatile].get("physics", -1))
	var r := role_of(metatile)
	return r.physics if r != null else -1


func set_override(metatile: int, tags: PackedStringArray, physics: int) -> void:
	overrides[metatile] = {"tags": tags, "physics": physics}


## Todos los tags conocidos (roles + ajustes), ordenados.
func known_tags() -> PackedStringArray:
	var seen := {}
	for r in roles:
		for t in r.tags:
			seen[t] = true
	for m in overrides:
		for t in overrides[m].get("tags", []):
			seen[t] = true
	for b in behavior_hints:
		for t in behavior_hints[b].get("tags", []):
			seen[t] = true
	var out := PackedStringArray(seen.keys())
	out.sort()
	return out
