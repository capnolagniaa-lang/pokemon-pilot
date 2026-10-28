extends "res://scripts/combat/signatures/body_trait_mechanic.gd"
## Habilidad de un Pokémon (3ª generación, adaptada al tiempo real; decisión del usuario 2026-10-28: la identidad de
## combate sale de la habilidad, el tipo y los ataques que elegís, y los ataques se comportan igual para todos).
## Genérica por parámetros: cada habilidad (data/abilities/<id>.tres, tools/apply_abilities.gd) prende los suyos. Además
## de los de body_trait (immune, thorns, wet_*, regen, shed_every, front/back_mult, perfect_dodge...):
##  · `absorb` {tipo: "immune"|"heal"|"boost"}: los golpes de ese tipo no le hacen nada; "heal" lo cura un 25% de la
##    vida, "boost" le sube un 50% sus ataques de ese tipo por 8 s (Absorbe Agua, Absorbe Fuego, Levitación, Pararrayos).
##  · `element_taken` {tipo: mult}: daño recibido de ese tipo (Sebo: fuego y hielo a la mitad).
##  · `pinch` (tipo): con menos de 1/3 de vida sus ataques de ese tipo pegan ×1,5 (Espesura, Mar Llamas, Torrente...).
##  · `status_atk`: con un problema de estado sus ataques físicos pegan eso (Agallas ×1,5).
##  · `kind_mult` {forma: mult}: más daño con una forma de ataque (Cabeza Roca: embestidas; Vista Lince: disparos).
##  · `contact_status` (+ `contact_chance`; lista = uno al azar): al que le pega cuerpo a cuerpo le pone ese estado
##    (Electricidad Estática, Punto Tóxico, Gran Encanto, Efecto Espora).
##  · `sturdy`: con la vida llena, un golpe que lo mataría lo deja con 1 (Robustez).
##  · `no_stagger`: no sufre el stagger de los golpes (Fuerza Mental).
##  · `intimidate` (estado): le pone ese estado al rival apenas lo encara (Intimidación).
##  · `sync`: los problemas de estado que le ponen se los devuelve al que se los puso (Sincronía).
##  · `flinch_chance`: sus golpes a veces aturden 0,3 s (Hedor).
##  · `aura_status` + `aura_radius`: cada 1,5 s le pone ese estado a los rivales cerca (Trampa Arena).
##  · `cooldown_drain`: cada golpe suyo le suma esos segundos a las recargas del rival (Presión).
##  · `status_chance_mult`: sus ataques con estado lo ponen más seguido (Ojo Compuesto ×1,3; Dicha ×2).
##  · `status_resist`: probabilidad de que no le entre un problema de estado (Polvo Escudo).
##  · `wake_fast`: se despierta solo a los N s (Madrugar).
##  · `evasion`: probabilidad de que un golpe no le entre (Velo Arena).
##  · `knockback`: multiplicador del empuje que recibe (Viscosidad).
##  · `drain_punish`: al que le roba vida con un ataque de drenar, le hace daño (Lodo Líquido).
##  · `dodge_mult`: recarga del esquive (Fuga: más seguido).
##  · `day_speed`: de día se mueve así de rápido (Clorofila).
##  · `on_hit_status` + `on_hit_chance`: sus golpes a veces ponen ese estado (Iluminación: Expuesto).
##  · `pickup`: si gana la pelea, a veces encuentra un objeto (Recogida; solo tu equipo).
##  · `trace`: copia la habilidad del primer rival que encara (Calco).
##  · `type_bonus` {tipo: mult}: más daño a los rivales de ese tipo (Imán: Acero). `speed`: velocidad fija (Impulso).
##  · `status_def`: con un problema de estado recibe eso (Escama Especial ×0,7).

var _boost_left := 0.0
var _boost_type := ""
var _intimidated := {}
var _aura_left := 0.0
var _slept := 0.0
var _traced := false


func _setup() -> void:
	super._setup()
	creature.killed.connect(_on_killed)


# --- Golpes que salen ------------------------------------------------------------------

