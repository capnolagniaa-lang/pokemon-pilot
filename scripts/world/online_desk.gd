class_name OnlineDesk
extends Node
## La recepcionista del Centro de Combate Online (Ciudad Verde; docs/PLAN_ONLINE.md, O-1/O-2): la acción `online` de
## su charla te conecta a la sala (Net) y abre `OnlineLobbyScreen` (desafiar, aceptar, elegir equipo). Conectado y
## con la sala cerrada, un desafío que te llega aparece como pregunta (si estás ocupado, se rechaza solo). Nodo del
## mundo (world.online).

const SPEAKER := "Recepcionista"

var world: Node
var screen: OnlineLobbyScreen
var _layer: CanvasLayer
var _last_message := ""


func _ready() -> void:
	world = get_parent()
	_layer = CanvasLayer.new()
	_layer.layer = 11  # como la tienda: encima del HUD y del menú
	add_child(_layer)
	world.story.register_action("online", desk)
	Events.online_state_changed.connect(func(_s, m): _last_message = m)
	Events.online_challenged.connect(_on_challenged)


func desk() -> void:
	var d: DialogBox = world.story.dialog
	if Net.is_online():
		var pick := await d.ask(SPEAKER, "Estás conectado como %s. ¿Qué hacemos?" % Net.display_name(),
			PackedStringArray(["Ir a la sala", "Desconectarme", "Nada, gracias"]))
		if pick == 1:
			Net.go_offline()
			await d.say(SPEAKER, PackedStringArray(["Listo, te desconecté. ¡Volvé cuando quieras!"]))
			return
		if pick == 2:
			return
	elif not await connect_now():
		return
	await open_lobby()
	if Net.is_online():
		await d.say(SPEAKER, PackedStringArray(["Seguís conectado: si alguien te desafía te aviso.", "Para desconectarte, hablame."]))


## Abre la sala y espera a que se cierre.
func open_lobby() -> void:
	if is_instance_valid(screen):
		return
	var hud: CanvasItem = world.get_node_or_null("UI/HUD")
	if hud != null:
		hud.visible = false
	screen = OnlineLobbyScreen.new()
	_layer.add_child(screen)
	await screen.closed
	screen.queue_free()
	screen = null
	if hud != null:
		hud.visible = true


## Conecta y espera la respuesta del servidor. Devuelve si quedó conectado.
func connect_now() -> bool:
	var d: DialogBox = world.story.dialog
	if Net.go_online() == OK:
		await d.say(SPEAKER, PackedStringArray(["Te conecto con el servidor..."]))
		while Net.state == "connecting":
			await get_tree().process_frame
	if Net.is_online():
		return true
	var why := "No encontré el servidor."
	if Net.state == "rejected":
		why = _last_message
	await d.say(SPEAKER, PackedStringArray([why, "Puede que el servidor esté apagado: probá de nuevo en un rato."]))
	return false


## Te desafían con la sala cerrada: pregunta (si estás en algo, se rechaza solo).
func _on_challenged(from_id: int, from_name: String, count: int) -> void:
	if is_instance_valid(screen):
		return  # la sala lo muestra
	if world.story.busy or world.combat.in_battle or get_tree().paused or world.arena.active:
		Net.answer(from_id, false)
		return
	world.story.lock()
	var pick: int = await world.story.dialog.ask(SPEAKER, "¡%s te desafía! (%d contra %d)" % [from_name, count, count],
		PackedStringArray(["Aceptar", "Rechazar"]))
	Net.answer(from_id, pick == 0)
	if pick == 0:
		await open_lobby()  # llega la elección de equipo
	world.story.unlock()


## Quién está (para mostrar en una línea: nombre y equipo).
func who_is_here() -> String:
	var names := PackedStringArray()
	for p in Net.players:
		var team := PackedStringArray()
		for m in p.get("team", []):
			var sp: SpeciesData = DB.species.get(m.species)
			team.append("%s Nv. %d" % [sp.display_name if sp else m.species, m.level])
		names.append("%s%s: %s" % [p.name, " (vos)" if p.id == Net.client.my_id else "",
			", ".join(team) if not team.is_empty() else "sin Pokémon"])
	return "\n".join(names)
