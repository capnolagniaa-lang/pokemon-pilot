extends SceneTree
## Aplica data/source/official.json (bajado de PokeAPI con tools/fetch_official_data.py) a los .tres:
## stats base, experiencia, curva de crecimiento, tasa de captura, tipos y datos de Pokédex de las especies;
## potencia, categoría, tipo y probabilidad de estado de los ataques. También define los 18 tipos y la tabla
## de tipos oficial, y deriva la recarga de cada ataque a partir de su potencia (ritmo del tiempo real).
## Las especies y ataques que no existen se crean (los ataques nuevos con una forma automática, ver _shape).
## Los ataques hechos a mano (MOVES del fetcher) conservan su forma; los automáticos solo se rearman con
## `-- --regen-auto`.
## Uso: godot --headless --path . --script res://tools/apply_official_data.gd [-- --regen-auto]

const T := "res://data/types/%s.tres"

# Tipo en PokeAPI -> [id del juego, nombre, color, color del centro, brillo]
const TYPES := {
	"normal": ["normal", "Normal", Color(0.72, 0.66, 0.56), Color(1.0, 0.97, 0.9), 1.0],
	"fire": ["fuego", "Fuego", Color(0.9, 0.26, 0.1), Color(1.0, 0.58, 0.22), 1.25],
	"water": ["agua", "Agua", Color(0.25, 0.55, 0.95), Color(0.75, 0.9, 1.0), 1.1],
	"grass": ["planta", "Planta", Color(0.35, 0.75, 0.3), Color(0.75, 1.0, 0.6), 1.0],
	"electric": ["electrico", "Eléctrico", Color(0.98, 0.85, 0.2), Color(1.0, 1.0, 0.8), 1.6],
	"ice": ["hielo", "Hielo", Color(0.6, 0.9, 1.0), Color(0.95, 1.0, 1.0), 1.3],
	"poison": ["veneno", "Veneno", Color(0.62, 0.3, 0.75), Color(0.9, 0.6, 1.0), 1.0],
	"flying": ["volador", "Volador", Color(0.62, 0.72, 0.95), Color(0.95, 0.97, 1.0), 1.0],
	"dark": ["siniestro", "Siniestro", Color(0.38, 0.3, 0.32), Color(0.62, 0.52, 0.56), 1.0],
	"fighting": ["lucha", "Lucha", Color(0.75, 0.22, 0.18), Color(1.0, 0.6, 0.5), 1.0],
	"ground": ["tierra", "Tierra", Color(0.82, 0.68, 0.38), Color(0.95, 0.88, 0.65), 1.0],
	"rock": ["roca", "Roca", Color(0.66, 0.58, 0.32), Color(0.88, 0.82, 0.6), 1.0],
	"bug": ["bicho", "Bicho", Color(0.62, 0.72, 0.16), Color(0.88, 0.95, 0.5), 1.0],
	"ghost": ["fantasma", "Fantasma", Color(0.45, 0.36, 0.62), Color(0.75, 0.65, 0.95), 1.15],
	"steel": ["acero", "Acero", Color(0.66, 0.68, 0.76), Color(0.92, 0.94, 1.0), 1.1],
	"psychic": ["psiquico", "Psíquico", Color(0.95, 0.35, 0.55), Color(1.0, 0.7, 0.82), 1.2],
	"dragon": ["dragon", "Dragón", Color(0.42, 0.28, 0.92), Color(0.72, 0.62, 1.0), 1.2],
	"fairy": ["hada", "Hada", Color(0.92, 0.6, 0.78), Color(1.0, 0.85, 0.93), 1.15],
}

