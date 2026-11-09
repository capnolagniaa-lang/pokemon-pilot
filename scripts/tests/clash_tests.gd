class_name ClashTests
extends Node
## Choque de proyectiles: gana el más fuerte (potencia × efectividad), parejos se destruyen los dos, y el que gana sigue con
## menos daño. Del mismo bando se destruyen los dos siempre; del mismo Pokémon no chocan.
##   godot --headless --path . --fixed-fps 60 --quit-after 20000 -- --autotest-clash
##   godot --path . --quit-after 200 --write-movie out/f.png --fixed-fps 30 -- --showcase-clash

var autotest: Node
var world: Node
var r := {}
var me: Creature
var foe: Creature
var spot := Vector2.ZERO
var heard: Array = []


func run() -> void:
	await _setup("charmander")
	Events.projectiles_clashed.connect(func(_parent, _at, a, b, _axis, strong): heard.append([a, b, strong]))

	var pair := await _shoot("ascuas", "ascuas")
	r["Iguales: se destruyen los dos"] = pair[0] == null and pair[1] == null
	r["Avisa el choque"] = heard.size() == 1

	pair = await _shoot("pistola_agua", "ascuas")
	r["Agua contra Fuego de igual potencia: gana el Agua"] = pair[0] != null and pair[1] == null
	if pair[0] != null:
		r["El que gana sigue con menos daño (%.2f)" % pair[0].hit.damage_mult] = pair[0].hit.damage_mult < _base_mult(me, "pistola_agua")
		r["Y no se frena"] = pair[0].velocity.length() > 0.0
		pair[0].queue_free()

	pair = await _shoot("ascuas", "hidrobomba")
	r["Uno mucho más fuerte pasa: gana Hidrobomba"] = pair[0] == null and pair[1] != null
	if pair[1] != null:
		r["Le queda casi todo el daño"] = pair[1].hit.damage_mult > _base_mult(foe, "hidrobomba") * 0.7
		pair[1].queue_free()

	heard.clear()
	pair = await _shoot("llamarada", "llamarada")
	r["Los fuertes hacen el choque grande (con anillo)"] = not heard.is_empty() and heard[0][2]
	heard.clear()
	pair = await _shoot("ascuas", "ascuas")
	r["Los chicos, sin anillo"] = not heard.is_empty() and not heard[0][2]

	# Del mismo Pokémon no chocan (un abanico no se destruye solo).
	var a := _projectile(me, "ascuas", spot + Vector2(-24, 0), Vector2.RIGHT)
	var b := _projectile(me, "ascuas", spot + Vector2(24, 0), Vector2.LEFT)
	await _wait(0.16)
	r["Los del mismo Pokémon se cruzan"] = is_instance_valid(a) and is_instance_valid(b)
	_free([a, b])

	# Del mismo bando, de otro Pokémon: se destruyen los dos, aunque uno sea mucho más fuerte.
	var ally: Creature = preload("res://scenes/creatures/creature.tscn").instantiate()
	ally.instance = CreatureInstance.create_rival(DB.species["vulpix"], 40)
	ally.team = Creature.Team.ALLY
	ally.position = spot + Vector2(0, -130)
	world.entities.add_child(ally)
	await get_tree().physics_frame
	a = _projectile(me, "hidrobomba", spot + Vector2(-24, 0), Vector2.RIGHT)
	b = _projectile(ally, "ascuas", spot + Vector2(24, 0), Vector2.LEFT)
	await _wait(0.16)
	r["Del mismo bando chocan y no sigue ninguno"] = not (is_instance_valid(a) and not a._dead) and not (is_instance_valid(b) and not b._dead)
	ally.queue_free()
	await get_tree().physics_frame

	# El disparo que no gana no le saca daño a los otros disparos del mismo ataque (comparten HitInfo).
	var shared := HitInfo.from(me, DB.moves["pistola_agua"])
	var one := Projectile.new()
	var two := Projectile.new()
	me.get_parent().add_child(one)
	me.get_parent().add_child(two)
	one.launch(shared, spot + Vector2(-30, 0), Vector2.RIGHT)
	two.launch(shared, spot + Vector2(-30, -35), Vector2.RIGHT)
	var enemy := _projectile(foe, "ascuas", spot + Vector2(30, 0), Vector2.LEFT)
	await _wait(0.18)
	r["Solo se debilita el que chocó"] = is_instance_valid(one) and is_instance_valid(two) and one.hit != two.hit and one.hit.damage_mult < two.hit.damage_mult
	r["El HitInfo compartido no cambia"] = is_instance_valid(two) and is_equal_approx(two.hit.damage_mult, _base_mult(me, "pistola_agua"))
	_free([one, two, enemy])

	# El que gana le pega de verdad al rival, con menos daño que sin chocar.
	var clean := await _damage_on_foe(false)
	var after := await _damage_on_foe(true)
	r["Sin chocar pega (%.0f)" % clean] = clean > 0.0
	r["Después de ganar un choque pega menos (%.0f)" % after] = after > 0.0 and after < clean

	# Sin hojas no se rompe nada, y las hojas están.
	r["Las hojas están"] = DB.vfx_sheet("res://sprites/fx/clash/destello.png") != null and DB.vfx_sheet("res://sprites/fx/clash/anillo.png") != null

	var ok := true
	for k: String in r:
		print("[clash] %s: %s" % [k, "OK" if r[k] else "FALLO"])
		ok = ok and r[k]
	print("[autotest-clash] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)


## Vitrina: choques parejos, con ganador y en diagonal.
func showcase() -> void:
	await _setup("squirtle")
	world.get_node("UI").visible = false
	world.trainer.global_position = spot + Vector2(0, -38)  # (la cámara lo sigue: que el choque quede en el medio)
	await get_tree().create_timer(0.5).timeout
	foe.global_position = spot + Vector2(0, 90)
	me.global_position = spot + Vector2(0, -90)
	var rounds := [["llamarada", "hidrobomba", Vector2.RIGHT], ["ascuas", "ascuas", Vector2.RIGHT],
		["llamarada", "llamarada", Vector2(1, 1).normalized()], ["pistola_agua", "rayo_hielo", Vector2(1, -1).normalized()]]
	for round_data: Array in rounds:
		var dir: Vector2 = round_data[2]
		print("[showcase] ", round_data[0], " vs ", round_data[1], " cuadro ", Engine.get_frames_drawn())
		_projectile(me, round_data[0], spot - dir * 50.0, dir)
		_projectile(foe, round_data[1], spot + dir * 50.0, -dir)
		await get_tree().create_timer(1.2).timeout
	get_tree().quit()


## Un caso para grabar (`--scenario <nombre>`): dos Pokémon de verdad se disparan, con su carga, su daño y sus sonidos.
const SCENARIOS := {
	"parejos_chico": ["Parejos, ataques chicos: se destruyen los dos", "charmander", "ascuas", "vulpix", "ascuas"],
	"parejos_grande": ["Parejos, ataques fuertes: choque grande, con anillo", "charmander", "llamarada", "vulpix", "llamarada"],
	"gana_por_tipo": ["Agua le gana a Fuego: sigue, con menos daño", "squirtle", "pistola_agua", "charmander", "ascuas"],
	"mucho_mas_fuerte": ["Mucho más fuerte: pasa casi entero", "squirtle", "hidrobomba", "charmander", "ascuas"],
	"fuertes_con_ganador": ["Dos fuertes, gana Agua: Hidrobomba contra Llamarada", "squirtle", "hidrobomba", "charmander", "llamarada"],
	"estado_pierde": ["Un disparo sin potencia pierde siempre", "squirtle", "rayo_hielo", "charmander", "disparo_demora"],
	"diagonal": ["En diagonal: las mitades siguen el ángulo", "squirtle", "pistola_agua", "charmander", "llamarada"],
	"mismo_bando": ["Del mismo bando: chocan y no sigue ninguno", "squirtle", "hidrobomba", "vulpix", "ascuas"],
}


func scenario(id: String) -> void:
	var data: Array = SCENARIOS[id]
	world = await autotest._setup_kit_world(data[1])
	var finder := BalanceTests.new()
	finder.world = world
	spot = finder._open_spot()
	finder.free()
	var dir := Vector2(1, 0.6).normalized() if id == "diagonal" else Vector2.RIGHT
	me = world.companion
	me.instance.level = 40
	me.instance.hp = me.instance.max_hp()

	me.global_position = spot - dir * 65.0
	world.trainer.global_position = spot + Vector2(0, -60)
	if id == "mismo_bando":
		foe = preload("res://scenes/creatures/creature.tscn").instantiate()
		foe.instance = CreatureInstance.create_rival(DB.species[data[3]], 40)
		foe.team = Creature.Team.ALLY
		foe.position = spot + dir * 65.0
		world.entities.add_child(foe)
	else:
		foe = autotest._dummy(world, data[3], spot + dir * 65.0, false)
	await get_tree().physics_frame
	me.machine.transition_to("controlled")
	foe.machine.transition_to("controlled")
	me.facing = dir
	foe.facing = -dir
	var layer := CanvasLayer.new()
	layer.layer = 20
	var label := Label.new()
	label.text = data[0]
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 8)
	label.position = Vector2(40, 90)
	layer.add_child(label)
	add_child(layer)
	await get_tree().create_timer(0.5).timeout
	print("[video] inicio ", Engine.get_frames_drawn())
	await get_tree().create_timer(0.6).timeout
	me.moves.slots[1] = DB.moves[data[2]]
	foe.moves.slots[1] = DB.moves[data[4]]
	# El que carga más arranca antes, para que los dos disparos salgan juntos y se encuentren en el medio.
	var mine_first: bool = DB.moves[data[2]].cast_time >= DB.moves[data[4]].cast_time
	var gap: float = absf(DB.moves[data[2]].cast_time - DB.moves[data[4]].cast_time)
	if mine_first:
		me.force_move(data[2], dir, foe.global_position)
	else:
		foe.force_move(data[4], -dir, me.global_position)
	if gap > 0.0:
		await get_tree().create_timer(gap).timeout
	if mine_first:
		foe.force_move(data[4], -dir, me.global_position)
	else:
		me.force_move(data[2], dir, foe.global_position)
	await get_tree().create_timer(2.2).timeout
	get_tree().quit()


