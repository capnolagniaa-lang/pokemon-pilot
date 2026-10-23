extends SignatureMechanic
## Deslizamiento (Poliwag, velocista acuático): sobre el agua o el suelo mojado se mueve más rápido
## (`speed_bonus`) y esquiva más seguido (`dodge_mult` de la recarga). Danza Lluvia moja el piso a su alrededor
## para armarse la cancha. Sin barra.

var _wet := false
var _check := 0.0


func _tick(delta: float) -> void:
	_check -= delta
	if _check > 0.0:
		return
	_check = 0.15
	var world := creature.get_tree().get_first_node_in_group("world")
	var tags: PackedStringArray = world.tags_at(creature.global_position) if world != null else PackedStringArray()
	_wet = creature.swims or tags.has("mojado") or tags.has("agua")


func speed_mult() -> float:
	return param("speed_bonus", 1.4) if _wet else 1.0


func dodge_cooldown_mult() -> float:
	return param("dodge_mult", 0.5) if _wet else 1.0


func state_label() -> String:
	return "DESLIZANDO" if _wet else ""
