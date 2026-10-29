class_name OnlineLobbyScreen
extends Control
## La sala online (docs/PLAN_ONLINE.md, O-2; la abre la recepcionista del Centro de Combate Online, `OnlineDesk`).
## Tres pasos en la misma pantalla:
##   sala   → los conectados (equipo y si están libres), elegís el formato (1, 3 o 6 Pokémon) y desafiás; un desafío
##            que te llega aparece arriba con Aceptar / Rechazar.
##   elegir → aceptado: elegís qué Pokémon llevás (con tiempo; si se termina, van los primeros en pie).
##   listo  → los dos eligieron: con quién y contra qué vas; enseguida se cierra y `OnlineDesk` arranca la pelea (O-3).
## Esc o "Salir" cierra en la sala (retira tu desafío si había uno). Habla con el servidor solo a través de `Net`.

signal closed

var step := "sala"
var count := 3
## Desafío que mandé (id del otro) y el que me llegó: {id, name, count}.
var waiting_for := 0
var incoming: Dictionary = {}
## Partida en curso: {id, opponent, count, left (segundos para elegir)}.
var match_info: Dictionary = {}
var picked: Array[int] = []
var _status: Label
var _body: VBoxContainer
var _head: Label
var _timer_label: Label


func _ready() -> void:
	theme = UiStyle.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	var frame := PanelContainer.new()  # fondo sólido: que no se lea el interior a través
	frame.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.ACCENT.darkened(0.3), 2, 22))
	frame.position = Vector2(40, 20)
	frame.size = Vector2(1200, 680)
	add_child(frame)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	frame.add_child(root)
	var top := HBoxContainer.new()
	root.add_child(top)
	_head = UiStyle.label("", 24, UiStyle.ACCENT)
	_head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_head)
	_timer_label = UiStyle.label("", 22, UiStyle.ACCENT)
	top.add_child(_timer_label)
	_status = UiStyle.label("", 17, UiStyle.TEXT_DIM)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_status)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_body)
	Events.online_players_changed.connect(_on_players)
	Events.online_challenged.connect(_on_challenged)
	Events.online_challenge_withdrawn.connect(_on_withdrawn)
	Events.online_challenge_answered.connect(_on_answered)
	Events.online_match_choose.connect(_on_choose)
	Events.online_match_ready.connect(_on_ready)
	Events.online_match_cancelled.connect(_on_cancelled)
	Events.online_state_changed.connect(_on_state)
	refresh()


func _process(delta: float) -> void:
	if step == "elegir" and not match_info.is_empty():
		match_info.left -= delta
		_timer_label.text = "%d s" % maxi(0, ceili(match_info.left))
		if match_info.left <= 0.0:
			auto_pick()
			confirm_pick()
	else:
		_timer_label.text = ""


func refresh() -> void:
	for c in _body.get_children():
		c.queue_free()
	match step:
		"sala":
			_build_lobby()
		"elegir":
			_build_pick()
		"listo":
			_build_ready()


# --- Sala ------------------------------------------------------------------------------------