func _setup(species: String) -> void:
	world = await autotest._setup_kit_world(species)
	world.combat.end_battle()
	world.companion.set_captured(true)
	var finder := BalanceTests.new()
	finder.world = world
	spot = finder._open_spot()
	finder.free()
	world.trainer.global_position = spot + Vector2(0, -130)
	me = world.companion
	me.team = Creature.Team.ALLY
	me.global_position = spot + Vector2(0, -80)
	foe = autotest._dummy(world, "squirtle", spot + Vector2(0, 80))
	await get_tree().physics_frame


func _projectile(user: Creature, move_id: String, at: Vector2, dir: Vector2) -> Projectile:
	var p := Projectile.new()
	user.get_parent().add_child(p)
	p.launch(HitInfo.from(user, DB.moves[move_id]), at, dir)
	return p


## Dos disparos de frente: devuelve los que sobrevivieron al choque ([tuyo, rival]; null = destruido).
func _shoot(mine: String, theirs: String) -> Array:
	var a := _projectile(me, mine, spot + Vector2(-24, 0), Vector2.RIGHT)
	var b := _projectile(foe, theirs, spot + Vector2(24, 0), Vector2.LEFT)
	await _wait(0.16)
	return [a if is_instance_valid(a) and not a._dead else null, b if is_instance_valid(b) and not b._dead else null]


func _damage_on_foe(clash: bool) -> float:
	foe.instance.hp = foe.instance.max_hp()
	foe.health.invulnerable_time = 0.0
	var before: float = foe.instance.hp
	var at: Vector2 = foe.global_position + Vector2(-50, -8)
	var seed_copy := _projectile(me, "hidrobomba", at, Vector2.RIGHT)
	if clash:
		_projectile(foe, "ascuas", at + Vector2(16, 0), Vector2.LEFT)
	var time := 0.0
	while foe.instance.hp >= before and time < 1.0 and is_instance_valid(seed_copy):
		await get_tree().physics_frame
		time += get_physics_process_delta_time()
	await _wait(0.1)
	return before - foe.instance.hp


func _base_mult(user: Creature, move_id: String) -> float:
	return HitInfo.from(user, DB.moves[move_id]).damage_mult


func _wait(time: float) -> void:
	await get_tree().create_timer(time, true, true).timeout


func _free(list: Array) -> void:
	for p in list:
		if is_instance_valid(p):
			p.queue_free()
