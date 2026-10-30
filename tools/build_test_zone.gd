extends RefCounted
## Zona de pruebas (pedido del usuario 2026-10-30, para la sesión de gráficos: docs/PLAN_TERRENO_PROPIO.md): un pueblo
## chico, un bosque chico pegado y una cueva chica, sin conexión con la historia. Se llega con «ir pruebas» en la consola
## de Game master (Ctrl+Shift+G). Se arma con las mismas operaciones del editor de mapas (MapDocument: pinceles por rol,
## árboles, sellos de FireRed, copiar/pegar de zonas reales), así cada celda tiene su rol y sus tags de siempre:
##  · pruebas_pueblo (40×32): 4 casas de Pueblo Paleta con puerta, plaza empedrada con la estatua de Carmín en el medio,
##    caminos de tierra, un estanque con cerca, un cantero de flores con cerca y árboles sueltos.
##  · pruebas_bosque (28×32, a la derecha del pueblo): árboles tupidos con un sendero de tierra, pasto alto (salvajes del
##    bioma "bosque") y la boca de cueva de la Ruta 4 (la del Mt. Moon) arriba a la derecha.
##  · pruebas_cueva (28×22, interior): las 4 esquinas del Mt. Moon (paredes, piso, arena, la escalera de arriba a la
##    izquierda, que sale al bosque) y un charco.
##  · pruebas_casa_1..4: el interior de la casa de tu rival (la misma escena) para cada casa.
## Todo va lejos, debajo del mundo (fuera del Mapa del menú) y como agregado (ExtraContent: data/world/extra/zones/,
## escenas en scenes/world/extra/), sin tocar kanto.tres. `ZoneEntry.test_zone`: no cuenta como visitada.
## Correrlo de nuevo PISA esas escenas (si se retocan con el editor de mapas, no volver a correrlo).
## Uso: godot --headless --path . --quit-after 60000 -- --build-test-zone  (corre dentro del juego: MapDocument usa DB)

const ZONES_DIR := "res://data/world/extra/zones"
const SCENES_DIR := "res://scenes/world/extra"
const ORIGIN := Vector2i(1000, 3400)
const HOUSE_SCENE := "res://scenes/world/zones/casa_rival.tscn"
const HOUSE_SIZE := Vector2i(13, 10)
## Celdas (del interior de la casa del rival) de la alfombra de salida y adonde se llega desde afuera.
const HOUSE_EXITS := [Vector2i(3, 8), Vector2i(4, 8)]
const HOUSE_ARRIVE := Vector2i(4, 8)
## Casa de Pueblo Paleta (5×5, puerta en la fila de abajo) y la estatua de Carmín (2×3).
const HOUSE_STAMP := "PalletTown_5_3"
const STATUE_STAMP := "VermilionCity_25_32"
## Cerca de FireRed (como la de la Ruta 4): dos piezas que se alternan.
const FENCE := [214, 215]
## Centro del agua (sin orilla): el charco de la cueva.
const WATER_CENTER := 425

var roles: TileRoleSet
var tileset: TileSet
var world: WorldData
var stamps := {}


func build() -> void:
	roles = ZoneBuilder.load_roles()
	tileset = load(ZoneBuilder.TILESET_PATH)
	world = MapDocument.load_world_copy()
	var catalog: TileCatalog = load("res://data/world/tile_catalog.tres")
	for s: Dictionary in catalog.stamps:
		stamps[s["id"]] = s
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCENES_DIR))
	var houses := _houses()
	var town := _entry("pruebas_pueblo", "Pueblo de pruebas", ORIGIN, Vector2i(40, 32), "pradera", Vector2i(21, 18), false)
	var forest := _entry("pruebas_bosque", "Bosque de pruebas", ORIGIN + Vector2i(40, 0), Vector2i(28, 32), "bosque",
		Vector2i(12, 16), false)
	var cave := _entry("pruebas_cueva", "Cueva de pruebas", ORIGIN + Vector2i(0, 50), Vector2i(28, 22), "cueva",
		Vector2i(8, 8), true)
	_build_town(town, houses)
	var mouth := _build_forest(forest)
	var ladder := _build_cave(cave)
	forest.warps[mouth] = {"to": cave.id, "cell": ladder}
	cave.warps[ladder] = {"to": forest.id, "cell": mouth}
	for e in [town, forest, cave] + houses:
		_save_entry(e)
	print("[zona de pruebas] lista: pruebas_pueblo, pruebas_bosque, pruebas_cueva, pruebas_casa_1..4")