func _build_lobby() -> void:
	_head.text = "SALA ONLINE · %d conectados" % Net.players.size()
	if not incoming.is_empty():
		var box := _panel(UiStyle.ACCENT)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		box.add_child(row)
		var l := UiStyle.label("¡%s te desafía! (%d contra %d)" % [incoming.name, incoming.count, incoming.count], 20, UiStyle.ACCENT)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var yes := UiStyle.button("Aceptar", 150)
		yes.pressed.connect(accept_incoming)
		row.add_child(yes)
		var no := UiStyle.button("Rechazar", 150)
		no.pressed.connect(decline_incoming)
		row.add_child(no)
		UiStyle.focus_later(yes)
	var fmt := HBoxContainer.new()
	fmt.add_theme_constant_override("separation", 8)
	fmt.add_child(UiStyle.label("Formato:", 18))
	var group := ButtonGroup.new()
	for n in NetPeer.COUNTS:
		var b := UiStyle.button("%d contra %d" % [n, n], 150)
		b.toggle_mode = true
		b.button_group = group
		b.button_pressed = n == count
		b.pressed.connect(func(): count = n)
		fmt.add_child(b)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fmt.add_child(gap)
	var leave := UiStyle.button("Salir (Esc)", 160)
	leave.pressed.connect(close)
	fmt.add_child(leave)
	_body.add_child(fmt)
	var others := Net.players.filter(func(p): return p.id != Net.client.my_id)
	if others.is_empty():
		_body.add_child(UiStyle.label("Todavía no hay nadie más. Cuando entren tus amigos van a aparecer acá.", 18, UiStyle.TEXT_DIM))
	for p in others:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var name := UiStyle.label(p.name, 20)
		name.custom_minimum_size.x = 220
		row.add_child(name)
		row.add_child(_team_row(p.get("team", [])))
		var gap2 := Control.new()
		gap2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(gap2)
		var st := UiStyle.label(_status_name(p.status), 16, UiStyle.GOOD if p.status == "libre" else UiStyle.TEXT_DIM)
		st.custom_minimum_size.x = 110
		row.add_child(st)
		var b := UiStyle.button("Retirar" if waiting_for == p.id else "Desafiar", 150)
		b.disabled = (waiting_for != 0 and waiting_for != p.id) or p.status != "libre" or not incoming.is_empty()
		b.pressed.connect(withdraw if waiting_for == p.id else challenge.bind(p.id))
		row.add_child(b)
		_body.add_child(row)


func challenge(id: int) -> void:
	waiting_for = id
	Net.challenge(id, count)
	_status.text = "Esperando a que %s conteste..." % _name(id)
	refresh()


func withdraw() -> void:
	Net.withdraw()
	_status.text = "Retiraste el desafío."
	waiting_for = 0
	refresh()


func accept_incoming() -> void:
	if incoming.is_empty():
		return
	Net.answer(incoming.id, true)
	_status.text = "Aceptaste. Preparando la partida..."
	incoming = {}
	refresh()


func decline_incoming() -> void:
	if incoming.is_empty():
		return
	Net.answer(incoming.id, false)
	_status.text = "Rechazaste el desafío de %s." % incoming.name
	incoming = {}
	refresh()


# --- Elegir equipo ---------------------------------------------------------------------------

func _build_pick() -> void:
	var opp: Dictionary = match_info.opponent
	var need := pick_size()
	_head.text = "CONTRA %s · %d contra %d" % [opp.name.to_upper(), match_info.count, match_info.count]
	_status.text = "Elegí %d Pokémon (%d/%d). Si se termina el tiempo, van los primeros en pie." % [need, picked.size(), need]
	var opp_row := HBoxContainer.new()
	opp_row.add_theme_constant_override("separation", 10)
	opp_row.add_child(UiStyle.label("Su equipo:", 18, UiStyle.TEXT_DIM))
	opp_row.add_child(_team_row(opp.get("team", [])))
	_body.add_child(opp_row)
	for i in GameState.party.size():
		var inst: CreatureInstance = GameState.party[i]
		var b := UiStyle.button("", 520)
		b.toggle_mode = true
		b.button_pressed = i in picked
		b.disabled = inst.hp <= 0.0
		b.text = "%s%s  Nv. %d  ·  PS %d/%d%s" % ["✔ " if i in picked else "   ", inst.display_name(), inst.level,
			ceili(inst.hp), ceili(inst.max_hp()), "  (debilitado)" if inst.hp <= 0.0 else ""]
		b.pressed.connect(toggle_pick.bind(i))
		_body.add_child(b)
	var ok := UiStyle.button("¡Listo!", 220)
	ok.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	ok.disabled = picked.size() != need
	ok.pressed.connect(confirm_pick)
	_body.add_child(ok)


## Cuántos tiene que elegir: el formato, o menos si no tenés tantos en pie.
func pick_size() -> int:
	var healthy := GameState.party.filter(func(c): return c.hp > 0.0).size()
	return mini(int(match_info.get("count", 1)), healthy)


func toggle_pick(i: int) -> void:
	if i in picked:
		picked.erase(i)
	elif picked.size() < pick_size() and GameState.party[i].hp > 0.0:
		picked.append(i)
	refresh()


func auto_pick() -> void:
	for i in GameState.party.size():
		if picked.size() >= pick_size():
			break
		if i not in picked and GameState.party[i].hp > 0.0:
			picked.append(i)


