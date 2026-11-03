class_name ShinyTests
extends Node
## Autotest de los shiny (CreatureInstance.shiny, ajuste shiny_odds, sprites de sprites/pokemon/<n.º>/shiny/, ShinySparkle):
##   godot --headless --path . --quit-after 30000 -- --autotest-shiny

var autotest: Node


func run() -> void:
	var r := {}
	GameState.new_game(DB.species["charmander"])
	r["Por defecto sale 1 de cada 1024"] = int(GameState.setting("shiny_odds")) == 1024
	GameState.set_setting("shiny_odds", 1)
	var all_shiny := range(20).all(func(_i): return CreatureInstance.create(DB.species["pidgey"], 5).shiny)
	GameState.set_setting("shiny_odds", 0)
	var none := range(50).all(func(_i): return not CreatureInstance.create(DB.species["pidgey"], 5).shiny)
	r["Con 1 de cada 1 salen todos shiny; con 0, ninguno"] = all_shiny and none
	var s := CreatureInstance.create(DB.species["pikachu"], 10)
	s.shiny = true
	var back := CreatureInstance.from_dict(s.to_dict())
	var old := s.to_dict()
	old.erase("shiny")
	r["Se guarda y una partida vieja no tiene shiny"] = back.shiny and not CreatureInstance.from_dict(old).shiny
	r["En los menús lleva estrella"] = s.label().ends_with("★") and not back.display_name().contains("★")
	var anims := DB.anims_of(DB.species["pikachu"], true)
	var normal := DB.anims_of(DB.species["pikachu"])
	r["Las hojas shiny salen de la carpeta shiny (mismos cuadros)"] = str(anims["Idle"]["file"]).contains("/shiny/") \
		and anims["Idle"]["w"] == normal["Idle"]["w"] and not str(normal["Idle"]["file"]).contains("/shiny/") \
		and DB.portrait_of(DB.species["pikachu"], true) != null
	var with_sheets := DB.species.values().filter(func(sp): return str(DB.anims_of(sp, true).get("Idle", {}).get("file", "")).contains("/shiny/"))
	r["Hay Idle shiny para casi todas (%d de 386)" % with_sheets.size()] = with_sheets.size() >= 370

	var world: Node = await autotest._setup_kit_world("charmander")
	GameState.set_setting("shiny_odds", 1)  # (después: la partida nueva vuelve a los ajustes de siempre)
	var wild: Creature = world.spawner.spawn(DB.species["rattata"], 5, world.companion.global_position + Vector2(80, 0))
	await get_tree().process_frame
	r["Un salvaje shiny aparece con destello y sprite shiny"] = wild.instance.shiny and wild.sprite.shiny \
		and wild.get_children().any(func(c): return c is ShinySparkle)
	GameState.set_setting("shiny_odds", 1024)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[shiny] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-shiny] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)
