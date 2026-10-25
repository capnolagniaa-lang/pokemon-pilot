class_name MartTests
extends Node
## Autotest del mercado (Tiendas Pokémon: data/shops, Mart, ShopScreen):
##   godot --headless --path . --quit-after 20000 -- --autotest-mart
## Vitrina (la pantalla de compra y la de venta):
##   godot --path . --quit-after 120 --write-movie out/f.png --fixed-fps 30 -- --showcase-mart

var autotest: Node


func run() -> void:
	var r := {}
	var verde: ShopData = load("res://data/shops/ciudad_verde.tres")
	var plateada: ShopData = load("res://data/shops/ciudad_plateada.tres")
	var ids := func(s: ShopData): return s.items.map(func(it): return it.id)
	r["Ciudad Verde vende como en FireRed"] = ids.call(verde) == ["poke_ball", "pocion", "antidoto", "antiparalizador", "antiquemar"]
	r["Ciudad Plateada suma Despertar"] = ids.call(plateada).has("despertar") and ids.call(plateada).has("poke_ball")
	r["Precios oficiales (Poké Ball 200, Poción 300, Antídoto 100)"] = DB.items["poke_ball"].price == 200 \
		and DB.items["pocion"].price == 300 and DB.items["antidoto"].price == 100
	r["Se vende a la mitad; los objetos clave y la Master Ball no"] = DB.items["pocion"].sell_price() == 150 \
		and DB.items["paquete_oak"].sell_price() == 0 and DB.items["master_ball"].sell_price() == 0

	var world: Node = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	await get_tree().physics_frame
	r["El mundo tiene el mercado con las 2 tiendas"] = world.mart.shops.size() >= 2 \
		and world.story.actions.has("tienda_ciudad_verde") and world.story.actions.has("tienda_ciudad_plateada")

	GameState.money = 1000
	GameState.bag.clear()
	r["Comprar 3 Poké Balls: −$600"] = Mart.buy(verde, DB.items["poke_ball"], 3) and GameState.money == 400 \
		and GameState.item_count("poke_ball") == 3
	r["Sin plata no compra"] = not Mart.buy(verde, DB.items["pocion"], 2) and GameState.money == 400
	r["No compra lo que esa tienda no vende (Super Ball)"] = not Mart.buy(verde, DB.items["super_ball"], 1)
	GameState.add_item("pocion", 2)
	r["Vender 2 Pociones: +$300"] = Mart.sell(DB.items["pocion"], 2) and GameState.money == 700 and GameState.item_count("pocion") == 0
	r["No vende más de los que tenés"] = not Mart.sell(DB.items["poke_ball"], 9) and GameState.item_count("poke_ball") == 3
	GameState.add_item("paquete_oak", 1)
	r["Los objetos clave no se venden"] = not Mart.sell(DB.items["paquete_oak"], 1)

	# Pantalla: elegir, cantidad (con tope por la plata) y confirmar.
	var screen: ShopScreen = world.mart.show_screen(verde, true)
	await get_tree().process_frame
	screen.select(DB.items["pocion"])
	screen.set_amount(50)
	r["La cantidad se topea con la plata ($700 → 2 Pociones)"] = screen._amount == 2
	r["Pantalla: comprar 2 Pociones"] = screen.confirm() and GameState.item_count("pocion") == 2 and GameState.money == 100
	var closed := [false]
	screen.closed.connect(func(): closed[0] = true)
	var esc := InputEventAction.new()
	esc.action = "ui_cancel"
	esc.pressed = true
	Input.parse_input_event(esc)
	await get_tree().process_frame
	r["Esc cierra la tienda"] = closed[0]
	screen.queue_free()
	var sell: ShopScreen = world.mart.show_screen(verde, false)
	await get_tree().process_frame
	r["Vender lista lo tuyo que se vende (sin objetos clave)"] = sell.items().has(DB.items["pocion"]) \
		and not sell.items().has(DB.items["paquete_oak"])
	sell.queue_free()

	# El vendedor de Ciudad Verde: en la historia vende después de entregar el correo; sin historia, siempre.
	var clerk: NpcData = DB.npcs["ciudad_verde_tienda_clerk"]
	GameState.story_flags.clear()
	r["Sin historia: el vendedor ya vende"] = clerk.talk_now() != null and clerk.talk_now().action == "tienda_ciudad_verde"
	GameState.set_flag("historia")
	GameState.set_flag("tiene_inicial")
	r["En la historia, antes del correo: te da el paquete (no vende)"] = clerk.talk_now().action == "" \
		and clerk.talk_now().give_items.has("paquete_oak")
	GameState.set_flag("tiene_paquete")
	GameState.set_flag("paquete_entregado")
	r["Después de entregar el correo: vende"] = clerk.talk_now().action == "tienda_ciudad_verde"
	r["El de Ciudad Plateada vende siempre"] = DB.npcs["ciudad_plateada_tienda_clerk"].talk_now().action == "tienda_ciudad_plateada"

	var ok := r.values().all(func(v): return v)
	for key in r:
		print("[mart] %s %s" % ["OK   " if r[key] else "FALLO", key])
	print("[autotest-mart] -> ", "OK" if ok else "FALLO")
	get_tree().quit(0 if ok else 1)


func showcase() -> void:
	var world: Node = await autotest._setup_kit_world("charmander")
	world.combat.end_battle()
	GameState.money = 3000
	GameState.add_item("pocion", 4)
	GameState.add_item("antidoto", 2)
	var shop: ShopData = load("res://data/shops/ciudad_plateada.tres")
	var screen: ShopScreen = world.mart.show_screen(shop, true)
	await get_tree().create_timer(0.5).timeout
	screen.select(DB.items["poke_ball"])
	screen.set_amount(5)
	await get_tree().create_timer(1.0).timeout
	screen.confirm()
	await get_tree().create_timer(0.8).timeout
	screen.queue_free()
	var sell: ShopScreen = world.mart.show_screen(shop, false)
	await get_tree().create_timer(1.2).timeout
	get_tree().quit()