func modify_hit(hit: HitInfo) -> void:
	super.modify_hit(hit)
	var m := hit.move
	if m == null or m.power <= 0.0:
		return
	var el := m.element.id if m.element != null else ""
	if el != "" and el == param("pinch", "") and creature.health.ratio() < 1.0 / 3.0:
		hit.damage_mult *= 1.5
	if _boost_left > 0.0 and el == _boost_type:
		hit.damage_mult *= 1.5
	var satk: float = param("status_atk", 1.0)
	if satk != 1.0 and m.category == MoveData.Category.PHYSICAL and _has_bad_status():
		hit.damage_mult *= satk
	var kinds: Dictionary = param("kind_mult", {})
	var kname: String = MoveData.Kind.keys()[m.kind]
	if kinds.has(kname):
		hit.damage_mult *= float(kinds[kname])
	var smult: float = param("status_chance_mult", 1.0)
	if smult > 1.0 and m.status != null and m.status_chance > 0.0 and hit.extra_status == null:
		hit.extra_status = m.status
		hit.extra_status_chance = minf(1.0, m.status_chance * (smult - 1.0))
	if data.params.has("on_hit_status") and hit.extra_status == null:
		hit.extra_status = DB.statuses.get(param("on_hit_status", ""))
		hit.extra_status_chance = param("on_hit_chance", 0.2)


func _on_hit_dealt(target: Creature, hit: HitInfo, dealt: float) -> void:
	super._on_hit_dealt(target, hit, dealt)
	if hit == null or not is_instance_valid(target) or target.is_down() or dealt <= 0.0:
		return
	if randf() < param("flinch_chance", 0.0):
		target.stun(0.3)
	var drain: float = param("cooldown_drain", 0.0)
	if drain > 0.0:
		for i in target.moves.cooldowns.size():
			target.moves.cooldowns[i] += drain
			target.moves.cooldown_total[i] = maxf(target.moves.cooldown_total[i], target.moves.cooldowns[i])


# --- Golpes que recibe -----------------------------------------------------------------

func ignores_hit(hit: HitInfo) -> bool:
	if hit == null or hit.move == null:
		return false
	var absorb: Dictionary = param("absorb", {})
	var el := hit.move.element.id if hit.move.element != null else ""
	if absorb.has(el) and hit.move.power > 0.0:
		match absorb[el]:
			"heal":
				creature.health.heal(creature.health.max_hp() * 0.25)
			"boost":
				_boost_left = 8.0
				_boost_type = el
		Events.signature_triggered.emit(creature, "¡%s!" % data.display_name, data.color)
		return true
	if randf() < param("evasion", 0.0) and hit.move.power > 0.0:
		Events.signature_triggered.emit(creature, "¡Esquivó!", data.color)
		return true
	return false


func damage_mult_against(hit: HitInfo, target: Creature) -> float:
	var mult: float = super.damage_mult_against(hit, target)
	var bonus: Dictionary = param("type_bonus", {})
	for t in target.instance.species.types:
		if bonus.has(t.id):
			mult *= float(bonus[t.id])
	return mult


func damage_taken_mult(hit: HitInfo) -> float:
	var mult: float = super.damage_taken_mult(hit)
	if data.params.has("status_def") and _has_bad_status():
		mult *= param("status_def", 1.0)
	var by_type: Dictionary = param("element_taken", {})
	if hit != null and hit.move != null and hit.move.element != null and by_type.has(hit.move.element.id):
		mult *= float(by_type[hit.move.element.id])
	return mult


func lethal_guard(amount: float, _hit: HitInfo) -> float:
	if param("sturdy", false) and creature.health.ratio() >= 0.999 and amount >= creature.health.hp():
		Events.signature_triggered.emit(creature, "¡Robustez!", data.color)
		return maxf(0.0, creature.health.hp() - 1.0)
	return amount


func hitstun_mult() -> float:
	return 0.0 if param("no_stagger", false) else 1.0


func knockback_taken_mult() -> float:
	return param("knockback", 1.0)


func dodge_cooldown_mult() -> float:
	return param("dodge_mult", 1.0)


func blocks_status(s: StatusEffect) -> bool:
	if super.blocks_status(s):
		return true
	return s != null and ItemData.BAD_STATUSES.has(s.id) and randf() < param("status_resist", 0.0)


