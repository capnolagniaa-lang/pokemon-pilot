extends SceneTree
## Habilidades (decisión del usuario 2026-10-28: "se respetan las habilidades innatas, todos los movimientos se comportan
## igual para todos y el estilo lo define el usuario"; los jefes de gimnasio conservan su kit de jefe).
##  · Crea data/abilities/<id>.tres (SignatureData con ability_mechanic.gd) para las 76 habilidades de 3ª generación de
##    data/source/abilities.json (tools/fetch_abilities.py), con su efecto en tiempo real (tabla EFFECTS).
##  · A cada especie le pone sus habilidades (SpeciesData.abilities).
##  · Los kits: los de BOSSES pasan a SpeciesData.boss_kit (los usa solo el Pokémon de un líder de gimnasio); todos los
##    demás se sacan de las especies (los archivos de data/kits/ quedan, por si se quieren retomar).
## Después: tools/build_learnsets.gd (sin kit: el learnset oficial de FRLG + las MT).
## Uso: godot --headless --path . --quit-after 20000 --script res://tools/apply_abilities.gd

const MECH := "res://scripts/combat/signatures/ability_mechanic.gd"
## Especies con kit de jefe (el de su líder: Brock, Misty, Lt. Surge).
const BOSSES := ["onix", "starmie", "raichu"]
const C_FIRE := Color(1.0, 0.5, 0.25)
const C_WATER := Color(0.35, 0.6, 1.0)
const C_GRASS := Color(0.4, 0.8, 0.35)
const C_ELEC := Color(1.0, 0.85, 0.3)
const C_MIND := Color(0.85, 0.55, 0.95)
const C_ROCK := Color(0.75, 0.65, 0.5)
const C_POISON := Color(0.7, 0.45, 0.85)
const C_BODY := Color(0.85, 0.85, 0.95)

