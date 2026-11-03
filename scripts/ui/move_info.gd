class_name MoveInfo
extends RefCounted
## Qué hace un ataque, en palabras (pedido del usuario 2026-10-28). Sale de cómo funciona en tiempo real (MoveData:
## forma, carga, combo, zona, estados...), así siempre coincide con lo que pasa en la pelea. Lo usan la ficha
## (Movimientos), la pantalla de aprender un ataque y la Pokédex.


## Una o dos oraciones: cómo se usa y qué hace.
static func what_it_does(m: MoveData) -> String:
	if m == null:
		return ""
	if m.does_nothing():
		return "Todavía no hace nada en combate: el efecto que tiene en los juegos no está hecho acá."
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
			elif m.weather == "":
				s.append("Te mejora por un rato.")
	if m.cast_time > 0.0:
		s.append("Hay que cargarlo un momento antes de que salga (un golpe fuerte lo corta).")
	if m.power <= 0.0 and m.kind not in [MoveData.Kind.SHIELD, MoveData.Kind.SELF_BUFF] and m.status == null \
			and m.statuses_on_hit.is_empty() and m.dwell_status == null and m.pp_drain <= 0.0 and not m.pain_split:
		s.append("No hace daño.")
	if m.status != null and m.status_chance > 0.0:
		s.append("Puede dejar %s (%d%%): %s." % [m.status.display_name, roundi(m.status_chance * 100.0), status_text(m.status)])
	for st in m.statuses_on_hit:
		s.append("Deja %s por %.0f s: %s." % [st.display_name, st.duration, status_text(st)])
	if m.dwell_status != null:
		s.append("Si alguien se queda %.1f s adentro, queda %s." % [m.dwell_time, m.dwell_status.display_name])
	match m.weather:
		"lluvia":
			s.append("Llueve %d s: el Agua pega un 50 %% más, el Fuego la mitad y los que pelean quedan empapados." % CombatWeather.DURATION)
		"sol":
			s.append("Sol fuerte %d s: el Fuego pega un 50 %% más y el Agua la mitad." % CombatWeather.DURATION)
		"granizo":
			s.append("Graniza %d s: los que pelean pierden un 2 %% de vida por segundo, salvo los tipo Hielo." % CombatWeather.DURATION)
		"arena":
			s.append("Tormenta de arena %d s: los que pelean pierden un 2 %% de vida por segundo, salvo los tipos Roca, Tierra y Acero." % CombatWeather.DURATION)
	if m.pp_drain > 0.0:
		s.append("Le saca el %s de su barra de PP." % _pct(m.pp_drain))
	if m.pain_split:
		s.append("Los dos quedan con la misma vida: el promedio entre la tuya y la suya.")
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
		out.append("pierde un %s de su vida por segundo" % _pct(st.damage_per_second))
		if st.leech > 0.0:
			out.append("y esa vida te la pasa a vos")
	if st.heal_per_second > 0.0:
		out.append("recupera un %s de su vida por segundo" % _pct(st.heal_per_second))
	if not st.can_act and not st.can_move:
		out.append("no puede moverse ni atacar")
	elif not st.can_act:
		out.append("no puede atacar")
	elif not st.can_move:
		out.append("no puede moverse")
	if st.speed_mult < 1.0:
		out.append("va un %s más lento" % _pct(1.0 - st.speed_mult))
	elif st.speed_mult > 1.0:
		out.append("va un %s más rápido" % _pct(st.speed_mult - 1.0))
	if st.attack_mult < 1.0:
		out.append("sus golpes físicos pegan un %s menos" % _pct(1.0 - st.attack_mult))
	elif st.attack_mult > 1.0:
		out.append("sus golpes físicos pegan un %s más" % _pct(st.attack_mult - 1.0))
	if st.damage_taken_mult > 1.0:
		out.append("recibe un %s más de daño" % _pct(st.damage_taken_mult - 1.0))
	elif st.damage_taken_mult < 1.0:
		out.append("recibe un %s menos de daño" % _pct(1.0 - st.damage_taken_mult))
	if st.jolt_interval > 0.0:
		out.append("se traba de a ratos")
	if st.aim_jitter_deg > 0.0:
		out.append("apunta peor")
	if st.heal_mult < 1.0:
		out.append("se cura menos")
	if st.knockback_mult < 1.0:
		out.append("lo empujan menos")
	if st.no_status_moves:
		out.append("no puede usar ataques de estado")
	if st.no_repeat:
		out.append("no puede repetir el mismo ataque dos veces seguidas")
	if st.no_dodge:
		out.append("no puede esquivar")
	if st.traps:
		out.append("no puede huir ni cambiarse")
	if st.only_while != "" and DB.statuses.has(st.only_while):
		out.append("solo si está %s" % DB.statuses[st.only_while].display_name.to_lower())
	if st.buildup:
		out.append("si se le acumula, queda aturdido")
	if st.wake_on_damage:
		out.append("se le pasa si le pegan")
	if out.is_empty():
		return "lo afecta un rato"
	var text := ", ".join(out).replace(", y esa", " y esa")
	if not st.immune_types.is_empty():
		var names: Array[String] = []
		for t in st.immune_types:
			names.append(DB.types[t].display_name if DB.types.has(t) else t.capitalize())
		text += " (a los de tipo %s no les hace nada)" % ", ".join(names)
	return text


static func _pct(f: float) -> String:
	return "%d %%" % roundi(f * 100.0)
