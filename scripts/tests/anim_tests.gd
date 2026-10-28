class_name AnimTests
extends Node
## Autotest de las animaciones de combate de SpriteCollab (tools/download_sprites.py → CreatureSprite.CHAINS):
##   godot --headless --path . --quit-after 30000 -- --autotest-anims
## Que las hojas nuevas existan y que la criatura elija la correcta al disparar, cargar, golpear, embestir,
## esquivar, dormirse y debilitarse (y que caiga a Attack si la especie no la tiene).

const DATA_SPECIES := ["charmander", "squirtle", "pikachu", "geodude", "pidgey"]

var autotest: Node


func run() -> void:
	var r := {}
	var shoot := 0
	var dodge := 0
	var faint := 0
	for sp: SpeciesData in DB.species.values():
		var a := DB.anims_of(sp)
		shoot += 1 if a.has("Shoot") else 0
		dodge += 1 if a.has("Hop") or a.has("Rotate") or a.has("Tumble") else 0
		faint += 1 if a.has("Faint") or a.has("HitGround") or a.has("LostBalance") else 0
	r["Muchas especies con Shoot (%d), esquive (%d) y caída (%d)" % [shoot, dodge, faint]] = \
		shoot >= 300 and dodge >= 300 and faint >= 80
	for id in DATA_SPECIES:
		var a := DB.anims_of(DB.species[id])
		var files_ok := true
		for anim in a:
			if anim != "portrait" and not ResourceLoader.exists(a[anim]["file"]):
				files_ok = false
		r["%s: hojas nuevas (%d animaciones) e importadas" % [id, a.size() - 1]] = files_ok and a.size() > 6

	var world: Node = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	# (desde las habilidades los Pokémon traen sus ataques de nivel: para probar la mecánica, los del viejo kit de Charmander)
	for i in 4:
		me.moves.slots[i] = DB.all_moves[["charmander/ascuas_abanico", "charmander/aranazo_embestida",
			"charmander/giro_fuego_trampa", "charmander/embestida_ignea"][i]]
		me.moves.reset_cooldown(i)
	var spr: CreatureSprite = me.sprite
	r["Charmander: disparo → Shoot, golpe → Strike, golpe fuerte → Swing, embestida → LeapForth"] = \
		spr.pick(CreatureSprite.chain_for_move(_move(MoveData.Kind.PROJECTILE, 40))) == "Shoot" \
		and spr.pick(CreatureSprite.chain_for_move(_move(MoveData.Kind.MELEE, 40))) in ["QuickStrike", "Strike"] \
		and spr.pick(CreatureSprite.chain_for_move(_move(MoveData.Kind.MELEE, 90))) == "Swing" \
		and spr.pick(CreatureSprite.chain_for_move(_move(MoveData.Kind.DASH, 60))) == "LeapForth"
	var combo := _move(MoveData.Kind.MELEE, 40)
	combo.combo_steps = 3
	r["Combo de 3: Strike, Swing, Double"] = [0, 1, 2].map(func(s): return spr.pick(CreatureSprite.chain_for_move(combo, s))) \
		== [spr.pick("strike"), "Swing", "Double"]

	var dummy: Creature = autotest._dummy(world, "bulbasaur", me.global_position + Vector2(60, 0))
	await get_tree().physics_frame
	var proj := -1
	for i in me.moves.slots.size():
		if me.moves.slots[i].kind == MoveData.Kind.PROJECTILE and me.moves.slots[i].cast_time <= 0.0:
			proj = i
	me.use_slot(proj, Vector2.RIGHT, dummy.global_position)
	await get_tree().process_frame
	r["Ascuas (disparo) usa Shoot"] = spr.current_anim() == "Shoot"
	await get_tree().create_timer(0.6).timeout

	var charged := _move(MoveData.Kind.PROJECTILE, 90)
	charged.cast_time = 0.4
	me.machine.transition_to("cast", {"move": charged, "aim": Vector2.RIGHT, "step": 0, "point": dummy.global_position, "spent": 0.0})
	await get_tree().create_timer(0.2).timeout
	var charging := spr.current_anim()
	await get_tree().create_timer(0.3).timeout
	r["Ataque con carga: Charge mientras carga (%s), Shoot al soltar (%s)" % [charging, spr.current_anim()]] = \
		charging == "Charge" and spr.current_anim() == "Shoot"
	await get_tree().create_timer(0.6).timeout

	me.release_move({"move": _move(MoveData.Kind.MELEE, 90), "aim": Vector2.RIGHT, "step": 0})
	await get_tree().process_frame
	r["Golpe físico fuerte usa Swing"] = spr.current_anim() == "Swing"
	await get_tree().create_timer(0.6).timeout
	me.machine.transition_to(me.default_state())

	me.moves.dodge_cooldown = 0.0
	var dodged := me.dodge(Vector2.UP)
	await get_tree().process_frame
	r["Esquive (Espacio) usa Hop/Rotate/Tumble (%s)" % spr.current_anim()] = dodged \
		and spr.current_anim() in ["Hop", "Rotate", "Tumble"]

	var sleeper: Creature = autotest._dummy(world, "charmander", me.global_position + Vector2(0, 60))
	await get_tree().process_frame
	sleeper.statuses.apply(DB.statuses["dormido"])
	await get_tree().process_frame
	await get_tree().process_frame
	r["Dormido usa Sleep"] = sleeper.sprite.current_anim() == "Sleep"

	var victim: Creature = autotest._dummy(world, "charmander", me.global_position + Vector2(-60, 0))
	await get_tree().process_frame
	victim.machine.transition_to("fainted")
	await get_tree().create_timer(0.5).timeout
	r["Debilitado usa Faint/HitGround/LostBalance y se queda caído (%s)" % victim.sprite.current_anim()] = \
		victim.sprite.current_anim() in ["Faint", "HitGround", "LostBalance"]

	var plain: SpeciesData = null  # una especie sin Shoot: cae a Attack
	for sp: SpeciesData in DB.species_by_dex():
		var a := DB.anims_of(sp)
		if a.has("Attack") and not a.has("Shoot"):
			plain = sp
			break
	if plain != null:
		var p: Creature = world.spawner.spawn(plain, 10, me.global_position + Vector2(-60, 60))
		await get_tree().process_frame
		r["Sin Shoot (%s): el disparo cae a Attack" % plain.display_name] = p.sprite.pick("shoot") == "Attack"

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[anims] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-anims] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Ataque de prueba de Charmander (tipo Fuego) con la forma y potencia pedidas.
func _move(kind: MoveData.Kind, power: float) -> MoveData:
	var m := MoveData.new()
	m.id = "test_anim"
	m.display_name = "Prueba"
	m.element = DB.species["charmander"].types[0]
	m.kind = kind
	m.power = power
	return m
