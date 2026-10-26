extends SignatureMechanic
## Gas Inflamable (Koffing, trampero; docs/PROPUESTA_KITS_PENDIENTES.md): sus nubes (zonas con `zone_flammable`) se
## prenden con cualquier fuego que las toque (un Ascuas tuyo, el de un Charmander rival...). Su ataque `detonate_move`
## (Detonar) las hace explotar **todas a la vez** (`GroundZone.ignite`), estén donde estén, con temblor de pantalla.
## La barra muestra cuántas nubes suyas hay en la cancha.


func _on_move_released(m: MoveData) -> void:
	if not m.id.begins_with(param("detonate_move", "detonar")):
		return
	var n := 0
	for z in _clouds():
		z.ignite()
		n += 1
	if n > 0:
		Events.camera_shake.emit(4.0 + n)
		Events.signature_triggered.emit(creature, "¡Detonación ×%d!" % n, data.color)


func _clouds() -> Array:
	var out := []
	for z in creature.get_parent().get_children():
		if z is GroundZone and not z.burning and not z._expiring and z.hit != null and z.hit.attacker == creature \
				and z.hit.move.zone_flammable:
			out.append(z)
	return out


func _can_decay() -> bool:
	return false


func _tick(_delta: float) -> void:
	set_value(minf(data.max_value, _clouds().size() * data.max_value / float(param("max_clouds", 3))))


func state_label() -> String:
	var n := _clouds().size()
	return "NUBES ×%d" % n if n > 0 else ""
