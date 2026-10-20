extends Node
## Datos globales: tipos, ataques, especies, equipo del jugador, sprites y controles.

const SpriteData = preload("res://scripts/sprite_data.gd")

const TYPE_COLORS := {
	"fuego": Color(0.93, 0.42, 0.2),
	"agua": Color(0.25, 0.55, 0.95),
	"planta": Color(0.35, 0.75, 0.3),
	"normal": Color(0.72, 0.66, 0.56),
}

# Multiplicador de daño: TYPE_CHART[tipo_ataque][tipo_defensor]
const TYPE_CHART := {
	"fuego": {"planta": 2.0, "agua": 0.5, "fuego": 0.5},
	"agua": {"fuego": 2.0, "planta": 0.5, "agua": 0.5},
	"planta": {"agua": 2.0, "fuego": 0.5, "planta": 0.5},
	"normal": {},
}

# kind: projectile (disparo), dash (embestida), area (golpe alrededor), shield (escudo)
const MOVES := {
	"ascuas": {"name": "Ascuas", "type": "fuego", "kind": "projectile", "power": 9.0, "cooldown": 0.45, "energy": 8.0, "speed": 560.0, "size": 7.0, "life": 0.9},
	"lanzallamas": {"name": "Lanzallamas", "type": "fuego", "kind": "projectile", "power": 14.0, "cooldown": 0.9, "energy": 14.0, "speed": 620.0, "size": 9.0, "life": 0.8},
	"giro_fuego": {"name": "Giro Fuego", "type": "fuego", "kind": "area", "power": 20.0, "cooldown": 4.0, "energy": 30.0, "radius": 120.0},
	"pistola_agua": {"name": "Pistola Agua", "type": "agua", "kind": "projectile", "power": 10.0, "cooldown": 0.5, "energy": 8.0, "speed": 600.0, "size": 7.0, "life": 0.9},
	"burbuja": {"name": "Burbuja", "type": "agua", "kind": "projectile", "power": 11.0, "cooldown": 0.6, "energy": 9.0, "speed": 420.0, "size": 10.0, "life": 1.2},
	"surf": {"name": "Surf", "type": "agua", "kind": "area", "power": 19.0, "cooldown": 3.8, "energy": 30.0, "radius": 145.0},
	"hoja_afilada": {"name": "Hoja Afilada", "type": "planta", "kind": "projectile", "power": 8.0, "cooldown": 0.35, "energy": 7.0, "speed": 680.0, "size": 6.0, "life": 0.8},
	"latigo_cepa": {"name": "Látigo Cepa", "type": "planta", "kind": "dash", "power": 13.0, "cooldown": 1.3, "energy": 13.0},
	"danza_petalo": {"name": "Danza Pétalo", "type": "planta", "kind": "area", "power": 20.0, "cooldown": 4.0, "energy": 30.0, "radius": 130.0},
	"placaje": {"name": "Placaje", "type": "normal", "kind": "dash", "power": 13.0, "cooldown": 1.4, "energy": 14.0},
	"aranazo": {"name": "Arañazo", "type": "normal", "kind": "dash", "power": 12.0, "cooldown": 1.1, "energy": 12.0, "dash_time": 0.18},
	"ataque_rapido": {"name": "Ataque Rápido", "type": "normal", "kind": "dash", "power": 11.0, "cooldown": 0.9, "energy": 12.0, "dash_time": 0.32},
	"mordisco": {"name": "Mordisco", "type": "normal", "kind": "dash", "power": 15.0, "cooldown": 1.5, "energy": 15.0},
	"rapidez": {"name": "Rapidez", "type": "normal", "kind": "projectile", "power": 10.0, "cooldown": 0.6, "energy": 9.0, "speed": 520.0, "size": 8.0, "life": 1.0},
	"tornado": {"name": "Tornado", "type": "normal", "kind": "projectile", "power": 11.0, "cooldown": 0.65, "energy": 10.0, "speed": 480.0, "size": 11.0, "life": 1.0},
	"vozarron": {"name": "Vozarrón", "type": "normal", "kind": "area", "power": 19.0, "cooldown": 4.0, "energy": 30.0, "radius": 140.0},
	"proteccion": {"name": "Protección", "type": "normal", "kind": "shield", "power": 0.0, "cooldown": 6.0, "energy": 20.0, "duration": 1.4},
}

