class_name KitsV8Tests
extends KitsV6Tests
## Autotest de los kits v8 (docs/PROPUESTA_KITS_PENDIENTES.md, Tanda C: Drowzee, Grimer, Koffing, Ponyta, Slowpoke,
## Magikarp) y de la **sinergia** de los kits con todo lo que aprenden (pedido del usuario 2026-10-26: "todos los
## movimientos de la wiki tienen que poder elegirse y hacer sinergia con el kit").
##   godot --headless --path . --quit-after 200000 -- --autotest-kits-v8 [--only <especie>|--only sinergia]

## Ataques de mejora propia que todavía no hacen nada en tiempo real (climas, Sustituto, Salpicadura...): permitidos.
const NO_EFFECT_OK := ["salpicadura", "sustituto", "metronomo", "camuflaje", "conversion", "ayuda", "robo", "sellar",
	"relevo", "reciclaje", "sonambulo", "senuelo", "mismo_destino", "canto_mortal", "rabia", "maldicion", "niebla",
	"granizo", "dia_soleado", "tormenta_de_arena", "chapoteo_lodo", "puas", "capa_magica", "legado", "carga"]


func _species() -> Dictionary:
	return {"drowzee": "control", "grimer": "tanque", "koffing": "control", "ponyta": "velocista",
		"slowpoke": "tanque", "magikarp": "caotico"}


func _heirs() -> Dictionary:
	return {"hypno": "drowzee", "muk": "grimer", "weezing": "koffing", "rapidash": "ponyta", "slowbro": "slowpoke"}


func _tag() -> String:
	return "kits-v8"


func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--only") and args.find("--only") + 1 < args.size() and args[args.find("--only") + 1] == "sinergia":
		var r := {}
		await _sinergia(r)
		_finish(r)
		return
	await super.run()


## Sinergia: todo lo de FRLG se puede elegir, los de mejora propia hacen algo, y las firmas reaccionan a los oficiales.
func _sinergia(r: Dictionary) -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/source/official.json"))
	var missing := []
	var empty := []
	for sp: SpeciesData in DB.species.values():
		if sp.kit == null:
			continue
		var names := sp.learnset.map(func(e): return e.move.display_name)
		for row in data["species"].get(sp.id, {}).get("learnset", []):
			var m: MoveData = DB.moves.get(row[1])
			if m != null and not m.display_name in names:
				missing.append("%s:%s" % [sp.id, row[1]])
		for e in sp.learnset:
			# (los del kit sin estado los maneja su firma: Florecer de Oddish, Metrónomo...)
			if e.move.kind == MoveData.Kind.SELF_BUFF and e.move.self_status == null and not e.move.cleanse_self \
					and not e.move in sp.kit.moves and not e.move.id in NO_EFFECT_OK and not e.move.id.begins_with("metronomo") and not "%s" % e.move.id in empty:
				empty.append(e.move.id)
	r["Los Pokémon con kit aprenden todo su learnset de FireRed %s" % str(missing.slice(0, 6))] = missing.is_empty()
	r["Los ataques de mejora propia que aprenden hacen algo %s" % str(empty)] = empty.is_empty()
	r["Refugio, Foco Energía y Protección oficiales ponen su estado"] = DB.moves["refugio"].self_status != null \
		and DB.moves["foco_energia"].self_status != null and DB.moves["proteccion"].self_status != null
	r["El Gas Venenoso oficial es una nube que Koffing puede detonar"] = DB.moves["gas_venenoso"].kind == MoveData.Kind.ZONE \
		and DB.moves["gas_venenoso"].zone_flammable
	# Seel: un Rayo Hielo aprendido (no del kit) también suma escarcha.
	await _setup("seel")
	var foe := _dummy("bulbasaur", Vector2(30, 0))
	await get_tree().physics_frame
	me.hit_dealt.emit(foe, HitInfo.from(me, DB.moves["rayo_hielo"]), 10.0)
	r["Seel: un Rayo Hielo aprendido suma escarcha (sinergia por tipo)"] = foe.statuses.stacks("escarcha") >= 1
	# Geodude: el Rodar oficial también encadena el Impulso.
	await _setup("geodude")
	var foe2 := _dummy("bulbasaur", Vector2(30, 0))
	await get_tree().physics_frame
	var h1 := HitInfo.from(me, DB.moves["rodar"])
	me.signature.modify_hit(h1)
	var h2 := HitInfo.from(me, DB.moves["rodar"])
	me.signature.modify_hit(h2)
	var first: float = h1.damage_mult
	var second: float = h2.damage_mult
	r["Geodude: el Rodar oficial también suma Impulso (%.2f → %.2f)" % [first, second]] = second > first


func _drowzee(r: Dictionary) -> void:
	await _setup("drowzee")
	var foe := _dummy("rattata", Vector2(30, 0))
	await get_tree().physics_frame
	for k in 4:
		me.hit_dealt.emit(foe, HitInfo.from(me, DB.moves["psiquico"]), 5.0)
	r["Drowzee: 4 golpes psíquicos (aunque no sean del kit) lo duermen"] = foe.statuses.has_status("dormido")