# Tabla de efectividad oficial (6ª gen en adelante, la de PokeAPI). Solo los valores distintos de 1.
const CHART := {
	"normal": {"roca": 0.5, "fantasma": 0.0, "acero": 0.5},
	"fuego": {"fuego": 0.5, "agua": 0.5, "planta": 2.0, "hielo": 2.0, "bicho": 2.0, "roca": 0.5, "dragon": 0.5, "acero": 2.0},
	"agua": {"fuego": 2.0, "agua": 0.5, "planta": 0.5, "tierra": 2.0, "roca": 2.0, "dragon": 0.5},
	"electrico": {"agua": 2.0, "electrico": 0.5, "planta": 0.5, "tierra": 0.0, "volador": 2.0, "dragon": 0.5},
	"planta": {"fuego": 0.5, "agua": 2.0, "planta": 0.5, "veneno": 0.5, "tierra": 2.0, "volador": 0.5, "bicho": 0.5,
		"roca": 2.0, "dragon": 0.5, "acero": 0.5},
	"hielo": {"fuego": 0.5, "agua": 0.5, "planta": 2.0, "hielo": 0.5, "tierra": 2.0, "volador": 2.0, "dragon": 2.0, "acero": 0.5},
	"lucha": {"normal": 2.0, "hielo": 2.0, "veneno": 0.5, "volador": 0.5, "psiquico": 0.5, "bicho": 0.5, "roca": 2.0,
		"fantasma": 0.0, "siniestro": 2.0, "acero": 2.0, "hada": 0.5},
	"veneno": {"planta": 2.0, "veneno": 0.5, "tierra": 0.5, "roca": 0.5, "fantasma": 0.5, "acero": 0.0, "hada": 2.0},
	"tierra": {"fuego": 2.0, "electrico": 2.0, "planta": 0.5, "veneno": 2.0, "volador": 0.0, "bicho": 0.5, "roca": 2.0, "acero": 2.0},
	"volador": {"electrico": 0.5, "planta": 2.0, "lucha": 2.0, "bicho": 2.0, "roca": 0.5, "acero": 0.5},
	"psiquico": {"lucha": 2.0, "veneno": 2.0, "psiquico": 0.5, "siniestro": 0.0, "acero": 0.5},
	"bicho": {"fuego": 0.5, "planta": 2.0, "lucha": 0.5, "veneno": 0.5, "volador": 0.5, "psiquico": 2.0, "fantasma": 0.5,
		"siniestro": 2.0, "acero": 0.5, "hada": 0.5},
	"roca": {"fuego": 2.0, "hielo": 2.0, "lucha": 0.5, "tierra": 0.5, "volador": 2.0, "bicho": 2.0, "acero": 0.5},
	"fantasma": {"normal": 0.0, "psiquico": 2.0, "fantasma": 2.0, "siniestro": 0.5},
	"dragon": {"dragon": 2.0, "acero": 0.5, "hada": 0.0},
	"siniestro": {"lucha": 0.5, "psiquico": 2.0, "fantasma": 2.0, "siniestro": 0.5, "hada": 0.5},
	"acero": {"fuego": 0.5, "agua": 0.5, "electrico": 0.5, "hielo": 2.0, "roca": 2.0, "acero": 0.5, "hada": 2.0},
	"hada": {"fuego": 0.5, "lucha": 2.0, "veneno": 0.5, "dragon": 2.0, "siniestro": 2.0, "acero": 0.5},
}

# Ataques hechos a mano cuyo efecto secundario oficial es un estado que tenemos: id -> estado.
# Giro Fuego es una adaptación: en los juegos atrapa; acá puede quemar (30%).
const STATUS_EFFECTS := {"ascuas": "quemado", "lanzallamas": "quemado", "impactrueno": "paralizado",
	"trueno": "paralizado", "ventisca": "congelado", "giro_fuego": "quemado", "rayo": "paralizado",
	"rayo_hielo": "congelado", "rueda_fuego": "quemado", "golpe_cuerpo": "paralizado", "acido": "envenenado",
	"viento_hielo": "ralentizado"}
# Adaptaciones: Giro Fuego atrapa en los juegos; Ácido baja la Def. Esp. (acá envenena 30%);
# Viento Hielo baja la Velocidad (acá ralentiza siempre).
const ADAPTED_CHANCE := {"giro_fuego": 30, "acido": 30, "viento_hielo": 100}
# Ataques automáticos: problema de estado de PokeAPI -> estado del juego (los demás no se implementan aún).
const AILMENTS := {"burn": "quemado", "paralysis": "paralizado", "freeze": "congelado", "poison": "envenenado",
	"sleep": "dormido", "confusion": "desorientado", "trap": "enraizado"}
