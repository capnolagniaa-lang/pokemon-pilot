class_name Hitbox
extends Area2D
## Zona que golpea hurtboxes del equipo contrario (una vez por objetivo).

signal hit_landed(hurtbox: Hurtbox)

var hit: HitInfo
var _already: Array = []


## Configura las capas para golpear al equipo contrario. Con hits_world también detecta paredes (capa 1).
func setup(p_hit: HitInfo, hits_world: bool = false) -> void:
	hit = p_hit
	collision_layer = 0
	collision_mask = (Hurtbox.LAYER_WILD if hit.team == 0 else Hurtbox.LAYER_ALLY) | (1 if hits_world else 0)
	monitoring = true
	monitorable = false
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func reset_targets() -> void:
	_already.clear()


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not _already.has(area):
		_already.append(area)
		area.receive(hit)
		hit_landed.emit(area)
