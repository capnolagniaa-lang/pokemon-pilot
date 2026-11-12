class_name RogueKitTests
extends Node
## Autotest de los kits de 5 teclas del Modo Desafío (RogueKits, tools/build_desafio_kits.py): datos, herencia, básico
## gratis, movilidad en Espacio, definitiva con barra, tipos aplanados, cada ataque sale y tiene su animación.
##   godot --headless --path . --fixed-fps 60 --quit-after 120000 -- --autotest-rogue-kits
##   godot --path . --quit-after 1500 --write-movie out/f.png --fixed-fps 30 -- --showcase-rogue-kits  (los 3 kits en acción)

const SPECIES := ["charmander", "squirtle", "bulbasaur"]
const EVOLVED := {"charmander": "charizard", "squirtle": "wartortle", "bulbasaur": "ivysaur"}

var world: Node
var r := {}


func run_tests() -> void:
	# --- Datos ---
	for id: String in SPECIES:
		var kit := RogueKits.of(DB.species[id])
		var ok: bool = kit != null and kit.moves.size() == 4 and kit.moves.all(func(m): return m != null) and kit.mobility != null \
			and kit.role != ""
		r["%s tiene kit: %s" % [id.capitalize(), _kit_text(kit)]] = ok
		r["%s: su evolución (%s) usa el mismo kit" % [id.capitalize(), EVOLVED[id]]] = RogueKits.of(DB.species[EVOLVED[id]]) == kit
		if kit == null:
			continue
		var missing: Array = []
		for m: MoveData in kit.moves + [kit.mobility]:
			if not _has_animation(m):
				missing.append(m.display_name)
		r["%s: todos sus ataques tienen animación propia%s" % [id.capitalize(), "" if missing.is_empty() else " (faltan: %s)" % ", ".join(missing)]] = missing.is_empty()
	r["Un Pokémon sin kit en su línea no cambia (Pidgey)"] = RogueKits.of(DB.species["pidgey"]) == null
	r["Fuera del modo los tipos pesan lo de siempre"] = is_equal_approx(Damage.flat(2.0), 2.0) and is_equal_approx(Damage.flat(0.0), 0.0)
	var plain := CreatureInstance.create(DB.species["charmander"], 10)
	r["Fuera del modo Charmander no tiene kit"] = plain.rogue_kit == null

	# --- En una sala, con cada uno ---
	for id: String in SPECIES:
		await _play(id)

	var ok_all: bool = r.values().all(func(v): return v)
	for key in r:
		print("[kits] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-rogue-kits] -> ", "OK" if ok_all else "FALLO")
	GameState.rogue = {}
	get_tree().quit(0 if ok_all else 1)


func _kit_text(kit: Kit) -> String:
	if kit == null:
		return "no"
	return "%s · %s + %s" % [kit.role, ", ".join(kit.moves.map(func(m): return m.display_name if m != null else "?")),
		kit.mobility.display_name if kit.mobility != null else "?"]


## ¿Tiene alguna hoja de efecto que no sea la genérica de su tipo? (cuerpo, zona, pegada al Pokémon, chorro o rayo)
func _has_animation(m: MoveData) -> bool:
	for part in ["zona", "cuerpo", "chorro", "rayo"]:
		if DB.vfx_part(m, part) != null:
			return true
	if DB.vfx_sheet("res://sprites/fx/moves/%s.png" % m.id) != null:
		return true
	var official := DB._official_move_id(m.display_name)
	if official != "" and DB.vfx_sheet("res://sprites/fx/moves/%s.png" % official) != null:
		return true
	return m.kind == MoveData.Kind.WHIP  # (el látigo se dibuja por código: WhipLash)


func _start(id: String) -> RogueRun:
	GameState.rogue = {}
	RogueRun.begin(DB.species[id])
	GameState.rogue["biomes"] = ["bosque", "volcan", "cueva", "hielo", "costa"]
	GameState.rogue["rewards"] = ["bendicion", "bendicion", "bendicion", "bendicion", "bendicion"]
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
	world = null
	await get_tree().process_frame
	await get_tree().process_frame
	await _until(func(): return _world() != null and world.get("rogue") != null and world.rogue.phase == "oleada" \
		and is_instance_valid(world.companion) and not world.rogue.foes.is_empty(), 25.0)
	return world.rogue