# dex = número de Pokédex (para buscar los sprites en sprite_data.gd)
const SPECIES := {
	"Bulbasaur": {"dex": 1, "type": "planta", "hp": 62.0, "atk": 12.0, "speed": 185.0, "moves": ["hoja_afilada", "latigo_cepa", "danza_petalo", "proteccion"]},
	"Charmander": {"dex": 4, "type": "fuego", "hp": 55.0, "atk": 13.0, "speed": 205.0, "moves": ["ascuas", "aranazo", "giro_fuego", "proteccion"]},
	"Squirtle": {"dex": 7, "type": "agua", "hp": 66.0, "atk": 11.0, "speed": 180.0, "moves": ["pistola_agua", "placaje", "surf", "proteccion"]},
	"Pidgey": {"dex": 16, "type": "normal", "hp": 50.0, "atk": 10.0, "speed": 220.0, "moves": ["tornado", "ataque_rapido", "vozarron", "proteccion"]},
	"Rattata": {"dex": 19, "type": "normal", "hp": 46.0, "atk": 12.0, "speed": 235.0, "moves": ["mordisco", "ataque_rapido", "vozarron", "proteccion"]},
	"Vulpix": {"dex": 37, "type": "fuego", "hp": 50.0, "atk": 12.0, "speed": 215.0, "moves": ["ascuas", "ataque_rapido", "giro_fuego", "proteccion"]},
	"Oddish": {"dex": 43, "type": "planta", "hp": 60.0, "atk": 11.0, "speed": 160.0, "moves": ["hoja_afilada", "placaje", "danza_petalo", "proteccion"]},
	"Psyduck": {"dex": 54, "type": "agua", "hp": 64.0, "atk": 11.0, "speed": 170.0, "moves": ["pistola_agua", "aranazo", "surf", "proteccion"]},
	"Growlithe": {"dex": 58, "type": "fuego", "hp": 68.0, "atk": 13.0, "speed": 195.0, "moves": ["lanzallamas", "mordisco", "giro_fuego", "proteccion"]},
	"Poliwag": {"dex": 60, "type": "agua", "hp": 52.0, "atk": 10.0, "speed": 210.0, "moves": ["burbuja", "placaje", "surf", "proteccion"]},
	"Bellsprout": {"dex": 69, "type": "planta", "hp": 56.0, "atk": 13.0, "speed": 190.0, "moves": ["hoja_afilada", "latigo_cepa", "danza_petalo", "proteccion"]},
	"Eevee": {"dex": 133, "type": "normal", "hp": 60.0, "atk": 12.0, "speed": 200.0, "moves": ["rapidez", "placaje", "vozarron", "proteccion"]},
}

const STARTERS := ["Bulbasaur", "Charmander", "Squirtle"]
const MAX_PARTY := 6

# Cada entrada del equipo: {"species", "level", "xp", "hp"}
var party: Array = []
var active := 0
var balls := 10

var _tex_cache := {}


func _ready() -> void:
	_bind("move_up", [KEY_W, KEY_UP])
	_bind("move_down", [KEY_S, KEY_DOWN])
	_bind("move_left", [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("attack_1", [KEY_1, KEY_J])
	_bind("attack_2", [KEY_2, KEY_K])
	_bind("attack_3", [KEY_3, KEY_L])
	_bind("attack_4", [KEY_4])
	_bind("dodge", [KEY_SPACE, KEY_SHIFT])
	_bind("capture", [KEY_E])
	_bind("switch", [KEY_TAB, KEY_Q])
	_bind_mouse("attack_1", MOUSE_BUTTON_LEFT)
	_bind_mouse("attack_2", MOUSE_BUTTON_RIGHT)


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)


func _bind_mouse(action: String, button: MouseButton) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)


## Carga una textura; si el proyecto no fue importado todavía, la lee directo del PNG.
func texture(path: String) -> Texture2D:
	if _tex_cache.has(path):
		return _tex_cache[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	else:
		var img := Image.load_from_file(path)
		if img != null:
			tex = ImageTexture.create_from_image(img)
	_tex_cache[path] = tex
	return tex


func anims_of(species_name: String) -> Dictionary:
	return SpriteData.ANIMS.get(SPECIES[species_name]["dex"], {})


func portrait_of(species_name: String) -> Texture2D:
	var a := anims_of(species_name)
	return texture(a["portrait"]) if a.has("portrait") else null


func stat_mult(level: int) -> float:
	return 1.0 + 0.1 * (level - 1)


func max_hp_of(entry: Dictionary) -> float:
	return SPECIES[entry["species"]]["hp"] * stat_mult(entry["level"])


func make_entry(species_name: String, level: int) -> Dictionary:
	var entry := {"species": species_name, "level": level, "xp": 0}
	entry["hp"] = max_hp_of(entry)
	return entry


func xp_to_next(level: int) -> int:
	return 20 + level * 10


## Suma experiencia y devuelve cuántos niveles subió.
func add_xp(entry: Dictionary, amount: int) -> int:
	var ups := 0
	entry["xp"] += amount
	while entry["xp"] >= xp_to_next(entry["level"]):
		entry["xp"] -= xp_to_next(entry["level"])
		entry["level"] += 1
		ups += 1
	return ups


func effectiveness(atk_type: String, def_type: String) -> float:
	return TYPE_CHART.get(atk_type, {}).get(def_type, 1.0)


## Devuelve [daño, efectividad].
func calc_damage(attack: Dictionary, def_type: String) -> Array:
	var eff := effectiveness(attack["type"], def_type)
	var stab := 1.25 if attack["type"] == attack["user_type"] else 1.0
	var dmg: float = attack["power"] * (attack["atk"] / 10.0) * eff * stab * randf_range(0.9, 1.1)
	return [dmg, eff]


func next_alive(from: int) -> int:
	for k in range(1, party.size() + 1):
		var i := (from + k) % party.size()
		if party[i]["hp"] > 0.0:
			return i
	return -1


func heal_all(fraction: float = 1.0) -> void:
	for e in party:
		var mx := max_hp_of(e)
		e["hp"] = minf(mx, e["hp"] + mx * fraction)