func confirm_pick() -> void:
	if step != "elegir" or picked.size() != pick_size():
		return
	var team: Array = picked.map(func(i): return GameState.party[i])
	Net.choose_team(match_info.id, team)
	step = "esperando"
	_status.text = "Esperando a que %s elija..." % match_info.opponent.name
	for c in _body.get_children():
		c.queue_free()


# --- Listo -----------------------------------------------------------------------------------

func _build_ready() -> void:
	_head.text = "¡PARTIDA LISTA!"
	var opp: Dictionary = match_info.opponent
	_body.add_child(UiStyle.label("Vas contra %s, que lleva:" % opp.name, 20))
	var team: Array = match_info.get("opponent_team", [])
	_body.add_child(_team_row(team.map(func(d): return {"species": d.get("species_id", ""), "level": d.get("level", 1)})))
	_body.add_child(UiStyle.label("¡A la arena! Sin pausa: la pelea sigue aunque abras el menú.", 18, UiStyle.TEXT_DIM))
	var back := UiStyle.button("Volver a la sala", 240)
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.pressed.connect(func():
		step = "sala"
		match_info = {}
		_status.text = ""
		refresh())
	_body.add_child(back)
	UiStyle.focus_later(back)


# --- Avisos del servidor ---------------------------------------------------------------------

func _on_players(_p: Array) -> void:
	if step == "sala":
		refresh()


func _on_challenged(from_id: int, from_name: String, n: int) -> void:
	incoming = {"id": from_id, "name": from_name, "count": n}
	Sound.sfx("menu_mover")
	if step == "sala":
		refresh()


func _on_withdrawn(from_id: int) -> void:
	if incoming.get("id", -1) == from_id:
		_status.text = "%s retiró el desafío." % incoming.name
		incoming = {}
		if step == "sala":
			refresh()


func _on_answered(to_id: int, accepted: bool, message: String) -> void:
	if to_id != waiting_for:
		return
	waiting_for = 0
	if not accepted:
		_status.text = message
		if step == "sala":
			refresh()


func _on_choose(match_id: int, opponent: Dictionary, n: int, seconds: float) -> void:
	waiting_for = 0
	incoming = {}
	match_info = {"id": match_id, "opponent": opponent, "count": n, "left": seconds}
	picked = []
	step = "elegir"
	refresh()


func _on_ready(match_id: int, opponent: Dictionary, opponent_team: Array) -> void:
	if match_info.get("id", -1) != match_id:
		match_info = {"id": match_id, "opponent": opponent, "count": opponent_team.size()}
	match_info.opponent_team = opponent_team
	step = "listo"
	refresh()


func _on_cancelled(match_id: int, reason: String) -> void:
	if match_info.get("id", -1) != match_id:
		return
	match_info = {}
	step = "sala"
	_status.text = "Se cayó la partida: %s" % reason
	refresh()


func _on_state(s: String, message: String) -> void:
	if s != "online":
		_status.text = message
		close()


func close() -> void:
	if waiting_for != 0:
		Net.withdraw()
		waiting_for = 0
	if not incoming.is_empty():
		Net.answer(incoming.id, false)
		incoming = {}
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		if step == "sala" or step == "listo":
			close()


# --- Piezas ----------------------------------------------------------------------------------

func _panel(border: Color) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG_SOFT, border, 2, 12))
	_body.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	return box


## Retratos chicos con el nivel: [{species, level}].
func _team_row(team: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	for m in team:
		var sp: SpeciesData = DB.species.get(str(m.get("species", "")))
		if sp == null:
			continue
		var pic := TextureRect.new()
		pic.texture = DB.portrait_of(sp)
		pic.custom_minimum_size = Vector2(32, 32)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		pic.tooltip_text = "%s Nv. %d" % [sp.display_name, int(m.get("level", 1))]
		row.add_child(pic)
		row.add_child(UiStyle.label("%d" % int(m.get("level", 1)), 14, UiStyle.TEXT_DIM))
	return row


func _status_name(s: String) -> String:
	return {"libre": "Libre", "eligiendo": "Eligiendo", "peleando": "Peleando"}.get(s, s)


func _name(id: int) -> String:
	for p in Net.players:
		if p.id == id:
			return p.name
	return "?"
