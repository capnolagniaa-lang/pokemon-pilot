extends SceneTree
## Aplica data/source/official.json (bajado de PokeAPI con tools/fetch_official_data.py) a los .tres:
## stats base, experiencia, curva de crecimiento, tasa de captura y tipos de las especies; potencia,
## categoría, tipo y probabilidad de estado de los ataques. También define la tabla de tipos oficial
## y deriva recarga/energía de cada ataque a partir de su potencia (ritmo del combate en tiempo real).
## Uso: godot --headless --path . --script res://tools/apply_official_data.gd

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
}

# Tabla de efectividad oficial (solo entre los tipos que hay en el juego).
const CHART := {
	"fuego": {"fuego": 0.5, "agua": 0.5, "planta": 2.0, "hielo": 2.0},
	"agua": {"fuego": 2.0, "agua": 0.5, "planta": 0.5},
	"planta": {"fuego": 0.5, "agua": 2.0, "planta": 0.5, "veneno": 0.5, "volador": 0.5},
	"electrico": {"agua": 2.0, "electrico": 0.5, "planta": 0.5, "volador": 2.0},
	"hielo": {"fuego": 0.5, "agua": 0.5, "planta": 2.0, "hielo": 0.5, "volador": 2.0},
	"veneno": {"planta": 2.0, "veneno": 0.5},
	"volador": {"electrico": 0.5, "planta": 2.0},
	"siniestro": {"siniestro": 0.5},
	"normal": {},
}

# Ataques cuyo efecto secundario oficial es un estado que tenemos: id -> estado.
# Giro Fuego es una adaptación: en los juegos atrapa; acá puede quemar (30%).
const STATUS_EFFECTS := {"ascuas": "quemado", "lanzallamas": "quemado", "impactrueno": "paralizado",
	"trueno": "paralizado", "ventisca": "congelado", "giro_fuego": "quemado"}
const ADAPTED_CHANCE := {"giro_fuego": 30}


func _init() -> void:
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

	for id in data["moves"]:
		var src: Dictionary = data["moves"][id]
		var path := "res://data/moves/%s.tres" % id
		var m: MoveData = load(path)
		m.element = load(T % TYPES[src["type"]][0])
		m.power = float(src["power"])
		m.category = {"physical": MoveData.Category.PHYSICAL, "special": MoveData.Category.SPECIAL}.get(src["category"], MoveData.Category.STATUS)
		if STATUS_EFFECTS.has(id):
			m.status = load("res://data/status/%s.tres" % STATUS_EFFECTS[id])
			m.status_chance = ADAPTED_CHANCE.get(id, int(src["effect_chance"])) / 100.0
		else:
			m.status = null
			m.status_chance = 0.0
		_pace(m)
		_save(m, path)

	for id in data["species"]:
		var src: Dictionary = data["species"][id]
		var path := "res://data/species/%s.tres" % id
		var s: SpeciesData = load(path)
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
		var types: Array[ElementType] = []
		for api_type in src["types"]:
			types.append(load(T % TYPES[api_type][0]))
		s.types = types
		_save(s, path)
	print("Datos oficiales aplicados: %d especies, %d ataques." % [data["species"].size(), data["moves"].size()])
	quit()


## Recarga y energía según la potencia: los ataques fuertes tardan más y cuestan más.
func _pace(m: MoveData) -> void:
	match m.kind:
		MoveData.Kind.PROJECTILE:
			m.cooldown = snappedf(0.7 + m.power / 55.0, 0.05)
			m.energy_cost = roundf(8.0 + m.power / 5.0)
		MoveData.Kind.AREA:
			m.cooldown = snappedf(2.0 + m.power / 35.0, 0.05)
			m.energy_cost = roundf(14.0 + m.power / 4.0)
		MoveData.Kind.DASH:
			m.cooldown = snappedf(1.0 + m.power / 70.0, 0.05)
			m.energy_cost = roundf(8.0 + m.power / 6.0)
		MoveData.Kind.SHIELD:
			m.cooldown = 8.0
			m.energy_cost = 25.0


func _save(res: Resource, path: String) -> void:
	var err := ResourceSaver.save(res, path)
	if err != OK:
		push_error("No se pudo guardar %s (%d)" % [path, err])
