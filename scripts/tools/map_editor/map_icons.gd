class_name MapIcons
extends RefCounted
## Íconos del editor de mapas sacados de los mismos gráficos del juego (atlas de FireRed y sprites de objetos).

static var _cache: Dictionary = {}


## Ícono de un metatile (parte de abajo o, con above = true, la de arriba).
static func metatile(m: int, above: bool = false) -> Texture2D:
	var key := "%d:%s" % [m, above]
	if _cache.has(key):
		return _cache[key]
	var t := AtlasTexture.new()
	t.atlas = load(ZoneBuilder.TILES_DIR + ("/general_above.png" if above else "/general_below.png"))
	t.region = Rect2((m % 16) * 16, (m / 16) * 16, 16, 16)
	_cache[key] = t
	return t


## Ícono de un rol (para un árbol, el 2x2 con su copa).
static func role(r: TileRole) -> Texture2D:
	if r.kind == TileRole.Kind.AUTOTILE:
		return metatile(r.piece(1, 1))
	if r.kind != TileRole.Kind.TREE:
		return metatile(r.metatiles[0])
	var key := "role:" + r.id
	if _cache.has(key):
		return _cache[key]
	var below: Image = (load(ZoneBuilder.TILES_DIR + "/general_below.png") as Texture2D).get_image()
	var above: Image = (load(ZoneBuilder.TILES_DIR + "/general_above.png") as Texture2D).get_image()
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var ids := [r.metatiles[0], r.metatiles[1], r.metatiles[4], r.metatiles[5]]
	var offs := [Vector2i(0, 0), Vector2i(16, 0), Vector2i(0, 16), Vector2i(16, 16)]
	for i in 4:
		var m: int = ids[i]
		var src := Rect2i((m % 16) * 16, (m / 16) * 16, 16, 16)
		img.blend_rect(_rgba(below.get_region(src)), Rect2i(0, 0, 16, 16), offs[i])
		if ZoneBuilder.has_above(m):
			img.blend_rect(_rgba(above.get_region(src)), Rect2i(0, 0, 16, 16), offs[i])
	var tex := ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex


static func _rgba(img: Image) -> Image:
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	return img


## Ícono de un objeto del entorno: primer cuadro de su Sprite.
static func object(scene_path: String) -> Texture2D:
	if _cache.has(scene_path):
		return _cache[scene_path]
	var node: Node = load(scene_path).instantiate()
	var tex: Texture2D = null
	var sprite := node.get_node_or_null("Sprite") as Sprite2D
	if sprite != null and sprite.texture != null:
		var a := AtlasTexture.new()
		a.atlas = sprite.texture
		var w := sprite.texture.get_width() / maxi(1, sprite.hframes)
		var h := sprite.texture.get_height() / maxi(1, sprite.vframes)
		a.region = Rect2(0, 0, w, h)
		tex = a
	node.free()
	_cache[scene_path] = tex
	return tex


## Nombre para mostrar de un objeto: su `display_name` (EnvObject) o el nombre del archivo.
static func object_name(scene_path: String) -> String:
	var packed: PackedScene = load(scene_path)
	var state := packed.get_state()
	for i in state.get_node_property_count(0):
		if state.get_node_property_name(0, i) == "display_name":
			return str(state.get_node_property_value(0, i))
	return scene_path.get_file().get_basename().capitalize()
