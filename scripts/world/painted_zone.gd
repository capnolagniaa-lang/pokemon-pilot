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
## Cuánto brilla la noche y su tinte salen del skin.json ("night_gain", "night_tint": [r, g, b]), para afinarla sin
## volver a pintar; "dawn_tint" = color del amanecer sobre la pintura del atardecer; "window_boost" = cuánto más brillan las ventanas; "moon_glints" = destellos de luna (rocío en el pasto, plata en el agua; 0 = sin).
## Con skin no se dibujan las sombras del mapa, las ventanas ni los faroles calculados (`covers`); sí las de personajes.
## La colisión, las puertas, los tags y los salvajes siguen saliendo de las celdas (las capas quedan, invisibles).

const ROOT := "res://art/skins/"
const CLASSIC := "clasico"
const LAYERS := ["Ground", "Water", "Foliage", "TreeShadows", "Overhead"]
const SHADER := preload("res://shaders/painted_zone.gdshader")
## Horas de los fundidos (pintura de día → atardecer → noche; de madrugada, noche → amanecer → día). El amanecer usa la
## pintura del atardecer con "dawn_tint" (skin.json). Sin pintura de atardecer, día → noche directo.
const DUSK_IN := Vector2(16.5, 18.5)
const NIGHT_IN := Vector2(19.0, 21.0)
const NIGHT_OUT := Vector2(4.5, 6.0)
const DAWN_OUT := Vector2(6.5, 8.0)
## Las ventanas (luces de la pintura de noche) se prenden antes de que entre la noche y se apagan al amanecer.
const LIGHTS_ON := Vector2(17.5, 19.5)
const LIGHTS_OFF := Vector2(5.5, 6.5)

var zone: Zone
var entry: ZoneEntry
var _hidden: Array[CanvasItem] = []
var _built := ""  # skin dibujada ahora ("" = ninguna: tiles)
var _night: Texture2D
var _dusk: Texture2D
var _sprites: Array[Sprite2D] = []
var _world: Node


## Las skins que hay: [[id, nombre], ...], la clásica primero.
static func skins() -> Array:
	var out := [[CLASSIC, "Clásico (FireRed)"]]
	for d in DirAccess.get_directories_at(ROOT):
		out.append([d, str(info(d).get("name", d))])
	return out


## El skin.json de una skin ({} si no tiene).
static func info(skin: String) -> Dictionary:
	var path := ROOT + skin + "/skin.json"
	if not FileAccess.file_exists(path):
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}


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


## Cuánto se ve de la pintura del atardecer (x) y de la de noche (y) a esa hora (las dos 0 = la de día).
## Cuánto de las ventanas prendidas se ve sobre la pintura de día a esa hora.
static func lights_weight(h: float) -> float:
	if h >= 12.0:
		return smoothstep(LIGHTS_ON.x, LIGHTS_ON.y, h)
	return 1.0 - smoothstep(LIGHTS_OFF.x, LIGHTS_OFF.y, h)


static func moment_weights(h: float, has_dusk := true) -> Vector2:
	if h >= 12.0:
		return Vector2(smoothstep(DUSK_IN.x, DUSK_IN.y, h) if has_dusk else 0.0, smoothstep(NIGHT_IN.x, NIGHT_IN.y, h))
	return Vector2(1.0 - smoothstep(DAWN_OUT.x, DAWN_OUT.y, h) if has_dusk else 0.0,
		1.0 - smoothstep(NIGHT_OUT.x, NIGHT_OUT.y, h))


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
	var dusk_path := ROOT + skin + "/" + entry.id + "@atardecer.png"
	_dusk = load(dusk_path) if ResourceLoader.exists(dusk_path) else null
	var k := float(day.get_width()) / (entry.size.x * Zone.TILE)  # píxeles de la imagen por píxel del mundo
	_layer("PaintedGround", day, k, null, false).z_index = (zone.ground as CanvasItem).z_index
	var water := zone.get_node_or_null("Water") as TileMapLayer
	if water != null and not water.get_used_cells().is_empty():
		_layer("PaintedWater", day, k, _cells(water), true).z_index = water.z_index
	var top := zone.get_node_or_null("Overhead") as TileMapLayer
	if top != null and not top.get_used_cells().is_empty():
		_layer("PaintedOverhead", day, k, _cells(top), false).z_index = top.z_index
	var data := info(skin)
	var tint: Array = data.get("night_tint", [1.0, 1.0, 1.0])
	var dawn: Array = data.get("dawn_tint", [0.92, 0.9, 1.06])
	for s in _sprites:
		var m := s.material as ShaderMaterial
		m.set_shader_parameter("night_gain", float(data.get("night_gain", 1.0)))
		m.set_shader_parameter("night_tint", Vector3(float(tint[0]), float(tint[1]), float(tint[2])))
		m.set_shader_parameter("moon_glints", float(data.get("moon_glints", 1.0)))
		m.set_shader_parameter("window_boost", float(data.get("window_boost", 1.0)))
		m.set_shader_parameter("world_px", k)
		m.set_shader_parameter("dawn_tint", Vector3(float(dawn[0]), float(dawn[1]), float(dawn[2])))
		if _dusk != null:
			m.set_shader_parameter("tex_dusk", _dusk)
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


## El color de la hora sobre la pintura de día, y las del atardecer y la noche fundidas según la hora (esas ya traen su
## luz).
func _light() -> void:
	var dn: DayNight = _world.get("day_night") if _world != null else null
	var w := moment_weights(dn.hour(), _dusk != null) if dn != null else Vector2.ZERO
	var daylight := _world.get_node_or_null("Daylight") as CanvasModulate if _world != null else null
	# Con HDR 2D el CanvasModulate multiplica en lineal: la pintura de noche se divide por el mismo color, en lineal.
	var d := daylight.color.srgb_to_linear() if daylight != null else Color.WHITE
	for s in _sprites:
		var m := s.material as ShaderMaterial
		m.set_shader_parameter("night_t", w.y)
		m.set_shader_parameter("dusk_t", w.x)
		m.set_shader_parameter("lights_t", lights_weight(dn.hour()) if dn != null else 0.0)
		m.set_shader_parameter("dawn", dn != null and dn.hour() < 12.0)
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
