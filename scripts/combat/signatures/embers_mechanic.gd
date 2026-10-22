extends SignatureMechanic
## Rescoldo (Vulpix, desgaste de quemaduras): sus golpes contra enemigos **quemados** pegan
## `burned_damage_mult` más y renuevan la quemadura, así el fuego no se apaga mientras lo siga castigando.
## Gana quemando de a poco (Fuego Fatuo asegura la quemadura) en vez de con golpes grandes.
## Sin barra: el estado muestra cuántos enemigos cercanos están quemados.


func damage_mult_against(_hit: HitInfo, target: Creature) -> float:
	if not target.statuses.has_status("quemado"):
		return 1.0
	target.statuses.apply(DB.statuses.get("quemado"))  # renueva la quemadura
	return param("burned_damage_mult", 1.35)


func burned_nearby() -> int:
	var n := 0
	for c in creature.get_tree().get_nodes_in_group("creatures"):
		if c.team != creature.team and not c.is_down() and c.statuses.has_status("quemado") \
				and c.global_position.distance_to(creature.global_position) <= 260.0:
			n += 1
	return n


func state_label() -> String:
	var n := burned_nearby()
	return "" if n == 0 else ("1 QUEMADO" if n == 1 else "%d QUEMADOS" % n)