func _entry(id: String, name: String, origin: Vector2i, size: Vector2i, biome: String, hub: Vector2i,
		interior: bool) -> ZoneEntry:
	var e := ZoneEntry.new()
	e.id = id
	e.display_name = name
	e.scene_path = "%s/%s.tscn" % [SCENES_DIR, id]
	e.origin = origin
	e.size = size
	e.biome = biome
	e.hub = hub
	e.interior = interior
	e.test_zone = true
	return e


## Las 4 casas: misma escena (el interior de la casa de tu rival), cada una en su lugar. Las puertas de vuelta se
## completan al ubicar cada casa en el pueblo.
func _houses() -> Array[ZoneEntry]:
	var out: Array[ZoneEntry] = []
	for i in 4:
		var e := _entry("pruebas_casa_%d" % (i + 1), "Casa de pruebas %d" % (i + 1), ORIGIN + Vector2i(i * 16, 80),
			HOUSE_SIZE, "interior", Vector2i(5, 5), true)
		e.scene_path = HOUSE_SCENE
		out.append(e)
	return out


func _doc(e: ZoneEntry) -> MapDocument:
	return MapDocument.create(world, e, roles, tileset, false)


func _rect(x: int, y: int, w: int, h: int) -> Array:
	var out := []
	for j in h:
		for i in w:
			out.append(Vector2i(x + i, y + j))
	return out


func _paint(d: MapDocument, role_id: String, x: int, y: int, w: int, h: int) -> void:
	d.paint_role(_rect(x, y, w, h), roles.get_role(role_id))


func _fence(d: MapDocument, x: int, y: int, w: int) -> void:
	for i in w:
		var m: int = FENCE[i % 2]
		var ref := ZoneBuilder.below_ref(m)
		var c := Vector2i(x + i, y)
		d.clear(MapDocument.FOLIAGE, c)
		d.set_raw(MapDocument.GROUND, c, ref[0], ref[1], ZoneBuilder.collision_alt(tileset, roles, m, true))


## Celda de la puerta de un sello puesto en `at`.
func _door(stamp_id: String, at: Vector2i) -> Vector2i:
	var s: Dictionary = stamps[stamp_id]
	var i: int = (s["variants"][0]["doors"] as PackedInt32Array)[0]
	return at + Vector2i(i % s["size"].x, i / s["size"].x)


