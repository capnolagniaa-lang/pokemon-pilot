class_name KitsV6Tests
extends Node
## Autotest de los kits v6 (docs/PROPUESTA_KITS_PENDIENTES.md, Tanda A): Raichu jefe de Surge, Zubat, Ekans, Machop,
## Nidoran♀, Nidoran♂, Horsea, Shellder, Tentacool y Voltorb.
##   godot --headless --path . --quit-after 90000 -- --autotest-kits-v6

const SPECIES := {"raichu": "bruiser", "zubat": "hostigador", "ekans": "control", "machop": "bruiser",
	"nidoran_f": "bruiser", "nidoran_m": "asesino", "horsea": "espaciador", "shellder": "tanque", "tentacool": "control",
	"voltorb": "hostigador"}
## Evoluciones que heredan estos kits (decisión del usuario 2026-10-25).
const HEIRS := {"golbat": "zubat", "arbok": "ekans", "machoke": "machop", "nidorina": "nidoran_f",
	"nidorino": "nidoran_m", "seadra": "horsea", "cloyster": "shellder", "tentacruel": "tentacool", "electrode": "voltorb"}

## Lo que cambia entre tandas (KitsV7Tests sobreescribe estos tres).
func _species() -> Dictionary:
	return SPECIES


func _heirs() -> Dictionary:
	return HEIRS


func _tag() -> String:
	return "kits-v6"


var autotest: Node
var world: Node
var me: Creature


func run() -> void:
	var r := {}
	# `-- --autotest-kits-v6 --only <especie>` (raichu, zubat, ..., voltorb) prueba solo esa especie (la corrida
	# entera arma el mundo 10 veces y con la PC cargada tarda mucho).
	var args := OS.get_cmdline_user_args()
	var only: String = args[args.find("--only") + 1] if args.has("--only") and args.find("--only") + 1 < args.size() else ""
	var species := _species()
	var heirs := _heirs()
	for id in species:
		var sp: SpeciesData = DB.species[id]
		r["%s: kit %s con 4 ataques y firma" % [sp.display_name, species[id]]] = sp.kit != null and not sp.kit_inherited \
			and sp.kit.archetype == species[id] and sp.kit.moves.size() == 4 and sp.kit.signature != null
		r["%s: aprende el kit (Nv. 1/1/3/5)" % sp.display_name] = sp.learnset.size() >= 4 \
			and sp.learnset[0].move == sp.kit.moves[0] and sp.learnset[3].level == 5
	for heir in heirs:
		r["%s hereda el kit de %s" % [heir, heirs[heir]]] = DB.species[heir].kit == DB.species[heirs[heir]].kit
	if species.has("raichu"):
		r["Raichu ya no pelea con el kit de Pikachu"] = DB.species["raichu"].kit != DB.species["pikachu"].kit

	# Una sola vuelta por Pokémon (armar el mundo es lo lento): sus 4 ataques y enseguida su firma.
	var used := []
	for id in species:
		if only != "" and id != only:
			continue
		print("[%s] … %s" % [_tag(), id])
		await _setup(id)
		var dummy := _dummy("bulbasaur", Vector2(45, 0))
		var n := 0
		var failed := []
		for slot in 4:
			me.moves.reset_cooldown(slot)
			var wait := 0.0
			while me.machine.current_name() != "controlled" and wait < 2.0:  # recuperación del anterior (Chispa)
				await get_tree().physics_frame
				wait += get_physics_process_delta_time()
			await get_tree().create_timer(0.05).timeout
			if me.use_slot(slot, Vector2.RIGHT, dummy.global_position):
				n += 1
			else:
				failed.append("%s (estado %s)" % [me.moves.slots[slot].id, me.machine.current_name()])
			await get_tree().create_timer(1.3).timeout
			me.statuses.clear()
			me.instance.hp = me.instance.max_hp()
			if me.machine.current_name() == "stunned":
				me.machine.transition_to("controlled")
		if n < 4:
			used.append("%s %d/4: %s" % [id, n, ", ".join(failed)])
		if has_method("_" + id):
			await call("_" + id, r)
	r["Todos usan sus 4 ataques %s" % str(used)] = used.is_empty()
	_finish(r)


