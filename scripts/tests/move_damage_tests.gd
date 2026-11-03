class_name MoveDamageTests
extends Node
## Cuánto pega de verdad cada ataque en el juego (no en los papeles): un Pokémon se lo tira a un muñeco quieto y se
## mide la vida que le saca, golpe por golpe (cuántos golpes conecta y cuánto cada uno), contra lo que da la fórmula.
##   godot --headless --path . --quit-after 60000 -- --autotest-move-damage [--moves a,b,c] [--species kadabra]

const DEFAULT_MOVES := ["confusion", "psiquico", "premonicion"]
const TRIES := 4

var autotest: Node


func run() -> void:
	var args := OS.get_cmdline_user_args()
	var moves: Array = DEFAULT_MOVES
	var species := "kadabra"
	for i in args.size() - 1:
		if args[i] == "--moves":
			moves = args[i + 1].split(",")
		elif args[i] == "--species":
			species = args[i + 1]
	var world: Node = await autotest._setup_kit_world(species)
	var me: Creature = world.companion
	me.instance.level = 30
	me.instance.hp = me.instance.max_hp()
	GameState.set_setting("pp_mode", false)  # que los PP no frenen la prueba
	var dummy: Creature = autotest._dummy(world, "snorlax", me.global_position + Vector2(48, 0))  # mucha vida: no se muere
	dummy.instance.level = 30
	dummy.instance.hp = dummy.instance.max_hp()
	var ok := true
	var rows := []
	var keys := ["Clic izq.", "Clic der.", "Q", "R"]
	for id in moves:
		var m: MoveData = DB.moves.get(id)
		if m == null:
			print("[daño] no existe el ataque ", id)
			ok = false
			continue
		for slot in [0, 1, 3]:
			for i in me.moves.slots.size():
				me.moves.slots[i] = null
			me.moves.slots[slot] = m
			rows.append(await _measure(me, dummy, m, slot, keys[slot]))
	for row in rows:
		print("[daño] %-12s potencia %3d en %-9s | en el juego %6.1f por uso (%.1f golpes) | fórmula %6.1f" % row)
	print("[autotest-move-damage] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func _measure(me: Creature, dummy: Creature, m: MoveData, slot: int, key: String) -> Array:
	var total := 0.0
	var hits := 0
	for t in TRIES:
		dummy.instance.hp = dummy.instance.max_hp()
		dummy.global_position = me.global_position + Vector2(48, 0)
		me.moves.reset_cooldown(slot)
		me.moves.gap_left = 0.0
		var before := dummy.instance.hp
		var last := before
		me.use_slot(slot, Vector2.RIGHT, dummy.global_position)
		var clock := 0.0
		while clock < 3.0:
			await get_tree().physics_frame
			clock += get_physics_process_delta_time()
			if dummy.instance.hp < last - 0.01:
				hits += 1
				last = dummy.instance.hp
		total += before - dummy.instance.hp
	var hit := HitInfo.from(me, m)
	var formula := Damage.resolve(hit, dummy.instance) / 0.925  # sin el azar (0,85-1)
	return [m.display_name, m.power, key, total / TRIES, float(hits) / TRIES, formula]
