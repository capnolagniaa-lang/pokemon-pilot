class_name NightCombatTests
extends Node
## Autotest de día y noche, parte D (docs/PLAN_DIA_NOCHE.md): de noche los efectos de ataque no se oscurecen y sus luces
## crecen; los impactos que brillan iluminan un instante; los Pokémon de fuego alumbran con su llama. De día, todo
## como antes.
##   godot --headless --path . --quit-after 30000 -- --autotest-night-combat
## Vitrina (Charmander tirando Ascuas de noche en Pueblo Paleta):
##   godot --path . --quit-after 240 --write-movie out/f.png --fixed-fps 30 -- --showcase-night-combat

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	world = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	# De día.
	await _set_hour(12.0)
	var day_shot := await _shoot(me)
	r["De día un disparo queda como siempre (sin compensar, luz 0,3)"] = day_shot[0].is_equal_approx(Color.WHITE) \
		and (day_shot[1] < 0.0 or is_equal_approx(day_shot[1], 0.3))
	var glow: CreatureGlow = _glow(me)
	r["Charmander tiene llama (tipo fuego)"] = glow != null
	r["De día la llama no se nota"] = glow != null and glow._base < 0.05
	# De noche.
	await _set_hour(23.0)
	var dark := NightLight.darkness(me)
	r["De noche afuera está oscuro (%.2f)" % dark] = dark > 0.5
	var night_shot := await _shoot(me)
	r["De noche el disparo no se oscurece (color ×%.2f)" % night_shot[0].b] = night_shot[0].r > 1.2 and night_shot[0].b > 1.1
	r["De noche su luz crece (%.2f, tope %.2f)" % [night_shot[1], NightLight.NIGHT_MAX]] = night_shot[1] > 0.3 \
		and night_shot[1] <= NightLight.NIGHT_MAX + 0.001
	glow._update()
	r["De noche la llama de Charmander alumbra"] = glow._base > 0.2
	var foe: Creature = autotest._dummy(world, "bulbasaur", me.global_position + Vector2(40, 0))
	await get_tree().physics_frame
	var lights_before := _lights(world.entities)
	foe.hurtbox.receive(HitInfo.from(me, me.moves.slots[0]))
	await get_tree().process_frame
	r["De noche un impacto de fuego ilumina un instante"] = _lights(world.entities) > lights_before
	r["Un Pokémon que no es de fuego no tiene llama"] = _glow(foe) == null
	GameState.set_setting("time_lock", -1.0)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[noche] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-night-combat] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	GameState.set_setting("time_lock", 22.5)
	var me: Creature = world.companion
	var foe: Creature = autotest._dummy(world, "bulbasaur", me.global_position + Vector2(70, 0))
	for k in 6:
		await get_tree().create_timer(0.7).timeout
		me.moves.reset_cooldown(0)
		me.use_slot(0, Vector2.RIGHT, foe.global_position)


func _set_hour(h: float) -> void:
	GameState.set_setting("time_lock", h)
	for k in 3:
		await get_tree().process_frame


## Dispara Ascuas y devuelve [modulate del primer proyectil, energía de su luz (-1 si no tiene)].
func _shoot(me: Creature) -> Array:
	var before: Array = world.entities.get_children()
	me.moves.reset_cooldown(0)
	if me.machine.current_name() != "controlled":
		me.machine.transition_to("controlled")
	await get_tree().physics_frame
	me.use_slot(0, Vector2.RIGHT, me.global_position + Vector2(80, 0))
	await get_tree().physics_frame
	for n in world.entities.get_children():
		if n is Projectile and not n in before:
			var energy := -1.0
			for c in n.get_children():
				if c is PointLight2D:
					energy = c.energy
			return [n.modulate, energy]
	return [Color.WHITE, -1.0]


func _glow(c: Creature) -> CreatureGlow:
	for n in c.get_children():
		if n is CreatureGlow:
			return n
	return null


func _lights(parent: Node) -> int:
	return parent.get_children().filter(func(n): return n is PointLight2D).size()