func _grimer(r: Dictionary) -> void:
	await _setup("grimer")
	me.statuses.apply(DB.statuses["envenenado"])
	me.statuses.apply(DB.statuses["ralentizado"])
	r["Grimer: no lo envenenan ni lo ralentizan"] = not me.statuses.has_status("envenenado") \
		and not me.statuses.has_status("ralentizado")
	var foe := _dummy("rattata", Vector2(20, 0))
	await get_tree().physics_frame
	me.hurtbox.receive(_hit(foe, 0))
	await get_tree().physics_frame
	r["Grimer: al que le pega cuerpo a cuerpo lo deja pegoteado"] = foe.statuses.has_status("ralentizado")
	r["Grimer: Derretirse deja un rastro tóxico"] = me.moves.slots[3].trail_status != null and me.moves.slots[3].trail_power > 0.0


func _koffing(r: Dictionary) -> void:
	await _setup("koffing")
	var foe := _dummy("bulbasaur", Vector2(60, 0))
	await get_tree().physics_frame
	me.moves.reset_cooldown(1)
	me.use_slot(1, Vector2.RIGHT, foe.global_position)
	await get_tree().create_timer(0.3).timeout
	r["Koffing: Gas Venenoso deja una nube suya"] = me.signature._clouds().size() == 1
	var hp0: float = foe.instance.hp
	me.moves.reset_cooldown(3)
	if me.machine.current_name() != "controlled":
		me.machine.transition_to("controlled")
	await get_tree().physics_frame
	me.use_slot(3, Vector2.RIGHT, foe.global_position)
	await get_tree().physics_frame
	var clouds := me.get_parent().get_children().filter(func(n): return n is GroundZone and n.hit != null and n.hit.attacker == me)
	r["Koffing: Detonar prende todas sus nubes"] = not clouds.is_empty() and clouds.all(func(z): return z.burning)
	await get_tree().create_timer(1.2).timeout
	r["Koffing: la nube prendida quema al que está adentro"] = foe.instance.hp < hp0


func _ponyta(r: Dictionary) -> void:
	await _setup("ponyta")
	me.machine.set_physics_process(false)
	var t := 0.0
	while t < 1.8:
		me.move(Vector2.RIGHT, me.speed())
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	r["Ponyta: corriendo derecho llena el galope y va más rápido (×%.2f)" % me.signature.speed_mult()] = \
		me.signature.ratio() > 0.9 and me.signature.speed_mult() > 1.3
	var h := HitInfo.from(me, me.moves.slots[3])
	me.signature.modify_hit(h)
	r["Ponyta: galopando, Derribo pega más"] = h.damage_mult > 1.3
	for k in 4:
		me.move(Vector2.UP, me.speed())
		await get_tree().physics_frame
	r["Ponyta: un giro fuerte pierde el galope"] = me.signature.ratio() < 0.5
	me.machine.set_physics_process(true)


func _slowpoke(r: Dictionary) -> void:
	await _setup("slowpoke")
	var foe := _dummy("rattata", Vector2(30, 0))
	await get_tree().physics_frame
	var hp0: float = me.instance.hp
	me.hurtbox.receive(_hit(foe, 0))
	await get_tree().physics_frame
	var now: float = hp0 - me.instance.hp
	await get_tree().create_timer(2.3).timeout
	var later: float = hp0 - me.instance.hp - now
	r["Slowpoke: parte del daño le llega tarde (%.1f ahora, %.1f después)" % [now, later]] = now > 0.0 and later > 0.0
	me.statuses.clear()
	me.status_inflicted.emit(foe, DB.statuses["bostezo"])
	foe.statuses.apply(DB.statuses["bostezo"])
	await get_tree().create_timer(2.3).timeout
	r["Slowpoke: Bostezo duerme al rival a los 2 s"] = foe.statuses.has_status("dormido")


func _magikarp(r: Dictionary) -> void:
	await _setup("magikarp")
	var foe := _dummy("rattata", Vector2(30, 0))
	await get_tree().physics_frame
	var full: float = me.signature.damage_mult_against(HitInfo.from(me, me.moves.slots[2]), foe)
	me.instance.hp = me.instance.max_hp() * 0.1
	me.health.changed.emit(me.instance.hp, me.instance.max_hp())
	var low: float = me.signature.damage_mult_against(HitInfo.from(me, me.moves.slots[2]), foe)
	r["Magikarp: Azote pega más con poca vida (×%.1f → ×%.1f)" % [full, low]] = full < 1.2 and low > 2.5
	var exp0: int = me.instance.experience
	me.killed.emit(foe)
	r["Magikarp: Determinación da EXP extra al derribar a un rival"] = me.instance.experience > exp0