## Un enemigo quieto al lado, que no ataca ni se muere.
func _dummy(run: RogueRun, me: Creature, at: Vector2) -> Creature:
	var foe: Creature = null
	for e: Creature in run.foes:
		if is_instance_valid(e) and not e.is_down():
			if foe == null:
				foe = e
			e.attack_gate = func(_c = null): return false
	if foe != null:
		foe.instance.hp_mult = 40.0
		foe.health.heal(999999.0)
		foe.global_position = me.global_position + at
	return foe


func _play(id: String) -> void:
	var name := id.capitalize()
	var run := await _start(id)
	if run == null or not is_instance_valid(world.companion):
		r["%s: arranca la partida" % name] = false
		return
	var me: Creature = world.companion
	var inst := me.instance
	var kit := inst.rogue_kit
	r["%s: en la partida pelea con su kit (%s)" % [name, kit.role if kit != null else "-"]] = kit != null and me.moves.kit == kit \
		and me.moves.slots[0] == kit.moves[0] and me.moves.slots[3] == kit.moves[3]
	if kit == null:
		return
	r["%s: en el modo los tipos pesan poco (×%.2f / ×%.2f, sin inmunidad)" % [name, Damage.flat(2.0), Damage.flat(0.0)]] = \
		is_equal_approx(Damage.flat(2.0), Damage.FLAT_STRONG) and is_equal_approx(Damage.flat(0.0), Damage.FLAT_WEAK)
	r["%s: el básico es gratis y las habilidades gastan PP (%d y %d)" % [name, int(me.moves.pp_cost(1)), int(me.moves.pp_cost(2))]] = \
		is_zero_approx(me.moves.pp_cost(0)) and me.moves.pp_cost(1) > 0.0 and me.moves.pp_cost(2) > 0.0 and is_zero_approx(me.moves.pp_cost(3))
	r["%s: la MT no sale de recompensa con kit" % name] = not run.rewards.available("mt")
	var foe := _dummy(run, me, Vector2(46, 0))
	await _wait(0.3)
	var aim := Vector2.RIGHT * 46.0
	# Definitiva: vacía no sale
	inst.ult = 0.0
	r["%s: con la barra vacía la definitiva no sale" % name] = not me.use_slot(3, aim, foe.global_position)
	# Básico: pega y carga la barra
	var hits := [0]
	var count := func(_t, _h, dmg): if dmg > 0.0: hits[0] += 1
	me.hit_dealt.connect(count)
	var t := 0.0
	while t < 4.0 and inst.ult <= 0.0:
		_hold(me, foe, Vector2(46, 0))
		me.use_slot(0, foe.global_position - me.global_position, foe.global_position)
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	r["%s: el básico (%s) pega y carga la definitiva (%d %%)" % [name, kit.moves[0].display_name, int(inst.ult * 100.0)]] = hits[0] > 0 and inst.ult > 0.0
	# Habilidades
	for slot in [1, 2]:
		await _ready_to_act(me, foe)
		me.moves.set_pp(me.moves.max_pp())
		me.moves.reset_cooldown(slot)
		var before := me.moves.pp()
		var used := me.use_slot(slot, foe.global_position - me.global_position, foe.global_position)
		r["%s: %s sale, gasta PP y queda en recarga" % [name, kit.moves[slot].display_name]] = used and me.moves.pp() < before \
			and me.moves.cooldowns[slot] > 0.5
		await _wait(1.0, me, foe)
	# Movilidad
	await _ready_to_act(me, foe)
	me.moves.dodge_cooldown = 0.0
	var from := me.global_position
	var dodged := [false]
	me.dodged.connect(func(): dodged[0] = true, CONNECT_ONE_SHOT)
	var moved := me.dodge(Vector2.LEFT, Vector2.RIGHT * 60.0)
	await _wait(0.5)
	r["%s: Espacio = %s (se mueve %d px, recarga %.1f s, cuenta como esquive)" % [name, kit.mobility.display_name,
		int(me.global_position.distance_to(from)), me.moves.dodge_total]] = moved and me.last_move == kit.mobility \
		and me.global_position.distance_to(from) > 12.0 and is_equal_approx(me.moves.dodge_total, kit.mobility.cooldown) and dodged[0]
	r["%s: en recarga no sale de nuevo" % name] = not me.dodge(Vector2.LEFT, Vector2.RIGHT * 60.0)
	await _wait(0.6)
	# Definitiva llena
	await _ready_to_act(me, foe)
	inst.ult = 1.0
	var ult_dmg := [0.0]  # (por el aviso del golpe y no por la vida: un muñeco Regenerador se cura al instante)
	var tally := func(_t, h, dmg): if h != null and h.move == kit.moves[3]: ult_dmg[0] += dmg
	me.hit_dealt.connect(tally)
	var fired := false
	for attempt in 3:  # (si un salvaje le corta la carga, la barra queda y se prueba de nuevo)
		await _ready_to_act(me, foe)
		me.statuses.clear()
		inst.ult = 1.0
		me.moves.reset_cooldown(3)
		fired = me.use_slot(3, foe.global_position - me.global_position, foe.global_position)
		await _wait(2.4, me, foe, false, 50.0)
		if ult_dmg[0] > 0.0:
			break
	var after_use := inst.ult
	me.hit_dealt.disconnect(tally)
	r["%s: con la barra llena sale %s, la vacía y pega (%d de daño)" % [name, kit.moves[3].display_name, int(ult_dmg[0])]] = 		fired and is_zero_approx(after_use) and ult_dmg[0] > 0.0
	# Subir de nivel no le cambia los ataques
	GameState.grant_exp(inst, 4000)
	r["%s: al subir de nivel (Nv. %d) sigue con su kit" % [name, inst.level]] = inst.level > 10 and inst.equipped_moves == kit.moves \
		and inst.rogue_kit == kit
	if me.hit_dealt.is_connected(count):
		me.hit_dealt.disconnect(count)