const SELF_TARGETS := ["user", "users-field", "user-and-allies", "ally", "entire-field", "opponents-field", "specific-move", "all-pokemon"]
const SHIELDS := ["protect", "detect", "endure"]


func _init() -> void:
	var regen := "--regen-auto" in OS.get_cmdline_user_args()
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/source/official.json"))
	for api_type in TYPES:
		var row: Array = TYPES[api_type]
		var t: ElementType = load(T % row[0]) if ResourceLoader.exists(T % row[0]) else ElementType.new()
		t.id = row[0]
		t.display_name = row[1]
		t.color = row[2]
		t.core_color = row[3]
		t.glow = row[4]
		_save(t, T % row[0])
	var chart: TypeChart = load(T % "type_chart")
	chart.multipliers = CHART.duplicate(true)
	_save(chart, T % "type_chart")

	# Los estados NO se tocan acá: siguen el plan de identidad (docs/PLAN_IDENTIDAD_COMBATE.md) y se
	# editan directo en data/status/*.tres.

	var created_moves := 0
	for id in data["moves"]:
		var src: Dictionary = data["moves"][id]
		var path := "res://data/moves/%s.tres" % id
		var auto: bool = src.get("auto", false)
		var exists := ResourceLoader.exists(path)
		var m: MoveData = load(path) if exists and not (auto and regen) else MoveData.new()
		m.id = id
		if not exists:
			created_moves += 1
		if m.display_name == "":
			m.display_name = src.get("name_es", id)
		m.element = load(T % TYPES[src["type"]][0])
		m.power = float(src["power"])
		m.category = {"physical": MoveData.Category.PHYSICAL, "special": MoveData.Category.SPECIAL}.get(src["category"], MoveData.Category.STATUS)
		if auto and (not exists or regen):
			_shape(m, src)
		if STATUS_EFFECTS.has(id):
			m.status = load("res://data/status/%s.tres" % STATUS_EFFECTS[id])
			m.status_chance = ADAPTED_CHANCE.get(id, int(src["effect_chance"])) / 100.0
		elif auto and AILMENTS.has(src["ailment"]) and m.category != MoveData.Category.STATUS:
			m.status = load("res://data/status/%s.tres" % AILMENTS[src["ailment"]])
			m.status_chance = maxf(src["ailment_chance"], src["effect_chance"]) / 100.0
		elif not auto:
			m.status = null
			m.status_chance = 0.0
		_pace(m, auto)
		_save(m, path)

	var created_species := 0
	for id in data["species"]:
		var src: Dictionary = data["species"][id]
		var path := "res://data/species/%s.tres" % id
		var s: SpeciesData = load(path) if ResourceLoader.exists(path) else SpeciesData.new()
		if s.id == "":
			created_species += 1
			s.id = id
			s.display_name = src["name_es"]
		s.dex = src["dex"]
		var b: Dictionary = src["base_stats"]
		s.base_hp = b["hp"]
		s.base_attack = b["attack"]
		s.base_defense = b["defense"]
		s.base_sp_attack = b["sp_attack"]
		s.base_sp_defense = b["sp_defense"]
		s.base_speed = b["speed"]
		s.base_experience = src["base_experience"]
		s.growth_rate = src["growth_rate"]
		s.capture_rate = src["capture_rate"]
		s.genus = src.get("genus_es", "")
		s.pokedex_entry = src.get("flavor_es", "")
		s.height_m = src.get("height_m", 0.0)
		s.weight_kg = src.get("weight_kg", 0.0)
		var types: Array[ElementType] = []
		for api_type in src["types"]:
			types.append(load(T % TYPES[api_type][0]))
		s.types = types
		_save(s, path)
	print("Datos oficiales aplicados: %d especies (%d nuevas), %d ataques (%d nuevos)." % [
		data["species"].size(), created_species, data["moves"].size(), created_moves])
	quit()