func _build_town(e: ZoneEntry, houses: Array[ZoneEntry]) -> void:
	var d := _doc(e)
	for side in ["up", "left", "down", "right"]:
		d.tree_border(side)
	# Caminos: la calle principal (sigue al bosque por la derecha), la que cruza y la de las casas de abajo.
	_paint(d, "dirt", 4, 16, 36, 2)
	_paint(d, "dirt", 19, 4, 2, 24)
	_paint(d, "dirt", 8, 24, 21, 2)
	# Plaza empedrada con la estatua en el medio.
	_paint(d, "stone_floor", 15, 12, 10, 9)
	d.place_stamp(stamps[STATUE_STAMP], Vector2i(19, 13))
	# Casas: dos arriba de la calle y dos abajo, cada una con su caminito hasta la calle.
	var spots := [Vector2i(7, 7), Vector2i(26, 7), Vector2i(7, 19), Vector2i(26, 19)]
	for i in 4:
		var at: Vector2i = spots[i]
		d.place_stamp(stamps[HOUSE_STAMP], at)
		var door := _door(HOUSE_STAMP, at)
		var to_road := 16 if at.y < 16 else 24
		_paint(d, "dirt", door.x, door.y + 1, 2, to_road - door.y - 1)
		e.warps[door] = {"to": houses[i].id, "cell": HOUSE_ARRIVE}
		for c in HOUSE_EXITS:
			houses[i].warps[c] = {"to": e.id, "cell": door}
	# Estanque con cerca abajo, cantero de flores con cerca, flores en la plaza y árboles sueltos.
	_paint(d, "water", 32, 5, 4, 5)
	_fence(d, 32, 11, 4)
	_paint(d, "flowers", 12, 8, 3, 3)
	_fence(d, 12, 12, 3)
	_paint(d, "flowers", 15, 22, 3, 2)
	_paint(d, "flowers", 22, 22, 3, 2)
	for t in [Vector2i(4, 12), Vector2i(33, 13), Vector2i(32, 22), Vector2i(14, 26)]:
		d.place_tree(t)
	_save(d)


## Devuelve la celda de la boca de la cueva.
func _build_forest(e: ZoneEntry) -> Vector2i:
	var d := _doc(e)
	for y in range(0, e.size.y, 2):
		for x in range(0, e.size.x, 2):
			d.place_tree(Vector2i(x, y))
	# La boca del Mt. Moon con su acantilado (Ruta 4), arriba a la derecha.
	var src := _open("ruta4")
	var clip := src.copy_region(Rect2i(30, 0, 13, 6))
	src.dispose()
	var at := Vector2i(15, 0)
	d.paste(clip, at)
	var mouth := at + Vector2i(7, 5)
	# Sendero: entra por la izquierda (la calle del pueblo), sube y llega a la cueva; pasto alto a los costados.
	_paint(d, "dirt", 0, 16, 14, 2)
	_paint(d, "dirt", 12, 8, 2, 10)
	_paint(d, "dirt", 12, 8, 11, 2)
	_paint(d, "dirt", mouth.x - 1, mouth.y + 1, 2, 3)
	_paint(d, "tall_grass", 2, 12, 8, 4)
	_paint(d, "tall_grass", 15, 12, 8, 8)
	_save(d)
	return mouth


## Devuelve la celda de la escalera (la de arriba a la izquierda del Mt. Moon).
func _build_cave(e: ZoneEntry) -> Vector2i:
	var d := _doc(e)
	var src := _open("mt_moon")
	# Las 4 esquinas del Mt. Moon (84×70): paredes de borde a borde y piso adentro.
	var parts := [[Rect2i(0, 0, 14, 11), Vector2i(0, 0)], [Rect2i(70, 0, 14, 11), Vector2i(14, 0)],
		[Rect2i(0, 59, 14, 11), Vector2i(0, 11)], [Rect2i(70, 59, 14, 11), Vector2i(14, 11)]]
	for p in parts:
		d.paste(src.copy_region(p[0]), p[1])
	src.dispose()
	for c in _rect(17, 13, 4, 3):
		d.set_metatile(MapDocument.WATER, c, WATER_CENTER)
	_save(d)
	return Vector2i(5, 6)


func _open(id: String) -> MapDocument:
	for z in world.zones:
		if z.id == id:
			return MapDocument.open(world, z, roles)
	push_error("No está la zona " + id)
	return null


func _save(d: MapDocument) -> void:
	var err := d.save(d.entry.scene_path, false)
	if err != OK:
		push_error("No se pudo guardar %s (%d)" % [d.entry.scene_path, err])
	d.dispose()


func _save_entry(e: ZoneEntry) -> void:
	var err := ResourceSaver.save(e, "%s/%s.tres" % [ZONES_DIR, e.id])
	if err != OK:
		push_error("No se pudo guardar la zona " + e.id)
