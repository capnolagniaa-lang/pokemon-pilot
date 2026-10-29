class_name MoveInfo
extends RefCounted
## Qué hace un ataque, en palabras (pedido del usuario 2026-10-28). Sale de cómo funciona en tiempo real (MoveData:
## forma, carga, combo, zona, estados...), así siempre coincide con lo que pasa en la pelea. Lo usan la ficha
## (Movimientos), la pantalla de aprender un ataque y la Pokédex.


## Una o dos oraciones: cómo se usa y qué hace.
static func what_it_does(m: MoveData) -> String:
	if m == null:
		return ""
	var s: Array[String] = []
	match m.kind:
		MoveData.Kind.PROJECTILE:
			if m.projectile_count > 1:
				s.append("Dispara un abanico de %d proyectiles hacia donde apuntás." % m.projectile_count)
			else:
				s.append("Dispara un proyectil hacia donde apuntás.")
		MoveData.Kind.DASH:
			if m.dash_hits:
				s.append("Te lanzás hacia donde apuntás y golpeás a lo que encontrés en el camino.")
			else:
				s.append("Te desplazás rápido hacia donde apuntás (no pega: sirve para escapar o acercarte).")
			if m.invulnerable_time > 0.0:
				s.append("Mientras dura no te pueden golpear.")
			if m.trail_duration > 0.0:
				s.append("Deja una estela en el suelo que lastima a los que la pisan.")
		MoveData.Kind.AREA:
			s.append("Suelta una onda a tu alrededor que golpea a todos los que estén cerca.")
		MoveData.Kind.SHIELD:
			s.append("Te cubrís durante %.1f s: los golpes te hacen un %d%% del daño." % [m.duration, roundi(Health.SHIELD_FACTOR * 100.0)])
		MoveData.Kind.MELEE:
			s.append("Golpe cuerpo a cuerpo: das un paso hacia donde apuntás y pegás.")
			if m.combo_steps > 1:
				s.append("Apretalo seguido para encadenar %d golpes; el último empuja más." % m.combo_steps)
		MoveData.Kind.ZONE:
			if m.zone_strike and m.strike_burrow:
				s.append("Te metés bajo tierra (no te pueden pegar) y salís golpeando donde apuntás.")
			elif m.zone_strike:
				s.append("Marca un círculo donde apuntás y enseguida cae el golpe" + (" (%d veces, alrededor)." % m.strike_count if m.strike_count > 1 else "."))
			elif m.zone_traps:
				s.append("Crea una zona donde apuntás que encierra %.0f s a los que quedan adentro." % m.zone_duration)
			else:
				s.append("Deja una nube o parche donde apuntás durante %.0f s que afecta a los rivales que estén adentro." % m.zone_duration)
		MoveData.Kind.CHANNEL:
			s.append("Lo sostenés %.1f s soltando un chorro en cono hacia adelante que pega varias veces." % m.channel_time)
		MoveData.Kind.LUNGE:
			s.append("Saltás hacia el punto apuntado; si conectás, encadenás un segundo golpe.")
		MoveData.Kind.WHIP:
			s.append("Un látigo en línea recta que agarra al primero que alcanza.")
		MoveData.Kind.SELF_BUFF:
			if m.self_status != null:
				s.append("Te da %s por %.0f s: %s." % [m.self_status.display_name, m.self_status.duration, status_text(m.self_status)])
			else:
				s.append("Te mejora por un rato.")
	if m.cast_time > 0.0:
		s.append("Hay que cargarlo un momento antes de que salga (un golpe fuerte lo corta).")
	if m.power <= 0.0 and m.kind not in [MoveData.Kind.SHIELD, MoveData.Kind.SELF_BUFF] and m.status == null \
			and m.statuses_on_hit.is_empty() and m.dwell_status == null:
		s.append("No hace daño.")
	if m.status != null and m.status_chance > 0.0:
		s.append("Puede dejar %s (%d%%): %s." % [m.status.display_name, roundi(m.status_chance * 100.0), status_text(m.status)])
	for st in m.statuses_on_hit:
		s.append("Deja %s: %s." % [st.display_name, status_text(st)])
	if m.dwell_status != null:
		s.append("Si alguien se queda %.1f s adentro, queda %s." % [m.dwell_time, m.dwell_status.display_name])
	if m.knockback < 0.0:
		s.append("Atrae al rival hacia vos.")
	elif m.knockback >= 240.0:
		s.append("Empuja lejos.")
	if m.recovery >= 0.35:  # solo si se nota (casi todos tienen un poquito)
		s.append("Después quedás expuesto un instante.")
	return " ".join(s)


## Qué le hace un estado al que lo tiene (sale de sus números).
static func status_text(st: StatusEffect) -> String:
	var out: Array[String] = []
	if st.damage_per_second > 0.0:
		out.append("pierde vida de a poco")
	if st.heal_per_second > 0.0:
		out.append("recupera vida de a poco")
	if not st.can_act and not st.can_move:
		out.append("no puede moverse ni atacar")
	elif not st.can_act:
		out.append("no puede atacar")
	elif not st.can_move:
		out.append("no puede moverse")
	if st.speed_mult < 1.0:
		out.append("va más lento")
	elif st.speed_mult > 1.0:
		out.append("va más rápido")
	if st.attack_mult < 1.0:
		out.append("pega menos")
	elif st.attack_mult > 1.0:
		out.append("pega más")
	if st.damage_taken_mult > 1.0:
		out.append("recibe más daño")
	elif st.damage_taken_mult < 1.0:
		out.append("recibe menos daño")
	if st.jolt_interval > 0.0:
		out.append("se traba de a ratos")
	if st.aim_jitter_deg > 0.0:
		out.append("apunta peor")
	if st.heal_mult < 1.0:
		out.append("se cura menos")
	if st.knockback_mult < 1.0:
		out.append("lo empujan menos")
	if st.buildup:
		out.append("si se le acumula, queda aturdido")
	if st.wake_on_damage:
		out.append("se le pasa si le pegan")
	if out.is_empty():
		return "lo afecta un rato"
	return ", ".join(out)