## id -> [qué hace en tiempo real, color, parámetros de ability_mechanic.gd]
const EFFECTS := {
	"espesura": ["Con menos de 1/3 de vida sus ataques de tipo Planta pegan ×1,5.", C_GRASS, {"pinch": "planta"}],
	"mar_llamas": ["Con menos de 1/3 de vida sus ataques de tipo Fuego pegan ×1,5.", C_FIRE, {"pinch": "fuego"}],
	"torrente": ["Con menos de 1/3 de vida sus ataques de tipo Agua pegan ×1,5.", C_WATER, {"pinch": "agua"}],
	"enjambre": ["Con menos de 1/3 de vida sus ataques de tipo Bicho pegan ×1,5.", C_GRASS, {"pinch": "bicho"}],
	"polvo_escudo": ["La mitad de las veces no le entra un problema de estado.", C_BODY, {"status_resist": 0.5}],
	"mudar": ["Cada 4 s se saca de encima los problemas de estado.", C_POISON, {"shed_every": 4.0, "shed_text": "¡Mudar!"}],
	"ojo_compuesto": ["Sus ataques con estado lo ponen un 30% más seguido.", C_GRASS, {"status_chance_mult": 1.3}],
	"vista_lince": ["No lo desorientan y sus disparos pegan +10%.", C_BODY, {"immune": ["desorientado"], "kind_mult": {"PROJECTILE": 1.1}}],
	"fuga": ["Esquiva mucho más seguido (recarga del esquive −40%).", C_BODY, {"dodge_mult": 0.6}],
	"agallas": ["Con un problema de estado sus ataques físicos pegan ×1,5.", C_FIRE, {"status_atk": 1.5}],
	"intimidacion": ["Al encarar a un rival lo deja Intimidado (pega menos).", C_FIRE, {"intimidate": "intimidado"}],
	"electricidad_estatica": ["Al que le pega cuerpo a cuerpo lo paraliza (30%).", C_ELEC, {"contact_status": "paralizado", "contact_chance": 0.3}],
	"velo_arena": ["Un 12% de los golpes no le entran.", C_ROCK, {"evasion": 0.12}],
	"punto_toxico": ["Al que le pega cuerpo a cuerpo lo envenena (30%).", C_POISON, {"contact_status": "envenenado", "contact_chance": 0.3}],
	"gran_encanto": ["Al que le pega cuerpo a cuerpo lo deja Intimidado (30%).", C_MIND, {"contact_status": "intimidado", "contact_chance": 0.3}],
	"absorbe_fuego": ["Los ataques de Fuego no le hacen nada y le suben un 50% los suyos de Fuego por 8 s.", C_FIRE, {"absorb": {"fuego": "boost"}}],
	"fuerza_mental": ["No sufre el stagger de los golpes: puede contestar enseguida.", C_MIND, {"no_stagger": true}],
	"clorofila": ["De día se mueve un 30% más rápido.", C_GRASS, {"day_speed": 1.3}],
	"efecto_espora": ["Al que le pega cuerpo a cuerpo le pone veneno, parálisis o sueño (30%).", C_GRASS, {"contact_status": ["envenenado", "paralizado", "dormido"], "contact_chance": 0.3}],
	"trampa_arena": ["Los rivales cerca suyo quedan ralentizados.", C_ROCK, {"aura_status": "ralentizado", "aura_radius": 60.0}],
	"recogida": ["Si gana una pelea, a veces encuentra una Poción (tu equipo).", C_BODY, {"pickup": true}],
	"flexibilidad": ["No lo paralizan.", C_BODY, {"immune": ["paralizado"]}],
	"humedad": ["No lo queman y el fuego le hace un 20% menos.", C_WATER, {"immune": ["quemado"], "element_taken": {"fuego": 0.8}}],
	"aclimatacion": ["No lo empapan ni le afecta el clima del suelo (mojado, hielo).", C_WATER, {"immune": ["empapado", "ralentizado"]}],
	"espiritu_vital": ["No lo duermen.", C_FIRE, {"immune": ["dormido", "somnolencia"]}],
	"absorbe_agua": ["Los ataques de Agua no le hacen nada y lo curan un 25%.", C_WATER, {"absorb": {"agua": "heal"}}],
	"sincronia": ["Los problemas de estado que le ponen se los devuelve al que se los puso.", C_MIND, {"sync": true}],
	"cuerpo_puro": ["No le bajan nada: no lo intimidan, exponen ni ralentizan.", C_BODY, {"immune": ["intimidado", "expuesto", "ralentizado"]}],
	"lodo_liquido": ["El que le roba vida (Absorber, Chupavidas...) en vez de curarse se lastima.", C_POISON, {"drain_punish": true}],
	"cabeza_roca": ["Sus embestidas pegan +25%.", C_ROCK, {"kind_mult": {"DASH": 1.25, "LUNGE": 1.25}}],
	"robustez": ["Con la vida llena, un golpe que lo debilitaría lo deja con 1 de vida.", C_ROCK, {"sturdy": true}],
	"despiste": ["No lo intimidan ni lo desorientan.", C_WATER, {"immune": ["intimidado", "desorientado"]}],
	"ritmo_propio": ["No lo desorientan.", C_MIND, {"immune": ["desorientado"]}],
	"iman": ["Sus ataques pegan +30% a los de tipo Acero.", C_ELEC, {"type_bonus": {"acero": 1.3}}],
	"madrugar": ["Dormido, se despierta solo al segundo.", C_BODY, {"wake_fast": 1.0}],
	"sebo": ["El fuego y el hielo le hacen la mitad.", C_WATER, {"element_taken": {"fuego": 0.5, "hielo": 0.5}}],
	"hedor": ["Sus golpes a veces aturden al rival un instante (10%).", C_POISON, {"flinch_chance": 0.1}],
	"viscosidad": ["Casi no lo empujan.", C_POISON, {"knockback": 0.4}],
	"caparazon": ["Lo cubre su caparazón: recibe 15% menos de frente.", C_WATER, {"front_mult": 0.85}],
	"levitacion": ["Flota: los ataques de Tierra no le hacen nada.", C_MIND, {"absorb": {"tierra": "immune"}}],
	"insomnio": ["No lo duermen.", C_MIND, {"immune": ["dormido", "somnolencia", "bostezo"]}],
	"corte_fuerte": ["No lo intimidan.", C_WATER, {"immune": ["intimidado"]}],
	"insonorizar": ["No le afectan los sonidos: no lo duermen con Canto ni lo desorientan con Supersónico.", C_BODY, {"immune": ["dormido", "desorientado"]}],
	"pararrayos": ["Atrae los rayos: los ataques Eléctricos no le hacen nada y le suben los suyos.", C_ELEC, {"absorb": {"electrico": "boost"}}],
	"cura_natural": ["Cada 8 s se cura los problemas de estado.", C_GRASS, {"shed_every": 8.0, "shed_text": "¡Cura Natural!"}],
	"dicha": ["Sus ataques con estado lo ponen el doble de seguido.", C_MIND, {"status_chance_mult": 2.0}],
	"nado_rapido": ["Mojado (agua, suelo mojado o empapado) se mueve un 40% más rápido.", C_WATER, {"wet_speed": 1.4}],
	"velo_agua": ["No lo queman.", C_WATER, {"immune": ["quemado"]}],
	"iluminacion": ["Brilla: sus golpes a veces dejan Expuesto al rival (20%).", C_ELEC, {"on_hit_status": "expuesto", "on_hit_chance": 0.2}],
	"cuerpo_llama": ["Al que le pega cuerpo a cuerpo lo quema (30%).", C_FIRE, {"contact_status": "quemado", "contact_chance": 0.3}],
	"absorbe_electricidad": ["Los ataques Eléctricos no le hacen nada y lo curan un 25%.", C_ELEC, {"absorb": {"electrico": "heal"}}],
	"calco": ["Copia la habilidad del primer rival que encara.", C_MIND, {"trace": true}],
	"armadura_batalla": ["Su armadura lo cubre: recibe 15% menos de frente.", C_ROCK, {"front_mult": 0.85}],
	"presion": ["Cada golpe suyo le suma 0,3 s a las recargas del rival.", C_MIND, {"cooldown_drain": 0.3}],
	"inmunidad": ["No lo envenenan.", C_BODY, {"immune": ["envenenado"]}],
	"entusiasmo": ["Sus golpes cuerpo a cuerpo pegan +30%.", C_FIRE, {"kind_mult": {"MELEE": 1.3, "LUNGE": 1.3, "DASH": 1.3}}],
	"potencia": ["Sus golpes cuerpo a cuerpo pegan +50%.", C_BODY, {"kind_mult": {"MELEE": 1.5, "LUNGE": 1.5, "DASH": 1.5, "WHIP": 1.5}}],
	"energia_pura": ["Sus golpes cuerpo a cuerpo pegan +50%.", C_MIND, {"kind_mult": {"MELEE": 1.5, "LUNGE": 1.5, "DASH": 1.5, "WHIP": 1.5}}],
	"impulso": ["Siempre un 15% más rápido.", C_GRASS, {"speed": 1.15}],
	"sombra_trampa": ["Los rivales cerca suyo quedan ralentizados.", C_MIND, {"aura_status": "ralentizado", "aura_radius": 70.0}],
	"escudo_magma": ["No lo congelan.", C_FIRE, {"immune": ["congelado", "escarcha"]}],
	"ventosas": ["Se agarra al suelo: casi no lo empujan.", C_WATER, {"knockback": 0.2}],
	"chorro_arena": ["Levanta arena: los rivales cerca suyo quedan desorientados.", C_ROCK, {"aura_status": "desorientado", "aura_radius": 60.0}],
	"cura_lluvia": ["Mojado se cura un 3% por segundo.", C_WATER, {"wet_heal": 0.03}],
	"llovizna": ["Llueve a su alrededor: los rivales cerca quedan empapados.", C_WATER, {"aura_status": "empapado", "aura_radius": 80.0}],
	"ausente": ["Por ahora sin efecto (en los juegos ataca un turno sí y otro no).", C_BODY, {}],
	"superguarda": ["Por ahora sin efecto (en los juegos solo le hacen daño los súper eficaces).", C_MIND, {}],
	"mas": ["Sus disparos pegan +20%.", C_ELEC, {"kind_mult": {"PROJECTILE": 1.2}}],
	"menos": ["Sus disparos pegan +20%.", C_ELEC, {"kind_mult": {"PROJECTILE": 1.2}}],
	"piel_tosca": ["Al que le pega cuerpo a cuerpo le devuelve un 12% del daño.", C_ROCK, {"thorns": 0.12}],
	"humo_blanco": ["No le bajan nada: no lo intimidan, exponen ni ralentizan.", C_BODY, {"immune": ["intimidado", "expuesto", "ralentizado"]}],
	"sequia": ["Sus golpes a veces queman (10%).", C_FIRE, {"on_hit_status": "quemado", "on_hit_chance": 0.1}],
	"escama_especial": ["Con un problema de estado recibe 30% menos.", C_WATER, {"status_def": 0.7}],
	"prediccion": ["No lo empapan ni lo congelan.", C_WATER, {"immune": ["empapado", "congelado"]}],
	"cambio_color": ["Por ahora sin efecto (en los juegos cambia al tipo que le pega).", C_MIND, {}],
	"bucle_aire": ["No lo empapan ni le afecta el clima del suelo (mojado, hielo).", C_MIND, {"immune": ["empapado", "ralentizado"]}],
}