func _finish(r: Dictionary) -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[%s] %s %s" % [_tag(), "OK   " if r[key] else "FALLO", key])
	print("[autotest-%s] -> " % _tag(), "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Arma el mundo con `id` de compañero; si ya está (la vuelta de sus 4 ataques), lo deja limpio sin volver a armarlo.
func _setup(id: String) -> void:
	if is_instance_valid(me) and me.instance.species.id == id and is_instance_valid(world):
		for c in world.entities.get_children():
			if (c is Creature and c != me) or c is Projectile:
				c.queue_free()
		me.statuses.clear()
		me.instance.hp = me.instance.max_hp()
		me.health.changed.emit(me.instance.hp, me.instance.max_hp())
		for slot in 4:
			me.moves.reset_cooldown(slot)
		if me.signature != null:
			me.signature.set_value(0.0)
		await get_tree().create_timer(0.3).timeout
		return
	world = await autotest._setup_kit_world(id)
	me = world.companion
	await get_tree().physics_frame


func _dummy(id: String, offset: Vector2) -> Creature:
	return autotest._dummy(world, id, me.global_position + offset)


func _hit(from: Creature, slot: int) -> HitInfo:
	return HitInfo.from(from, from.moves.slots[slot])


func _raichu(r: Dictionary) -> void:
	await _setup("raichu")
	r["Raichu: es grande (jefe)"] = me.sprite.scale.x >= 1.25
	var foe := _dummy("pikachu", Vector2(30, 0))
	await get_tree().physics_frame
	var hp0: float = foe.instance.hp
	me.signature.set_value(me.signature.data.max_value)
	await get_tree().physics_frame
	r["Raichu: con la barra llena planta la cola (quieto)"] = me.statuses.has_status("plantado") and not me.statuses.can_move()
	await get_tree().create_timer(1.3).timeout
	r["Raichu: la descarga lastima alrededor"] = foe.instance.hp < hp0
	var st = world.reactions.state_at(me.global_position + Vector2(20, 0))
	r["Raichu: deja el suelo chamuscado y electrificado"] = st != null and st.id == "chamuscado_electrico"
	r["Raichu: la barra se vacía (la descarga solo vuelve a sumar un poco)"] = me.signature.value < me.signature.data.max_value * 0.3
	me.instance.hp = me.instance.max_hp() * 0.45
	me.health.changed.emit(me.instance.hp, me.instance.max_hp())
	await get_tree().physics_frame
	r["Raichu: a mitad de vida, Sobrecarga"] = me.statuses.has_status("sobrecarga")
	r["Raichu: Trueno cae 3 veces del cielo"] = me.moves.slots[3].zone_strike and me.moves.slots[3].strike_count == 3


func _zubat(r: Dictionary) -> void:
	await _setup("zubat")
	me.statuses.apply(DB.statuses["desorientado"])
	r["Zubat: es ciego, no lo desorientan"] = not me.statuses.has_status("desorientado")
	var foe := _dummy("bulbasaur", Vector2(20, 0))
	await get_tree().physics_frame
	me.instance.hp = me.instance.max_hp() * 0.5
	var h0: float = me.instance.hp
	foe.hurtbox.receive(_hit(me, 0))
	var plain: float = me.instance.hp - h0
	foe.statuses.apply(DB.statuses["desorientado"])
	me.instance.hp = me.instance.max_hp() * 0.5
	h0 = me.instance.hp
	foe.hurtbox.receive(_hit(me, 0))
	var bonus: float = me.instance.hp - h0
	r["Zubat: Chupavidas cura más contra un desorientado (%.1f vs %.1f)" % [bonus, plain]] = plain > 0.0 and bonus > plain * 1.5


func _ekans(r: Dictionary) -> void:
	await _setup("ekans")
	await get_tree().create_timer(1.0).timeout
	r["Ekans: quieto se enrosca"] = me.signature.poised()
	var h := _hit(me, 0)
	me.signature.modify_hit(h)
	r["Ekans: el golpe enroscado pega +40% y lo gasta"] = h.damage_mult >= 1.39 and not me.signature.poised()


func _machop(r: Dictionary) -> void:
	await _setup("machop")
	me.statuses.apply(DB.statuses["ralentizado"])
	r["Machop: no lo pueden ralentizar"] = not me.statuses.has_status("ralentizado")
	var foe := _dummy("bulbasaur", Vector2(20, 0))
	await get_tree().physics_frame
	me.moves.cooldowns[3] = 5.0
	me.hit_dealt.emit(foe, _hit(me, 0), 10.0)
	r["Machop: cada golpe que conecta baja las recargas"] = me.moves.cooldowns[3] < 5.0


func _nidoran_f(r: Dictionary) -> void:
	await _setup("nidoran_f")
	var foe := _dummy("rattata", Vector2(20, 0))
	await get_tree().physics_frame
	var hp0: float = foe.instance.hp
	me.hurtbox.receive(_hit(foe, 0))
	await get_tree().physics_frame
	r["Nidoran♀: las púas devuelven daño al que le pega cuerpo a cuerpo"] = foe.instance.hp < hp0
	var bite := HitInfo.from(me, me.moves.slots[2])
	foe.statuses.apply(DB.statuses["envenenado"])
	r["Nidoran♀: Mordisco pega ×1,5 a lo envenenado"] = me.signature.damage_mult_against(bite, foe) >= 1.5


func _nidoran_m(r: Dictionary) -> void:
	# Nidoran♂: esquive perfecto con un disparo a punto de llegar.
	await _setup("nidoran_m")
	var shooter := _dummy("squirtle", Vector2(60, 0))
	await get_tree().physics_frame
	me.moves.cooldowns[3] = 5.0
	var p := Projectile.new()
	world.entities.add_child(p)
	p.launch(_hit(shooter, 1), me.global_position + Vector2(20, 0), Vector2.LEFT)
	await get_tree().physics_frame
	me.dodge(Vector2.UP)
	await get_tree().physics_frame
	var h := _hit(me, 0)
	me.signature.modify_hit(h)
	r["Nidoran♂: esquive perfecto recarga Cornada y deja un crítico"] = me.moves.cooldowns[3] == 0.0 and h.damage_mult >= 1.5


func _horsea(r: Dictionary) -> void:
	await _setup("horsea")
	await get_tree().create_timer(0.7).timeout
	var shot := _hit(me, 1)
	me.signature.modify_hit(shot)
	var hit_melee := HitInfo.from(me, DB.species["rattata"].kit.moves[0])
	me.signature.modify_hit(hit_melee)
	r["Horsea: anclado, sus disparos pegan +30% (y solo los disparos)"] = shot.damage_mult >= 1.29 and hit_melee.damage_mult == 1.0
	r["Horsea: anclado no lo empujan"] = me.signature.knockback_taken_mult() == 0.0


func _shellder(r: Dictionary) -> void:
	await _setup("shellder")
	me.facing = Vector2.RIGHT
	var front := _dummy("rattata", Vector2(30, 0))
	var back := _dummy("rattata", Vector2(-30, 0))
	await get_tree().physics_frame
	var f: float = me.signature.damage_taken_mult(_hit(front, 0))
	var b: float = me.signature.damage_taken_mult(_hit(back, 0))
	r["Shellder: de frente recibe menos y de espaldas más (%.1f / %.1f)" % [f, b]] = f < 0.7 and b > 1.3


func _tentacool(r: Dictionary) -> void:
	await _setup("tentacool")
	await get_tree().physics_frame
	await get_tree().physics_frame
	var dry: bool = me.signature.speed_mult() < 1.0
	me.instance.hp = me.instance.max_hp() * 0.5
	var h0: float = me.instance.hp
	me.statuses.apply(DB.statuses["empapado"])
	await get_tree().create_timer(1.0).timeout
	r["Tentacool: en seco va más lento"] = dry
	r["Tentacool: mojado se cura"] = me.instance.hp > h0 and me.signature.speed_mult() == 1.0


func _voltorb(r: Dictionary) -> void:
	await _setup("voltorb")
	await get_tree().create_timer(1.8).timeout
	r["Voltorb: quieto se camufla"] = me.signature.poised() and me.sprite.modulate.a < 0.6
	var h := _hit(me, 1)
	me.signature.modify_hit(h)
	r["Voltorb: el golpe desde el camuflaje es crítico"] = h.damage_mult >= 1.49
	var foe := _dummy("bulbasaur", Vector2(40, 0))
	await get_tree().physics_frame
	var hp0: float = foe.instance.hp
	me.moves.reset_cooldown(3)
	me.use_slot(3, Vector2.RIGHT, foe.global_position)
	await get_tree().create_timer(1.6).timeout
	r["Voltorb: Autodestrucción lastima en área"] = foe.instance.hp < hp0
	r["Voltorb: y lo deja con 1 de vida (no se debilita)"] = me.instance.hp <= 1.0 and me.instance.hp > 0.0