## Deja al muñeco donde va y lleno, y a vos también.
func _hold(me: Creature, foe: Creature, at: Vector2) -> void:
	if is_instance_valid(foe):
		foe.health.heal(999999.0)
		foe.global_position = me.global_position + at
		foe.velocity = Vector2.ZERO
	me.health.heal(999999.0)


func _ready_to_act(me: Creature, foe: Creature) -> void:
	var t := 0.0
	while t < 4.0 and not (me.can_act() and me.statuses.can_move()):
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
	if is_instance_valid(foe):
		foe.statuses.clear()
		foe.global_position = me.global_position + Vector2(46, 0)
	me.facing = Vector2.RIGHT


## `follow` > 0: el muñeco se queda adelante de donde mirás, a esa distancia (un canalizado gira hacia el mouse).
func _wait(time: float, me: Creature = null, foe: Creature = null, heal := true, follow := 0.0) -> void:
	var t := 0.0
	while t < time:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if me != null and is_instance_valid(me):
			me.health.heal(999999.0)
		if heal and foe != null and is_instance_valid(foe):
			foe.health.heal(999999.0)
		if follow > 0.0 and is_instance_valid(me) and is_instance_valid(foe):
			foe.global_position = me.global_position + me.facing.normalized() * follow
			foe.velocity = Vector2.ZERO


# --- Vitrina: cada kit tira sus 5 movimientos contra un muñeco ---

func showcase() -> void:
	for id: String in SPECIES:
		var run := await _start(id)
		var me: Creature = world.companion
		var foe := _dummy(run, me, Vector2(70, 0))
		for e: Creature in run.foes:
			if e != foe and is_instance_valid(e):
				e.global_position = me.global_position + Vector2(-400, -300)
		await _wait(0.6)
		for step in [0, 0, 0, 1, 2, 4, 0, 3]:
			await _ready_to_act(me, null)
			if is_instance_valid(foe):
				foe.global_position = me.global_position + Vector2(70, 0)
			var aim: Vector2 = Vector2(70, 0)
			if step == 4:
				me.moves.dodge_cooldown = 0.0
				me.dodge(Vector2.UP, aim)
			else:
				me.instance.ult = 1.0 if step == 3 else me.instance.ult
				me.moves.set_pp(me.moves.max_pp())
				me.moves.reset_cooldown(step)
				me.use_slot(step, aim, me.global_position + aim)
			await _wait(2.4 if step == 3 else (0.5 if step == 0 else 1.5), me, foe, true, 70.0 if step == 3 else 0.0)
	GameState.rogue = {}
	get_tree().quit(0)


func _world() -> Node:
	var s := get_tree().current_scene
	world = s if s != null and s.scene_file_path.ends_with("world.tscn") else null
	return world


func _until(cond: Callable, timeout: float) -> void:
	var t := 0.0
	while t < timeout and not cond.call():
		await get_tree().process_frame
		t += get_process_delta_time()
