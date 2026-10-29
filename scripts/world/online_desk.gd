class_name OnlineDesk
extends Node
## La recepcionista del Centro de Combate Online (Ciudad Verde; docs/PLAN_ONLINE.md, O-1): la acción `online` de su
## charla te conecta a la sala (Net) y te dice quién está. La pantalla de la sala (desafiar) es la O-2. Nodo del mundo
## (world.online).

const SPEAKER := "Recepcionista"

var world: Node


func _ready() -> void:
	world = get_parent()
	world.story.register_action("online", desk)


func desk() -> void:
	var d: DialogBox = world.story.dialog
	if not Net.is_online():
		var ok: bool = await connect_now()
		if not ok:
			return
	while true:
		var n: int = Net.players.size()
		var question := "Estás conectado como %s. Hay %s en la sala." % [Net.display_name(),
			"1 entrenador (vos)" if n <= 1 else "%d entrenadores" % n]
		var pick := await d.ask(SPEAKER, question, PackedStringArray(["Ver quién está", "Desconectarme", "Nada, gracias"]))
		if pick == 0:
			await d.say(SPEAKER, PackedStringArray([who_is_here(), "Pronto vas a poder desafiarlos desde acá."]))
		elif pick == 1:
			Net.go_offline()
			await d.say(SPEAKER, PackedStringArray(["Listo, te desconecté. ¡Volvé cuando quieras!"]))
			return
		else:
			return


## Conecta y espera la respuesta del servidor. Devuelve si quedó conectado.
func connect_now() -> bool:
	var d: DialogBox = world.story.dialog
	if Net.go_online() == OK:
		await d.say(SPEAKER, PackedStringArray(["Te conecto con el servidor... (%s:%d)" % [Net.address, Net.port]]))
		while Net.state == "connecting":
			await get_tree().process_frame
	if Net.is_online():
		return true
	var why := "No encontré el servidor."
	if Net.state == "rejected":
		why = _last_message
	await d.say(SPEAKER, PackedStringArray([why, "Fijate que el servidor esté prendido y la dirección en Opciones → Online."]))
	return false


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


var _last_message := ""


func _enter_tree() -> void:
	Events.online_state_changed.connect(func(_s, m): _last_message = m)
