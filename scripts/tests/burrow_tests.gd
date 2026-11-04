class_name BurrowTests
extends Node
## Excavar en dos tiempos (`Burrow`) y el stagger:
##   godot --headless --path . --quit-after 60000 -- --autotest-burrow


## Teclas de mentira: lo que el test diga.
class FakeInput extends CombatInput:
	var held := -1
	var dir := Vector2.ZERO

	func move_dir(_actor: Creature) -> Vector2:
		return dir

	func aim(_actor: Creature) -> Vector2:
		return Vector2.RIGHT * 20.0

	func aim_point(actor: Creature) -> Vector2:
		return actor.global_position + Vector2.RIGHT * 20.0

	func wants_slot(slot: int) -> bool:
		return slot == held

	func wants_dodge() -> bool:
		return false


var autotest: Node
var world: Node
var r := {}


func run() -> void:
	world = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	var keys := FakeInput.new()
	me.input_source = keys
	me.machine.transition_to("controlled")
	var dig: MoveData = DB.moves["excavar"]
	me.moves.slots[0] = dig
	var p := me.global_position
	var foe: Creature = autotest._dummy(world, "rattata", p + Vector2(60, 0))
	await get_tree().physics_frame
	await _stagger_check(me, foe)
	var normal: float = me.speed()
	var hp0: float = foe.instance.hp

	# Primer toque: se mete
	keys.held = 0
	await _frames(3)
	r["Primer toque: queda bajo tierra, no se ve"] = me.is_burrowed() and not me.sprite.visible
	r["Bajo tierra va un 10 % más rápido"] = absf(me.speed() / normal - 1.1) < 0.001
	r["Bajo tierra no le pegan"] = _no_damage_from(foe, me)
	await _frames(3)
	r["Bajo tierra los disparos pasan (sin hurtbox)"] = not me.hurtbox.monitorable
	me.moves.reset_cooldown(1)
	r["Bajo tierra no sale otro ataque"] = not me.use_slot(1, Vector2.RIGHT)
	r["Bajo tierra no esquiva"] = not me.dodge(Vector2.RIGHT)

	# Mantener la tecla no lo saca
	await get_tree().create_timer(0.5).timeout
	r["Mantener la tecla apretada no lo saca"] = me.is_burrowed()

	# Se mueve y pasa por debajo del rival
	keys.held = -1
	keys.dir = Vector2.RIGHT
	await _until(func() -> bool: return me.global_position.x > foe.global_position.x + 4.0, 2.0)
	r["Se mueve y pasa por debajo de un rival"] = me.global_position.x > foe.global_position.x + 4.0 and me.is_burrowed()
	keys.dir = Vector2.ZERO

	# Segundo toque: sale y pega ahí
	var at := me.global_position
	keys.held = 0
	await _frames(3)
	keys.held = -1
	await get_tree().create_timer(0.1).timeout
	r["Segundo toque: sale donde está"] = not me.is_burrowed() and me.sprite.visible and me.global_position.distance_to(at) < 6.0
	r["Al salir le pega al de al lado"] = foe.instance.hp < hp0
	r["Al salir arranca la recarga"] = me.moves.cooldowns[0] > 0.0
	r["Al salir vuelve a chocar y a recibir golpes"] = me.collision_layer != 0
	await _frames(3)
	r["...y vuelve a tener hurtbox"] = me.hurtbox.monitorable
	await _until(func() -> bool: return me.machine.current_name() == "controlled", 1.0)

	# Sale solo al terminar el tiempo
	me.moves.reset_cooldown(0)
	me.moves.set_pp(me.moves.max_pp())
	var hp1: float = foe.instance.hp
	r["Se usa de nuevo"] = me.use_slot(0, Vector2.RIGHT)
	await get_tree().create_timer(dig.burrow_time - 0.5).timeout
	r["Sigue abajo hasta el final del tiempo (%.0f s)" % dig.burrow_time] = me.is_burrowed()
	await get_tree().create_timer(0.8).timeout
	r["Sale solo al terminar y golpea"] = not me.is_burrowed() and foe.instance.hp < hp1
	await _until(func() -> bool: return me.machine.current_name() == "controlled", 1.0)

	# Copia del rival online: entra y sale con los avisos, no sola
	me.moves.reset_cooldown(0)
	r["Online: el primer aviso lo mete"] = me.force_move("excavar", Vector2.RIGHT) and me.is_burrowed() and me.burrow.remote
	await get_tree().create_timer(dig.burrow_time + 0.3).timeout
	r["Online: no sale solo, espera el aviso"] = me.is_burrowed()
	r["Online: el segundo aviso lo saca"] = me.force_move("excavar", Vector2.RIGHT) and not me.is_burrowed()
	await _until(func() -> bool: return me.machine.current_name() == "controlled", 1.0)

	# Online: si tu pantalla y el servidor no coinciden, manda el servidor (después de la demora normal de la red)
	OnlineBattle.sync_burrow(me, true)
	r["Online: la demora normal de la red no lo mueve"] = not me.is_burrowed()
	await get_tree().create_timer(OnlineBattle.BURROW_SLACK + 0.1).timeout
	OnlineBattle.sync_burrow(me, true)
	r["Online: el servidor dice abajo y acá no: entra"] = me.is_burrowed() and me.burrow.remote
	OnlineBattle.sync_burrow(me, true)
	OnlineBattle.sync_burrow(me, false)
	await get_tree().create_timer(OnlineBattle.BURROW_SLACK + 0.1).timeout
	OnlineBattle.sync_burrow(me, false)
	r["Online: el servidor dice arriba y acá no: sale, sin golpear de nuevo"] = not me.is_burrowed() and me.sprite.visible
	await _until(func() -> bool: return me.machine.current_name() == "controlled", 1.0)

	# Terminar la pelea bajo tierra
	me.moves.reset_cooldown(0)
	me.use_slot(0, Vector2.RIGHT)
	world.combat.end_battle()
	await _frames(4)
	r["Si termina la pelea abajo, vuelve a verse"] = not me.is_burrowed() and me.sprite.visible
	await _ai_uses_it()

	var ok := true
	for k: String in r:
		print("[excavar] %s %s" % ["OK   " if r[k] else "FALLO", k])
		ok = ok and r[k]
	print("[autotest-burrow] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)


## Stagger +15 %: Placaje (40) 0,272 → 0,313 s.
func _stagger_check(me: Creature, foe: Creature) -> void:
	r["Stagger: el mínimo, el máximo y el de cada punto de potencia subieron 15 %"] = is_equal_approx(Creature.HITSTUN_MIN, 0.23) \
		and is_equal_approx(Creature.HITSTUN_MAX, 0.5175 + 0.0025) and is_equal_approx(Creature.HITSTUN_PER_POWER, 0.00207)
	var tackle: MoveData = DB.moves["placaje"]
	foe.hurtbox.receive(HitInfo.from(me, tackle))
	r["Stagger: Placaje deja 0,31 s"] = absf(foe.hitstun_left - 0.313 * clampf(0.5 + foe.statuses.knockback_mult() * 0.5, 0.5, 1.0)) < 0.03
	await get_tree().create_timer(0.8).timeout


func _no_damage_from(foe: Creature, me: Creature) -> bool:
	var before: float = me.instance.hp
	me.hurtbox.receive(HitInfo.from(foe, DB.moves["placaje"]))
	return me.instance.hp == before


## La IA: se mete, va hasta abajo tuyo y sale pegándote.
func _ai_uses_it() -> void:
	world.combat.start_battle()
	await get_tree().physics_frame
	var me: Creature = world.companion
	me.input_source = null
	me.machine.transition_to("controlled")
	var rival: Creature = autotest._dummy(world, "sandshrew", me.global_position + Vector2(110, 0), false)
	await get_tree().physics_frame
	rival.moves.slots[0] = DB.moves["excavar"]
	rival.target = me
	rival.machine.transition_to("attack")
	var hp0: float = me.instance.hp
	rival.use_slot(0, Vector2.LEFT)
	r["IA: se mete bajo tierra"] = rival.is_burrowed()
	await _until(func() -> bool: return not rival.is_burrowed(), 3.5)
	await get_tree().create_timer(0.15).timeout
	r["IA: sale cerca tuyo y te pega"] = not rival.is_burrowed() and rival.global_position.distance_to(me.global_position) < 34.0 and me.instance.hp < hp0


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _until(cond: Callable, seconds: float) -> void:
	var left := seconds
	while left > 0.0 and not cond.call():
		await get_tree().physics_frame
		left -= get_physics_process_delta_time()
