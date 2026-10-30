class_name PaintedZone
extends Node2D
## Skins del mundo (docs/PLAN_TERRENO_PROPIO.md, "Workflow vigente"): una skin es una carpeta art/skins/<skin>/ con una
## escena pintada por zona (<zona>.png = de día, <zona>@noche.png = de noche con las ventanas prendidas; de
## tools/repaint_zone.py) y un skin.json con su nombre. Con la skin elegida en Ajustes del juego (ajuste de partida
## "skin"; "clasico" = los tiles de FireRed), la zona que tenga imagen se dibuja con ella en lugar de sus capas de tiles:
## - suelo: la pintura entera, con el z de la capa Ground;
## - agua: la misma pintura solo en las celdas de la capa Water, con ondas (shaders/painted_zone.gdshader);
## - techos y copas: la misma pintura solo en las celdas de la capa Overhead, con su z (te tapan al pasar por detrás).
## La pintura va dentro de la zona (z de sus capas): el Daylight (CanvasModulate) tiñe la pintura de día como a todo; al
## oscurecer se funde la de noche, que ya trae su luz: el shader la divide por el color del Daylight para que el
## CanvasModulate no la oscurezca dos veces. (En CanvasLayer propias se veía mucho más oscura y saturada con HDR 2D.)
## Con skin no se dibujan las sombras del mapa, las ventanas ni los faroles calculados (`covers`); sí las de personajes.
## La colisión, las puertas, los tags y los salvajes siguen saliendo de las celdas (las capas quedan, invisibles).

const ROOT := "res://art/skins/"
const CLASSIC := "clasico"
const LAYERS := ["Ground", "Water", "Foliage", "TreeShadows", "Overhead"]
const SHADER := preload("res://shaders/painted_zone.gdshader")
## Oscuridad de DayNight entre la que se funde la pintura de noche.
const NIGHT_FROM := 0.45
const NIGHT_FULL := 0.95

var zone: Zone
var entry: ZoneEntry
var _hidden: Array[CanvasItem] = []
var _built := ""  # skin dibujada ahora ("" = ninguna: tiles)
var _night: Texture2D
var _sprites: Array[Sprite2D] = []
var _world: Node


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


## Cuánto de la pintura de noche se ve con esa oscuridad (0 = de día).
static func night_weight(darkness: float) -> float:
	return smoothstep(NIGHT_FROM, NIGHT_FULL, darkness)


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


func _ready() -> void:
	_world = get_tree().get_first_node_in_group("world")


func _process(_delta: float) -> void:
	_sync()
	if _built != "":
		_light()
		# Sin sombras de nubes en la zona donde estás si tiene skin (el multiplicado oscurecía y saturaba la pintura).
		var st = _world.get("streamer") if _world != null else null
		var clouds := _world.get_node_or_null("CloudShadows") as CanvasItem if _world != null else null
		if st != null and st.current != null and st.current.id == entry.id and clouds != null:
			clouds.visible = false


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
	var day: Texture2D = load(ROOT + skin + "/" + entry.id + ".png")
	var night_path := ROOT + skin + "/" + entry.id + "@noche.png"
	_night = load(night_path) if ResourceLoader.exists(night_path) else day
	var k := float(day.get_width()) / (entry.size.x * Zone.TILE)  # píxeles de la imagen por píxel del mundo
	_layer("PaintedGround", day, k, null, false).z_index = (zone.ground as CanvasItem).z_index
	var water := zone.get_node_or_null("Water") as TileMapLayer
	if water != null and not water.get_used_cells().is_empty():
		_layer("PaintedWater", day, k, _cells(water), true).z_index = water.z_index
	var top := zone.get_node_or_null("Overhead") as TileMapLayer
	if top != null and not top.get_used_cells().is_empty():
		_layer("PaintedOverhead", day, k, _cells(top), false).z_index = top.z_index
	for name in LAYERS:
		var l := zone.get_node_or_null(name) as CanvasItem
		if l != null and l.visible:
			l.visible = false
			_hidden.append(l)
	_light()


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


## El color de la hora sobre la pintura de día y la de noche fundida según la oscuridad (esa ya trae su luz).
func _light() -> void:
	var dn: DayNight = _world.get("day_night") if _world != null else null
	var t := night_weight(dn.darkness) if dn != null and _night != null else 0.0
	var daylight := _world.get_node_or_null("Daylight") as CanvasModulate if _world != null else null
	var d := daylight.color if daylight != null else Color.WHITE
	for s in _sprites:
		var m := s.material as ShaderMaterial
		m.set_shader_parameter("night_t", t)
		m.set_shader_parameter("daylight", Vector3(d.r, d.g, d.b))


func _layer(node_name: String, tex: Texture2D, k: float, cells: Texture2D, is_water: bool) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = node_name
	s.texture = tex
	s.centered = false
	s.scale = Vector2.ONE / k
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("tex_night", _night)
	mat.set_shader_parameter("use_cells", cells != null)
	mat.set_shader_parameter("water", is_water)
	mat.set_shader_parameter("image_px", Vector2(tex.get_size()))
	if cells != null:
		mat.set_shader_parameter("cells", cells)
	s.material = mat
	add_child(s)
	_sprites.append(s)
	return s


## Máscara de un píxel por celda con las celdas usadas de una capa de tiles.
func _cells(layer: TileMapLayer) -> Texture2D:
	var img := Image.create(entry.size.x, entry.size.y, false, Image.FORMAT_L8)
	for c in layer.get_used_cells():
		if Rect2i(Vector2i.ZERO, entry.size).has_point(c):
			img.set_pixelv(c, Color.WHITE)
	return ImageTexture.create_from_image(img)
