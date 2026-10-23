extends SignatureMechanic
## Rastreo (Growlithe, perseguidor): sus golpes marcan al rival (estado `rastreado`, lo ponen los ataques con
## statuses_on_hit). Mientras su objetivo está marcado, corre más rápido (`speed_bonus`) y le pega más
## (`damage_bonus`). Sin barra.


func _target_marked() -> bool:
	var t: Creature = creature.target
	if not is_instance_valid(t):
		# Tu Pokémon (sin target de IA): el enemigo marcado más cercano cuenta.
		for c in creature.get_tree().get_nodes_in_group("creatures"):
			if c.team != creature.team and not c.is_down() and c.statuses.has_status("rastreado") \
					and c.global_position.distance_to(creature.global_position) < 220.0:
				return true
		return false
	return t.statuses.has_status("rastreado")


func damage_mult_against(_hit: HitInfo, target: Creature) -> float:
	return param("damage_bonus", 1.25) if target.statuses.has_status("rastreado") else 1.0


func speed_mult() -> float:
	return param("speed_bonus", 1.25) if in_combat() and _target_marked() else 1.0


func state_label() -> String:
	return "RASTREANDO" if in_combat() and _target_marked() else ""
