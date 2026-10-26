class_name KitsV7Tests
extends KitsV6Tests
## Autotest de los kits v7 (docs/PROPUESTA_KITS_PENDIENTES.md, Tanda B): Clefairy, Jigglypuff, Abra, Goldeen, Magnemite y
## Meowth. Misma estructura que KitsV6Tests (una vuelta por especie: sus 4 ataques y su firma).
##   godot --headless --path . --quit-after 200000 -- --autotest-kits-v7 [--only <especie>]


func _species() -> Dictionary:
	return {"clefairy": "caotico", "jigglypuff": "control", "abra": "velocista", "goldeen": "perseguidor",
		"magnemite": "espaciador", "meowth": "asesino"}


func _heirs() -> Dictionary:
	return {"clefable": "clefairy", "wigglytuff": "jigglypuff", "seaking": "goldeen", "magneton": "magnemite",
		"persian": "meowth"}


func _tag() -> String:
	return "kits-v7"


func _clefairy(r: Dictionary) -> void:
	await _setup("clefairy")
	var pool: Array[MoveData] = me.signature.pool()
	r["Clefairy: el Metrónomo puede sacar ataques de todos los kits (%d)" % pool.size()] = pool.size() > 50 \
		and not pool.any(func(m): return m.id.begins_with("autodestruccion") or m.id.begins_with("metronomo"))
	var foe := _dummy("bulbasaur", Vector2(50, 0))
	me.target = foe
	await get_tree().physics_frame
	var before: int = world.entities.get_child_count()
	me.moves.reset_cooldown(3)
	me.use_slot(3, Vector2.RIGHT, foe.global_position)
	await get_tree().create_timer(0.6).timeout
	r["Clefairy: Metrónomo carga la luna"] = me.signature.value > 0.0
	me.signature.set_value(me.signature.data.max_value)
	me.moves.reset_cooldown(3)
	if me.machine.current_name() != "controlled":
		me.machine.transition_to("controlled")
	await get_tree().physics_frame
	me.use_slot(3, Vector2.RIGHT, foe.global_position)
	await get_tree().physics_frame
	r["Clefairy: con la luna llena sale uno fuerte y la luna se vacía"] = me.signature.value == 0.0


func _jigglypuff(r: Dictionary) -> void:
	await _setup("jigglypuff")
	var foe := _dummy("rattata", Vector2(30, 0))
	await get_tree().physics_frame
	me.hurtbox.receive(_hit(foe, 0))
	me.hurtbox.receive(_hit(foe, 0))
	await get_tree().physics_frame
	r["Jigglypuff: cada golpe que recibe lo infla"] = me.statuses.stacks("inflado") >= 2
	var roll := HitInfo.from(me, me.moves.slots[1])
	r["Jigglypuff: Rodar gasta el inflado y pega más"] = me.signature.damage_mult_against(roll, foe) > 1.4 \
		and me.statuses.stacks("inflado") == 0
	foe.statuses.apply(DB.statuses["dormido"])
	me.signature.damage_mult_against(_hit(me, 0), foe)
	r["Jigglypuff: golpear a un dormido le deja un garabato (Expuesto)"] = foe.statuses.has_status("expuesto")


func _abra(r: Dictionary) -> void:
	await _setup("abra")
	var foe := _weak("rattata", Vector2(25, 0))  # nivel 2: el Rattata de práctica (Nv. 40) lo debilita de un golpe
	await get_tree().physics_frame
	var p0 := me.global_position
	me.hurtbox.receive(_hit(foe, 0))
	await get_tree().physics_frame
	r["Abra: cuando le pegan se teletransporta lejos"] = me.global_position.distance_to(p0) > 40.0
	var p1 := me.global_position
	me.hurtbox.receive(_hit(foe, 0))
	await get_tree().physics_frame
	r["Abra: no puede volver a hacerlo enseguida"] = me.global_position.distance_to(p1) < 5.0
	await _setup("abra")
	me.statuses.apply(DB.statuses["dormido"])
	var foe2 := _weak("rattata", Vector2(25, 0))
	await get_tree().physics_frame
	var p2 := me.global_position
	me.hurtbox.receive(_hit(foe2, 0))
	await get_tree().physics_frame
	r["Abra: dormido no se escapa (así se lo atrapa)"] = me.global_position.distance_to(p2) < 5.0


func _goldeen(r: Dictionary) -> void:
	await _setup("goldeen")
	var tank := _dummy("squirtle", Vector2(30, 0))
	await get_tree().physics_frame
	tank.statuses.apply(DB.statuses["refugio"])
	r["Goldeen: Cornada atraviesa las defensas (×1,6 contra Refugio)"] = \
		me.signature.damage_mult_against(HitInfo.from(me, me.moves.slots[3]), tank) >= 1.6
	await get_tree().physics_frame
	var dry: float = me.signature.speed_mult()
	me.statuses.apply(DB.statuses["empapado"])
	await get_tree().physics_frame
	await get_tree().physics_frame
	r["Goldeen: en seco aletea (×%.2f) y mojado vuela (×%.2f)" % [dry, me.signature.speed_mult()]] = dry < 1.0 \
		and me.signature.speed_mult() > 1.2


func _magnemite(r: Dictionary) -> void:
	await _setup("magnemite")
	me.statuses.apply(DB.statuses["ralentizado"])
	r["Magnemite: flota (no lo ralentizan)"] = not me.statuses.has_status("ralentizado")
	r["Magnemite: sus disparos atraen en vez de empujar"] = me.moves.slots[0].knockback < 0.0
	var foe := _dummy("rattata", Vector2(30, 0))
	await get_tree().physics_frame
	foe.statuses.apply(DB.statuses["expuesto"])
	r["Magnemite: pega más a lo que marcó con Fijar Blanco"] = me.signature.damage_mult_against(_hit(me, 0), foe) >= 1.25


func _meowth(r: Dictionary) -> void:
	await _setup("meowth")
	var foe := _dummy("bulbasaur", Vector2(20, 0))
	await get_tree().physics_frame
	var money0 := GameState.money
	me.moves.cooldowns[3] = 5.0
	for k in 4:
		me.hit_dealt.emit(foe, _hit(me, 0), 10.0)
	r["Meowth: cada golpe suma monedas a tu dinero ($%d)" % (GameState.money - money0)] = GameState.money == money0 + 20
	r["Meowth: cada 4 golpes, Día de Pago baja las recargas"] = me.moves.cooldowns[3] < 5.0


## Un rival quieto de nivel 2 (para recibir golpes sin debilitarse).
func _weak(id: String, offset: Vector2) -> Creature:
	var d: Creature = world.spawner.spawn(DB.species[id], 2, me.global_position + offset)
	d.get_node("StateMachine/Wander").aggro_radius = 0.0
	d.machine.set_physics_process.call_deferred(false)
	return d
