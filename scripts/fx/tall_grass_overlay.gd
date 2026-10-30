extends Sprite2D
## Cuando el personaje está en pasto alto, dibuja el frente del pasto sobre sus piernas
## y suelta hojitas al entrar a cada mata nueva. En una zona dibujada con un paquete de estilo (StyleOverlay), el pasto
## es la mata del paquete y no el tile de FireRed.

const TILE := 16
const GRASS_METATILE := 13
## Cuántos píxeles del pasto (desde abajo) tapan al personaje.
const COVER := 9

var _last_cell := Vector2i(1 << 30, 0)
var _world: Node


var _fire_texture: Texture2D
var _styled: Texture2D


func _ready() -> void:
	_fire_texture = load("res://art/pret/tiles/general_below.png")
	_use_fire()
	region_enabled = true
	centered = false
	top_level = true
	z_index = 1
	visible = false


func _physics_process(_delta: float) -> void:
	if _world == null:
		_world = get_tree().get_first_node_in_group("world")
		if _world == null:
			return
	var feet: Vector2 = get_parent().global_position
	var in_grass: bool = _world.tags_at(feet).has("pasto_alto")
	visible = in_grass
	if not in_grass:
		_last_cell = Vector2i(1 << 30, 0)
		return
	var cell := Vector2i((feet / TILE).floor())
	var ov := StyleOverlay.at(_world, feet)
	var styled := StyleOverlay.texture("pasto_alto") if ov != null else null
	if styled == null:
		_use_fire()
	elif styled != _styled:
		_styled = styled
		texture = styled
		var k := float(styled.get_width()) / TILE  # píxeles de la mata por píxel del mundo (4 en HD)
		region_rect = Rect2(0, styled.get_height() - COVER * k, styled.get_width(), COVER * k)
		scale = Vector2.ONE / k
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if k > 1.0 else CanvasItem.TEXTURE_FILTER_PARENT_NODE
	global_position = Vector2(cell * TILE) + Vector2(0, TILE - COVER)
	if cell != _last_cell:
		_last_cell = cell
		_rustle(Vector2(cell * TILE) + Vector2(TILE / 2.0, TILE - 4))


func _use_fire() -> void:
	if texture == _fire_texture:
		return
	_styled = null
	texture = _fire_texture
	scale = Vector2.ONE
	texture_filter = CanvasItem.TEXTURE_FILTER_PARENT_NODE
	region_rect = Rect2((GRASS_METATILE % 16) * TILE, (GRASS_METATILE / 16) * TILE + TILE - COVER, TILE, COVER)


func _rustle(at: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = 7
	p.lifetime = 0.45
	p.explosiveness = 0.9
	p.direction = Vector2.UP
	p.spread = 70.0
	p.initial_velocity_min = 25.0
	p.initial_velocity_max = 45.0
	p.gravity = Vector2(0, 160)
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.0
	p.color = Color(0.45, 0.78, 0.36)
	p.z_index = 2
	p.global_position = at
	get_tree().current_scene.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)