## Forma automática de un ataque oficial en tiempo real (para los ~300 que no se hicieron a mano):
##  · estado sobre uno mismo: Protección/Detección → escudo; curación → Síntesis; el resto, mejora propia
##    sin efecto todavía (subir/bajar stats no está implementado);
##  · estado sobre el rival con problema de estado (Somnífero, Onda Trueno...) → disparo que lo aplica;
##    sin problema de estado (Gruñido, Malicioso...) → onda corta sin efecto todavía;
##  · daño a todos los rivales (Terremoto, Surf...) → área alrededor;
##  · físico: prioridad o potencia ≥ 80 → embestida; si no, golpe cuerpo a cuerpo;
##  · especial → disparo (los muy fuertes con carga telegrafiada).
func _shape(m: MoveData, src: Dictionary) -> void:
	var power: float = src["power"]
	var target: String = src["target"]
	if src["category"] == "status":
		m.power = 0.0
		m.knockback = 0.0
		if SHIELDS.has(src["name_en"]):
			m.kind = MoveData.Kind.SHIELD
			m.duration = 1.4
		elif src["healing"] > 0 or src["meta_category"] == "heal":
			m.kind = MoveData.Kind.SELF_BUFF
			m.self_status = load("res://data/status/sintesis.tres")
		elif SELF_TARGETS.has(target):
			m.kind = MoveData.Kind.SELF_BUFF
		elif AILMENTS.has(src["ailment"]):
			m.kind = MoveData.Kind.PROJECTILE
			m.speed = 220.0
			m.size = 4.5
			m.lifetime = 0.8
			var st: Array[StatusEffect] = [load("res://data/status/%s.tres" % AILMENTS[src["ailment"]])]
			m.statuses_on_hit = st
		else:
			m.kind = MoveData.Kind.AREA
			m.radius = 40.0
		return
	if target in ["all-opponents", "all-other-pokemon"]:
		m.kind = MoveData.Kind.AREA
		m.radius = 52.0
		m.knockback = 200.0
		m.cast_time = 0.3 if power >= 90.0 else 0.0
		m.recovery = 0.3 if power >= 90.0 else 0.1
	elif src["category"] == "physical":
		if src["priority"] > 0 or power >= 80.0:
			m.kind = MoveData.Kind.DASH
			m.dash_time = 0.2 if src["priority"] > 0 else 0.28
			m.knockback = 140.0 if src["priority"] > 0 else 220.0
			m.recovery = 0.1 if src["priority"] > 0 else 0.3
		else:
			m.kind = MoveData.Kind.MELEE
			m.melee_range = 13.0
			m.swing_radius = 12.0
			m.knockback = 120.0
			m.final_knockback = 150.0
			m.recovery = 0.1
	else:
		m.kind = MoveData.Kind.PROJECTILE
		m.speed = 280.0
		m.size = clampf(3.0 + power / 40.0, 3.0, 8.0)
		m.lifetime = 0.85
		m.knockback = clampf(power * 1.6, 60.0, 260.0)
		m.cast_time = 0.45 if power >= 100.0 else (0.15 if power >= 80.0 else 0.0)
		m.recovery = 0.4 if power >= 100.0 else 0.1


## Recarga según la potencia: los ataques fuertes tardan más. Los de estado tienen recarga larga.
func _pace(m: MoveData, auto: bool) -> void:
	match m.kind:
		MoveData.Kind.PROJECTILE:
			m.cooldown = snappedf(0.7 + m.power / 55.0, 0.05)
		MoveData.Kind.AREA:
			m.cooldown = snappedf(2.0 + m.power / 35.0, 0.05)
		MoveData.Kind.DASH:
			m.cooldown = snappedf(1.0 + m.power / 70.0, 0.05)
		MoveData.Kind.SHIELD:
			m.cooldown = 8.0
		MoveData.Kind.MELEE:
			if auto:
				m.cooldown = snappedf(0.6 + m.power / 80.0, 0.05)
		MoveData.Kind.SELF_BUFF:
			if auto:
				m.cooldown = 10.0
	if auto and m.category == MoveData.Category.STATUS and m.kind in [MoveData.Kind.PROJECTILE, MoveData.Kind.AREA]:
		m.cooldown = 6.0


func _save(res: Resource, path: String) -> void:
	var err := ResourceSaver.save(res, path)
	if err != OK:
		push_error("No se pudo guardar %s (%d)" % [path, err])
