class_name KitsV3Tests
extends Node
## Autotest de los 10 kits nuevos (v3, docs/PLAN_IDENTIDAD_COMBATE.md):
##   godot --headless --path . --quit-after 60000 -- --autotest-kits-v3
## Cada kit: 4 ataques que se usan sin errores + su mecánica de firma.

const SPECIES := {"squirtle": "tanque", "pikachu": "velocista", "oddish": "desgaste", "paras": "control",
	"psyduck": "caotico", "poliwag": "velocista", "growlithe": "perseguidor", "eevee": "adaptativo", "seel": "tanque",
	"geodude": "tanque"}

var autotest: Node
var world: Node
var me: Creature


func run() -> void:
	var r := {}
	for id in SPECIES:
		var sp: SpeciesData = DB.species[id]
		r["%s: kit %s con 4 ataques" % [sp.display_name, SPECIES[id]]] = sp.kit != null and sp.kit.archetype == SPECIES[id] \
			and sp.kit.moves.size() == 4
	r["16 especies con kit"] = DB.species.values().filter(func(s): return s.kit != null).size() == 16

	# Cada kit usa sus 4 ataques contra un muñeco sin errores.
	var used := {}
	for id in SPECIES:
		await _setup(id)
		var dummy := _dummy("bulbasaur", Vector2(45, 0))
		var n := 0
		for slot in 4:
			me.moves.reset_cooldown(slot)
			await get_tree().create_timer(0.05).timeout
			if me.use_slot(slot, Vector2.RIGHT, dummy.global_position):
				n += 1
			await get_tree().create_timer(0.7).timeout
			me.statuses.clear()
			if me.machine.current_name() == "stunned":
				me.machine.transition_to("controlled")
		used[id] = n
	r["Todos usan sus 4 ataques (%s)" % str(used.values())] = used.values().all(func(n): return n == 4)

	await _squirtle(r)
	await _pikachu(r)
	await _oddish(r)
	await _paras(r)
	await _psyduck(r)
	await _poliwag(r)
	await _growlithe_eevee(r)
	await _seel(r)
	await _geodude(r)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[kits-v3] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-kits-v3] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _setup(id: String) -> void:
	world = await autotest._setup_kit_world(id)
	me = world.companion
	await get_tree().physics_frame


func _dummy(id: String, offset: Vector2) -> Creature:
	return autotest._dummy(world, id, me.global_position + offset)


func _squirtle(r: Dictionary) -> void:
	await _setup("squirtle")
	var sig := me.signature
	var foe := _dummy("rattata", Vector2(30, 0))
	await get_tree().physics_frame
	me.use_slot(2, Vector2.RIGHT)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var hp0 := me.instance.hp
	me.hurtbox.receive(HitInfo.from(foe, foe.moves.slots[0]))
	r["Squirtle: Refugio justo a tiempo = parry (no entra y aturde)"] = me.instance.hp == hp0 and foe.machine.current_name() == "stunned" and sig.value > 0.0
	await get_tree().create_timer(0.4).timeout
	var full := Damage.resolve(HitInfo.from(foe, foe.moves.slots[0]), me.instance)
	hp0 = me.instance.hp
	me.hurtbox.receive(HitInfo.from(foe, foe.moves.slots[0]))
	r["Squirtle: en el caparazón recibe mucho menos"] = hp0 - me.instance.hp < full * 0.6
	var boosted := HitInfo.from(me, me.moves.slots[0])
	r["Squirtle: la Presión potencia el próximo golpe"] = boosted.damage_mult > 1.0 and sig.value == 0.0
	await get_tree().create_timer(1.3).timeout
	me.statuses.apply(DB.statuses["envenenado"])
	me.moves.reset_cooldown(3)
	me.use_slot(3, Vector2.LEFT)
	r["Squirtle: Giro Rápido limpia sus estados"] = not me.statuses.has_status("envenenado")


