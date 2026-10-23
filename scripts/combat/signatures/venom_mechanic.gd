extends SignatureMechanic
## Aguijón venenoso (Weedle, asesino): le pega más a lo que está envenenado, un `per_stack` más por cada stack de
## Envenenado del rival (hasta ×`max_mult`). Sin barra.


func damage_mult_against(_hit: HitInfo, target: Creature) -> float:
	var n := target.statuses.stacks("envenenado")
	return minf(1.0 + param("per_stack", 0.1) * n, param("max_mult", 1.5))


func state_label() -> String:
	var t = creature.target
	if is_instance_valid(t) and t.statuses.stacks("envenenado") > 0:
		return "VENENO ×%d" % t.statuses.stacks("envenenado")
	return ""
