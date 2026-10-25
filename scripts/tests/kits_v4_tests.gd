class_name KitsV4Tests
extends Node
## Autotest de los kits v4 (Kanto hasta Ciudad Plateada, docs/PLAN_IDENTIDAD_COMBATE.md "v4"):
##   godot --headless --path . --quit-after 60000 -- --autotest-kits-v4
## Vitrina del jefe Onix (Atadura, Lanzarrocas, Excavar, Tumba Rocas y el rugido de la 2ª fase):
##   godot --path . --quit-after 330 --write-movie out/f.png --fixed-fps 30 -- --showcase-onix
## Cada kit: 4 ataques que se usan sin errores + su mecánica de firma. Onix (jefe de Brock) con más detalle.

const SPECIES := {"caterpie": "control", "weedle": "asesino", "metapod": "tanque", "kakuna": "tanque",
	"spearow": "asesino", "mankey": "bruiser", "sandshrew": "control", "onix": "tanque"}

var autotest: Node
var world: Node
var me: Creature


func run() -> void:
	var r := {}
	for id in SPECIES:
		var sp: SpeciesData = DB.species[id]
		r["%s: kit %s con 4 ataques y firma" % [sp.display_name, SPECIES[id]]] = sp.kit != null \
			and sp.kit.archetype == SPECIES[id] and sp.kit.moves.size() == 4 and sp.kit.signature != null
		r["%s: aprende el kit (Nv. 1/1/3/5)" % sp.display_name] = sp.learnset.size() >= 4 \
			and sp.learnset[0].move == sp.kit.moves[0] and sp.learnset[3].level == 5
	r["24 especies con kit (o más)"] = DB.species.values().filter(func(s): return s.kit != null).size() >= 24

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
			await get_tree().create_timer(1.2).timeout
			me.statuses.clear()
			if me.machine.current_name() == "stunned":
				me.machine.transition_to("controlled")
		used[id] = n
	r["Todos usan sus 4 ataques (%s)" % str(used.values())] = used.values().all(func(n): return n == 4)

	await _caterpie(r)
	await _weedle(r)
	await _cocoon(r)
	await _spearow(r)
	await _mankey(r)
	await _sandshrew(r)
	await _onix(r)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[kits-v4] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-kits-v4] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _setup(id: String) -> void:
	world = await autotest._setup_kit_world(id)
	me = world.companion
	await get_tree().physics_frame


func _dummy(id: String, offset: Vector2) -> Creature:
	return autotest._dummy(world, id, me.global_position + offset)


func _caterpie(r: Dictionary) -> void:
	await _setup("caterpie")
	var foe := _dummy("rattata", Vector2(40, 0))
	await get_tree().physics_frame
	for k in 3:
		foe.hurtbox.receive(HitInfo.from(me, me.moves.slots[1]))
	r["Caterpie: 3 de seda enredan (no se mueve)"] = foe.statuses.has_status("enraizado") and foe.statuses.stacks("seda") == 0


func _weedle(r: Dictionary) -> void:
	await _setup("weedle")
	var foe := _dummy("bulbasaur", Vector2(40, 0))
	await get_tree().physics_frame
	var h := HitInfo.from(me, me.moves.slots[0])
	var clean: float = me.signature.damage_mult_against(h, foe)
	for k in 3:
		foe.statuses.apply(DB.statuses["envenenado"])
	r["Weedle: pega más a lo envenenado"] = clean == 1.0 and me.signature.damage_mult_against(h, foe) > 1.25


func _cocoon(r: Dictionary) -> void:
	await _setup("kakuna")
	var foe := _dummy("rattata", Vector2(20, 0))
	await get_tree().create_timer(2.2).timeout
	var hit := HitInfo.from(foe, foe.moves.slots[0])
	r["Kakuna: quieto se endurece (recibe la mitad)"] = me.signature.damage_taken_mult(hit) < 0.6
	var poisoned := false
	for k in 8:
		me.signature.damage_taken_mult(hit)
		poisoned = poisoned or foe.statuses.has_status("envenenado")
	r["Kakuna: endurecido envenena al que le pega de cerca"] = poisoned
	me.velocity = Vector2(80, 0)
	me.signature._tick(0.5)
	r["Kakuna: moverse lo ablanda"] = me.signature.ratio() < 0.6


