class_name NpcPropTests
extends Node
## Lo que las personas tienen en la mano (NpcData.prop + NpcProp; pedido del usuario 2026-11-08: el empleado de la
## Tienda en la Ruta 1 fumándose un porro).
##   godot --headless --path . --quit-after 20000 -- --autotest-npc-prop
##   godot --path . --quit-after 160 --write-movie out/f.png --fixed-fps 30 -- --showcase-npc-prop

var autotest: Node
var world: Node
var r := {}


func run() -> void:
	var clerk := await _clerk()
	r["El empleado de la Ruta 1 tiene el porro"] = clerk != null and clerk.data.prop == "porro" and clerk.get_node_or_null("Prop") is NpcProp
	if clerk == null:
		_results()
		return
	var prop: NpcProp = clerk.get_node("Prop")
	r["Echa humo (el hilito de la brasa)"] = prop._smoke != null and prop._smoke.emitting
	prop._puff_in = 0.05
	await get_tree().create_timer(NpcProp.EXHALE_DELAY + 0.3).timeout
	r["Da una pitada: se aviva la brasa y larga una nube por la boca"] = prop.puffs >= 1 and prop._cloud.emitting
	# Sigue hacia dónde mira: de perfil adelante, de espaldas no se ve el porro.
	clerk.facing = Vector2i.LEFT
	var left := prop._hand()
	clerk.facing = Vector2i.RIGHT
	var right := prop._hand()
	r["El porro va del lado al que mira"] = left.x < 0.0 and right.x > 0.0
	var boy: StoryNPC = world.story.npcs.get("ruta1_boy")
	r["Los demás no tienen nada en la mano"] = boy == null or boy.get_node_or_null("Prop") == null
	r["Sigue dando la Poción de muestra"] = clerk.data.talks[0].give_items.has("pocion") \
		and "Poción" in " ".join(clerk.data.talks[0].lines)
	_results()


## La vitrina: el empleado de cerca, con humo y una pitada.
func showcase() -> void:
	var clerk := await _clerk()
	if clerk == null:
		get_tree().quit(1)
		return
	var prop: NpcProp = clerk.get_node("Prop")
	prop._puff_in = 1.2
	world.trainer.global_position = clerk.global_position + Vector2(-60, 30)  # (lejos: que no se dé vuelta a mirarlo)
	world.camera.target = clerk
	world.camera.zoom = Vector2(4, 4)
	world.camera.snap()
	world.get_node_or_null("UI/HUD").visible = false


func _clerk() -> StoryNPC:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.time_of_day = 15.0
	var npc: NpcData = DB.npcs.get("ruta1_martclerk")
	if npc == null:
		return null
	var data: WorldData = world.streamer.world_data
	var entry: ZoneEntry = null
	for z in data.zones:
		if z.id == npc.zone_id:
			entry = z
	var pos := Vector2((entry.origin + npc.cell + Vector2i(0, 2)) * data.tile_size) + Vector2.ONE * data.tile_size / 2.0
	world.streamer.load_around_now(pos)
	world.trainer.global_position = pos
	world.camera.snap()
	for i in 3:
		await get_tree().process_frame
	world.story.refresh()
	await get_tree().physics_frame
	return world.story.npcs.get("ruta1_martclerk")


func _results() -> void:
	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[npc-prop] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-npc-prop] -> %s" % ("OK" if ok else "FALLO"))
	get_tree().quit(0 if ok else 1)