func _on_damage_received(amount: float, hit: HitInfo) -> void:
	super._on_damage_received(amount, hit)
	if hit == null or hit.move == null or not is_instance_valid(hit.attacker) or hit.attacker == creature:
		return
	var attacker: Creature = hit.attacker
	if hit.move.drain > 0.0 and param("drain_punish", false) and amount > 0.0:
		attacker.take_status_damage(amount * hit.move.drain * 2.0)  # (además de no curarse)
	if data.params.has("contact_status") and hit.move.kind in MELEE_KINDS and randf() < param("contact_chance", 0.3):
		var ids = param("contact_status", "")
		var id: String = ids[randi() % ids.size()] if ids is Array else ids
		if DB.statuses.has(id) and not attacker.is_down():
			attacker.statuses.apply(DB.statuses[id])
	if param("sync", false):
		var before := creature.statuses.active.keys()
		_sync_back.call_deferred(attacker, before)


func _sync_back(attacker: Creature, before: Array) -> void:
	if not is_instance_valid(attacker) or attacker.is_down() or not is_instance_valid(creature):
		return
	for id in creature.statuses.active.keys():
		if not id in before and ItemData.BAD_STATUSES.has(id):
			attacker.statuses.apply(creature.statuses.active[id]["status"])
			Events.signature_triggered.emit(creature, "¡Sincronía!", data.color)


# --- Cada cuadro -----------------------------------------------------------------------

func _tick(delta: float) -> void:
	super._tick(delta)
	_boost_left = maxf(0.0, _boost_left - delta)
	var foe: Creature = creature.target if is_instance_valid(creature.target) and not creature.target.is_down() else null
	if foe != null and param("trace", false) and not _traced and foe.signature != null and foe.signature.data != data:
		_traced = true
		var copy: Dictionary = foe.signature.data.params.duplicate(true)
		copy.erase("trace")
		data = data.duplicate()
		data.params = copy
		Events.signature_triggered.emit(creature, "¡Calco: %s!" % foe.signature.data.display_name, data.color)
	var intim: String = param("intimidate", "")
	if foe != null and intim != "" and not _intimidated.has(foe) \
			and foe.global_position.distance_to(creature.global_position) < 160.0 and DB.statuses.has(intim):
		_intimidated[foe] = true
		foe.statuses.apply(DB.statuses[intim])
		Events.signature_triggered.emit(creature, "¡Intimidación!", data.color)
	if data.params.has("aura_status"):
		_aura_left -= delta
		if _aura_left <= 0.0:
			_aura_left = 1.5
			for c in creature.get_tree().get_nodes_in_group("creatures"):
				if c != creature and c.team != creature.team and not c.is_down() \
						and c.global_position.distance_to(creature.global_position) < param("aura_radius", 60.0):
					c.statuses.apply(DB.statuses[param("aura_status", "ralentizado")])
	var wake: float = param("wake_fast", 0.0)
	if wake > 0.0 and creature.statuses.has_status("dormido"):
		_slept += delta
		if _slept >= wake:
			creature.statuses.cure(DB.statuses["dormido"])
			Events.signature_triggered.emit(creature, "¡Madrugar!", data.color)
	else:
		_slept = 0.0


func speed_mult() -> float:
	var m: float = super.speed_mult() * param("speed", 1.0)
	var day: float = param("day_speed", 1.0)
	if day != 1.0:
		var world := creature.get_tree().get_first_node_in_group("world")
		var dn = world.get("day_night") if world != null else null
		if dn == null or dn.darkness < 0.3:
			m *= day
	return m


func _on_killed(_target: Creature) -> void:
	if param("pickup", false) and creature.team == Creature.Team.ALLY and not creature.ai_fighter and randf() < 0.1:
		GameState.add_item("pocion", 1)
		Events.message_requested.emit("¡%s encontró una Poción! (Recogida)" % creature.instance.display_name())


func _has_bad_status() -> bool:
	return creature.statuses.active.keys().any(func(id): return ItemData.BAD_STATUSES.has(id))


func state_label() -> String:
	if _boost_left > 0.0:
		return "%s ×1,5" % _boost_type.to_upper()
	if param("pinch", "") != "" and creature.health.ratio() < 1.0 / 3.0:
		return data.display_name.to_upper()
	return super.state_label()
