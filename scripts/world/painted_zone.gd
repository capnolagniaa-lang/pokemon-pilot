class_name PaintedZone
extends Node2D
## Skins del mundo (docs/PLAN_TERRENO_PROPIO.md, "Repintado"): una skin es una carpeta art/skins/<skin>/ con una imagen
## repintada por zona (<zona>.png = mediodía, de tools/repaint_zone.py), las mismas re-iluminadas por momento del día
## (<zona>@manana.png, @atardecer, @noche: luz horneada) y un skin.json con su nombre. Con la skin elegida en Ajustes del
## juego (ajuste de partida "skin"; "clasico" = los tiles de FireRed), la zona que tenga imagen se dibuja con ella en
## lugar de sus capas de tiles, fundiendo las dos imágenes más cercanas a la hora (shaders/painted_zone.gdshader).
## La pintura va en sus propias capas (CanvasLayer que siguen a la cámara: el suelo debajo del mundo, techos y copas
## encima), así el tinte de la hora (Daylight) no la vuelve a teñir: solo tiñe a personajes, Pokémon y efectos. En una
## zona con skin no se dibujan las sombras del mapa, las ventanas ni los faroles calculados (ya están pintados):
## `covers(zone)` lo consultan ZoneShadows, ZoneLights, StreetLamps y DayNight.
## La colisión, las puertas, los tags y los salvajes siguen saliendo de las celdas (las capas quedan, invisibles).

const ROOT := "res://art/skins/"
const CLASSIC := "clasico"
const LAYERS := ["Ground", "Water", "Foliage", "TreeShadows", "Overhead"]
const SHADER := preload("res://shaders/painted_zone.gdshader")
## Momentos del día que puede tener una zona ("" = la imagen base, el mediodía) y a qué hora se ve cada uno entero;
## entre dos se funde. Si falta alguno, se usa la base.
const MOMENTS := [[0.0, "noche"], [5.0, "noche"], [7.0, "manana"], [10.0, ""], [15.5, ""], [18.5, "atardecer"],
	[20.5, "noche"], [24.0, "noche"]]
## Capas: el suelo debajo del mundo (capa 0, la del Daylight) y los techos encima (debajo del post-procesado, 5).
const GROUND_LAYER := -1
const TOP_LAYER := 1

var zone: Zone
var entry: ZoneEntry
var _hidden: Array[CanvasItem] = []
var _built := ""  # skin dibujada ahora ("" = ninguna: tiles)
var _tex := {}    # momento -> Texture2D
var _sprites: Array[Sprite2D] = []


## Las skins que hay: [[id, nombre], ...], la clásica primero.
static func skins() -> Array:
	var out := [[CLASSIC, "Clásico (FireRed)"]]
	for d in DirAccess.get_directories_at(ROOT):
		var name := d
		var info := ROOT + d + "/skin.json"
		if FileAccess.file_exists(info):
			var data = JSON.parse_string(FileAccess.get_file_as_string(info))
			if data is Dictionary:
				name = str(data.get("name", d))
		out.append([d, name])
	return out


static func current() -> String:
	return str(GameState.setting("skin"))


static func available(zone_id: String, skin := "") -> bool:
	if skin == "":
		skin = current()
	return skin != CLASSIC and ResourceLoader.exists(ROOT + skin + "/" + zone_id + ".png")


## ¿Esa zona (nodo) se está dibujando con una skin? (Las sombras, ventanas y faroles calculados se apagan.)
static func covers(zone_node: Node) -> bool:
	var pz := zone_node.get_node_or_null("PaintedZone") as PaintedZone if zone_node != null else null
	return pz != null and pz._built != ""


static func attach(zone_node: Node2D, e: ZoneEntry) -> PaintedZone:
	var old := zone_node.get_node_or_null("PaintedZone")
	if old != null:
		(old as PaintedZone).clear()
		old.free()
	var node := PaintedZone.new()
	node.name = "PaintedZone"
	node.zone = zone_node as Zone
	node.entry = e
	zone_node.add_child(node)
	zone_node.move_child(node, 0)
	node._sync()
	return node


