class_name TutorialScreen
extends Control
## "Cómo se juega" (pedido del usuario 2026-10-28): páginas con los controles, el combate, la captura, los ataques y
## todo lo que se puede modificar. Sale sola la primera vez que entrás al mundo con una partida (bandera
## "tutorial_visto", World) y siempre desde Esc → Cómo se juega. ←/→ (o A/D) cambian de página; Esc cierra.

signal closed

## [título, [líneas]]. Las teclas son las de Controls.
const PAGES := [
	["¡Bienvenido a Pokémon Pilot!", [
		"Es un juego de Pokémon con combates en tiempo real: vos manejás a tu Pokémon y atacás como en un juego de acción.",
		"En la historia recorrés Kanto como en FireRed: gimnasios, rival, Team Rocket y la Liga.",
		"Este tutorial lo podés volver a ver cuando quieras en Esc → Cómo se juega.",
	]],
	["Moverte y explorar", [
		"WASD o flechas: caminar.  Shift: correr.",
		"E frente a alguien o algo: hablar, leer un cartel, usar una máquina o la tienda.",
		"Puertas: caminá contra ellas. Los salientes del pasto se bajan saltando (no se suben).",
		"Pokébolas en el suelo: pasá por encima para juntarlas (objetos de las rutas y lo que sueltan los salvajes).",
		"Corte, Surf y Fuerza: con la MO y su medalla se usan solas al caminar contra el árbol, el agua o la roca.",
	]],
	["Los salvajes", [
		"Cada especie tiene su temperamento: los agresivos te atacan apenas te ven; los territoriales solo si entrás a su zona (si te miran con \"...\", todavía estás afuera); los tímidos huyen; los curiosos se acercan a mirar.",
		"Cuando uno te desafía empieza el combate y manejás a tu Pokémon.",
		"F: entrar o salir del combate. Si huís, el salvaje te deja unos segundos tranquilo para que te alejes.",
		"Si le pegás a uno que huye o que te ignoraba, pelea igual.",
	]],
	["El combate", [
		"WASD: mover a tu Pokémon.  Mouse: apuntar.",
		"Clic izquierdo, Clic derecho, Q y R: sus 4 ataques. Cada uno tiene su recarga.",
		"Espacio: esquivar (te tirás hacia un costado).",
		"Todo golpe deja aturdido un instante (stagger); un golpe fuerte corta los ataques que se cargan.",
		"Los tipos importan como en los juegos: súper eficaz, poco eficaz e inmunidades (a un Volador no le hace nada un ataque Tierra, a un Veneno no lo envenenás...).",
	]],
	["Tu equipo", [
		"1 a 6: cambiar de Pokémon en plena pelea (tiene una recarga corta).",
		"La experiencia se reparte entre los que pelearon contra ese rival y siguen en pie.",
		"Los Pokémon no se curan solos: Centro Pokémon, tu casa u objetos de la Mochila.",
		"C: usar el objeto rápido (lo elegís en la Mochila) sobre el que está afuera. Usarlo en combate te deja expuesto un instante.",
		"Si se debilitan todos, volvés al último lugar donde te curaste.",
	]],
	["Atrapar Pokémon", [
		"Bajale la vida y, si podés, dejalo dormido o paralizado: es más fácil.",
		"E: lanzar la Pokébola hacia donde apuntás. La que usás se elige en la Mochila.",
		"Si errás, la bola queda en el piso un rato: pasá por encima para recuperarla.",
		"Con el equipo lleno (6), lo que atrapás va a la Caja (Esc → Caja).",
		"Los de un entrenador no se pueden atrapar.",
	]],
	["Ataques y habilidades", [
		"Esc → Equipo → elegí un Pokémon → Movimientos: ponés los 4 que quieras entre todo lo que aprendió (por nivel y con MT).",
		"Al elegir un ataque se explica qué hace, con su potencia, recarga y estados. También en la Pokédex.",
		"Si aprende uno nuevo con los 4 lugares llenos, te pregunta si querés reemplazar alguno.",
		"Cada Pokémon tiene una habilidad (una de las de su especie, al azar) que cambia cómo pelea: la ves en su ficha.",
		"Cuando va a evolucionar, Esc la frena (salvo con piedra).",
	]],
	["Lo que podés modificar", [
		"Esc → Opciones: dificultad de la IA (Fácil, Normal, Difícil o Personalizado) y el volumen.",
		"Esc → Opciones → Ajustes del juego (se guardan con cada partida): experiencia, dinero de los premios, facilidad de captura, daño que hacés y que recibís, vida de los Pokémon, stagger, cantidad de salvajes, curación sola fuera de combate, objetos en las rutas, hora fija y, en Personalizado, cada detalle de la IA.",
		"Tus 4 ataques, la Pokébola que lanzás y el objeto rápido de la C.",
		"Varias partidas con nombre, cada una con sus ajustes.",
	]],
	["El menú (Esc)", [
		"Guía: qué hacer ahora para seguir la historia y lo opcional que te queda.",
		"Mapa: dónde estás y adónde ir (en la historia, cuando te dan el Mapa).",
		"Equipo, Mochila, Caja, Pokédex y Tarjeta de entrenador.",
		"Guardar: guardá seguido. En combate el menú se abre reducido y la pelea queda en pausa.",
		"¡Listo! Andá a buscar tu primer Pokémon.",
	]],
]

var page := 0
var _title: Label
var _body: VBoxContainer
var _counter: Label
var _prev: Button
var _next: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(UiStyle.dim())
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.BG, UiStyle.ACCENT.darkened(0.3), 2, 22))
	panel.position = Vector2(200, 70)
	panel.custom_minimum_size = Vector2(880, 560)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var top := HBoxContainer.new()
	box.add_child(top)
	var head := UiStyle.label("CÓMO SE JUEGA", 15, UiStyle.TEXT_DIM)
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(head)
	_counter = UiStyle.label("", 15, UiStyle.TEXT_DIM)
	top.add_child(_counter)
	_title = UiStyle.label("", 26, UiStyle.ACCENT)
	box.add_child(_title)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 10)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_body)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 12)
	box.add_child(nav)
	_prev = UiStyle.button("← Anterior", 180)
	_prev.pressed.connect(func(): show_page(page - 1))
	nav.add_child(_prev)
	_next = UiStyle.button("Siguiente →", 180)
	_next.pressed.connect(func(): show_page(page + 1) if page < PAGES.size() - 1 else closed.emit())
	nav.add_child(_next)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav.add_child(gap)
	var skip := UiStyle.button("Cerrar (Esc)", 180)
	skip.pressed.connect(func(): closed.emit())
	nav.add_child(skip)
	show_page(0)
	UiStyle.focus_later(_next)


func show_page(i: int) -> void:
	page = clampi(i, 0, PAGES.size() - 1)
	_title.text = PAGES[page][0]
	_counter.text = "%d / %d" % [page + 1, PAGES.size()]
	for c in _body.get_children():
		c.queue_free()
	for line in PAGES[page][1]:
		var l := UiStyle.label("•  " + line, 18)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 836
		_body.add_child(l)
	_prev.disabled = page == 0
	_next.text = "¡A jugar!" if page == PAGES.size() - 1 else "Siguiente →"


## En _input (antes que los botones): si no, ←/→ solo movían el foco entre los botones.
func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		show_page(page - 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		show_page(page + 1)
		get_viewport().set_input_as_handled()
