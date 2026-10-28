class_name SettingsTests
extends Node
## Autotest de los Ajustes del juego por partida (Esc → Opciones → Ajustes del juego; GameState.settings):
##   godot --headless --path . --quit-after 30000 -- --autotest-settings

var autotest: Node
var world: Node


func run() -> void:
	var r := {}
	GameState.new_game(DB.species["charmander"])
	r["Una partida nueva arranca con los valores de siempre (EXP ×0,5, vida ×3)"] = GameState.settings.is_empty() \
		and is_equal_approx(GameState.setting("exp_mult"), DB.config.exp_multiplier) \
		and is_equal_approx(CreatureInstance.hp_scale(), CreatureInstance.HP_SCALE)
	var foe := CreatureInstance.create(DB.species["rattata"], 10)
	var exp0 := CreatureInstance.exp_yield(foe)
	GameState.set_setting("exp_mult", float(GameState.setting("exp_mult")) * 2.0)
	r["Experiencia ×2 → el doble de EXP"] = abs(CreatureInstance.exp_yield(foe) - exp0 * 2) <= 1
	var inst: CreatureInstance = GameState.party[0]
	var max0 := inst.max_hp()
	inst.hp = max0 * 0.5
	GameState.set_setting("hp_scale", CreatureInstance.HP_SCALE * 2.0)
	r["Vida ×2: el doble de vida y la actual se reescala (sigue a la mitad)"] = is_equal_approx(inst.max_hp(), max0 * 2.0) \
		and is_equal_approx(inst.hp / inst.max_hp(), 0.5)
	var money0 := GameState.money
	GameState.set_setting("money_mult", 2.0)
	GameState.add_prize(100)
	r["Dinero de los premios ×2"] = GameState.money == money0 + 200
	var c0 := Capture.catch_value(foe, 1.0)
	GameState.set_setting("catch_mult", 2.0)
	r["Captura ×2"] = is_equal_approx(Capture.catch_value(foe, 1.0), c0 * 2.0)
	GameState.set_setting("ai_dodge", 0.9)
	GameState.set_difficulty("personalizado")
	r["Dificultad personalizada con los ajustes de la IA"] = GameState.difficulty_id() == "personalizado" \
		and is_equal_approx(CombatBody.difficulty().dodge_chance, 0.9)
	GameState.set_setting("ai_dodge", 0.7)
	r["Cambiar un ajuste de la IA actualiza la personalizada"] = is_equal_approx(CombatBody.difficulty().dodge_chance, 0.7)
	# Se guardan con la partida.
	var d := GameState.to_dict()
	GameState.new_game(DB.species["squirtle"])
	r["Otra partida nueva vuelve a los de siempre"] = GameState.settings.is_empty() and GameState.difficulty_id() == "normal"
	GameState.from_dict(d)
	r["Cargar la partida trae sus ajustes y su dificultad personalizada"] = is_equal_approx(GameState.setting("money_mult"), 2.0) \
		and GameState.difficulty_id() == "personalizado" and is_equal_approx(CombatBody.difficulty().dodge_chance, 0.7)
	var old := GameState.to_dict()
	old.erase("settings")
	GameState.from_dict(old)
	r["Una partida vieja (sin ajustes) usa los de siempre"] = GameState.settings.is_empty()
	GameState.from_dict(d)

	# En el mundo: daño, salvajes, curación sola.
	world = await autotest._setup_kit_world("charmander")
	var me: Creature = world.companion
	GameState.set_setting("dealt_mult", 2.0)
	r["Daño que hacés ×2"] = HitInfo.from(me, me.moves.slots[0]).damage_mult >= 1.99
	GameState.set_setting("wild_mult", 0.0)
	r["Cantidad de salvajes ×0 → no aparece ninguno"] = world.spawner.max_alive(world.streamer.current.id) == 0
	world.combat.end_battle()
	GameState.set_setting("regen", true)
	var mine: CreatureInstance = GameState.party[0]
	mine.hp = mine.max_hp() * 0.5
	var h0 := mine.hp
	await get_tree().create_timer(1.0).timeout
	r["Curación sola fuera de combate (si la prendés)"] = mine.hp > h0
	# La pantalla: mover un deslizador cambia el ajuste.
	var layer := CanvasLayer.new()
	add_child(layer)
	var screen := GameSettingsScreen.new()
	layer.add_child(screen)
	await get_tree().process_frame
	(screen.controls["taken_mult"] as HSlider).value = 0.5
	(screen.controls["field_items"] as CheckBox).button_pressed = false
	r["La pantalla cambia los ajustes (daño recibido ×0,5, sin objetos)"] = is_equal_approx(GameState.setting("taken_mult"), 0.5) \
		and GameState.setting("field_items") == false
	GameState.reset_settings()
	screen.refresh()
	r["Valores por defecto"] = GameState.settings.is_empty() \
		and is_equal_approx((screen.controls["taken_mult"] as HSlider).value, 1.0)

	# --- Árboles y pasto alto hechos con IA (TilePack): se prenden y apagan en el momento ---
	var ts: TileSet = load(ZoneBuilder.TILESET_PATH)
	var src := TilePack._source(ts, TilePack.GENERAL_BELOW)
	GameState.set_setting("tile_pack", true)
	r["Árboles nuevos: el atlas usa el paquete"] = TilePack.is_on() and src.texture is ImageTexture
	GameState.set_setting("tile_pack", false)
	r["Árboles de FireRed: vuelve el atlas original"] = not TilePack.is_on() \
		and src.texture.resource_path == TilePack.GENERAL_BELOW
	GameState.set_setting("tile_pack", true)

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[ajustes] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-settings] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


## Vitrina: la pantalla de ajustes abierta desde Esc → Opciones.
##   godot --path . --quit-after 40 --write-movie out/f.png --fixed-fps 30 -- --showcase-settings
func showcase() -> void:
	world = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	world.pause_menu.try_open()
	world.pause_menu.push(GameSettingsScreen.new())
