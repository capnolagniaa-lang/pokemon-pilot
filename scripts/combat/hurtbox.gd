class_name Hurtbox
extends Area2D
## Zona donde una criatura puede recibir golpes. Su capa depende del equipo (6 aliada, 7 salvaje).

const LAYER_ALLY := 1 << 5
const LAYER_WILD := 1 << 6

signal hit_received(hit: HitInfo)


func set_team(team: int) -> void:
	collision_layer = LAYER_ALLY if team == 0 else LAYER_WILD
	collision_mask = 0
	monitoring = false
	monitorable = true


func receive(hit: HitInfo) -> void:
	hit_received.emit(hit)