func _pikachu(r: Dictionary) -> void:
	await _setup("pikachu")
	var sig := me.signature
	sig.gain("moved", 200.0)
	r["Pikachu: moverse carga Estática"] = sig.value >= 40.0
	sig.set_value(100.0)
	var h := HitInfo.from(me, me.moves.slots[0])
	r["Pikachu: con 5 cargas, Descarga (paraliza y vacía)"] = h.extra_status != null and h.extra_status.id == "paralizado" and sig.value == 0.0
	sig.set_value(60.0)
	await get_tree().create_timer(0.5).timeout
	r["Pikachu: quieto pierde las cargas"] = sig.value < 60.0
	# Rayo: cae del cielo en un círculo chico donde apuntás, con aviso antes.
	var foe := _dummy("rattata", Vector2(80, 0))
	var far := _dummy("rattata", Vector2(80, 60))
	await get_tree().physics_frame
	var hp0: float = foe.instance.hp
	var hp_far: float = far.instance.hp
	me.moves.reset_cooldown(3)
	me.use_slot(3, Vector2.RIGHT, foe.global_position)
	await get_tree().create_timer(0.3).timeout
	r["Pikachu: el Rayo avisa antes de caer"] = foe.instance.hp == hp0 and world.entities.get_children().any(func(n): return n is SkyStrike)
	await get_tree().create_timer(0.5).timeout
	r["Pikachu: el Rayo pega en el área y no fuera"] = foe.instance.hp < hp0 and far.instance.hp == hp_far


func _oddish(r: Dictionary) -> void:
	await _setup("oddish")
	var foe := _dummy("rattata", Vector2(50, 0))
	await get_tree().physics_frame
	me.instance.hp = me.instance.max_hp() * 0.5
	var hp0 := me.instance.hp
	foe.hurtbox.receive(HitInfo.from(me, me.moves.slots[0]))
	r["Oddish: Absorber cura y deja una espora"] = me.instance.hp > hp0 and foe.statuses.stacks("esporas") == 1
	for k in 4:
		foe.statuses.apply(DB.statuses["esporas"])
	me.use_slot(3, Vector2.RIGHT)
	await get_tree().create_timer(0.6).timeout
	r["Oddish: Florecer con 5 esporas envenena y duerme"] = foe.statuses.has_status("envenenado") and foe.statuses.has_status("dormido") \
		and foe.statuses.stacks("esporas") == 0


func _paras(r: Dictionary) -> void:
	await _setup("paras")
	var foe := _dummy("rattata", Vector2(60, 0))
	await get_tree().physics_frame
	me.use_slot(3, Vector2.RIGHT, foe.global_position)
	await get_tree().create_timer(0.6).timeout
	var zones: Array = world.entities.get_children().filter(func(n): return n is GroundZone)
	r["Paras: Espora deja una nube"] = not zones.is_empty()
	if not zones.is_empty():
		Events.element_impact.emit(DB.types["fuego"], zones[0].global_position, 4.0)
		await get_tree().create_timer(0.7).timeout
		r["Paras: el fuego prende las esporas y quema al que está adentro"] = zones[0].burning and foe.statuses.has_status("quemado")


func _psyduck(r: Dictionary) -> void:
	await _setup("psyduck")
	var foe := _dummy("rattata", Vector2(40, 0))
	await get_tree().physics_frame
	foe.moves.consume(0)
	var cd0: float = foe.moves.cooldowns[0]
	foe.hurtbox.receive(HitInfo.from(me, me.moves.slots[3]))
	r["Psyduck: Anulación alarga las recargas del rival"] = foe.moves.cooldowns[0] >= cd0 + 2.5 and foe.moves.cooldowns[1] >= 2.5
	me.signature.set_value(100.0)
	await get_tree().create_timer(0.3).timeout
	r["Psyduck: la Jaqueca estalla y desorienta alrededor"] = foe.statuses.has_status("desorientado") and me.signature.value < 50.0