func _initialize() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/source/abilities.json"))
	DirAccess.make_dir_recursive_absolute("res://data/abilities")
	var mech: Script = load(MECH)
	var made := {}
	for id in data["abilities"]:
		var a: Dictionary = data["abilities"][id]
		var e: Array = EFFECTS.get(id, ["Por ahora sin efecto.", C_BODY, {}])
		var sd := SignatureData.new()
		sd.id = id
		sd.display_name = a["name_es"]
		sd.description = e[0]
		sd.color = e[1]
		sd.max_value = 0.0
		sd.decay_out_of_combat = 0.0
		sd.mechanic_script = mech
		sd.params = e[2]
		var path := "res://data/abilities/%s.tres" % id
		ResourceSaver.save(sd, path)
		made[id] = load(path)
		if not EFFECTS.has(id):
			print("sin efecto definido: ", id)
	var bosses := 0
	var cleared := 0
	for f in DirAccess.get_files_at("res://data/species"):
		if not f.ends_with(".tres"):
			continue
		var path := "res://data/species/" + f
		var sp: SpeciesData = load(path)
		var list: Array[SignatureData] = []
		for aid in data["species"].get(sp.id, []):
			if made.has(aid):
				list.append(made[aid])
		sp.abilities = list
		if sp.id in BOSSES and sp.kit != null and not sp.kit_inherited:
			sp.boss_kit = sp.kit
			bosses += 1
		if sp.kit != null:
			cleared += 1
		sp.kit = null
		sp.kit_inherited = false
		ResourceSaver.save(sp, path)
	print("habilidades: %d · especies con kit de jefe: %d · kits sacados: %d" % [made.size(), bosses, cleared])
	quit()
