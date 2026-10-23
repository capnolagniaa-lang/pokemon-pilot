extends SignatureMechanic
## Esporas (Oddish, desgaste): sus ataques dejan esporas en el rival (estado `esporas`, se acumula hasta 5; lo
## ponen los ataques con statuses_on_hit). El ataque con id `bloom_move` (Florecer) las hace florecer en todos los
## enemigos cercanos: 1+ envenena, 3+ paraliza, 5 duerme. Oddish se cura `heal_per_spore` por cada espora.
## Sin barra: el estado dice cuántas esporas tiene el rival actual.


func _on_move_released(m: MoveData) -> void:
	if m.id != param("bloom_move", "florecer"):
		return
	var total := 0
	for c in creature.get_tree().get_nodes_in_group("creatures"):
		if c.team == creature.team or c.is_down() or c.global_position.distance_to(creature.global_position) > param("radius", 150.0):
			continue
		var n: int = c.statuses.stacks("esporas")
		if n <= 0:
			continue
		total += n
		c.statuses.cure(DB.statuses["esporas"])
		c.statuses.apply(DB.statuses["envenenado"])
		if n >= 3:
			c.statuses.apply(DB.statuses["paralizado"])
			c.statuses.apply(DB.statuses["paralizado"])
		if n >= 5:
			c.statuses.apply(DB.statuses["dormido"])
		Fx.burst(c.get_parent(), c.global_position + Vector2(0, -8), Color(0.9, 0.6, 1.3), 6 + n * 2, 40.0)
	if total > 0:
		creature.health.heal(creature.health.max_hp() * param("heal_per_spore", 0.03) * total)
		Events.signature_triggered.emit(creature, "¡Florecer! ×%d" % total, data.color)


func state_label() -> String:
	var t: Creature = creature.target
	var n: int = t.statuses.stacks("esporas") if is_instance_valid(t) else 0
	return "%d ESPORAS" % n if n > 0 else ""