func _spearow(r: Dictionary) -> void:
	await _setup("spearow")
	var foe := _dummy("bulbasaur", Vector2(20, 0))
	await get_tree().physics_frame
	var h := HitInfo.from(me, me.moves.slots[0])
	var m := []
	for k in 4:
		m.append(me.signature.damage_mult_against(h, foe))
	r["Spearow: Furia sube con golpes seguidos (%s)" % str(m)] = m[0] == 1.0 and m[3] > m[1] and m[3] >= 1.29
	var other := _dummy("rattata", Vector2(-20, 0))
	r["Spearow: cambiar de rival pierde la Furia"] = me.signature.damage_mult_against(h, other) == 1.0


func _mankey(r: Dictionary) -> void:
	await _setup("mankey")
	var foe := _dummy("rattata", Vector2(30, 0))
	await get_tree().physics_frame
	for k in 5:
		me.signature.gain("damage_received")
	r["Mankey: con la Rabia llena se enfurece"] = me.statuses.has_status("enfurecido") and me.signature.value == 0.0


func _sandshrew(r: Dictionary) -> void:
	await _setup("sandshrew")
	var before: int = world.entities.get_children().filter(func(n): return n is GroundZone).size()
	me.dodge(Vector2.UP)
	await get_tree().physics_frame
	var after: int = world.entities.get_children().filter(func(n): return n is GroundZone).size()
	r["Sandshrew: esquivar deja una nube de arena"] = after == before + 1


func _onix(r: Dictionary) -> void:
	await _setup("onix")
	r["Onix: es enorme (jefe)"] = me.sprite.scale.x >= 1.3 and me.hurtbox.scale.x >= 1.3
	var foe := _dummy("pikachu", Vector2(30, 0))
	await get_tree().physics_frame
	var p0 := me.global_position
	me.hurtbox.receive(HitInfo.from(foe, foe.moves.slots[1]))  # Ataque Rápido: empuja
	await get_tree().create_timer(0.2).timeout
	r["Onix: no lo empujan ni lo tambalean"] = me.global_position.distance_to(p0) < 2.0 and me.machine.current_name() != "stunned"
	var phys := HitInfo.from(foe, foe.moves.slots[1])
	r["Onix: recibe menos daño físico"] = me.signature.damage_taken_mult(phys) < 0.8
	# Excavar: se mete bajo tierra (invisible e invulnerable) y sale donde apunta.
	var far := _dummy("rattata", Vector2(110, 0))
	await get_tree().physics_frame
	var hp0: float = far.instance.hp
	me.moves.reset_cooldown(2)
	me.use_slot(2, Vector2.RIGHT, far.global_position)
	await get_tree().create_timer(0.4).timeout
	r["Onix: Excavar lo esconde bajo tierra"] = not me.sprite.visible and me.health.is_invulnerable()
	await get_tree().create_timer(1.0).timeout
	r["Onix: Excavar sale debajo del rival y le pega"] = me.sprite.visible and me.global_position.distance_to(far.global_position) < 40.0 \
		and far.instance.hp < hp0
	# Tumba Rocas: varias piedras.
	me.moves.reset_cooldown(3)
	me.use_slot(3, Vector2.RIGHT, far.global_position)
	await get_tree().create_timer(0.35).timeout
	r["Onix: Tumba Rocas tira 3 piedras"] = world.entities.get_children().filter(func(n): return n is SkyStrike).size() == 3
	# Segunda fase.
	me.instance.hp = me.instance.max_hp() * 0.6
	me.hurtbox.receive(HitInfo.from(foe, foe.moves.slots[0]))
	me.instance.hp = me.instance.max_hp() * 0.45
	me.health.changed.emit(me.instance.hp, me.instance.max_hp())
	await get_tree().physics_frame
	r["Onix: a mitad de vida ruge y entra en Furia de Roca"] = me.statuses.has_status("furia_roca")


func showcase_onix() -> void:
	await _setup("onix")
	var foes: Array[Creature] = [_dummy("pikachu", Vector2(70, -10)), _dummy("charmander", Vector2(60, 30))]
	await get_tree().create_timer(0.5).timeout
	for slot in [0, 1, 2, 3]:
		me.moves.reset_cooldown(slot)
		var t: Creature = foes[slot % 2]
		me.use_slot(slot, (t.global_position - me.global_position).normalized(), t.global_position)
		await get_tree().create_timer(2.0).timeout
	me.instance.hp = me.instance.max_hp() * 0.4
	me.health.changed.emit(me.instance.hp, me.instance.max_hp())
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
