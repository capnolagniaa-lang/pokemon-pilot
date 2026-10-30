class_name ZoneShadows
extends ColorRect
## Sombras largas de lo que hay en el mapa (casas, árboles, cercas, carteles, rocas) según el sol
## (docs/PLAN_DIA_NOCHE.md parte B). World la agrega a cada zona exterior al cargarla.
## Al armarse, dibuja una máscara de la zona a partir de las celdas sólidas del TileSet (no los salientes ni el
## agua): la altura sale del largo de la columna de celdas sólidas (una cerca = 1, una casa = 4 o más) y los
## árboles van redondos. El shader (shaders/sun_shadows.gdshader) estira esa silueta hacia el lado contrario al sol,
## con la dirección, el largo y la opacidad que da DayNight. Se dibuja sobre el suelo y el pasto, debajo de todo lo
## demás.

const SHADER := preload("res://shaders/sun_shadows.gdshader")
const MASK_PX := 4          # píxeles de máscara por celda
const BASE_LENGTH := 26.0   # largo (px) de la sombra de algo de altura 1 al mediodía
const MAX_RUN := 4          # celdas sólidas en columna para la altura máxima
const TREE_HEIGHT := 0.8
const PAINTED_ALPHA := 0.6
const PAINTED_SOFTEN := 5.0
const Z := -7               # junto a TreeShadows: sobre Ground, Water y Foliage; debajo de todo lo demás

var _world: Node


static func attach(zone: Node2D, entry: ZoneEntry, world: WorldData) -> ZoneShadows:
	var old := zone.get_node_or_null("SunShadows")
	if old != null:
		old.free()
	if entry.interior:
		return null
	var node := ZoneShadows.new()
	node.name = "SunShadows"
	node.size = Vector2(entry.size * world.tile_size)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.z_index = Z
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("mask", ImageTexture.create_from_image(build_mask(zone, entry)))
	mat.set_shader_parameter("zone_px", node.size)
	node.material = mat
	zone.add_child(node)
	return node


## Máscara de la zona (MASK_PX por celda): R altura, G proyecta, B ocupado.
static func build_mask(zone: Node2D, entry: ZoneEntry) -> Image:
	var w := entry.size.x
	var h := entry.size.y
	var solid := PackedByteArray()
	solid.resize(w * h)
	var tree := PackedByteArray()
	tree.resize(w * h)
	var none := {}
	for y in h:
		for x in w:
			var c := Vector2i(x, y)
			if MapRules.cell_physics(zone, c, none) != MapRules.SOLID:
				continue
			var tags: PackedStringArray = zone.get_tags(c)
			if "saliente" in tags or "agua" in tags:
				continue
			solid[y * w + x] = 1
			if "arbol" in tags:
				tree[y * w + x] = 1
	var img := Image.create(w * MASK_PX, h * MASK_PX, false, Image.FORMAT_RGBA8)
	for x in w:
		var y := 0
		while y < h:
			if solid[y * w + x] == 0:
				y += 1
				continue
			var y0 := y
			while y < h and solid[y * w + x] == 1:
				y += 1
			var height := clampf(float(y - y0) / MAX_RUN, 0.25, 1.0)
			for yy in range(y0, y):
				var cell_rect := Rect2i(x * MASK_PX, yy * MASK_PX, MASK_PX, MASK_PX)
				if tree[yy * w + x] == 1:
					_tree(img, cell_rect, maxf(height, TREE_HEIGHT))
				else:
					img.fill_rect(cell_rect, Color(height, 1.0, 1.0, 1.0))
	return img


## Árbol: la celda entera ocupada (no se oscurece) y una silueta redonda que proyecta.
static func _tree(img: Image, r: Rect2i, height: float) -> void:
	var center := Vector2(r.position) + Vector2(r.size) / 2.0
	var radius := MASK_PX * 0.62
	for py in range(r.position.y, r.end.y):
		for px in range(r.position.x, r.end.x):
			var inside := Vector2(px + 0.5, py + 0.5).distance_to(center) <= radius
			img.set_pixel(px, py, Color(height, 1.0 if inside else 0.35, 1.0, 1.0))


func _ready() -> void:
	_world = get_tree().get_first_node_in_group("world")


func _process(_delta: float) -> void:
	var dn: DayNight = _world.get("day_night") if _world != null else null
	visible = dn != null and dn.casts_shadows and dn.shadow_alpha > 0.0
	if not visible:
		return
	var m := material as ShaderMaterial
	m.set_shader_parameter("dir", dn.shadow_direction)
	m.set_shader_parameter("len_px", BASE_LENGTH * dn.shadow_length)
	# Con una skin (PaintedZone) la pintura ya trae su sombra suave al pie de las cosas: la del sol va más suave y clara.
	var pz := get_parent().get_node_or_null("PaintedZone")
	var painted: bool = pz != null and pz.get_node_or_null("PaintedGround") != null
	m.set_shader_parameter("alpha", dn.shadow_alpha * (PAINTED_ALPHA if painted else 1.0))
	m.set_shader_parameter("soften", PAINTED_SOFTEN if painted else 0.0)
	m.set_shader_parameter("shadow_color", Vector3(dn.shadow_color.r, dn.shadow_color.g, dn.shadow_color.b))