func _process(_delta: float) -> void:
	_sync()
	if _built != "":
		_blend(GameState.time_of_day)


## Dibuja la skin elegida si cambió (o vuelve a los tiles).
func _sync() -> void:
	var want := current() if available(entry.id) else ""
	if want == _built:
		return
	clear()
	if want != "":
		build(want)


func build(skin: String) -> void:
	_built = skin
	_tex.clear()
	for m in MOMENTS:
		var moment: String = m[1]
		var path := ROOT + skin + "/" + entry.id + ("" if moment == "" else "@" + moment) + ".png"
		if not _tex.has(moment) and ResourceLoader.exists(path):
			_tex[moment] = load(path)
	var base: Texture2D = _tex[""]
	var k := float(base.get_width()) / (entry.size.x * Zone.TILE)  # píxeles de la imagen por píxel del mundo
	_sprites.append(_layer("PaintedGround", GROUND_LAYER, base, k, null))
	var cells := _overhead_cells()
	if cells != null:
		_sprites.append(_layer("PaintedOverhead", TOP_LAYER, base, k, cells))
	for name in LAYERS:
		var l := zone.get_node_or_null(name) as CanvasItem
		if l != null and l.visible:
			l.visible = false
			_hidden.append(l)
	_blend(GameState.time_of_day)


## Deja la zona como estaba (los tiles a la vista).
func clear() -> void:
	_built = ""
	_sprites.clear()
	for c in get_children():
		c.queue_free()
	for l in _hidden:
		if is_instance_valid(l):
			l.visible = true
	_hidden.clear()


## Qué dos imágenes y cuánto de cada una a esa hora.
static func blend_at(h: float, have: Dictionary) -> Array:
	h = fposmod(h, 24.0)
	for i in range(MOMENTS.size() - 1):
		var a: Array = MOMENTS[i]
		var b: Array = MOMENTS[i + 1]
		if h <= b[0]:
			var ma: String = a[1] if have.has(a[1]) else ""
			var mb: String = b[1] if have.has(b[1]) else ""
			var t := 0.0 if b[0] == a[0] else smoothstep(0.0, 1.0, (h - a[0]) / (b[0] - a[0]))
			return [ma, mb, t]
	return ["", "", 0.0]


func _blend(h: float) -> void:
	var b := blend_at(h, _tex)
	for s in _sprites:
		if not is_instance_valid(s):
			continue
		s.texture = _tex[b[0]]
		var mat := s.material as ShaderMaterial
		mat.set_shader_parameter("tex_b", _tex[b[1]])
		mat.set_shader_parameter("mix_t", b[2])


## Un sprite de la pintura en su propia capa (sigue a la cámara, en coordenadas del mundo).
func _layer(node_name: String, layer: int, tex: Texture2D, k: float, cells: Texture2D) -> Sprite2D:
	var cl := CanvasLayer.new()
	cl.name = node_name + "Layer"
	cl.layer = layer
	cl.follow_viewport_enabled = true
	add_child(cl)
	var s := Sprite2D.new()
	s.name = node_name
	s.texture = tex
	s.centered = false
	s.position = zone.global_position
	s.scale = Vector2.ONE / k
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("use_cells", cells != null)
	if cells != null:
		mat.set_shader_parameter("cells", cells)
	s.material = mat
	cl.add_child(s)
	return s


## Máscara de un píxel por celda con las celdas de la capa Overhead (techos, copas), o null si no hay.
func _overhead_cells() -> Texture2D:
	var layer := zone.get_node_or_null("Overhead") as TileMapLayer
	if layer == null or layer.get_used_cells().is_empty():
		return null
	var img := Image.create(entry.size.x, entry.size.y, false, Image.FORMAT_L8)
	for c in layer.get_used_cells():
		if Rect2i(Vector2i.ZERO, entry.size).has_point(c):
			img.set_pixelv(c, Color.WHITE)
	return ImageTexture.create_from_image(img)
