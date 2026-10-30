class_name PaintedZone
extends Node2D
## Skins del mundo (docs/PLAN_TERRENO_PROPIO.md, "Repintado"): una skin es una carpeta art/skins/<skin>/ con una imagen
## repintada por zona (<zona>.png, de tools/repaint_zone.py) y un skin.json con su nombre. Con la skin elegida en
## Ajustes del juego (ajuste de partida "skin"; "clasico" = los tiles de FireRed), la zona que tenga imagen se dibuja con
## ella en lugar de sus capas de tiles. La colisión, las puertas, los tags, los salvajes, la luz por hora, las sombras
## y las ventanas siguen saliendo de las celdas de la zona (las capas quedan, invisibles).
## Lo que tapa al jugador cuando pasa por detrás (techos, copas) se recorta de la misma imagen: las celdas donde la
## zona tiene algo en su capa `Overhead` van en una segunda imagen con el mismo z que esa capa.
## World la agrega a cada zona al cargarla; cambiar de skin en plena partida se ve al instante.

const ROOT := "res://art/skins/"
const CLASSIC := "clasico"
const LAYERS := ["Ground", "Water", "Foliage", "TreeShadows", "Overhead"]

var zone: Zone
var entry: ZoneEntry
var _hidden: Array[CanvasItem] = []
var _built := ""  # skin dibujada ahora ("" = ninguna: tiles)


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
	var tex: Texture2D = load(ROOT + skin + "/" + entry.id + ".png")
	var k := float(tex.get_width()) / (entry.size.x * Zone.TILE)  # píxeles de la imagen por píxel del mundo
	var ground := _layer("PaintedGround", tex, k)
	ground.z_index = (zone.ground as CanvasItem).z_index
	ground.z_as_relative = zone.ground.z_as_relative
	var top := _overhead(tex, k)
	if top != null:
		var layer := zone.get_node_or_null("Overhead") as CanvasItem
		_layer("PaintedOverhead", top, k).z_index = layer.z_index if layer != null else 20
	for name in LAYERS:
		var l := zone.get_node_or_null(name) as CanvasItem
		if l != null and l.visible:
			l.visible = false
			_hidden.append(l)


## Deja la zona como estaba (los tiles a la vista).
func clear() -> void:
	_built = ""
	for c in get_children():
		c.queue_free()
	for l in _hidden:
		if is_instance_valid(l):
			l.visible = true
	_hidden.clear()


func _layer(node_name: String, tex: Texture2D, k: float) -> Sprite2D:
	var s := Sprite2D.new()
	s.name = node_name
	s.texture = tex
	s.centered = false
	s.scale = Vector2.ONE / k
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(s)
	return s


## Recorte de la imagen en las celdas que tienen algo en la capa Overhead (techos, copas), o null si no hay.
func _overhead(tex: Texture2D, k: float) -> Texture2D:
	var layer := zone.get_node_or_null("Overhead") as TileMapLayer
	if layer == null or layer.get_used_cells().is_empty():
		return null
	var src := tex.get_image()
	if src.is_compressed():
		src.decompress()
	src.convert(Image.FORMAT_RGBA8)
	var out := Image.create(src.get_width(), src.get_height(), false, Image.FORMAT_RGBA8)
	var cell_px := Zone.TILE * k
	for c in layer.get_used_cells():
		var r := Rect2i(Vector2i((Vector2(c) * cell_px).floor()), Vector2i(ceili(cell_px), ceili(cell_px)))
		out.blit_rect(src, r, r.position)
	return ImageTexture.create_from_image(out)
