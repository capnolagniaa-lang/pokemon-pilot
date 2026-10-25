class_name Mart
extends Node
## El mercado: las Tiendas Pokémon (data/shops/<id>.tres, ShopData). El vendedor abre la tienda con la acción
## `tienda_<id>` de su conversación (NpcTalk.action, registrada en StoryDirector): pregunta Comprar / Vender y abre
## `ShopScreen`. Precios oficiales (ItemData.price); se vende a la mitad (ItemData.sell_price). Nodo del mundo
## (world.mart).

var world: Node
var shops: Dictionary = {}  # id -> ShopData
## Capa de la pantalla de la tienda: encima del HUD y del menú (10).
var _layer: CanvasLayer


func _ready() -> void:
	world = get_parent()
	_layer = CanvasLayer.new()
	_layer.layer = 11
	add_child(_layer)
	for f in DirAccess.get_files_at("res://data/shops"):
		var s = load("res://data/shops/" + f.trim_suffix(".remap"))
		if s is ShopData:
			shops[s.id] = s
			world.story.register_action("tienda_" + s.id, open.bind(s))
	world.story.register_action("vender_magikarp", sell_magikarp)


## Charla con el vendedor: Comprar / Vender / Nada, hasta que se despide.
func open(shop: ShopData) -> void:
	var d: DialogBox = world.story.dialog
	var question := "¡Bienvenido! ¿En qué te puedo ayudar?"
	while true:
		var pick := await d.ask(shop.clerk, question, PackedStringArray(["Comprar", "Vender", "Nada, gracias"]))
		if pick == 2:
			break
		var hud: CanvasItem = world.get_node_or_null("UI/HUD")
		if hud != null:
			hud.visible = false  # la tienda tapa la pantalla: que no se crucen los textos
		var screen := show_screen(shop, pick == 0)
		await screen.closed
		screen.queue_free()
		if hud != null:
			hud.visible = true
		question = "¿Algo más?"
	await d.say(shop.clerk, PackedStringArray(["¡Gracias! Volvé cuando quieras."]))


## El vendedor del Centro de la Ruta 4 (como en FireRed): un Magikarp Nv. 5 por $500, una sola vez.
const MAGIKARP_PRICE := 500


func sell_magikarp() -> void:
	var d: DialogBox = world.story.dialog
	if await d.ask("Vendedor", "¿Te vendo un Magikarp por solo $%d? (Tenés $%d)" % [MAGIKARP_PRICE, GameState.money],
			PackedStringArray(["Sí", "No"])) != 0:
		await d.say("Vendedor", PackedStringArray(["¡Te lo perdés! Es un Pokémon con muuucho futuro."]))
		return
	var where := buy_magikarp()
	if where == "":
		await d.say("Vendedor", PackedStringArray(["No te alcanza la plata, pibe. Volvé con $%d." % MAGIKARP_PRICE]))
		return
	await d.say("Vendedor", PackedStringArray(["¡Trato hecho! Tomá tu Magikarp.%s" % (" (Se fue a la Caja: tu equipo está lleno.)"
		if where == "caja" else ""), "...Ojo que no hago devoluciones, eh."]))


## Cobra y entrega el Magikarp (al equipo o, si está lleno, a la Caja). "" si no alcanza la plata o ya lo compró.
func buy_magikarp() -> String:
	if GameState.has_flag("magikarp_comprado") or not GameState.spend_money(MAGIKARP_PRICE):
		return ""
	GameState.set_flag("magikarp_comprado")
	var inst := CreatureInstance.create(DB.species["magikarp"], 5)
	if GameState.add_to_party(inst):
		return "equipo"
	GameState.box.append(inst)
	GameState.mark_fought(inst.species)
	return "caja"


## Abre la pantalla de comprar (o vender) de una tienda. Se cierra con su señal `closed` (quien la abre la borra).
func show_screen(shop: ShopData, buying: bool) -> ShopScreen:
	var screen := ShopScreen.new()
	screen.setup(shop, buying)
	_layer.add_child(screen)
	return screen


## Compra `amount` de un objeto de la tienda. false si no lo vende o no te alcanza la plata.
static func buy(shop: ShopData, item: ItemData, amount: int = 1) -> bool:
	if amount <= 0 or item.price <= 0 or not shop.items.has(item):
		return false
	if not GameState.spend_money(item.price * amount):
		return false
	GameState.add_item(item.id, amount)
	return true


## Vende `amount` de un objeto de la Mochila a la mitad del precio. false si no se vende o no tenés tantos.
static func sell(item: ItemData, amount: int = 1) -> bool:
	if amount <= 0 or item.sell_price() <= 0 or GameState.item_count(item.id) < amount:
		return false
	GameState.remove_item(item.id, amount)
	GameState.add_money(item.sell_price() * amount)
	return true
