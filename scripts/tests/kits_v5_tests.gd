class_name KitsV5Tests
extends Node
## Autotest de los kits v5 (capítulo 2, docs/PLAN_CAPITULO_2.md parte K): Staryu y Starmie, la jefa de Misty.
##   godot --headless --path . --quit-after 60000 -- --autotest-kits-v5
## Núcleo (core_mechanic.gd): girando desvía proyectiles, más daño a lo Empapado, la barra llena cura; Starmie además
## es grande, casi no la empujan y a mitad de vida el núcleo brilla (onda + Núcleo Brillante).

const SPECIES := {"staryu": "velocista", "starmie": "control"}

var autotest: Node
var world: Node
var me: Creature


func run() -> void:
	var r := {}
	for id in SPECIES:
		var sp: SpeciesData = DB.species[id]
		r["%s: kit %s con 4 ataques y firma Núcleo" % [sp.display_name, SPECIES[id]]] = sp.kit != null \
			and sp.kit.archetype == SPECIES[id] and sp.kit.moves.size() == 4 and sp.kit.signature != null
		r["%s: aprende el kit (Nv. 1/1/3/5)" % sp.display_name] = sp.learnset.size() >= 4 \
			and sp.learnset[0].move == sp.kit.moves[0] and sp.learnset[3].level == 5
		r["%s: tiene estilo de pelea (ágil)" % sp.display_name] = DB.fight_styles.has(id) and DB.fight_styles[id].move_style == "agil"

	for id in SPECIES:
		await _setup(id)
		var dummy := _dummy("bulbasaur", Vector2(45, 0))
		var n := 0
		for slot in 4:
			me.moves.reset_cooldown(slot)
			await get_tree().create_timer(0.05).timeout
			if me.use_slot(slot, Vector2.RIGHT, dummy.global_position):
				n += 1
			await get_tree().create_timer(1.0).timeout
			me.statuses.clear()
			if me.machine.current_name() == "stunned":
				me.machine.transition_to("controlled")
		r["%s usa sus 4 ataques (%d)" % [id, n]] = n == 4

	await _staryu(r)
	await _starmie(r)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[kits-v5] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-kits-v5] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _setup(id: String) -> void:
	world = await autotest._setup_kit_world(id)
	me = world.companion
	await get_tree().physics_frame


func _dummy(id: String, offset: Vector2) -> Creature:
	return autotest._dummy(world, id, me.global_position + offset)


func _staryu(r: Dictionary) -> void:
	await _setup("staryu")
	var foe := _dummy("charmander", Vector2(40, 0))
	await get_tree().physics_frame
	foe.hurtbox.receive(HitInfo.from(me, me.moves.slots[1]))
	r["Staryu: Pistola Agua deja Empapado"] = foe.statuses.has_status("empapado")
	r["Staryu: le pega más a lo Empapado"] = me.signature.damage_mult_against(HitInfo.from(me, me.moves.slots[0]), foe) > 1.1
	# Giro Rápido: un proyectil rival que lo toca sale desviado.
	me.moves.reset_cooldown(2)
	me.use_slot(2, Vector2.UP, me.global_position + Vector2(0, -60))
	await get_tree().physics_frame
	var p := Projectile.new()
	world.entities.add_child(p)
	p.launch(HitInfo.from(foe, foe.moves.slots[1]), me.global_position + Vector2(14, 0), Vector2.LEFT)
	await get_tree().physics_frame
	await get_tree().physics_frame
	r["Staryu: girando desvía los proyectiles"] = is_instance_valid(p) and not p._dead and p.velocity.x > 0.0
	# Núcleo: la barra llena cura.
	await get_tree().create_timer(0.6).timeout
	me.instance.hp = me.instance.max_hp() * 0.5
	var hp0: float = me.instance.hp
	me.signature.set_value(me.signature.data.max_value)
	r["Staryu: el núcleo lleno regenera vida y vuelve a 0"] = me.instance.hp > hp0 and me.signature.value == 0.0


func _starmie(r: Dictionary) -> void:
	await _setup("starmie")
	r["Starmie: es grande (jefa)"] = me.sprite.scale.x >= 1.25 and me.hurtbox.scale.x >= 1.25
	var foe := _dummy("pikachu", Vector2(30, 0))
	await get_tree().physics_frame
	var p0 := me.global_position
	me.hurtbox.receive(HitInfo.from(foe, foe.moves.slots[1]))
	await get_tree().create_timer(0.25).timeout
	r["Starmie: casi no la empujan"] = me.global_position.distance_to(p0) < 12.0
	r["Starmie: Rapidez tira 5 estrellas"] = me.moves.slots[1].projectile_count == 5
	me.moves.reset_cooldown(3)
	me.instance.hp = me.instance.max_hp() * 0.7
	var hp0: float = me.instance.hp
	me.use_slot(3, Vector2.RIGHT, foe.global_position)
	await get_tree().create_timer(1.5).timeout
	r["Starmie: Recuperación la cura"] = me.instance.hp > hp0 + 1.0
	# Segunda fase: el núcleo brilla.
	var foe_hp: float = foe.instance.hp
	me.instance.hp = me.instance.max_hp() * 0.45
	me.health.changed.emit(me.instance.hp, me.instance.max_hp())
	await get_tree().create_timer(0.3).timeout
	r["Starmie: a mitad de vida el núcleo brilla (más fuerte)"] = me.statuses.has_status("nucleo_brillante")
	r["Starmie: la onda del núcleo moja y lastima al rival"] = foe.statuses.has_status("empapado") and foe.instance.hp < foe_hp
