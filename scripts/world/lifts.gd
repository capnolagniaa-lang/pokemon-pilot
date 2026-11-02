class_name Lifts
extends Node
## Ascensores (Escondite Rocket, Silph S.A., Gran Almacén de Azulona). En FireRed el ascensor es un cuarto aparte con
## destino "dinámico" (MAP_DYNAMIC, lo elige un script), y el importador de mapas no lo trae: las puertas del ascensor
## quedaban sin destino y, en el Escondite, la parte de Giovanni del sótano 4 no tenía cómo alcanzarse.
## Acá la puerta del ascensor de cada piso es una puerta más (se agrega a `ZoneEntry.warps` al arrancar, marcada como
## agregada para que el editor no la guarde): caminando contra ella (o con la E) aparece "¿A qué piso?" y se sale por
## la puerta del ascensor del piso elegido. El del Escondite pide la Llave Ascensor (como en FireRed). Nodo del mundo
## (world.lifts); celdas de las puertas = las de los mapas de FireRed (warps a *_ELEVATOR).

const KEY := "lift"
const LIFTS := {
	"escondite_rocket": {"key_item": "llave_ascensor", "key_flag": "tiene_llave_ascensor", "floors": [
		["Sótano 1", "escondite_rocket_s1", [Vector2i(23, 25), Vector2i(24, 25), Vector2i(25, 25)]],
		["Sótano 2", "escondite_rocket_s2", [Vector2i(28, 16), Vector2i(29, 16)]],
		["Sótano 4", "escondite_rocket_s4", [Vector2i(20, 23), Vector2i(21, 23)]]]},
	"silph": {"floors": [
		["Piso 1", "silph_1p", [Vector2i(22, 3)]], ["Piso 2", "silph_2p", [Vector2i(22, 3)]],
		["Piso 3", "silph_3p", [Vector2i(22, 3)]], ["Piso 4", "silph_4p", [Vector2i(22, 3)]],
		["Piso 5", "silph_5p", [Vector2i(22, 3)]], ["Piso 6", "silph_6p", [Vector2i(20, 3)]],
		["Piso 7", "silph_7p", [Vector2i(23, 3)]], ["Piso 8", "silph_8p", [Vector2i(22, 3)]],
		["Piso 9", "silph_9p", [Vector2i(24, 3)]], ["Piso 10", "silph_10p", [Vector2i(13, 3)]],
		["Piso 11", "silph_11p", [Vector2i(13, 3)]]]},
	"almacen_azulona": {"floors": [
		["Piso 1", "ciudad_azulona_almacen_1p", [Vector2i(6, 1)]], ["Piso 2", "ciudad_azulona_almacen_2p", [Vector2i(6, 1)]],
		["Piso 3", "ciudad_azulona_almacen_3p", [Vector2i(6, 1)]], ["Piso 4", "ciudad_azulona_almacen_4p", [Vector2i(6, 1)]],
		["Piso 5", "ciudad_azulona_almacen_5p", [Vector2i(6, 1)]]]},
}

var world: Node


func _ready() -> void:
	world = get_parent()
	add_doors(world.streamer.world_data)
	world.story.register_interaction(_on_interact)


## Suma las puertas de los ascensores a las zonas (una sola vez; las zonas que no estén se saltean).
static func add_doors(data: WorldData) -> void:
	var by_id := {}
	for z in data.zones:
		by_id[z.id] = z
	for lift_id: String in LIFTS:
		var floors: Array = LIFTS[lift_id]["floors"]
		for i in floors.size():
			var entry: ZoneEntry = by_id.get(floors[i][1])
			if entry == null:
				continue
			var other: Array = floors[(i + 1) % floors.size()]  # un destino válido para el que lea las puertas (mapa, tests)
			for c: Vector2i in floors[i][2]:
				entry.warps[c] = {"to": other[1], "cell": other[2][0], KEY: lift_id, ExtraContent.EXTRA_KEY: true}


## [id del ascensor, índice del piso] de una celda, o [] si ahí no hay ascensor.
static func lift_at(zone_id: String, cell: Vector2i) -> Array:
	for lift_id: String in LIFTS:
		var floors: Array = LIFTS[lift_id]["floors"]
		for i in floors.size():
			if floors[i][1] == zone_id and cell in floors[i][2]:
				return [lift_id, i]
	return []


## ¿Se puede usar? (el del Escondite, con la Llave Ascensor).
static func can_use(lift_id: String) -> bool:
	var l: Dictionary = LIFTS[lift_id]
	if not l.has("key_item"):
		return true
	return GameState.item_count(l["key_item"]) > 0 or GameState.has_flag(l.get("key_flag", ""))


## Sube al ascensor desde la puerta `cell` de la zona `entry` (la llama WarpSystem.use).
func ride(entry: ZoneEntry, cell: Vector2i) -> void:
	var at := lift_at(entry.id, cell)
	if at.is_empty():
		return
	var lift_id: String = at[0]
	var here: int = at[1]
	var story: StoryDirector = world.story
	var warps: WarpSystem = world.warps
	warps.busy = true
	story.lock()
	var target := -1
	if not can_use(lift_id):
		await story._say("", PackedStringArray(["Es un ascensor... Parece que hace falta una llave para usarlo."]))
	else:
		var floors: Array = LIFTS[lift_id]["floors"]
		var options := PackedStringArray()
		var targets: Array[int] = []
		for i in floors.size():
			if i != here:
				options.append(floors[i][0])
				targets.append(i)
		options.append("Quedarse")
		var pick := await story.dialog.ask("", "Ascensor (%s). ¿A qué piso?" % floors[here][0], options)
		if pick >= 0 and pick < targets.size():
			target = targets[pick]
	story.unlock()
	warps.busy = false
	if target < 0:
		warps.hold(1.0)  # que no vuelva a preguntar enseguida si seguís caminando contra la puerta
		return
	var dest: Array = LIFTS[lift_id]["floors"][target]
	Events.camera_shake.emit(1.0)
	await warps.travel(entry, dest[1], dest[2][0])


func _on_interact(zone_id: String, cell: Vector2i, _front: Vector2) -> bool:
	if lift_at(zone_id, cell).is_empty():
		return false
	ride(_entry(zone_id), cell)
	return true


func _entry(id: String) -> ZoneEntry:
	for z in world.streamer.world_data.zones:
		if z.id == id:
			return z
	return null
