class_name VermilionGymPuzzle
extends Node
## Puzzle de los basureros del Gimnasio de Ciudad Carmín (como en FireRed; docs/PLAN_CAPITULO_3.md). Hay 15 basureros
## en una grilla de 5×3: debajo de uno hay un interruptor y debajo de uno vecino (arriba, abajo o a los costados) el
## segundo. Hay que encontrar el segundo enseguida del primero: si le errás, se apagan y cambian de lugar. Con los dos,
## se apaga la barrera eléctrica que tapa a Lt. Surge (bandera surge_puerta_abierta: queda abierta). Nodo del mundo
## (world.vermilion_puzzle); se engancha a la E con StoryDirector.register_interaction.

const ZONE := "ciudad_carmin_gimnasio"
## Basureros (celdas del gimnasio, en orden: 3 filas de 5).
const CANS: Array[Vector2i] = [Vector2i(1, 10), Vector2i(3, 10), Vector2i(5, 10), Vector2i(7, 10), Vector2i(9, 10),
	Vector2i(1, 12), Vector2i(3, 12), Vector2i(5, 12), Vector2i(7, 12), Vector2i(9, 12),
	Vector2i(1, 14), Vector2i(3, 14), Vector2i(5, 14), Vector2i(7, 14), Vector2i(9, 14)]
## La barrera: el centro del rayo eléctrico (celdas que pasan a ser piso) y el metatile de piso.
const GATE: Array[Vector2i] = [Vector2i(4, 6), Vector2i(5, 6), Vector2i(6, 6), Vector2i(4, 7), Vector2i(5, 7), Vector2i(6, 7)]
const FLOOR := 58001
const FLAG := "surge_puerta_abierta"

var world: Node
var switch1 := -1
var switch2 := -1
var found_first := false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	world = get_parent()
	_rng.randomize()
	shuffle()
	world.story.register_interaction(_on_interact)
	Events.zone_loaded.connect(func(z: ZoneEntry, node: Node): if z.id == ZONE: _on_gym_loaded(node))
	Events.zone_entered.connect(func(z: ZoneEntry): if z.id == ZONE and not GameState.has_flag(FLAG): shuffle())


## Esconde los interruptores de nuevo: el primero en cualquier basurero y el segundo en uno vecino.
func shuffle() -> void:
	switch1 = _rng.randi() % CANS.size()
	var n := neighbors(switch1)
	switch2 = n[_rng.randi() % n.size()]
	found_first = false


static func neighbors(i: int) -> Array[int]:
	var out: Array[int] = []
	var col := i % 5
	var row := i / 5
	for d in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		var c: int = col + d.x
		var r: int = row + d.y
		if c >= 0 and c < 5 and r >= 0 and r < 3:
			out.append(r * 5 + c)
	return out


## Revisa un basurero (lo usa la E y el autotest). Devuelve "nada", "primero", "abierta", "reinicio" o "ya".
func check_can(i: int) -> String:
	if GameState.has_flag(FLAG):
		return "ya"
	if not found_first:
		if i == switch1:
			found_first = true
			return "primero"
		return "nada"
	if i == switch2:
		GameState.set_flag(FLAG)
		var zone: Zone = world.streamer.zone_node(ZONE)
		if zone != null:
			open_gate(zone)
		Events.camera_shake.emit(4.0)
		return "abierta"
	shuffle()
	return "reinicio"


func _on_interact(zone_id: String, cell: Vector2i, _front: Vector2) -> bool:
	if zone_id != ZONE or not CANS.has(cell):
		return false
	_dialog(check_can(CANS.find(cell)))
	return true


func _dialog(result: String) -> void:
	var lines := {
		"ya": ["Es un basurero. Ya apretaste los dos interruptores."],
		"nada": ["Nada más que basura..."],
		"primero": ["¡Eh! ¡Abajo de la basura hay un interruptor!", "¡Lo apretaste! Se apagó el primer cierre eléctrico.",
			"Dicen que el segundo está en un basurero de al lado..."],
		"abierta": ["¡Hay otro interruptor! ¡Lo apretaste!", "¡Se apagó el segundo cierre: la barrera eléctrica se abrió!"],
		"reinicio": ["¡Solo basura!", "...¡Bzzt! Los cierres eléctricos se reiniciaron. Hay que empezar de nuevo."],
	}
	var story: StoryDirector = world.story
	story.lock()
	await story._say("", PackedStringArray(lines[result]))
	story.unlock()


func _on_gym_loaded(node: Node) -> void:
	if GameState.has_flag(FLAG) and node is Zone:
		open_gate(node)


## Apaga la barrera: el centro del rayo pasa a ser piso transitable.
func open_gate(zone: Zone) -> void:
	for c in GATE:
		ZoneBuilder.set_metatile(zone.ground, c, FLOOR)