func _poliwag(r: Dictionary) -> void:
	await _setup("poliwag")
	var dry := me.speed()
	me.use_slot(2, Vector2.RIGHT)
	await get_tree().create_timer(0.4).timeout
	# Alrededor (no en una sola celda: el mapa puede tener un árbol al lado, que no se moja).
	var wet: Array = [Vector2.ZERO, Vector2(16, 0), Vector2(-16, 0), Vector2(0, 16), Vector2(0, -16)] 		.filter(func(o): return world.reactions.state_at(me.global_position + o) != null)
	r["Poliwag: Danza Lluvia moja el piso alrededor"] = not wet.is_empty()
	if not wet.is_empty():
		me.global_position += wet[0]  # pararse en una celda mojada
	await get_tree().create_timer(0.3).timeout
	r["Poliwag: sobre lo mojado se mueve más rápido"] = me.speed() > dry * 1.2
	me.dodge(Vector2.UP)
	r["Poliwag: sobre lo mojado esquiva más seguido"] = me.moves.dodge_cooldown < MoveUser.DODGE_COOLDOWN * 0.8
	var foe := _dummy("rattata", Vector2(30, 0))
	await get_tree().physics_frame
	var hp0: float = foe.instance.hp
	foe.hurtbox.receive(HitInfo.from(me, me.moves.slots[0]))
	r["Poliwag: Burbuja encierra, no moja y saca poco"] = foe.statuses.has_status("burbuja") and not foe.statuses.has_status("empapado") 		and not foe.statuses.can_act() and hp0 - foe.instance.hp < foe.instance.max_hp() * 0.15
	await get_tree().create_timer(1.1).timeout
	r["Poliwag: la burbuja dura poco"] = not foe.statuses.has_status("burbuja")


func _growlithe_eevee(r: Dictionary) -> void:
	await _setup("growlithe")
	var foe := _dummy("rattata", Vector2(20, 0))
	await get_tree().physics_frame
	foe.hurtbox.receive(HitInfo.from(me, me.moves.slots[0]))
	r["Growlithe: Mordisco marca al rival (Rastreo) y le pega más"] = foe.statuses.has_status("rastreado") \
		and me.signature.damage_mult_against(HitInfo.from(me, me.moves.slots[0]), foe) > 1.2
	await _setup("eevee")
	var foe2 := _dummy("vulpix", Vector2(40, 0))
	await get_tree().physics_frame
	var ember := HitInfo.from(foe2, foe2.moves.slots[0])
	me.hurtbox.receive(ember)
	r["Eevee: se adapta al tipo que le pegó (recibe menos)"] = me.signature.damage_taken_mult(HitInfo.from(foe2, foe2.moves.slots[0])) < 1.0


func _seel(r: Dictionary) -> void:
	await _setup("seel")
	var foe := _dummy("rattata", Vector2(40, 0))
	await get_tree().physics_frame
	for k in 3:
		foe.hurtbox.receive(HitInfo.from(me, me.moves.slots[2]))
		await get_tree().physics_frame
	r["Seel: 3 escarchas congelan"] = foe.statuses.has_status("congelado") and foe.statuses.stacks("escarcha") == 0


func _geodude(r: Dictionary) -> void:
	await _setup("geodude")
	var roll: MoveData = me.moves.slots[1]
	var first := HitInfo.from(me, roll)
	var second := HitInfo.from(me, roll)
	r["Geodude: Rodar encadenado pega más (Impulso)"] = second.damage_mult > first.damage_mult * 1.4
	me.statuses.apply(DB.statuses["rizo"])
	var curled := HitInfo.from(me, roll)
	r["Geodude: con Rizo Defensa recibe la mitad y Rodar pega el doble"] = me.statuses.damage_taken_mult() <= 0.5 \
		and curled.damage_mult >= 2.0
