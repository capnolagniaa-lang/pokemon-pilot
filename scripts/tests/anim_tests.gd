class_name AnimTests
extends Node
## Autotest de las animaciones de combate de SpriteCollab (tools/download_sprites.py → CreatureSprite.CHAINS):
##   godot --headless --path . --quit-after 30000 -- --autotest-anims
## Que las hojas nuevas existan y que la criatura elija la correcta al disparar, cargar, golpear, embestir,
## esquivar, dormirse y debilitarse (y que caiga a Attack si la especie no la tiene).

const DATA_SPECIES := ["charmander", "squirtle", "pikachu", "geodude", "pidgey"]
## Golpe (Strike) hecho con Qwen-Image 2.1 (tools/comfy/strike_sheet.py, docs/COMFYUI.md): no lo tenían en SpriteCollab.
const QWEN_STRIKE := ["bulbasaur", "squirtle", "pidgey", "rattata", "geodude"]

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

	for id in QWEN_STRIKE:
		var a := DB.anims_of(DB.species[id])
		var st: Dictionary = a.get("Strike", {})
		var own: bool = str(st.get("file", "")).ends_with("/Strike-Anim.png") and ResourceLoader.exists(st["file"])
		var tex: Texture2D = load(st["file"]) if own else null
		r["%s: golpe propio (Strike de 8 direcciones)" % id] = tex != null and tex.get_height() == int(st["h"]) * 8 and not a.has("QuickStrike")

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
	# La hoja Sleep tiene una sola fila (mira a la izquierda): se usa esa fila y se espeja si mira a la derecha.
	sleeper.facing = Vector2.RIGHT
	var cur: Array = sleeper.sprite._current()
	r["Dormido mirando a la derecha: fila 0, espejado"] = cur[1].position.y == 0.0 and cur[3]
	sleeper.facing = Vector2.LEFT
	cur = sleeper.sprite._current()
	r["Dormido mirando a la izquierda: fila 0, sin espejar"] = cur[1].position.y == 0.0 and not cur[3]
	var body := CreatureSprite._body_rect(cur[0], cur[1])
	r["Respiración: encuentra el cuerpo dentro del cuadro (%s)" % body] = body.size.y > 6 \
		and body.size.y < int(cur[1].size.y) + 1

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


## Vitrina: Pokémon dormidos (respiran y sueltan "z"), mirando a los dos lados. Los de arriba tienen ojos cerrados
## redibujados con Qwen (docs/COMFYUI.md); los de abajo, la hoja de PMD tal cual.
##   godot --path . --quit-after 220 --write-movie out/f.png --fixed-fps 30 -- --showcase-sleep
func showcase_sleep() -> void:
	var world: Node = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	world.companion.visible = false
	world.trainer.visible = false
	var base: Vector2 = world.trainer.global_position + Vector2(0, 110)
	var ids := ["charmander", "pikachu", "snorlax", "gyarados", "magikarp", "gastly", "beedrill", "butterfree"]
	for i in ids.size():
		for side in 2:
			var c: Creature = autotest._dummy(world, ids[i], base + Vector2(-147 + i * 42, -22 + side * 48))
			c.statuses.apply(DB.statuses["dormido"], 100.0)
			c.facing = Vector2.LEFT if side == 0 else Vector2.RIGHT
	world.camera.target = null
	world.camera.global_position = base
	for i in 210:  # (la cámara vuelve al zoom normal sola)
		world.camera.zoom = Vector2(3.6, 3.6)
		await get_tree().process_frame
	get_tree().quit()


## Vitrina: los golpes hechos con Qwen (arriba) contra el Attack de PMD que usaban antes (abajo), girando por las
## 8 direcciones.
##   godot --path . --quit-after 400 --write-movie out/f.png --fixed-fps 30 -- --showcase-strike
func showcase_strike() -> void:
	var world: Node = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	world.companion.visible = false
	world.trainer.visible = false
	var base: Vector2 = world.trainer.global_position + Vector2(0, 110)
	var rows: Array = []
	for i in QWEN_STRIKE.size():
		var pair: Array = []
		for side in 2:
			var c: Creature = autotest._dummy(world, QWEN_STRIKE[i], base + Vector2(-100 + i * 50, -24 + side * 52))
			c.set_physics_process(false)
			pair.append(c)
		rows.append(pair)
	world.camera.target = null
	world.camera.global_position = base
	var dirs := [Vector2.DOWN, Vector2(1, 1), Vector2.RIGHT, Vector2(1, -1), Vector2.UP, Vector2(-1, -1), Vector2.LEFT,
		Vector2(-1, 1)]
	for f in 390:
		world.camera.zoom = Vector2(3.4, 3.4)
		if f % 24 == 0:
			var d: Vector2 = dirs[(f / 48) % dirs.size()].normalized()
			for pair in rows:
				pair[0].facing = d
				pair[1].facing = d
				pair[0].sprite.play_chain("strike", 0.35)
				pair[1].sprite.play_once("Attack", 0.35)
		await get_tree().process_frame
	get_tree().quit()


## Ataque de prueba de Charmander (tipo Fuego) con la forma y potencia pedidas.
func _move(kind: MoveData.Kind, power: float) -> MoveData:
	var m := MoveData.new()
	m.id = "test_anim"
	m.display_name = "Prueba"
	m.element = DB.species["charmander"].types[0]
	m.kind = kind
	m.power = power
	return m
