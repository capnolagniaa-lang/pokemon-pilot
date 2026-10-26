extends SignatureMechanic
## Rasgos del cuerpo (genérica por parámetros; docs/PROPUESTA_KITS_PENDIENTES.md). Cada uno se prende con su parámetro:
##  · `immune` (lista de estados): no los recibe (Zubat es ciego: no lo desorientan; Machop no se deja frenar).
##  · `drain_bonus_status` + `drain_bonus`: sus golpes que drenan curan `drain_bonus` más del daño contra un rival con
##    ese estado (Zubat: el desorientado por Supersónico).
##  · `thorns` (fracción) + `thorns_status`: al que le pega cuerpo a cuerpo le devuelve esa parte del daño y le aplica
##    el estado (Nidoran♀); con `thorns_boost_status` activo, `thorns_boosted` y el estado seguro.
##  · `bonus_vs_status` + `bonus_move_prefix` + `bonus_mult`: un ataque pega más contra un estado (Mordisco ×1,5 a lo
##    envenenado).
##  · `melee_cooldown_cut`: cada golpe cuerpo a cuerpo que conecta baja esos segundos todas sus recargas (Machop).
##  · `front_mult` / `back_mult`: daño recibido de frente y de espaldas según hacia dónde mira (Shellder).
##  · `wet_heal` (fracción por s) + `dry_speed`: sobre agua o suelo mojado se cura; en seco va más lento (Tentacool).
##  · `perfect_dodge` (s): esquivar con un golpe rival a punto de llegar recarga la ranura `perfect_slot` y deja el
##    próximo golpe crítico (`crit_mult`) (Nidoran♂).

const MELEE_KINDS := [MoveData.Kind.MELEE, MoveData.Kind.LUNGE, MoveData.Kind.DASH, MoveData.Kind.WHIP]

var _crit_ready := false
var _wet := false


func _setup() -> void:
	creature.hit_dealt.connect(_on_hit_dealt)
	creature.damage_received.connect(_on_damage_received)
	creature.dodged.connect(_on_dodged)


func _on_hit_dealt(target: Creature, hit: HitInfo, dealt: float) -> void:
	if hit == null or hit.move == null:
		return
	var st: String = param("drain_bonus_status", "")
	if st != "" and hit.move.drain > 0.0 and dealt > 0.0 and is_instance_valid(target) and target.statuses.has_status(st):
		creature.health.heal(dealt * hit.move.drain * param("drain_bonus", 1.0))
	var cut: float = param("melee_cooldown_cut", 0.0)
	if cut > 0.0 and hit.move.kind in MELEE_KINDS:
		for i in creature.moves.cooldowns.size():
			creature.moves.cooldowns[i] = maxf(0.0, creature.moves.cooldowns[i] - cut)


func _on_damage_received(amount: float, hit: HitInfo) -> void:
	var k: float = param("thorns", 0.0)
	if k <= 0.0 or hit == null or hit.move == null or not hit.move.kind in MELEE_KINDS:
		return
	var attacker = hit.attacker
	if not is_instance_valid(attacker) or attacker == creature or attacker.is_down():
		return
	var boosted: bool = creature.statuses.has_status(param("thorns_boost_status", ""))
	attacker.health.apply_damage(amount * (param("thorns_boosted", k) if boosted else k))
	var st: StatusEffect = DB.statuses.get(param("thorns_status", ""))
	if st != null and (boosted or randf() < param("thorns_chance", 0.5)):
		attacker.statuses.apply(st)


func _on_dodged() -> void:
	var window: float = param("perfect_dodge", 0.0)
	if window <= 0.0 or not _threat_incoming(window):
		return
	_crit_ready = true
	var slot: int = param("perfect_slot", -1)
	if slot >= 0:
		creature.moves.reset_cooldown(slot)
	Events.signature_triggered.emit(creature, param("perfect_text", "¡Esquive perfecto!"), data.color)


## Un golpe rival a punto de llegar: un proyectil que le viene encima o un rival embistiendo/golpeando muy cerca.
func _threat_incoming(window: float) -> bool:
	for n in creature.get_parent().get_children():
		if n is Projectile and n.hit != null and n.hit.team != creature.team:
			var rel: Vector2 = creature.global_position - n.global_position
			if n.velocity.dot(rel) > 0.0 and rel.length() <= n.velocity.length() * window + 12.0:
				return true
		elif n is Creature and n != creature and n.team != creature.team and not n.is_down() \
				and n.global_position.distance_to(creature.global_position) < 40.0 \
				and n.machine.current_name() in ["dash", "lunge", "attack"] and n.target == creature:
			return true
	return false


func modify_hit(hit: HitInfo) -> void:
	if _crit_ready and hit.move.power > 0.0:
		_crit_ready = false
		hit.damage_mult *= param("crit_mult", 1.5)
		Events.signature_triggered.emit(creature, "¡Crítico!", data.color)


func damage_mult_against(hit: HitInfo, target: Creature) -> float:
	var st: String = param("bonus_vs_status", "")
	if st != "" and hit.move.id.begins_with(param("bonus_move_prefix", "")) and target.statuses.has_status(st):
		return param("bonus_mult", 1.5)
	return 1.0


func damage_taken_mult(hit: HitInfo) -> float:
	if not data.params.has("front_mult") or hit == null or not is_instance_valid(hit.attacker):
		return 1.0
	var from: Vector2 = (hit.attacker.global_position - creature.global_position).normalized()
	var d := from.dot(creature.facing.normalized())
	if d > 0.3:
		return param("front_mult", 1.0)
	if d < -0.3:
		return param("back_mult", 1.0)
	return 1.0


func _tick(delta: float) -> void:
	var heal: float = param("wet_heal", 0.0)
	if heal <= 0.0:
		return
	var world := creature.get_tree().get_first_node_in_group("world")
	_wet = false
	if world != null:
		var tags: PackedStringArray = world.tags_at(creature.global_position) if world.has_method("tags_at") else PackedStringArray()
		var st = world.reactions.state_at(creature.global_position) if world.get("reactions") != null else null
		_wet = tags.has("agua") or creature.swims or (st != null and st.id == "mojado") \
			or creature.statuses.has_status("empapado")
	if _wet and not creature.is_down():
		creature.health.heal(creature.health.max_hp() * heal * delta)


func speed_mult() -> float:
	return param("dry_speed", 1.0) if data.params.has("wet_heal") and not _wet else 1.0


func state_label() -> String:
	if _crit_ready:
		return "CRÍTICO LISTO"
	if data.params.has("wet_heal"):
		return "MOJADO" if _wet else "SECO"
	return ""
